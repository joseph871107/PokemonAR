//
//  View.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/14.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

import SwiftUI
import Combine

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

struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
    }
}

extension View {
    func circle(width: CGFloat, height: CGFloat) -> some View {
        let mn = min(width, height)
        return self.frame(width: width, height: height)
            .clipped()
            .cornerRadius(mn)
    }
    
    func circleWithBorderNShadow(width: CGFloat, height: CGFloat, borderWidth: CGFloat = 5) -> some View {
        return self.circle(width: width, height: height)
            .overlay(Circle().stroke(.white, lineWidth: borderWidth))
            .shadow(color: Color.black.opacity(0.9), radius: 20)
    }
    
    func turnIntoTextFieldStyle() -> some View {
        self.padding()
            .background(Color.lightGray)
            .cornerRadius(5.0)
    }
    
    func turnIntoButtonStyle(_ backgroundColor: Color = .blue, _ foregroundColor: Color = .white) -> some View {
        self.background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(Capsule())
    }
    
    func keyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive())
    }
}
