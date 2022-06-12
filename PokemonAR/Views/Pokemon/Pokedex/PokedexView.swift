//
//  PokedexView.swift
//  ViewCheatsheet
//
//  Created by Joseph Ouyang on 2022/6/12.
//

import SwiftUI

struct PokedexView: View {
    @EnvironmentObject var userSession: UserSessionModel
    
    @State var show = false
    @State var selectedPokemon: Pokemon?
    
    var pokeBag: PokeBag? {
        self.userSession.userModel.data?.pokeBag
    }
    
    var gridItemLayout = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack{
            ScrollView {
                LazyVGrid(columns: gridItemLayout, spacing: 20) {
                    ForEach(pokeBag?.pokemons ?? []) { pokemon in
                        PokemonCardView(pokemon: pokemon)
                            .shadow(radius: 10)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                                    selectedPokemon = pokemon
                                    show = true
                                }
                            }
                    }
                }
            }
            .onLongPressGesture(perform: {
                userSession.userModel.data?.pokeBag.pokemons.append(Pokemon(pokedexId: 1))
            })
        }
        .foregroundColor(.white)
        .sheet(isPresented: $show) {
            PokemonView(pokemon: selectedPokemon ?? Pokemon(pokedexId: 1))
        }
    }
}

struct PokedexView_Previews: PreviewProvider {
    static var previews: some View {
        getPokedexView()
    }
}

func getPokedexView() -> PokedexView {
    let pokedexView = PokedexView()
    pokedexView.userSession.loginDemo(completion: { result in
        
    })
    return pokedexView
}


extension Color {
    static var pokemonRed: Color {
        Color.init(red: 231/255, green: 32/255, blue: 32/255)
    }
}

struct PresentablePokedexBase {
    var pokedex_base: Pokedex.Base
    
    struct Presentable {
        var key: String
        var value: Int
        
        var str: String {
            return "\(key): \(value)"
        }
    }
    
    var allCases: [String] {
        return [
            Presentable(key: "HP", value: pokedex_base.HP).str,
            Presentable(key: "Attack", value: pokedex_base.Attack).str,
            Presentable(key: "Defense", value: pokedex_base.Defense).str,
            Presentable(key: "Sp. Attack", value: pokedex_base.SpAttack).str,
            Presentable(key: "Sp. Defense", value: pokedex_base.SpDefense).str,
            Presentable(key: "Speed", value: pokedex_base.Speed).str,
        ]
    }
}
