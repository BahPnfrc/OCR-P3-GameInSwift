//
//  FightExtension.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 09/04/2021.
//

import Foundation

extension Game {
    
    func fightStep() {
        Toon.resetAllPromptID()
        var counter: Int = 0
        var round: Int = 0
        var turn: [String] = ["🅰️","🅱️"]
        
        // MARK: A - WORKFLOW
        repeat {
            
            counter += 1
            if (counter - 1).isMultiple(of: 2) { round += 1 ; roundPlayed = round }
            Console.newSection()
            
            // A - ACTION
            switchPlayers() // Attacker and defender are switched each round
            Console.write(0, 0, "➡️ Round #️⃣\(round)\(turn[0]) : 🔔 *Ding Ding Ding* \(attackingPlayer.name) on stage !".withNum(), 1)
            turn.swapAt(0, 1) // for next round
            
            var toondidMedicine: Bool = false
            if let machine = attackingPlayer as? MachinePlayer { // Machine is playing
                
                toondidMedicine =  _fightStep_machinePlayWithIA(withMachine: machine)
                
            } else { // Human is playing
                
                // a - Lists all toons
                let listHeader: String = "Ok \(attackingPlayer.name), pick one of your champions 🥊 :"
                _ = attackingPlayer.listAllToons(aliveOnly: false, header: listHeader)
                // b - Choose one toon
                let choosenToon: Toon = _fightStep_chooseToon(of: attackingPlayer)
                // c - Extra weapon attempt
                if Setting.ExtraWeapon.isActivated {
                    switch mode {
                    case .isVersusMachine:
                        if Setting.ExtraWeapon.againstMachine == true { fallthrough }
                    case .isVersusHuman:
                        ExtraWeapon.extraWeaponAttempt(forToon: choosenToon)
                    }
                } // d - Medicine or fight
                if let medicalToon = choosenToon as? MedicalToon {
                    toondidMedicine = _fightStep_isDoctor(withToon: medicalToon)
                } else { _fightStep_isElse(withToon: choosenToon) }
                
            }
            
            // B - REPORT
            if toondidMedicine {
                let reportHeader = "Here is \(attackingPlayer.name)'s Team after medication ⛑ :"
                _ = attackingPlayer.listAllToons(aliveOnly: false, header: reportHeader, withBar: true)
            } else {
                let reportHeader = "Here is \(defendingPlayer.name)'s Team after this blow 🪖 :"
                _ = defendingPlayer.listAllToons(aliveOnly: false, header: reportHeader, withBar: true)
            }
            
            // C - EXTRA
            ExtraWeapon.handleAfterFightExtraData(inGame: self)
            
            // D - BREAK PROMPT
            let exitPrompt: Bool =  Console.getExitPrompt(exitWord: "exit")
            if exitPrompt == true { break }
            
        } while _fightStep_CanContinue() // E - END CHECK
        
    }
    
    
    // MARK: B - MISCELLANEOUS
    private func _fightStep_chooseToon(of player: Player) -> Toon {
        while true {
            let promptForNumber = Console.getIntInput(fromTo: 1...player.toons.count)
            let choosenToon = player.toons.first(where: { $0.promptID == promptForNumber })!
            if !choosenToon.isAlive() {
                Console.write(1, 1, choosenToon.getPicWithName() + " can't fight : \(choosenToon.getHeOrShe())is knocked out !", 1)
            } else { return choosenToon }
        }
    }
    
