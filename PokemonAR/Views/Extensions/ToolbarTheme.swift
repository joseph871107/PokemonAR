//
//  ToolbarTheme.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/16.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

import UIKit

class ToolbarTheme {
    static func navigationBarColor(titleColor : UIColor? = nil, tintColor : UIColor? = nil){
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithOpaqueBackground()
        navigationAppearance.backgroundColor = .clear
        navigationAppearance.shadowColor = .clear
        
        navigationAppearance.titleTextAttributes = [.foregroundColor: titleColor ?? .black]
        navigationAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor ?? .black]
       
        UINavigationBar.appearance().standardAppearance = navigationAppearance
        UINavigationBar.appearance().compactAppearance = navigationAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance

        UINavigationBar.appearance().tintColor = tintColor ?? titleColor ?? .black
    }
}
