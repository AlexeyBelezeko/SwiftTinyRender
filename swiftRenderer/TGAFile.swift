//
//  TGAFile.swift
//  swiftRenderer
//
//  Created by Alexey on 8/5/15.
//  Copyright (c) 2015 SFÇD. All rights reserved.
//

import Foundation

protocol InitiableInteger {
    init()
    init(UInt8)
    init(Int)
    func += (inout Self, Self)
    func << (Self, Self) -> Self
}

extension UInt32: InitiableInteger {}
extension UInt16: InitiableInteger {}

func readBytes<T: InitiableInteger>(buffer: [UInt8], range: NSRange) -> T {
    var tempBuffer = buffer[range.location..<range.location+range.length]
    var value = T()
    for var i = 0; i < tempBuffer.count; i++ {
        value += T(tempBuffer[i]) << T(i * 8)
    }
    return value
}

func writeBytes<T>(var value: T, inout buffer: [UInt8], shift: Int){
    let data = NSData(bytes: &value, length: sizeof(T))
    var tempBuffer = [UInt8](count: sizeof(T), repeatedValue: 0)
    data.getBytes(&tempBuffer, length: tempBuffer.count)
    for var index=0; index<sizeof(T); index++ {
        buffer[index+shift] = tempBuffer[index]
    }
}

struct TGAColor {
    static func white() -> TGAColor {
        return TGAColor(r: 255, g: 255, b: 255, a: 255)
    }
    static func red() -> TGAColor {
        return TGAColor(r: 255, g: 0, b: 0, a: 255)
    }
    static func green() -> TGAColor {
        return TGAColor(r: 0, g: 255, b: 0, a: 255)
    }
    static func blue() -> TGAColor {
        return TGAColor(r: 0, g: 0, b: 255, a: 255)
    }
    var raw: [UInt8] = [0, 0, 0, 0]
    var bytesPP: UInt8 = 1
    var val: UInt32 {
        get {
            return UnsafePointer<UInt32>(raw).memory
        }
        set (newVal) {
            writeBytes(newVal, &raw, 0)
        }
    }
    var b: UInt8 {
        get {
            return raw[0]
        }
    }
    var g: UInt8 {
        get {
            return raw[1]
        }
    }
    var r: UInt8 {
        get {
            return raw[2]
        }
    }
    var a: UInt8 {
        get {
            return raw[3]
        }
    }
    
    init () {
        var randomColorRaw = [UInt8]()
        for _ in 0 ... 3 {
            randomColorRaw.append(UInt8(arc4random_uniform(255)))
        }
        self.raw = randomColorRaw
        self.bytesPP = 4
    }
    
    init (r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        self.raw = [b, g, r, a]
        self.bytesPP = 4
    }
    
    init (value: UInt32, bytesPP: UInt8) {
        self.bytesPP = bytesPP
        self.val = value
    }
    
    mutating func intensity(val: Double) {
        for i in 0 ... 2 {
            raw[i] = UInt8( Double(raw[i]) * val )
        }
    }
}

struct TGAHeader {
    var raw = [UInt8](count: 18, repeatedValue: 0)
    var idlength: UInt8 {
        get {
            return raw[0]
        }
        set (newValue) {
            raw[0] = newValue
        }
    }
    var colormaptype: UInt8 {
        get {
            return raw[1]
        }
        set (newValue) {
            raw[1] = newValue
        }
    }
    var datatypecode: UInt8 {
        get {
            return raw[2]
        }
        set (newValue) {
            raw[2] = newValue
        }
    }
    var colormaporigin: UInt16 {
        get {
            return readBytes(raw, NSMakeRange(3, 2))
        }
        set (newValue) {
            writeBytes(newValue, &raw, 3)
        }
    }
    var colormaplength: UInt16 {
        get {
            return readBytes(raw, NSMakeRange(5, 2))
        }
        set (newValue) {
            writeBytes(newValue, &raw, 5)
        }
    }
    var colormapdepth: UInt8 {
        get {
            return raw[7]
        }
        set (newValue) {
            raw[7] = newValue
        }
    }
    var x_origin: UInt16 {
        get {
            return readBytes(raw, NSMakeRange(8, 2))
        }
        set (newValue) {
            writeBytes(newValue, &raw, 8)
        }
    }
    var y_origin: UInt16 {
        get {
            return readBytes(raw, NSMakeRange(10, 2))
        }
        set (newValue) {
            writeBytes(newValue, &raw, 10)
        }
    }
    var width: UInt16 {
        get {
            return readBytes(raw, NSMakeRange(12, 2))
        }
        set (newValue) {
            writeBytes(newValue, &raw, 12)
        }
    }
    var height: UInt16 {
        get {
            return readBytes(raw, NSMakeRange(14, 2))
        }
        set (newValue) {
            writeBytes(newValue, &raw, 14)
        }
    }
    var bitsperpixel: UInt8 {
        get {
            return raw[16]
        }
        set (newValue) {
            raw[16] = newValue
        }
    }
    var imagedescriptor: UInt8 {
        get {
            return raw[17]
        }
        set (newValue) {
            raw[17] = newValue
        }
    }
};

