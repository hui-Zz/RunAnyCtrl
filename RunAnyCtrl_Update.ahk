SetWorkingDir,%A_ScriptDir%	;~脚本当前工作目录
updateMsg:=Object()
updateNeed:=Object()
notnewest:=true
RunAnyGithubDir:="https://raw.githubusercontent.com/hui-Zz/RunAnyCtrl/master"
DownList:=["RunAnyCtrl","RunAnyCtrlFunc","rule_common","rule_time"]
URLDownloadToFile,%RunAnyGithubDir%/RunAnyCtrl.ahk ,%A_Temp%\temp_RunAnyCtrl.ahk
;[从RunAnyCtrl中取出需要更新的插件列表]
PluginsReg=iS)^\t*\s*global PluginsList:="(.*)"
Loop, read, %A_Temp%\temp_RunAnyCtrl.ahk
{
	if(RegExMatch(A_LoopReadLine,PluginsReg)){
		PluginsRegStr:=RegExReplace(A_LoopReadLine,PluginsReg,"$1")
		break
	}
}
PluginsList:=StrSplit(PluginsRegStr,",")
PluginsList.Insert("RunAnyCtrl")
;[下载github上的RunAnyCtrl脚本和读取本地的版本号]
For di, dname in PluginsList
{
	dnameahk:=dname . ".ahk"
	dnamePath:=(dname="RunAnyCtrl") ? "/" dnameahk: "/Lib/" dnameahk
	URLDownloadToFile,%RunAnyGithubDir%%dnamePath% ,%A_Temp%\temp_%dnameahk%
	versionStr:=""
	versionReg=iS)^\t*\s*global %dname%_version:="([\d\.]*)"
	Loop, read, %A_ScriptDir%%dnamePath%
	{
		if(RegExMatch(A_LoopReadLine,versionReg)){
			versionStr:=RegExReplace(A_LoopReadLine,versionReg,"$1")
			break
		}
	}
	updateMsg[dname]:=versionStr ? versionStr : "无版本"
	IfNotExist, %A_ScriptDir%%dnamePath%
	{
		updateNeed[dname]:=true
	}
}
;[比较github上的版本号和本地的版本号]
For di, dname in PluginsList
{
	dnameahk:=dname . ".ahk"
	versionStr:=""
	versionReg=iS)^\t*\s*global %dname%_version:="([\d\.]*)"
	Loop, read, %A_Temp%\temp_%dnameahk%
	{
		if(RegExMatch(A_LoopReadLine,versionReg)){
			versionStr:=RegExReplace(A_LoopReadLine,versionReg,"$1")
			break
		}
		if(A_LoopReadLine="404: Not Found")
			versionStr:="下载失败"
	}
	if(versionStr && versionStr!="下载失败"){
		if(updateMsg[dname]!=versionStr)
			notnewest:=false
		if(updateMsg[dname]<versionStr)
			updateNeed[dname]:=true
	}
	updateMsg[dname].="`t版本更新后=>`t"
	updateMsg[dname].=versionStr ? versionStr : "无"
}
msgResult:=""
For dname, msg in updateMsg
{
	if(updateNeed[dname]){
		msgResult.=dname ".ahk：`n" msg "`n`n"
	}
}
if(notnewest){
	msgResult.="RunAnyCtrl已经是最新版本。"
}else{
	msgResult.="RunAnyCtrl是否更新到最新版本？"
}
MsgBox, 33, RunAnyCtrl更新, %msgResult%
IfMsgBox Ok
{
	IfNotExist,%A_ScriptDir%\Lib
	{
		FileCreateDir, %A_ScriptDir%\Lib
	}
	For dname, update in updateNeed
	{
		if(update){
			dnameahk:=dname . ".ahk"
			dnamePath:=(dname="RunAnyCtrl") ? "/" dnameahk: "/Lib/" dnameahk
			FileCopy, %A_Temp%\temp_%dnameahk%, %A_ScriptDir%%dnamePath%, 1
		}
		FileDelete, %A_Temp%\temp_%dnameahk%
	}
	IfNotExist,%A_ScriptDir%\Lib\RunAnyCtrl.ico
	{
		URLDownloadToFile,%RunAnyGithubDir%/Lib/RunAnyCtrl.ico ,%A_ScriptDir%\Lib\RunAnyCtrl.ico
	}
}