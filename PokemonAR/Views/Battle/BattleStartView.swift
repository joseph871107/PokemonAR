//
//  BattleStartView.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/21.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

import SwiftUI

struct BattleStartView: View {
    @EnvironmentObject var userSession: UserSessionModel
    @EnvironmentObject var pokebag: PokeBagViewModel
    
    @Binding var showSheet: Bool
    @State var enemyPokemon: Pokemon?
    
    @State var startBattling = false
    @State private var showingConfirmation = false
    
    var body: some View {
        GeometryReader { geometry in
            if startBattling {
                JSWebViewDemoView()
                    .environmentObject(userSession.battleObjectDecoder)
                ZStack {
                    Color.pokemonRed.ignoresSafeArea()
                    Text("Classic Battle")
                        .font(.headline)
                        .foregroundColor(.white)
                    HStack() {
                        Button(action: {
                            showingConfirmation = true
                        }, label: {
                            HStack {
                                Image(systemName: "chevron.backward")
                                Text("Exit the Battle")
                            }
                            .foregroundColor(.white)
                        })
                        .padding()
                        Spacer()
                    }
                }
                .frame(height: geometry.size.height * 0.1)
            } else {
                ZStack {
                    PokemonSelectionView(callback: { pokemon in
                        onStart(pokemon: pokemon)
                    })
                    .environmentObject(pokebag)
                }
            }
        }
        .transition(.move(edge: .trailing))
        .animation(.easeInOut)
        .alert(isPresented:$showingConfirmation) {
            Alert(
                title: Text("Are you sure you want to exit the battle?"),
                message: Text("This will end the battle and you will not be able to go back here."),
                primaryButton: .destructive(Text("Exit")) {
                   onExit()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    func onStart(pokemon: Pokemon) {
        userSession.battleObjectDecoder.observableViewModel.updatePokemon(pokemon: pokemon)
        startBattling = true
    }
    
    func onExit() {
        userSession.battleObjectDecoder.observableViewModel.deleteUserModel()
        startBattling = false
        showSheet = false
    }
}

struct PokemonSelectionView: View {
    @EnvironmentObject var pokebag: PokeBagViewModel
    
    @State var callback: (Pokemon) -> Void
    @State var selectedPokemon: Pokemon?
    
    var body: some View {
        PokedexView(titleView: {
            Text("Select your Pokemon")
                .font(.title)
                .foregroundColor(.white)
                .padding()
        }, onSelectedCallback: { pokemon in
            selectedPokemon = pokemon
            
            if let selectedPokemon = selectedPokemon {
                self.callback(selectedPokemon)
            }
        })
    }
}

struct Previews_BattleStartView_Previews: PreviewProvider {
    static var previews: some View {
        getBattleStartView()
    }
}

func getBattleStartView() -> some View {
    let userSession = UserSessionModel()
    let pokebag = PokeBagViewModel()
    let battleStartView = BattleStartView(showSheet: .constant(true))
        .environmentObject(userSession)
        .environmentObject(pokebag)
    userSession.loginDemo(completion: { result in
        pokebag.updateUser(userID: userSession.user?.uid ?? "")
    })
    return battleStartView
}
