//
//  ViewController.swift
//  testcocoappswift
//
//  Created by gwh on 2019/2/21.
//  Copyright © 2019 gwh. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet var projectPath: NSTextField!
    @IBOutlet var projectName: NSTextField!
    @IBOutlet var debugRelease: NSSegmentedControl!
    @IBOutlet var exportOptionsPath: NSTextField!
    @IBOutlet var ipaPath: NSTextField!
    
    @IBOutlet var logTextField: NSTextField!
    
    @IBOutlet var showInfoTextView: NSTextView!
    
    weak var observe : NSObjectProtocol?
    
    var isLoadingRepo=false// 记录是否正在加载中..
    var outputPipe=Pipe()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        recoverAndSet();
        // Do any additional setup after loading the view.
    }
    
    func recoverAndSet() {
        
        let objs:[Any]=[projectPath,projectName,exportOptionsPath,ipaPath]
        let names:[NSString]=["projectPath","projectName","exportOptionsPath","ipaPath"]
        
        for i in 0...3{
            print(i)
            let key=names[i]
            let obj=objs[i] as! NSTextField
            let v=UserDefaults.standard.value(forKey: key as String)
            if (v == nil){
                continue
            }
            obj.stringValue=(v as? String)!
        }
        let ps=UserDefaults.standard.value(forKey: "projectName" as String)
        if (ps==nil){
        }else{
            projectName.stringValue=(ps as? String)!;
        }
        let dr=UserDefaults.standard.value(forKey: "debugRelease")
        if (dr==nil){
        }else{
            debugRelease.selectedSegment=dr as! Int;
        }
        
        debugRelease.action = #selector(segmentControlChanged(segmentControl:))
    }
    
    @objc func segmentControlChanged(segmentControl: NSSegmentedControl) {
        print(segmentControl.selectedSegment)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func selectProjPath(_ sender: NSButton) {
        
        self.selectPath(sender);
    }
    
    @IBAction func selectPath(_ sender: NSButton) {
        let tag=sender.tag
        print(tag)
        
        // 1. 创建打开文档面板对象
        let openPanel = NSOpenPanel()
        // 2. 设置确认按钮文字
        openPanel.prompt = "Select"
        // 3. 设置禁止选择文件
        openPanel.canChooseFiles = true
        if tag==0||tag==2 {
            openPanel.canChooseFiles = false
        }
        // 4. 设置可以选择目录
        openPanel.canChooseDirectories = true
        if tag==1 {
            openPanel.canChooseDirectories = false
            openPanel.allowedFileTypes=["plist"]
        }
        // 5. 弹出面板框
        openPanel.beginSheetModal(for: self.view.window!) { (result) in
            // 6. 选择确认按钮
            if result == NSApplication.ModalResponse.OK {
                // 7. 获取选择的路径
                let path=openPanel.urls[0].absoluteString.removingPercentEncoding!
                if tag==0 {
                    self.projectPath.stringValue=path
                    let array=path.components(separatedBy:"/")
                    if array.count>1{
                        let name=array[array.count-2]
                        print(array)
                        print(name as Any)
                        self.projectName.stringValue=name
                    }
                }else if tag==1 {
                    self.exportOptionsPath.stringValue=path
                }else{
                    self.ipaPath.stringValue=path
                }
            
                let names:[NSString]=["projectPath","exportOptionsPath","ipaPath"]
                UserDefaults.standard.setValue(openPanel.url?.path, forKey: names[tag] as String)
                UserDefaults.standard.setValue(self.projectName.stringValue, forKey: "projectName")
                UserDefaults.standard.synchronize()
                
//                self.savePath.stringValue = (openPanel.directoryURL?.path)!
//                // 8. 保存用户选择路径(为了可以在其他地方有权限访问这个路径,需要对用户选择的路径进行保存)
//                UserDefaults.standard.setValue(openPanel.url?.path, forKey: kSelectedFilePath)
//                UserDefaults.standard.synchronize()
            }
            // 9. 恢复按钮状态
//            sender.state = NSOffState
        }
    }
    
    @IBAction func start(_ sender: Any) {
        
        guard projectPath.stringValue != "" else {
            self.logTextField.stringValue="工程目录不能为空";
            return
        }
        guard projectName.stringValue != "" else {
            self.logTextField.stringValue="工程名不能为空";
            return
        }
        guard exportOptionsPath.stringValue != "" else {
            self.logTextField.stringValue="exportOptions不能为空 xcode生成ipa文件夹中包含";
            return
        }
        guard ipaPath.stringValue != "" else {
            self.logTextField.stringValue="输出ipa目录不能为空";
            return
        }
        
        
        var str1="abc"
        let str2="abc"
        if str1==str2{
            print("same")
        }
        
        //save
        let objs:[Any]=[projectPath,exportOptionsPath,ipaPath]
        let names:[NSString]=["projectPath","exportOptionsPath","ipaPath"]
        for i in 0...2{
            let obj=objs[i] as! NSTextField
            UserDefaults.standard.setValue(obj.stringValue, forKey: names[i] as String)
        }
        UserDefaults.standard.setValue(self.projectName.stringValue, forKey: "projectName")
        UserDefaults.standard.setValue(self.debugRelease.selectedSegment, forKey: "debugRelease")
        UserDefaults.standard.synchronize()
        
//        self.showInfoTextView.string="abc";
        
        if isLoadingRepo {
            self.logTextField.stringValue="正在执行上一个任务";
            return
        }// 如果正在执行,则返回
        isLoadingRepo = true   // 设置正在执行标记
        
        let projectStr=self.projectPath.stringValue
        let nameStr=self.projectName.stringValue
        let plistStr=self.exportOptionsPath.stringValue
        let ipaStr=self.ipaPath.stringValue
        
        let returnData = Bundle.main.path(forResource: "package", ofType: "sh")
        let data = NSData.init(contentsOfFile: returnData!)
        var str =  NSString(data:data! as Data, encoding: String.Encoding.utf8.rawValue)! as String
        if debugRelease.selectedSegment==0 {
            str = str.replacingOccurrences(of: "DEBUG_RELEASE", with: "debug")
        }else{
            str = str.replacingOccurrences(of: "DEBUG_RELEASE", with: "release")
        }
        str = str.replacingOccurrences(of: "NAME_PROJECT", with: nameStr)
        str = str.replacingOccurrences(of: "PATH_PROJECT", with: projectStr)
        str = str.replacingOccurrences(of: "PATH_PLIST", with: plistStr)
        str = str.replacingOccurrences(of: "PATH_IPA", with: ipaStr)
        str = str.replacingOccurrences(of: "file://", with: "")
        print("返回的数据：\(str)");
        
        self.logTextField.stringValue="执行中。。。";
        
        DispatchQueue.global(qos: .default).async {
            
//            str="aaaabc"
//            str = str.replacingOccurrences(of: "ab", with: "dd")
            
//            print(self.projectPath.stringValue)
//            print(self.exportOptionsPath.stringValue)
//            print(self.ipaPath.stringValue)
            
            
            let task = Process()     // 创建NSTask对象
            // 设置task
            task.launchPath = "/bin/bash"    // 执行路径(这里是需要执行命令的绝对路径)
            // 设置执行的具体命令
            task.arguments = ["-c",str]
            
            task.terminationHandler = { proce in              // 执行结束的闭包(回调)
                self.isLoadingRepo = false    // 恢复执行标记
                
                //5. 在主线程处理UI
                DispatchQueue.main.async(execute: {
                    self.logTextField.stringValue="执行完毕";
                })
            }
            
            self.captureStandardOutputAndRouteToTextView(task)
            task.launch()                // 开启执行
            task.waitUntilExit()       // 阻塞直到执行完毕
            
        }
        
    }
    
}

