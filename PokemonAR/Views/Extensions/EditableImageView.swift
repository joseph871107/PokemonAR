//
//  EditableImageView.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/15.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation
import SwiftUI

struct EditableImageView<ImageContent: View> : View {
    @State var size: CGFloat
    
    @Binding var selected_image: UIImage
    @State var showSheet = false
    
    @State var imageContent: () -> ImageContent
    
    init(size: CGFloat, selected_image: Binding<UIImage>, @ViewBuilder imageContent: @escaping () -> ImageContent) {
        self.size = size
        self._selected_image = selected_image
        self.imageContent = imageContent
    }
    
    var width: CGFloat {
        self.size
    }
    var height: CGFloat {
        self.size
    }
    
    var body: some View{
        ZStack{
            ZStack(content: imageContent)
            ZStack{
                VStack{
                    Spacer()
                    Text("Edit")
                        .font(.system(size: size * 0.1))
                        .frame(width: width, height: height * 0.2)
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                }
                .frame(width: width, height: height)
            }
            .circle(width: width, height: height)
        }
        .onTapGesture(perform: {
            self.clicked()
        })
        .padding()
        .sheet(isPresented: $showSheet) {
            ImagePicker(selectedImage: $selected_image)
        }
    }
    
    func clicked(callback: () -> Void = {}) {
        showSheet = true
    }
}
