//
//  Camera.swift
//  AR-IPOD
//
//  Created by Remi Decelle on 19/04/2018.
//  Copyright © 2018 Remi Decelle. All rights reserved.
//

import Foundation
import ARKit
import AVFoundation

/**
 * Camera stores all information about camera and
 * mathematics' objects needed to convert 3D point to 2D (or 2D to 3D).
 * It stores all information provided by VIO and tracking feature given by
 * ARFaceTrackingConfiguration.
 * See ARCamera for more information and details, since Camera is an summary of ARCamera.
 */
struct Camera {
    var height:     UInt16  = 0     // Camera height
    var width:      UInt16  = 0     // Camera width
    var zFar:       Float   = 0.0   // Nearest point seen by camera
    var zNear:      Float   = 0.0   // Farther point ssen by camera
    
    let intrinsics: matrix_float3x3 // Matrix K (state-of-the-art). Converts 3D point to 2D
    var extrinsics: matrix_float4x4 // Extrinsics camera : rotation and camera's position
   
    /**
     * Initializes both matrices as identity.
     */
    init() {
        //intrinsics = matrix_float3x3(diagonal: Vector(1,1,1))
        intrinsics =  matrix_float3x3(float3(4, 0, 645),
                                      float3(0, 2.5, 31544),
                                      float3(0, 0, 1))
        extrinsics = matrix_float4x4(diagonal: float4(1,1,1,1))
    }
    
    /**
     * Initilialize camera given K and camera's dimensions
     */
    init(_intrinsics: matrix_float3x3, dim: CGSize) {
        intrinsics  = _intrinsics
        width       = UInt16(dim.width)
        height      = UInt16(dim.height)
        extrinsics  = matrix_float4x4()
    }
    
    /**
     * Updates extrinsics matrix (rotation and camera's position).
     */
    mutating func update(position: matrix_float4x4) {
        extrinsics = position
    }
    
    /**
     * See Geometry.project
     */
    func project(vector: Vector) -> Pixel {
        return AR_IPOD.project(vector: vector, K: intrinsics)
    }
    
    /**
     * See Geometry.unproject
     */
    func unproject(i: Int, j: Int, depth: Float) -> Vector {
        return AR_IPOD.unproject(vector: Vector(Float(i), Float(j), depth), K: intrinsics)
    }
    
    /**
     * See Geometry.unproject
     */
    func unproject(pixel: Pixel, depth: Float) -> Vector {
        return AR_IPOD.unproject(pixel: pixel, depth: depth, K: intrinsics)
    }
}