    private func _fightStep_CanContinue() -> Bool {
        if defendingPlayer.toons.allSatisfy({ $0.lifeSet.hitpoints <= 0 }) {
            return false // stop
        } else { return true } // continue
    }
    
    
    // MARK: C - MEDICAL ACTIONS
    private func _fightStep_isDoctor(withToon doctor: MedicalToon) -> Bool {
        let toonDidMedicine: Bool = _fightStep_isDoctor_DoMedicine(of: attackingPlayer, with: doctor)
        if !toonDidMedicine { // Fight
            _fightStep_chooseDefenderAndFight(withToon: doctor)
            return false
        } else {
            return true
        }
    }
    private func _fightStep_isDoctor_DoMedicine(of player: Player, with choosenToon: Toon) -> Bool {
        // A - Quit if toon is not a Medical or no Medicine left
        guard let doctor = choosenToon as? MedicalToon else { return false }
        let pack: [Medicine] = doctor.medicalPack
        let medicineIsLeft: Bool = !pack.allSatisfy({ $0.left == 0 })
        guard medicineIsLeft else { return false }
        // B - Prepare prompt text
        var promptID: Int = 1 ; let weaponPromptID: Int = promptID ; var maxPromptID: Int = weaponPromptID ;
        var promptText: String = "\(String(weaponPromptID).withNum()). Use \(doctor.getHisOrHer())\(doctor.weapon!.getPicWithName()) : it blows haters to smithereens"
        for index in 0...2 {
            if pack[index].left > 0 {
                promptID += 1 ; maxPromptID = promptID; pack[index].promptID = promptID
                promptText += "\n\(String(promptID).withNum()). Use \(doctor.getHisOrHer())\(pack[index].getPicWithName()) : \(pack[index].about)"
            } else { pack[index].promptID = 0 }
        }
        // C - Call prompt and get result
        Console.write(0, 1, """
            What do you want to do with \(doctor.getPicWithName()) ?
            \(promptText)
            """, 1)
        let promptForMedicine = Console.getIntInput(fromTo: 1...maxPromptID)
        if promptForMedicine == weaponPromptID {return false}
        _fightStep_isDoctor_ApplyMedecine(ofPlayer: doctor, withID: promptForMedicine)
        return true
    }
    private func _fightStep_isDoctor_ApplyMedecine(ofPlayer doctor: MedicalToon, withID medicineID:Int) {
        let choosenMedicine: Medicine = doctor.medicalPack.first(where: { $0.promptID == medicineID })!
        if let teamUseMedicine = choosenMedicine as? TeamUseMedicine {
            teamUseMedicine.use(fromDoctor: doctor, OnTeam: attackingPlayer)
        } else  {
            let singleUseMedicine = choosenMedicine as! SingleUseMedicine
            var maxPromptID: Int = 0 ; var promptText: String = ""
            for index in 0...attackingPlayer.toons.count - 1 {
                let toon = attackingPlayer.toons[index]
                if toon.isAlive() {
                    maxPromptID += 1 ; toon.promptID = maxPromptID
                    promptText += "\(String(toon.promptID).withNum()). \(toon.getPicWithName()) with \(toon.getHitpointsAndPercent()) \n"
                } else { toon.promptID = 0 }
            }
            Console.write(0, 1, """
                Who shall receive the \(singleUseMedicine.getPicWithName()) ?
                \(promptText)
                """, 0)
            let choosenID = Console.getIntInput(fromTo: 1...maxPromptID)
            let choosenToon = attackingPlayer.toons.first(where: {$0.promptID == choosenID})!
            singleUseMedicine.use(fromDoctor: doctor, onToon: choosenToon)
        }
    }
    private func _fightStep_isElse(withToon toon: Toon) {
        _fightStep_chooseDefenderAndFight(withToon: toon)
    }
    
    
    // MARK: D - FIGHT ACTIONS
    private func _fightStep_chooseDefenderAndFight(withToon attacker: Toon) {
        // A - Choose defender
        var maxPromptID: Int = 0 ; var promptText: String = ""
        for index in 0...defendingPlayer.toons.count - 1 {
            let toon = defendingPlayer.toons[index]
            if toon.isAlive() {
                maxPromptID += 1 ; toon.promptID = maxPromptID
                promptText += "\(String(toon.promptID).withNum()). \(toon.getPicWithName()) with \(toon.getHitpointsAndPercent()) \n"
            } else { toon.promptID = 0 }
        }
        Console.write(0, 1, """
            Who shall suffer the wrath of \(attacker.getPicWithName()) ?
            \(promptText)
            """, 0)
        let targetID: Int = Console.getIntInput(fromTo: 1...maxPromptID)
        let defender: Toon = defendingPlayer.toons.first(where: {$0.promptID == targetID})!
        // B - Fight
        let damage: Double = Weapon.getDamage(from: attacker, to: defender)
        _fightStep_applyDamage(from: attacker, to: defender, for: Int(damage))
        _figthStep_Report(from: attacker, to: defender, of: Double(damage))
    }
    
