//
//  Medicine.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 21/03/2021.
//

import Foundation

final class Medicine : Tool {
    
    
    
    private let lightMedicine =
        (tool: Tool("🩹", "Savage Bandage"),
         wasUsed: 0,
         maxUse: 2,
         detail: "Boost receiving toon hitpoints to 70%")
    private let mediumMedicine =
        (tool: Tool("💊", "Precision Pill"),
         wasUsed: 0,
         maxUse: 1,
         detail: "Boost receiving toon hitpoints to 90%")
    private let heavyMedicine =
        (tool: Tool("🧬", "Dna Denaturator"),
         wasUsed: 0,
         maxUse: 1,
         detail: "Boost all toons hitpoints to 50%")
   
    
    
}
