﻿/*
【RunAnyCtrl检查更新Github上的最新版本】
*/
global RunAnyCtrl_update_version:="2.5.4"
SetWorkingDir,%A_ScriptDir%	;~脚本当前工作目录
global RunAnyCtrl:="RunAnyCtrl"
global iniFile:=A_ScriptDir "\" RunAnyCtrl ".ini"
updateMsg:=Object()
updateNeed:=Object()
notnewest:=true
DownList:=["RunAnyCtrl","RunAnyCtrlFunc","JSON","rule_common","rule_time"]
;[下载最新的更新脚本]
lpszUrl:="https://raw.githubusercontent.com"
RunAnyGithubDir:=lpszUrl . "/hui-Zz/RunAnyCtrl/master"
network:=DllCall("Wininet.dll\InternetCheckConnection", "Ptr", &lpszUrl, "UInt", 0x1, "UInt", 0x0, "Int")
if(!network){
	MsgBox,网络异常，无法从https://github.com/hui-Zz/RunAnyCtrl上读取最新版本文件
	return
}
URLDownloadToFile,%RunAnyGithubDir%/RunAnyCtrl_Update.ahk ,%A_Temp%\temp_RunAnyCtrl_Update.ahk
versionReg=iS)^\t*\s*global RunAnyCtrl_update_version:="([\d\.]*)"
Loop, read, %A_Temp%\temp_RunAnyCtrl_Update.ahk
{
	if(RegExMatch(A_LoopReadLine,versionReg)){
		versionStr:=RegExReplace(A_LoopReadLine,versionReg,"$1")
		break
	}
	if(A_LoopReadLine="404: Not Found"){
		MsgBox,"网络异常，下载失败"
		return
	}
}
if(versionStr){
	if(RunAnyCtrl_update_version<versionStr){
		FileCopy, %A_Temp%\temp_RunAnyCtrl_Update.ahk, %A_ScriptDir%\RunAnyCtrl_Update.ahk, 1
		FileDelete, %A_Temp%\temp_RunAnyCtrl_Update.ahk
		Run,%A_ScriptDir%\RunAnyCtrl_Update.ahk
		ExitApp
	}
}
;[从RunAnyCtrl中取出需要更新的插件列表]
URLDownloadToFile,%RunAnyGithubDir%/RunAnyCtrl.ahk ,%A_Temp%\temp_RunAnyCtrl.ahk
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
;[下载github上的规则配置文件]
IfExist,%iniFile%
{
	URLDownloadToFile,%RunAnyGithubDir%/Lib/RunAnyCtrlRule.ini ,%A_ScriptDir%\Lib\RunAnyCtrlRule.ini
	ruleitemList:=Object(),rulefuncList:=Object()
	IniRead,ruleitemVar,%iniFile%,rule_item
	Loop, parse, ruleitemVar, `n, `r
	{
		itemList:=StrSplit(A_LoopField,"=")
		IniRead, OutputVar, %iniFile%, rule_item,% itemList[1]
		ruleitemList[itemList[1]]:=OutputVar
	}
	IniRead,rulefuncVar,%iniFile%,func_item
	Loop, parse, rulefuncVar, `n, `r
	{
		itemList:=StrSplit(A_LoopField,"=")
		IniRead, OutputVar, %iniFile%, func_item,% itemList[1]
		rulefuncList[itemList[1]]:=OutputVar
	}
	;写入新的规则名和规则路径
	IniRead,ruleitemVarNew,%A_ScriptDir%\Lib\RunAnyCtrlRule.ini,rule_item
	Loop, parse, ruleitemVarNew, `n, `r
	{
		itemList:=StrSplit(A_LoopField,"=")
		IniRead, newRuleVar, %A_ScriptDir%\Lib\RunAnyCtrlRule.ini, rule_item,% itemList[1]
		sameFlag:=false
		For ki, kv in ruleitemList
		{
			if(itemList[1]=ki && newRuleVar=kv){
				sameFlag=true
			}
		}
		if(!sameFlag){
			IniWrite, %newRuleVar%, %iniFile%, rule_item, % itemList[1]
		}
	}
	;写入新的规则名和规则函数
	IniRead,rulefuncVarNew,%A_ScriptDir%\Lib\RunAnyCtrlRule.ini,func_item
	Loop, parse, rulefuncVarNew, `n, `r
	{
		itemList:=StrSplit(A_LoopField,"=")
		IniRead, newFuncVar, %A_ScriptDir%\Lib\RunAnyCtrlRule.ini, func_item,% itemList[1]
		sameFlag:=false
		For ki, kv in rulefuncList
		{
			if(itemList[1]=ki && newFuncVar=kv){
				sameFlag=true
			}
		}
		if(!sameFlag){
			IniWrite, %newFuncVar%, %iniFile%, func_item, % itemList[1]
		}
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
		if(updateMsg[dname]<versionStr)
			updateNeed[dname]:=true
		if(updateMsg[dname]!=versionStr && updateMsg[dname]="无版本")
			notnewest:=false
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
	if(A_DD=01 || A_DD=15){
		;当天已经检查过就不再更新
		if(FileExist(A_Temp "\temp_RunAnyCtrl.ahk")){
			FileGetTime,tempMTime, %A_Temp%\temp_RunAnyCtrl.ahk, M  ; 获取修改时间.
			t1 := A_Now
			t1 -= %tempMTime%, Days
			FormatTime,tempTimeDD,%tempMTime%,dd
			if(t1=0 && (tempTimeDD=01 || tempTimeDD=15))
				return
		}
	}
	msgResult.="RunAnyCtrl已经是最新版本。"
	TrayTip,,%msgResult%,3,1
}else{
	msgResult.="RunAnyCtrl是否更新到最新版本？`n覆盖老版本文件，如有过修改请注意备份`n更新后重启RunAnyCtrl生效"
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
		Run,https://github.com/hui-Zz/RunAnyCtrl/wiki/RunAnyCtrl历史更新版本
	}
}
