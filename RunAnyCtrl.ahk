/*
╔══════════════════════════════════════════════════
║【RunAnyCtrl】一劳永逸的规则启动控制器 v1.4.18
║ https://github.com/hui-Zz/RunAnyCtrl
║ by hui-Zz 建议：hui0.0713@gmail.com
║ 讨论QQ群：[246308937]、3222783、493194474
╚══════════════════════════════════════════════════
*/
#NoEnv                  ;~不检查空变量为环境变量
#Persistent             ;~让脚本持久运行
#WinActivateForce       ;~强制激活窗口
#SingleInstance,Force   ;~运行替换旧实例
ListLines,Off           ;~不显示最近执行的脚本行
CoordMode,Menu          ;~相对于整个屏幕
SetBatchLines,-1        ;~脚本全速执行
SetWorkingDir,%A_ScriptDir% ;~脚本当前工作目录
SetTitleMatchMode,2         ;~窗口标题模糊匹配
DetectHiddenWindows,On      ;~显示隐藏窗口
global RunAnyCtrl:="RunAnyCtrl"	;名称
global RunAnyCtrl_version:="1.4.18"
global ahkExePath:=Var_Read("ahkExePath",A_AhkPath)	;AutoHotkey.exe路径
global iniFile:=A_ScriptDir "\" RunAnyCtrl ".ini"
global pluginsFile:=A_ScriptDir "\Lib\RunAnyCtrlPlugins.ahk"
global menuItem:=""
global PluginsList:="RunAnyCtrlFunc,JSON,rule_common,rule_time"
#Include *i %A_ScriptDir%\Lib\JSON.ahk
#Include *i %A_ScriptDir%\Lib\RunAnyCtrlFunc.ahk
Gosub,Var_Set		;~参数初始化
if(!ahkExePath || !FileExist(ahkExePath)){
	RegRead, regFileExt, HKEY_CLASSES_ROOT, .ahk
	RegRead, regFileIcon, HKEY_CLASSES_ROOT, %regFileExt%\DefaultIcon
	regFileIconS:=StrSplit(regFileIcon,",")
	if(regFileIconS[1]){
		Reg_Set("ahkExePath",regFileIconS[1])
		ahkExePath:=regFileIconS[1]
	}else{
		InputBox, UserInput, 未找到AutoHotkey.exe, 请输入正确的AutoHotkey.exe所在路径
		if !ErrorLevel
			Reg_Set("ahkExePath",UserInput)
			ahkExePath:=UserInput
	}
}
if(A_AhkVersion < 1.1.19){
	TrayTip,,由于你的AHK版本没有高于1.1.19，可能会影响到部分功能的使用,3,1
}
gosub,MenuTray
gosub,Run_Item_Read
#Include *i %A_ScriptDir%\Lib\RunAnyCtrlPlugins.ahk
gosub,Rule_Item_Read
Gosub,Rule_Effect
Gosub,AutoRun_Effect
OnExit,ExitSub
;每月1日检查版本更新
if(A_DD=01){
	Gosub,Github_Update
}
return
;══════════════════════════════════════════════════════════════════════════════════════════════════════
;~;[启动项管理器]
;══════════════════════════════════════════════════════════════════════════════════════════════════════
LV_Show:
gosub,Run_Item_Read
global ColumnName:=1
global ColumnType:=2
global ColumnAutoRun:=3
global ColumnHideRun:=4
global ColumnCloseRun:=5
global ColumnRepeatRun:=6
global ColumnMostRun:=7
global ColumnRuleRun:=8
global ColumnRuleLogic:=9
global ColumnRuleNumber:=10
global ColumnRuleTime:=11
global ColumnStatus:=12
global ColumnLastTime:=13
global ColumnPath:=14
Gui,Destroy
Gui,Default
Gui,+Resize
Gui,Font, s10, Microsoft YaHei
Gui,Add, Listview, xm w800 r20 grid AltSubmit vRunAnyLV glistview, 启动项名|类型|自启|隐藏|自关|不重复|最多|规则|匹配|循环|间隔|状态|最后运行时间|路径
;~;[读取启动项内容写入列表]
GuiControl, -Redraw, RunAnyLV
For runn, runv in runitemList
{
	runStatus:=Check_IsRun(runv) ? "启动" : "x"
	runValue:=RegExReplace(runv,"iS)(.*?\.exe)($| .*)","$1")	;去掉参数
	SplitPath, runValue,,, FileExt  ; 获取文件扩展名.
	runType:=FileExt ? FileExt : RegExMatch(runv,"iS)([\w-]+://?|www[.]).*") ? "网址" : "未知"
	LV_Add("", runn, runType, autorunList[runn] ? "是" : "x", hiderunList[runn] ? "是" : "x", closerunList[runn] ? "是" : "x", repeatrunList[runn] ? "是" : "x", mostrunList[runn], rulerunList[runn] ? "是" : "x", rulerunList[runn] ? rulelogicList[runn] ? "与" : "或" : "x", rulenumberList[runn], ruletimeList[runn], runStatus, lasttimeList[runn], runv)
}
GuiControl, +Redraw, RunAnyLV
LVMenu("LVMenu")
LVMenu("ahkGuiMenu")
Gui, Menu, ahkGuiMenu
LVModifyCol(38,ColumnAutoRun,ColumnHideRun,ColumnCloseRun,ColumnRepeatRun,ColumnRuleRun,ColumnRuleLogic)  ; 根据内容自动调整每列的大小.
Gui,Show, , %RunAnyCtrl% 启动控制器 by hui-Zz 2018 %RunAnyCtrl_version%
return

LVMenu(addMenu){
	flag:=addMenu="ahkGuiMenu" ? true : false
	Menu, %addMenu%, Add,% flag ? "启动" : "启动`tF1", LVRun
	Menu, %addMenu%, Icon,% flag ? "启动" : "启动`tF1", %ahkExePath%,2
	Menu, %addMenu%, Add,% flag ? "配置" : "配置`tF2", LVConfig
	Menu, %addMenu%, Icon,% flag ? "配置" : "配置`tF2", SHELL32.dll,134
	Menu, %addMenu%, Add,% flag ? "新建" : "新建`tF3", LVAdd
	Menu, %addMenu%, Icon,% flag ? "新建" : "新建`tF3", SHELL32.dll,194
	Menu, %addMenu%, Add,% flag ? "挂起" : "挂起`tF4", LVSuspend
	Menu, %addMenu%, Icon,% flag ? "挂起" : "挂起`tF4", %ahkExePath%,3
	Menu, %addMenu%, Add,% flag ? "暂停" : "暂停`tF5", LVPause
	Menu, %addMenu%, Icon,% flag ? "暂停" : "暂停`tF5", %ahkExePath%,4
	Menu, %addMenu%, Add,% flag ? "关闭" : "关闭`tF6", LVClose
	Menu, %addMenu%, Icon,% flag ? "关闭" : "关闭`tF6", SHELL32.dll,28
	Menu, %addMenu%, Add,% flag ? "编辑" : "编辑`tF7", LVEdit
	Menu, %addMenu%, Icon,% flag ? "编辑" : "编辑`tF7", SHELL32.dll,2
	Menu, %addMenu%, Add,% flag ? "删除" : "删除`tDel", LVDel
	Menu, %addMenu%, Icon,% flag ? "删除" : "删除`tDel", SHELL32.dll,132
	Menu, %addMenu%, Add,% flag ? "导入" : "导入`tF8", LVImport
	Menu, %addMenu%, Icon,% flag ? "导入" : "导入`tF8", SHELL32.dll,46
	Menu, %addMenu%, Add,% flag ? "设置" : "设置`tF9", LVSet
	Menu, %addMenu%, Icon,% flag ? "设置" : "设置`tF9", SHELL32.dll,22
	Menu, %addMenu%, Add,% flag ? "规则" : "规则`tF10", LVRule
	Menu, %addMenu%, Icon,% flag ? "规则" : "规则`tF10", SHELL32.dll,166
}
LVRun:
	menuItem:="启动"
	gosub,LVApply
	return
