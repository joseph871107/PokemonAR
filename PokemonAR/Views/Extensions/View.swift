//
//  View.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/14.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation
import SwiftUI

class PopupViewController : UIViewController {
}

struct ViewAcceptPopupViewController : UIViewControllerRepresentable {
    @State var view = PopupViewController()
    typealias UIViewControllerType = PopupViewController
    
    func makeUIViewController(context: Context) -> PopupViewController {
        view
    }
    
    func updateUIViewController(_ uiViewController: PopupViewController, context: Context) {
        
    }
}
