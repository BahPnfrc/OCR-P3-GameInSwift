//
//  Game.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 04/03/2021.
//

import Foundation

enum Mode: CaseIterable { case isVersusHuman, isVersusMachine }
enum Level: CaseIterable { case isDefault, easy, medium, hard }

class Game {
    
    var mode: Mode
    var level: Level = .isDefault
    var player: (main: Player, second: Player)
    var queueSaver: [Player] = []
    
    init(){
        // MARK: A - MODE
        Console.write(0, 0, "WELCOME TO THE GAME")
        Console.write(1, 1, """
            How do you want to play ?
            1. 🧠 Against a friend
            2. ⚙️ Against the machine
            """, 1)
        let modePrompt:Int = Console.getIntInput(fromTo: 1...2)
        mode = modePrompt == 1 ? .isVersusHuman: .isVersusMachine
        
        // MARK: B - MAIN PLAYER
        let mainNamePrompt: String = Console.getStringInput(prompt: "your name")
        player.main = Human(mainNamePrompt.uppercased()) as Player
        
        // MARK: C - SECOND PLAYER
        switch mode {
        case .isVersusHuman:
            var secondNamePrompt: String = ""
            while true {
                secondNamePrompt = Console.getStringInput(prompt: "the other player's name")
                if secondNamePrompt == player.main.name { Console.write(1, 1, "⚠️ Players can't have the same name : try another ⚠️", 1)}
                else { break }
            }
            player.second = Human(secondNamePrompt.uppercased()) as Player
        case .isVersusMachine:
            Console.newSection()
            player.second = Machine() as Player
            Console.write(0, 0,
                "Ok \(player.main.name), I'm \(player.second.name) and I'm your opponent !", 0)
            // MARK: D - LEVEL
            Console.write(1, 1, """
                Choose my level :
                1. 🌸 Easy. Because you're soft and delicate
                2. 🏓 Medium. For a real one on one baby
                3. 🪖 Hard. Can't fight the dust !
                """, 1)
            let levelPrompt: Int = Console.getIntInput(fromTo: 1...3)
            level =
                levelPrompt == 1 ? .easy:
                levelPrompt == 2 ? .medium:
                .hard
        }
    }
    
    func run(){
        orderStep()
        chooseStep()
        fightStep()
    }
}

// MARK: E - ORDER PLAYERS
extension Game {
    private func orderStep(){
        Console.newSection()
        Console.write(0, 0, """
            Ok \(player.main.name), two teams will now be made.
            Choosing toons first is penalized by shooting second.
            """)
        Console.write(1, 1, """
            Who choose first :
            1. 🏆 I want to choose first no matter what
            2. 🎳 I'd prefer to shoot first so I'll choose second
            3. 🎲 I'd rather roll the dice and let chance decide
            """, 1)
        let orderPrompt: Int = Console.getIntInput(fromTo: 1...3)
        queueSaver =
            orderPrompt == 1 ? [player.main, player.second] :
            orderPrompt == 2 ? [player.second, player.main] :
            [player.main, player.second].shuffled()
    }
}

// MARK: F - CHOOSE TOONS
extension Game {
    private func chooseStep(){
        let firstToChoose: Player = queueSaver[0]
        let secondToChose: Player = queueSaver[1]
        if self.mode == .isVersusHuman {
            // A - First Player is Human ; B - Second is Human
            _chooseStep_humanChoose(forPlayer: firstToChoose)
            let header = "OK, \(secondToChose.name), it's your turn now."
            _chooseStep_humanChoose(forPlayer: secondToChose, withHeader: header)
        } else {
            if let machine = firstToChoose as? Machine {
                // A - First player is Machine ; B - Second is Human
                _chooseStep_machineChoose(forPlayer: machine)
                _chooseStep_humanChoose(forPlayer: secondToChose)
            }
            else {
                // A - First player is Human ; B - Second is Machine
                _chooseStep_humanChoose(forPlayer: firstToChoose)
                _chooseStep_machineChoose(forPlayer: secondToChose)
            }
        }
        // C - Show both teams
        Console.newSection()
        Console.write(0, 0, "So here are both teams :")
        _ = firstToChoose.listAllToons(aliveOnly: false)
        _ = secondToChose.listAllToons(aliveOnly: false)
    }
    private func _chooseStep_humanChoose(forPlayer human: Player, withHeader header: String? = nil){
        let defaultHeader: String = """
            Ok \(human.name), time is to choose your toons.
            You must pick one Engineer, one Military and one Medical.
            """
        Console.newSection()
        Console.write(0, 0, header ?? defaultHeader)
        let toonTypes = [
             (all: Engineer.All, message: "There it goes Engineers :"),
             (all: Military.All, message: "Time is to pick up a Military now :"),
             (all: Medical.All, message: "You can finally pick up your Medical :")]
        var previousNames: [String] = []
        for toonType in toonTypes { // For each type of toon
            // A - Show message and list all toons
            Console.write(1, 1, toonType.message, 0)
            var maxPromptID: Int = 0
            for toon in toonType.all {
                if !toon.isInTeam {
                    maxPromptID += 1 ; toon.promptID = maxPromptID
                    Console.write(0, 1, toon.getFirstPromptInfos(), 0)
                } else {toon.promptID = 0}
            }
            // B - Prompt to choose a toon by its ID
            Console.emptyLine()
            let promptForNumber: Int = Console.getIntInput(fromTo: 1...maxPromptID)
            let chosenToon: Toon = toonType.all.first(where: {$0.promptID == promptForNumber})!
            // C - Prompt to choose a name for this toon
            var promptForName: String = ""
            while true {
                promptForName = Console.getStringInput(prompt: "a name for this toon")
                if previousNames.contains(promptForName){ Console.write(1, 1, "⚠️ Toons can't have the same name : try another ⚠️", 1)}
                else { previousNames.append(promptForName) ; break }
            }
            chosenToon.name = promptForName.uppercased()
            chosenToon.isInTeam = true
            human.toons.append(chosenToon)
        }
    }
    private func _chooseStep_machineChoose(forPlayer machine: Player) {
        var results: [(ID: Int, globalSet: Double)] = []
        let toonClasses = [Engineer.All, Military.All, Medical.All]
        for toonClass in toonClasses { // For each class of toons
            // A - Copy to an array each toon ID and global set
            var maxPromptID: Int = 0
            for toon in toonClass {
                if !toon.isInTeam {
                    maxPromptID += 1 ; toon.promptID = maxPromptID
                    results.append((toon.promptID, toon.globalSet))
                } else {toon.promptID = 0}
            }
            // B - Order this array according to the level
            switch level {
            case .easy: results.sort { $0.globalSet < $1.globalSet } // Lowest score on top
            case .hard: results.sort { $0.globalSet > $1.globalSet } // Highest score on top
            default: results.shuffle() // Simple shuffle
            }
            // C - Pick the toon at the top [0] index
            let rightToon = toonClass.first(where: {$0.promptID == results[0].ID} )!
            rightToon.name = rightToon.getRandomName().uppercased() // Get a random 1900' style name
            rightToon.isInTeam = true
            machine.toons.append(rightToon)
            results.removeAll() // For next loop
        }
    }
    
}

