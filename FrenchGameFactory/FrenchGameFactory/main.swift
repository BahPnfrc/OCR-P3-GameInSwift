//
//  main.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 02/03/2021.
//


import Foundation

// singleton design pattern
//toto.shared.tata()

Engineer.createAll()
Medical.createAll()
Military.createAll()

let game = Game()
game.thenRun()

