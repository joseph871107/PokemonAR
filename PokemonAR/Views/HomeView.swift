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
    
    var body: some View {
        VStack{
            VStack{
                HStack{
                    Image("demo_cat")
                        .circle(width: 100, height: 100)
                    Text("Joseph")
                        .font(.largeTitle)
                }
                Divider()
                LevelView()
                Divider()
                SettingTriggerView()
                Divider()
            }
            Spacer()
            VStack{
                Divider()
                NewsTriggerView()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct LevelView : View {
    var body: some View {
        VStack{
            Text("LV: 10")
                .font(.title)
            ExperienceView(value: .constant(0.5))
                .frame(height: 10)
                .padding()
        }
    }
}

struct SettingTriggerView : View {
    var body: some View {
        Text("Account Setting")
            .padding()
    }
}

struct ExperienceView : View {
    @Binding var value: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))
                Rectangle()
                    .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color(UIColor.systemGreen))
                    .animation(.linear)
            }
            .cornerRadius(45.0)
        }
    }
}

struct NewsTriggerView : View {
    var body: some View {
        Text("What's NEW")
            .padding()
    }
}

extension Image {
    func circle(width: CGFloat, height: CGFloat) -> some View {
        let mn = min(width, height)
        return self.resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
            .clipped()
            .cornerRadius(mn)
    }
}