LVEdit:
	menuItem:="编辑"
	gosub,LVApply
	return
LVSuspend:
	menuItem:="挂起"
	gosub,LVApply
	return
LVPause:
	menuItem:="暂停"
	gosub,LVApply
	return
LVClose:
	menuItem:="关闭"
	gosub,LVApply
	return
LVDel:
	menuItem:="删除"
	gosub,LVApply
	return
LVAdd:
	menuItem:="新建"
	gosub,GuiConfig
	return
LVConfig:
	menuItem:="配置"
	gosub,GuiConfig
	return
LVApply:
	Row:=LV_GetNext(0, "F")
	RowNumber:=0
	if(Row && menuItem="删除"){
		MsgBox,35,确认删除？(Esc取消),确定删除选中的启动项和其中的规则项？(不会删除文件)
		DelRowList:=""
	}
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		LV_GetText(FileName, RowNumber, ColumnName)
		LV_GetText(FileHideRun, RowNumber, ColumnHideRun)
		LV_GetText(FileStatus, RowNumber, ColumnStatus)
		LV_GetText(FilePath, RowNumber, ColumnPath)
		if(menuItem="启动"){
			if(FileHideRun="是")
				Run,%FilePath%,, hide
			else
				Run,%FilePath%,, UseErrorLevel
			LV_Modify(RowNumber, "", , , , , , , , , , , , "启动", A_Now)
			IniWrite, %A_Now%, %iniFile%, last_run_time, %FileName%
		}else if(menuItem="编辑"){
			PostMessage, 0x111, 65401,,, %FilePath% ahk_class AutoHotkey
		}else if(menuItem="挂起"){
			PostMessage, 0x111, 65404,,, %FilePath% ahk_class AutoHotkey
			LVStatusChange(RowNumber,FileStatus,"挂起")
		}else if(menuItem="暂停"){
			PostMessage, 0x111, 65403,,, %FilePath% ahk_class AutoHotkey
			LVStatusChange(RowNumber,FileStatus,"暂停")
		}else if(menuItem="关闭"){
			runValue:=RegExReplace(FilePath,"iS)(.*?\.exe)($| .*)","$1")	;去掉参数
			SplitPath, runValue, name,, ext  ; 获取扩展名
			if(ext="ahk"){
				PostMessage, 0x111, 65405,,, %FilePath% ahk_class AutoHotkey
				runStatus:="x"
			}else if(name){
				Process,Close,%name%
				if ErrorLevel
					runStatus:="x"
			}
			LV_Modify(RowNumber, "", , , , , , , , , , , , runStatus)
		}else if(menuItem="删除"){
			IfMsgBox Yes
			{
				DelRowList := RowNumber . ":" . DelRowList
				For ki, kv in KeyList
				{
					if(kv="rule_item" || kv="func_item")
						continue
					IniDelete, %iniFile%, %kv%, %FileName%
				}
				IniDelete, %iniFile%, %FileName%
				gosub,Run_Item_Read
			}
		}
	}
	if(menuItem="删除"){
		IfMsgBox Yes
		{
			stringtrimright, DelRowList, DelRowList, 1
			loop, parse, DelRowList, :
				LV_Delete(A_loopfield)
		}
	}
return

GuiConfig:
gosub,Rule_Item_Read
FileName:=FileAutoRun:=FileHideRun:=FileCloseRun:=FileRepeatRun:=FileMostRun:=FileRuleRun:=FileRuleNumber:=FileRuleTime:=FilePath:=""
FileRuleLogic1:=1
if(menuItem="配置"){
	RunRowNumber := LV_GetNext(0, "F")
	if not RunRowNumber
		return
	LV_GetText(FileName, RunRowNumber, ColumnName)
	LV_GetText(FileAutoRun, RunRowNumber, ColumnAutoRun)
	LV_GetText(FileHideRun, RunRowNumber, ColumnHideRun)
	LV_GetText(FileCloseRun, RunRowNumber, ColumnCloseRun)
	LV_GetText(FileRepeatRun, RunRowNumber, ColumnRepeatRun)
	LV_GetText(FileMostRun, RunRowNumber, ColumnMostRun)
	LV_GetText(FileRuleRun, RunRowNumber, ColumnRuleRun)
	LV_GetText(FileRuleNumber, RunRowNumber, ColumnRuleNumber)
	LV_GetText(FileRuleTime, RunRowNumber, ColumnRuleTime)
	LV_GetText(FilePath, RunRowNumber, ColumnPath)
	FileRuleLogic1:=rulelogicList[FileName]
}
FileRuleLogic2:=FileRuleLogic1 ? 0 : 1
FileAutoRun:=FileAutoRun="是" ? 1 : 0
FileHideRun:=FileHideRun="是" ? 1 : 0
FileCloseRun:=FileCloseRun="是" ? 1 : 0
FileRepeatRun:=FileRepeatRun="是" ? 1 : 0
FileRuleRun:=FileRuleRun="是" ? 1 : 0
Gui,2:Destroy
Gui,2:Default
Gui,2:Font,,Microsoft YaHei
Gui,2:Margin,20,20
Gui,2:Add, GroupBox,xm y+10 w500 h175,启动项设置
Gui,2:Add, Text, xm+10 y35 w60, 启动项名：
Gui,2:Add, Edit, x+5 yp-3 w400 vvFileName, %FileName%
Gui,2:Add, Button, xm+5 yp+35 w60 GSetFilePath,启动路径
Gui,2:Add, Edit, x+10 yp w400 r3 vvFilePath, %FilePath%
Gui,2:Add, CheckBox, xm+10 y+5 Checked%FileAutoRun% vvFileAutoRun, 自动启动
Gui,2:Add, CheckBox, x+15 yp Checked%FileHideRun% vvFileHideRun, 隐藏启动
Gui,2:Add, CheckBox, x+10 yp Checked%FileCloseRun% vvFileCloseRun, 随RunAnyCtrl自动关闭
Gui,2:Add, Text, xm+10 y+10 w85, 最多启动次数：
Gui,2:Add, Edit, x+2 yp-3 Number w63 h20 vvFileMostRun, %FileMostRun%
Gui,2:Add, CheckBox, x+20 yp+3 Checked%FileRepeatRun% vvFileRepeatRun, 不重复启动
if(!IsFunc("rule_IsRun")){
	Gui,2:Add, Text, x+2 yp CRed w50, (不可用)
}
Gui,2:Add, GroupBox,xm y+15 w500 h350,规则项设置
Gui,2:Add, CheckBox, xm+10 yp+25 w130 Checked%FileRuleRun% vvFileRuleRun, 使用规则自动启动
Gui,2:Add, Radio, x+20 yp Checked%FileRuleLogic1% vvFileRuleLogic1, 与(全部匹配)(&A)
Gui,2:Add, Radio, x+5 yp Checked%FileRuleLogic2% vvFileRuleLogic2, 或(部分匹配)(&O)
Gui,2:Add, Text, xm+10 y+10 w110, 规则循环最大次数：
Gui,2:Add, Edit, x+2 yp-3 Number w50 h20 vvFileRuleNumber, %FileRuleNumber%
Gui,2:Add, Text, x+20 yp w120, 循环间隔时间(毫秒)：
Gui,2:Add, Edit, x+2 yp-3 Number w100 h20 vvFileRuleTime, %FileRuleTime%
Gui,2:Add, Button, xm+10 y+15 w70 GLVFuncAdd, 增加规则
Gui,2:Add, Button, x+10 yp w70 GLVFuncEdit, 修改规则
Gui,2:Add, Button, x+10 yp w70 GLVFuncRemove, 减少规则
Gui,2:Font, s10, Microsoft YaHei
Gui,2:Add, Listview, xm+10 y+10 w480 r10 grid AltSubmit C808000 vFuncLV glistfunc, 规则名|中断|条件|自定义条件值
;[读取启动项设置的规则内容写入列表]
GuiControl, 2:-Redraw, FuncLV
For k, v in runruleitemList[FileName]
{
	LV_Add("", v["ruleName"], v["ruleBreak"] ? "*" : "", v["ruleLogic"] ? "相等" : "不相等", v["ruleParamStr"])
}
LV_ModifyCol(1)
LV_ModifyCol(2)
LV_ModifyCol(3)
GuiControl, 2:+Redraw, FuncLV
Gui,2:Add,Button,Default xm+150 y+15 w75 GLVSave,保存(&Y)
Gui,2:Add,Button,x+20 w75 GLVCancel,取消(&C)
Gui,2:Show, , %RunAnyCtrl% 启动项规则 - %menuItem%
return