// MARK: F - FIGHT
extension Game {
    
    private func fightStep() {
        
        Toon.resetAllPromptID()
        var round: Int = 0
        repeat {
            round += 1
            // A - Pick one player
            queueSaver.swapAt(0, 1) // Swap players at each round
            let (attacker, defender) = (queueSaver[0], queueSaver[1])
            
            // B - Lists all toons
            let header: String = "Ok \(attacker.name), pick one of your champions :"
            _ = attacker.listAllToons(aliveOnly: false, header: header)
            // C - Choose one toon
            let choosenToon: Toon = _fightStep_chooseToon(of: attacker)
            // D - Heal
            let toonDidMedicine: Bool = _fightStep_DoMedicine(of: attacker, with: choosenToon)
            if toonDidMedicine { break }
            
        } while _fightStep_CanContinue()
    }
    
    private func _fightStep_chooseToon(of player: Player) -> Toon {
        while true {
            let promptForNumber = Console.getIntInput(fromTo: 1...player.toons.count)
            let choosenToon = player.toons.first(where: { $0.promptID == promptForNumber })!
            if !choosenToon.isAlive() {
                Console.write(1, 1, choosenToon.getPicWithName() + " can't fight : too many damages taken", 1)
            } else { return choosenToon }
        }
    }
    private func _fightStep_DoMedicine(of player: Player, with choosenToon: Toon) -> Bool {
        // A - Quit if toon is not a Medical
        guard let doctor = choosenToon as? Medical else { return false }
        // B - Prepare prompt text
        let pack: [Medicine] = doctor.medicalPack
        var promptID: Int = 0 ; var promptText: String = ""
        for index in 0...2 {
            if pack[index].usage.wasUsed < pack[index].usage.wasUsed {
                promptID += 1 ; pack[index].promptID = promptID
                promptText += "\(promptID). Use a \(pack[index].getPicWithName()) : \(pack[index].usage)\n"
            } else { pack[index].promptID = 0 }
        }
        let weaponPromptID: Int = promptID + 1 ; let maxPromptID = weaponPromptID
        promptText += "\(weaponPromptID). Use \(doctor.weapon!.getPicWithName()) : it blows haters to smithereens"
        // C - Call prompt and get result
        Console.write(1, 1, """
            What do you want to do with \(doctor.name!) ?
            \(promptText)
            """, 1)
        let promptForNumber = Console.getIntInput(fromTo: 1...maxPromptID)
        if promptForNumber == weaponPromptID {return false}
        _fightStep_ApplyMedecine(withID: promptForNumber)
        return true
    }
    private func _fightStep_ApplyMedecine(withID promptID:Int) {
        
        
    }
    private func _fightStep_CanContinue() -> Bool {
        for player in ([player.main, player.second]) { // For each player
            if !player.toons.allSatisfy({ $0.lifeSet.hitpoints == 0 }) {
                return true // Continue
            }
        }
        return false // Stop
    }
    
    
    
    
    private static func applyDamage(from attacker: Toon, to defender: Toon) -> String {
        let biologicDamage: Double = attacker.weapon!.getBiologicDamage()
            * attacker.getBiologicAttack()
            / defender.getBiologicDefense()
        let kineticDamage: Double = attacker.weapon!.getKineticDamage()
            * attacker.getKineticAttack()
            / defender.getKineticDefense()
        let thermicDamage: Double = attacker.weapon!.getThermicDamage()
            * attacker.getThermicAttack()
            / defender.getThermicDefense()

        let givenDamage: Double = (biologicDamage + kineticDamage + thermicDamage)
            * attacker.getStrenght() / defender.getAgility()
            * attacker.getAccuracy() / defender.getForsight()
        
        let expectedDamage = attacker.weapon!.isUpdated == true ?
            Setting.Weapon.expectedUpdatedDamage : Setting.Weapon.expectedBasicDamage
        
        let (action, result) =
            (givenDamage < (expectedDamage * 0.9)) ? (" barely scratched " , " causing "):
            (givenDamage < (expectedDamage * 1.1)) ? (" frontly touched " , " amounting for ") :
            (" perfectly hit " , " wrecking for ")
        
        let message: String = "" // CHANGE
        return message
    }

}
