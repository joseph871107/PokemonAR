//
//  ViewControllerPreview.swift
//  ObjectDetection
//
//  Created by Joseph Ouyang on 2022/6/3.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import SwiftUI

struct ViewControllerPreview: UIViewControllerRepresentable{
    @State var cameraFeedManager = CameraFeedManagerPreview(previewView: PreviewView())
    
    func makeUIViewController(context: Context) -> ViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        
        
        viewController.setCameraFeedManager(cameraFeedManager: self.cameraFeedManager)
        self.cameraFeedManager.triggerOutput()
        
        
        let pview = PreviewViewPreview()
//        pview.uiImageView.frame.origin = viewController.view.frame.origin
        pview.uiImageView.frame.origin.y = -44
        pview.uiImageView.frame.size = viewController.view.frame.size
        pview.uiImageView.image = self.cameraFeedManager.image

        viewController.view.addSubview(pview.uiImageView)
        viewController.view.sendSubviewToBack(pview.uiImageView)
        viewController.view.exchangeSubview(at: 0, withSubviewAt: 1)

        viewController.previewView = pview
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        self.cameraFeedManager.triggerOutput()
    }
    
    typealias UIViewControllerType = ViewController
}

struct Previews_ViewControllerPreview_Previews: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview()
    }
}
