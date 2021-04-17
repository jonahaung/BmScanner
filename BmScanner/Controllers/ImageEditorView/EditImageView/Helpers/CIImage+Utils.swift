//
//  CIImage+Utils.swift
//  WeScan
//
//  Created by Julian Schiavo on 14/11/2018.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import CoreImage
import UIKit

extension CIImage {
    /// Applies an AdaptiveThresholding filter to the image, which enhances the image and makes it completely gray scale
    func applyingAdaptiveThreshold() -> CIImage? {
        guard let colorKernel = CIColorKernel(source:
                                                """
            kernel vec4 color(__sample pixel, float inputEdgeO, float inputEdge1)
            {
                float luma = dot(pixel.rgb, vec3(0.2126, 0.7152, 0.0722));
                float threshold = smoothstep(inputEdgeO, inputEdge1, luma);
                return vec4(threshold, threshold, threshold, 1.0);
            }
            """
        ) else { return nil }
        
        let firstInputEdge = 0.1
        let secondInputEdge = 0.4
        
        let arguments: [Any] = [self, firstInputEdge, secondInputEdge]
    
        return colorKernel.apply(extent: self.extent, arguments: arguments)
        
    }
    
    func appalyingNoiseReduce() -> CIImage? {
        guard let noiseReduction = CIFilter(name: "CINoiseReduction") else { return nil}
        noiseReduction.setValue(self, forKey: kCIInputImageKey)
        noiseReduction.setValue(0.02, forKey: "inputNoiseLevel")
        noiseReduction.setValue(0.40, forKey: "inputSharpness")
        
        return noiseReduction.outputImage
    }
    func adjustColors() -> CIImage? {
        let filter = CIFilter(name: "CIColorControls",
                              parameters: [kCIInputImageKey: self,
                                           kCIInputSaturationKey: 0,
                                           kCIInputContrastKey: 1.45])
        return filter?.outputImage
      }
      
      
    
    var cgImage: CGImage? { return CIContext().createCGImage(self, from: self.extent)}
    
    var uiImage: UIImage? {
        if let cgImage = cgImage {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}

extension CGImage {
    
    func grayscaled() -> CGImage? {
      let colorSpace = CGColorSpaceCreateDeviceGray()
      let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
      let cgContext = CGContext(data: nil,
                                width: self.width,
                                height: self.height,
                                bitsPerComponent: 8,
                                bytesPerRow: 0,
                                space: colorSpace,
                                bitmapInfo: bitmapInfo.rawValue)
      cgContext?.draw(self,
                      in: CGRect(x: 0, y: 0, width: self.width, height: self.height))

      return cgContext?.makeImage()
    }
    
    var uiImage: UIImage { return UIImage(cgImage: self)}
}
