//
//  DualHomeView.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/26.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import SwiftUI
import Combine

struct DualHomeView: View {
    @EnvironmentObject var userSession: UserSessionModel
    @EnvironmentObject var pokebag: PokeBagViewModel
    
    @State var roomID: String = ""
    
    @State var sub: AnyCancellable?
    @State var lastBattle: BattleMainModel = BattleMainModel()
    @State var battleEntered: Bool = false
    
    @State var roomStarted: Bool = false
    
    var body: some View {
        if !roomStarted {
            GeometryReader { geometry in
                VStack(alignment: .center) {
                    Button(action: {
                        roomStarted = true
                        userSession.battleObjectDecoder.observableViewModel.startRoom()
                    }, label: {
                        Text("Start a Room")
                            .frame(width: geometry.size.width * 0.5, height: 50)
                            .turnIntoButtonStyle(Color.pokemonRed)
                    })
                    LabelledDivider(label: "or")
                    DualRoomSelectionView()
                }
                .padding()
                .environmentObject(userSession)
                .environmentObject(pokebag)
            }
            .onAppear(perform: {
                self.lastBattle = userSession.battleObjectDecoder.observableViewModel.data ?? lastBattle
                
                self.sub = userSession.battleObjectDecoder.observableViewModel.objectWillChange.sink { _ in
                    if let newBattle = userSession.battleObjectDecoder.observableViewModel.data {
                        print("lastBattle \( lastBattle )")
                        print("newBattle \( newBattle )")
                        
                        if self.battleEntered == false && (
                            lastBattle.startUserID != newBattle.startUserID ||
                            lastBattle.receiveUserID != newBattle.startUserID ||
                            lastBattle.roomID != newBattle.roomID ||
                            lastBattle.createTime != newBattle.createTime
                        ) && (
                            !(newBattle.startUserID ?? "").isEmpty &&
                            !(newBattle.receiveUserID ?? "").isEmpty &&
                            newBattle.createTime != nil
                        ){
                            DispatchQueue.main.async {
                                self.battleEntered = true
                                userSession.enableBattleSheet = true
                            }
                        }
                    }
                }
            })
        } else {
            VStack(alignment: .center) {
                ProgressView()
                Text("Waiting ...")
            }
        }
    }
}

struct DualHomeView_Previews: PreviewProvider {
    static var previews: some View {
        getDualHomeView()
    }
}

func getDualHomeView() -> some View {
    let userSession = UserSessionModel()
    let pokebag = PokeBagViewModel()
    let dualHomeView = DualHomeView()
        .environmentObject(userSession)
        .environmentObject(pokebag)
    userSession.loginDemo(completion: { result in
        pokebag.updateUser(userID: userSession.user?.uid ?? "")
    })
    return dualHomeView
}
