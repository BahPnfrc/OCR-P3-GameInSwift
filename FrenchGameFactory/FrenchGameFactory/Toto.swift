//
//  Toto.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 13/03/2021.
//

import Foundation

class toto{
    
    // I. Déf. d'un Singleton : Patron de conception , design pattern
    // II. Danger d'un Singleton : Dangereux en multithread car "restreint l'instanciation d'une classe à un seul objet"
    // III. Value/Référence : SAD (string, array, dict) => Value type !
    // IV. Plan pratique, à quoi sert de déballer : déballer sert à débuguer (optionnel)
    
    static let shared = toto()
    func tata() {
        print("bonjour")
    }
}
