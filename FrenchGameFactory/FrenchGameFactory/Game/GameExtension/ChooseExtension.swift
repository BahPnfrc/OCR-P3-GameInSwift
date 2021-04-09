//
//  ChooseExtension.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 09/04/2021.
//

import Foundation

extension Game {
    
    // MARK: A - MAIN
    func chooseStep(){
        
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
            else { // A - First player is Human ; B - Second is Machine
                _chooseStep_humanChoose(forPlayer: firstToChoose)
                _chooseStep_machineChoose(forPlayer: secondToChose)
                _chooseStep_machineReportChoose(forPlayer: secondToChose, as: .second)
            }
        }
    }
    
    // MARK: B - HUMAN ACTIONS
    private func _chooseStep_humanChoose(forPlayer human: Player, withHeader header: String? = nil){
        
        let defaultHeader: String = """
            Ok \(human.name), time is to choose your toons.
            You must pick one Engineer, one Military and one Medical.
            """
        Console.newSection()
        Console.write(0, 0, header ?? defaultHeader)
        
        let toonTypes = [
             (all: EngineerToon.All, subHeader: "There it goes Engineers :"),
             (all: MilitaryToon.All, subHeader: "Time is to pick up a Military now :"),
             (all: MedicalToon.All, subHeader: "You can finally pick up your Medical :")]
        
        for toonType in toonTypes { // For each type of toon
            
            // A - Show message and list all toons
            var promptText: String = ""
            Console.write(1, 1, toonType.subHeader, 0)
            var maxPromptID: Int = 0
            for toon in toonType.all {
                if !toon.isInTeam {
                    maxPromptID += 1 ; toon.promptID = maxPromptID
                    promptText += toon.getChooseToonPrompt() + "\n"
                } else {toon.promptID = 0}
            }
            Console.write(0, 1, promptText.withNum().withEmo(), 0)
            
            // B - Prompt to choose a toon by its ID
            let promptForNumber: Int = !Setting.Game.fastPlayEnabled ?
                Console.getIntInput(fromTo: 1...maxPromptID) :
                (1...maxPromptID).randomElement()!
            let chosenToon: Toon = toonType.all.first(where: {$0.promptID == promptForNumber})!
            
            // C - Prompt to choose a name for this toon
            var promptForName: String = ""
            while true {
                promptForName = !Setting.Game.fastPlayEnabled ?
                    Console.getStringInput(prompt: "a name for this toon") :
                    Toon.getStaticRandomName(forToon: chosenToon)
                if Setting.Game.fastPlayEnabled == false && self.previousNames.contains(promptForName) {
                    Console.write(1, 1, "⚠️ Toons can't have the same name : try another ⚠️", 1)
                }
                else if Setting.Game.fastPlayEnabled == false && promptForName.count < 3 {
                    Console.write(1, 1, "⚠️ A name should count at least 3 caracters : try longer ⚠️".withNum(), 1)
                }
                else { self.previousNames.append(promptForName) ; break }
            }
            chosenToon.name = promptForName.uppercased()
            chosenToon.isInTeam = true
            human.toons.append(chosenToon)
            
            // D - Fast play notify
            if Setting.Game.fastPlayEnabled == true {
                Console.write(0, 2, "⬆️. Random toon was picked : \(chosenToon.getPicWithName()) ✅", 0)
            }
        }
    }
    
    // MARK: C - MACHINE ACTIONS
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
            case .isEasy: results.sort { $0.globalSet < $1.globalSet } // Worst toon first
            case .isHard: results.sort { $0.globalSet > $1.globalSet } // Best toon first
            default: // .isMedium
                results.sort { $0.globalSet > $1.globalSet } // Best toon first
                results.removeFirst() ; results.removeLast(2) ; results.shuffle()
            }
            
            // C - Pick the toon at the top [0] index
            let rightToon = toonClass.first(where: {$0.promptID == results[0].ID} )!
            rightToon.name = rightToon.getRandomName().uppercased() // Get a random 1900' name
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
        if order == .first { Console.write(1, 1, "⚙️ \(machine.name) chose first and decided to cherry pick :\n" + reportText, 0)
        } else {  Console.write(1, 1, "⚙️ \(machine.name) made a choice too and finally picked :\n" + reportText, 0) }
        Console.getBreakPrompt()
    }
}
