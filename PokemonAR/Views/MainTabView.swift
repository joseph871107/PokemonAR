//
//  MainTabView.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/13.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userSession: UserSessionModel
    @StateObject var pokebag = PokeBagViewModel()
    
    @State var enableBattleSheet = false
    
    var body: some View {
        ZStack {
            if enableBattleSheet {
                BattleStartView(showSheet: $enableBattleSheet)
            } else {
                TabView(selection: $userSession.tabSelection) {
                    HomeView(enableBattleSheet: $enableBattleSheet)
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                        .tag(1)
                    PokedexHomeView()
                        .tabItem {
                            Label("Pokedex", systemImage: "square.grid.3x3.fill")
                        }
                        .tag(2)
                    ARViewControllerRepresentable(enableBattleSheet: $enableBattleSheet)
                        .environmentObject(userSession)
                        .tabItem {
                            Label("Catch", systemImage: "lasso")
                        }
                        .tag(3)
                }
            }
        }
        .transition(.move(edge: .trailing))
        .animation(.easeInOut)
        .environmentObject(userSession)
        .environmentObject(pokebag)
        .onAppear(perform: {
            if let _ = userSession.user {
                pokebag.updateUser(userID: userSession.user?.uid ?? "")
            }
        })
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        getMainTabView()
    }
}

func getMainTabView() -> some View {
    let userSession = UserSessionModel()
    let mainTabView = MainTabView()
        .environmentObject(userSession)
    userSession.loginDemo(completion: { result in
        
    })
    return mainTabView
}
