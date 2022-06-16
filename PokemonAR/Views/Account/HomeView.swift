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
    
    @State var frame = CGRect()
    
    @State var isShowing: Bool = false
    @State var sheetSelect: HomeSheet = .whats_new
    
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
                                NewsTriggerView(showSheet: $isShowing, sheetSelect: $sheetSelect)
                            }
                        }
                        .padding(.top, imgSize * 0.5)
                    },
                    toolbarItemsContent: MyToolBarContent()
                )
            }
        }
        .sheet(isPresented: $isShowing, content: {
            HomeSheetSelectView(isShowing: $isShowing, sheetSelect: $sheetSelect)
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
            })
        })
        ToolbarItem(placement: .navigationBarLeading, content: {
            Button(action: {
                isShowing = true
                sheetSelect = .settins
            }, label: {
                Text("Settings")
            })
        })
    }
}

enum HomeSheet {
    case settins
    case whats_new
}

struct HomeSheetSelectView: View {
    @Binding var isShowing: Bool
    @Binding var sheetSelect: HomeSheet
    
    var body: some View {
        switch sheetSelect {
        case .settins:
            AccountSettingView(showSettings: $isShowing)
        case .whats_new:
            WebView(url: URL(string: "https://github.com/joseph871107/PokemonAR"))
        }
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
    
    var body: some View {
        VStack{
            Text("LV: \(userSession.userModel.level)")
                .font(.title)
            ExperienceView(value: $userSession.userModel.remainExperiencePercentage)
                .frame(height: 10)
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
    @Binding var sheetSelect: HomeSheet
    
    var body: some View {
        Button(action: {
            sheetSelect = .whats_new
            showSheet = true
        }, label: {
            Text("What's New?")
                .font(.headline)
                .padding()
        })
    }
}
