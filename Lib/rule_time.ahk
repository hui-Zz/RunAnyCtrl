/*
【RunAnyCtrl时间规则函数库】
*/
global rule_time_version:="1.3.4"
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