/*
【RunAnyCtrl公共规则函数库】
*/
global rule_common_version:="1.3.4"
rule_true(){
	return true
}
rule_false(){
	return false
}
/*
【判断启动项当前是否已经运行】（RunAnyCtrl使用中，勿删慎改）
runNamePath 进程名或者启动项路径
*/
Check_IsRun(runNamePath){
	runValue:=RegExReplace(runNamePath,"iS)(.*?\.exe)($| .*)","$1")	;去掉参数
	SplitPath, runValue, name,, ext  ; 获取扩展名
	if(ext="ahk"){
		IfWinExist, %runNamePath% ahk_class AutoHotkey
		{
			return true
		}
	}else if(name){
		Process,Exist,%name%
		if ErrorLevel
			return true
	}
	return false
}
/*
【验证网络是否连接正常】
lpszUrl 网络测试网址，不传默认用百度做为测试站点
*/
rule_network(lpszUrl="http://www.baidu.com"){
	FLAG_ICC_FORCE_CONNECTION := 0x1
	dwReserved := 0x0
	return DllCall("Wininet.dll\InternetCheckConnection", "Ptr", &lpszUrl, "UInt", FLAG_ICC_FORCE_CONNECTION, "UInt", dwReserved, "Int")
}
/*
【验证当前连接的Wifi名称】（闪动命令框）
ssid wifi名称
*/
rule_wifi_twinkle(ssid){
	cmdResult:=cmdReturn("netsh wlan show interface | findstr ""`\<SSID""")
	return RegExMatch(cmdResult, "\s*SSID\s*:\s" . ssid . "$") ? true : false
}
/*
【验证当前连接的Wifi名称】（后台静默）
ssid wifi名称
*/
rule_wifi_silence(ssid){
	cmdResult:=cmdSilenceReturn("netsh wlan show interface | findstr ""`\<SSID""")
	return RegExMatch(cmdResult, "\s*SSID\s*:\s" . ssid . "$") ? true : false
}
/*
【验证当前电脑名称】
name 电脑名
*/
rule_computer_name(name){
	return A_ComputerName=name ? true : false
}
