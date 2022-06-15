//
//  Publisher.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/16.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//
// Eeference : https://www.vadimbulavin.com/how-to-move-swiftui-view-when-keyboard-covers-text-field/

import Foundation

import Combine
import UIKit

extension Publishers {
    // 1.
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        // 2.
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        // 3.
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}
