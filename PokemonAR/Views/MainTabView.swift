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
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            PokedexView()
                .tabItem {
                    Label("Pokedex", systemImage: "square.grid.3x3.fill")
                }
            JSWebViewDemoView()
                .tabItem {
                    Label("WebView", systemImage: "square.grid.3x3.fill")
                }
            ARViewControllerRepresentable()
                .environmentObject(userSession)
                .tabItem {
                    Label("Catch", systemImage: "lasso")
                }
        }
        .edgesIgnoringSafeArea(.all)
        .environmentObject(userSession)
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