LVSave:
	Gui,2:Submit, NoHide
	if(!vFileName || !vFilePath){
		MsgBox, 48, ,请填入启动项名和启动路径
		return
	}
	if(FileName!=vFileName && runitemList[vFileName]){
		MsgBox, 48, ,已存在相同的启动项名，请修改
		return
	}
	For ki, kv in KeyList
	{
		if(vFileName=kv){
			MsgBox, 48, ,启动项名不能与RunAnyCtrl内置配置重名，请修改
			return
		}
	}
	if(Instr(vFileName, A_SPACE)){
		StringReplace, vFileName, vFileName, %A_SPACE%, _, All
		GuiControl, 2:, vFileName, %vFileName%
		MsgBox, 48, ,启动项名不能带有空格，请用_代替
		return
	}
	if(Instr(vFileName, A_Tab)){
		StringReplace, vFileName, vFileName, %A_Tab%, _, All
		GuiControl, 2:, vFileName, %vFileName%
		MsgBox, 48, ,启动项名不能带有制表符，请用_代替
		return
	}
	;~ 先删除启动项原有规则项
	IniDelete, %iniFile%, %FileName%
	ruleContent:=""
	Loop % LV_GetCount()
	{
		LV_GetText(RuleName, A_Index, 1)
		LV_GetText(FuncBreak, A_Index, 2)
		LV_GetText(FuncBoolean, A_Index, 3)
		LV_GetText(FuncValue, A_Index, 4)
		FuncBoolean:=FuncBoolean="相等" ? 1 : 0
		ruleContent.=RuleName . "|" . FuncBreak . FuncBoolean . "|" . FuncValue . "`n"
	}
	if(ruleContent){
		stringtrimright, ruleContent, ruleContent, 1
		IniWrite, %ruleContent%, %iniFile%, %vFileName%
	}
	;[写入配置文件]
	Gui,1:Default
	vFileRuleLogic:=vFileRuleLogic1 ? 1 : 0
	runValue:=RegExReplace(vFilePath,"iS)(.*?\.exe)($| .*)","$1")	;去掉参数
	SplitPath, runValue,,, FileExt  ; 获取文件扩展名.
	runType:=FileExt ? FileExt : RegExMatch(vFilePath,"iS)([\w-]+://?|www[.]).*") ? "网址" : "未知"
	if(menuItem="新建"){
		LV_Add("",vFileName,runType,vFileAutoRun ? "是" : "x",vFileHideRun ? "是" : "x",vFileCloseRun ? "是" : "x",vFileRepeatRun ? "是" : "x",vFileMostRun,vFileRuleRun ? "是" : "x",vFileRuleRun ? vFileRuleLogic ? "与" : "或" : "x",vFileRuleNumber,vFileRuleTime,"x",,vFilePath)
	}else{
		;~ 删除原有启动项其他配置，不包含规则项
		For ki, kv in KeyList
		{
			if((kv="rule_item" || kv="func_item") || (vFileName=FileName && kv="run_item"))
				continue
			IniDelete, %iniFile%, %kv%, %FileName%
		}
		LV_Modify(RunRowNumber,"",vFileName,runType,vFileAutoRun ? "是" : "x",vFileHideRun ? "是" : "x",vFileCloseRun ? "是" : "x",vFileRepeatRun ? "是" : "x",vFileMostRun,vFileRuleRun ? "是" : "x",vFileRuleRun ? vFileRuleLogic ? "与" : "或" : "x",vFileRuleNumber,vFileRuleTime,,,vFilePath)
	}
	Gui,2:Destroy
	GuiControl, 1:+Redraw, RunAnyLV
	IniWrite, %vFilePath%, %iniFile%, run_item, %vFileName%
	if(vFileAutoRun)
		IniWrite, %vFileAutoRun%, %iniFile%, auto_run_item, %vFileName%
	if(vFileHideRun)
		IniWrite, %vFileHideRun%, %iniFile%, hide_run_item, %vFileName%
	if(vFileCloseRun)
		IniWrite, %vFileCloseRun%, %iniFile%, close_run_item, %vFileName%
	if(vFileRepeatRun)
		IniWrite, %vFileRepeatRun%, %iniFile%, repeat_run_item, %vFileName%
	if(vFileMostRun)
		IniWrite, %vFileMostRun%, %iniFile%, most_run_item, %vFileName%
	if(vFileRuleRun)
		IniWrite, %vFileRuleRun%, %iniFile%, rule_run_item, %vFileName%
	if(vFileRuleRun && vFileRuleLogic)
		IniWrite, %vFileRuleLogic%, %iniFile%, rule_logic_item, %vFileName%
	if(vFileRuleNumber)
		IniWrite, %vFileRuleNumber%, %iniFile%, rule_number_item, %vFileName%
	if(vFileRuleTime)
		IniWrite, %vFileRuleTime%, %iniFile%, rule_time_item, %vFileName%
	gosub,Run_Item_Read
return
LVImport:
	FileSelectFile, selectName, M35, , 选择多项要导入的AHK(EXE), (*.ahk;*.exe)
	Loop,parse,selectName,`n
	{
		if(A_Index=1){
			dir:=A_LoopField
		}else{
			fullPath:=dir "\" A_LoopField
			SplitPath, fullPath, , , ext, name_no_ext
			if(runitemList[name_no_ext]){
				TrayTip,,导入项中有已存在的相同文件名启动项，不会导入,3,1
				continue
			}
			LV_Add("", name_no_ext, ext, "x", "x", "x", "x", , "x", "x", , ,"x", , fullPath)
			IniWrite, %fullPath%, %iniFile%, run_item, %name_no_ext%
		}
	}
	LVModifyCol(38,ColumnAutoRun,ColumnHideRun,ColumnCloseRun,ColumnRepeatRun,ColumnRuleRun,ColumnRuleLogic)  ; 根据内容自动调整每列的大小.
return
;══════════════════════════════════════════════════════════════════════════════════════════════════════
;~;[规则函数配置]
LVFuncAdd:
	menuFuncItem:="新建规则函数"
	RuleName:=FuncBoolean:=FuncValue:=""
	FuncBreak:=0
	FuncBoolean1:=1
	RuleNameChoose:=1
	gosub,LVFuncConfig
return
LVFuncEdit:
	menuFuncItem:="修改规则函数"
	RowNumber:=LV_GetNext(0, "F")
	if not RowNumber
		return
	LV_GetText(RuleName, RowNumber, 1)
	LV_GetText(FuncBreak, RowNumber, 2)
	LV_GetText(FuncBoolean, RowNumber, 3)
	LV_GetText(FuncValue, RowNumber, 4)
	FuncBoolean1:=FuncBoolean="相等" ? 1 : 0
	FuncBreak:=FuncBreak ? 1 : 0
	RuleNameChoose:=1
	loop, parse, rulenameStr, |
	{
		if(RuleName=A_LoopField){
			RuleNameChoose:=A_Index
			break
		}
	}
	ruleParamContent:=ruleParamTen:=""
	Loop, parse, FuncValue, |
	{
		if(A_Index>0 && A_Index<10){
			ruleParamContent.=A_LoopField . "`n"
			continue
		}
		if(A_Index>=10)
			ruleParamTen.=A_LoopField . "|"
	}
	;第十个参数及以上分隔参数，都归为第十参数
	if(ruleParamTen){
		stringtrimright, ruleParamTen, ruleParamTen, 1
		ruleParamContent.=ruleParamTen
	}else{
		stringtrimright, ruleParamContent, ruleParamContent, 1
	}
	FuncValue:=ruleParamContent
	gosub,LVFuncConfig
