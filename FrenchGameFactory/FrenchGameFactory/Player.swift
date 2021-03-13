//
//  Player.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 06/03/2021.
//

import Foundation

// MARK: Mother class
class Player {
    
    // Static
    static let Max: Int = 2
    static var All: [Player] = [Player]()
    static private var newID: Int = 0
    static private func GetNewID() -> Int {
        Player.newID += 1
        return Player.newID
    }
    
    // Properties
    var ID: Int
    var name: String
    var toons: [Toon]? // COM
    
    
    // https://www.behindthename.com/top/lists/france/1900
    private static var defaultNameForMan: [(Bool, String)] =
        [(isUsed: false, name: ""),
         (isUsed: false, name: ""),
         (isUsed: false, name: ""),
         (isUsed: false, name: ""),
         (isUsed: false, name: ""),
         (isUsed: false, name: ""),
         (isUsed: false, name: ""),
         (isUsed: false, name: ""),
         (isUsed: false, name: "")]
    // https://www.behindthename.com/top/lists/france/1900
    private static var defaultnameForWoman: [(Bool, String)] =
        [(isUsed: false, name: "Evodie"),
         (isUsed: false, name: "Rejane"),
         (isUsed: false, name: "Vitaline"),
         (isUsed: false, name: "Nonce"),
         (isUsed: false, name: "Toussine"),
         (isUsed: false, name: "Firmine"),
         (isUsed: false, name: "Gratienne"),
         (isUsed: false, name: "Renelle"),
         (isUsed: false, name: "Zilda")]
        
    // Init
    init(_ name: String) {
        self.name = name
        self.ID = Player.GetNewID()
    }
}

// MARK: Human class
final class Human: Player { // COM
    override init(_ name: String) {
        super.init(name)
    }
}

// MARK: Machine class
final class Machine: Player {
    
    private static let names: [String] = // COM
        ["Grimhilde", "Brutus", "Ratigan"]
    
    var level: Level // COM
    
    init(level: Level) {
        self.level = level // COM
        var randomName: String { // COM
            return Machine.names.count > 0 ?
                Machine.names.randomElement()!:
                "Nero"
        }
        super.init(randomName)
    }
}

// MARK: EXTENSION
extension Machine { // COM
    enum Level {
        case easy, medium, hard
    }
}
