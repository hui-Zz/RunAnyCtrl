/*
【RunAnyCtrl特殊函数调用库】
*/
global RunAnyCtrlFunc_version:="2.5.1"
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
【绝对路径转换为相对路径 by hui-Zz】
fPath 被转换的全路径，可带文件名
ahkPath 相对参照的执行脚本完整全路径，带文件名
return -1 路径参数有误
return -2 被转换路径和参照路径不在同一磁盘，不能转换
*/
funcPath2RelativeZz(fPath,ahkPath){
	SplitPath, fPath, fname, fdir, fext, , fdrive
	SplitPath, ahkPath, name, dir, ext, , drive
	if(!fPath || !ahkPath || !dir || !fdir || !fdrive)
		return -1
	if(fdrive!=drive){
		return -2
	}
	;下级目录直接去掉参照目录路径
	if(InStr(fPath,dir)){
		filePath:=StrReplace(fPath,dir)
		StringTrimLeft, filePath, filePath, 1
		return filePath
	}
	;上级目录根据层级递进添加多级前缀..\
	pathList:=StrSplit(dir,"\")
	Loop,% pathList.MaxIndex()
	{
		pathStr:=""
		upperStr:=""
		;每次向上递进，找到与启动项相匹配路径段替换成..\
		Loop,% pathList.MaxIndex()-A_Index
		{
			pathStr.=pathList[A_Index] . "\"
		}
		StringTrimRight, pathStr, pathStr, 1
		if(InStr(fdir,pathStr)){
			Loop,% A_Index
			{
				upperStr.="..\"
			}
			StringTrimRight, upperStr, upperStr, 1
			filePath:=StrReplace(fPath,pathStr,upperStr)
			return filePath
		}
	}
	return false
}
/*
【相对路径转换为绝对路径 by hui-Zz】
aPath 被转换的相对路径，可带文件名
ahkPath 相对参照的执行脚本完整全路径，带文件名
return -1 路径参数有误
*/
funcPath2AbsoluteZz(aPath,ahkPath){
	SplitPath, aPath, fname, fdir, fext, , fdrive
	SplitPath, ahkPath, name, dir, ext, , drive
	if(!aPath || !ahkPath)
		return -1
	;下级目录直接加上参照目录路径
	if(!fdrive && !InStr(aPath,"..")){
		return dir . "\" . aPath
	}
	pathList:=StrSplit(dir,"\")
	;上级目录根据层级递进添加多级路径
	if(InStr(aPath,"..\")=1){
		aPathStr:=RegExReplace(aPath, "\.\.\\", , PointCount)
		pathStr:=""
		;每次向上递进，找到添加与启动项相匹配路径段
		Loop,% pathList.MaxIndex()-PointCount
		{
			pathStr.=pathList[A_Index] . "\"
		}
		filePath:=pathStr . aPathStr
		return filePath
	}
	return false
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
【后台静默运行cmd命令缓存文本取值 @hui-Zz】
*/
cmdSilenceReturn(command){
	CMDReturn:=""
	cmdFN:="RunAnyCtrlCMD"
	try{
		RunWait,% ComSpec " /C " command " > ""%Temp%\" cmdFN ".log""",, Hide
		FileRead, CMDReturn, %A_Temp%\%cmdFN%.log
		FileDelete,%A_Temp%\%cmdFN%.log
	}catch{}
	return CMDReturn
}
/*
【隐藏运行cmd命令并将结果存入剪贴板后取回 @hui-Zz】
*/
cmdClipReturn(command){
	cmdInfo:=""
	Clip_Saved:=ClipboardAll
	try{
		Clipboard:=""
		Run,% ComSpec " /C " command " | CLIP", , Hide
		ClipWait,2
		cmdInfo:=Clipboard
	}catch{}
	Clipboard:=Clip_Saved
	return cmdInfo
}
/*
【StdoutToVar不弹窗不缓存取cmd命令结果】
*/
StdoutToVar_CreateProcess(sCmd, sEncoding:="CP0", sDir:="", ByRef nExitCode:=0) {
    DllCall( "CreatePipe",           PtrP,hStdOutRd, PtrP,hStdOutWr, Ptr,0, UInt,0 )
    DllCall( "SetHandleInformation", Ptr,hStdOutWr, UInt,1, UInt,1                 )
 
            VarSetCapacity( pi, (A_PtrSize == 4) ? 16 : 24,  0 )
    siSz := VarSetCapacity( si, (A_PtrSize == 4) ? 68 : 104, 0 )
    NumPut( siSz,      si,  0,                          "UInt" )
    NumPut( 0x100,     si,  (A_PtrSize == 4) ? 44 : 60, "UInt" )
    NumPut( hStdInRd,  si,  (A_PtrSize == 4) ? 56 : 80, "Ptr"  )
    NumPut( hStdOutWr, si,  (A_PtrSize == 4) ? 60 : 88, "Ptr"  )
    NumPut( hStdOutWr, si,  (A_PtrSize == 4) ? 64 : 96, "Ptr"  )
 
    If ( !DllCall( "CreateProcess", Ptr,0, Ptr,&sCmd, Ptr,0, Ptr,0, Int,True, UInt,0x08000000
                                  , Ptr,0, Ptr,sDir?&sDir:0, Ptr,&si, Ptr,&pi ) )
        Return ""
      , DllCall( "CloseHandle", Ptr,hStdOutWr )
      , DllCall( "CloseHandle", Ptr,hStdOutRd )
 
    DllCall( "CloseHandle", Ptr,hStdOutWr ) ; The write pipe must be closed before reading the stdout.
    VarSetCapacity(sTemp, 4095)
    While ( DllCall( "ReadFile", Ptr,hStdOutRd, Ptr,&sTemp, UInt,4095, PtrP,nSize, Ptr,0 ) )
        sOutput .= StrGet(&sTemp, nSize, sEncoding)
 
    DllCall( "GetExitCodeProcess", Ptr,NumGet(pi,0), UIntP,nExitCode )
    DllCall( "CloseHandle",        Ptr,NumGet(pi,0)                  )
    DllCall( "CloseHandle",        Ptr,NumGet(pi,A_PtrSize)          )
    DllCall( "CloseHandle",        Ptr,hStdOutRd                     )
    Return sOutput
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