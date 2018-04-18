/*
【RunAnyCtrl特殊函数调用库】
*/
global RunAnyCtrlFunc_version:="1.4.9"
/*
【自动识别AHK脚本中的函数 by hui-Zz】（RunAnyCtrl使用中，勿删慎改）
ahkPath AHK脚本路径
return AHK脚本所有函数用|分隔的字符串,没有返回""
*/
getAhkFuncZz(ahkPath){
	funcName:=funcnameStr:=""
	StringReplace, checkPath, ahkPath,`%A_ScriptDir`%, %A_ScriptDir%
	if(FileExist(checkPath)){
		funcIndex:=0
		getFuncNameReg:="iS)^\t*\s*(?!if)([^\s\.,:=\(]*)\(.*?\)\t*\s*"
		getFuncNameReg1:=getFuncNameReg . "\{"
		getFuncNameReg2:=getFuncNameReg . "$"
		Loop, read, %checkPath%
		{
			if(RegExMatch(A_LoopReadLine,getFuncNameReg1)){
				funcnameStr.=RegExReplace(A_LoopReadLine,getFuncNameReg1,"$1") . "|"
			}
			if(funcName && A_Index=funcIndex && RegExMatch(A_LoopReadLine,"^\t*\s*\{\t*\s*$")){
				funcnameStr.=funcName . "|"
			}
			if(RegExMatch(A_LoopReadLine,getFuncNameReg2)){
				funcName:=RegExReplace(A_LoopReadLine,getFuncNameReg2,"$1")
				funcIndex:=A_Index+1
			}
		}
		stringtrimright, funcnameStr, funcnameStr, 1
	}
	return funcnameStr
}
/*
【返回cmd命令的结果值 @hui-Zz】
*/
cmdReturn(command){
    ; WshShell 对象: http://msdn.microsoft.com/en-us/library/aew9yb99
    shell := ComObjCreate("WScript.Shell")
    ; 通过 cmd.exe 执行单条命令
    exec := shell.Exec(ComSpec " /C " command)
    ; 读取并返回命令的输出
    return exec.StdOut.ReadAll()
}
/*
【缓存到批处理中后台静默运行cmd命令，并用缓存文本取到结果值 @hui-Zz】
*/
cmdSilenceReturn(command){
	CMDReturn:=""
	try{
		wifiBat:=command . " >> %Temp%\RunAnyCtrlCMD.txt"
		FileAppend,%wifiBat%,%A_Temp%\RunAnyCtrlCMD.bat
		shell := ComObjCreate("WScript.Shell")
		shell.run("%Temp%\RunAnyCtrlCMD.bat",0)
		Loop,100
		{
			FileRead, CMDReturn, %A_Temp%\RunAnyCtrlCMD.txt
			if(CMDReturn)
				break
			Sleep,20
		}
		FileDelete,%A_Temp%\RunAnyCtrlCMD.bat
		FileDelete,%A_Temp%\RunAnyCtrlCMD.txt
	}catch{}
	return CMDReturn
}
/*
通过第三方接口获取IP地址等信息 @hui-Zz
query、country、countryCode、regionName、region、city、lat、lon、timezone、isp
外网ip、国家、国家代码、地区、地区代码、城市、纬度、经度、时区、运营商
*/
get_ip_api(){
	if(!IsObject(JSON))
		return false
	;~ 测试网络连接
	lpszUrl:="http://www.ip-api.com"
	network:=DllCall("Wininet.dll\InternetCheckConnection", "Ptr", &lpszUrl, "UInt", 0x1, "UInt", 0x0, "Int")
	if(!network)
		return false
	apiUrl=http://ip-api.com/json
	sendStr:=apiUrl
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", sendStr)
	try {
		whr.Send()
	} catch {
		TrayTip,,验证IP地址异常，可能是网络已断开或接口失效,3,1
	}
	responseStr:= whr.ResponseText
	if(responseStr)
		jsonData:=JSON.Load(responseStr)
	return jsonData
}