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
    @State var pokemon: Pokemon
    
    @State var scene: SCNScene?
    
    var sceneView: SceneView?
    
    var cameraNode: SCNNode? {
        scene?.rootNode.childNode(withName: "camera", recursively: false)
    }
    
    var body: some View {
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
                    Text(pokemon.info.name.english)
                        .font(.title3)
                        .fontWeight(.black)
                        .foregroundColor(.primary)
                        .lineLimit(3)
                    Text("Level : \(pokemon.level)")
                }
            }
        }
    }
}

struct PokemonView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonView(pokemon: Pokemon(pokedexId: 1))
    }
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
