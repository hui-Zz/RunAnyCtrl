/*
【RunAnyCtrl时间规则函数库】
*/
global rule_time_version:="1.4.17"
/*
验证星期几(1-7)，1表示星期天 @hui-Zz
*/
rule_today_week(week){
	return A_WDay=week ? true : false
}
/*
验证指定时间点（小时） @hui-Zz
*/
rule_today_hour(hour, operator=""){
	if hour is number
	{
		if(operator){
			if(operator=">="){
				if(A_Hour>=hour){
					return true
				}
			}
			if(operator="<="){
				if(A_Hour<=hour){
					return true
				}
			}
			if(operator=">"){
				if(A_Hour>hour){
					return true
				}
			}
			if(operator="<"){
				if(A_Hour<hour){
					return true
				}
			}
		}else{
			if(A_Hour=hour){
				return true
			}
		}
	}
	return false
}
/*
通过第三方接口验证节假日 @hui-Zz
*/
rule_holiday(today=""){
	;~ 测试网络连接
	lpszUrl:="http://api.goseek.cn"
	network:=DllCall("Wininet.dll\InternetCheckConnection", "Ptr", &lpszUrl, "UInt", 0x1, "UInt", 0x0, "Int")
	if(!network)
		return false
	today:=today ? today : A_YYYY A_MM A_DD
	apiUrl=http://api.goseek.cn/Tools/holiday?date=
	sendStr:=apiUrl . today
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", sendStr)
	try {
		whr.Send()
	} catch {
		TrayTip,,验证节假日异常，可能是网络已断开或接口失效,3,1
	}
	responseStr:= whr.ResponseText
	dayStatus:=responseStr ? SubStr(responseStr, -1 , 1) : 0
	return dayStatus=0 ? false : true
}
