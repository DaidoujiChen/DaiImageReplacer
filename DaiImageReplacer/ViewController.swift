//
//  ViewController.swift
//  DaiImageReplacer
//
//  Created by DaidoujiChen on 2015/12/7.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

import Cocoa

enum TableType: String {
    case Source, Target
}

// MARK: GenerateOperationDelegate
extension ViewController: GenerateOperationDelegate {
    
    func onFinish(result: [String: [DaiFileManagerPath]], forKey key: String, duration: NSTimeInterval) {
        self.addLog(key + " cost : " + duration + " seconds")
        switch key {
        case TableType.Source.rawValue:
            self.sourceTable = result
        case TableType.Target.rawValue:
            self.targetTable = result
        default:
            break
        }

        var namesTotalCount = 0
        var pathsTotalCount = 0
        for (name, paths) in result {
            namesTotalCount++
            pathsTotalCount += paths.count
            if paths.count > 1 {
                self.addLog("duplicate " + name + " " + paths.count + " times in " + key)
            }
        }
        self.addLog("total " + key + " name count : " + namesTotalCount)
        self.addLog("total " + key + " path count : " + pathsTotalCount)
    }
    
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
            let newGenerateOperation = GenerateOperation(source: DaiFileManager.custom(safeSelf.pathsFrom(safeURL)), forKey: TableType.Source.rawValue)
            newGenerateOperation.delegate = safeSelf
            safeSelf.generateOperationQueue.addOperation(newGenerateOperation)
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
            let newGenerateOperation = GenerateOperation(source: DaiFileManager.custom(safeSelf.pathsFrom(safeURL)), forKey: TableType.Target.rawValue)
            newGenerateOperation.delegate = safeSelf
            safeSelf.generateOperationQueue.addOperation(newGenerateOperation)
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
    
}

// MARK: ViewController
class ViewController: NSViewController {

    @IBOutlet weak var logsTableView: NSTableView!
    @IBOutlet weak var sourcePathControl: NSPathControl!
    @IBOutlet weak var targetPathControl: NSPathControl!
    
    private var sourceTable = [String: [DaiFileManagerPath]]()
    private var targetTable = [String: [DaiFileManagerPath]]()
    private let generateOperationQueue = NSOperationQueue()
    private var logs = [String]()

}
