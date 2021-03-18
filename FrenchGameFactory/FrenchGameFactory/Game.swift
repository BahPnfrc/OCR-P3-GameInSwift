//
//  Game.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 04/03/2021.
//

import Foundation



enum Mode: CaseIterable { case isVersusHuman, isVersusMachine }




class Game {
    
    var mode: Mode
    var player: (main: Player, second: Player)
        
    var mainPlayer: String { player.main.name }
    var secondPlayer: String { player.second.name }
    
    
    func getFullNameWithTool(off toon: Toon) -> String {
        return ""
    }
    
    
    private static func welcome() {
        ConsoleIO.write("""
            WELCOME TO THE GAME
            """)
    }
    
    init(){
        Game.welcome()
        // A - MODE
        ConsoleIO.write("""
            How do you want to play ?
            1. Against a friend
            2. Against the machine
            """)
        let modePrompt:Int = ConsoleIO.getIntInput(fromTo: 1...2)
        mode = modePrompt == 1 ? .isVersusHuman: .isVersusMachine
        // B - MAIN PLAYER
        let mainNamePrompt: String = ConsoleIO.getStringInput(prompt: "your name")
        player.main = Human(mainNamePrompt) as Player
        // C - SECOND PLAYER
        switch mode {
        case .isVersusHuman:
            let secondNamePrompt = ConsoleIO.getStringInput(prompt: "the second player's name")
            player.second = Human(secondNamePrompt) as Player
        case .isVersusMachine:
            let machine = Machine()
            // D - LEVEL
            ConsoleIO.write("""
                Ok \(player.main.name), I'm \(machine.name) and I'll be your opponent !

                Choose my level :
                1. Easy : Because you're soft and delicate
                2. Medium : Real one on one baby
                3. Hard : Can't fight the dust
                """)
            let levelPrompt: Int = ConsoleIO.getIntInput(fromTo: 1...3)
            machine.level =
                levelPrompt == 1 ? .easy:
                levelPrompt == 2 ? .medium:
                .hard
            player.second = machine
        }
    }
    
    func run(){
        chooseToon(for: player.main)
        chooseToon(for: player.second)
    }
    
    private func chooseToon(for player: Player){
        ConsoleIO.write("""
            Ok \(player.name), time is to choose your toons.
            You must pick one Engineer, one Military and one Medical.
            """)
        
        let toonTuples = [
             (array: Engineer.All, message: "There it goes all Engineers :"),
             (array: Military.All, message: "Time is to pick up a Military now :"),
             (array: Medical.All, message: "You can finally pick up your Medical :")]
        
        for toonTuple in toonTuples {
            ConsoleIO.write(toonTuple.message)
            for eachToon in toonTuple.array {
                ConsoleIO.write(eachToon.getPresentation())
            }
            let prompt = ConsoleIO.getIntInput(fromTo: 1...toonTuple.array.count)
            player.toons?.append(toonTuple.array.first(where: {$0.ID == prompt})!)
        }
    }
    
    static func applyDamage(from attacker: Toon, to defender: Toon, with tool: Tool) -> String {
        let biologicDamage: Double = tool.getBiologicDamage()
            * attacker.getBiologicAttack()
            / defender.getBiologicDefense()
        let kineticDamage: Double = tool.getKineticDamage()
            * attacker.getKineticAttack()
            / defender.getKineticDefense()
        let thermicDamage: Double = tool.getThermicDamage()
            * attacker.getThermicAttack()
            / defender.getThermicDefense()

        let givenDamage: Double = (biologicDamage + kineticDamage + thermicDamage)
            * attacker.getStrenght() / defender.getAgility()
            * attacker.getAccuracy() / defender.getExperience()
        
        let expectedDamage = tool.isUpdated == true ?
            Setting.Tool.expectedUpdatedDamage : Setting.Tool.expectedBasicDamage
        
        let (action, result) =
            (givenDamage < (expectedDamage * 0.9)) ? (" barely scratched " , " causing "):
            (givenDamage < (expectedDamage * 1.1)) ? (" frontly touched " , " amounting for ") :
            (" perfectly hit " , " wrecking for ")
        
        let message: String = "" // CHANGE
        return message
    }

}
