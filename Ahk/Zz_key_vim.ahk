;**************************
;*  左Alt键搭配的Vim热键  *
;*          by hui-Zz     *
;**************************
#NoEnv                  ;~不检查空变量为环境变量
#NoTrayIcon             ;~不显示托盘图标
#SingleInstance,Force   ;~运行替换旧实例
ListLines,Off           ;~不显示最近执行的脚本行
SendMode,Input          ;~使用更速度和可靠方式发送键鼠点击
SetBatchLines,-1        ;~脚本全速执行(默认10ms)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
<!j::SendInput,{Down}		;~ 方向↓
<!k::SendInput,{Up}		;~ 方向↑
<!h::SendInput,{Left}		;~ 方向←
<!l::SendInput,{Right}		;~ 方向→
<!n::SendInput,^{Left}		;~ 跳转左边单词
<!m::SendInput,^{Right}	;~ 跳转右边单词
<!,::SendInput,{Home}		;~ 跳转行首
<!.::SendInput,{End}		;~ 跳转行末
<!u::SendInput,^{End}		;~ 跳转顶部
<!i::SendInput,^{Home}		;~ 跳转底部
;~ <!+j::SendInput,+{Down}	;~ 向↓选中
<!+k::SendInput,+{Up}		;~ 向↑选中
<!+h::SendInput,+{Left}	;~ 向←选中
<!+l::SendInput,+{Right}	;~ 向→选中
<!+n::SendInput,^+{Left}	;~ 跳转选中左边单词
<!+m::SendInput,^+{Right}	;~ 跳转选中右边单词

<!+,::
	SendInput,+{Home}	;~ 跳转选中到行首
	SendInput,^c
	return
<!+.::
	SendInput,+{End}	;~ 跳转选中到行末
	SendInput,^c
	return
<!+u::
	SendInput,^+{End}	;~ 跳转选中顶部
	SendInput,^c
	return
<!+i::
	SendInput,^+{Home}	;~ 跳转选中底部
	SendInput,^c
	return
<!g::
	KeyWait,g
	Keywait,g,d,t0.2
	If Errorlevel
		SendInput,^{Home} ;~ 跳转顶部
	Else
		SendInput,^{End} ;~跳转底部
	Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CapsLock & d::MouseClick,WD,,,2		;~上滚
CapsLock & e::MouseClick,WU,,,2		;~下滚
CapsLock & s::
	ControlGetFocus,zFocus,A
	Loop 5
		SendMessage,0x114,0,0,%zFocus%,A
	return
CapsLock & f::
	ControlGetFocus,zFocus,A
	Loop 5
		SendMessage,0x114,1,0,%zFocus%,A
	return
CapsLock & g::
	KeyWait,g
	Keywait,g,d,t0.2
	If Errorlevel
		SendInput,^{Home} ;~ 跳转顶部
	Else
		SendInput,^{End} ;~跳转底部
	Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
