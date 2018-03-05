/*
【RunAnyCtrl特殊函数调用库】
*/
global RunAnyCtrlFunc_version:="1.3.5"
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
	wifiBat:=command . " >> %Temp%\RunAnyCtrlCMD.txt"
	FileAppend,%wifiBat%,%A_Temp%\RunAnyCtrlCMD.bat
	CMDReturn:=""
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
	return CMDReturn
}