//
//  main.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 02/03/2021.
//


import Foundation

// Create all toons
EngineerToon.createAll()
MedicalToon.createAll()
MilitaryToon.createAll()
// Run the game
let game = Game()
game.run()
