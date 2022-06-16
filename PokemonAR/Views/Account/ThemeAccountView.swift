//
//  ThemeAccountView.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/14.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import SwiftUI

struct ThemeAccountView<ImageContent: View, BottomContent: View, ToolbarItemsContent: ToolbarContent>: View {
    var imgSize: CGFloat
    var imageHolder: () -> ImageContent
    var content: () -> BottomContent
    var toolbarItemsContent: ToolbarItemsContent
    
    init(
        imgSize: CGFloat,
        @ViewBuilder imageHolder: @escaping () -> ImageContent,
        @ViewBuilder content: @escaping () -> BottomContent,
        toolbarItemsContent: ToolbarItemsContent
    ) {
        self.imgSize = imgSize
        self.imageHolder = imageHolder
        self.content = content
        self.toolbarItemsContent = toolbarItemsContent
        
        ToolbarTheme.navigationBarColor(titleColor: .white)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let offsetY = imgSize * 0.2
            NavigationView{
                ZStack {
                    VStack{
                        Color.pokemonRed
                            .ignoresSafeArea()
                            .frame(width: geometry.size.width, height: imgSize / 2 - offsetY, alignment: .leading)
                        VStack(content: content)
                    }
                    GeometryReader { geo in
                        VStack{
                            HStack(alignment: .center) {
                                imageHolder()
                                    .padding(.top, -offsetY)
                            }
                            Spacer()
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                        .toolbar {
                            toolbarItemsContent
                        }
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct ThemeAccountView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            let imgSize = geometry.size.width * 0.5
            
            ThemeAccountView(
                imgSize: imgSize,
                imageHolder: {
                    Image(uiImage: .demo_pikachu)
                        .circleWithBorderNShadow(width: imgSize, height: imgSize)
                },
                content: {
                    ScrollView{
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                            ForEach(1...99, id: \.self) { index in
                                Text("\( index )")
                                    .padding()
                                    .shadow(radius: 10)
                            }
                        }
                    }
                    .overlay(Rectangle().stroke(Color.red.opacity(0.5), lineWidth: 20))
                },
                toolbarItemsContent: MyToolBarContent()
            )
        }
    }
    
    struct MyToolBarContent: ToolbarContent {
        var body: some ToolbarContent {
            ToolbarItem(placement: .principal, content: {
                HStack {
                    Text("Demo")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
            })
        }
    }
}
