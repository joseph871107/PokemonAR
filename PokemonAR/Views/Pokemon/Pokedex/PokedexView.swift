//
//  PokedexView.swift
//  ViewCheatsheet
//
//  Created by Joseph Ouyang on 2022/6/12.
//

import SwiftUI
import Combine

struct PokedexView<TitleView: View>: View {
    @EnvironmentObject var userSession: UserSessionModel
    @EnvironmentObject var pokebag: PokeBagViewModel
    
    @State var titleView: () -> TitleView
    
    @State var onSelectedCallback: (Pokemon) -> Void = { pokemon in
        
    }
    
    @State private var logOutTrigger: AnyCancellable?
    
    @State var gridSize: Double = 100
    @State var gridMin: Double  = 0
    @State var gridMax: Double  = 1000
    @State var filtertext = ""
    @State var selections = Dictionary(uniqueKeysWithValues: PokemonType.allCasesWithoutUnused.map{ ($0, false) })
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                ZStack{
                    Color.pokemonRed.ignoresSafeArea()
                    VStack{
                        HStack(alignment: .center) {
                            titleView()
                        }
                        SearchBar(text: $filtertext, color: .white.opacity(0.5), primaryColor: .white)
                            .padding(.vertical, -10)
                        Slider(value: $gridSize, in: gridMin...gridMax, label: {
                            Text("Change for grid size")
                        }, minimumValueLabel: {
                            Image(systemName: "square.grid.3x3.fill")
                        }, maximumValueLabel: {
                            Image(systemName: "square.grid.2x2.fill")
                        })
                    }
                    .padding(.horizontal)
                }
                .frame(height: geometry.size.height * 0.2, alignment: .top)
                
                GeometryReader { geo_for_pokedex in
                    let gridItemLayout = [
                        GridItem(
                            .adaptive(
                                minimum: gridSize
                            )
                        )
                    ]
                    let spacing: Double = 20
                    ScrollView {
                        LazyVGrid(columns: gridItemLayout, spacing: spacing) {
                            ForEach(pokebag.pokemons.filter({ pokemon in
                                let p_name = pokemon.info.name.english
                                let l_p_name = p_name.lowercased()
                                
                                let name = pokemon.name
                                let l_name = name.lowercased()
                                
                                let text = filtertext
                                let l_text = text.lowercased()
                                
                                let types = selections.filter({ (key, value) in
                                    value
                                }).map{ (key, value) -> Bool in
                                    let value = selections[key]!
                                    if value {
                                        if pokemon.info.type.first(where: { $0.info == key}) != nil {
                                            return value
                                        }
                                    }
                                    return false
                                }
                                
                                return (
                                    (
                                        p_name.contains(text) ||
                                        p_name.contains(l_text) ||
                                        
                                        l_p_name.contains(text) ||
                                        l_p_name.contains(l_text) ||
                                        
                                        name.contains(text) ||
                                        name.contains(l_text) ||
                                        
                                        l_name.contains(text) ||
                                        l_name.contains(l_text) ||
                                        
                                        filtertext.isEmpty
                                    ) && (
                                        !types.contains(false) ||
                                        selections.values.filter({ $0 }).count == 0
                                    )
                                )
                            })) { pokemon in
                                PokemonCardView(index: pokebag.pokemons.firstIndex(of: pokemon)!)
                                    .environmentObject(pokebag)
                                    .shadow(radius: 10)
                                    .onTapGesture {
                                        onSelectedCallback(pokemon)
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                            }
                        }
                        .padding()
                    }
                    .frame(width: geo_for_pokedex.size.width)
                    .onLongPressGesture(perform: {
                        pokebag.pokemons.append(Pokemon(pokedexId: 1))
                    })
                    .foregroundColor(.white)
                    .onAppear(perform: {
                        gridSize = geo_for_pokedex.size.width
                        gridMin = gridSize / 4
                        gridMax = gridSize / 2
                        gridSize = gridMin
                        
                    })
                }
                        
                let bottomSelectionHeight = CGFloat(50)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(PokemonType.allCasesWithoutUnused, id: \.self) { type in
                            PokemonTypeSelectionCard(selections: $selections, size: bottomSelectionHeight, type: type)
                        }
                    }
                }
                .frame(height: bottomSelectionHeight)
            }
            .onAppear(perform: {
                logOutTrigger = userSession.objectWillChange.sink { result in
                    if let _ = userSession.user {
                        
                    } else {
                        pokebag.stopListening()
                    }
                }
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
    let pokebag = PokeBagViewModel()
    let pokedexView = PokedexView(titleView: {
        Text("Pok??dex")
            .font(.largeTitle)
            .foregroundColor(.white)
    })
        .environmentObject(userSession)
        .environmentObject(pokebag)
    userSession.loginDemo(completion: { result in
        pokebag.updateUser(userID: userSession.user?.uid ?? "")
    })
    return pokedexView
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

struct PokemonTypeSelectionCard: View {
    @Binding var selections: Dictionary<PokemonType, Bool>
    
    var size: CGFloat
    var type: PokemonType
    @State var toggle: Bool = false {
        didSet {
            selections[type] = toggle
        }
    }
    
    var body: some View {
        ZStack {
            Image(uiImage: type.instance.image)
                .resizable()
                .scaledToFit()
                .frame(height: size)
            if toggle {
                Circle()
                    .fill(.black.opacity(0.5))
            }
        }
        .cornerRadius(10)
        .onTapGesture {
            toggle.toggle()
        }
    }
}
