//
//  Machine.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 22/03/2021.
//

import Foundation

final class Machine: Player {
    
    private static let randomNames: [String] = []
    private static var randomName: String {
            Machine.randomNames.count > 0 ?
            Machine.randomNames.randomElement()!:
            "MACHINE"}
    
    init(_ name: String?) {
        guard let name = name else {
            super.init(named: Machine.randomName)
            return
        }
        super.init(named: name)
    }
    
    convenience init() {
        self.init(Machine.randomName)
    }
    
    private func chooseTarget(inGame game: Game) -> (attacker: Toon, defender: Toon){
        let machine: Player = game.attackingPlayer as! Machine
        let human: Player = game.defendingPlayer
        
        var attackingCases: [(attackingID: Int, defendingID: Int, damage: Double, isLethal: Bool)]
            = _getDamageProfil(attackingToons: machine.toons, defendingToons: human.toons)
        var defendingCase:[(attackingID: Int, defendingID: Int, damage: Double, isLethal: Bool)]
            = _getDamageProfil(attackingToons: human.toons, defendingToons: machine.toons)
        
        let bestAttackingCase: (attackingID: Int, defendingID: Int, damage: Double, isLethal: Bool)
        let worstDefendingCase: (attackingID: Int, defendingID: Int, damage: Double, isLethal: Bool)
        switch game.level {
        case .isHard:
            attackingCases.sort { $0.isLethal && $0.damage > $1.damage } // Damages computer can give
            defendingCase.sort { $0.isLethal && $0.damage > $1.damage } // Damages computer can receive
            bestAttackingCase =
                attackingCases.first(where: {$0.isLethal == true}) ?? // First lethal strike
                attackingCases.first(where: {$0.isLethal == false})! // Or highest damage given
            worstDefendingCase =
                defendingCase.first(where: {$0.isLethal == true}) ?? // First lethal strike
                defendingCase.first(where: {$0.isLethal == false})! // Or highest damage received
        
            let choosenAttacker: Toon = machine.toons.first { $0.ID == bestAttackingCase.attackingID }!
            let choosenDefender: Toon = human.toons.first { $0.ID == bestAttackingCase.defendingID}!
        
            
        case .isEasy:
            attackingCases.sort { !$0.isLethal && $0.damage < $1.damage }
            defendingCase.sort { !$0.isLethal && $0.damage < $1.damage }
            bestAttackingCase = attackingCases.first(where: {$0.isLethal == false}) ?? attackingCases[0]
            worstDefendingCase = defendingCase.first(where: {$0.isLethal == false}) ?? defendingCase[0]
            
        default:
            attackingCases.sort { $0.damage > $1.damage }
            defendingCase.sort { $0.damage > $1.damage }
            attackingCases.shuffle() ; defendingCase.shuffle()
            bestAttackingCase = attackingCases.first(where: {$0.isLethal == false}) ?? attackingCases[3]
            worstDefendingCase = defendingCase.first(where: {$0.isLethal == false}) ?? defendingCase[3]
            
        }
        
        let choosenAttacker: Toon = machine.toons.first { $0.ID == bestAttackingCase.attackingID }!
        let choosenDefender: Toon = human.toons.first { $0.ID == bestAttackingCase.defendingID}!
        return (choosenAttacker, choosenDefender)
    }
    private func _getDamageProfil(attackingToons: [Toon], defendingToons: [Toon]) -> [(Int, Int, Double, Bool)] {
        var results: [(attackingID: Int, defendingID: Int, damage: Double, isLethal: Bool)] = []
        for attackingToon in attackingToons{
            for defendingToon in defendingToons{
                let damage: Double = Weapon.getDamage(from: attackingToon, to: defendingToon)
                let isLethal: Bool = defendingToon.lifeSet.hitpoints - Int(damage) <= 0
                results.append((attackingToon.ID, defendingToon.ID, damage, isLethal))
            }
        }
        return results
    }
    private func _getHardCase() {
        
    }
    private func _getEasyCase() {
        
    }
    private func _getElseCase() {
        
    }
}
