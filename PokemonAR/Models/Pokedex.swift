//
//  Pokedex.swift
//  ViewCheatsheet
//
//  Created by Joseph Ouyang on 2022/6/12.
//

import Foundation
import UIKit

class Pokedex{
    struct Pokemon: Codable, Identifiable {
        let id: Int
        let name: Name
        let type: [String]
        let base: Base
        let model: Model
        
        var image: UIImage{
            Bundle.main.url(forResource: "pokemon.json-master/sprites/\(String(format: "%03dMS", id))", withExtension: "png")?.loadImage() ?? UIImage()
        }
        
        var modelUrl: URL? {
            let name = "Models/\(model.file_name)"
            var splits = name.split(separator: ".")
            guard let ext = splits.popLast() else { return nil }
            
            return Bundle.main.url(forResource: splits.joined(separator: "."), withExtension: String(ext))
        }
    }

    struct Name: Codable {
        let english: String
        let japanese: String
        let chinese: String
    }
    
    struct Base: Codable {
        let HP: Int
        let Attack: Int
        let Defense: Int
        let SpAttack: Int
        let SpDefense: Int
        let Speed: Int
        
        enum CodingKeys: String, CodingKey, CaseIterable {
            case HP
            case Attack
            case Defense
            case SpAttack = "Sp. Attack"
            case SpDefense = "Sp. Defense"
            case Speed
        }
    }
    
    struct Model: Codable {
        let file_name: String
        let name: String
        let gender: String?
        let type: String?
    }
    
    class PokedexInfo: ObservableObject{
        @Published var pokemons=[Pokedex.Pokemon]()
        
        init(){
            loadData()
        }
        
        func loadData(){
            guard let url = Bundle.main.url(forResource: "pokemon.json-master/sorted_pokedex", withExtension: "json")
                else{
                    print("Json file not found")
                    return
            }
            let data = try?Data(contentsOf: url)
            print(data!)
            
            if let pokemons = try?JSONDecoder().decode([Pokedex.Pokemon].self,from: data!) {
                self.pokemons = pokemons
            }else{
                print("Error")
            }
            print("Finished")
       }
    }

    static var pokedex = PokedexInfo()
    
    static func getInfoFromId(_ id: Int) -> Pokedex.Pokemon {
        pokedex.pokemons[id - 1]
    }
}

struct Pokemon: Codable, Identifiable, Equatable {
    var id = UUID()
    var createDate = Date()
    
    var pokedexId: Int
    var experience = 0
    var displayName: String = ""
    
    var unitsPerLevel: Int {
        return 100
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
    
    var name: String {
        if displayName == "" {
            return info.name.english
        } else {
            return displayName
        }
    }
    
    var info: Pokedex.Pokemon {
        Pokedex.getInfoFromId(self.pokedexId)
    }
    
    static func == (lhs: Pokemon, rhs: Pokemon) -> Bool {
       return lhs.id == rhs.id
    }
}

struct PokeBag : Codable {
    var pokemons = [Pokemon]()
}