return
LVFuncConfig:
	FuncBoolean2:=FuncBoolean1 ? 0 : 1
	Gui,F:Destroy
	Gui,F:Font,,Microsoft YaHei
	Gui,F:Margin,20,10
	Gui,F:Add, Text, xm y+10 w60, 规则名：
	Gui,F:Add, DropDownList, xm+60 yp Choose%RuleNameChoose% vvRuleName, %rulenameStr%
	Gui,F:Add, Radio, xm y+10 Checked%FuncBoolean1% vvFuncBoolean1, 相等、真(&T)
	Gui,F:Add, Radio, x+5 yp Checked%FuncBoolean2% vvFuncBoolean2, 不相等、假(&F)
	Gui,F:Add, CheckBox, x+20 yp Checked%FuncBreak% vvFuncBreak, 不满足中断规则循环
	Gui,F:Add, Text, xm y+10 w350, 自定义条件(只判断规则真假，不用填写)：`n（多个参数每行为一个参数，最多支持10个，保存会用|分隔）
	Gui,F:Add, Edit, xm y+10 w350 r8 vvFuncValue, %FuncValue%
	Gui,F:Add, Button,Default xm+80 y+15 w75 GLVFuncSave,保存(&Y)
	Gui,F:Add, Button,x+10 w75 GLVCancel,取消(&C)
	Gui,F:Show, , %RunAnyCtrl% 修改使用规则
return
LVFuncRemove:
	DelRowList:=""
	Row:=LV_GetNext(0, "F")
	RowNumber:=0
	if(Row)
		MsgBox,35,确认删除？(Esc取消),确定删除选中的规则项？
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		IfMsgBox Yes
		{
			DelRowList:=RowNumber . ":" . DelRowList
		}
	}
	IfMsgBox Yes
	{
		stringtrimright, DelRowList, DelRowList, 1
		loop, parse, DelRowList, :
			LV_Delete(A_loopfield)
	}
return
LVFuncSave:
	Gui,F:Submit, NoHide
	if(!vRuleName){
		MsgBox, 48, ,请选择使用的规则
		return
	}
	if(InStr(vFuncValue,"|")){
		MsgBox, 48, ,自定义条件不能包含有“|”，因为每个参数保存用“|”进行分隔
		return
	}
	vFuncValueNums:=StrSplit(vFuncValue,"`n")
	if(vFuncValueNums.MaxIndex() > 10){
		MsgBox, 48, ,自定义条件每行为一个参数，最多支持10行
		return
	}
	funcValueStr:=""
	Loop,% vFuncValueNums.MaxIndex()
	{
		if(vFuncValueNums[A_Index])
			funcValueStr.=vFuncValueNums[A_Index] . "|"
	}
	stringtrimright, funcValueStr, funcValueStr, 1
	;[写入配置文件]
	Gui,F:Destroy
	Gui,2:Default
	vFuncBoolean:=vFuncBoolean1 ? 1 : 0
	if(menuFuncItem="修改规则函数"){
		LV_Modify(RowNumber,"",vRuleName,vFuncBreak ? "*" : "",vFuncBoolean ? "相等" : "不相等",funcValueStr)
	}else{
		LV_Add("",vRuleName,vFuncBreak ? "*" : "",vFuncBoolean ? "相等" : "不相等",funcValueStr)
	}
	LV_ModifyCol(1)
	LV_ModifyCol(2)
	LV_ModifyCol(3)
	GuiControl, 2:+Redraw, FuncLV
return
listfunc:
    if A_GuiEvent = DoubleClick
    {
		gosub,LVFuncEdit
    }
return
;══════════════════════════════════════════════════════════════════════════════════════════════════════
#If WinActive(RunAnyCtrl A_Space "启动控制器")
	F1::gosub,LVRun
	F2::gosub,LVConfig
	F3::gosub,LVAdd
	F4::gosub,LVSuspend
	F5::gosub,LVPause
	F6::gosub,LVClose
	Del::gosub,LVDel
	F7::gosub,LVEdit
	F8::gosub,LVImport
	F9::gosub,LVSet
	F10::gosub,LVRule
#If
GuiContextMenu:
	If (A_GuiControl = "RunAnyLV") {
		LV_Modify(A_EventInfo, "Select Vis")
		Menu, LVMenu, Show
	}
return
GuiSize:
	if A_EventInfo = 1
		return
	GuiControl, Move, RunAnyLV, % "H" . (A_GuiHeight-10) . " W" . (A_GuiWidth - 20)
	GuiControl, Move, RuleLV, % "H" . (A_GuiHeight-10) . " W" . (A_GuiWidth - 20)
return
GuiClose:
	Gui,Destroy
return
GuiEscape:
	Gui,Destroy
return
LVCancel:
	Gui,Destroy
return
listview:
    if A_GuiEvent = DoubleClick
    {
		menuItem:="配置"
		gosub,GuiConfig
    }
return
SetFilePath:
	FileSelectFile, filePath, 3, , 请选择导入的启动项, (*.ahk;*.exe)
	GuiControl, 2:, vFilePath, %filePath%
return
LVSet:
	Gui,S:Destroy
	Gui,S:Margin,50,30
	Gui,S:Add, Checkbox,Checked%AutoRun% xm yp+10 h30 vvAutoRun,开机自动启动
	Gui,S:Add, GroupBox,xm-10 y+10 w225 h55,RunAnyCtrl配置自定义热键 %ConfigHotKey%
	Gui,S:Add, Hotkey,xm yp+20 w150 vvConfigKey,%ConfigKey%
	Gui,S:Add, Checkbox,Checked%ConfigWinKey% xm+155 yp+3 vvConfigWinKey,Win
	Gui,S:Add, Button,Default xm+15 y+30 w75 GLVSetSave,保存(&Y)
	Gui,S:Add, Button,x+10 w75 GLVCancel,取消(&C)
	Gui,S:Show, , %RunAnyCtrl% 设置选项
return
LVSetSave:
	Gui,S:Submit
	reloadFlag:=false
	if(vAutoRun!=AutoRun){
		AutoRun:=vAutoRun
		if(AutoRun){
			RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, RunAnyCtrl, %A_ScriptFullPath%
		}else{
			RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, RunAnyCtrl
		}
		reloadFlag:=true
	}
	if(vConfigKey!=ConfigKey){
		IniWrite,%vConfigKey%,%iniFile%,run_any_ctrl_config,ConfigKey
		reloadFlag:=true
	}
	if(vConfigWinKey!=ConfigWinKey){
		IniWrite,%vConfigWinKey%,%iniFile%,run_any_ctrl_config,ConfigWinKey
		reloadFlag:=true
	}
	if(reloadFlag)
		Reload
