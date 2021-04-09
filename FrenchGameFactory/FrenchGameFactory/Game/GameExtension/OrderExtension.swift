//
//  OrderExtension.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 09/04/2021.
//

import Foundation

extension Game {
    
    func orderStep(){
        Console.newSection()
        Console.write(0, 0, """
            Ok \(player.main.name), two teams will now be made.
            Choosing toons first is penalized by shooting second.
            """)
        Console.write(1, 1, """
            So who choose first ?
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
            Console.write(0, 2, "⬆️. Default setting was applied : \(orderPrompt.text) ✅", 0)
        } else { orderPrompt.number = Console.getIntInput(fromTo: 1...3) }
        
        queue =
            orderPrompt.number == 1 ? [player.main, player.second] :
            orderPrompt.number == 2 ? [player.second, player.main] :
            [player.main, player.second].shuffled()
    }
}