class TGAImage {
    
    enum format:UInt8 {
        case grayscale = 1
        case rgb = 3
        case rgba = 4
    }
    
    enum flipOrintation:Int {
        case horizontal = 1
        case vertical = 2
    }
    
    var width: UInt16 = 0
    var height: UInt16 = 0
    var bytesPP: UInt8 = 0
    var data: [UInt8] = []
    
    init() {
        
    }
    
    init(width: UInt16, height: UInt16, bytesPP: format) {
        self.width = width
        self.height = height
        self.bytesPP = bytesPP.rawValue
        self.data = [UInt8](count: Int(width)*Int(height)*Int(self.bytesPP), repeatedValue: 0);
    }
    
    func load(name: String) {
        
    }
    
    func write(name: String, rle: Bool) {
        var dev_area_ref: [UInt8] = [0,0,0,0]
        var ext_area_ref: [UInt8] = [0,0,0,0]
        var footer = [UInt8]("TRUEVISION-XFILE.\0".utf8)
        
        var header = TGAHeader()
        header.width = self.width
        header.height = self.height
        header.bitsperpixel = self.bytesPP<<3
        header.datatypecode = self.bytesPP == format.grayscale.rawValue ? (rle ? 11:3) : (rle ? 10:2);
        header.imagedescriptor = 0x20
        var mutableData = NSMutableData(bytes: &header.raw, length: header.raw.count)
        if rle {
            mutableData = unloadRleData(mutableData)
        } else {
            mutableData.appendBytes(&data, length: data.count)
        }
        mutableData.appendBytes(&dev_area_ref, length: dev_area_ref.count)
        mutableData.appendBytes(&ext_area_ref, length: ext_area_ref.count)
        mutableData.appendBytes(&footer, length: footer.count)
        mutableData.writeToFile(name, atomically: true)
        println("File has writen successfuly!")
    }
    
    func read(name: String) {
        var fileData = NSData(contentsOfFile: name)
        
        var dataShift = 0
        var header = TGAHeader()
        fileData!.getBytes(&header.raw, length: header.raw.count)
        dataShift += header.raw.count
        width = header.width
        height = header.height
        bytesPP = header.bitsperpixel>>3
        var nBytes = Int(width) * Int(height) * Int(bytesPP)
        data = [UInt8](count: nBytes, repeatedValue: 0)
        if (header.datatypecode == 3 || header.datatypecode == 2) {
            fileData?.getBytes(&data, range: NSMakeRange(dataShift, nBytes))
        } else if (header.datatypecode == 10 || header.datatypecode == 11) {
            loadRleData(fileData!, shift: &dataShift)
        } else {
            println("Unknown file firmat!")
        }
        if ((header.imagedescriptor & 0x20) == 0) {
            flip(.vertical)
        }
        if ((header.imagedescriptor & 0x10) == 1) {
            flip(.horizontal)
        }
    }
    
