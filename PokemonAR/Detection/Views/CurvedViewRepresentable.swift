//
//  CurvedViewRepresentable.swift
//  ObjectDetection
//
//  Created by Joseph Ouyang on 2022/6/3.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import SwiftUI

struct CurvedViewRepresentable: UIViewRepresentable{
    func makeUIView(context: Context) -> CurvedView {
        let curvedView = CurvedView()
        
        return curvedView
    }
    
    func updateUIView(_ uiView: CurvedView, context: Context) {

    }
    
    typealias UIViewType = CurvedView
}

struct Previews_CurvedViewRepresentable_Previews: PreviewProvider {
    static var previews: some View {
        CurvedViewRepresentable()
    }
}
