//
//  DualRoomSelectionView.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/26.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import SwiftUI
import Combine

struct DualRoomSelectionView: View {
    @EnvironmentObject var userSession: UserSessionModel
    @EnvironmentObject var pokebag: PokeBagViewModel
    
    @State var rooms: [OpponentInfo] = []
    @State var sub: AnyCancellable?
    
    var body: some View {
        VStack {
            Text("Select Room")
            List {
                ForEach(rooms) { room in
                    Button(action: {
                        userSession.battleObjectDecoder.observableViewModel.enterRoom(roomID: room.id)
                    }, label: {
                        HStack {
                            Text("User ID : \( room.userID )")
                            Text("Room ID : \( room.id )")
                        }
                    })
                }
            }
        }
        .onAppear(perform: {
            self.sub = userSession.battleObjectDecoder.observableViewModel.objectWillChange.sink { _ in
                print("Syncing rooms for : \( userSession.battleObjectDecoder.observableViewModel.availableRooms.count ) rooms")
                self.rooms = userSession.battleObjectDecoder.observableViewModel.availableRooms
            }
            
            userSession.battleObjectDecoder.observableViewModel.listenRoomInfos()
        })
        .onDisappear(perform: {
            userSession.battleObjectDecoder.observableViewModel.stopListeningRoomInfos()
        })
    }
}

struct DualRoomSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        DualRoomSelectionView()
    }
}
