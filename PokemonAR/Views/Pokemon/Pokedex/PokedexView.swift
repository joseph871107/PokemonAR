//
//  PokedexView.swift
//  ViewCheatsheet
//
//  Created by Joseph Ouyang on 2022/6/12.
//

import SwiftUI
import Combine

struct PokedexView: View {
    @EnvironmentObject var userSession: UserSessionModel
    
    @State var show = false
    @State var selectedPokemonIndex: Int = 0
    
    @StateObject var pokebag = PokeBagViewModel()
    @State private var logOutTrigger: AnyCancellable?
    
    @State var filtertext = ""
    @State var selections = Dictionary(uniqueKeysWithValues: PokemonType.allCasesWithoutUnused.map{ ($0, false) })
    
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
                        Button(action: {
                            print("Pokebag user ID : \(pokebag.userID)")
                            pokebag.addDemoWithRandomName()
                        }, label: {
                            Text("Add demo with random name")
                        })
                        Button(action: {
                            print("Pokebag user ID : \(pokebag.userID)")
                            pokebag.removeAll()
                        }, label: {
                            Text("Remove all")
                        })
                    }
                    Spacer()
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .zIndex(1)
#endif
                
                GeometryReader { geo in
                    VStack{
                        ZStack{
                            Color.pokemonRed.ignoresSafeArea()
                            VStack{
                                HStack(alignment: .center) {
                                    Text("Pokédex")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                }
                                SearchBar(text: $filtertext, color: .white.opacity(0.5), primaryColor: .white)
                                    .padding()
                            }
                        }
                        .frame(height: geo.size.height * 0.2)
                        ScrollView {
                            LazyVGrid(columns: gridItemLayout, spacing: 20) {
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
                                            selectedPokemonIndex = pokebag.pokemons.firstIndex(of: pokemon)!
                                            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                                                show = true
                                            }
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                                }
                            }
                            .padding()
                        }
                        .onLongPressGesture(perform: {
                            pokebag.pokemons.append(Pokemon(pokedexId: 1))
                        })
                        .foregroundColor(.white)
                        
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
                }
            }
            .sheet(isPresented: $show) {
                PokemonView(index: $selectedPokemonIndex)
                    .environmentObject(pokebag)
            }
            .onAppear(perform: {
                logOutTrigger = userSession.objectWillChange.sink { result in
                    if let _ = userSession.user {
                        
                    } else {
                        pokebag.stopListening()
                    }
                }
                if let _ = userSession.user {
                    pokebag.updateUser(userID: userSession.user?.uid ?? "")
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
    let pokedexView = PokedexView()
        .environmentObject(userSession)
    userSession.loginDemo(completion: { result in
        
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
