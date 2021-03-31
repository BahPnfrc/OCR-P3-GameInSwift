//
//  Player.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 06/03/2021.
//

import Foundation

class Player {
    
    private static var newID: Int = 0
    private static func GetNewID() -> Int {
        Player.newID += 1
        return Player.newID
    }
    
    var ID: Int
    var name: String
    var toons: [Toon] = []
    var finalScore: Int = 0
        
    init(named name: String) {
        self.name = name
        self.ID = Player.GetNewID()
    }
    
    func listAllToons(aliveOnly: Bool, header: String? = nil, withBar: Bool = true) -> ClosedRange<Int> {
        // Header
        let header: String = header ?? "Team of \(self.name) :"
        Console.write(1, 1, header,0)
        // Body
        var body:String = ""
        var currentPromptID = 0
        for toon in self.toons {
            if aliveOnly == true && !toon.isAlive() { toon.promptID = 0 ; continue }
            currentPromptID += 1 ; toon.promptID = currentPromptID
            body.append(toon.getFightPrompt() + "\n")
            if withBar { body.append(toon.getLifeBar()  + "\n")}
        }
        Console.write(0, 1, body)
        return 1...currentPromptID
    }
}
