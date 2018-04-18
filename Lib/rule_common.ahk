/*
【RunAnyCtrl公共规则函数库】
*/
global rule_common_version:="1.4.18"
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
rule_IsRun(runNamePath){
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
	cmdResult:=IsFunc("cmdReturn") ? Func("cmdReturn").Call("netsh wlan show interface | findstr ""`\<SSID""") : ""
	return RegExMatch(cmdResult, "\s*SSID\s*:\s" . ssid . "$") ? true : false
}
/*
【验证当前连接的Wifi名称】（后台静默）
ssid wifi名称
*/
rule_wifi_silence(ssid){
	cmdResult:=IsFunc("cmdSilenceReturn") ? Func("cmdSilenceReturn").Call("netsh wlan show interface | findstr ""`\<SSID""") : ""
	return RegExMatch(cmdResult, "\s*SSID\s*:\s" . ssid . "$") ? true : false
}
/*
【验证当前电脑名称】
name 电脑名
*/
rule_computer_name(name){
	return A_ComputerName=name ? true : false
}
/*
【验证当前登录用户名称】
name 用户名
*/
rule_user_name(name){
	return A_UserName=name ? true : false
}
/*
【验证当前登录用户有管理员权限】
*/
rule_user_is_admin(){
	return A_IsAdmin=1 ? true : false
}
/*
【验证当前windows系统版本】
version 如：WIN_7, WIN_8, WIN_VISTA, WIN_2003, WIN_XP, WIN_2000, Windows10版本为具体的版本号数字
*/
rule_system_version(version){
	return A_OSVersion=version ? true : false
}
/*
【验证当前当操作系统为64位】
*/
rule_system_is_64bit(){
	return A_Is64bitOS=1 ? true : false
}
/*
验证当前内网ip地址 @hui-Zz
ip 验证的ip（模糊匹配）
*/
rule_ip_internal(ip=""){
	if(!ip)
		return false
	cmdResult:=IsFunc("cmdSilenceReturn") ? Func("cmdSilenceReturn").Call("for /f ""tokens=4"" %%a in ('route print^|findstr 0.0.0.0.*0.0.0.0') do echo %%a") : ""
	return InStr(cmdResult,ip) ? true : false
}
/*
验证当前外网ip地址 @hui-Zz
ip 验证的ip（模糊匹配）
*/
rule_ip_external(ip=""){
	if(!ip)
		return false
	jsonData:=IsFunc("get_ip_api") ? Func("get_ip_api").Call() : ""
	if(!jsonData)
		return false
	return InStr(jsonData.query,ip) ? true : false
}
/*
验证当前ip地址定位的省市地址 @hui-Zz
city 验证的城市名
regionName 验证的省名
*/
rule_ip_address(city="",regionName=""){
	rule_result:=false
	jsonData:=IsFunc("get_ip_api") ? Func("get_ip_api").Call() : ""
	if(!jsonData)
		return false
	if(city && regionName){
		if(jsonData.city=city && jsonData.regionName=regionName){
			return true
		}
	}else{
		if(city){
			rule_result:=jsonData.city=city ? true : false
		}
		if(regionName){
			rule_result:=jsonData.regionName=regionName ? true : false
		}
	}
	return rule_result
}
/*
验证当前网络运营商 @hui-Zz
isp 验证的运营商名，如中国电信：China Telecom
*/
rule_ip_isp(isp=""){
	if(!isp)
		return false
	jsonData:=IsFunc("get_ip_api") ? Func("get_ip_api").Call() : ""
	if(!jsonData)
		return false
	return InStr(jsonData.isp,isp) ? true : false
}