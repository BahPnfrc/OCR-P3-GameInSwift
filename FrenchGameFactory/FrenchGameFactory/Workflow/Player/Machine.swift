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
    
    private func _getAllDamageCases(attackers: [Toon], defenders: [Toon]) -> [(DmgCase)] {
        var results: [DmgCase] = []
        for attacker in attackers{
            for defender in defenders{
                let damage: Double = Weapon.getDamage(from: attacker, to: defender)
                let isLethal: Bool = defender.lifeSet.hitpoints - Int(damage) <= 0
                let dmgProfil: DmgCase = DmgCase(
                    attacker: attacker,
                    defender: defender,
                    damage: damage,
                    isLethal: isLethal)
                results.append(dmgProfil)
            }
        }
        return results
    }
    
    private func chooseTarget(inGame game: Game) -> (DmgCase){
        let machine: Player = game.attackingPlayer as! Machine
        let human: Player = game.defendingPlayer
        
        var attackCasesOnN0: [DmgCase] = _getAllDamageCases(
                attackers: _aliveOnly(machine.toons),
                defenders: _aliveOnly(human.toons))
        var defenseCasesOnN1:[DmgCase] = _getAllDamageCases(
                attackers: _aliveOnly(human.toons),
                defenders: _aliveOnly(machine.toons))
        
        switch game.level {
        case .isHard:
            attackCasesOnN0.sort { $0.isLethal && $0.damage > $1.damage } // Damages computer can give
            defenseCasesOnN1.sort { $0.isLethal && $0.damage > $1.damage } // Damages computer can receive
        case .isEasy:
            attackCasesOnN0.sort { !$0.isLethal && $0.damage < $1.damage }
            defenseCasesOnN1.sort { !$0.isLethal && $0.damage < $1.damage }
        default:
            attackCasesOnN0.sort { $0.damage > $1.damage }
            defenseCasesOnN1.sort { $0.damage > $1.damage }
            attackCasesOnN0.shuffle() ; defenseCasesOnN1.shuffle()
        }
        
            
        let canTake_orBestCase = _check_1_canTake_OrBestCase(attackCases: attackCasesOnN0)
        let canLose_orWorstCase = _check_2_canLose_orWorstCase(defenseCases: defenseCasesOnN1)
        let shouldAttackDoctor = _check_5_shouldAttackDoctor(attackCases: attackCasesOnN0)
        
        switch canLose_orWorstCase.result {
        case false: // A - Machine can't lose toon on N1
            
            if canTake_orBestCase.result == true { return canTake_orBestCase.playPattern } // 1° : Take out any
            else if shouldAttackDoctor.result == true { return shouldAttackDoctor.playPattern! } // 2° : Take out Doctor second
            else { return canTake_orBestCase.playPattern } // 3° : Do best case third
        
        case true: // B - Machine can lose toon on N1
            
            let threatIsBestTarget = _check_3_threatIsBestTarget(
                attackCases: attackCasesOnN0,
                defenseCases: defenseCasesOnN1)
            
            switch threatIsBestTarget.result {
            case true:
                
                return threatIsBestTarget.playPattern! // 4° : Kill threat
            
            case false:
                
                let check_4 = _check_4_outnumberOrEqual(machine: game.attackingPlayer, human: game.defendingPlayer)
                if check_4 == true {
                    let check_5 = _check_5_shouldAttackDoctor(attackCases: attackCasesOnN0)
                    if check_5.result == true { return check_5.playPattern! } // Attack the doctor with highest damage
                    
                } else {
                    
                }
            
            }
        }
    
        
            
        

            
        
     
    }
    
    private func _getHardCase() {
        
    }
    private func _getEasyCase() {
        
    }
    private func _getElseCase() {
        
    }
    
    private func _aliveOnly(_ toons: [Toon]) -> [Toon] {
        return toons.filter({ $0.isAlive() })
    }
    
    private func _chooseCaseOnIndexZero(attackCases: [DmgCase]) {
        
        
    }
    
    private func _check_1_canTake_OrBestCase(attackCases: [DmgCase])
    -> (result: Bool, playPattern: DmgCase) {
        guard let canKillCase = attackCases.first(where: {$0.isLethal == true}) else {
            let elseCase = attackCases.first(where: {$0.isLethal == false})!
            return (false, elseCase)
        }
        return (true, canKillCase)
    }
    // If true assign target ; Else do :
    private func _check_2_canLose_orWorstCase(defenseCases: [DmgCase])
    -> (result: Bool, playPattern: DmgCase) {
        guard let canBeKilledCase = defenseCases.first(where: {$0.isLethal == true}) else {
            let elseCase = defenseCases.first(where: {$0.isLethal == false})!
            return (false, elseCase)
        }
        return (true, canBeKilledCase)
    }
    // If true assign target ; Else do :
    private func _check_3_threatIsBestTarget(attackCases: [DmgCase], defenseCases: [DmgCase])
    -> (result: Bool, playPattern: DmgCase?) {
        for defenseCase in defenseCases {
            if defenseCase.isLethal {
                for attackCase in attackCases {
                    if attackCase.isLethal && attackCase.defender.ID == defenseCase.attacker.ID {
                        return (true, attackCase) // The N+1 lethal attacker can be killed at N
                    }
                }
            }
        }
        return (false, nil)
    }
    // If true assign target ; Else do :
    private func _check_4_outnumberOrEqual(machine: Player, human: Player) -> Bool {
        var attackerLeftToons: Int = 0
        var defenderLeftToons: Int = 0
        for toon in machine.toons { if toon.isAlive() { attackerLeftToons += 1 }}
        for toon in human.toons { if toon.isAlive() { defenderLeftToons += 1 }}
        return attackerLeftToons >= defenderLeftToons ? true : false
    }
    // If true assign target ; Else do :
    private func _check_5_shouldAttackDoctor(attackCases: [DmgCase])
    -> (result: Bool, playPattern: DmgCase?) {
        // A - Pick only cases where defender is Medical
        var attackOnDoctor = attackCases.filter({ $0.defender is Medical})
        guard attackOnDoctor.count > 0 else { return (false, nil) }
        // B - Sort them by highest damage
        attackOnDoctor.sort { $0.isLethal && $0.damage > $1.damage }
        // C - If any medicine is left then attack
        let doctor = attackOnDoctor[0].defender as! Medical
        if !doctor.medicalPack.allSatisfy({ $0.left == 0 }) {
            return (true, attackOnDoctor[0])
        }
        return (false, nil)
    }
    
    private func _check_5b_shouldUseMedicine() {
        
    }
    
    // If true assign target ; Else do :
    private func _check_6_shouldUseMedicine() -> (Bool) {
        
        
        return false
    }
}
