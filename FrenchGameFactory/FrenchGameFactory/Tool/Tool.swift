//
//  Tool.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 05/03/2021.
//

import Foundation

// MARK: Mother class
class Tool {
    
    let pic: String
    let name: String

    func getPicWithName() -> String {
        self.pic + " " + self.name
    }
    
    init (withPic pic: String,
          withName name: String) {
        (self.pic, self.name)  = (pic, name)
    }
}


