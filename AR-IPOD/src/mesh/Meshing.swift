//
//  Meshing.swift
//  AR-IPOD
//
//  Created by Remi Decelle on 26/04/2018.
//  Copyright © 2018 Remi Decelle. All rights reserved.
//

import Foundation
import ARKit

func convertVolumeIntoCells(volume: Volume) -> [Cell] {
    var cells = [Cell]()
    let n = volume.size
    for i in 0..<(n-1) {
        for j in 0..<(n-1) {
            for k in 0..<(n-1) {
                let n2 = n*n
                let i0 = i*n2 + j*n + (k+1)
                let i1 = (i+1)*n2 + j*n + (k+1)
                let i2 = (i+1)*n2 + j*n + k
                let i3 = i*n2 + j*n + k
                let i4 = i*n2 + (j+1)*n + (k+1)
                let i5 = (i+1)*n2 + (j+1)*n + (k+1)
                let i6 = (i+1)*n2 + (j+1)*n + k
                let i7 = i*n2 + (j+1)*n + k
                let points = [volume.centroids[i0], volume.centroids[i1], volume.centroids[i2], volume.centroids[i3],
                              volume.centroids[i4], volume.centroids[i5], volume.centroids[i6], volume.centroids[i7]]
                let values = [volume.voxels[i0].sdf, volume.voxels[i1].sdf, volume.voxels[i2].sdf, volume.voxels[i3].sdf,
                              volume.voxels[i4].sdf, volume.voxels[i5].sdf, volume.voxels[i6].sdf, volume.voxels[i7].sdf]
                let cell = Cell(_points : points, _values: values)
                cells.append(cell)
            }
        }
    }
    return cells
}

func extractMesh(from: [Cell], isolevel: Float) -> [Triangle] {
    var triangles = [Triangle]()
    for cell in from {
        let (i, temp) = polygonise(gridCell: cell, isolevel: isolevel)
        if i == 0 { continue }
        for triangle in temp { triangles.append(triangle) }
    }
    return triangles
}
