//
//  UIImage.swift
//  PokemonAR
//
//  Created by Joseph Ouyang on 2022/6/14.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    static var demo_cat: UIImage {
        return UIImage(named: "demo_cat")!
    }
    
    static var demo_pikachu: UIImage {
        return UIImage(named: "demo_pikachu")!
    }
    
    func resizeImage(targetSize: CGSize) -> UIImage? {
        let image = self
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func centerCropImage(targetSize: CGSize) -> UIImage? {
        // Center crop the image
        let sourceImage = self
        let sourceCGImage = sourceImage.cgImage!
        
        // The shortest side
        let sideLength = min(
            sourceImage.size.width,
            sourceImage.size.height
        )
        
        let sideTargetLength = min(
            sideLength,
            targetSize.width,
            targetSize.height
        )
        let sideScale = sideLength / sideTargetLength

        // Determines the x,y coordinate of a centered
        // sideLength by sideLength square
        let sourceSize = sourceImage.size
        let xOffset = (sourceSize.width - sideLength) / 2.0
        let yOffset = (sourceSize.height - sideLength) / 2.0

        // The cropRect is the rect of the image to keep,
        // in this case centered
        let cropRect = CGRect(
            x: xOffset,
            y: yOffset,
            width: targetSize.width * sideScale,
            height: targetSize.height * sideScale
        ).integral
        
        let croppedCGImage = sourceCGImage.cropping(
            to: cropRect
        )!

        // Use the cropped cgImage to initialize a cropped
        // UIImage with the same image scale and orientation
        let croppedImage = UIImage(
            cgImage: croppedCGImage,
            scale: sourceImage.imageRendererFormat.scale,
            orientation: sourceImage.imageOrientation
        )
        
        return croppedImage.resizeImage(targetSize: targetSize)
    }
    
    var isNull: Bool {
        let image = self
        let size = CGSize(width: 0, height: 0)
        if (image.size.width == size.width)
        {
            return true
        } else {
            return false
        }
    }
}
