//
//  Toto.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 13/03/2021.
//

import Foundation


class toto{
    
    // Patron de conception , design pattern
    // dangereux en multithread car "restreint l'instanciation d'une classe à un seul objet"
    
    //let toto = "bonjour"
    //let tata = toto
    
    // array string dict = value type  par coeur
    
    // déballer sert à débuguer (optionnel)
    
    static let shared = toto()
    func tata() {
        print("bonjour")
    }
}
