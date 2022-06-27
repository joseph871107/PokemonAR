//
//  ARViewControllerExtPokemon.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/19.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

import UIKit
import ARKit
import SceneKit

extension ARViewController {
    func customInitialization() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func tapped(gesture: UITapGestureRecognizer) {
        // Get exact position where touch happened on screen of iPhone (2D coordinate)
        let touchPosition = gesture.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchPosition)

        if !hitTestResult.isEmpty {
            for result in hitTestResult {
                if let id = self.checkIsPokemonNode(node: result.node) {
                    let pokemon = Pokedex.getInfoFromId(id)
                    
                    onPokemonEnter(pokemon)
                    print(pokemon)
                }
            }
            
//            addGrass(hitTestResult: hitResult)
        }
    }
    
    func addGrass(hitTestResult: ARHitTestResult) {
        let scene = SCNScene(named: "art.scnassets/grass.scn")!
        let grassNode = scene.rootNode.childNode(withName: "grass", recursively: true)
        grassNode?.position = SCNVector3(hitTestResult.worldTransform.columns.3.x,hitTestResult.worldTransform.columns.3.y, hitTestResult.worldTransform.columns.3.z)
        
        self.sceneView.scene.rootNode.addChildNode(grassNode!)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if let _ = sceneView.scene.rootNode.childNode(withName: "Plane", recursively: false) {
            print(true)
        }
        self.process_detection(session, frame: frame)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let grid = self.grids.filter { grid in
            return grid.anchor.identifier == anchor.identifier
        }.first

        guard let foundGrid = grid else {
            return
        }

        foundGrid.update(anchor: anchor as! ARPlaneAnchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor {
            DispatchQueue.main.async {
                let grid = Grid(anchor: anchor)
                self.grids.append(grid)
                node.addChildNode(grid)
            }
        } else {
            if let id = self.checkIsPokemonAnchor(anchor: anchor) {
                self.addPokemonToScene(pokemonID: id, anchor: anchor, node: node)
            }
        }
    }
    
    func checkIsPokemonAnchor(anchor: ARAnchor) -> Int? {
        if let name = anchor.name {
            if name.contains("Pokemon") {
                let start = name.index(name.startIndex, offsetBy: 9)
                if let id = Int(name.substring(with: start..<name.endIndex)) {
                    return id
                }
            }
        }
        
        return nil
    }
    
    func checkIsPokemonNode(node: SCNNode, recursive: Bool = true) -> Int? {
        if let name = node.name {
            print("[checkIsPokemonNode] checking for name : \( name )")
            if name.contains("Pokemon") {
                let start = name.index(name.startIndex, offsetBy: 9)
                if let id = Int(name.substring(with: start..<name.endIndex)) {
                    return id
                }
            } else {
                if recursive {
                    if let parentNode = node.parent {
                        print("[checkIsPokemonNode] continueing searching for \( parentNode )")
                        return checkIsPokemonNode(node: parentNode, recursive: recursive)
                    }
                }
            }
        }
        
        return nil
    }
    
    func addPokemonToScene(pokemonID: Int, anchor: ARAnchor, node: SCNNode) {
        let pokemon = Pokedex.getInfoFromId(pokemonID)
        
        if let url = pokemon.modelUrl {
            do {
                let scene = try SCNScene(url: url)
                let pokemonNode = scene.rootNode
                
                let scale: Float = 0.004
                pokemonNode.scale = SCNVector3(x: scale, y: scale, z: scale)
                
                pokemonNode.name = anchor.name
                node.addChildNode(pokemonNode)
            } catch {
                print(String(describing: error))
            }
        }
    }
    
    func onReceiveResult(_ result: Result, _ capturedSize: CGSize) {
        var filtered_inferences = [Inference]()
        
        for inference in result.inferences.reversed() {
            if inference.confidence > 0.6 {
                filtered_inferences.append(inference)
            }
        }
        self.result = Result(inferenceTime: result.inferenceTime, inferences: filtered_inferences)
        
        let pokemonLookupTable = Pokedex.pokedex.pokemons
        
        let root = sceneView.scene.rootNode
        
        for inference in result.inferences {
            self.addAnchorFromInference(inference: inference, capturedSize: capturedSize)
        }
    }
    
    func addAnchorFromInference(inference: Inference, capturedSize: CGSize) {
        let screenRect = sceneView.frame
        let inferenceRect = inference.rect
        
        let newOrigin = CGPoint(
            x: inferenceRect.origin.x / capturedSize.width * screenRect.width,
            y: inferenceRect.origin.y / capturedSize.height * screenRect.height
        )
        let newSize = CGSize(
            width: inferenceRect.width / capturedSize.width * screenRect.width,
            height: inferenceRect.height / capturedSize.height * screenRect.height
        )
        let centerPoint = CGPoint(x: newOrigin.x + newSize.width / 2, y: newOrigin.y + newSize.height / 2)
        
        let raycastQuery: ARRaycastQuery? = sceneView.raycastQuery(
            from: centerPoint,
            allowing: .estimatedPlane,
            alignment: .any
        )

        let results: [ARRaycastResult] = sceneView.session.raycast(raycastQuery!)
        
        for hitTest in results {
            let pokemonId = Pokedex.mapFromInferenceID(inferenceID: inference.index)
            let anchor = ARAnchor(name: "Pokemon: \( pokemonId )", transform: hitTest.worldTransform)
            
            var isIntantiable = true
            
            let anchorPosition = anchor.transform.columns.3
            
            if let camera = sceneView.session.currentFrame?.camera {
                let cameraPosition = camera.transform.columns.3
                let distance = length(anchorPosition - cameraPosition)
                print("Camera Distance : \(distance)")
                
                if distance < 0.5 {
                    isIntantiable = false
                }
            }
            
            if let anchors = sceneView.session.currentFrame?.anchors {
                for otherAnchor in anchors {
                    if let _ = self.checkIsPokemonAnchor(anchor: otherAnchor) {
                        let otherAnchorPosition = otherAnchor.transform.columns.3
                        
                        let distance = length(otherAnchorPosition - anchorPosition)
                        print("Distance : \(distance)")
                        
                        if distance < 1.5 {
                            isIntantiable = false
                        }
                    }
                }
            }
            
            if isIntantiable {
                print(pokemonId)
                sceneView.session.add(anchor: anchor)
            }
        }
    }
}
