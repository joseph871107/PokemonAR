//
//  PokemonView.swift
//  ViewCheatsheet
//
//  Created by Joseph Ouyang on 2022/6/12.
//

import SwiftUI
import SceneKit

import ModelIO
import SceneKit.ModelIO

struct PokemonView: View {
    @EnvironmentObject var pokebag: PokeBagViewModel
    @Binding var index: Int
    
    @State var scene: SCNScene?
    @State var animatedExperienceValue = CGFloat(0)
    
    var sceneView: SceneView?
    
    var cameraNode: SCNNode? {
        scene?.rootNode.childNode(withName: "camera", recursively: false)
    }
    
    var body: some View {
        ZStack {
            Color.pokemonRed
                .ignoresSafeArea()
            GeometryReader { geometry in
                VStack {
                    HStack(alignment: .top){
                        VStack {
                            PokemonNameDisplayView(pokemon: pokemon)
                            
                            Divider()
                            
                            VStack {
                                Image(uiImage: pokemon.info.image)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(minWidth: geometry.size.width * 0.2)
                                Text("Pokédex ID : \( pokemon.info.id )")
                                    .font(.caption)
                                    .fontWeight(.black)
                                    .foregroundColor(.white)
                            }
                            
                            Divider()
                            
                            ZStack{
                                ExperienceView(value: $animatedExperienceValue)
                                    .frame(height: 30)
                                    .onAppear(perform: {
                                        animatedExperienceValue = pokemon.remainExperiencePercentage
                                    })
                                Text("Level : \(pokemon.level)")
                                    .fontWeight(.black)
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }
                        
                        Divider()
                        
                        VStack {
                            Text("Evolution")
                                .font(.title3)
                                .fontWeight(.black)
                                .foregroundColor(.white)
                            EvolutionView(pokemon: pokemon.info)
                        }
                        .frame(minWidth: geometry.size.width * 0.5)
                    }
                    .frame(maxHeight: geometry.size.height * 0.5)
                    
                    PokemonStatsView(pokemon: pokemon)
                    .frame(maxHeight: geometry.size.height * 0.15)
                    
                    Divider()
                    
                    VStack {
                        if let url = pokemon.info.modelUrl {
                            SceneKitView(objectURL: url)
                        } else {
                            Text("3D Model currently not available.")
                        }
                    }
                }
            }
            .padding()
        }
        .environmentObject(pokebag)
    }
    
    var pokemon: Pokemon {
        if pokebag.pokemons.count > index {
            return pokebag.pokemons[index]
        } else {
            return Pokemon(pokedexId: 1)
        }
    }
}

struct PokemonView_Previews: PreviewProvider {
    static var previews: some View {
        getPokemonView()
    }
}
struct PokemonNameDisplayView: View {
    @EnvironmentObject var pokebag: PokeBagViewModel
    
    @State var pokemon: Pokemon
    
    @State var editProcessGoing = false
    @State var newName = ""
    
    var body: some View {
        VStack {
            if pokemon.name.isEmpty {
                Text("Pokémon name : \( pokemon.displayName )")
                    .font(.title3)
                    .fontWeight(.black)
                    .foregroundColor(.white)
            }
            HStack {
                ZStack {
                    HStack {
                        if !pokemon.name.isEmpty {
                            Text("Name : ")
                                .font(.title3)
                                .fontWeight(.black)
                                .foregroundColor(.white)
                        }
                        Text(pokemon.name)
                            .font(.title3)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .lineLimit(3)
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(Color.white)
                    }
                        .opacity(editProcessGoing ? 0 : 1)
                    
                    // TextField for edit mode of View
                    HStack {
                        Text("Name : ")
                            .font(.title3)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                        TextField(
                            pokemon.displayName,
                            text: $newName,
                            onEditingChanged: { _ in },
                            onCommit: {
                                pokemon.displayName = newName
                                pokebag.modifyPokemon(pokemon: pokemon)
                                editProcessGoing = false
                            }
                        )
                        .background(Color.white)
                        .foregroundColor(.black)
                    }
                    .opacity(editProcessGoing ? 1 : 0)
                }
                .onTapGesture(perform: { editProcessGoing = true } )
            }
        }
    }
}

struct PokemonStatsView: View {
    @State var pokemon: Pokemon
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Attack : ")
                    Spacer()
                    Text("\( pokemon.info.base.Attack )")
                }
                HStack {
                    Text("Defense : ")
                    Spacer()
                    Text("\( pokemon.info.base.Defense )")
                }
                HStack {
                    Text("HP : ")
                    Spacer()
                    Text("\( pokemon.info.base.HP )")
                }
            }
            
            Divider()
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Speed : ")
                    Spacer()
                    Text("\( pokemon.info.base.Speed )")
                }
                HStack {
                    Text("Special Attack : ")
                    Spacer()
                    Text("\( pokemon.info.base.SpAttack )")
                }
                HStack {
                    Text("Special Defense : ")
                    Spacer()
                    Text("\( pokemon.info.base.SpDefense )")
                }
            }
        }
        .font(.caption)
        .foregroundColor(.white)
        .padding()
        .cornerRadius(10)
        .border(Color.white, width: 2)
    }
}

