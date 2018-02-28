rule_true(){
	return true
}
rule_false(){
	return false
}
/*
验证网络是否连接正常，默认用百度做为测试站点
*/
rule_network(lpszUrl="http://www.baidu.com"){
	FLAG_ICC_FORCE_CONNECTION := 0x1
	dwReserved := 0x0
	return DllCall("Wininet.dll\InternetCheckConnection", "Ptr", &lpszUrl, "UInt", FLAG_ICC_FORCE_CONNECTION, "UInt", dwReserved, "Int")
}
/*
验证当前电脑名称
*/
rule_computer_name(name){
	return A_ComputerName=name ? true : false
}
