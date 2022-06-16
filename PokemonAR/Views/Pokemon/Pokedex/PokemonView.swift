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
        if pokebag.pokemons.count <= index{
            Text("Something wrong")
        } else {
            ZStack {
                Color.pokemonRed
                    .ignoresSafeArea()
                VStack {
                    Image(uiImage: pokemon.info.image)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
    //                SceneView(
    //                    scene: scene,
    //                    pointOfView: cameraNode,
    //                    options: []
    //                )
    //                SceneKitView(objectURL: pokemon.info.modelUrl!)
    //                .onAppear(perform: {
    //                    scene = SceneSetup()
    //                })
                    VStack {
                        Text(pokemon.name)
                            .font(.title3)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .lineLimit(3)
                        VStack{
                            Text("Level : \(pokemon.level)")
                                .foregroundColor(.white)
                            ExperienceView(value: $animatedExperienceValue)
                                .frame(height: 30)
                                .onAppear(perform: {
                                    animatedExperienceValue = pokemon.remainExperiencePercentage
                                })
                        }
                        .padding()
                    }
                }
            }
        }
    }
    
    var pokemon: Pokemon {
        pokebag.pokemons[index]
    }
}

struct PokemonView_Previews: PreviewProvider {
    static var previews: some View {
        getPokemonView()
    }
}

func getPokemonView() -> some View {
    let pokebag = PokeBagViewModel()
    var pokemon = Pokemon(pokedexId: 1)
    pokemon.experience = 175
    pokebag.pokemons.append(pokemon)
    
    let pokemonView = PokemonView(index: .constant(0))
        .environmentObject(pokebag)

    return pokemonView
}


func SceneSetup() -> SCNScene {
    
    // 1
    let scene = SCNScene()

    // 2
    let boxGeometry = SCNBox(width: 10.0, height: 10.0, length: 10.0, chamferRadius: 1.0)
    let boxNode = SCNNode(geometry: boxGeometry)
    scene.rootNode.addChildNode(boxNode)

    // 3
    return scene
}
