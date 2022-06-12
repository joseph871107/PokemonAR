//
//  PokemonCardView.swift
//  ViewCheatsheet
//
//  Created by Joseph Ouyang on 2022/6/12.
//

import SwiftUI

struct PokemonCardView: View {
    @State var pokemon: Pokemon
    
    var body: some View {
        ZStack {
            Image(uiImage: pokemon.info.image)
                .interpolation(.none)
                .resizable()
//                .scaledToFit()
                .aspectRatio(contentMode: .fit)
                .background(Color.orange)

            VStack {
                Text(pokemon.info.name.english)
                    .font(.title3)
                    .fontWeight(.black)
                    .foregroundColor(.primary)
                    .lineLimit(3)

                Spacer()
                Text("Level : \(pokemon.level)")
                    .foregroundColor(.primary)
            }
            .padding(10.0)
        }
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.1), lineWidth: 1)
        )
        .padding([.top, .horizontal])
        .shadow(radius: 10)
    }
}

struct PokemonCardView_Previews: PreviewProvider {
    @Namespace static var namespace
    static var gridItemLayout = [GridItem(.flexible())]
    
    static var previews: some View {
        ScrollView {
            LazyVGrid(columns: gridItemLayout, spacing: 20) {
                PokemonCardView(pokemon: Pokemon(pokedexId: 1))
            }
        }
    }
}
