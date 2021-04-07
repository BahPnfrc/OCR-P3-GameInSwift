//
//  Game.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 04/03/2021.
//

import Foundation

enum Mode: CaseIterable { case isVersusHuman, isVersusMachine }
enum Level: String, CaseIterable { case isDefault, isEasy = "Easy", isMedium = "Medium", isHard = "Hard"}
enum Order: String, CaseIterable { case first = "First", second = "Second", chance = "Chance"}

class Game {
    
    private var mode: Mode
    var level: Level = .isDefault
    var player: (main: Player, second: Player)
    
    private var queue: [Player] = []
    private func switchPlayers() { self.queue.swapAt(0, 1)}
    
    var attackingPlayer: Player { return queue[0]}
    var defendingPlayer: Player { return queue[1]}
    
    init(){
        // MARK: A - MODE
        Console.write(0, 1, """
            ✨🦠✨ WELCOME TO MY GAME ✨🍄✨
            """)
        Console.write(1, 1, """
            How do you want to play ?
            1. 🧠 Against a friend
            2. ⚙️ Against the machine
            3. 🕣 Fast play using default setting
            """.withNum(), 1)
        let modePrompt:Int = !Setting.Game.fastPlayEnabled ? Console.getIntInput(fromTo: 1...3) : 2

        if modePrompt == 3 {
            Setting.Game.fastPlayEnabled = true
            self.mode = .isVersusMachine
        } else { mode = modePrompt == 1 ? .isVersusHuman: .isVersusMachine }
        
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
            Console.write(0, 0,
                "Ok \(player.main.name), I'm \(player.second.name) and I'm your opponent !", 0)
            // MARK: D - LEVEL
            Console.write(1, 1, """
                How do you want me to be ?
                1. 🌸 Easy. I'll do low damages with no medicine
                2. 🏓 Medium. I'll do balanced damages and use medicine
                3. 🪖 Hard. I'll do high damages and use medicine
                """.withNum(), 1)
            if Setting.Game.fastPlayEnabled {
                level = Setting.Game.fastPlayLevel
                Console.write(0, 2, "ℹ️. Default setting was applied : \(level.rawValue) ✅", 0)
            } else {
                let levelPrompt: Int = Console.getIntInput(fromTo: 1...3) // #TEST
                level = levelPrompt == 1 ? .isEasy: levelPrompt == 2 ? .isMedium: .isHard
            }
        }
    }
    
    func run(){
        orderStep()
        chooseStep()
        fightStep()
        statStep()
        endOfGame()
    }
}

// MARK: E - ORDER PLAYERS
extension Game {
    private func orderStep(){
        Console.newSection()
        Console.write(0, 0, """
            Ok \(player.main.name), two teams will now be made.
            Choosing toons first is penalized by shooting second.
            """)
        Console.write(1, 1, """
            Who choose first ?
            1. 🏆 First. I want to choose first no matter what
            2. 🎳 Second. I'd prefer to shoot first so I'll choose second
            3. 🎲 Chance. I'd rather roll the dice and let chance decide
            """.withNum(), 1)
        let orderPrompt: (number: Int, text: String )
        if Setting.Game.fastPlayEnabled {
            orderPrompt =
                Setting.Game.fastPlayOrder == .first ? (1, Order.first.rawValue) :
                Setting.Game.fastPlayOrder == .second ? (2, Order.second.rawValue) :
                (3, Order.chance.rawValue)
            Console.write(0, 2, "ℹ️. Default setting was applied : \(orderPrompt.text) ✅", 0)
        } else {
            orderPrompt.number = Console.getIntInput(fromTo: 1...3)
        }
        queue =
            orderPrompt.number == 1 ? [player.main, player.second] :
            orderPrompt.number == 2 ? [player.second, player.main] :
            [player.main, player.second].shuffled()
    }
}

