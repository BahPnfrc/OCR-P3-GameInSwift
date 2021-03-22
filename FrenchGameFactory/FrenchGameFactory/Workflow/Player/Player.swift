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
        
    init(named name: String) {
        self.name = name
        self.ID = Player.GetNewID()
    }
    
    func listAllToons(aliveOnly: Bool, header: String? = nil) -> ClosedRange<Int> {
        var currentPromptIndex = 0
        let message: String = header ?? "Team of \(self.name) :"
        Console.write(1, 1, message,0)
        for toon in self.toons {
            if aliveOnly == true && !toon.isAlive() {continue}
            currentPromptIndex += 1
            toon.ID = currentPromptIndex
            Console.write(0, 1, toon.getFightInfos(),0)
            Console.write(0, 1, toon.getLifeBar(),0)
        }
        Console.newLign()
        return 1...currentPromptIndex
    }
}
