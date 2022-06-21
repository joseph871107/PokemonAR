//
//  Pokemon.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/21.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

struct Pokemon: Codable, Identifiable, Equatable, Hashable {
    var id = UUID()
    var createDate = Date()
    
    var pokedexId: Int
    var experience = 0
    var displayName: String = ""
    var learned_skills: [Pokedex.PokemonSkillReference] = []
    
    var unitsPerLevel: Int {
        return 100
    }
    
    var level: Int {
        return (self.experience / unitsPerLevel) + 1
    }
    
    var remainExperience: Int {
        return experience - (level - 1) * unitsPerLevel
    }
    
    var remainExperiencePercentage: Double {
        return Double(Double(remainExperience) / Double(unitsPerLevel))
    }
    
    var name: String {
        if displayName == "" {
            return info.name.english
        } else {
            return displayName
        }
    }
    
    var info: Pokedex.PokemonInfo {
        Pokedex.getInfoFromId(self.pokedexId)
    }
    
    static func == (lhs: Pokemon, rhs: Pokemon) -> Bool {
       return lhs.id == rhs.id
    }
}
