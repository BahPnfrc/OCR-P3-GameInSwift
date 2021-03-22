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
    
    
    init(){
        // MARK: A - MODE
        Console.write(0, 0, "WELCOME TO THE GAME", 0)
        Console.write(1, 1, """
            How do you want to play ?
            1. Against a friend
            2. Against the machine
            """)
        let modePrompt:Int = Console.getIntInput(fromTo: 1...2)
        mode = modePrompt == 1 ? .isVersusHuman: .isVersusMachine
        
        // MARK: B - MAIN PLAYER
        let mainNamePrompt: String = Console.getStringInput(prompt: "your name")
        player.main = Human(mainNamePrompt) as Player
        
        // MARK: C - SECOND PLAYER
        switch mode {
        case .isVersusHuman:
            let secondNamePrompt = Console.getStringInput(prompt: "the other player's name")
            player.second = Human(secondNamePrompt) as Player
        case .isVersusMachine:
            
            // MARK: D - LEVEL
            player.second = Machine() as Player
            Console.write(1, 0,
                "Ok \(player.main.name), I'm \(player.second.name) and I'm your opponent !", 0)
            Console.write(1, 1, """
                Choose my level :
                1. 🌸 Easy : Because you're soft and delicate
                2. 🏓 Medium : Real one on one baby
                3. 🪖 Hard : Can't fight the dust
                """)
            let levelPrompt: Int = Console.getIntInput(fromTo: 1...3)
            level =
                levelPrompt == 1 ? .easy:
                levelPrompt == 2 ? .medium:
                .hard
        }
    }
    
    func run(){
        chooseToons()
    }
}

// MARK: E - CHOOSE TOONS
extension Game {
    private func chooseToons(){
        let humanHeader = (
            main: """
            Ok \(player.main.name), time is to choose your toons.
            You must pick one Engineer, one Military and one Medical.
            """,
            second: "OK, \(player.second.name), it's your turn now.")
        humanChoose(withHeader: humanHeader.main, for: player.main)
        _ = player.main.listAllToons(aliveOnly: false)
        
        
        if self.mode == .isVersusHuman {
            humanChoose(withHeader: humanHeader.second, for: player.second)
        } else {
            let machineHeader = "OK, I'm choosing my toons as well. Let me see..."
            machineChoose(withHeader: machineHeader)
        }
        _ = player.second.listAllToons(aliveOnly: false)
    }
    private func humanChoose(withHeader header: String, for player: Player){
        Console.write(1, 0, header)
        let toonTypes = [
             (all: Engineer.All, message: "There it goes all Engineers :"),
             (all: Military.All, message: "Time is to pick up a Military now :"),
             (all: Medical.All, message: "You can finally pick up your Medical :")]
        for toonType in toonTypes { // For each type of toon
            // A - Show message and list all toons
            Console.write(0, 1, toonType.message, 0)
            for toon in toonType.all { Console.write(0, 1, toon.getFirstPromptInfos(), 0) }
            // B - Prompt to choose a toon by its ID
            Console.newLign()
            let promptForNumber: Int = Console.getIntInput(fromTo: 1...toonType.all.count)
            let chosenToon: Toon = toonType.all.first(where: {$0.ID == promptForNumber})!
            // C - Prompt to choose a name for this toon
            let promptForName: String = Console.getStringInput(prompt: "a name for this toon")
            chosenToon.name = promptForName
            player.toons.append(chosenToon)
        }
    }
    private func machineChoose(withHeader header: String) {
        Console.write(0, 0, header)
        let toonTypes = [Engineer.All, Military.All, Medical.All]
        var currentID : Int ; var currentScore: Double
        var results: [(ID: Int, score: Double)] = []
        for toonType in toonTypes { // For each type of toon
            // A - Copy its score and associated ID to an array
            for toon in toonType { // For each toon of this type
                (currentID, currentScore) = (toon.ID, toon.globalSet) // Get ID and score
                results.append((ID: currentID, score: currentScore)) // Add them to results
            }
            // B - Order this array according to the level
            switch level {
            case .easy: results.sort { $0.score < $1.score } // Put lowest score on top
            case .hard: results.sort { $0.score > $1.score } // Put highest score on top
            default: results.shuffle() // Simple shuffle
            }
            // C - Pick toons at the top of the array
            let requestedID: Int = results[0].ID
            let rightToon = toonType.first(where: {$0.ID == requestedID} )!
            rightToon.name = rightToon.getRandomName()
            player.second.toons.append(rightToon)
            results.removeAll() // For next loop
        }
    }
    
}

// MARK: F - FIGHT
extension Game {
    
    private func fight() {
        
        fightResetToonsID()
        var round: Int = 0
        //getOrder()
        
        var players = [player.main, player.second]
        repeat {
            round += 1
            // A - Pick one player
            let (attacker, defender) = (players[0], players[1]) // Get the first player
            players.swapAt(0, 1) // Swap for the next round
            // B - Lists all toons
            fightListToons(of: attacker, with: "OK \(attacker.name), pick your champion :")
            // C - Choose one toon
            let choosenToon: Toon = fightPickToon(of: attacker)
            // D - Heal
            let usedHeal: Bool = fightDoMedicine(of: attacker, with: choosenToon)
            if usedHeal { break }
            
        } while fightCanContinue()
    }
    

    private func fightResetToonsID() {
        for player in ([player.main, player.second]) { // For each player
            for index in 0...player.toons.count {
                player.toons[index].ID = index + 1
            }
        }
    }
    private func fightListToons(of player: Player, with header: String) {
        Console.write(0, 1, header)
        for currentToon in player.toons {
            Console.write(0, 1, currentToon.getFightInfos())
        }
    }
    private func fightPickToon(of player: Player) -> Toon {
        while true {
            let promptForNumber = Console.getIntInput(fromTo: 1...player.toons.count)
            let choosenToon = player.toons.first(where: { $0.ID == promptForNumber })!
            if !choosenToon.isAlive() {
                Console.write(1, 1, choosenToon.getPicWithName() + " can't fight anymore", 1)
            } else { return choosenToon }
        }
    }
    private func fightDoMedicine(of player: Player, with choosenToon: Toon) -> Bool {
        guard let doctor = choosenToon as? Medical else {
           return false
        }
        Console.write(1, 1, """
            What do you want to do with \(doctor.name!) ?
            1. Bring medical help to my team
            2. \(doctor.weapon!.pic) Blow the enemy to smithereens
            """)
        let promptForNumber = Console.getIntInput(fromTo: 1...2)
        
        
        return true
        
        
    }
    private func fightCanContinue() -> Bool {
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
