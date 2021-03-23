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

//Console.write(1,2, "111", 0)
//Console.emptyLine()
//Console.write(0,0, "222", 0)
//Console.write(0,0, "333", 0)
//Console.write(0,0, "444", 0)
//Console.write(0,0, "555", 0)

let game = Game()
game.run()

