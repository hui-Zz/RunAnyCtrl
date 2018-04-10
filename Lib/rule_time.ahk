/*
【RunAnyCtrl时间规则函数库】
*/
global rule_time_version:="1.4.10"
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
	today:=today ? today : A_YYYY A_MM A_DD
	apiUrl=http://www.easybots.cn/api/holiday.php?d=
	sendStr:=apiUrl . today
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", sendStr)
	try {
		whr.Send()
	} catch {
		TrayTip,,验证节假日异常，可能是网络已断开或接口失效,3,1
	}
	responseStr:= whr.ResponseText
	dayStatus:=responseStr ? SubStr(responseStr, -2 , 1) : 0
	return dayStatus=0 ? false : true
}
