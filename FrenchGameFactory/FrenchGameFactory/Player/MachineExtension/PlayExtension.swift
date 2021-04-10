//
//  PlayExtension.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 09/04/2021.
//

import Foundation

extension MachinePlayer {
    
    // MARK: A1 - Play easy
    func play_Easy()
    -> (attackCase: DamageCase?, medicineCase: (useMedicine: Medicine, onToon: Toon?)?) {
        attackCasesOnN0.sort { $0.damage < $1.damage }
        defenseCasesOnN1.sort { $0.damage < $1.damage }
        let lowestDamage: DamageCase = attackCasesOnN0[0]
        return (lowestDamage, nil)
    }
    
    // MARK: A2 - Play medium
    func play_Medium()
    -> (attackCase: DamageCase?, medicineCase: (useMedicine: Medicine, onToon: Toon?)?) {
        attackCasesOnN0.sort { $0.damage > $1.damage }
        defenseCasesOnN1.sort { $0.damage > $1.damage }
        
        // A1 - Remove highest and lowest damage cases
        let removeCases: [(upperBound: Int, removeFirst: Int, removeLast: Int)]
            = [(9, 2, 3), (6, 1, 2), (3, 0, 1)]
        for removeCase in removeCases {
            if attackCasesOnN0.count >= removeCase.upperBound {
                if removeCase.removeFirst > 0 { for _ in 1...removeCase.removeFirst { attackCasesOnN0.removeFirst() }}
                if removeCase.removeLast > 0 { for _ in 1...removeCase.removeLast { attackCasesOnN0.removeLast() }}
                break
            }
        }
        
        // A2 - Do basic checks first
        let canLoseToonOrWorstCase = check_canLoseToonOrWorstCase(defenseCases: defenseCasesOnN1)
        let canTakeToonOrBestCase = check_canTakeToonOrBestCase(attackCases: attackCasesOnN0)
        
        if canTakeToonOrBestCase.result == true {
            return (canTakeToonOrBestCase.playPattern, nil)
        }
        
        switch canLoseToonOrWorstCase.result {
        case true: // B1 - Machine can lose toon on N1
            
            let shoudlUseMedicine = check_shouldUseMedicine(machine: game.attackingPlayer)
            
            switch shoudlUseMedicine.result {
            case true: // C1 - Team suffers injuries
                
                guard let returnedMedicine = shoudlUseMedicine.withMedicine else { fallthrough }
                if returnedMedicine.type == .isHeavy { return (nil, (returnedMedicine, nil))
                } else {
                    guard let returnedToon = shoudlUseMedicine.onToon else { fallthrough }
                    return (nil, (returnedMedicine, returnedToon))
                }
                
            case false: // C2 - Team suffers not injuries
                
                return (attackCasesOnN0.randomElement()!, nil)
            }
            
        case false: // B2 - Machine can't lose toon on N1
            return (attackCasesOnN0.randomElement()!, nil)
        }
    }
    
    // MARK: A3 - Play hard
    func play_Hard()
    -> (attackCase: DamageCase?, medicineCase: (useMedicine: Medicine, onToon: Toon?)?){
            
        attackCasesOnN0.sort { $0.damage > $1.damage }
        defenseCasesOnN1.sort { $0.damage > $1.damage }
        
        // A - Do basic checks first
        let canTakeToonOrBestCase = check_canTakeToonOrBestCase(attackCases: attackCasesOnN0)
        let canLoseToonOrWorstCase = check_canLoseToonOrWorstCase(defenseCases: defenseCasesOnN1)
        
        switch canLoseToonOrWorstCase.result {
        case false: // B1 - Machine can't lose toon on N1
            
            if canTakeToonOrBestCase.result == true { return (canTakeToonOrBestCase.playPattern, nil) } // 1° : Take out any if possible
            else { return (canTakeToonOrBestCase.playPattern, nil) } // 2° : Play best case
        
        case true: // B2 - Machine can lose toon on N1
            
            let canTakeOutNextRoundThreat = check_canTakeOutNextRoundThreat(attackCases: attackCasesOnN0, defenseCases: defenseCasesOnN1)
            
            switch canTakeOutNextRoundThreat.result {
            case true: // C1 - Machine can take out threat
                
                return (canTakeOutNextRoundThreat.playPattern!, nil) // 3° : Take out threat
        
            case false: // C2 - Machine can't take out threat
            
                let machineOutnumber = check_machineOutnumbers(machine: game.attackingPlayer, human: game.defendingPlayer)
                
                switch machineOutnumber {
                case true: // D1 - Machine outnumber Human
                    
                    return (canTakeToonOrBestCase.playPattern, nil) // 6° : Play best case
                    
                case false: // D2 - Human outnumbers Machine
                    
                    let shoudlUseMedicine = check_shouldUseMedicine(machine: game.attackingPlayer)
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
}
