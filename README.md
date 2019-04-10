# PackageMachine
iOS developer tool for package  
v1.2.0  
Use default ExportOptions.plist file if ExportOptions path is null.
Try to use Xcode export ExportOptions.plist file if your package task failed.

# Function Instruction
========  

TaskBoard: task list table.  
Save: save current task. will use taskName as key, the same name task will be overlap.  
Start: start to run package task.  
Share: will download shared ExportOptions.plist from server. (current not must)  

add task: will add a blank template, fill it and click "save".  
delete: remove current task.  

# notice
========  
<img src="https://github.com/gwh111/testcocoappswift/blob/master/screenshot.png" width="600">  
<img src="https://github.com/gwh111/testcocoappswift/blob/master/screenshot2.png" width="600">  

1. error: Signing for "xxx" requires a development team. Select a development team in the project editor. (in target 'xxx')  
solution: select the right team in project.  

2. error:IDEArchivePathOverride = /Users/../xxx/temp/archive/xxx  
solution: check project path and project name, make sure they are right.   

3. debug release  
blue is selected.

4. use dmg 
open package.dmg to use directly.  

5. ExportOptions.plist path can be empty. so this version share is not necessary.  
