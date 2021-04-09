//
//  CheckExtension.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 09/04/2021.
//

import Foundation

extension MachinePlayer {
    // MARK: B - Check for damages
    func check_aliveOnly(_ toons: [Toon]) -> [Toon] {
        return toons.filter({ $0.isAlive() == true })
    }

    func check_getAllDamageCases(attackers: [Toon], defenders: [Toon]) -> [(DamageCase)] {
        var results: [DamageCase] = []
        for attacker in attackers{
            for defender in defenders{
                let damage: Double = Weapon.getDamage(from: attacker, to: defender)
                let isLethal: Bool = defender.lifeSet.hitpoints - Int(damage) <= 0
                let damageCase: DamageCase = DamageCase(
                    attacker: attacker,
                    defender: defender,
                    damage: damage,
                    isLethal: isLethal)
                results.append(damageCase)
            }
        }
        return results
    }

    // MARK: C - Check for scenarii
    func check_canTakeToonOrBestCase(attackCases: [DamageCase])
    -> (result: Bool, playPattern: DamageCase) {
        guard let canKillCase = attackCases.first(where: {$0.isLethal == true}) else {
            let elseCase = attackCases[0] // Top case after sort
            return (false, elseCase)
        }
        return (true, canKillCase)
    }

    func check_canLoseToonOrWorstCase(defenseCases: [DamageCase])
    -> (result: Bool, playPattern: DamageCase) {
        guard let canBeKilledCase = defenseCases.first(where: {$0.isLethal == true}) else {
            let elseCase = defenseCases[0] // Top case after sort
            return (false, elseCase)
        }
        return (true, canBeKilledCase)
    }

    func check_canTakeOutNextRoundThreat(attackCases: [DamageCase], defenseCases: [DamageCase])
    -> (result: Bool, playPattern: DamageCase?) {
        for defenseCase in defenseCases {
            if defenseCase.isLethal {
                for attackCase in attackCases {
                    if attackCase.isLethal && attackCase.defender.ID == defenseCase.attacker.ID {
                        return (true, attackCase) // Take out the threat of N1 on N0
                    }
                }
            }
        }
        return (false, nil)
    }

    func check_machineOutnumbers(machine: Player, human: Player) -> Bool {
        var machineToons: Int = 0
        var humanToons: Int = 0
        for toon in machine.toons { if toon.isAlive() { machineToons += 1 }}
        for toon in human.toons { if toon.isAlive() { humanToons += 1 }}
        return machineToons > humanToons ? true : false
    }

    // MARK: D - Check for medical
    func check_shouldAttackDoctor(attackCases: [DamageCase])
    -> (result: Bool, playPattern: DamageCase?) {
        // A - Pick only cases where defender is Medical
        var attackOnDoctor = attackCases.filter({ $0.defender is MedicalToon})
        guard attackOnDoctor.count > 0 else { return (false, nil) }
        // B - Sort them by highest damage
        attackOnDoctor.sort { $0.damage > $1.damage }
        // C - If any medicine is left then attack
        let doctor = attackOnDoctor[0].defender as! MedicalToon
        if !doctor.medicalPack.allSatisfy({ $0.left == 0 }) {
            return (true, attackOnDoctor[0])
        }
        return (false, nil)
    }
    
    func check_shouldUseMedicine(machine: Player)
    -> (result: Bool, withMedicine: Medicine?, onToon: Toon?){
        // A - See if doctor and medicines are left
        guard let isDoctor = machine.toons.first(where: { $0.self is MedicalToon }) else { return (false, nil, nil) }
        let doctor: MedicalToon = isDoctor as! MedicalToon ; guard doctor.isAlive() else { return (false, nil, nil) }
        guard !doctor.medicalPack.allSatisfy({ $0.left == 0 }) else { return (false, nil, nil) }
        // B - Get all medicine use cases in array
        var medicineCases: [(toon: Toon, medicine: Medicine, gain: Int)] = []
        for medicine in doctor.medicalPack { // For each medicine
            guard medicine.left > 0 else { continue }
            let restoreTo: Double = Double(Setting.Toon.defaultLifeSet.hitpoints) * medicine.factor
            for toon in machine.toons { // On each toon
                guard toon.isAlive() else { continue }
                let gain: Int = Int(restoreTo) - toon.lifeSet.hitpoints
                if gain > 0 { medicineCases.append((toon, medicine, gain)) } // Save case
            }
        }
        guard medicineCases.count > 0 else { return (false, nil, nil) }
        let toonsUnderPercent50 = medicineCases.filter({ $0.medicine.type == .isHeavy})
        var toonsUnderPercent70 = medicineCases.filter({ $0.medicine.type == .isLight })
        var toonsUnderPercent90 = medicineCases.filter({ $0.medicine.type == .isMedium })
        
        if toonsUnderPercent50.count > 1 && toonsUnderPercent50.allSatisfy( {$0.gain > 150 } ) {
            // C1 - Heavy medicine use if 2 toons at least are under 50%
            return (true, toonsUnderPercent50[0].medicine, nil)
        } else if toonsUnderPercent90.count > 0 {
            // C2 - Medium medicine use if 1 toon is under 90%
            toonsUnderPercent90.sort { $0.gain > $1.gain }
            return (true, toonsUnderPercent90[0].medicine, toonsUnderPercent90[0].toon)
        } else if toonsUnderPercent70.count > 0 {
            // C3 - Light medicine use if 1 toon is under 70%
            toonsUnderPercent70.sort { $0.gain > $1.gain }
            return (true, toonsUnderPercent70[0].medicine, toonsUnderPercent70[0].toon)
        } else if toonsUnderPercent50.count == 1 { // C4 - Single 50% use
            return (true, toonsUnderPercent50[0].medicine, nil)
        } // No case matched
        else { return (false, nil, nil) }
    }
}
