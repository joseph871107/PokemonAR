//
//  ARViewControllerRepresentable.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/17.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

import UIKit
import SwiftUI

import ARKit
import RealityKit

struct ARViewControllerRepresentable: UIViewControllerRepresentable {
    @State var viewController: ARViewController?
    
    func makeUIViewController(context: Context) -> ARViewController {
        let viewController = UIStoryboard(name: "ARMain", bundle: nil).instantiateViewController(withIdentifier: "ARViewController") as! ARViewController
        self.viewController = viewController
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = ARViewController
}
