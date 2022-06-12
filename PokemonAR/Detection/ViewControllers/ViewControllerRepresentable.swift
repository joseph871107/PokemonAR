//
//  ViewControllerRepresentable.swift
//  ObjectDetection
//
//  Created by Joseph Ouyang on 2022/6/3.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import SwiftUI

struct ViewControllerRepresentable: UIViewControllerRepresentable{
    @State var cameraFeedManager = CameraFeedManagerPreview(previewView: PreviewView())
    
    func makeUIViewController(context: Context) -> ViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    }
    
    typealias UIViewControllerType = ViewController
}
