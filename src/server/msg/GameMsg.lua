module("server", package.seeall)

SystemTimer = caseclass("SystemTimer", "m30000", "infoList")


--------------build-------------------
BuildTimer = caseclass("BuildTimer", "m30000", "cn", "cmd", "obj", "powerlist") --建筑定时器


SystemTimer = caseclass("SystemTimer", "m30000", "infoList")

BuildInfo = caseclass("BuildInfo", "infos") --建筑信息
--------------------------------

SendTimer = caseclass("SendTimer") --发送30000