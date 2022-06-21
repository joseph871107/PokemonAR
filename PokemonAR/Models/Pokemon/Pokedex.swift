//
//  Pokedex.swift
//  ViewCheatsheet
//
//  Created by Joseph Ouyang on 2022/6/12.
//

import Foundation
import UIKit

class Pokedex{
    struct PokemonInfo: Codable, Identifiable {
        var id: Int
        let name: Name
        let type: [PokemonTypeReference]
        let base: Base
        var model: Model? = .empty
        var evolution: EvolutionReference
        let skills: [PokemonSkillReference]
        
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
        
        func randomlyGenerate() -> Pokemon {
            let skillCount = Int.random(in: 1...4)
            var skillsIndex: [Int] = Array(repeating: 0, count: skillCount)
            skillsIndex = skillsIndex.map({ _ in Int.random(in: 0...(skills.count-1)) })
            
            return Pokemon(
                pokedexId: id,
                experience: Int.random(in: 0...1000), learned_skills: skillsIndex.map({ skills[$0] }))
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
            
            var info: Pokedex.PokemonInfo? {
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
            
            var info: Pokedex.PokemonInfo? {
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
    
    struct PokemonSkillReference: Codable, Hashable  {
        let id: Int
        
        var info: PokemonSkillInstance {
            PokemonSkillSingleton.findSkill(id)
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
        @Published var pokemons = [Pokedex.PokemonInfo]()
        
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
                let pokemons = try JSONDecoder().decode([Pokedex.PokemonInfo].self, from: data!)
                self.pokemons = pokemons.filter({ $0.modelUrl != nil })
            } catch {
                fatalError(String(describing: error))
            }
            print("Finished loading processed_pokedex.json")
       }
    }

    static var pokedex = PokedexInfo()
    
    static func getInfoFromId(_ id: Int) -> Pokedex.PokemonInfo {
        return Pokedex.get(id)!
    }
    
    static func mapFromInferenceID(inferenceID: Int) -> Int {
        return Int(round(Double(inferenceID - 1) / Double(90) * Double(self.pokedex.pokemons.count)) + 1)
    }
    
    static func mapFromPokemonID(pokemonID: Int) -> Int {
        return 1
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
    
    static func get(_ id: Int) -> Pokedex.PokemonInfo? {
        return pokedex.pokemons.first(where: { $0.id == id })
    }
}

struct PokeBag : Codable {
    var pokemons = [Pokemon]()
}
