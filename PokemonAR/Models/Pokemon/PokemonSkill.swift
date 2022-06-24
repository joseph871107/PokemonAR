//
//  PokemonSkill.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/20.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

import UIKit

struct PokemonSkillInstance: Codable {
    let id: Int
    let name: String
    let power: Int?
    let pp: Int?
    let type: String
    let accuracy: Int?
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case name = "ename"
        case power
        case pp
        case type
        case accuracy
    }
}

extension PokemonSkillInstance: Equatable {
    //MARK:- Equatable Methods
    static func == (lhs: PokemonSkillInstance, rhs: PokemonSkillInstance) -> Bool {
        return (
            lhs.id == rhs.id
        )
    }
}

class PokemonSkillSingleton: ObservableObject{
    @Published var instances = [PokemonSkillInstance]()

    init(){
        loadData()
    }

    func loadData() {
        guard let url = Bundle.main.url(forResource: "pokemon.json-master/moves", withExtension: "json")
        else{
            print("Json file not found")
            return
        }
        let data = try?Data(contentsOf: url)

        do {
            let instances = try JSONDecoder().decode([PokemonSkillInstance].self, from: data!)
            self.instances = instances
        } catch {
            fatalError(String(describing: error))
        }
        print("Finished loading moves.json")
    }
    
    static var skills = PokemonSkillSingleton()
    
    static func findSkill(_ id: Int) -> PokemonSkillInstance {
        return skills.instances.first(where: { $0.id == id })!
    }
}
