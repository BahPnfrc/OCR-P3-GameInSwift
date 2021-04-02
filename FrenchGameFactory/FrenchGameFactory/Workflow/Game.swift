//
//  Game.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 04/03/2021.
//

import Foundation

extension String {
    func withNum() -> String {
        var result: String = self
        let changeSet: [(from: String, to: String)] =
            [("0", "0️⃣"), ("1", "1️⃣"), ("2", "2️⃣"), ("3", "3️⃣"), ("4", "4️⃣"),
             ("5", "5️⃣"), ("6", "6️⃣"), ("7", "7️⃣"), ("8", "8️⃣"), ("9", "9️⃣")]
        for change in changeSet {
            result = result.replacingOccurrences(of: change.from, with: change.to)
        }
        return result
    }
    func withEmo() -> String {
        var result: String = self
        let changeSet: [(from: String, to: String)] =
            [("woman ", "🚺 "), ("man ","🚹 ")]
        for change in changeSet {
            result = result.replacingOccurrences(of: change.from, with: change.to)
        }
        return result
    }
}

enum Mode: CaseIterable { case isVersusHuman, isVersusMachine }
enum Level: CaseIterable { case isDefault, isEasy, isMedium, isHard }

class Game {
    
    private var mode: Mode
    var level: Level = .isDefault
    var player: (main: Player, second: Player)
    
    private var queue: [Player] = []
    private func switchPlayers() { self.queue.swapAt(0, 1)}
    
    var attackingPlayer: Player { return queue[0]}
    var defendingPlayer: Player { return queue[1]}
    
    var isRunningTest: Bool = true // #TEST
    
