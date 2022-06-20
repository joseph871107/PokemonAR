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
        var id: Int
        let name: Name
        let type: [PokemonTypeReference]
        let base: Base
        var model: Model? = .empty
        var evolution: EvolutionReference
        
        var image: UIImage{
            Bundle.main.url(forResource: "pokemon.json-master/sprites/\(String(format: "%03dMS", id))", withExtension: "png")?.loadImage() ?? UIImage()
        }
        
        var modelUrl: URL? {
            if let model = model {
                let name = "\(model.file_name)"
                var splits = name.split(separator: ".")
                guard let _ = splits.popLast() else { return nil }
                
                return Bundle.main.url(forResource: splits.joined(separator: "."), withExtension: "scn")
            } else {
                return .none
            }
        }
    }
    
    struct EvolutionReference: Codable, Hashable {
        static func == (lhs: Pokedex.EvolutionReference, rhs: Pokedex.EvolutionReference) -> Bool {
            lhs.pastBranches == rhs.pastBranches && lhs.futureBranches == rhs.futureBranches
        }
        
        var pastBranches: [PastBranch]
        var futureBranches: [FutureBranch]
        
        struct PastBranch: Codable, Hashable {
            let index: Int
            let id: Int
            
            var info: Pokedex.Pokemon? {
                return Pokedex.get(id)
            }
            
            static func == (lhs: Pokedex.EvolutionReference.PastBranch, rhs: Pokedex.EvolutionReference.PastBranch) -> Bool {
                lhs.id == rhs.id
            }
        }
        
        struct FutureBranch: Codable, Hashable {
            let hier_index: Int
            let id: Int
            let futureBranches: [FutureBranch]
            
            var info: Pokedex.Pokemon? {
                return Pokedex.get(id)
            }
            
            static func == (lhs: Pokedex.EvolutionReference.FutureBranch, rhs: Pokedex.EvolutionReference.FutureBranch) -> Bool {
                lhs.id == rhs.id
            }
        }
    }
    
    struct PokemonTypeReference: Codable, Hashable  {
        let id: PokemonType
        let name: String
        
        var info: PokemonType {
            self.id
        }
    }

    struct Name: Codable, Hashable {
        let english: String
        let japanese: String
        let chinese: String
    }
    
    struct Base: Codable, Hashable {
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
        
        static var empty: Model {
            Model(file_name: "", name: "", gender: "", type: "")
        }
    }
    
    class PokedexInfo: ObservableObject{
        @Published var pokemons=[Pokedex.Pokemon]()
        
        init(){
            loadData()
        }
        
        func loadData(){
            guard let url = Bundle.main.url(forResource: "pokemon.json-master/processed_pokedex", withExtension: "json")
                else{
                    print("Json file not found")
                    return
            }
            let data = try? Data(contentsOf: url)
            
            do {
                let pokemons = try JSONDecoder().decode([Pokedex.Pokemon].self, from: data!)
                self.pokemons = pokemons
            } catch {
                fatalError(String(describing: error))
            }
            print("Finished loading processed_pokedex.json")
       }
    }

    static var pokedex = PokedexInfo()
    
    static func getInfoFromId(_ id: Int) -> Pokedex.Pokemon {
        return Pokedex.get(id)!
    }
    
    static func mapFromInferenceID(inferenceID: Int) -> Int? {
        return nil
    }
    
    static func mapFromPokemonID(pokemonID: Int) -> Int? {
        return nil
    }
    
    static func findPokemonByName(name: String) -> Int? {
        if name.contains("Pokemon") {
            let start = name.index(name.startIndex, offsetBy: 9)
            if let id = Int(name.substring(with: start..<name.endIndex)) {
                return id
            }
        }
        
        return nil
    }
    
    static func get(_ id: Int) -> Pokedex.Pokemon? {
        return pokedex.pokemons.first(where: { $0.id == id })
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
