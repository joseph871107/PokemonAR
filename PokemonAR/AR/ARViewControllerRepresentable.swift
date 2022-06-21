//
//  ARViewControllerRepresentable.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/17.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

import Combine
import UIKit
import SwiftUI

import ARKit
import RealityKit

struct ARViewControllerRepresentable: UIViewControllerRepresentable {
    @EnvironmentObject var userSession: UserSessionModel
    
    @State var viewController: ARViewController?
    
    @Binding var enableBattleSheet: Bool
    
    @State var onPokemonEnter: (Pokedex.PokemonInfo) -> Void = { pokemon in
        
    }
    
    func makeUIViewController(context: Context) -> ARViewController {
        let viewController = UIStoryboard(name: "ARMain", bundle: nil).instantiateViewController(withIdentifier: "ARViewController") as! ARViewController
        self.viewController = viewController
        viewController.onPokemonEnter = { pokemon in
            onPokemonEnter(pokemon)
            enableBattleSheet = true
            userSession.battleObjectDecoder.observableViewModel.updateEnemyPokemon(pokemon: pokemon.randomlyGenerate())
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = ARViewController
}