// MARK: F - CHOOSE TOONS
extension Game {
    private func chooseStep(){
        let firstToChoose: Player = queue[0]
        let secondToChose: Player = queue[1]
        if self.mode == .isVersusHuman {
            // A - First Player is Human ; B - Second is Human
            _chooseStep_humanChoose(forPlayer: firstToChoose)
            let header = "OK, \(secondToChose.name), it's your turn now."
            _chooseStep_humanChoose(forPlayer: secondToChose, withHeader: header)
        } else {
            if let machine = firstToChoose as? MachinePlayer {
                // A - First player is Machine ; B - Second is Human
                _chooseStep_machineChoose(forPlayer: machine)
                _chooseStep_machineReportChoose(forPlayer: machine, as: .first)
                _chooseStep_humanChoose(forPlayer: secondToChose)
            }
            else {
                // A - First player is Human ; B - Second is Machine
                _chooseStep_humanChoose(forPlayer: firstToChoose)
                _chooseStep_machineChoose(forPlayer: secondToChose)
                _chooseStep_machineReportChoose(forPlayer: secondToChose, as: .second)
            }
        }
    }
    private func _chooseStep_humanChoose(forPlayer human: Player, withHeader header: String? = nil){
        let defaultHeader: String = """
            Ok \(human.name), time is to choose your toons.
            You must pick one Engineer, one Military and one Medical.
            """
        Console.newSection()
        Console.write(0, 0, header ?? defaultHeader)
        let toonTypes = [
             (all: EngineerToon.All, message: "There it goes Engineers :"),
             (all: MilitaryToon.All, message: "Time is to pick up a Military now :"),
             (all: MedicalToon.All, message: "You can finally pick up your Medical :")]
        var previousNames: [String] = []
        for toonType in toonTypes { // For each type of toon
            // A - Show message and list all toons
            var promptText: String = ""
            Console.write(1, 1, toonType.message, 0)
            var maxPromptID: Int = 0
            for toon in toonType.all {
                if !toon.isInTeam {
                    maxPromptID += 1 ; toon.promptID = maxPromptID
                    promptText += toon.getChooseToonPrompt() + "\n"
                } else {toon.promptID = 0}
            }
            Console.write(0, 1, promptText.withNum().withEmo(), 0)
            // B - Prompt to choose a toon by its ID
            let promptForNumber: Int =
                !Setting.Game.fastPlayEnabled ? Console.getIntInput(fromTo: 1...maxPromptID) : (1...maxPromptID).randomElement()!
            let chosenToon: Toon = toonType.all.first(where: {$0.promptID == promptForNumber})!
            // C - Prompt to choose a name for this toon
            var promptForName: String = ""
            while true {
                promptForName = !Setting.Game.fastPlayEnabled ?
                    Console.getStringInput(prompt: "a name for this toon") :
                    Toon.getStaticRandomName(forToon: chosenToon)
                if previousNames.contains(promptForName){
                    if Setting.Game.fastPlayEnabled == false {
                        Console.write(1, 1, "⚠️ Toons can't have the same name : try another ⚠️", 1)
                    }
                }
                else { previousNames.append(promptForName) ; break }
            }
            chosenToon.name = promptForName.uppercased()
            chosenToon.isInTeam = true
            human.toons.append(chosenToon)
            if Setting.Game.fastPlayEnabled == true {
                Console.write(0, 2, "ℹ️. Random toon was choosed : \(chosenToon.getPicWithName()) ✅", 0)
            }
        }
    }
    private func _chooseStep_machineChoose(forPlayer machine: Player) {
        var results: [(ID: Int, globalSet: Double)] = []
        let toonClasses = [EngineerToon.All, MilitaryToon.All, MedicalToon.All]
        for toonClass in toonClasses { // For each class of toons
            // A - Copy to an array each toon ID and global set
            var maxPromptID: Int = 0
            for toon in toonClass {
                if !toon.isInTeam {
                    maxPromptID += 1 ; toon.promptID = maxPromptID
                    results.append((toon.promptID, toon.globalSet))
                } else {toon.promptID = 0}
            }
            // B - Order this array according to the level
            switch level {
            case .isEasy: results.sort { $0.globalSet < $1.globalSet } // Lowest score on top
            case .isHard: results.sort { $0.globalSet > $1.globalSet } // Highest score on top
            default: results.shuffle() // Simple shuffle
            }
            // C - Pick the toon at the top [0] index
            let rightToon = toonClass.first(where: {$0.promptID == results[0].ID} )!
            rightToon.name = rightToon.getRandomName().uppercased() // Get a random 1900' style name
            rightToon.isInTeam = true
            machine.toons.append(rightToon)
            results.removeAll() // For next loop
        }
        
    }
    private func _chooseStep_machineReportChoose(forPlayer machine: Player, as order: Order) {
        var reportText: String = ""
        for toon in machine.toons {
            let text = "ℹ️. " + toon.getPicWithName() + " with \(toon.getHisOrHer())\(toon.weapon!.getPicWithName()) ✅\n"
            reportText.append(text)
        }
        if order == .first {
            Console.write(1, 1, "⚙️ \(machine.name) choosed first and decided to pick :\n" + reportText, 0)
        } else {  Console.write(1, 1, "⚙️ \(machine.name) made a choice and finally picked :\n" + reportText, 0) }
        Console.getSimplePrompt()
    }
}

// MARK: F - FIGHT
extension Game {
    
