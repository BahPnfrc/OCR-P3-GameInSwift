//
//  MachinePlayer.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 22/03/2021.
//

import Foundation

final class MachinePlayer: Player {
    
    private static let randomNames: [String] = []
    private static var randomName: String {
            MachinePlayer.randomNames.count > 0 ?
            MachinePlayer.randomNames.randomElement()!:
            "MACHINE"}
    
    var attackCasesOnN0: [DamageCase] = []
    var defenseCasesOnN1: [DamageCase] = []
    
    init(_ name: String?) {
        guard let name = name else {
            super.init(named: MachinePlayer.randomName)
            return
        }
        super.init(named: name)
    }
    
    convenience init() {
        self.init(MachinePlayer.randomName)
    }
    
    // MARK: A - Machine IA Play
    func PlayWithIA (game: Game)
    -> (attackCase: DamageCase?, medicineCase: (useMedicine: Medicine, onToon: Toon?)?){
        // A - Get players
        let machine: Player = game.attackingPlayer as! MachinePlayer
        let human: Player = game.defendingPlayer
        // B - Get all damages toons can deal to each others
        self.attackCasesOnN0 = Weapon.getAllDamageCases( // On this round N0
                attackers: machine.toons,
                defenders: human.toons)
        self.defenseCasesOnN1 = Weapon.getAllDamageCases( // On next round N1
                attackers: human.toons,
                defenders: machine.toons)
        // C - Sort damages cases according to level
        switch game.level {
        case .isEasy: return play_Easy()
        case .isHard: return play_Hard()
        default: return play_Medium()
        }
    }
}
