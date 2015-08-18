//
//  Vert.swift
//  swiftRenderer
//
//  Created by Alexey on 8/16/15.
//  Copyright (c) 2015 SFÇD. All rights reserved.
//

import Foundation

protocol Countable {
    func + (left: Self, right: Self) -> Self
    func - (left: Self, right: Self) -> Self
    func * (left: Self, right: Self) -> Self
    func / (left: Self, right: Self) -> Self
    func += (inout left: Self, right: Self)
    init ()
    init (Double)
    init (Int)
    init (Self)
}

extension Int : Countable {}
extension Double : Countable {}

struct Vert <T : Countable> {
    var x: T {
        get {
            return val[0]
        }
        set {
            val[0] = newValue
        }
    }
    var y: T {
        get {
            return val[1]
        }
        set {
            val[1] = newValue
        }
    }
    var z: T {
        get {
            return val[2]
        }
        set {
            val[2] = newValue
        }
    }
    var val: [T]
    
    init () {
        val = [T](count: 3, repeatedValue: T(0))
    }
    
    init (_ values: [T]) {
        val = values
    }
    
    subscript(index: Int) -> T {
        get {
            if (index<val.count) {
                return val[index]
            } else {
                return T(0)
            }
        }
        set(newValue) {
            val[index] = newValue
        }
    }
}

func normalize(vert: Vert<Double>) -> Vert<Double> {
    var newVert = Vert<Double>()
    var length = sqrt(vert.x*vert.x+vert.y*vert.y+vert.z*vert.z)
    for i in 0 ... 2 {
        newVert.val[i] = vert.val[i] / length
    }
    return newVert
}

func +<T : Countable> (left: Vert<T>, right: Vert<T>) -> Vert<T> {
    var newVert = Vert<T>()
    for var i=0; i<3; i++ {
        newVert[i] = left[i] + right[i]
    }
    return newVert
}

func -<T : Countable> (left: Vert<T>, right: Vert<T>) -> Vert<T> {
    var newVert = Vert<T>()
    for var i=0; i<3; i++ {
        newVert[i] = left[i] - right[i]
    }
    return newVert
}

func *<T : Countable> (left: Vert<T>, right: Vert<T>) -> T {
    var result = T(0)
    for var i=0; i<3; i++ {
        result += left[i]*right[i]
    }
    return result
}

func ^<T : Countable> (l: Vert<T>, r: Vert<T>) -> Vert<T> {
    var newVert = Vert<T>()
    newVert[0] = l.y * r.z - l.z * r.y
    newVert[1] = l.z * r.x - l.x * r.z
    newVert[2] = l.x * r.y - l.y * r.x
    return newVert
}

func * (left: Vert<Int>, right: Double) -> Vert<Int> {
    var newVert = Vert<Int>()
    for var i=0; i<3; i++ {
        newVert[i] = Int(Double(left[i]) * right)
    }
    return newVert
}

func *<T : Countable> (left: Vert<T>, right: T) -> Vert<T> {
    var newVert = Vert<T>()
    for var i=0; i<3; i++ {
        newVert[i] = left[i] * right
    }
    return newVert
}