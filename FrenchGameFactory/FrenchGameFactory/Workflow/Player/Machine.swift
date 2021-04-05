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
    
    //private let game: Game
    private var attackCasesOnN0: [DmgCase] = []
    private var defenseCasesOnN1: [DmgCase] = []
    
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
    
    // MARK: Machine IA Play
    func PlayWithIA (game: Game)
    -> (attackCase: DmgCase?, medicineCase: (useMedicine: Medicine, onToon: Toon?)?){
        // A - Get players
        let machine: Player = game.attackingPlayer as! Machine
        let human: Player = game.defendingPlayer
        // B - Get all damages toons can deal to each others
        self.attackCasesOnN0 = _getAllDamageCases( // On this round N0
                attackers: _aliveOnly(machine.toons),
                defenders: _aliveOnly(human.toons))
        self.defenseCasesOnN1 = _getAllDamageCases( // On next round N1
                attackers: _aliveOnly(human.toons),
                defenders: _aliveOnly(machine.toons))
        // C - Sort damages cases according to level
        switch game.level {
        case .isEasy: return _atLevelEasy()
        case .isHard: return _atLevelHard()
        default: return _atLevelMedium()
        }
    }
    
    // MARK: IA Play easy
    private func _atLevelEasy()
    -> (attackCase: DmgCase?, medicineCase: (useMedicine: Medicine, onToon: Toon?)?) {
        attackCasesOnN0.sort { $0.damage < $1.damage }
        defenseCasesOnN1.sort { $0.damage < $1.damage }
        let lowestDamage: DmgCase = attackCasesOnN0[0]
        return (lowestDamage, nil)
    }
    
    // MARK: IA Play medium
    private func _atLevelMedium()
    -> (attackCase: DmgCase?, medicineCase: (useMedicine: Medicine, onToon: Toon?)?) {
        attackCasesOnN0.sort { $0.damage > $1.damage }
        defenseCasesOnN1.sort { $0.damage > $1.damage }
        
        // A - Do basic checks first
        let shoudlUseMedicine = _shouldUseMedicine(machine: game.attackingPlayer)
      
        switch shoudlUseMedicine.result {
        case true: // B1 - Team suffers injuries
            
            guard let returnedMedicine = shoudlUseMedicine.withMedicine else { fallthrough }
            if returnedMedicine.type == .isHeavy { return (nil, (returnedMedicine, nil))
            } else {
                guard let returnedToon = shoudlUseMedicine.onToon else { fallthrough }
                return (nil, (returnedMedicine, returnedToon))
            }
            
        case false: // B2 - Team suffers not injuries
            
            return (attackCasesOnN0[0], nil)
        }
    }
    
    // MARK: IA Play hard
    private func _atLevelHard()
    -> (attackCase: DmgCase?, medicineCase: (useMedicine: Medicine, onToon: Toon?)?){
            
        attackCasesOnN0.sort { $0.damage > $1.damage }
        defenseCasesOnN1.sort { $0.damage > $1.damage }
        
        // A - Do basic checks first
        let canTakeToonOrBestCase = _canTakeToonOrBestCase(attackCases: attackCasesOnN0)
        let canLoseToonOrWorstCase = _canLoseToonOrWorstCase(defenseCases: defenseCasesOnN1)
        
        switch canLoseToonOrWorstCase.result {
        case false: // B1 - Machine can't lose toon on N1
            
            if canTakeToonOrBestCase.result == true { return (canTakeToonOrBestCase.playPattern, nil) } // 1° : Take out any if possible
            else { return (canTakeToonOrBestCase.playPattern, nil) } // 2° : Play best case
        
        case true: // B2 - Machine can lose toon on N1
            
            let canTakeOutNextRoundThreat = _canTakeOutNextRoundThreat(attackCases: attackCasesOnN0, defenseCases: defenseCasesOnN1)
            
            switch canTakeOutNextRoundThreat.result {
            case true: // C1 - Machine can take out threat
                
                return (canTakeOutNextRoundThreat.playPattern!, nil) // 3° : Take out threat
        
            case false: // C2 - Machine can't take out threat
            
                let machineOutnumber = _machineOutnumbers(machine: game.attackingPlayer, human: game.defendingPlayer)
                
                switch machineOutnumber {
                case true: // D1 - Machine outnumber Human
                    
                    return (canTakeToonOrBestCase.playPattern, nil) // 6° : Play best case
                    
                case false: // D2 - Human outnumbers Machine
                    
                    let shoudlUseMedicine = _shouldUseMedicine(machine: game.attackingPlayer)
                    switch shoudlUseMedicine.result {
                    case true: // E1 - Team suffers injuries
                        
                        // 7° : Use medicine if necessary
                        guard let returnedMedicine = shoudlUseMedicine.withMedicine else { fallthrough }
                        if returnedMedicine.type == .isHeavy { return (nil, (returnedMedicine, nil))
                        } else {
                            guard let returnedToon = shoudlUseMedicine.onToon else { fallthrough }
                            return (nil, (returnedMedicine, returnedToon))
                        }
                    
                    case false: // E2 - Team suffers not injuries
                        
                        // 8° : Play best case
                        return (canTakeToonOrBestCase.playPattern, nil)
                    }
                }
            }
        }
    }
    
    // MARK: Damage check
    private func _aliveOnly(_ toons: [Toon]) -> [Toon] {
        return toons.filter({ $0.isAlive() == true })
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

    // MARK: Hard level check
    private func _canTakeToonOrBestCase(attackCases: [DmgCase])
    -> (result: Bool, playPattern: DmgCase) {
        guard let canKillCase = attackCases.first(where: {$0.isLethal == true}) else {
            let elseCase = attackCases[0] // Top case after sort
            return (false, elseCase)
        }
        return (true, canKillCase)
    }

    private func _canLoseToonOrWorstCase(defenseCases: [DmgCase])
    -> (result: Bool, playPattern: DmgCase) {
        guard let canBeKilledCase = defenseCases.first(where: {$0.isLethal == true}) else {
            let elseCase = defenseCases[0] // Top case after sort
            return (false, elseCase)
        }
        return (true, canBeKilledCase)
    }

    private func _canTakeOutNextRoundThreat(attackCases: [DmgCase], defenseCases: [DmgCase])
    -> (result: Bool, playPattern: DmgCase?) {
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

    private func _machineOutnumbers(machine: Player, human: Player) -> Bool {
        var machineToons: Int = 0
        var humanToons: Int = 0
        for toon in machine.toons { if toon.isAlive() { machineToons += 1 }}
        for toon in human.toons { if toon.isAlive() { humanToons += 1 }}
        return machineToons > humanToons ? true : false
    }

    // MARK: Medical check
    private func _shouldAttackDoctor(attackCases: [DmgCase])
    -> (result: Bool, playPattern: DmgCase?) {
        // A - Pick only cases where defender is Medical
        var attackOnDoctor = attackCases.filter({ $0.defender is Medical})
        guard attackOnDoctor.count > 0 else { return (false, nil) }
        // B - Sort them by highest damage
        attackOnDoctor.sort { $0.damage > $1.damage }
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
        } else if toonsUnderPercent70.count > 0 {
            // C2 - Medium medicine use if 1 toon is under 90%
            toonsUnderPercent90.sort { $0.gain > $1.gain }
            return (true, toonsUnderPercent90[0].medicine, toonsUnderPercent90[0].toon)
        } else if toonsUnderPercent70.count > 0 {
            // C3 - Light medicine use if 1 toon is under 70%
            toonsUnderPercent70.sort { $0.gain > $1.gain }
            return (true, toonsUnderPercent70[0].medicine, toonsUnderPercent70[0].toon)
        } else {
            return (true, toonsUnderPercent50[0].medicine, nil)
        }
    }
}
