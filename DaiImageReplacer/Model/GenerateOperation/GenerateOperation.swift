//
//  GenerateOperation.swift
//  DaiImageReplacer
//
//  Created by DaidoujiChen on 2015/12/9.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

import Foundation

extension GenerateOperation {
    
    // 允許的副檔名
    private func isAllow(named: String) -> Bool {
        let allows = ["png", "jpg", "jpeg"]
        let split = named.componentsSeparatedByString(".")
        return allows.contains(split.last ?? "")
    }
    
    // 生成比對表
    private func generateFrom(source: DaiFileManagerPath, inout toTable table: [String: [DaiFileManagerPath]]) {
        for file in source.files.all() {
            if self.isAllow(file) {
                if table[file] != nil {
                    table[file]?.append(source[file])
                }
                else {
                    let newPath = [source[file]]
                    table[file] = newPath
                }
            }
        }
        
        for folder in source.folders.all() {
            self.generateFrom(source[folder], toTable: &table)
        }
    }
    
}

class GenerateOperation: NSOperation {
    
    var source: DaiFileManagerPath?
    var uniqueKey: String?
    var delegate: GenerateOperationDelegate?
    
    init(source: DaiFileManagerPath, forKey key: String) {
        super.init()
        self.source = source
        self.uniqueKey = key
    }
    
    override func main() {
        guard
            let safeSource = self.source,
            safeKey = self.uniqueKey
            else {
                print("data missing")
                return
        }
        let startTime = NSDate()
        
        var table = [String: [DaiFileManagerPath]]()
        self.generateFrom(safeSource, toTable: &table)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.delegate?.onFinish(table, forKey: safeKey, duration: -startTime.timeIntervalSinceNow)
        }
    }
    
}

protocol GenerateOperationDelegate {
    
    func onFinish(result: [String: [DaiFileManagerPath]], forKey key: String, duration: NSTimeInterval)
    
}
