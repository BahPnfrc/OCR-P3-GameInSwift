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
        Console.write("""
            WELCOME TO THE GAME
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
            Console.write("""
                Ok \(player.main.name), I'm \(player.second.name) and I'm your opponent !

                Choose my level :
                1. Easy : Because you're soft and delicate
                2. Medium : Real one on one baby
                3. Hard : Can't fight the dust
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
        
        if self.mode == .isVersusHuman {
            humanChoose(withHeader: humanHeader.second, for: player.second)
        } else {
            let machineHeader = "OK, I'm choosing my toons as well. Let me see..."
            machineChoose(withHeader: machineHeader)
        }
    }
    private func humanChoose(withHeader header: String, for player: Player){
        Console.write(header)
        let toonTypes = [
             (all: Engineer.All, message: "There it goes all Engineers :"),
             (all: Military.All, message: "Time is to pick up a Military now :"),
             (all: Medical.All, message: "You can finally pick up your Medical :")]
        for toonType in toonTypes { // For each type of toon
            // A - Show message and list all toons
            Console.write(toonType.message)
            for toon in toonType.all { Console.write(toon.getPresentation()) }
            // B - Prompt to choose a toon by its ID
            let promptForNumber: Int = Console.getIntInput(fromTo: 1...toonType.all.count)
            let chosenToon: Toon = toonType.all.first(where: {$0.ID == promptForNumber})!
            // C - Prompt to choose a name for this toon
            let promptForName: String = Console.getStringInput(prompt: "a name for this toon")
            chosenToon.name = promptForName
            player.toons.append(chosenToon)
        }
    }
    private func machineChoose(withHeader header: String) {
        Console.write(header)
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
            default: results.shuffle() // Sort result with shuffle
            }
            // C - Pick toons at the top of the array
            let requestedID: Int = results[0].ID
            let rightToon = toonType.first(where: {$0.ID == requestedID} )!
            rightToon.name = rightToon.getRandomName()
            player.second.toons.append(rightToon)
            results.removeAll()
        }
    }
    
}

// MARK: F - FIGHT
extension Game {
    
    private func fight() {
        //getOrder()
        
        var players = [player.main, player.second]
        repeat {
            let currentPlayer = players[0]
            Console.write("OK \(currentPlayer.name), select a toon of your team :")
            for index in 0...currentPlayer.toons.count { // For each toon left
                currentPlayer.toons[index].ID = index + 1 // Reset its prompt counter
            }
            for toon in currentPlayer.toons {
                if toon.lifeSet.hitpoints > 0 {toon.getPresentation()}
            }
            
            let promptForNumber: Int = Console.getIntInput(fromTo: 1...currentPlayer.toons.count)
            let attacker: Toon = toonType.all.first(where: {$0.ID == promptForNumber})!
            
            
            
            players.swapAt(0, 1)
        } while gameCanContinue()
    }
    
    private func gameCanContinue() -> Bool {
        for player in ([player.main, player.second]) { // For each player
            if !player.toons.allSatisfy({ $0.lifeSet.hitpoints == 0 }) {
                return true // Continue
            }
        }
        return false // Stop
    }
    
    
    
    
    private static func applyDamage(from attacker: Toon, to defender: Toon) -> String {
        let biologicDamage: Double = attacker.tool!.getBiologicDamage()
            * attacker.getBiologicAttack()
            / defender.getBiologicDefense()
        let kineticDamage: Double = attacker.tool!.getKineticDamage()
            * attacker.getKineticAttack()
            / defender.getKineticDefense()
        let thermicDamage: Double = attacker.tool!.getThermicDamage()
            * attacker.getThermicAttack()
            / defender.getThermicDefense()

        let givenDamage: Double = (biologicDamage + kineticDamage + thermicDamage)
            * attacker.getStrenght() / defender.getAgility()
            * attacker.getAccuracy() / defender.getForsight()
        
        let expectedDamage = attacker.tool!.isUpdated == true ?
            Setting.Tool.expectedUpdatedDamage : Setting.Tool.expectedBasicDamage
        
        let (action, result) =
            (givenDamage < (expectedDamage * 0.9)) ? (" barely scratched " , " causing "):
            (givenDamage < (expectedDamage * 1.1)) ? (" frontly touched " , " amounting for ") :
            (" perfectly hit " , " wrecking for ")
        
        let message: String = "" // CHANGE
        return message
    }

}