extension ViewController{
    fileprivate func captureStandardOutputAndRouteToTextView(_ task:Process) {
        //1. 设置标准输出管道
        outputPipe = Pipe()
        task.standardOutput = outputPipe
        
        //2. 在后台线程等待数据和通知
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        //3. 接受到通知消息
        
        observe=NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) { notification in
            
            //4. 获取管道数据 转为字符串
            let output = self.outputPipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            if outputString != ""{
                //5. 在主线程处理UI
                DispatchQueue.main.async {
                    
                    if self.isLoadingRepo == false {
                        let previousOutput = self.showInfoTextView.string
                        let nextOutput = previousOutput + "\n" + outputString
                        self.showInfoTextView.string = nextOutput
                        // 滚动到可视位置
                        let range = NSRange(location:nextOutput.utf8CString.count,length:0)
                        self.showInfoTextView.scrollRangeToVisible(range)
                        
                        if self.observe==nil {
                            return
                        }
                        NotificationCenter.default.removeObserver(self.observe!)
                        
                        return
                    }else{
                        let previousOutput = self.showInfoTextView.string
                        var nextOutput = previousOutput + "\n" + outputString as String
                        if nextOutput.count>5000 {
                            nextOutput=String(nextOutput.suffix(1000));
                        }
                        // 滚动到可视位置
                        let range = NSRange(location:nextOutput.utf8CString.count,length:0)
                        self.showInfoTextView.scrollRangeToVisible(range)
                        self.showInfoTextView.string = nextOutput
                    }
                }
            }
            
            if self.isLoadingRepo == false {
                return
            }
            //6. 继续等待新数据和通知
            self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
    }
    
}

