//
//  UserDataModel.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/15.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

import UIKit

import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserDataModel: Codable, Identifiable {
    @DocumentID var id: String?
    var userID: String = ""
    
    var birthday: Date = Date()
    var gender: Gender = .NotRevealed
    
    var experience: Int = 0
    
    static var empty: UserDataModel {
        UserDataModel(id: "", userID: "")
    }
    
    var unitsPerLevel: Int {
        return 1000
    }
    
    var level: Int {
        return (self.experience / unitsPerLevel) + 1
    }
    
    var remainExperience: Int {
        return experience - (level - 1) * unitsPerLevel
    }
    
    var remainExperiencePercentage: CGFloat {
        return CGFloat(Double(remainExperience) / Double(unitsPerLevel))
    }
}

enum Gender : String, Codable, CaseIterable {
    case Male
    case Female
    case Neither
    case NotRevealed = "Not revealed"
}