    func unloadRleData(var outputData: NSMutableData) -> NSMutableData {
        let maxChunkLength = 128;
        let pixelCount = Int(width)*Int(height);
        var currentPixel = 0;
        while currentPixel < pixelCount {
            let chunkStart = currentPixel * Int(bytesPP)
            var currentByte = chunkStart
            var chunkLength = 1
            var raw = true
            while currentPixel + chunkLength < pixelCount && chunkLength < maxChunkLength {
                var equal = true;
                for var t = 0; equal && t < Int(bytesPP); t++ {
                    equal = data[currentByte+t] == data[currentByte+t+Int(bytesPP)]
                }
                currentByte += Int(bytesPP)
                if (chunkLength == 1) {
                    raw = !equal
                }
                if (raw && equal) {
                    chunkLength--;
                    break
                }
                if (!raw && !equal) {
                    break;
                }
                chunkLength++;
            }
            currentPixel += chunkLength;
            var val : UInt8 = raw ? UInt8(chunkLength)-1 : UInt8(chunkLength) + 127
            outputData.appendBytes(&val, length: sizeof(UInt8))
            let bufferLength = raw ? chunkLength*Int(bytesPP) : Int(bytesPP)
            var tempBuffer = [UInt8](count: bufferLength, repeatedValue: 0)
            tempBuffer[0..<bufferLength] = data[chunkStart ..< chunkStart+bufferLength]
            outputData.appendBytes(&tempBuffer, length:tempBuffer.count)
        }
        return outputData;
    }
    
    func loadRleData(var fileData: NSData, inout shift: Int) {
        let bytesCount = Int(width)*Int(height)*Int(bytesPP)
        var currentByte = 0
        do {
            var chunkHeader = 0
            fileData.getBytes(&chunkHeader, range: NSMakeRange(shift++, 1))
            if chunkHeader < 128 {
                chunkHeader++
                let bufferSize = chunkHeader * Int(bytesPP)
                var buffer = [UInt8](count: bufferSize, repeatedValue: 0)
                fileData.getBytes(&buffer, range: NSMakeRange(shift, bufferSize))
                data[currentByte ..< currentByte + bufferSize] = buffer[0 ..< buffer.count]
                shift += bufferSize
                currentByte += bufferSize
            } else {
                chunkHeader -= 127
                var colorBuffer = [UInt8](count: Int(bytesPP), repeatedValue: 0)
                fileData.getBytes(&colorBuffer, range: NSMakeRange(shift, Int(bytesPP)))
                shift += Int(bytesPP)
                for i in 0 ..< chunkHeader {
                    data[currentByte ..< currentByte + colorBuffer.count] = colorBuffer[0 ..< colorBuffer.count]
                    currentByte += Int(bytesPP)
                }
            }
        
        } while currentByte < bytesCount
    }
    
    func set(color: TGAColor, x: Int, y: Int) -> Bool {
        if x<0 || y<0 || x>=Int(width) || y>=Int(height)  {
            return false
        } else {
            for var i = 0; i < Int(self.bytesPP); i++ {
                self.data[(x+y*Int(width))*Int(self.bytesPP)+i] = color.raw[i]
            }
            return true
        }
    }
    
    func get(x: Int, y: Int) -> TGAColor? {
        if x<0 || y<0 || x>=Int(width) || y>=Int(height)  {
            return nil
        } else {
            var temp: UInt32 = readBytes(data, NSMakeRange((x+y*Int(width))*Int(bytesPP), Int(bytesPP)))
            return TGAColor(value: temp, bytesPP: bytesPP)
        }
    }
    
    func flip(orientation: flipOrintation) {
        var half = 0
        if orientation == flipOrintation.horizontal {
            half = Int(width>>1)
            for var i = 0; i<half; i++ {
                for var j = 0; j < Int(height); j++ {
                    let color1 = get(i, y: j)
                    let color2 = get(Int(width)-1-i, y: j)
                    set(color2!, x: i, y: j)
                    set(color1!, x: Int(width)-1-i, y: j)
                }
            }
        } else if orientation == flipOrintation.vertical {
            half = Int(height>>1)
            for var i = 0; i<half-1; i++ {
                let row1Start = i*Int(width)*Int(bytesPP)
                let row1End = (i+1)*Int(width)*Int(bytesPP)
                let row2Start = (Int(height)-2-i)*Int(width)*Int(bytesPP)
                let row2End = (Int(height)-1-i)*Int(width)*Int(bytesPP)
                let temp = data[row1Start ..< row1End]
                data[row1Start ..< row1End] = data[row2Start ..< row2End]
                data[row2Start ..< row2End] = temp
            }
        }
    }
}