func getPokemonView() -> some View {
    let pokebag = PokeBagViewModel()
    var pokemon = Pokemon(pokedexId: 133)
    pokemon.experience = 175
    pokebag.pokemons.append(pokemon)
    
    let pokemonView = PokemonView(index: .constant(0))
        .environmentObject(pokebag)

    return pokemonView
}

struct SceneKitView: UIViewRepresentable {
    var objectURL: URL?
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.autoenablesDefaultLighting = true
        
        if let objectURL = objectURL {
            do{
                let scene = try SCNScene(url: objectURL)
                scnView.scene = scene
                
                for node in scene.rootNode.childNodes {
                    let box = node.boundingBox
                    let midX = (box.max.x - box.min.x) / 2
                    let midY = (box.max.y - box.min.y) / 2
                    let midZ = (box.max.z - box.min.z) / 2
                    let middle = SCNVector3(x: midX, y: midY, z: midZ)
                    node.worldPosition = middle
                }
                
                // create and add a camera to the scene
                let cameraNode = SCNNode()
                cameraNode.camera = SCNCamera()
                scene.rootNode.addChildNode(cameraNode)
                
                // place the camera
                cameraNode.position = SCNVector3(x: 0, y: 5, z: 0)
                
                // create and add an ambient light to the scene
                let ambientLightNode = SCNNode()
                ambientLightNode.light = SCNLight()
                ambientLightNode.light!.type = .ambient
                ambientLightNode.light!.color = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
                scene.rootNode.addChildNode(ambientLightNode)
            } catch {
                print(String(describing: error))
            }
        }
        
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        #if DEBUG
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        #endif
        
        // configure the view
        scnView.backgroundColor = UIColor.white
    }
}

struct EvolutionView: View {
    @State var pokemon: Pokedex.PokemonInfo
    
    var body: some View {
        PastBranchView(pokemon: pokemon)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
    }
}

struct PastBranchView: View {
    @State var pokemon: Pokedex.PokemonInfo
    
    var body: some View {
        let evolutionReferences = pokemon.evolution
        let pastBranches = evolutionReferences.pastBranches.filter({ $0.info?.modelUrl != nil }).sorted(by: { $0.index > $1.index })
        
        VStack {
            HStack{
                ForEach(pastBranches.indices, id: \.self) { i in
                    let pastBranch = pastBranches[i]
                    let pokemon = pastBranch.info
                    
                    if i > 0 && i < pastBranches.count {
                        Image(systemName: "arrow.right")
                    }
                    
                    EvolutionImageView(pokemon: pokemon)
                }
            }
            VStack {
                if !pastBranches.isEmpty {
                    Image(systemName: "arrow.down")
                }
                
                EvolutionImageView(pokemon: pokemon)
                    .border(Color.blue, width: 1)
                
                let futureBranches = evolutionReferences.futureBranches
                FutureBranchView(futureBranches: futureBranches)
            }
        }
    }
}

struct FutureBranchView: View {
    @State var futureBranches: [Pokedex.EvolutionReference.FutureBranch]
    
    var body: some View {
        let futureBranches = futureBranches.filter({ $0.info?.modelUrl != nil }).sorted(by: { $0.hier_index > $1.hier_index })
        
        HStack {
            ForEach(futureBranches, id: \.self) { futureBranch in
                let pokemon = Pokedex.get(futureBranch.id)
                
                if let pokemon = pokemon {
                    VStack {
                        Image(systemName: "arrow.down")
                        
                        EvolutionImageView(pokemon: pokemon)
                        FutureBranchView(futureBranches: futureBranch.futureBranches)
                    }
                }
            }
        }
    }
}

struct EvolutionImageView: View {
    @State var pokemon: Pokedex.PokemonInfo?
    
    var body: some View {
        if let pokemon = pokemon {
            Image(uiImage: pokemon.image)
                .renderingMode(.none)
        } else {
            Text("Pokemon not available")
        }
    }
}
