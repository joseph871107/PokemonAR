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
    {
        didSet {
            print("[MainAuthView] - userSession changed \(String(describing: userSession))")
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack{
                if userSession.isLogged {
                    MainTabView()
                } else {
                    LoginView()
                }
            }
            .transition(.slide)
            .environmentObject(userSession)
        }
    }
}

struct MainAuthView_Previews: PreviewProvider {
    static var previews: some View {
        getMainAuthView()
    }
}

func getMainAuthView() -> some View {
    let userSession = UserSessionModel()
    let mainAuthView = MainAuthView(userSession: userSession)
    userSession.loginDemo(completion: { result in
        
    })
    return mainAuthView
}
