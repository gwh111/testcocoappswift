//
//  CustomCell.swift
//  TableViewTest3
//
//  Created by Su Xiaozhou on 25/04/2017.
//  Copyright © 2017 Su Xiaozhou. All rights reserved.
//

import Cocoa

/**
 *  声明一个闭包别名，闭包含字符串类型的两个参数，无返回值(使用“（）”或者“Void”都一样)
 */
typealias SwiftClosure = (String,Int) -> Void

class CustomCell: NSTableCellView {
    
    /**
     *  定义闭包属性,可选类型
     */
    var callBackClosure : SwiftClosure?
    
    var row:Int = 0
    var selected:Bool = false
    @IBOutlet weak var deleteBt: NSButton!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var detailLabel: NSTextField!
    
    override func awakeFromNib() {
        self.canDrawSubviewsIntoLayer = true
        self.wantsLayer = true
    }
    
    /**
     *  闭包触发调用后，对闭包属性赋值，同时提供调用外部访问闭包中数值的接口
     */
    func callBackClosureFunction(closure:@escaping SwiftClosure){
        callBackClosure = closure
    }
    
    func setContent(item: NSDictionary?){
        
        guard let item = item else {
            return
        }
        
        if selected {
            
            let color: NSColor = NSColor.init(red: 222.0/255.0, green: 222.0/255.0, blue: 222.0/255.0, alpha: 1.0);
            self.layer?.backgroundColor=color.cgColor
        }else{
            self.layer?.backgroundColor=NSColor.clear.cgColor
        }
        
        self.titleLabel.stringValue = item.object(forKey: "taskName") as! String
        self.detailLabel.stringValue = item.object(forKey: "projectPath") as! String
        
//        self.detailLabel.setNeedsDisplay()
//        self.detailLabel.displayIfNeeded()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    @IBAction func deletTapped(_ sender: Any) {
        
        let alert:NSAlert=NSAlert.init()
        alert.addButton(withTitle: "确定")
        alert.addButton(withTitle: "取消")
        alert.messageText="确定删除这个任务吗？"
        alert.beginSheetModal(for: self.window!) { (result) in
            print(result.rawValue)
            if result.rawValue==1000 {
                print("ok")
                
                if self.callBackClosure != nil {
                    self.callBackClosure!("suc",self.row)
                }
            }
        }
    }
    
}
