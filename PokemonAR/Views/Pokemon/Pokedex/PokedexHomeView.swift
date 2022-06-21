//
//  PokedexHomeView.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/21.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

import SwiftUI

struct PokedexHomeView: View {
    @EnvironmentObject var userSession: UserSessionModel
    @EnvironmentObject var pokebag: PokeBagViewModel
    
    @State var show = false
    @State var selectedPokemonIndex: Int = 0
    
    var body: some View {
        ZStack {
#if DEBUG
            VStack(alignment: .leading) {
                HStack{
                    Button(action: {
                        print("Pokebag user ID : \(pokebag.userID)")
                        pokebag.addPokemon(pokemon: Pokemon(pokedexId: 1))
                    }, label: {
                        Text("Add one")
                    })
                    Button(action: {
                        print("Pokebag user ID : \(pokebag.userID)")
                        pokebag.addDemo()
                    }, label: {
                        Text("Add demo")
                    })
                    Button(action: {
                        print("Pokebag user ID : \(pokebag.userID)")
                        pokebag.addDemoWithRandomName()
                    }, label: {
                        Text("Add demo with random name")
                    })
                    Button(action: {
                        print("Pokebag user ID : \(pokebag.userID)")
                        pokebag.removeAll()
                    }, label: {
                        Text("Remove all")
                    })
                }
                Spacer()
            }
            .zIndex(1)
#endif
            PokedexView(titleView: {
                Text("Pokédex")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }, onSelectedCallback: { pokemon in
                selectedPokemonIndex = pokebag.pokemons.firstIndex(of: pokemon)!
                
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                    show = true
                }
            })
            .sheet(isPresented: $show) {
                PokemonView(index: $selectedPokemonIndex)
                    .environmentObject(pokebag)
                    .environmentObject(userSession)
                    .environmentObject(pokebag)
            }
        }
    }
}
