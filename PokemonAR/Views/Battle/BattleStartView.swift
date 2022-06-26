//
//  BattleStartView.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/21.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

import SwiftUI

enum BattleAlert {
    typealias RawValue = Hashable
    
    case onExit
    case onFinished
    case onCatch
}

struct BattleStartView: View {
    @EnvironmentObject var userSession: UserSessionModel
    @EnvironmentObject var pokebag: PokeBagViewModel
    
    @State var enemyPokemon: Pokemon?
    
    @State var startBattling = false
    @State private var showingAlert = false
    
    @State var alertSelect: BattleAlert = .onExit
    @State var alertMessage: AlertMessage = AlertMessage(title: "", message: "")
    @State var showingCatchAlert = false
    
    struct AlertMessage {
        var title: String
        var message: String
    }
    
    var body: some View {
        GeometryReader { geometry in
            if startBattling {
                JSWebViewDemoView(onEnded: { catched in
                    print("[BattleStartView] - on finished")
                    let battleResult = userSession.battleObjectDecoder.observableViewModel.data!
                    print(battleResult)
                    
                    let side = (battleResult.battle.availableInfos.commands.last)!.side
                    
                    if let userID = userSession.user?.uid {
                        let actualSide = (userID == userSession.battleObjectDecoder.observableViewModel.data?.startUserID)
                        let message = battleResult.battle.summary(win: side == actualSide, pokeBag: pokebag)
                        print(message)
                        
                        alertMessage = AlertMessage(title: "Battle finished", message: message)
                        
                        if side == actualSide {
                            if battleResult.receiveUserID == "computer" {
                                self.showAlert(.onCatch)
                                return
                            }
                        }
                        self.showAlert(.onFinished)
                    }
                })
                    .environmentObject(userSession.battleObjectDecoder)
                ZStack {
                    Color.pokemonRed.ignoresSafeArea()
                    Text("Classic Battle")
                        .font(.headline)
                        .foregroundColor(.white)
                    HStack() {
                        Button(action: {
                            showingAlert = true
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
                        if let receiveUserID = userSession.battleObjectDecoder.observableViewModel.data?.receiveUserID {
                            if receiveUserID == "computer" {
                                let enemyPokemon = (userSession.battleObjectDecoder.observableViewModel.data)!.battle.enemyPokemon
                                userSession.battleObjectDecoder.observableViewModel.updateEnemyPokemon(pokemon: enemyPokemon.info.randomlyGenerate(level: pokemon.level), computer: true)
                            }
                        }
                        
                        onStart(pokemon: pokemon)
                    })
                    .environmentObject(pokebag)
                }
            }
        }
        .transition(.move(edge: .trailing))
        .animation(.easeInOut)
        .alert(isPresented:$showingAlert, content: {
            switch(alertSelect) {
            case .onExit:
                return Alert(
                    title: Text("Are you sure you want to exit the battle?"),
                    message: Text("This will end the battle and you will not be able to go back here."),
                    primaryButton: .destructive(Text("Exit")) {
                       onExit()
                    },
                    secondaryButton: .cancel()
                )
            case .onFinished:
                return Alert(
                    title: Text(alertMessage.title),
                    message: Text(alertMessage.message),
                    dismissButton: .default(Text("Okay")) {
                       onExit()
                    }
                )
            case .onCatch:
                return Alert(
                    title: Text("You won the battle"),
                    message: Text("Do you wish to catch it?"),
                    primaryButton: .default(Text("Yes")) {
                        if let data = UserSessionModel.session?.battleObjectDecoder.observableViewModel.data {
                            pokebag.addPokemon(pokemon: data.battle.enemyPokemon)
                            
                            self.showAlert(.onFinished)
                        }
                    },
                    secondaryButton: .cancel(Text("No"), action: {
                        self.showAlert(.onFinished)
                    })
                )
            }
        })
    }
    
    func onStart(pokemon: Pokemon) {
        userSession.battleObjectDecoder.observableViewModel.updatePokemon(pokemon: pokemon)
        startBattling = true
    }
    
    func onExit() {
        userSession.battleObjectDecoder.observableViewModel.deleteUserModel()
        startBattling = false
        userSession.enableBattleSheet = false
    }
    
    func showAlert(_ active: BattleAlert) -> Void {
        self.showingAlert = false
        
        DispatchQueue.main.async {
            self.alertSelect = active
            self.showingAlert = true
        }
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
    let battleStartView = BattleStartView()
        .environmentObject(userSession)
        .environmentObject(pokebag)
    userSession.loginDemo(completion: { result in
        pokebag.updateUser(userID: userSession.user?.uid ?? "")
    })
    return battleStartView
}
