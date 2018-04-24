//
//  VoxelSlice.swift
//  AR-IPOD
//
//  Created by Remi Decelle on 19/04/2018.
//  Copyright © 2018 Remi Decelle. All rights reserved.
//

import Foundation
import ARKit
import AVFoundation

struct Volume {
    // Singleton pattern : Only one volume will be create
    static let sharedInstance = Volume()
    
    static let tau_min: Float = 0.4
    
    var size:       Point3D // X size, Y size and Z size
    var resolution: Float   // Number of voxels per meter
    lazy var voxels:     [Int: Voxel]   = self.allocate()
    lazy var centroids:  [Int: Vector]  = self.allocate()
    
    // Prevents others from using default init() for this class
    private init() {
        size        = Point3D(0, 0, 0)
        resolution  = 1.0
    }
    
    func allocate<T>() -> [Int: T] {
        var allocator = [Int: T]()
        allocator.removeAll()
        allocator.reserveCapacity(numberOfVoxels())
        return allocator
    }
    
    mutating func initialize() {
        for i in 0..<Int(size.x) {
            for j in 0..<Int(size.y) {
                for k in 0..<Int(size.z) {
                    let p = Point3D(Float(i), Float(j), Float(k))
                    let n = p.index()
                    voxels[n] = Voxel()
                    centroids[n] = mappingVoxelCentroid(voxel: p, dim: size, step: resolution)
                }
            }
        }
    }
    
    func numberOfVoxels() -> Int {
        return Int(size.x * size.y * size.z)
    }
    
    func truncation(range: Float) -> Float {
        // TO DO
        return 1
    }
    
    mutating func integrateDepthMap(image: DepthImage, camera: Camera) {
        // Get nearest and farthest depth
        let (minimumDepth, maximumDepth, _) = image.getStats()
        // Set near range and far range
        var copyCamera = camera
        copyCamera.zFar = maximumDepth
        copyCamera.zNear = minimumDepth
        // Create camera frustum
        let frustrum = Frustrum()
        frustrum.setUp(camera: copyCamera)
        // Determines intersects between frustrum and volume
        let bbox = computeBoundingBox(frustrum: frustrum)
        let (voxelsIDs, _) = retriveIDs(from: bbox, dim: size, step: resolution)
        // For each voxel/centroid retrieved
        for i in 0..<voxelsIDs.count {
            let id = voxelsIDs[i]
            if let centroid = centroids[id] {
                let positionCamera = camera.extrinsics.columns.3
                let distance = (centroid - Vector(positionCamera.x, positionCamera.y, positionCamera.z)).length()
                let uv      = camera.project(vector: centroid)
                let depth   = image.at(row: Int(uv.x), column: Int(uv.y))
                if depth.isNaN { continue }
                let proj    = camera.unproject(pixel: uv, depth: Float(depth))
                let range   = proj.length()
                let tau     = truncation(range: range)
                if distance >= Volume.tau_min && distance < tau - range {
                    voxels[id]?.carve()
                }
                else if fabs(distance) >= tau + range {
                    voxels[id]?.update(sdfUpdate: uv.x, weightUpdate: 1.0)
                }
            }
        }
    }
}