return
;══════════════════════════════════════════════════════════════════════════════════════════════════════
;~;[规则配置]
;══════════════════════════════════════════════════════════════════════════════════════════════════════
LVRule:
	gosub,Rule_Item_Read
	Gui,R:Destroy
	Gui,R:Default
	Gui,R:+Resize
	Gui,R:Font, s10, Microsoft YaHei
	Gui,R:Add, Listview, xm w600 r15 grid AltSubmit BackgroundF6F6E8 vRuleLV glistrule, 规则名|规则函数|状态|规则路径
	;[读取规则内容写入列表]
	GuiControl, -Redraw, RuleLV
	For ki, kv in ruleitemList
	{
		LV_Add("", ki, rulefuncList[ki], rulestatusList[ki] ? "正常" : "不可用", kv)
	}
	GuiControl, +Redraw, RuleLV
	Menu, ruleGuiMenu, Add, 增加, LVRulePlus
	Menu, ruleGuiMenu, Icon, 增加, SHELL32.dll,1
	Menu, ruleGuiMenu, Add, 编辑, LVRuleEdit
	Menu, ruleGuiMenu, Icon, 编辑, SHELL32.dll,134
	Menu, ruleGuiMenu, Add, 减少, LVRuleMinus
	Menu, ruleGuiMenu, Icon, 减少, SHELL32.dll,132
	Gui,R:Menu, ruleGuiMenu
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	Gui,R:Show, , %RunAnyCtrl% 规则管理
return
LVRulePlus:
	menuRuleItem:="规则新建"
	RuleName:=RuleFunction:=RulePath:=""
	gosub,LVRuleConfig
return
LVRuleEdit:
	RowNumber:=LV_GetNext(0, "F")
	if not RowNumber
		return
	LV_GetText(RuleName, RowNumber, 1)
	LV_GetText(RuleFunction, RowNumber, 2)
	LV_GetText(RulePath, RowNumber, 4)
	menuRuleItem:="规则编辑"
	gosub,LVRuleConfig
return
LVRuleConfig:
	Gui,P:Destroy
	Gui,P:Font,,Microsoft YaHei
	Gui,P:Margin,20,10
	Gui,P:Add, Text, xm y+10 w60, 规则名：
	Gui,P:Add, Edit, xm+60 yp-3 w450 vvRuleName, %RuleName%
	Gui,P:Add, Text, xm y+10 w60, 规则函数：
	Gui,P:Add, Edit, xm+60 yp-3 w225 vvRuleFunction, %RuleFunction%
	Gui,P:Add, DropDownList, x+5 yp+2 w220 vvRuleDLL GDropDownRuleList
	Gui,P:Add, Button, xm-5 yp+30 w60 h60 GSetRulePath,规则路径 可自动识别函数名
	Gui,P:Add, Edit, xm+60 yp w450 r3 vvRulePath GRulePathChange, %RulePath%
	Gui,P:Add, Button,Default xm+180 y+10 w75 GLVRuleSave,保存(&Y)
	Gui,P:Add, Button,x+10 w75 GLVCancel,取消(&C)
	Gui,P:Show, , %RunAnyCtrl% 规则编辑
	funcnameStr:=KnowAhkFuncZz(RulePath)
	GuiControl, P:, vRuleDLL, |
	GuiControl, P:, vRuleDLL, %funcnameStr%
	funcNameChoose:=1
	loop, parse, funcnameStr, |
	{
		if(RuleFunction=A_LoopField){
			funcNameChoose:=A_Index
			break
		}
	}
	GuiControl, P:Choose, vRuleDLL, %funcNameChoose%
return
LVRuleMinus:
	DelRowList:=""
	Row:=LV_GetNext(0, "F")
	RowNumber:=0
	if(Row)
		MsgBox,35,确认删除？(Esc取消),确定删除选中的规则项？
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		IfMsgBox Yes
		{
			LV_GetText(RuleName, RowNumber, 1)
			LV_GetText(RuleFunction, RowNumber, 2)
			LV_GetText(RulePath, RowNumber, 4)
			DelRowList:=RowNumber . ":" . DelRowList
			IniDelete, %iniFile%, rule_item, %RuleName%
			IniDelete, %iniFile%, func_item, %RuleName%
			;删除所有正在使用此规则的关联配置
			Change_Rule_Name(RuleName,"")
			gosub,Rule_Item_Read
			;~ 判断如果所有规则都没用到此脚本，则去除引用
			NoQuote:=true
			For ki, kv in ruleitemList
			{
				if(RulePath=kv)
					NoQuote:=false
			}
			if(NoQuote){
				oldRule:="#Include *i " RulePath
				Plugins_Replace(oldRule)
				gosub,Plugins_Read
			}
		}
	}
	IfMsgBox Yes
	{
		stringtrimright, DelRowList, DelRowList, 1
		loop, parse, DelRowList, :
			LV_Delete(A_loopfield)
	}
return
LVRuleSave:
	Gui,P:Submit, NoHide
	if(!vRuleName || !vRuleFunction || !vRulePath){
		MsgBox, 48, ,请填入规则名、规则函数和规则路径
		return
	}
	if(InStr(vRuleName,"|")){
		MsgBox, 48, ,规则名不能包含有“|”分割符
		return
	}
	if(RuleName!=vRuleName && ruleitemList[vRuleName]){
		MsgBox, 48, ,已存在相同的规则名，请修改
		return
	}
	StringReplace, checkRulePath, vRulePath,`%A_ScriptDir`%, %A_ScriptDir%
	IfNotExist,%checkRulePath%
	{
		MsgBox, 48, ,规则路径AHK脚本不存在，请重新添加
		return
	}
	;[写入配置文件]
	Gui,R:Default
	includeStr:="#Include *i "
	if(menuRuleItem="规则编辑"){
		if(RuleName!=vRuleName){
			IniDelete, %iniFile%, rule_item, %RuleName%
			IniDelete, %iniFile%, func_item, %RuleName%
			;~ 变更所有正在使用此规则的启动项中关联规则名称
			Change_Rule_Name(RuleName,vRuleName)
		}
		if(!pluginsList[includeStr . vRulePath]){
			oldRule:=includeStr . RulePath
			appendRule:=includeStr . vRulePath
			Plugins_Replace(oldRule,appendRule)
		}
		LV_Modify(RowNumber,"",vRuleName,vRuleFunction,IsFunc(vRuleFunction) ? "正常" : "不可用",vRulePath)
	}else{
		if(!pluginsList[includeStr . vRulePath]){
			FileAppend,% "`n" . includeStr . vRulePath,%pluginsFile%
		}
		LV_Add("",vRuleName,vRuleFunction,"重启生效",vRulePath)
	}
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	GuiControl, R:+Redraw, RuleLV
	IniWrite, %vRulePath%, %iniFile%, rule_item, %vRuleName%
	IniWrite, %vRuleFunction%, %iniFile%, func_item, %vRuleName%
	gosub,Plugins_Read
	gosub,Rule_Item_Read
	Gui,P:Destroy
return
listrule:
    if A_GuiEvent = DoubleClick
    {
		gosub,LVRuleEdit
    }
return
SetRulePath:
	FileSelectFile, rulePath, 3, , 请选择要使用的的AutoHotkey规则脚本, (*.ahk)
	if(rulePath){
		Gui,P:Submit, NoHide
		Get_Rule_Func_Name(rulePath,vRuleFunction)
		GuiControl, P:, vRulePath, %rulePath%
	}
return
RulePathChange:
	Gui,P:Submit, NoHide
	Get_Rule_Func_Name(vRulePath,vRuleFunction)
return
DropDownRuleList:
	Gui,P:Submit, NoHide
	GuiControl, P:, vRuleFunction, %vRuleDLL%
