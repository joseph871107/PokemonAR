//
//  PokemonCardView.swift
//  ViewCheatsheet
//
//  Created by Joseph Ouyang on 2022/6/12.
//

import SwiftUI

struct PokemonCardView: View {
    @State static var cardInstances = [PokemonCardView]()
    
    @EnvironmentObject var pokebag: PokeBagViewModel
    var index: Int
    
    var body: some View {
        ZStack {
            Color.orange
                .ignoresSafeArea()
            Image(uiImage: pokemon.info.image)
                .interpolation(.none)
                .resizable()
//                .scaledToFit()
                .aspectRatio(contentMode: .fit)

            VStack {
                Text(pokemon.name)
                    .font(.caption)
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
        .shadow(radius: 10)
    }
    
    var pokemon: Pokemon {
        pokebag.pokemons[index]
    }
}

struct PokemonCardView_Previews: PreviewProvider {
    static var gridItemLayout = [GridItem(.flexible())]
    
    static var previews: some View {
        ScrollView {
            LazyVGrid(columns: gridItemLayout, spacing: 20) {
                getPokebag()
            }
        }
    }
}

func getPokebag() -> some View {
    let pokebag = PokeBagViewModel()
    pokebag.pokemons.append(Pokemon(pokedexId: 1))
    
    let pokemonCardView = PokemonCardView(index: 0)
        .environmentObject(pokebag)

    return pokemonCardView
}
