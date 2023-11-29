//
//  Core+FileManager.swift
//  HXPHPicker
//
//  Created by Slience on 2022/10/1.
//

import Foundation

extension FileManager: HXPickerCompatible {
    class var documentPath: String {
        NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last ?? ""
    }
    class var cachesPath: String {
        NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last ?? ""
    }
    class var tempPath: String {
        var tmpPath = NSTemporaryDirectory()
        tmpPath.append(contentsOf: "com.silence.HXPHPicker/temp/")
        folderExists(atPath: tmpPath)
        return tmpPath
    }
    static func folderExists(atPath path: String) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            try? fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
    }
    @discardableResult
    static func removeTempCache() -> Bool {
        return removeFile(filePath: tempPath)
    }
    @discardableResult
    static func removeFile(filePath: String) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: filePath) {
                try FileManager.default.removeItem(atPath: filePath)
            }
            return true
        } catch {
            return false
        }
    }
}

public extension HXPickerWrapper where Base: FileManager {
    static var documentPath: String {
        Base.documentPath
    }
    static var cachesPath: String {
        Base.cachesPath
    }
    static var tempPath: String {
        Base.tempPath
    }
}
