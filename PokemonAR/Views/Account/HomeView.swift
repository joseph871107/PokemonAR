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
        GeometryReader { geometry in
            let imgSize = CGFloat(geometry.size.width * 0.5)
            
            ThemeAccountView(
                imgSize: imgSize,
                imageHolder: {
                    if let _ = userSession.user?.photoURL {
                        AsyncImage(
                            url: $userSession.photoURL,
                            placeholder: {
                                ZStack{
                                    Circle().fill(Color.white)
                                    LoadingCircle()
                                }
                            },
                            image: {
                                Image(uiImage: $0)
                                    .resizable()
                            }
                        )
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                            .circleWithBorderNShadow(width: imgSize, height: imgSize)
                    } else {
                        Image(uiImage: UIImage.demo_pikachu)
                            .circleWithBorderNShadow(width: imgSize, height: imgSize)
                    }
                },
                content: {
                    VStack {
                        VStack {
                            Text(userSession.userName)
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
                },
                toolbarItemsContent: MyToolBarContent()
            )
        }
        .sheet(isPresented: $showSettings, content: {
            AccountSettingView()
        })
    }
    
    @ToolbarContentBuilder
    func MyToolBarContent() -> some ToolbarContent {
        ToolbarItem(placement: .principal, content: {
            HStack{
                Text("Home")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.top, 50)
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