    private func fightStep() {
        Toon.resetAllPromptID()
        var counter: Int = 0
        var round: Int = 0
        var turn: [String] = ["🅰️","🅱️"]
        repeat {
            counter += 1
            if (counter - 1).isMultiple(of: 2) {round += 1}
            Console.newSection()
            // A - Pick one player
            switchPlayers() // Attacker and defender are switched
            Console.write(0, 0, "➡️ Round #️⃣\(round)\(turn[0]) : 🔔 *Ding Ding Ding* \(attackingPlayer.name) on stage, Fight 🥊 !".withNum(), 1)
            turn.swapAt(0, 1)
            
            var didMedicine: Bool = false
            if let machine = attackingPlayer as? MachinePlayer { // Machine IA autoplay
                
                didMedicine =  _fightStep_machinePlayWithIA(withMachine: machine)
                
            } else { // Human play
                
                // B - Lists all toons
                let listHeader: String = "Ok \(attackingPlayer.name), pick one of your champions :"
                _ = attackingPlayer.listAllToons(aliveOnly: false, header: listHeader)
                // C - Choose one toon
                let choosenToon: Toon = _fightStep_chooseToon(of: attackingPlayer)
                // D - Engage in action
                if Setting.ExtraWeapon.isActivated {
                    switch mode {
                    case .isVersusMachine:
                        if Setting.ExtraWeapon.againstMachine == true { fallthrough }
                    case .isVersusHuman:
                        ExtraWeapon.extraWeaponAttempt(forToon: choosenToon)
                    }
                }
                if let medicalToon = choosenToon as? MedicalToon { didMedicine = _fightStep_isDoctor(withToon: medicalToon)
                } else { _fightStep_isElse(withToon: choosenToon) }
            }
            
            // E1 - Report
            if didMedicine {
                let reportHeader = "Here is \(attackingPlayer.name)'s Team after medication ⛑ :"
                _ = attackingPlayer.listAllToons(aliveOnly: false, header: reportHeader, withBar: true)
            } else {
                let reportHeader = "Here is \(defendingPlayer.name)'s Team after this blow 🪖 :"
                _ = defendingPlayer.listAllToons(aliveOnly: false, header: reportHeader, withBar: true)
            }
            
            // E2 - Extra report and other actions
            ExtraWeapon.handleAfterFightExtraData(inGame: self)
            
            // F - Prompt to continue
            let exitPrompt: Bool =  Console.getExitPrompt(exitWord: "exit")
            if exitPrompt == true { break }
            
        } while _fightStep_CanContinue()
        
    }
    
