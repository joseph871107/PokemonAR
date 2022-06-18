//
//  CIImage.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/19.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

import UIKit

extension CIImage {
    func toPixelBuffer(context : CIContext, size inSize:CGSize? = nil, gray : Bool = true) -> CVPixelBuffer? {
        let attributes = [
            
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue ] as CFDictionary
        
        var nullablePixelBuffer : CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.extent.size.width), Int(self.extent.size.height), kCVPixelFormatType_32BGRA, attributes, &nullablePixelBuffer)
        
        guard status == kCVReturnSuccess, let pixelBuffer = nullablePixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        context.render(self, to: pixelBuffer, bounds: CGRect(x: 0, y: 0, width: self.extent.size.width, height: self.extent.size.height), colorSpace: gray ? CGColorSpaceCreateDeviceGray() : self.colorSpace)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}
