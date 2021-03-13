//
//  Game.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 04/03/2021.
//

import Foundation

enum Mode: CaseIterable { case isVersusHuman, isVersusMachine }

class Game {
    
    
    
    static func applyDamage(from attacker: Toon, to defender: Toon, with tool: Tool) -> Void {
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
        
        let message: String =
            attacker.getFullName()
            + action
            + defender.getFullName()
            + (attacker.gender == Gender.isMan ? " with his " : " with her ")
            + tool.getFullName()
            + result + String(format: "%", givenDamage) + " hitpoints"
    }
    
    
    
    
    init (){
        ConsoleIO.write("""
            WELCOME TO THE GAME

            How do you want to play ?
            1. Against a friend
            2. Against the machine
            """)
        
    }

}

