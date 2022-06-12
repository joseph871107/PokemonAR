//
//  OverlayViewRepresentable.swift
//  ObjectDetection
//
//  Created by Joseph Ouyang on 2022/6/3.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import SwiftUI

struct OverlayViewPresentable: UIViewRepresentable{
    @State var objectOverlays: [ObjectOverlay]
    @State var overlayView = OverlayView()
    
    func makeUIView(context: Context) -> OverlayView {
        self.overlayView.objectOverlays = self.objectOverlays
        self.overlayView.setNeedsDisplay()
        
        return overlayView
    }
    
    func updateUIView(_ uiView: OverlayView, context: Context) {
        self.overlayView.setNeedsDisplay()
    }
    
    typealias UIViewType = OverlayView
}

struct Previews_OverlayViewRepresentable_Previews: PreviewProvider {
    static var previews: some View {
        OverlayViewPresentable(objectOverlays: self.demoObjectOverlay)
    }
    
    static var demoObjectOverlay: [ObjectOverlay] {
        var objectOverlays = [ObjectOverlay]()
        
        let displayFont = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        
        var name = "Dog (60%)"
        objectOverlays.append(
            ObjectOverlay(
                name: name,
                borderRect: CGRect(x: 0, y: 10, width: 100, height: 100),
                nameStringSize: name.size(usingFont: displayFont),
                color: .red,
                font: displayFont
            )
        )
        
        name = "Fish (58%)"
        objectOverlays.append(
            ObjectOverlay(
                name: name,
                borderRect: CGRect(x: 150, y: 100, width: 200, height: 100),
                nameStringSize: name.size(usingFont: displayFont),
                color: .green,
                font: displayFont
            )
        )
        
        return objectOverlays
    }
}
