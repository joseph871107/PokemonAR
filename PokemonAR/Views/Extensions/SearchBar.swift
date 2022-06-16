//
//  SearchBar.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/16.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation
import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @State var isEditing = false
    var color: Color = .black.opacity(0.5)
    var primaryColor: Color = .black
    
    var body: some View {
        HStack {
            ZStack{
                TextField("Search", text: $text, onEditingChanged: { (editingChanged) in
                    isEditing = editingChanged
                })
                    .padding(15)
                    .padding(.horizontal, 25)
                    .background(Color.black.opacity(0.1))
                    .foregroundColor(primaryColor)
                    .cornerRadius(8)
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(color)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 15)
                    
                    if isEditing {
                        Button(action: {
                            self.text = ""
                        }, label: {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(color)
                                .padding(.trailing, 8)
                        })
                    }
                }
            }
            .onTapGesture(perform: {
                self.isEditing = true
            })
            
            if self.isEditing {
                Button(action: {
                    self.isEditing = false
                    
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }, label: {
                    Text("Cancel")
                        .foregroundColor(color)
                })
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
    }
}

struct Previews_SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant(""))
    }
}