return
;[自动根据规则脚本的路径来变更函数下拉选择框和空规则函数]
Get_Rule_Func_Name(rulePath,vRuleFunction){
	if(rulePath){
		funcnameStr:=KnowAhkFuncZz(rulePath)
		GuiControl, P:, vRuleDLL, |
		GuiControl, P:, vRuleDLL, %funcnameStr%
		GuiControl, P:Choose, vRuleDLL, 1
		if(!vRuleFunction && funcnameStr){
			gosub,DropDownRuleList
		}
	}
}
;[判断脚本当前状态]
LVStatusChange(RowNumber,FileStatus,lvItem){
	item:=lvItem
	if(FileStatus="挂起" && lvItem="暂停"){
		lvItem:="挂起暂停"
	}else if(FileStatus="暂停" && lvItem="挂起"){
		lvItem:="暂停挂起"
	}else if(FileStatus!="启动"){
		StringReplace, lvItem, FileStatus, %item%
	}
	if(lvItem="")
		lvItem:="启动"
	LV_Modify(RowNumber, "", , , , , , , , , , , , lvItem)
	LVModifyCol(38,ColumnAutoRun,ColumnHideRun,ColumnCloseRun,ColumnRepeatRun,ColumnRuleRun,ColumnRuleLogic)  ; 根据内容自动调整每列的大小.
}
;[自动调整列表宽度]
LVModifyCol(width, colList*){
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	for index,col in colList
	{
		LV_ModifyCol(col, width)
		LV_ModifyCol(col, "center")
	}
}
;[变更所有正在使用此规则的启动项中关联规则名称]
Change_Rule_Name(rname,rnew){
	For runn, runv in runitemList
	{
		writeFalg:=false
		ruleContent:=""
		IniRead,runRuleVar,%iniFile%,%runn%
		Loop, parse, runRuleVar, `n, `r
		{
			runRuleSplit:=""
			Loop, parse, A_LoopField, |
			{
				if(A_Index=1 && A_LoopField=rname){
					writeFalg:=true
					if(rnew){
						runRuleSplit.=rnew . "|"
						continue
					}else{
						break
					}
				}
				runRuleSplit.=A_LoopField . "|"
			}
			stringtrimright, runRuleSplit, runRuleSplit, 1
			ruleContent.=runRuleSplit . "`n"
		}
		if(writeFalg){
			IniDelete, %iniFile%, %runn%
			stringtrimright, ruleContent, ruleContent, 1
			IniWrite, %ruleContent%, %iniFile%, %runn%
		}
	}
}
;[替换嵌入脚本的文本，需要重启生效]
Plugins_Replace(oldPlugins,newPlugins:=""){
	content:=""
	FileRead, pluginsContent, %pluginsFile%
	Loop, parse, pluginsContent, `n, `r
	{
		if(A_LoopField=oldPlugins){
			content.=newPlugins
			if(newPlugins)
				content.="`n"
		}else{
			content.=A_LoopField "`n"
		}
	}
	stringtrimright, content, content, 1
	FileDelete,%pluginsFile%
	FileAppend,%content%,%pluginsFile%
}
Check_IsRun(runv){
	return IsFunc("rule_IsRun") ? Func("rule_IsRun").Call(runv) : false
}
KnowAhkFuncZz(RulePath){
	return IsFunc("getAhkFuncZz") ? Func("getAhkFuncZz").Call(RulePath) : ""
}
Var_Read(rValue,defVar=""){
	RegRead, regVar, HKEY_CURRENT_USER, SOFTWARE\%RunAnyCtrl%, %rValue%
	if(regVar)
		return regVar
	else
		return defVar
}
Reg_Set(sz,var){
	RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\%RunAnyCtrl%, %sz%, %var%
}
;══════════════════════════════════════════════════════════════════════════════════════════════════════
;~;[生效规则]
;══════════════════════════════════════════════════════════════════════════════════════════════════════
Rule_Effect:
	global runIndex:=Object(),funcEffect:=Object()
	try{
		For runn, runv in runitemList	;循环启动项
		{
			if(rulerunList[runn]){		;需要执行规则
				;已在运行且设定为不重复启动
				if(repeatrunList[runn] && Check_IsRun(runv))
					continue
				;是否设定运行项最多启动次数
				if(mostrunList[runn] && !mostrunIndex[runn])
					mostrunIndex[runn]:=0
				if((rulenumberList[runn] && rulenumberList[runn] > 1) || (rulenumberList[runn] > 0 && ruletimeList[runn])){
					runIndex[runn]:=0	;规则定时器初始计数为0
					funcEffect%runn%:=Func("Func_Effect").Bind(runn, runv)	;规则定时器
					ruleTime:=ruletimeList[runn] ? ruletimeList[runn] : 1		;规则定时器间隔时间(毫秒)
					SetTimer,% funcEffect%runn%, %ruleTime%
				}else{
					Func_Effect(runn, runv)
				}
			}
		}
	} catch e {
			MsgBox,16,规则启动出错,% "启动项名：" runn "`n启动项路径：" runv "`n出错脚本：" e.File "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	}
return
/*
[规则嵌入函数验证]
最多支持传递10个参数
*/
Func_Effect(runn, runv){
	effectFlag:=false
	For k, v in runruleitemList[runn]	;循环规则内容
	{
		if(!v["ruleParam"]){	;规则没有传参，直接执行规则
			effectFlag:=funccallList[v["ruleName"]].Call()
		}else if(v["ruleParam"].MaxIndex()=1){
			effectFlag:=v["ruleParam"][1] ? funccallList[v["ruleName"]].Call(v["ruleParam"][1]) : funccallList[v["ruleName"]].Call()
		}else if(v["ruleParam"].MaxIndex()=2){
			effectFlag:=funccallList[v["ruleName"]].Call(v["ruleParam"][1],v["ruleParam"][2])
		}else if(v["ruleParam"].MaxIndex()=3){
			effectFlag:=funccallList[v["ruleName"]].Call(v["ruleParam"][1],v["ruleParam"][2],v["ruleParam"][3])
		}else if(v["ruleParam"].MaxIndex()=4){
			effectFlag:=funccallList[v["ruleName"]].Call(v["ruleParam"][1],v["ruleParam"][2],v["ruleParam"][3],v["ruleParam"][4])
		}else if(v["ruleParam"].MaxIndex()=5){
			effectFlag:=funccallList[v["ruleName"]].Call(v["ruleParam"][1],v["ruleParam"][2],v["ruleParam"][3],v["ruleParam"][4],v["ruleParam"][5])
		}else if(v["ruleParam"].MaxIndex()=6){
			effectFlag:=funccallList[v["ruleName"]].Call(v["ruleParam"][1],v["ruleParam"][2],v["ruleParam"][3],v["ruleParam"][4],v["ruleParam"][5],v["ruleParam"][6])
		}else if(v["ruleParam"].MaxIndex()=7){
			effectFlag:=funccallList[v["ruleName"]].Call(v["ruleParam"][1],v["ruleParam"][2],v["ruleParam"][3],v["ruleParam"][4],v["ruleParam"][5],v["ruleParam"][6],v["ruleParam"][7])
		}else if(v["ruleParam"].MaxIndex()=8){
			effectFlag:=funccallList[v["ruleName"]].Call(v["ruleParam"][1],v["ruleParam"][2],v["ruleParam"][3],v["ruleParam"][4],v["ruleParam"][5],v["ruleParam"][6],v["ruleParam"][7],v["ruleParam"][8])
		}else if(v["ruleParam"].MaxIndex()=9){
			effectFlag:=funccallList[v["ruleName"]].Call(v["ruleParam"][1],v["ruleParam"][2],v["ruleParam"][3],v["ruleParam"][4],v["ruleParam"][5],v["ruleParam"][6],v["ruleParam"][7],v["ruleParam"][8],v["ruleParam"][9])
		}else if(v["ruleParam"].MaxIndex()=10){
			effectFlag:=funccallList[v["ruleName"]].Call(v["ruleParam"][1],v["ruleParam"][2],v["ruleParam"][3],v["ruleParam"][4],v["ruleParam"][5],v["ruleParam"][6],v["ruleParam"][7],v["ruleParam"][8],v["ruleParam"][9],v["ruleParam"][10])
		}
		;如果规则设定条件为（不相等、假），而脚本执行结果是真，则判定为false；执行结果是假，则判定为true
		if(!v["ruleLogic"]){
			effectFlag:=effectFlag ? false : true
		}
		;规则不满足且有中断标记则直接中断后续判断并停止规则循环
		if(!effectFlag && v["ruleBreak"]){
			try SetTimer,% funcEffect%runn%, Off
			break
		}
		;该启动项所有规则必须全部为真时，如有一假就退出循环
		;该启动项只需要有一项规则为真时，如有一真就退出循环
		if(rulelogicList[runn]){
			if(!effectFlag)
				break
		}else{
			if(effectFlag)
				break
		}
	}
	if(effectFlag){
		;启动项是否超出最多运行次数
		if(!mostrunList[runn] || mostrunIndex[runn] < mostrunList[runn]){
			if(hiderunList[runn])
				Run,%runv%,, hide
			else
				Run,%runv%,, UseErrorLevel
			WriteLastRunTimeFunc%runn%:=Func("Write_Last_Run_Time").Bind(runn,A_Now)	;写运行时间定时器
			SetTimer,% WriteLastRunTimeFunc%runn%, %WriteLastRunTime%
			if(mostrunList[runn])
				mostrunIndex[runn]++
		}
	}
	runIndex[runn]++	;规则定时器运行计数+1
	;规则运行计数达到最大循环次数 || 已在运行且设定为不重复启动 || 启动项已达到最多运行次数 => 结束定时器
	if((runIndex[runn] && runIndex[runn] >= rulenumberList[runn]) || (repeatrunList[runn] && Check_IsRun(runv)) || (mostrunList[runn] && mostrunIndex[runn] >= mostrunList[runn])){
		try SetTimer,% funcEffect%runn%, Off
	}
}
;~;[自动启动生效]
AutoRun_Effect:
	try {
		For runn, runv in runitemList	;循环启动项
		{
			;需要自动启动的项
			if(autorunList[runn]){
				;已在运行且设定为不重复启动
				if(repeatrunList[runn] && Check_IsRun(runv))
					continue
				;设定为隐藏启动
				if(hiderunList[runn])
					Run,%runv%,, hide
				else
					Run,%runv%,, UseErrorLevel
				WriteLastRunTimeFunc%runn%:=Func("Write_Last_Run_Time").Bind(runn,A_Now)	;写运行时间定时器
				SetTimer,% WriteLastRunTimeFunc%runn%, %WriteLastRunTime%
			}
		}
	} catch e {
			MsgBox,16,自动启动出错,% "启动项名：" runn "`n启动项路径：" runv "`n出错脚本：" e.File "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	}
return
;~;[随RunAnyCtrl自动关闭]
AutoClose_Effect:
	For runn, runv in runitemList
	{
		if(closerunList[runn]){
			runValue:=RegExReplace(runv,"iS)(.*?\.exe)($| .*)","$1")	;去掉参数
			SplitPath, runValue, name,, ext  ; 获取扩展名
			if(ext="ahk"){
				PostMessage, 0x111, 65405,,, %FilePath% ahk_class AutoHotkey
			}else if(name){
				Process,Close,%name%
			}
		}
	}
return
Write_Last_Run_Time(runn,runTime){
	IniWrite, %runTime%, %iniFile%, last_run_time, %runn%
	try SetTimer,% WriteLastRunTimeFunc%runn%, Off
}
;══════════════════════════════════════════════════════════════════════════════════════════════════════
;~;[初始化]
;══════════════════════════════════════════════════════════════════════════════════════════════════════
Var_Set:
	;~;[RunAnyCtrl设置参数]
	RegRead, AutoRun, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, RunAnyCtrl
	AutoRun:=AutoRun ? 1 : 0
	global KeyList:=["run_any_ctrl_config","run_item","rule_item","func_item","auto_run_item","hide_run_item","close_run_item","repeat_run_item","most_run_item","last_run_time","rule_run_item","rule_logic_item","rule_number_item","rule_time_item"]
	;配置界面的热键
	IniRead, ConfigKey,%iniFile%, run_any_ctrl_config, ConfigKey
	IniRead, ConfigWinKey,%iniFile%, run_any_ctrl_config, ConfigWinKey
	ConfigHotKey:=ConfigWinKey ? "#" . ConfigKey : ConfigKey
	try Hotkey,%ConfigHotKey%,LV_Show,On
	global mostrunIndex:=Object()
	;等待一段时间(OneDrive同步结束)后写最后运行时间到配置，避免与OneDrive文件版本冲突
	global WriteLastRunTime:=100
	IniRead, WriteLastRunTime,%iniFile%, run_any_ctrl_config, WriteLastRunTime, 100
	;配置文件初始化操作
	IfNotExist,%A_ScriptDir%\Lib
	{
		FileCreateDir, %A_ScriptDir%\Lib
	}
	IfNotExist,%iniFile%
	{
		initIniContent:=""
		initRun:="RunAnyCtrl=https://github.com/hui-Zz/RunAnyCtrl"
		initRule:="网络连接=%A_ScriptDir%\Lib\rule_common.ahk`n电脑名=%A_ScriptDir%\Lib\rule_common.ahk`nWiFi名(静默)=%A_ScriptDir%\Lib\rule_common.ahk`n运行状态=%A_ScriptDir%\Lib\rule_common.ahk`n时间点=%A_ScriptDir%\Lib\rule_time.ahk`n星期几=%A_ScriptDir%\Lib\rule_time.ahk"
		initFunc:="网络连接=rule_network`n电脑名=rule_computer_name`nWiFi名(静默)=rule_wifi_silence`n运行状态=rule_IsRun`n时间点=rule_today_hour`n星期几=rule_today_week"
		For ki, kv in KeyList
		{
			initIniContent.="[" kv "]`n"
		}
		FileAppend,%initIniContent%,%iniFile%
		IniWrite, %initRun%, %iniFile%, run_item
		IniWrite, %initRule%, %iniFile%, rule_item
		IniWrite, %initFunc%, %iniFile%, func_item
		IniWrite, 1, %iniFile%, rule_run_item, RunAnyCtrl
		IniWrite, 网络连接|1|, %iniFile%, RunAnyCtrl
		TrayTip,,RunAnyCtrl初始化成功！点击任务栏图标设置，可自由定制规则启动程序（如有网络打开网页）,3,1
	}
	if(FileExist(pluginsFile))
		FileRead, pluginsVar, %pluginsFile%
	if(!FileExist(pluginsFile) || !pluginsVar){
		TrayTip,,RunAnyCtrl初始化生成导入规则函数%A_ScriptDir%\Lib\RunAnyCtrlPlugins.ahk,3,1
		content:=""
		commonAhk:="\Lib\rule_common.ahk"
		timeAhk:="\Lib\rule_time.ahk"
		if(FileExist(A_ScriptDir commonAhk)){
			content.="#Include *i %A_ScriptDir%" . commonAhk
		}
		if(FileExist(A_ScriptDir timeAhk)){
			content.="`n#Include *i %A_ScriptDir%" . timeAhk
		}
		FileAppend,%content%,%pluginsFile%
		Reload
	}
	gosub,Plugins_Read
return
;~ [规则插件内容]
Plugins_Read:
	global pluginsList:=Object()
	global pluginsContent:=""
	FileRead, pluginsContent, %pluginsFile%
	Loop, parse, pluginsContent, `n, `r
	{
		pluginsList[A_LoopField]:=1
	}
return
;~;[启动项数据]
Run_Item_Read:
	;参数列表：启动名+（启动路径；自动启动；隐藏启动；关闭启动；不重复启动；最多启动次数；最后运行时间；规则启动；规则逻辑；循环次数；循环间隔时间）
	global runitemList:=Object(),autorunList:=Object(),hiderunList:=Object(),closerunList:=Object(),repeatrunList:=Object(),mostrunList:=Object(),lasttimeList:=Object(),rulerunList:=Object(),rulelogicList:=Object(),rulenumberList:=Object(),ruletimeList:=Object()
	runitemVar:=autorunVar:=hiderunVar:=closerunVar:=repeatrunVar:=mostrunVar:=lasttimeVar:=rulerunVar:=rulelogicVar:=rulenumberVar:=ruletimeVar:=""
	IniRead,runitemVar,%iniFile%,run_item
	Loop, parse, runitemVar, `n, `r
	{
		itemList:=StrSplit(A_LoopField,"=")
		IniRead, OutputVar, %iniFile%, run_item,% itemList[1]
		runitemList[itemList[1]]:=OutputVar
	}
	IniRead,autorunVar,%iniFile%,auto_run_item
	Loop, parse, autorunVar, `n, `r
	{
		itemList:=StrSplit(A_LoopField,"=")
		autorunList[itemList[1]]:=itemList[2]
	}
	IniRead,hiderunVar,%iniFile%,hide_run_item
	Loop, parse, hiderunVar, `n, `r
	{
		itemList:=StrSplit(A_LoopField,"=")
		hiderunList[itemList[1]]:=itemList[2]
	}
	IniRead,closerunVar,%iniFile%,close_run_item
	Loop, parse, closerunVar, `n, `r
	{
		itemList:=StrSplit(A_LoopField,"=")
		closerunList[itemList[1]]:=itemList[2]
	}
	IniRead,repeatrunVar,%iniFile%,repeat_run_item
	Loop, parse, repeatrunVar, `n, `r
	{
		itemList:=StrSplit(A_LoopField,"=")
		repeatrunList[itemList[1]]:=itemList[2]
	}
	IniRead,mostrunVar,%iniFile%,most_run_item
	Loop, parse, mostrunVar, `n, `r
	{
		itemList:=StrSplit(A_LoopField,"=")
		mostrunList[itemList[1]]:=itemList[2]
	}
	IniRead,lasttimeVar,%iniFile%,last_run_time
	Loop, parse, lasttimeVar, `n, `r
	{
		itemList:=StrSplit(A_LoopField,"=")
		lasttimeList[itemList[1]]:=itemList[2]
	}
	IniRead,rulerunVar,%iniFile%,rule_run_item
	Loop, parse, rulerunVar, `n, `r
	{
		itemList:=StrSplit(A_LoopField,"=")
		rulerunList[itemList[1]]:=itemList[2]
	}
	IniRead,rulelogicVar,%iniFile%,rule_logic_item
	Loop, parse, rulelogicVar, `n, `r
	{
		itemList:=StrSplit(A_LoopField,"=")
		rulelogicList[itemList[1]]:=itemList[2]
	}
	IniRead,rulenumberVar,%iniFile%,rule_number_item
	Loop, parse, rulenumberVar, `n, `r
	{
		itemList:=StrSplit(A_LoopField,"=")
		rulenumberList[itemList[1]]:=itemList[2]
	}
	IniRead,ruletimeVar,%iniFile%,rule_time_item
	Loop, parse, ruletimeVar, `n, `r
	{
		itemList:=StrSplit(A_LoopField,"=")
		ruletimeList[itemList[1]]:=itemList[2]
	}
return
;~;[规则数据]
Rule_Item_Read:
	;规则名-脚本路径列表；规则名-函数名列表；规则名-状态列表；规则名-执行列表；每项启动项设置的规则内容
	global ruleitemList:=Object(),rulefuncList:=Object(),rulestatusList:=Object(),funccallList:=Object(),runruleitemList:=Object()
	global rulenameStr:=""
	ruleitemVar:=rulefuncVar:=""
	IniRead,ruleitemVar,%iniFile%,rule_item
	Loop, parse, ruleitemVar, `n, `r
	{
		itemList:=StrSplit(A_LoopField,"=")
		rulenameStr.=itemList[1] "|"
		IniRead, OutputVar, %iniFile%, rule_item,% itemList[1]
		ruleitemList[itemList[1]]:=OutputVar
		IniRead,rulefuncVar,%iniFile%,func_item,% itemList[1]
		rulefuncList[itemList[1]]:=rulefuncVar
		rulestatusList[itemList[1]]:=IsFunc(rulefuncVar) ? 1 : 0
		if(rulestatusList[itemList[1]]){
			funccallList[itemList[1]]:=Func(rulefuncVar)
		}
	}
	stringtrimright, rulenameStr, rulenameStr, 1
	;读取启动项设置的规则内容
	For runn, runv in runitemList
	{
		ruleArray:=Object()		;~规则内容队列
		IniRead,runRuleVar,%iniFile%,%runn%
		Loop, parse, runRuleVar, `n, `r
		{
			ruleObj:=Object(),ruleParamArray:=Object()	;~规则内容对象，规则参数队列
			ruleParamStr:=ruleParamTen:=""
			Loop, parse, A_LoopField, |
			{
				if(A_Index=1){
					ruleObj["ruleName"]:=A_LoopField
					continue
				}
				if(A_Index=2){
					ruleLogicStr:=A_LoopField
					if(InStr(A_LoopField, "*")){
						ruleObj["ruleBreak"]:=1
						StringReplace, ruleLogicStr, A_LoopField, *
					}
					ruleObj["ruleLogic"]:=ruleLogicStr
					continue
				}
				if(A_Index>=3 && A_Index<12){
					ruleParamStr.=A_LoopField . "|"
					ruleParamArray.Insert(A_LoopField)
					continue
				}
				if(A_Index>=12)
					ruleParamTen.=A_LoopField . "|"
			}
			;第十个参数及以上分隔参数，都归为第十参数
			if(ruleParamTen){
				stringtrimright, ruleParamTen, ruleParamTen, 1
				ruleParamStr.=ruleParamTen
				ruleParamArray.Insert(ruleParamTen)
			}else{
				stringtrimright, ruleParamStr, ruleParamStr, 1
			}
			ruleObj["ruleParamStr"]:=ruleParamStr
			ruleObj["ruleParam"]:=ruleParamArray
			ruleArray.Insert(ruleObj)
		}
		runruleitemList[runn]:=ruleArray
	}
return
;══════════════════════════════════════════════════════════════════════════════════════════════════════
;~;[托盘菜单]
;══════════════════════════════════════════════════════════════════════════════════════════════════════
MenuTray:
	Menu,Tray,NoStandard
	zzIcon:=A_ScriptDir "\Lib\RunAnyCtrl.ico"
	if(FileExist(zzIcon))
		Menu,Tray,Icon,%zzIcon%,1
	else
		Menu,Tray,Icon,%ahkExePath%,2
	Menu,Tray,add,启动管理(&Z),LV_Show
	Menu,Tray,add,修改配置(&E),LV_Ini
	Menu,Tray,add
	Menu,Tray,add,检查更新(&U),Github_Update
	Menu,Tray,add
	Menu,Tray,add,重启(&R),Menu_Reload
	Menu,Tray,add,挂起(&S),Menu_Suspend
	Menu,Tray,add,暂停(&A),Menu_Pause
	Menu,Tray,add,退出(&X),Menu_Exit
	Menu,Tray,Default,启动管理(&Z)
	Menu,Tray,Click,1
return
LV_Ini:
	Run,%iniFile%
return
Github_Update:
	if(!FileExist(A_ScriptDir "\" RunAnyCtrl "_Update.ahk")){
		RunAnyGithubDir:="https://raw.githubusercontent.com/hui-Zz/RunAnyCtrl/master"
		URLDownloadToFile, %RunAnyGithubDir%/%RunAnyCtrl%_Update.ahk, %A_ScriptDir%\%RunAnyCtrl%_Update.ahk
	}
	Run,%RunAnyCtrl%_Update.ahk
return
Menu_Reload:
	Reload
return
Menu_Suspend:
	Menu,tray,ToggleCheck,挂起(&S)
	Suspend
return
Menu_Pause:
	Menu,tray,ToggleCheck,暂停(&A)
	Pause
return
Menu_Exit:
	ExitApp
return
ExitSub:
	gosub,AutoClose_Effect
	ExitApp