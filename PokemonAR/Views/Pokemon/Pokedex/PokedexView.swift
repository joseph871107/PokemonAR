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
    @State var selectedPokemonIndex: Int = 0
    
    @StateObject var pokebag = PokeBagViewModel()
    
    var gridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
#if DEBUG
                VStack(alignment: .leading) {
                    HStack{
                        Button(action: {
                            print("Pokebag user ID : \(pokebag.userID)")
                            pokebag.addPokemon(pokemon: Pokemon(pokedexId: 1))
                        }, label: {
                            Text("Add one")
                        })
                        Button(action: {
                            print("Pokebag user ID : \(pokebag.userID)")
                            pokebag.addDemo()
                        }, label: {
                            Text("Add demo")
                        })
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
#endif
            
                ZStack{
                    ScrollView {
                        LazyVGrid(columns: gridItemLayout, spacing: 20) {
                            ForEach(pokebag.pokemons) { pokemon in
                                PokemonCardView(index: pokebag.pokemons.firstIndex(of: pokemon)!)
                                    .environmentObject(pokebag)
                                    .shadow(radius: 10)
                                    .onTapGesture {
                                        selectedPokemonIndex = pokebag.pokemons.firstIndex(of: pokemon)!
                                        withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                                            show = true
                                        }
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                            }
                        }
                    }
                    .onLongPressGesture(perform: {
                        pokebag.pokemons.append(Pokemon(pokedexId: 1))
                    })
                    .foregroundColor(.white)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .sheet(isPresented: $show) {
                PokemonView(index: $selectedPokemonIndex)
                    .environmentObject(pokebag)
            }
            .onAppear(perform: {
                pokebag.updateUser(userID: userSession.user?.uid ?? "")
            })
        }
    }
}

struct PokedexView_Previews: PreviewProvider {
    static var previews: some View {
        getPokedexView()
    }
}

func getPokedexView() -> some View {
    let userSession = UserSessionModel()
    let pokedexView = PokedexView()
        .environmentObject(userSession)
    userSession.loginDemo(completion: { result in
        
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
