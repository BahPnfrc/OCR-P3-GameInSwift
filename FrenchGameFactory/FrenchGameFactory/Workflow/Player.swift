//
//  Player.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 06/03/2021.
//

import Foundation

// MARK: Mother class
class Player {
    
    private static var newID: Int = 0
    private static func GetNewID() -> Int {
        Player.newID += 1
        return Player.newID
    }
    
    var ID: Int
    var name: String
    var toons: [Toon] = [Toon]()
        
    init(named name: String) {
        self.name = name
        self.ID = Player.GetNewID()
    }
}

// MARK: Human class
final class Human: Player { // COM
    init(_ name: String) {
        super.init(named: name)
    }
}

// MARK: Machine class
final class Machine: Player {
    
    private static let randomNames: [String] = []
    private static var randomName: String {
            Machine.randomNames.count > 0 ?
            Machine.randomNames.randomElement()!:
            "TheMachine"}
    
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
}
