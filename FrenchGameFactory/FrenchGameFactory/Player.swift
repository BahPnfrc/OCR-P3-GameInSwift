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
    static var All: [Player] = [Player]()
    
    private static var newID: Int = 0
    private static func GetNewID() -> Int {
        Player.newID += 1
        return Player.newID
    }
    
    // Properties
    var ID: Int
    var name: String
    var toons: [Toon] = [Toon]()
    
    
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
    
    enum Level { case easy, medium, hard }
    var level: Level = .medium
    
    private static let randomNames: [String] = [String]() //
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
