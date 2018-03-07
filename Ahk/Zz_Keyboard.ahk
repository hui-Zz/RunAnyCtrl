#NoEnv                  ;~不检查空变量为环境变量
#NoTrayIcon             ;~不显示托盘图标
#WinActivateForce       ;~强制激活窗口
#SingleInstance,Force   ;~运行替换旧实例
ListLines,Off           ;~不显示最近执行的脚本行
SendMode,Input          ;~使用更速度和可靠方式发送键鼠点击
SetBatchLines,-1        ;~脚本全速执行(默认10ms)
SetControlDelay,0       ;~控件修改命令自动延时(默认20)
SetTitleMatchMode,2     ;~窗口标题模糊匹配
CoordMode,Menu,Window   ;~坐标相对活动窗口
SetWorkingDir,%A_ScriptDir% ;~脚本当前工作目录
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
SetTimer,Rest_Time,2700000	;45分钟
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#Include *i %A_ScriptDir%\Zz_Window.ahk
#Include *i %A_ScriptDir%\Zz_key_vim.ahk
#Include *i %A_ScriptDir%\Zz_MButton.ahk
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
AskTime(ask){
	ToolTip,【%ask%!】,A_ScreenWidth/2-105,0
	Speak(ask)
}
Speak(say){
	spovice:=ComObjCreate("sapi.spvoice")
	spovice.Speak(say)
}
Rest_Time:
	CoordMode,ToolTip
	If(A_Hour=9 && A_Min<30)
		AskTime("早上好")
	Else If(A_Hour=12 && A_Min<30)
		AskTime("中午午休……")
	Else If(A_Hour>=0 && A_Hour<=6)
		ToolTip,【明天不想起床？】,A_ScreenWidth/2-105,0
	;~ Else
		;~ Speak("休息一下吧")
		;~ ToolTip,【起来走走`|休息眼睛`|注意喝水】,A_ScreenWidth/2-105,0
	SetTimer,RemoveToolTip,30000
	return
RemoveToolTip:
	SetTimer,RemoveToolTip,Off
	ToolTip
	return