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
            PokedexView()
                .environmentObject(userSession)
                .tabItem {
                    Label("Pokedex", systemImage: "car")
                }
            ViewControllerRepresentable()
                .environmentObject(userSession)
                .tabItem {
                    Label("Catch", systemImage: "photo")
                }
            LoggedView()
                .environmentObject(userSession)
                .tabItem {
                    Label("Setting", systemImage: "gear")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        getMainTabView()
    }
}

func getMainTabView() -> MainTabView {
    let mainTabView = MainTabView()
    mainTabView.userSession.loginDemo(completion: { result in
        
    })
    return mainTabView
}


struct LoggedView : View {
    @EnvironmentObject var userSession: UserSessionModel
    
    var body: some View {
        VStack{
            VStack{
                Text("UID : \(userSession.user?.uid ?? "")")
                Text("Email : \(userSession.user?.email ?? "")")
                Text("Display Name : \(userSession.user?.displayName ?? "")")
            }
            VStack{
                NavigationLink(
                    "Start detect",
                    destination: ViewControllerRepresentable()
                )
                Button("Logout", action: {
                    userSession.logout(completion: { result in
                        
                    })
                })
            }
            .padding()
            PokedexView()
        }
    }
}
