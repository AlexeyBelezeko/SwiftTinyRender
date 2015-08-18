//
//  main.swift
//  swiftRenderer
//
//  Created by Alexey on 8/5/15.
//  Copyright (c) 2015 SFÇD. All rights reserved.
//

import Foundation

let width = 800
let height = 800
let depth = 255
var lightDirection = Vert<Double>([0, 0, -1])

func arrSwap<T>(inout arr:[T], firstInd: Int, secondInd: Int) {
    var temp = arr[firstInd]
    arr[firstInd] = arr[secondInd]
    arr[secondInd] = temp
}

func line(var x0: Int, var y0: Int, var x1: Int, var y1: Int, inout image: TGAImage, color: TGAColor) {
    var steep = false;
    if (abs(x0-x1)<abs(y0-y1)) {
        swap(&x0, &y0);
        swap(&x1, &y1);
        steep = true;
    }
    if (x0>x1) {
        swap(&x0, &x1);
        swap(&y0, &y1);
    }
    var dx = x1-x0;
    var dy = y1-y0;
    var derror2 = abs(dy)*2;
    var error2 = 0;
    var y = y0;
    for var x=x0; x<=x1; x++ {
        if (steep) {
            image.set(color, x: y, y: x);
        } else {
            image.set(color, x: x, y: y);
        }
        error2 += derror2;
        if (error2 > dx) {
            y += (y1>y0 ? 1 : -1);
            error2 -= dx*2;
        }
    }
}

func triangle(
    var verts: [Vert<Int>],
    inout zBuffer:[Int],
    inout image: TGAImage,
    var textureCoords: [Vert<Double>],
    texture: TGAImage,
    intensity: Double)
{
    if verts[0].y > verts[1].y {
        arrSwap(&verts, 0, 1)
        arrSwap(&textureCoords, 0, 1)
    }
    if verts[0].y > verts[2].y {
        arrSwap(&verts, 0, 2)
        arrSwap(&textureCoords, 0, 2)
    }
    if verts[1].y > verts[2].y {
        arrSwap(&verts, 1, 2)
        arrSwap(&textureCoords, 1, 2)
    }
    var totalHeight = verts[2].y-verts[0].y;
    for var y = verts[0].y; y <= verts[2].y ; y++ {
        let alpha = totalHeight == 0 ? 0 : Double(y - verts[0].y) / Double(totalHeight)
        var A = verts[0] + (verts[2] - verts[0]) * alpha
        var TexA = textureCoords[0] + (textureCoords[2] - textureCoords[0]) * alpha
        var B: Vert<Int>
        var TexB: Vert<Double>
        if (y<verts[1].y) {
            let segmentHeight = verts[1].y - verts[0].y
            let beta = segmentHeight==0 ? 0 : Double(y - verts[0].y) / Double(segmentHeight)
            B = verts[0] + (verts[1] - verts[0]) * beta
            TexB = textureCoords[0] + (textureCoords[1] - textureCoords[0]) * beta
        } else {
            let segmentHeight = verts[2].y - verts[1].y
            let beta = segmentHeight==0 ? 0 : Double(y - verts[1].y) / Double(segmentHeight)
            B = verts[1] + (verts[2] - verts[1]) * beta
            TexB = textureCoords[1] + (textureCoords[2] - textureCoords[1]) * beta
        }
        if (A.x > B.x) {
            swap(&A, &B)
            swap(&TexA, &TexB)
        }
        for var x = A.x; x < B.x; x++ {
            var phi = B.x == A.x ? Double(1) : Double(x-A.x)/Double(B.x-A.x)
            var tempVert = A + (B - A) * phi
            var index = x+y*width
            if zBuffer[index] < tempVert.z {
                zBuffer[index] = tempVert.z
                //Interpolate texture
                var textVert = TexA + (TexB - TexA) * phi
                var v = Int(Double(texture.height) - Double(texture.height) * textVert.y)
                var color = texture.get(Int(Double(texture.width) * textVert.x), y: v)!
                color.intensity(intensity)
                image.set(color, x: x, y: y)
            }
        }
    }
}

func drawHead(inout image: TGAImage) {
    let textureFilePath = "/Users/alexey/Projects/swiftRenderer/swiftRenderer/obj/african_head_diffuse.tga"
    var textureImage = TGAImage()
    textureImage.read(textureFilePath)
    let objFilePath = "/Users/alexey/Projects/swiftRenderer/swiftRenderer/obj/african_head.obj"
    var africanHead = ObjModel(filePath: objFilePath)
    var zBuffer = [Int](count: width*height, repeatedValue: Int.min)
    for var i=0; i<africanHead.faces.count; i++ {
        var face = africanHead.faces[i]
        var screenCoords = [Vert<Int>](count: 3, repeatedValue: Vert<Int>())
        var worldCoords = [Vert<Double>]()
        var textureCoords = [Vert<Double>]()
        for var j = 0; j<3; j++ {
            var v = africanHead.verts[face[j].v]
            screenCoords[j] = Vert([Int((v.x+1)*Double(width)/2), Int((v.y+1)*Double(height)/2), Int((v.z+1)*Double(depth)/2)])
            worldCoords.append(v)
            textureCoords.append(africanHead.vt[face[j].vt])
        }
        var triangleNormal = (worldCoords[2] - worldCoords[0]) ^ (worldCoords[1] - worldCoords[0])
        triangleNormal = normalize(triangleNormal)
        var intensity = triangleNormal * lightDirection
        if intensity > 0 {
            triangle(screenCoords, &zBuffer, &image, textureCoords, textureImage, intensity)
        }
    }
}

var image = TGAImage(width: UInt16(width), height: UInt16(height), bytesPP: .rgb)

drawHead(&image)

image.flip(.vertical)
image.write("output.tga", rle: true)
