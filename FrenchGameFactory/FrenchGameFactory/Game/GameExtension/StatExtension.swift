//
//  StatExtension.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 09/04/2021.
//

import Foundation

extension Game {
    
    // MARK: A - MAIN
    func statStep() {
        
        // A - Global HP given + restored score
        player.main.finalScore = _statStep_AverageScore(OfPlayer: player.main)
        player.second.finalScore = _statStep_AverageScore(OfPlayer: player.second)
        
        // B - Declaration of result
        (self.winner, self.loser) = _statStep_getWinnerAndLoser()
        guard let winner = self.winner, let loser = self.loser else {
            Console.writeError(atLine: #line, inFunc: #function)
            return
        }
        _statStep_gameAward(withWinner: winner, withLoser: loser)
        
        // C - Prepare data for awards
        for player in [winner, loser] { for toon in player.toons {
            toon.name! += " (\(player.name))" // Add team to name of toon
        }}
        var allToons = player.main.toons + player.second.toons // Gather all toons
        allToons.sort { toon0, toon1 in // Sort by hitpoints and damage given if equals
            return (toon0.lifeSet.hitpoints, toon0.statSet.totalDamage.given)
                > (toon1.lifeSet.hitpoints, toon1.statSet.totalDamage.given)
            }
        
        // D - Give awards
        _statStep_survivorAwards(withToons: allToons)
        _statStep_otherAwards(withToons: allToons)
        
    }
    
    // MARK: B - RESULT
    private func _statStep_AverageScore(OfPlayer player: Player) -> Int {
        var global:Int = 0
        for toon in player.toons { global += toon.statSet.totalDamage.given + toon.statSet.medicine.received }
        return global
    }
    
    private func _statStep_getWinnerAndLoser() -> (Player, Player){
        let mainPlayerLeftToon: [Toon] = player.main.toons.filter({ $0.isAlive() })
        let secondPlayerLeftToon: [Toon] = player.second.toons.filter({ $0.isAlive() })
        switch (mainPlayerLeftToon.count, secondPlayerLeftToon.count) {
        case (1...3, 0): return (player.main, player.second)
        case (0, 1...3): return (player.second, player.main)
        default: return player.main.finalScore > player.second.finalScore ?
            (player.main, player.second) : (player.second, player.main)
        }
    }
    
    private func _statStep_gameAward(withWinner winner: Player, withLoser loser: Player) {
        Console.write(1, 0, "⏹ Round #️⃣\(roundPlayed)✅ : 🔔 *Ding Ding* We have a champion 🏆 !" .withNum(),0)
        Console.write(1, 1, """
            🏁 Winner : \(winner.name) with \(winner.finalScore) HP Taken + Healed
            🏳️ Loser : \(loser.name) with \(loser.finalScore) HP Taken + Healed
            """, 0)
    }
    
    // MARK: C - AWARDS
    private func _statStep_survivorAwards(withToons allToons: [Toon]) {
        // Survivor award
        let Medals: [String] = ["🥇", "🥈", "🥉"]
        var survivorAward: String = ""
        for index in 0...2 {
            let toon = allToons[index]
            guard toon.isAlive() else { continue }
            survivorAward += "\(Medals[index]). 🎖" + toon.getPicWithName() + " : \(toon.lifeSet.hitpoints) HP Left\n"
        }
        Console.write(1, 1, """
            1️⃣. Survivor ✨award✨ 👑 :"
            \(survivorAward)
            """, 0)
    }
    
    private func _statStep_otherAwards(withToons allToons: [Toon]) {
        
        let hitmanNominated : [Toon]  = allToons.sorted {$0.statSet.bestDamage.given > $1.statSet.bestDamage.given}
        let berserkerNominated: [Toon] = allToons.sorted {$0.statSet.totalDamage.given > $1.statSet.totalDamage.given}
        let doctorNominated: [Toon] = allToons.sorted {$0.statSet.medicine.given > $1.statSet.medicine.given}
        
        let hitmanAward: String = _statStep_getRank(
            withToons: hitmanNominated, withMaxIndex: 2, withType: "Taken",
            rankCheck: { (toons: [Toon]) -> Bool in return toons.allSatisfy({ $0.statSet.bestDamage.given == 0 }) },
            rankValue: { (toon: Toon) -> Int in return toon.statSet.bestDamage.given })
        let berserkerAward: String = _statStep_getRank(
            withToons: berserkerNominated, withMaxIndex: 2, withType: "Taken",
            rankCheck: { (toons: [Toon]) -> Bool in return toons.allSatisfy({ $0.statSet.totalDamage.given == 0 }) },
            rankValue: { (toon: Toon) -> Int in return toon.statSet.totalDamage.given })
        let doctorAward: String = _statStep_getRank(
            withToons: doctorNominated, withMaxIndex: 1, withType: "Healed",
            rankCheck: { (toons: [Toon]) -> Bool in return toons.allSatisfy({ $0.statSet.medicine.given == 0 }) },
            rankValue: { (toon: Toon) -> Int in return toon.statSet.medicine.given })
        
        Console.write(0, 1, """
            2️⃣. Hitman ✨award✨ 🎯 :
            \(hitmanAward)
            3️⃣. Berserker ✨award✨ ⚔️ :
            \(berserkerAward)
            4️⃣. Doctor ✨award✨ 🌡 :
            \(doctorAward)
            """, 0)
    }
    
    // MARK: D - TOOLS
    private func _statStep_getRank(
            withToons toons: [Toon], withMaxIndex maxIndex: Int, withType type: String,
            rankCheck noRankCheck: ([Toon]) -> Bool,
            rankValue getRankValue: (Toon) -> Int
            ) -> String {
        var result: String = ""
        if noRankCheck(toons) == true {
            return "- No toon was ranked\n"
        } else { for index in 0...maxIndex {
            guard maxIndex <= (Game.Medals.count - 1) else { break }
            let toonRankValue = getRankValue(toons[index])
            guard toonRankValue > 0 else { continue }
            result += Game.Medals[index] + ". " + toons[index].getPicWithName() + " : "
                + String(toonRankValue) + " HP " + type + "\n"
        }}
        return result
    }
    
    private func _statStep_getBar (
            with part: Int,
            outOf total: Int,
            legend: String,
            withBlocks blocks: Int = 20,
            colored: String = "🟦",
            blank: String = "⬜️"
            ) -> String {
        let percent: Int = part * 100 / total
        let coloredBlockNumber: Int = percent * blocks / 100
        let blankBlockNumber: Int = blocks - coloredBlockNumber
        var lifeBar: String = ""
        lifeBar.append(String(repeating: colored, count: coloredBlockNumber))
        lifeBar.append(String(repeating: blank, count: blankBlockNumber))
        return lifeBar + " \(percent)% " + legend
    }
    
}
