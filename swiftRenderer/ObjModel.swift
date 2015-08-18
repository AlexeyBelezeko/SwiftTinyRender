//
//  ObjModel.swift
//  swiftRenderer
//
//  Created by Alexey on 8/11/15.
//  Copyright (c) 2015 SFÇD. All rights reserved.
//

import Foundation

struct ObjPoint {
    var v = 0
    var vt = 0
    var vn = 0
}

class ObjModel {
    var verts: [Vert<Double>] = []
    var vt: [Vert<Double>] = []
    var faces: [[ObjPoint]] = []
    
    init (filePath: String) {
        var err: NSErrorPointer = NSErrorPointer()
        var str = String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: err)
        
        let lineScaner:NSScanner = NSScanner(string: str!)
        while let line = lineScaner.scanUpToCharactersFromSet(NSCharacterSet.newlineCharacterSet()) {
            let scanner = NSScanner(string: line)
            
            if let instruction = scanner.scanString("v ") {
                var newVert = Vert<Double>()
                newVert.x = scanner.scanDouble()!
                newVert.y = scanner.scanDouble()!
                newVert.z = scanner.scanDouble()!
                verts.append(newVert)
            } else if let instruction = scanner.scanString("f ") {
                var newFaces = [ObjPoint]()
                let whitespaceAndPunctuationSet = NSMutableCharacterSet.whitespaceAndNewlineCharacterSet()
                whitespaceAndPunctuationSet.formUnionWithCharacterSet(NSCharacterSet.punctuationCharacterSet())
                scanner.charactersToBeSkipped = whitespaceAndPunctuationSet
                while let index = scanner.scanInteger() {
                    var newPoint = ObjPoint()
                    newPoint.v = index-1
                    newPoint.vt = scanner.scanInteger()!-1
                    newPoint.vn = scanner.scanInteger()!-1
                    newFaces.append(newPoint)
                }
                faces.append(newFaces)
            } else if let instruction = scanner.scanString("vt ") {
                var newTextCoord = Vert<Double>()
                var i = 0
                while let newVal = scanner.scanDouble() {
                    newTextCoord[i++] = newVal
                }
                vt.append(newTextCoord)
            }
        }
        println("Verts# \(verts.count) Faces# \(faces.count)")
    }
}