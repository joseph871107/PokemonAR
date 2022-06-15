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
    
    @Binding var selected_image: UIImage?
    @State var showSelection = false
    @State var showSheet = false
    
    @State var sourceType: UIImagePickerController.SourceType = .camera
    
    @State var imageContent: () -> ImageContent
    
    init(size: CGFloat, selected_image: Binding<UIImage?>, @ViewBuilder imageContent: @escaping () -> ImageContent) {
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
        .actionSheet(isPresented: $showSelection) { () -> ActionSheet in
            ActionSheet(title: Text("Select Photo"), buttons: [
                ActionSheet.Button.default(Text("Camera"), action: {
                    sourceType = .camera
                    showSheet = true
                    showSelection = false
                }),
                ActionSheet.Button.default(Text("Photo Library"), action: {
                    sourceType = .photoLibrary
                    showSheet = true
                    showSelection = false
                }),
                ActionSheet.Button.default(Text("Saved Photo Album"), action: {
                    sourceType = .savedPhotosAlbum
                    showSheet = true
                    showSelection = false
                }),
                ActionSheet.Button.cancel(Text("Cancel"))
            ])
        }
        .sheet(isPresented: $showSheet) {
            ImagePicker(selectedImage: $selected_image, sourceType: sourceType)
        }
    }
    
    func clicked(callback: () -> Void = {}) {
        showSelection = true
    }
}
