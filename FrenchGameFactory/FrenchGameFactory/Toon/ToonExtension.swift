//
//  ToonExtension.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 10/04/2021.
//

import Foundation

extension Toon {
    
    private static var defaultNameForMan: [String] =
        ["Zenon", "Danton", "Gatien", "Zephir", "Clodomir",
        "Petrus", "Lazare", "Flavien", "Ovide", "Medard"]
    
    private static var defaultNameForWoman: [String] =
        ["Evodie", "Rejane", "Vitaline", "Nonce", "Toussine",
         "Firmine", "Peroline", "Gratienne", "Renelle", "Zilda"]
    
    func getRandomName() -> String {
        var randomName: String
        var rightArray = self.gender == .isMan ?
            Toon.defaultNameForMan : Toon.defaultNameForWoman
        rightArray.shuffle()
        randomName = rightArray.first!
        rightArray.removeFirst()
        return randomName
    }
    static func getStaticRandomName(forToon toon: Toon) -> String {
        var randomName: String
        var rightArray = toon.gender == .isMan ?
            Toon.defaultNameForMan : Toon.defaultNameForWoman
        rightArray.shuffle()
        randomName = rightArray.first!
        rightArray.removeFirst()
        return randomName
    }
    
    func getHeOrShe(withMaj:Bool = false) -> String {
        gender == .isMan ?
            (withMaj == true ? "He " : "he ") :
            (withMaj == true ? "She " : "she ")
    }
    func getHisOrHer(withMaj:Bool = false) -> String {
        gender == .isMan ?
            (withMaj == true ? "His " : "his ") :
            (withMaj == true ? "Her " : "her ")
    }
    func getAgeWithGender() -> String {
        age.rawValue + " " + gender.rawValue
    }
    func getPicWithName() -> String {
        var pic = self.pic
        if !isAlive() { pic = "❌" + pic }
        else if isSick() { pic = "🦠" + pic }
        guard let name = name else { return  pic + " " + title }
        return pic + " " + title + " " + name
    }
    func getChooseToonPrompt() -> String {
        let name: String = String(promptID) + ". " +  getPicWithName() + " " + gender.rawValue
        let age: String = "a " + self.age.rawValue
        let tool: String = "with " + getHisOrHer() + weapon!.getPicWithName()
        return name + " : " + age + " " + tool
    }
    func getFightPrompt() -> String {
        let name : String = String(promptID).withNum() + ". " + getPicWithName()
        let tool : String = weapon!.getPicWithName()
        return name + " with " + getHisOrHer() + tool
    }
    
    func getFightPromptWithBar() -> String {
        return getFightPrompt() + "\n" + getLifeBar() + "\n"
    }
    
    func getHitpointsAndPercent() -> String {
        return "\(self.lifeSet.hitpoints) HP left : \(getPercentLeft())%"
    }
    
    func getLifeBar(withBlocks blocks: Int = 28) -> String {
        // A - Percent as a string
        let percentLeft: Int = self.getPercentLeft()
        var percentText: String = String(percentLeft)
        if percentLeft == 0 && self.isAlive() { percentText = "±0"}
        let percentAsString = " " + percentText + "%"
        // B - Percent as a picture
        let barLenght: Int = blocks
        let model: [(percent: Int, block: String)] =
        [(60, "🟩"), (40, "🟨"), (20, "🟧"),(0, "🟥")]
        var lifeBar: String = ""
        for step in model {
            if percentLeft > step.percent {
                var coloredBlockNumber: Int = percentLeft * barLenght / 100
                if coloredBlockNumber == 0 { coloredBlockNumber = 1 } //
                let blankBlockNumber: Int = barLenght - coloredBlockNumber
                lifeBar.append(String(repeating: step.block, count: coloredBlockNumber))
                lifeBar.append(String(repeating: "⬜️", count: blankBlockNumber))
                return lifeBar + percentAsString
            }
        }
        lifeBar.append(String(repeating: "⬜️", count: barLenght))
        return lifeBar + percentAsString
    }
}