    private func _fightStep_chooseToon(of player: Player) -> Toon {
        while true {
            let promptForNumber = Console.getIntInput(fromTo: 1...player.toons.count)
            let choosenToon = player.toons.first(where: { $0.promptID == promptForNumber })!
            if !choosenToon.isAlive() {
                Console.write(1, 1, choosenToon.getPicWithName() + " can't fight : \(choosenToon.getHeOrShe())is knocked out !", 1)
            } else { return choosenToon }
        }
    }
    // MARK: F - a - Medecine
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
        var restoredHitpoints: Int // #STAT
        let choosenMedicine: Medicine = doctor.medicalPack.first(where: { $0.promptID == medicineID })!
        if let teamUseMedicine = choosenMedicine as? TeamUseMedicine {
            restoredHitpoints = teamUseMedicine.use(OnTeam: attackingPlayer) // #STAT
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
            restoredHitpoints = singleUseMedicine.use(onToon: choosenToon) // #STAT
        }
        doctor.statSet.medicine.given += restoredHitpoints // #STAT
    }
    private func _fightStep_isElse(withToon toon: Toon) {
        _fightStep_chooseDefenderAndFight(withToon: toon)
    }
    // MARK: F - b - Fight
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
        _fightStep_applyDamageSicknessAndStats(from: attacker, to: defender, of: Int(damage))
        _figthStep_Report(from: attacker, to: defender, of: Double(damage))
    }
    
    private func _fightStep_applyDamageSicknessAndStats(from attacker: Toon, to defender: Toon, of damage: Int) {
        // A - Attacker
        attacker.statSet.roundPlayed += 1
        attacker.statSet.totalDamage.given += damage
        if damage > attacker.statSet.bestDamage.given {
            attacker.statSet.bestDamage.given = damage
        }
        // B - Defender
        defender.lifeSet.hitpoints -= damage
        defender.statSet.totalDamage.received += damage
        if damage > defender.statSet.bestDamage.received {
            defender.statSet.bestDamage.received = damage
        }
        // C - Extra
        ExtraWeapon.getToonSickIfRequired(from: attacker, to: defender)
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
    private func _fightStep_CanContinue() -> Bool {
        if defendingPlayer.toons.allSatisfy({ $0.lifeSet.hitpoints <= 0 }) {
            return false // stop
        } else { return true } // Stop
    }
    
    // MARK: F - c - Machine
    private func _fightStep_machinePlayWithIA(withMachine machine: MachinePlayer) -> Bool {
        var didMedicine: Bool = false
        let action = machine.PlayWithIA(game: self)
        if let doAttack = action.attackCase {
            Console.write(0, 1, "⚙️ \(attackingPlayer.name) made a choice and decided to attack :", 1)
            _fightStep_machineFight(withToon: doAttack.attacker, againt: doAttack.defender)
            return didMedicine
        } else {
            guard let doMedicine = action.medicineCase else {
                Console.write(1, 1, "❌ An error occured and the game will quit now !", 0)
                return didMedicine
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
        _fightStep_applyDamageSicknessAndStats(from: attacker, to: defender, of: Int(damage))
        _figthStep_Report(from: attacker, to: defender, of: Double(damage))
    }
    
    private func _fightStep_machineApplyMedicine(doctor: MedicalToon, medicine: Medicine, onToon toon: Toon?) {
        var restoredHitpoints: Int // #STAT
        if let teamUseMedicine = medicine as? TeamUseMedicine {
            restoredHitpoints = teamUseMedicine.use(OnTeam: attackingPlayer) // #STAT
        } else {
            let singleUseMedicine = medicine as! SingleUseMedicine
            guard let toon = toon else {
                Console.write(1, 1, "❌ An error occured and \(singleUseMedicine.getPicWithName()) could not be used !", 1)
                return
            }
            restoredHitpoints = singleUseMedicine.use(onToon: toon) // #STAT
        }
        doctor.statSet.medicine.given += restoredHitpoints // #STAT
    }
    
    // MARK: G - STAT
    func statStep() {
        
        // NOMBRE TOUR / alive ? => Barre
        
        player.main.finalScore = _statStep_AverageScore(OfPlayer: player.main)
        player.second.finalScore = _statStep_AverageScore(OfPlayer: player.second)
        let result: (winner: Player, loser: Player) =
            player.main.finalScore > player.second.finalScore ?
            (player.main, player.second) : (player.second, player.main)
            
        let allToons = player.main.toons + player.second.toons
        let mostDamageGiven: [Toon] = allToons.sorted {$0.statSet.totalDamage.given > $1.statSet.totalDamage.given}
        let bestDamageGiven : [Toon]  = allToons.sorted {$0.statSet.bestDamage.given > $1.statSet.bestDamage.given}
        let mostMedicineGiven: [Toon] = allToons.sorted {$0.statSet.medicine.given > $1.statSet.medicine.given}
        
        let Medals: [String] = ["🥇", "🥈", "🥉"]
        var mostDamageGivenRank: String = ""
        var bestDamageGivenRank: String = ""
        var mostMedicineGivenRank: String = ""
        for index in 0...2 {
            mostDamageGivenRank += Medals[index] + " - " + mostDamageGiven[index].getPicWithName() + " : "
                + String(mostDamageGiven[index].statSet.totalDamage.given) + " hitpoints taken\n"
            bestDamageGivenRank += Medals[index] + " - " + bestDamageGiven[index].getPicWithName() + " : "
                + String(bestDamageGiven[index].statSet.bestDamage.given) + " hitpoints taken\n"
        }
        for index in 0...1 {
            mostMedicineGivenRank += Medals[index] + " - " + mostMedicineGiven[index].getPicWithName() + " : "
                + String(mostMedicineGiven[index].statSet.medicine.given) + " hitpoints taken\n"
        }
        
        let rank:String = """
            They made History today 🏆 :
            🏁 - \(result.winner.name) : \(result.winner.finalScore) damages taken
            🏳️ - \(result.loser.name) : \(result.loser.finalScore) damages taken

            Best unique damage dealer 🎯 :
            \(bestDamageGivenRank)
            Best global damage dealer 🕑 :
            \(mostDamageGivenRank)
            Best medicine dealer 🌡 :
            \(mostMedicineGivenRank)
            """
        Console.write(1, 1, rank, 0)
        
    }
    private func _statStep_AverageScore(OfPlayer player: Player) -> Int {
        var global:Int = 0
        for toon in player.toons { global += toon.statSet.totalDamage.given + toon.statSet.medicine.received }
        return global
    }
    
    
    // MARK: G - END OF GAME
    func endOfGame() {
        Console.write(1, 0, "END OF THE GAME", 0)
    }
}
