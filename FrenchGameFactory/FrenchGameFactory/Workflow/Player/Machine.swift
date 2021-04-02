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
    
    private func _aliveOnly(_ toons: [Toon]) -> [Toon] {
        return toons.filter({ $0.isAlive() })
    }
    
    func play (inGame game: Game)
    -> (attackCase: DmgCase?, medicineCase: (useMedicine: Medicine, onToon: Toon)?){
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
            
        let canTakeToonOrBestCase = _canTakeToonOrBestCase(attackCases: attackCasesOnN0)
        let canLoseToonOrWorstCase = _canLoseToonOrWorstCase(defenseCases: defenseCasesOnN1)
        let shouldAttackDoctor = _shouldAttackDoctor(attackCases: attackCasesOnN0)
        
        switch canLoseToonOrWorstCase.result {
        case false: // A1 - Machine can't lose toon on N1
            
            if canTakeToonOrBestCase.result == true { return (canTakeToonOrBestCase.playPattern, nil) } // 1° : Take out any
            else if shouldAttackDoctor.result == true { return (shouldAttackDoctor.playPattern!, nil) } // 2° : Take out Doctor primarily
            else { return (canTakeToonOrBestCase.playPattern, nil) } // 3° : Play best case
        
        case true: // A2 - Machine can lose toon on N1
            
                let canTakeOutNextRoundThreat = _canTakeOutNextRoundThreat(
                        attackCases: attackCasesOnN0,
                        defenseCases: defenseCasesOnN1)
                
                switch canTakeOutNextRoundThreat.result {
                case true: // B1 - Machine can take out threat
                    
                    return (canTakeOutNextRoundThreat.playPattern!, nil) // 4° : Take out threat
            
            case false: // B2 - Machine can't take out threat
                
                let asManyOrMoreToonsLeft = _asManyOrMoreToonsLeft(machine: game.attackingPlayer, human: game.defendingPlayer)
                
                switch asManyOrMoreToonsLeft {
                case true: // C1 - Machine outnumber or equals Human
                    if shouldAttackDoctor.result == true { return (shouldAttackDoctor.playPattern!, nil) } // 5° : Take out Doctor primarily
                    else { return (canTakeToonOrBestCase.playPattern, nil) } // 6° : Play best case
                    
                case false: // C2 - Human outnumbers or equals Machine
                    
                    let shoudlUseMedicine = _shouldUseMedicine(machine: game.attackingPlayer)
                    switch shoudlUseMedicine.result {
                    case true: // D1 : Team suffers injuries
                        
                        // 7° : Use medicine if necessary
                        guard let returnedMedicine = shoudlUseMedicine.withMedicine,
                              let returnedToon = shoudlUseMedicine.onToon
                        else { fallthrough }
                        return (nil, (returnedMedicine, returnedToon))
                        
                    case false: // D2 Team suffers not injuries
                        return (canTakeToonOrBestCase.playPattern, nil)// 6° : Play best case
                    }
                   
                }
            }
        }
    }

    private func _canTakeToonOrBestCase(attackCases: [DmgCase])
    -> (result: Bool, playPattern: DmgCase) {
        guard let canKillCase = attackCases.first(where: {$0.isLethal == true}) else {
            let elseCase = attackCases.first(where: {$0.isLethal == false})!
            return (false, elseCase)
        }
        return (true, canKillCase)
    }
    // If true assign target ; Else do :
    private func _canLoseToonOrWorstCase(defenseCases: [DmgCase])
    -> (result: Bool, playPattern: DmgCase) {
        guard let canBeKilledCase = defenseCases.first(where: {$0.isLethal == true}) else {
            let elseCase = defenseCases.first(where: { $0.isLethal == false} )!
            return (false, elseCase)
        }
        return (true, canBeKilledCase)
    }
    // If true assign target ; Else do :
    private func _canTakeOutNextRoundThreat(attackCases: [DmgCase], defenseCases: [DmgCase])
    -> (result: Bool, playPattern: DmgCase?) {
        for defenseCase in defenseCases {
            if defenseCase.isLethal {
                for attackCase in attackCases {
                    if attackCase.isLethal && attackCase.defender.ID == defenseCase.attacker.ID {
                        return (true, attackCase) // Take out on N0 the threat of N1
                    }
                }
            }
        }
        return (false, nil)
    }
    // If true assign target ; Else do :
    private func _asManyOrMoreToonsLeft(machine: Player, human: Player) -> Bool {
        var attackerLeftToons: Int = 0
        var defenderLeftToons: Int = 0
        for toon in machine.toons { if toon.isAlive() { attackerLeftToons += 1 }}
        for toon in human.toons { if toon.isAlive() { defenderLeftToons += 1 }}
        return attackerLeftToons >= defenderLeftToons ? true : false
    }
    // If true assign target ; Else do :
    private func _shouldAttackDoctor(attackCases: [DmgCase])
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
    
    private func _shouldUseMedicine(machine: Player)
    -> (result: Bool, withMedicine: Medicine?, onToon: Toon?){
        // A - See if doctor and medicines are left
        guard let isDoctor = machine.toons.first(where: { $0.self is Medical }) else { return (false, nil, nil) }
        let doctor: Medical = isDoctor as! Medical ; guard doctor.isAlive() else { return (false, nil, nil) }
        guard !doctor.medicalPack.allSatisfy({ $0.left == 0 }) else { return (false, nil, nil) }
        // B - Get all medicine use cases in array
        var medicineCases: [(toon: Toon, medicine: Medicine, gain: Int)] = []
        for medicine in doctor.medicalPack { // For each medicine
            guard medicine.left > 0 else { continue }
            let restoreTo: Double = Double(Setting.Toon.defaultLifeSet.hitpoints) * medicine.factor
            for toon in machine.toons { // On each toon
                guard toon.isAlive() else { continue }
                let gain: Int = Int(restoreTo) - toon.getPercentLeft()
                if gain > 0 { medicineCases.append((toon, medicine, gain)) } // Save case
            }
        }
        guard medicineCases.count > 0 else { return (false, nil, nil) }
        let heavyMedicineNeed = medicineCases.filter({ $0.medicine.type == .isHeavy})
        var lightMedicineNeed = medicineCases.filter({ $0.medicine.type == .isLight })
        var mediumMedicineNeed = medicineCases.filter({ $0.medicine.type == .isMedium })
        
        if heavyMedicineNeed.count > 1 && heavyMedicineNeed.allSatisfy( {$0.gain > 100 } ) {
            // C1 - Heavy medicine use if 2 toons at least are under 50%
            return (true, heavyMedicineNeed[0].medicine, nil)
        } else if lightMedicineNeed.count > 0 {
            // C2 - Light medicine use if 1 toon is under 70%
            lightMedicineNeed.sort { $0.gain > $1.gain }
            return (true, lightMedicineNeed[0].medicine, lightMedicineNeed[0].toon)
        } else {
            // C3 - Medium medicine use if 1 toon is under 90%
            mediumMedicineNeed.sort { $0.gain > $1.gain }
            return (true, mediumMedicineNeed[0].medicine, mediumMedicineNeed[0].toon)
        }
    }
}
