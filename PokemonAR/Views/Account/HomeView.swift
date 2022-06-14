//
//  HomeView.swift
//  ObjectDetection
//
//  Created by Joseph Ouyang on 2022/6/9.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userSession: UserSessionModel
    @State var showSettings = false
    
    @State var frame = CGRect()
    
    var body: some View {
        NavigationView{
            GeometryReader { geometry in
                let imgSize = geometry.size.width * 0.5
                ZStack {
                    VStack{
                        Color.pokemonRed
                            .ignoresSafeArea()
                            .frame(width: geometry.size.width, height: imgSize / 2, alignment: .leading)
                        Spacer()
                    }
                    VStack{
                        VStack(alignment: .center) {
                            Image(uiImage: userSession.userImg)
                                .circle(width: imgSize, height: imgSize)
                                .overlay(Circle().stroke(.white, lineWidth: 5))
                                .shadow(color: Color.black.opacity(0.9), radius: 20)
                            
                            Text("Joseph")
                                .font(.largeTitle)
                            Divider()
                            LevelView()
                            Divider()
                        }
                        .padding(.horizontal)
                        Spacer()
                        VStack{
                            Divider()
                            DualTriggerView()
                            NewsTriggerView()
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .principal, content: {
                            HStack {
                                Text("Home")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            }
                        })
                        ToolbarItem(placement: .navigationBarTrailing, content: {
                            Button(action: {
                                userSession.logout()
                            }, label: {
                                Text("Logout")
                                    .foregroundColor(.white)
                            })
                        })
                        ToolbarItem(placement: .navigationBarLeading, content: {
                            Button(action: {
                                showSettings = true
                            }, label: {
                                SettingTriggerView()
                            })
                        })
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
        .sheet(isPresented: $showSettings, content: {
            AccountSettingView()
        })
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        getHomeView()
    }
}

func getHomeView() -> some View {
    let userSession = UserSessionModel()
    let homeView = HomeView()
        .environmentObject(userSession)
    userSession.loginDemo(completion: { result in
        
    })
    return homeView
}

struct LevelView : View {
    @State var animatedValue = CGFloat(0)
    
    var body: some View {
        VStack{
            Text("LV: 10")
                .font(.title)
            ExperienceView(value: $animatedValue)
                .frame(height: 10)
                .padding()
                .onAppear(perform: {
                    withAnimation(.spring(), {
                        animatedValue = CGFloat(0.5)
                    })
                })
        }
    }
}

struct SettingTriggerView : View {
    var body: some View {
        Text("Settings")
            .foregroundColor(.white)
    }
}

struct DualTriggerView : View {
    var height = CGFloat(100)
    
    var body: some View {
        Button(action: {
            
        }, label: {
            Text("Start dual with people")
                .padding(.horizontal, 50.0)
                .padding(.vertical)
                .font(.headline)
                .foregroundColor(.white)
                .background(Color.pokemonRed)
                .cornerRadius(height / 2)
                .frame(height: height)
        })
    }
}

struct NewsTriggerView : View {
    var body: some View {
        Button(action: {
            
        }, label: {
            Text("What's New?")
                .font(.headline)
                .padding()
        })
    }
}
