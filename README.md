# 【RunAnyCtrl】一劳永逸的规则启动控制器 v1.3.5

设定足够灵活的规则，在不同的使用场景下自动智能地启动不同的软件和应用，这是我开发这个软件的初衷😁

**RunAnyCtrl跟OneDrive之类同步网盘搭配更佳，让你公司和家里的电脑都随你心意！**


同时RunAnyCtrl也可以做为一个AHK脚本的集中管理器

> （RunAnyCtrl是AHK脚本，需要先在系统中安装AutoHotkey软件，才能启动，下载地址：[https://autohotkey.com](https://autohotkey.com) ）

---

## RunAnyCtrl使用说明

![RunAnyCtrl使用说明](https://raw.githubusercontent.com/hui-Zz/RunAnyCtrl/master/RunAnyCtrl使用说明.png)

---
## RunAnyCtrl现有规则表

| 公共规则                                                  | 时间规则                 |      |
| :-------------------------------------------------------- | ------------------------ | ---- |
| 无条件真和假<br />用于循环执行等特殊情况                  | 验证星期几(1-7)          |      |
| 判断启动项当前是否已经运行                                | 验证指定时间点（小时）   |      |
| 验证网络是否连接正常                                      | 通过第三方接口验证节假日 |      |
| 验证当前连接的Wifi名称<br />（命令执行，会闪一下命令框）  |                          |      |
| 验证当前连接的Wifi名称<br />（后台静默写入bat执行后删除） |                          |      |
| 验证当前电脑名称                                          |                          |      |
| 验证当前登录用户名称                                      |                          |      |
| 验证当前登录用户有管理员权限                              |                          |      |
| 验证当前windows系统版本                                   |                          |      |
| 验证当前当操作系统为64位                                  |                          |      |

配置文件，可以复制粘贴到对应的规则路径和规则函数中：

```ini
;规则名=规则路径
[rule_item]
真=%A_ScriptDir%\Lib\rule_common.ahk
电脑名=%A_ScriptDir%\Lib\rule_common.ahk
WiFi名(静默)=%A_ScriptDir%\Lib\rule_common.ahk
WiFi名(闪动)=%A_ScriptDir%\Lib\rule_common.ahk
网络连接=%A_ScriptDir%\Lib\rule_common.ahk
运行状态=%A_ScriptDir%\Lib\rule_common.ahk
时间点=%A_ScriptDir%\Lib\rule_time.ahk
星期几=%A_ScriptDir%\Lib\rule_time.ahk
节假日=%A_ScriptDir%\Lib\rule_time.ahk
用户名=%A_ScriptDir%\Lib\rule_common.ahk
用户管理员权限=%A_ScriptDir%\Lib\rule_common.ahk
系统版本=%A_ScriptDir%\Lib\rule_common.ahk
系统64位=%A_ScriptDir%\Lib\rule_common.ahk

;规则名=规则函数
[func_item]
真=rule_true
电脑名=rule_computer_name
WiFi名(静默)=rule_wifi_silence
WiFi名(闪动)=rule_wifi_twinkle
网络连接=rule_network
运行状态=rule_IsRun
时间点=rule_today_hour
星期几=rule_today_week
节假日=rule_holiday
用户名=rule_user_name
用户管理员权限=rule_user_is_admin
系统版本=rule_system_version
系统64位=rule_system_is_64bit
```

---


**你的支持是我最大的动力！金额随意**

![支付宝](https://raw.githubusercontent.com/hui-Zz/RunAny/master/支持RunAny.jpg)
