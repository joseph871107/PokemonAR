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

struct Pokemon: Codable, Identifiable {
    var id = UUID()
    var pokedexId: Int
    var experience = 0
    
    var level: Int {
        return (self.experience / 100) + 1
    }
    
    var info: Pokedex.Pokemon {
        Pokedex.getInfoFromId(self.pokedexId)
    }
}

struct PokeBag : Codable {
    var pokemons = [Pokemon]()
}

extension URL {
    func loadImage() -> UIImage? {
        var image: UIImage?
        
        if let data = try? Data(contentsOf: self), let loaded = UIImage(data: data) {
            image = loaded
        } else {
            image = nil
        }
        return image
    }
    func saveImage(_ image: UIImage?) {
        if let image = image {
            if let data = image.jpegData(compressionQuality: 1.0) {
                try? data.write(to: self)
            }
        } else {
            try? FileManager.default.removeItem(at: self)
        }
    }
}