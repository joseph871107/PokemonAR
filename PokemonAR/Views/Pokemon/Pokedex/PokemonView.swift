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
                VStack {
                    Image(uiImage: pokemon.info.image)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                    VStack {
                        if let url = pokemon.info.modelUrl {
                            SceneKitView(objectURL: url)
                        } else {
                            Text("3D Model currently not available.")
                        }
                    }
                        .padding()
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

func getPokemonView() -> some View {
    let pokebag = PokeBagViewModel()
    var pokemon = Pokemon(pokedexId: 1)
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
                
//                // create and add a light to the scene
//                let lightNode = SCNNode()
//                lightNode.light = SCNLight()
//                lightNode.light!.type = .omni
//                lightNode.position = SCNVector3(x: 0, y: 5, z: 50)
//                scene.rootNode.addChildNode(lightNode)
                
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
        scnView.backgroundColor = UIColor.black
    }
}
