//
//  Image.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/14.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation
import SwiftUI

extension Image {
    func circle(width: CGFloat, height: CGFloat) -> some View {
        let mn = min(width, height)
        return self.resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
            .clipped()
            .cornerRadius(mn)
    }
}
