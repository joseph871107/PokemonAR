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
    
    @State var showSheet = false
    @State var showWebview = false
    
    @State var frame = CGRect()
    
    var body: some View {
        GeometryReader { geometry in
            let imgSize = CGFloat(geometry.size.width * 0.5)
            
            ZStack{
                ThemeAccountView(
                    imgSize: imgSize,
                    imageHolder: {
                        if let _ = userSession.user?.photoURL {
                            AsyncImage(
                                url: $userSession.photoURL,
                                placeholder: {
                                    ZStack{
                                        Circle().fill(Color.white)
                                        ScallingCircles()
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
                                NewsTriggerView(showSheet: $showSheet, showWebview: $showWebview)
                            }
                        }
                        .padding(.top, imgSize * 0.5)
                    },
                    toolbarItemsContent: MyToolBarContent()
                )
            }
        }
        .sheet(isPresented: $showSheet, content: {
            if showWebview {
                WebView(url: URL(string: "https://github.com/joseph871107/PokemonAR"))
            } else {
                AccountSettingView(showSettings: $showSheet)
            }
        })
    }
    
    @ToolbarContentBuilder
    func MyToolBarContent() -> some ToolbarContent {
        ToolbarItem(placement: .principal, content: {
            HStack{
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
                showSheet = true
                showWebview = false
            }, label: {
                Text("Settings")
                    .foregroundColor(.white)
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
    @EnvironmentObject var userSession: UserSessionModel
    
    @State var animatedValue = CGFloat(0)
    
    var body: some View {
        VStack{
            Text("LV: \(userSession.userModel.data.level)")
                .font(.title)
            ExperienceView(value: $animatedValue)
                .frame(height: 10)
                .onAppear(perform: {
                    withAnimation(.spring(), {
                        animatedValue = userSession.userModel.data.remainExperiencePercentage
                    })
                })
        }
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
    @Binding var showSheet: Bool
    @Binding var showWebview: Bool
    
    var body: some View {
        Button(action: {
            showWebview = true
            showSheet = true
        }, label: {
            Text("What's New?")
                .font(.headline)
                .padding()
        })
    }
}
