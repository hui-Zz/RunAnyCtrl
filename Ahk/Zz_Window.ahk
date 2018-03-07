;**************************
;*    窗口快捷操作脚本    *
;*          by hui-Zz     *
;**************************
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
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
;~ +LWin::Reload
PrintScreen::return
<+Space::SendInput,{Enter} ;<--回车
LCtrl & CapsLock::SendInput,^+{Tab} ;~激活上个标签
LShift & CapsLock::SendInput,{Delete} ;<--删除
CapsLock & Tab::SendInput,{BackSpace} ;<--退格删除
LAlt::
	KeyWait,LAlt
	KeyWait,LAlt,d,t0.2
	if !Errorlevel
		SendInput,!{Enter} ;<--属性
	return
LWin & RButton:: ;<--重置窗口
	WinGetActiveStats,zTitle,var_width,var_height,var_x,var_y
	WinMove,%zTitle%,,(A_ScreenWidth-var_width)/2,(A_ScreenHeight-var_height)/2+15,var_width,var_height
	return
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
LWin & WheelUp::ChangeTransparency("increase",30) ;<--每次增加不透明
LWin & WheelDown::ChangeTransparency("decrease",30) ;<--每次减低不透明
ChangeTransparency(flag = "increase",amount = 10)
{
	WinGetTitle, ActiveTitle, A
	static t = 255
	If(flag == "increase")
		tmp := t + amount
	else if(flag == "decrease")
		tmp := t - amount
	If(tmp > 255)
		tmp = 255
	else if(tmp < 0)
		tmp = 0
	WinSet,Transparent,%tmp%,%ActiveTitle%
	ToolTip,当前透明度:%tmp%
	Sleep,1000
	ToolTip
	t := tmp
}
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
LWin & F1:: ;<--窗口置顶
	WinSet,AlwaysOnTop,Toggle,A
	ToolTip,切换窗口置顶
	Sleep,500
	ToolTip
	return
+LWin:: ;<--窗口置顶并设置透明
	Suspend,Permit
	WinGet, temp, ExStyle, A
	if(temp & 0x8){  ; 0x8 表示 WS_EX_TOPMOST.
		;这个分支是当前激活窗口是置顶窗口
		SetTimer, transparEnter, Off ;关闭时钟
		WinSet,AlwaysOnTop,off, A ;关闭置顶
		;关闭窗口置顶后取消窗口透明
		WinSet, Transparent, 255, A ;帮助中说,先设置255会让透明关闭的比较稳定
		WinSet, Transparent, off, A
	}else{
		;这个分支是当前激活窗口不是置顶窗口,这时什么也不做
		WinSet,AlwaysOnTop,on,A  ;开启置顶
		SetTimer, transparEnter, 250
		;global nhwnd
		MouseGetPos, , , nhwnd
	}
	return
transparEnter: ;当前置顶窗口执行透明子程序
	WinGet, temp, ExStyle, A ;获取当前激活窗口是否置顶状态
	if(temp & 0x8){  ; 0x8 表示 WS_EX_TOPMOST.
		;这个分支是当前激活窗口是置顶窗口,如果当前置顶窗口获取焦点了则取消透明
		WinGet, TransparEnter, Transparent, A
		if(TransparEnter <> 255){
			WinSet, Transparent, 255, A
		}
	}else{
		;这个分支是当前激活窗口不是置顶窗口,这时设置置顶的那个窗口透明
		WinSet, Transparent, 128,ahk_id %nhwnd%
		;MsgBox,%nhwnd%
	}
	return
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
LWin & F3:: ;<--切换显示标题栏
	WinSet,Style,^0xC00000,A
	WinSet,Style,^0×40000,A
	return
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
LWin & F4:: ;智能隐藏标题栏
	MouseGetPos,,,wh
	WinGet,zW,MinMax,ahk_id %wh%
	if zW=1
	{
		WinRestore,ahk_id %wh%
		WinSet,Style,+0xC00000,ahk_id %wh%
	}else{
		WinMaximize,ahk_id %wh%
		WinSet,Style,-0xC00000,ahk_id %wh%
	}
	return
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
LWin & 1::win_Size_Zz(A_ScreenWidth*0.5,A_ScreenHeight*0.5)
LWin & 2::win_Size_Zz(A_ScreenWidth*0.5,A_ScreenHeight*0.7)
LWin & 3::win_Size_Zz(A_ScreenWidth*0.8,A_ScreenHeight*0.8)
LWin & 4::win_Size_Zz(A_ScreenWidth*0.8,A_ScreenHeight*0.9)
LWin & 7::win_Size_Zz(A_ScreenWidth*0.3,A_ScreenHeight*0.3)
LWin & 9::win_Size_Zz(650,384)
LWin & 0::win_Size_Zz(340,200)
win_Size_Zz(var_width,var_height){
	WinMove,A,,,,%var_width%,%var_height%
}