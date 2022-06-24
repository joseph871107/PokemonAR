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
    
    func damage(skill: PokemonSkillInstance, on: Pokemon) -> Int {
        let level = self.level
        let power = skill.power ?? 0
        let accuracy = (skill.accuracy) ?? 100
        let isMissed = Int.random(in: 0...100) > accuracy
        
        let myAttack: Int = Int(Double((power + self.info.base.Attack) * self.level) / 5.0)
        let enemyDefense: Int = Int(Double(on.info.base.Defense * on.level) / 5.0)
        var trueDamage = (myAttack - enemyDefense)
        if trueDamage < 0{
            trueDamage = 0
        }
        
        if isMissed {
            return 0
        } else {
            return Int(
                round(
                    Double(trueDamage) /
                    Double(level)
                )
            )
        }
    }
    
    static func == (lhs: Pokemon, rhs: Pokemon) -> Bool {
       return lhs.id == rhs.id
    }
}
