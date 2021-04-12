//
//  Game.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 04/03/2021.
//

import Foundation

enum Mode { case isVersusHuman, isVersusMachine }
enum Level: String { case isDefault, isEasy = "Easy", isMedium = "Medium", isHard = "Hard"}
enum Order: String { case first = "First", second = "Second", chance = "Chance"}

class Game {
   
    static let Medals: [String] = ["🥇", "🥈", "🥉"]
    
    var mode: Mode
    var level: Level = .isDefault
    var player: (main: Player, second: Player)
    var roundPlayed: Int = 0
    
    var queue: [Player] = []
    func switchPlayers() { self.queue.swapAt(0, 1)}
    var attackingPlayer: Player { return queue[0]}
    var defendingPlayer: Player { return queue[1]}
    
    var previousNames: [String] = []
    
    var winner: Player?
    var loser: Player?
    
    init(){
        
        Console.write(0, 1, """
            ✨🦠✨ WELCOME TO MY GAME ✨🍄✨
            """)
        Console.write(1, 1, """
            How do you want to play ?
            1. 🧠 Against a friend
            2. ⚙️ Against the machine
            3. 🕣 Fast play with stock setting
            """.withNum(), 1)
        
        // MARK: A - MODE
        let modePrompt:Int = !Setting.Game.fastPlayEnabled ?
            Console.getIntInput(fromTo: 1...3) : 2
        if modePrompt == 3 {
            Setting.Game.fastPlayEnabled = true
            self.mode = .isVersusMachine
        } else {
            mode = modePrompt == 1 ?
                .isVersusHuman: .isVersusMachine
        }
        
        // MARK: B - MAIN PLAYER
        let mainNamePrompt: String = Console.getStringInput(prompt: "your name")
        player.main = HumanPlayer(mainNamePrompt.uppercased()) as Player
        
        // MARK: C - SECOND PLAYER
        switch mode {
        case .isVersusHuman:
            
            var secondNamePrompt: String = ""
            while true {
                secondNamePrompt = Console.getStringInput(prompt: "the other player's name")
                if secondNamePrompt == player.main.name { Console.write(1, 1, "⚠️ Players can't have the same name : try another ⚠️", 1)}
                else { break }
            }
            player.second = HumanPlayer(secondNamePrompt.uppercased()) as Player
            
        case .isVersusMachine:
            
            Console.newSection()
            player.second = MachinePlayer() as Player
            Console.write(0, 0, "Ok \(player.main.name), I'm \(player.second.name) and I'm your opponent !", 0)
            
            Console.write(1, 1, """
                How do you want me to play ?
                1. 🌸 Easy. You're soft and delicate
                2. 🏓 Medium. Pretty fair one on one
                3. 🎖 Hard. Can't fight the dust
                """.withNum(), 1)
            
            // MARK: D - LEVEL
            if Setting.Game.fastPlayEnabled {
                level = Setting.Game.fastPlayLevel
                Console.write(0, 2, "⬆️. Default setting was applied : \(level.rawValue) ✅", 0)
            } else {
                let levelPrompt: Int = Console.getIntInput(fromTo: 1...3)
                level = levelPrompt == 1 ? .isEasy: levelPrompt == 2 ? .isMedium: .isHard
            }
            
        }
    }
    
    func run(){
        orderStep()
        chooseStep()
        fightStep()
        statStep()
        quit()
    }
    
    func help() -> String {
        var allDamages = Weapon.getAllDamageCases(
                attackers: attackingPlayer.toons,
                defenders: defendingPlayer.toons)
        allDamages.shuffle()
        var defendingIndex: Int = 0
        for toon in defendingPlayer.toons {
            if toon.isAlive() {
                defendingIndex += 1
                toon.promptID = defendingIndex
            }
        }
        var attackingIndex = 0 ; let maxIndex = 3 ; var damageCases: [String] = []
        for damageCase in allDamages {
            attackingIndex += 1 ; if attackingIndex > maxIndex { break }
            damageCases.append("\(String(damageCase.attacker.promptID).withNum()). \(damageCase.attacker.getPicWithName()) 🆚\(String(damageCase.defender.promptID).withNum()) \(damageCase.defender.getPicWithName()) : \(Int(damageCase.damage)) damages ✅")
        }
        let damageCasesAsString: String = damageCases.joined(separator: "\n")
        return "✳️. Help was requested :\n\(damageCasesAsString)"
    }
    
    func quit() {
        Console.write(1, 1, "✨🦠✨ END OF THE GAME ✨🍄✨", 2)
    }
    
}
