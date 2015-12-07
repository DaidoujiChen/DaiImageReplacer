//
//  ViewController.swift
//  DaiImageReplacer
//
//  Created by DaidoujiChen on 2015/12/7.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

import Cocoa

// MARK: IBAction
extension ViewController {
    
    @IBAction func onClickAction(sender: AnyObject) {
        guard let sourcePath = self.sourcePathControl.URL, targetPath = self.targetPathControl.URL else {
            print("There Is No Path")
            return
        }
        
        let source = DaiFileManager.custom(self.pathsFrom(sourcePath))
        let target = DaiFileManager.custom(self.pathsFrom(targetPath))
        self.replace(source, to: target)
    }
    
    @IBAction func onSelectSourceAction(sender: AnyObject) {
        self.defaultPathPanel { [weak self] (result, panel) -> Void in
            guard let safeSelf = self else {
                print("Self Dealloced")
                return
            }
            
            if result == NSFileHandlingPanelOKButton {
                safeSelf.sourcePathControl.URL = panel.URL
            }
        }
    }
    
    @IBAction func onSelectTargetAction(sender: AnyObject) {
        self.defaultPathPanel { [weak self] (result, panel) -> Void in
            guard let safeSelf = self else {
                print("Self Dealloced")
                return
            }
            
            if result == NSFileHandlingPanelOKButton {
                safeSelf.targetPathControl.URL = panel.URL
            }
        }
    }
    
}

// MARK: Private Instance Method
extension ViewController {
    
    // 建立一個資料夾選擇器
    private func defaultPathPanel(handler: (Int, NSOpenPanel) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = false
        panel.resolvesAliases = true
        panel.title = "Set Your Directory"
        panel.prompt = "Set"
        panel.beginWithCompletionHandler { (result) -> Void in
            handler(result, panel)
        }
    }
    
    // 從 NSURL 切細為 String 陣列
    private func pathsFrom(urlPath: NSURL) -> [String] {
        let safePath = urlPath.absoluteString.componentsSeparatedByString("/")
        return self.pathsFrom(safePath)
    }
    
    // 從 String 切細為 String 陣列
    private func pathsFrom(path: String) -> [String] {
        let safePath = path.componentsSeparatedByString("/")
        return self.pathsFrom(safePath)
    }
    
    // 從切細過後的陣列, 過濾出不需要的部份
    private func pathsFrom(originPaths: [String]) -> [String] {
        var paths: [String] = []
        for path in originPaths {
            if path.characters.count != 0 && path != "file:" {
                paths.append(path)
            }
        }
        return paths
    }
    
    // 允許的副檔名
    private func isAllow(named: String) -> Bool {
        let allows = ["png", "jpg", "jpeg"]
        let split = named.componentsSeparatedByString(".")
        return allows.contains(split.last ?? "")
    }
    
    // 替換圖片
    private func replace(source: DaiFileManagerPath, to target: DaiFileManagerPath) {
        for file in source.files.all() {
            if self.isAllow(file) {
                self.found(file, inThe: target, onMatch: { (path) -> Void in
                    print(path)
                    path.delete()
                    source[file].copy(path)
                })
            }
        }
        
        for folder in source.folders.all() {
            self.replace(source[folder], to: target)
        }
    }
    
    // 找看 target 中是不是有該張圖片
    private func found(named: String, inThe target: DaiFileManagerPath, onMatch match: (DaiFileManagerPath) -> Void) {
        for file in target.files.all() {
            if file == named {
                match(target[file])
            }
        }
        
        for folder in target.folders.all() {
            self.found(named, inThe: target[folder], onMatch: match)
        }
    }
    
}

// MARK: ViewController
class ViewController: NSViewController {

    @IBOutlet weak var sourcePathControl: NSPathControl!
    @IBOutlet weak var targetPathControl: NSPathControl!

}
