# PackageMachine
iOS developer tool for package

# 功能说明
========
展开任务版：可打开任务列表
Save：保存当前任务，会以taskName命名，相同名会覆盖
添加一个task：新建一个空白模板，填完后Save即可
Start：开始执行打包任务
delete：删除对应的模板
共享下载：可共享ExportOptions.plist文件 从共享端拉取

# notice
========
![img](https://github.com/gwh111/testcocoappswift/blob/master/screenshot.png)
1. error: Signing for "xxx" requires a development team. Select a development team in the project editor. (in target 'xxx')
解决：在工程里选择正确的Team

2. error:IDEArchivePathOverride = /Users/../xxx/temp/archive/xxx
解决：检查工程路径和工程名是否正确

3. debug release 蓝色为选中

4. 直接使用
使用package.dmg打开app

5. 因为开源暴露通信key会被攻击，使用共享exportOptions需要我这里统一上传，可自行修改地址
