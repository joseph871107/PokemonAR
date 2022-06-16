//
//  PokemonType.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/16.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//
// Reference 1 : https://swiftwithsadiq.wordpress.com/2017/08/21/custom-types-as-raw-value-for-enum-in-swift/
// Reference 2 : https://betterprogramming.pub/parse-items-with-different-key-value-pairs-in-a-json-array-with-the-help-of-enums-and-associated-301ffa81179e

import Foundation

import UIKit

struct PokemonTypeAtkScalar: Codable {
    let id: PokemonType
    let attackScalar: Float
}

struct PokemonTypeInstance: Codable {
    let id: PokemonType
    let name: String
    let damage: [PokemonTypeAtkScalar]
    
    static var unknown: PokemonTypeInstance {
        PokemonTypeInstance(id: .unknown, name: "unknown", damage: PokemonType.allCasesWithoutUnused.map({ type in
            PokemonTypeAtkScalar(id: type, attackScalar: 1)
        }))
    }
    
    var image: UIImage{
        Bundle.main.url(forResource: "pokemon.json-master/types/\(name)", withExtension: "png")?.loadImage() ?? UIImage()
    }
}

extension PokemonTypeInstance: Equatable {
    //MARK:- Equatable Methods
    static func == (lhs: PokemonTypeInstance, rhs: PokemonTypeInstance) -> Bool {
        return (
            lhs.id == rhs.id
        )
    }
}

extension PokemonTypeInstance: ExpressibleByStringLiteral {
    //MARK:- ExpressibleByStringLiteral Methods
    init(stringLiteral value: String) {
        let components = value.components(separatedBy: ",")
        if components.count == 3 {
            guard let tp = PokemonType(rawValue: components[0]) else { fatalError("Json file error.") }
            self.id = tp
            self.name = components[1]
            
            let decoder = JSONDecoder()
            let jsonData = components[2].data(using: .utf8)!
            self.damage = try! decoder.decode(Array<PokemonTypeAtkScalar>.self, from: jsonData)
        } else {
            fatalError("Json file error.")
        }
    }
}

enum PokemonType: String {
    case Bug = "POKEMON_TYPE_BUG"
    case Dark = "POKEMON_TYPE_DARK"
    case Dragon = "POKEMON_TYPE_DRAGON"
    case Electric = "POKEMON_TYPE_ELECTRIC"
    case Fairy = "POKEMON_TYPE_FAIRY"
    case Fighting = "POKEMON_TYPE_FIGHTING"
    case Fire = "POKEMON_TYPE_FIRE"
    case Flying = "POKEMON_TYPE_FLYING"
    case Ghost = "POKEMON_TYPE_GHOST"
    case Grass = "POKEMON_TYPE_GRASS"
    case Ground = "POKEMON_TYPE_GROUND"
    case Ice = "POKEMON_TYPE_ICE"
    case Normal = "POKEMON_TYPE_NORMAL"
    case Poison = "POKEMON_TYPE_POISON"
    case Psychic = "POKEMON_TYPE_PSYCHIC"
    case Rock = "POKEMON_TYPE_ROCK"
    case Steel = "POKEMON_TYPE_STEEL"
    case Water = "POKEMON_TYPE_WATER"
    case unknown
}

extension PokemonType: Codable {
    public init(from decoder: Decoder) throws {
        self = try PokemonType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

extension PokemonType: CaseIterable {
    var instance: PokemonTypeInstance {
        PokemonTypeSingleton.findInstance(of: self)
    }
    
    static var allCasesWithoutUnused: [PokemonType] {
        PokemonType.allCases.filter({ type in
            !(
                type == .unknown ||
                type == .Dark
            )
        })
    }
}

class PokemonTypeSingleton: ObservableObject{
    @Published var instances = [PokemonTypeInstance]()

    init(){
        loadData()
    }

    func loadData() {
        guard let url = Bundle.main.url(forResource: "pokemon.json-master/type", withExtension: "json")
        else{
            print("Json file not found")
            return
        }
        let data = try?Data(contentsOf: url)

        if let instances = try?JSONDecoder().decode([PokemonTypeInstance].self, from: data!) {
            self.instances = instances
        }else{
            print("Error")
        }
        print("Finished loading type.json")
    }
    
    static var types = PokemonTypeSingleton()
    
    static func findInstance(of: PokemonType) -> PokemonTypeInstance{
        if of == .unknown{
            return .unknown
        } else {
            let instanceIndex = PokemonTypeSingleton.types.instances.map({ $0.id }).firstIndex(of: of)!
            let instance = PokemonTypeSingleton.types.instances[instanceIndex]
            return instance
        }
    }
}
