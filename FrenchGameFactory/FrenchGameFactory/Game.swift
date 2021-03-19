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
        ConsoleIO.write("""
            WELCOME TO THE GAME
            How do you want to play ?
            1. Against a friend
            2. Against the machine
            """)
        let modePrompt:Int = ConsoleIO.getIntInput(fromTo: 1...2)
        mode = modePrompt == 1 ? .isVersusHuman: .isVersusMachine
        
        // MARK: B - MAIN PLAYER
        let mainNamePrompt: String = ConsoleIO.getStringInput(prompt: "your name")
        player.main = Human(mainNamePrompt) as Player
        
        // MARK: C - SECOND PLAYER
        switch mode {
        case .isVersusHuman:
            let secondNamePrompt = ConsoleIO.getStringInput(prompt: "the other player's name")
            player.second = Human(secondNamePrompt) as Player
        case .isVersusMachine:
            
            // MARK: D - LEVEL
            player.second = Machine() as Player
            ConsoleIO.write("""
                Ok \(player.main.name), I'm \(player.second.name) and I'm your opponent !

                Choose my level :
                1. Easy : Because you're soft and delicate
                2. Medium : Real one on one baby
                3. Hard : Can't fight the dust
                """)
            let levelPrompt: Int = ConsoleIO.getIntInput(fromTo: 1...3)
            level =
                levelPrompt == 1 ? .easy:
                levelPrompt == 2 ? .medium:
                .hard
        }
    }
    
    func thenRun(){
        // MARK: E - CHOOSE TOONS
        let header = (
            main: """
            Ok \(player.main.name), time is to choose your toons.
            You must pick one Engineer, one Military and one Medical.
            """,
            second: "OK, \(player.second.name), it's your turn now.")
        pickToons(for: player.main, withHeader: header.main)
        
        if self.mode == .isVersusHuman {
            pickToons(for: player.second, withHeader: header.second)
        } else {
            machinePickToons() // COMPLETER
        }
    }
    
    private func pickToons(for player: Player, withHeader header: String){
        ConsoleIO.write(header)
        let toonTypes = [
             (array: Engineer.All, message: "There it goes all Engineers :"),
             (array: Military.All, message: "Time is to pick up a Military now :"),
             (array: Medical.All, message: "You can finally pick up your Medical :")]
        for toonType in toonTypes {
            ConsoleIO.write(toonType.message)
            // List all toons
            for toon in toonType.array {
                ConsoleIO.write(toon.getPresentation())
            }
            // Choose a toon by its ID
            let promptForNumber: Int = ConsoleIO.getIntInput(fromTo: 1...toonType.array.count)
            let chosenToon: Toon = toonType.array.first(where: {$0.ID == promptForNumber})!
            // Choose a name for this toon
            let promptForName: String = ConsoleIO.getStringInput(prompt: "a name for this toon")
            chosenToon.name = promptForName
            player.toons.append(chosenToon)
        }
    }
    private func machinePickToons() {
        
        var currentID : Int ; var currentScore: Double
        var results: [(ID: Int, score: Double)] = []
        
        let toonTypes = [Engineer.All, Military.All, Medical.All]
        for toonType in toonTypes { // For a given type of Toon
            for toon in toonType { // Go throught each toon
                (currentID, currentScore) = (toon.ID, toon.averageSet) // Get its ID and score
                results.append((ID: currentID, score: currentScore)) // And add it to results
            }
            switch level { // According to level
            case .easy:
                results.sort { $0.score < $1.score } // Put lowest score first
            case .hard:
                results.sort { $0.score > $1.score } // Sort results from best to lowest
            default:
                results.shuffle() // Sort result by chance
            }
            
            for index in 0...2 { // For first index of results
                let requestedID: Int = results[index].ID
                let rightToon = toonType.first(where: {$0.ID == requestedID} )!
                rightToon.name = "RANDOMNAME"
                player.second.toons.append(rightToon)
            }
        }
        
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
