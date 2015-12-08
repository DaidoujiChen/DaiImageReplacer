//
//  ViewController.swift
//  DaiImageReplacer
//
//  Created by DaidoujiChen on 2015/12/7.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

import Cocoa

func +(left: String, right: Int) -> String {
    return String(format: "%@%td", left, right)
}

func +(left: Int, right: String) -> String {
    return String(format: "%td%@", left, right)
}

// MARK: IBAction
extension ViewController {
    
    @IBAction func onClickAction(sender: AnyObject) {
        guard let _ = self.sourcePathControl.URL, _ = self.targetPathControl.URL else {
            print("There Is No Path")
            return
        }

        for (name, sourcePaths) in self.sourceTable {
            if let sourcePath = sourcePaths.first {
                if let targetPaths = self.targetTable[name] {
                    targetPaths.forEach({ (targetPath) -> () in
                        targetPath.delete()
                        sourcePath.copy(targetPath)
                        self.addLog("copy " + sourcePath.path)
                        self.addLog("to " + targetPath.path)
                    })
                }
            }
        }
    }
    
    @IBAction func onSelectSourceAction(sender: AnyObject) {
        self.defaultPathPanel { [weak self] (result, panel) -> Void in
            guard
                let safeSelf = self,
                safeURL = panel.URL
                where result == NSFileHandlingPanelOKButton
                else {
                    print("Source Path Set Fail")
                    return
            }
            
            safeSelf.sourcePathControl.URL = panel.URL
            safeSelf.generateFrom(DaiFileManager.custom(safeSelf.pathsFrom(safeURL)), toTable: &safeSelf.sourceTable)
            
            var namesTotalCount = 0
            var pathsTotalCount = 0
            for (name, paths) in safeSelf.sourceTable {
                namesTotalCount++
                pathsTotalCount += paths.count
                if paths.count > 1 {
                    safeSelf.addLog(name + " have : " + paths.count + " times in source")
                }
            }
            safeSelf.addLog("total source name count : " + namesTotalCount)
            safeSelf.addLog("total source path count : " + pathsTotalCount)
        }
    }
    
    @IBAction func onSelectTargetAction(sender: AnyObject) {
        self.defaultPathPanel { [weak self] (result, panel) -> Void in
            guard
                let safeSelf = self,
                safeURL = panel.URL
                where result == NSFileHandlingPanelOKButton
                else {
                    print("Source Path Set Fail")
                    return
            }
            
            safeSelf.targetPathControl.URL = panel.URL
            safeSelf.generateFrom(DaiFileManager.custom(safeSelf.pathsFrom(safeURL)), toTable: &safeSelf.targetTable)
            
            var namesTotalCount = 0
            var pathsTotalCount = 0
            for (name, paths) in safeSelf.targetTable {
                namesTotalCount++
                pathsTotalCount += paths.count
                if paths.count > 1 {
                    safeSelf.addLog(name + " have : " + paths.count + " times in target")
                }
            }
            safeSelf.addLog("total target name count : " + namesTotalCount)
            safeSelf.addLog("total target path count : " + pathsTotalCount)
        }
    }
    
}

// MARK: NSTableViewDataSource
extension ViewController: NSTableViewDataSource {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.logs.count
    }
    
}

// MARK: NSTableViewDelegate
extension ViewController: NSTableViewDelegate {
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeViewWithIdentifier("NSTableCellView", owner: self) as! NSTableCellView
        cell.textField?.stringValue = self.logs[row]
        return cell
    }
    
}

// MARK: Log Control
extension ViewController {
    
    private func addLog(log: String) {
        self.logs.insert(log, atIndex: 0)
        self.logsTableView.reloadData()
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
    
    // 生成比對表
    private func generateFrom(source: DaiFileManagerPath, inout toTable table: [String: [DaiFileManagerPath]]) {
        for file in source.files.all() {
            if self.isAllow(file) {
                if var paths = table[file] {
                    paths.append(source[file])
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

// MARK: ViewController
class ViewController: NSViewController {

    @IBOutlet weak var logsTableView: NSTableView!
    @IBOutlet weak var sourcePathControl: NSPathControl!
    @IBOutlet weak var targetPathControl: NSPathControl!
    
    var sourceTable = [String: [DaiFileManagerPath]]()
    var targetTable = [String: [DaiFileManagerPath]]()
    var logs = [String]()

}