    init(){
        // MARK: A - MODE
        Console.write(0, 0, "WELCOME TO THE GAME")
        Console.write(1, 1, """
            How do you want to play ?
            1. 🧠 Against a friend
            2. ⚙️ Against the machine
            """.withNum(), 1)
        let modePrompt:Int =
            !isRunningTest ? Console.getIntInput(fromTo: 1...2) : 2 // #TEST
        mode = modePrompt == 1 ? .isVersusHuman: .isVersusMachine
        
        // MARK: B - MAIN PLAYER
        let mainNamePrompt: String =
            !isRunningTest ? Console.getStringInput(prompt: "your name") : "alex" // #TEST
        player.main = Human(mainNamePrompt.uppercased()) as Player
        
        // MARK: C - SECOND PLAYER
        switch mode {
        case .isVersusHuman:
            var secondNamePrompt: String = ""
            while true {
                secondNamePrompt =
                    !isRunningTest ? Console.getStringInput(prompt: "the other player's name") : "andre" // #TEST
                if secondNamePrompt == player.main.name { Console.write(1, 1, "⚠️ Players can't have the same name : try another ⚠️", 1)}
                else { break }
            }
            player.second = Human(secondNamePrompt.uppercased()) as Player
        case .isVersusMachine:
            Console.newSection()
            player.second = Machine() as Player
            Console.write(0, 0,
                "Ok \(player.main.name), I'm \(player.second.name) and I'm your opponent !", 0)
            // MARK: D - LEVEL
            Console.write(1, 1, """
                How do you want me to be ?
                1. 🌸 Easy. Because you're soft and delicate
                2. 🏓 Medium. For a real one on one baby
                3. 🪖 Hard. Can't fight the dust !
                """.withNum(), 1)
            let levelPrompt: Int =
                !isRunningTest ? Console.getIntInput(fromTo: 1...3) : 3 // #TEST
            level =
                levelPrompt == 1 ? .isEasy:
                levelPrompt == 2 ? .isMedium:
                .isHard
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
            1. 🏆 I want to choose first no matter what
            2. 🎳 I'd prefer to shoot first so I'll choose second
            3. 🎲 I'd rather roll the dice and let chance decide
            """.withNum(), 1)
        let orderPrompt: Int =
            !isRunningTest ? Console.getIntInput(fromTo: 1...3) : 2
        queue =
            orderPrompt == 1 ? [player.main, player.second] :
            orderPrompt == 2 ? [player.second, player.main] :
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
            if let machine = firstToChoose as? Machine {
                // A - First player is Machine ; B - Second is Human
                _chooseStep_machineChoose(forPlayer: machine)
                _chooseStep_humanChoose(forPlayer: secondToChose)
            }
            else {
                // A - First player is Human ; B - Second is Machine
                _chooseStep_humanChoose(forPlayer: firstToChoose)
                _chooseStep_machineChoose(forPlayer: secondToChose)
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
             (all: Engineer.All, message: "There it goes Engineers :"),
             (all: Military.All, message: "Time is to pick up a Military now :"),
             (all: Medical.All, message: "You can finally pick up your Medical :")]
        var previousNames: [String] = []
        var testIndex = -1
        let testData: [String] = ["toon#1", "toon#2", "toon#3"]
        for toonType in toonTypes { // For each type of toon
            testIndex += 1
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
            Console.emptyLine()
            let promptForNumber: Int =
                !isRunningTest ? Console.getIntInput(fromTo: 1...maxPromptID) : testIndex + 1 // #TEST
            let chosenToon: Toon = toonType.all.first(where: {$0.promptID == promptForNumber})!
            // C - Prompt to choose a name for this toon
            var promptForName: String = ""
            while true {
                promptForName =
                    !isRunningTest ? Console.getStringInput(prompt: "a name for this toon") : testData[testIndex] // #TEST
                if previousNames.contains(promptForName){ Console.write(1, 1, "⚠️ Toons can't have the same name : try another ⚠️", 1)}
                else { previousNames.append(promptForName) ; break }
            }
            chosenToon.name = promptForName.uppercased()
            chosenToon.isInTeam = true
            human.toons.append(chosenToon)
        }
    }
    private func _chooseStep_machineChoose(forPlayer machine: Player) {
        var results: [(ID: Int, globalSet: Double)] = []
        let toonClasses = [Engineer.All, Military.All, Medical.All]
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
    
}

// MARK: F - FIGHT
extension Game {
    
    private func fightStep() {
        Toon.resetAllPromptID()
        var counter: Int = 0
        var round: Int = 0
        repeat {
            counter += 1
            if (counter - 1).isMultiple(of: 2) {round += 1}
            Console.newSection()
            // A - Pick one player
            switchPlayers() // Attacker and defender are switched
            Console.write(0, 0, "🔔 *Ding Ding* : Round \(round) of \(attackingPlayer.name), Fight 🥊 !".withNum(), 0)
            
            if let machine = attackingPlayer as? Machine {
                
                let action = machine.play(inGame: self)
                if let doAttack = action.attackCase {
                    
                    _fightStep_machineFight(withToon: doAttack.attacker, againt: doAttack.defender)
                    
                } else {
                    
                    guard let doMedicine = action.medicineCase else { return }
                    let doctor: Medical = machine.toons.first(where: { $0.self is Medical }) as! Medical
                    let medicine = doMedicine.useMedicine ; let toon = doMedicine.onToon
                    _fightStep_machineApplyMedicine(doctor: doctor, medicine: medicine, onToon: toon)
                
                }
                
            } else {
                // B - Lists all toons
                let listHeader: String = "Ok \(attackingPlayer.name), pick one of your champions :"
                _ = attackingPlayer.listAllToons(aliveOnly: false, header: listHeader)
                // C - Choose one toon
                let choosenToon: Toon = _fightStep_chooseToon(of: attackingPlayer)
                // D - Engage in action
                var didMedicine: Bool = false
                if let medicalToon = choosenToon as? Medical { didMedicine = _fightStep_isDoctor(withToon: medicalToon)
                } else { _fightStep_isElse(withToon: choosenToon) }
                // E - Report
                if didMedicine {
                    let reportHeader = "Here is \(attackingPlayer.name)'s Team after medication ⛑ :"
                    _ = attackingPlayer.listAllToons(aliveOnly: false, header: reportHeader, withBar: true)
                } else {
                    let reportHeader = "Here is \(defendingPlayer.name)'s Team after this blow 🪖 :"
                    _ = defendingPlayer.listAllToons(aliveOnly: false, header: reportHeader, withBar: true)
                }
                // F - Prompt to continue
                let exitPrompt: Bool =  Console.getExitPrompt(exitWord: "exit")
                if exitPrompt == true { break }
            }
            
        } while _fightStep_CanContinue()
        
    }
    
    private func _fightStep_chooseToon(of player: Player) -> Toon {
        while true {
            let promptForNumber = Console.getIntInput(fromTo: 1...player.toons.count)
            let choosenToon = player.toons.first(where: { $0.promptID == promptForNumber })!
            if !choosenToon.isAlive() {
                Console.write(1, 1, choosenToon.getPicWithName() + " can't fight : \(choosenToon.getHeOrShe())'s knocked out 🥊", 1)
            } else { return choosenToon }
        }
    }
    // MARK: F - a - Medecine
    private func _fightStep_isDoctor(withToon doctor: Medical) -> Bool {
        let toonDidMedicine: Bool = _fightStep_isDoctor_DoMedicine(of: attackingPlayer, with: doctor)
        if !toonDidMedicine { // Fight
            _fightStep_chooseDefenderAndFight(withToon: doctor)
            return false
        } else {
            return true
        }
    }
    private func _fightStep_isDoctor_DoMedicine(of player: Player, with choosenToon: Toon) -> Bool {
        // A - Quit if toon is not a Medical
        guard let doctor = choosenToon as? Medical else { return false }
        // B - Prepare prompt text
        let pack: [Medicine] = doctor.medicalPack
        var promptID: Int = 0 ; var promptText: String = ""
        for index in 0...2 {
            if pack[index].left > 0 {
                promptID += 1 ; pack[index].promptID = promptID
                promptText += "\(promptID). Use \(doctor.getHisOrHer())\(pack[index].getPicWithName()) : \(pack[index].about)\n"
            } else { pack[index].promptID = 0 }
        }
        let weaponPromptID: Int = promptID + 1 ; let maxPromptID = weaponPromptID
        promptText += "\(weaponPromptID). Use \(doctor.getHisOrHer())\(doctor.weapon!.getPicWithName()) : it blows haters to smithereens"
        // C - Call prompt and get result
        Console.write(1, 1, """
            What do you want to do with \(doctor.getPicWithName()) ?
            \(promptText)
            """, 1)
        let promptForMedicine = Console.getIntInput(fromTo: 1...maxPromptID)
        if promptForMedicine == weaponPromptID {return false}
        _fightStep_isDoctor_ApplyMedecine(ofPlayer: doctor, withID: promptForMedicine)
        return true
    }
    private func _fightStep_isDoctor_ApplyMedecine(ofPlayer doctor: Medical, withID medicineID:Int) {
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
                    promptText += "\(toon.promptID). \(toon.getPicWithName()) with \(toon.getHitpointsAndPercent()) \n"
                } else { toon.promptID = 0 }
            }
            Console.write(1, 1, """
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
                promptText += "\(toon.promptID). \(toon.getPicWithName()) with \(toon.getHitpointsAndPercent()) \n"
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
        _fightStep_applyDamageAndStats(from: attacker, to: defender, of: Int(damage))
        _figthStep_Report(from: attacker, to: defender, of: Double(damage))
    }
    
    private func _fightStep_applyDamageAndStats(from attacker: Toon, to defender: Toon, of damage: Int) {
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
    }
    private func _figthStep_Report(from attacker: Toon, to defender: Toon, of damage: Double) {
        let realDamage = damage
        let expectedDamage = attacker.weapon!.isUpdated == true ?
            Setting.Weapon.expectedUpdatedDamage : Setting.Weapon.expectedBasicDamage
        let (action, result, medal) =
            (realDamage < (expectedDamage * 0.9)) ? (" scratched " , "causing only ", "🥉"):
            (realDamage < (expectedDamage * 1.1)) ? (" touched " , "amounting for ", "🥈") :
            (" punished " , "wrecking for ", "🥇")
        let attackInfo: String = "ℹ️" + attacker.getPicWithName() + action + "" + defender.getPicWithName()
        let weaponInfo: String = "With " + attacker.getHisOrHer() + attacker.weapon!.getPicWithName()
        let resultInfo: String = result + String(Int(realDamage)) + " damages " + medal
        let message: String = attackInfo + "\n" + weaponInfo + " " + resultInfo
        Console.write(1, 1, message, 1)
    }
    private func _fightStep_CanContinue() -> Bool {
        if defendingPlayer.toons.allSatisfy({ $0.lifeSet.hitpoints <= 0 }) {
            return false // stop
        } else { return true } // Stop
    }
    
    // MARK: F - C - Machine
    private func _fightStep_machineFight(withToon attacker: Toon, againt defender: Toon) {
        let damage: Double = Weapon.getDamage(from: attacker, to: defender)
        _fightStep_applyDamageAndStats(from: attacker, to: defender, of: Int(damage))
        _figthStep_Report(from: attacker, to: defender, of: Double(damage))
    }
    
    private func _fightStep_machineApplyMedicine(doctor: Medical, medicine: Medicine, onToon toon: Toon?) {
        var restoredHitpoints: Int // #STAT
        if let teamUseMedicine = medicine as? TeamUseMedicine {
            restoredHitpoints = teamUseMedicine.use(OnTeam: attackingPlayer) // #STAT
        } else {
            let singleUseMedicine = medicine as! SingleUseMedicine
            restoredHitpoints = singleUseMedicine.use(onToon: toon!) // #STAT
        }
        doctor.statSet.medicine.given += restoredHitpoints // #STAT
    }
    
    // MARK: G - STAT
    func statStep() {
        
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
                + String(mostMedicineGiven[index].statSet.medicine.given) + " hitpoints saved\n"
        }
        
        let rank:String = """
            They made History today 🏆 :
            🏁 - \(result.winner.name) : \(result.winner.finalScore) damages given
            🏳️ - \(result.loser.name) : \(result.loser.finalScore) damages given

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
