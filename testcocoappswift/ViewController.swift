//
//  ViewController.swift
//  testcocoappswift
//
//  Created by gwh on 2019/2/21.
//  Copyright © 2019 gwh. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet var taskName: NSTextField!
    @IBOutlet var projectPath: NSTextField!
    @IBOutlet var projectName: NSTextField!
    @IBOutlet var debugRelease: NSSegmentedControl!
    @IBOutlet var exportOptionsPath: NSTextField!
    @IBOutlet var ipaPath: NSTextField!
    
    @IBOutlet var logTextField: NSTextField!
    
    @IBOutlet var showInfoTextView: NSTextView!
    
    weak var observe : NSObjectProtocol?
    
    var selectIndex:Int!=0
    
    //board
    var board: NSView!

    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var tableView: NSTableView!{
        didSet{
            let nib = NSNib(nibNamed: "CustomCell", bundle: nil)
            self.tableView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CustomCell"))
        }
    }
    var dataSource: [NSDictionary]?
    
    var isLoadingRepo=false// 记录是否正在加载中..
    var outputPipe=Pipe()
    
    @IBAction func sharedDownload(_ sender: Any) {
        let name=projectName.stringValue
        download(name: name)
    }
    
    func download(name: String) {
        //http://bench-ios.oss-cn-shanghai.aliyuncs.com/project/KKTribe_EO.plist
        let urlPath="http://bench-ios.oss-cn-shanghai.aliyuncs.com/project/"+name+"_EO.plist"
        
        let url: NSURL = NSURL(string: urlPath)!
        
        let request: NSURLRequest = NSURLRequest(url: url as URL)
        
        let session: URLSession = URLSession.shared
        
        let dataTask: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if(error == nil){
                
                print(data?.count as Any)
                let desS=response?.description
                if (desS != nil) {
                    if desS!.contains("Status Code: 200") {
                        
                        var eoPath=NSHomeDirectory().appending("/ProjectPackage/eo") as String
                        eoPath=eoPath+"/"+name+"_EO.plist"
                        try!data?.write(to: NSURL.fileURL(withPath: eoPath))
                       
                        DispatchQueue.main.async {
                            self.exportOptionsPath.stringValue=eoPath
                            self.showNotice(str: "exportOptions.plist文件下载成功~",suc: true)
                        }
                    }else {
                        
                        DispatchQueue.main.async {
                            
                            self.showNotice(str: "未找到名为"+name+"的plist文件",suc: false)
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        
                        self.showNotice(str: "网络问题",suc: false)
                    }
                }
                
            }
        }
        dataTask.resume()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let taskPath=NSHomeDirectory().appending("/ProjectPackage/task") as String
        let eoPath=NSHomeDirectory().appending("/ProjectPackage/eo") as String
        
        let fileM=FileManager.default
        let existed:Bool=fileM.fileExists(atPath: taskPath, isDirectory: nil)
        if (existed==false) {
            do {
                try fileM.createDirectory(at: NSURL.fileURL(withPath: taskPath), withIntermediateDirectories: true, attributes: nil)
            }catch{
                
            }
        }
        let existed_eo:Bool=fileM.fileExists(atPath: eoPath, isDirectory: nil)
        if (existed_eo==false) {
            do {
                try fileM.createDirectory(at: NSURL.fileURL(withPath: eoPath), withIntermediateDirectories: true, attributes: nil)
            }catch{
                
            }
        }
//        print(read() as Any)
        
        //save exp
        let returnData = Bundle.main.path(forResource: "ExportOptions", ofType: "plist")
        let data = NSData.init(contentsOfFile: returnData!)
        var str =  NSString(data:data! as Data, encoding: String.Encoding.utf8.rawValue)! as String
        let homeDic=NSHomeDirectory().appending("/ProjectPackage/eo") as String
        let fileName:String=homeDic.appending("/"+"ExportOptions"+".plist")
        data!.write(toFile: fileName, atomically: true)
        
        displayCurrentTable()
        addBoard()
        showBoard(self)
//        recoverAndSet();
        // Do any additional setup after loading the view.
    }
    
    func addBoard(){
        
        board=NSView.init()
        board.frame=self.view.visibleRect
        board.wantsLayer=true
        self.view.addSubview(board)
        
        let colorBoard:NSView=NSView.init()
        colorBoard.frame=board.visibleRect
        colorBoard.wantsLayer=true
        colorBoard.layer?.backgroundColor=NSColor.black.cgColor
        colorBoard.alphaValue=0.5;
        board.addSubview(colorBoard)
        
        let cancelBt:NSButton=NSButton.init()
        cancelBt.frame=board.visibleRect
        cancelBt.alphaValue=0;
        cancelBt.action = #selector(cancelBtTapped(bt:))
        board.addSubview(cancelBt)
        
        let leftBoard:NSView=NSView.init()
        leftBoard.frame=NSRect(x:0,y:0,width:300,height:board.visibleRect.height)
        leftBoard.wantsLayer=true
        leftBoard.layer?.backgroundColor=NSColor.white.cgColor
        board.addSubview(leftBoard)
        
        dataSource = read()
        
        scrollView.frame=NSRect(x:leftBoard.frame.origin.x,y:leftBoard.frame.origin.y+40,width:leftBoard.frame.size.width,height:leftBoard.frame.size.height-40)
//        tableView.delegate=(self as NSTableViewDelegate)
//        tableView.dataSource=(self as NSTableViewDataSource)
        board.addSubview(scrollView)
        
        let addBt:NSButton=NSButton.init()
        addBt.frame=NSRect(x:0,y:0,width:100,height:40)
        let str="add task" as String
        let attrTitle = NSMutableAttributedString.init(string: str)
        let titleRange = NSMakeRange(0, str.count)
        attrTitle.addAttributes([NSAttributedString.Key.foregroundColor: NSColor.black], range: titleRange)
        
        addBt.attributedTitle=attrTitle
        addBt.bezelStyle=NSButton.BezelStyle.regularSquare
        addBt.action = #selector(addBtTapped(bt:))
        board.addSubview(addBt)
        
        tableView.reloadData()
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        saveCurrentTable()
    }
    
    @objc func addBtTapped(bt: NSButton) {
        
        displayNewTable()
        let tempBt=NSButton.init()
        cancelBtTapped(bt: tempBt)
        print("addBtTapped")
        
    }
    
    func read() ->[NSDictionary]? {
        let homeDic=NSHomeDirectory().appending("/ProjectPackage/task") as String
        print(homeDic)
        
        var taskList:[NSDictionary]=[]
        
        let fileM=FileManager.default
        do {
            let cintents1 = try fileM.contentsOfDirectory(atPath: homeDic)
//            print("cintents:\(cintents1.count)\n")
            
            for name in cintents1 {
                let fileName:String=homeDic.appending("/"+name)
                let taskDic=readFileName(fileName: fileName)
                if (taskDic) != nil{
                    taskList.insert(taskDic!, at: 0)
                }
            }
        } catch {
            
        }
        return taskList
    }
    
    func readFileName(fileName:String) ->NSMutableDictionary? {
        let fileM=FileManager.default
        let existed:Bool=fileM.fileExists(atPath: fileName, isDirectory: nil)
        if (existed==true) {
            if fileName.hasSuffix(".plist") {
                let setUpDic:NSMutableDictionary=NSMutableDictionary.init(contentsOf: NSURL.fileURL(withPath: fileName))!
                setUpDic.setObject(fileName, forKey: "fileName" as NSCopying)
                return setUpDic
            }
        }
        return nil
    }
    
    func deleteAtIndex(index:Int){
        let tempDic:NSDictionary=read()![index]
        let fileName=tempDic.object(forKey: "fileName") as! String
        let fileM=FileManager.default
        let existed:Bool=fileM.fileExists(atPath: fileName, isDirectory: nil)
        if (existed==true) {
            try!fileM.removeItem(atPath: fileName)
        }
        print(fileName as Any)
    }
    
    func readFromCurrentTable()->NSDictionary {
        let mutDic:NSMutableDictionary=NSMutableDictionary.init()
        let taskNameS:String=taskName.stringValue
        mutDic.setObject(taskNameS, forKey: "taskName" as NSCopying)
        let projectPathS:String=projectPath.stringValue
        mutDic.setObject(projectPathS, forKey: "projectPath" as NSCopying)
        let projectNameS:String=projectName.stringValue
        mutDic.setObject(projectNameS, forKey: "projectName" as NSCopying)
        let exportOptionsPathS:String=exportOptionsPath.stringValue
        mutDic.setObject(exportOptionsPathS, forKey: "exportOptionsPath" as NSCopying)
        let ipaPathS:String=ipaPath.stringValue
        mutDic.setObject(ipaPathS, forKey: "ipaPath" as NSCopying)
        
        return mutDic
    }
    
    func saveCurrentTable(){
        let saveDic=readFromCurrentTable();
        let taskS=saveDic.object(forKey: "taskName") as! String
        if taskS.count<=0 {
            showNotice(str: "没有写taskName", suc: false)
            return;
        }
        showNotice(str: "创建【"+taskS+"】成功", suc: true)
//        alt(altStr: "创建【"+taskS+"】成功")
        
        let homeDic=NSHomeDirectory().appending("/ProjectPackage/task") as String
        let fileName:String=homeDic.appending("/"+taskS+".plist")
        
        saveDic.write(toFile: fileName, atomically: true)
        
        dataSource = read()
        tableView.reloadData()
    }
    
    func displayNewTable() {
        taskName.stringValue=""
        projectName.stringValue=""
        projectPath.stringValue=""
        exportOptionsPath.stringValue=""
        ipaPath.stringValue=""
    }
    
    func displayCurrentTable() {
        let arr=read()!
        if arr.count<=0 {
            return
        }
        let currentDic=arr[selectIndex]
        taskName.stringValue=currentDic.object(forKey: "taskName") as! String
        projectName.stringValue=currentDic.object(forKey: "projectName") as! String
        projectPath.stringValue=currentDic.object(forKey: "projectPath") as! String
        exportOptionsPath.stringValue=currentDic.object(forKey: "exportOptionsPath") as! String
        ipaPath.stringValue=currentDic.object(forKey: "ipaPath") as! String
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
    @IBAction func courseTapped(_ sender: Any) {
        let returnData = Bundle.main.path(forResource: "README", ofType: "md")
        let data = NSData.init(contentsOfFile: returnData!)
        let str =  NSString(data:data! as Data, encoding: String.Encoding.utf8.rawValue)! as String
        
        self.showInfoTextView.string=str
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
    
    @IBAction func showBoard(_ sender: Any) {
        
        showNotice(str: "", suc: true)
        taskName.abortEditing()
        projectPath.abortEditing()
        projectName.abortEditing()
        exportOptionsPath.abortEditing()
        ipaPath.abortEditing()
        
        board.frame=self.view.visibleRect
        
    }
    
    func alt(altStr:String) {
        let alert:NSAlert=NSAlert.init()
        alert.addButton(withTitle: "确定")
        alert.messageText=altStr
        alert.beginSheetModal(for: self.view.window!) { (result) in
            print(result.rawValue)
            if result.rawValue==1000 {
                print("ok")
            }
        }
    }
    
    @objc func cancelBtTapped(bt: NSButton) {
        let selfR:NSRect=self.view.visibleRect
        board.frame=NSRect(x:-selfR.size.width, y:selfR.origin.y, width:selfR.size.width,height:selfR.size.height)
    }
    
    func showNotice(str:String, suc:Bool) {
        self.logTextField.stringValue=str
        if suc {
            let color: NSColor = NSColor.init(red: 18.0/255.0, green: 189.0/255.0, blue: 0, alpha: 1.0);
            self.logTextField.textColor=color
        }else{
            let color: NSColor = NSColor.init(red: 150.0/255.0, green: 0, blue: 0, alpha: 1.0);
            self.logTextField.textColor=color
        }
    }
    
    @IBAction func start(_ sender: Any) {
        
        guard projectPath.stringValue != "" else {
//            self.logTextField.stringValue="工程目录不能为空";
            showNotice(str: "工程目录不能为空", suc: false)
            return
        }
        guard projectName.stringValue != "" else {
//            self.logTextField.stringValue="工程名不能为空";
            showNotice(str: "工程名不能为空", suc: false)
            return
        }
//        guard exportOptionsPath.stringValue != "" else {
////            self.logTextField.stringValue="exportOptions不能为空 xcode生成ipa文件夹中包含";
//            showNotice(str: "exportOptions不能为空 xcode生成ipa文件夹中包含", suc: false)
//            return
//        }
        guard ipaPath.stringValue != "" else {
//            self.logTextField.stringValue="输出ipa目录不能为空";
            showNotice(str: "输出ipa目录不能为空", suc: false)
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
//            self.logTextField.stringValue="正在执行上一个任务";
            showNotice(str: "正在执行上一个任务", suc: false)
            return
        }// 如果正在执行,则返回
        isLoadingRepo = true   // 设置正在执行标记
        
        var projectStr=self.projectPath.stringValue
        if projectStr.first=="/" {
        }else{
            projectStr="/"+projectStr
        }
        let nameStr=self.projectName.stringValue
        var plistStr:String=self.exportOptionsPath.stringValue
        if plistStr.count<=0 {
            let homeDic=NSHomeDirectory().appending("/ProjectPackage/eo") as String
            plistStr=homeDic.appending("/"+"ExportOptions"+".plist")
        }
        
        var ipaStr=self.ipaPath.stringValue
        if ipaStr.first=="/" {
        }else{
            ipaStr="/"+ipaStr
        }
        
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
        print("result：\(str)");
        
        self.logTextField.stringValue="start running task...";
        
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
                    self.logTextField.stringValue="finish running task...";
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

//MARK: - NSTableViewDataSource
extension ViewController: NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard let dataSource = dataSource else {
            return 0
        }
        return dataSource.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let rowView = tableView.rowView(atRow: row, makeIfNecessary: false)
        rowView?.isEmphasized = false
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CustomCell"), owner: self) as! CustomCell
        let item = dataSource?[row]
        cell.row=row
        if row==selectIndex {
            cell.selected=true;
        }else{
            cell.selected=false;
        }
        cell.setContent(item: item)
        cell.callBackClosureFunction { (name, index) in
            print("name:\(name), index:\(index)")
            
            //从沙盒删除
            self.deleteAtIndex(index: index)
            
            self.dataSource?.remove(at: index)
            self.tableView.reloadData()
        }
        return cell
    }
    
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CustomCell"), owner: self) as! CustomCell
        let item = dataSource?[row]
        cell.setContent(item: item)
        
        if tableView.tableColumns.count>0 {
            let tc = tableView.tableColumns[0]
            let gap: CGFloat = 10 //width outside of label
            cell.titleLabel.preferredMaxLayoutWidth = tc.width - gap
            cell.detailLabel.preferredMaxLayoutWidth = tc.width - gap
        }
        
        return cell.fittingSize.height
    }
    
}

//MARK: - NSTableViewDelegate
extension ViewController: NSTableViewDelegate{
    
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        print("click at row \(row)")
        selectIndex=row
        displayCurrentTable()
        tableView.reloadData()
        return true
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let itemsSelected = tableView.selectedRowIndexes.count
        
        if itemsSelected > 0 {
            let row = tableView.selectedRow
            tableView.deselectRow(row)
        }
    }
    
    
}

