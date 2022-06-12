//
//  MainAuthView.swift
//  ObjectDetection
//
//  Created by Joseph Ouyang on 2022/6/3.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import SwiftUI

struct MainAuthView: View {
    @StateObject var userSession = UserSessionModel()
    
    var body: some View {
        NavigationView {
            ZStack{
                if userSession.isLogged {
                    MainTabView()
                        .environmentObject(userSession)
                } else {
                    LoginView()
                        .environmentObject(userSession)
                }
            }
            .transition(.slide)
        }
    }
}

struct MainAuthView_Previews: PreviewProvider {
    static var previews: some View {
        getMainAuthView()
    }
}

func getMainAuthView() -> MainAuthView {
    let mainAuthView = MainAuthView()
    mainAuthView.userSession.loginDemo(completion: { result in
        
    })
    return mainAuthView
}