    private func _fightStep_applyDamage(from attacker: Toon, to defender: Toon, for damage: Int) {
        defender.loseHP(from: attacker, for: damage)
    }
    private func _figthStep_Report(from attacker: Toon, to defender: Toon, of damage: Double) {
        let realDamage = damage
        let expectedDamage = attacker.weapon!.isUpdated == true ?
            Setting.Weapon.expectedUpdatedDamage : Setting.Weapon.expectedBasicDamage
        let (action, result, medal) =
            (realDamage < (expectedDamage * 0.9)) ? (" scratched " , "causing only ", "🥉"):
            (realDamage < (expectedDamage * 1.1)) ? (" touched " , "amounting for ", "🥈") :
            (" punished " , "wrecking for ", "🥇")
        let attackInfo: String = "ℹ️. " + attacker.getPicWithName() + action + "" + defender.getPicWithName()
        let weaponInfo: String = "With " + attacker.getHisOrHer() + attacker.weapon!.getPicWithName()
        let resultInfo: String = result + String(Int(realDamage)) + " damages " + medal
        let message: String = attackInfo + "\n" + weaponInfo + " " + resultInfo
        Console.write(0, 1, message, 1)
    }
    
    // MARK: E - MACHINE ACTIONS
    private func _fightStep_machinePlayWithIA(withMachine machine: MachinePlayer) -> Bool {
        var didMedicine: Bool = false
        let action = machine.PlayWithIA(game: self)
        if let doAttack = action.attackCase {
            Console.write(0, 1, "⚙️ \(attackingPlayer.name) made a choice and decided to attack :", 1)
            _fightStep_machineFight(withToon: doAttack.attacker, againt: doAttack.defender)
            return didMedicine
        } else {
            guard let doMedicine = action.medicineCase else {
                Console.writeError(atLine: #line, inFunc: #function)
                return false
            }
            Console.write(0, 1, "⚙️ \(attackingPlayer.name) made a choice and decided to use medicine :", 1)
            let doctor: MedicalToon = machine.toons.first(where: { $0.self is MedicalToon }) as! MedicalToon
            let medicine = doMedicine.useMedicine ; let toon = doMedicine.onToon
            _fightStep_machineApplyMedicine(doctor: doctor, medicine: medicine, onToon: toon)
            didMedicine = true
            return didMedicine
        }
    }
    
    private func _fightStep_machineFight(withToon attacker: Toon, againt defender: Toon) {
        let damage: Double = Weapon.getDamage(from: attacker, to: defender)
        _fightStep_applyDamage(from: attacker, to: defender, for: Int(damage))
        _figthStep_Report(from: attacker, to: defender, of: Double(damage))
    }
    
    private func _fightStep_machineApplyMedicine(doctor: MedicalToon, medicine: Medicine, onToon toon: Toon?) {
        if let teamUseMedicine = medicine as? TeamUseMedicine {
            teamUseMedicine.use(fromDoctor: doctor, OnTeam: attackingPlayer)
        } else {
            let singleUseMedicine = medicine as! SingleUseMedicine
            guard let toon = toon else {
                Console.writeError(atLine: #line, inFunc: #function)
                return
            }
            singleUseMedicine.use(fromDoctor: doctor, onToon: toon)
        }
    }
    
}
