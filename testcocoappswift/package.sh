#!/bin/bash
#只需要在终端中输入 $ sh cp_20.sh + 配置文件地址. 即可打包成ipa
#配置文件目录结构
#            |-icon
#            |-params.xml

#工程名
project_name='NAME_project'
#工程地址
project_path='PATH_project'
#31个图标启动图等存放位置 里面是app名字的文件夹
resource_path='/Users/danche/Desktop/Rainbown_Main/Rainbow/package/图标'
#ipa生成路径
#在此新建一个空文件夹archive
output_path='PATH_ipa'
#xcarchive临时存放路径
archive_path="$output_path/archive"

#打1个试一下all=0 还是全部all=1
all=1

appName='xx'
appId='xx'


icons=(icon.png)
#launchs=(LaunchImage1.png) //启动图是一样的暂时不需要替换


packaging(){

#***********配置项目
MWConfiguration=Debug
#日期
MWDate=`date +%Y%m%d_%H%M`

#pod 相关配置

#更新pod配置
# pod install

#构建
xcodebuild archive \
-workspace "$project_path$project_name.xcworkspace" \
-scheme "$project_name" \
-configuration "$MWConfiguration" \
-archivePath "$archive_path/$project_name" \
clean \
build \
-derivedDataPath "$MWBuildTempDir"

#生成ipa
xcodebuild -exportArchive -exportOptionsPlist "PATH_plist" -archivePath "$archive_path/$project_name.xcarchive" -exportPath $output_path/$appId

#########这里不需要也可以去掉#########
#移动重命名
#mv /$output_path/$appId/LotteryShop.ipa /$output_path/$appId.ipa
mv /$output_path/$appId/$project_name.ipa /$output_path/$appId.ipa

#删除
rm -r $output_path/$appId/
#########这里不需要也可以去掉#########


}


group(){

appNames=($project_name)

appIds=($project_name)


if [[ $all -eq 0 ]]; then
echo "all=$all"

appNames=($project_name)

appIds=($project_name)

fi

i=0
while [[ i -lt ${#appIds[@]} ]]; do

appName=${appNames[i]}
appId=${appIds[i]}
let i++

echo $appName
#替换资源
# prepare

#打包
packaging

done

open $output_path

}
#---------------------------------------------------------------------------------------------------------------------------------

#打包
group
