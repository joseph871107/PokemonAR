//
//  ExperienceView.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/13.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import SwiftUI

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

struct ExperienceView_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            VStack{
                ExperienceView(value: .constant(0.75))
            }
            .frame(height: 20)
        }
    }
}
