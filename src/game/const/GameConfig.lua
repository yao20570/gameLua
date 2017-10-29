GameConfig = {}

-- local mt = {}
-- mt.__index = function(table, key)
--     local value = rawget(table, key)
--     if key == "serverTime" then
-- --        return server.TimerDefine.triggerTime
--         return os.time()
--     end
--     return value
-- end
-- mt.__newindex = function(table, key, value)
--     if key ~= "serverTime" then
--         rawset(table,key,value)
--     end
-- end
-- setmetatable(GameConfig, mt)

GameConfig.server = ""
GameConfig.port = 8080
GameConfig.accountName = ""
GameConfig.sceneAccountName = "" --在场景里登录的账号名，用来缓存做判断，进入场景后需要置空
GameConfig.serverName = "" --服务器名字
GameConfig.serverArea = "" --服务器区，服务器区 对应server_no
GameConfig.serverId = "" --服务器唯一ID 后台以这个为准
GameConfig.serverState = 1 --服务器状态
GameConfig.isPre = false  --服务器是否为预览版
GameConfig.actorid = "00000000"
GameConfig.actorName = ""
GameConfig.level = 0 --玩家的等级
GameConfig.vipLevel = 0
GameConfig.serverTime = os.time() --服务器时间，一段时间后，通过心跳包 去同步时间
GameConfig.roleCreateTime = 0 --角色创建时间 
GameConfig.isRelogin = false --是否重登 场景切换账号用
GameConfig.isInGateQueue = false --是否在排队中，如果在场景排队则，不做心跳断开
GameConfig.isServerFull = false --是否服务器满人

GameConfig.lastTouchTime = os.time() --最后一次触摸的时间
GameConfig.maxRecorderTime = 15 --最大的录音时间

GameConfig.curSendNetNum = 0 --发送协议的条数

--
GameConfig.is_request = true  --是否要发送注册统计
GameConfig.startGameTime = 0 --开始游戏的时间
GameConfig.showLoginViewTime = 0 --登录界面显示的时间
GameConfig.registerOverTime = 0 --平台信息回调时间
--

GameConfig.lastHeartbeatTime = os.time() --最后的心跳时间
GameConfig.enterBackgroundTime = nil --回到后台时间

GameConfig.web_server = "119.29.11.150"
--GameConfig.web_server = "192.168.31.190" --内网PHP
GameConfig.web_port = 80

GameConfig.targetPlatform = cc.Application:getInstance():getTargetPlatform()
function GameConfig:isIOS()
    local targetPlatform = self.targetPlatform
    if cc.PLATFORM_OS_IPHONE == targetPlatform or 
        cc.PLATFORM_OS_IPAD == targetPlatform then
        return true
    end
    return false
end
GameConfig.osName = "" --系统名称

GameConfig.frameRate = 60
GameConfig.frequency = 1 / GameConfig.frameRate --1帧多少秒
GameConfig.isLoginSucess = false
GameConfig.isOtherLogin = false
--GameConfig.server = "192.168.31.120"
--GameConfig.port = 10000
GameConfig.count = 0
GameConfig.debug = false 
GameConfig.isConnected = false --是否已经连网了

GameConfig.version = "0.0"
GameConfig.clientVersion = "0.0"
GameConfig.mainVersion = require("version")  --主版本

GameConfig.packageInfo = 1 --安装包类型 1 A包，内部测试包 ；2 B包 android正式包，正式包  3测试包 4版署包 5ios包正式包

GameConfig.newApkURL = "http://119.29.63.155/dou/apk/kkk/myWorld.apk"

GameConfig.local_admincenter_api_url = "http://192.168.10.138:8001/gcol/" --本地中央服接口
GameConfig.admincenter_api_url = "http://center.znlgame.com:8888/gcol/"  --中央接口服
GameConfig.version_head_url = GameConfig.admincenter_api_url .. "version/platform/"
--GameConfig.cdn_host_url = "http://download.5aiyoo.com/wk/"

GameConfig.server_list_url = GameConfig.admincenter_api_url .. "get_test_slg_server_list.php"
GameConfig.real_name_url = GameConfig.admincenter_api_url  -----实名验证地址

GameConfig.client_activate_url = GameConfig.admincenter_api_url  --客户端激活地址

GameConfig.isTest = 2 --是否为测试包 1测试 2正式 3运营

GameConfig.phoneVersionUrl = "" --从外部传过来的版本地址，主要可以用来测试正式包的热更、分包问题

function GameConfig:setPackageInfo(packageInfo)
    self.packageInfo = packageInfo
    if self.packageInfo == 1 then
        self.cdn_host = self.version_head_url .. "testModule/"  --cdn更新路径
        self.server_list_url = self.admincenter_api_url .. ""
        GameConfig.isTest = 1
    elseif self.packageInfo == 3 then
        self.cdn_host = self.version_head_url .. "test/"  --cdn更新路径
        self.server_list_url = self.admincenter_api_url .. ""
        GameConfig.isTest = 1
    elseif self.packageInfo == 4 then --版署服，直接写死 url内容不会变
        self.cdn_host = self.version_head_url .. "department/"  --cdn更新路径
        self.server_list_url = self.admincenter_api_url .. "version/get_server_list.php"
    elseif self.packageInfo == 5 then --ios正式包
        self.cdn_host = self.version_head_url .. "ios/"  --cdn更新路径
        self.server_list_url = self.admincenter_api_url .. ""
        GameConfig.get_version_info_path = GameConfig.admincenter_api_url .. "get_version_ios_info.php"
    elseif self.packageInfo == 7 then --ios正式包
        self.cdn_host = self.version_head_url .. "testIOS/"  --cdn更新路径
        self.server_list_url = self.admincenter_api_url .. ""
        GameConfig.get_version_info_path = GameConfig.admincenter_api_url .. "get_version_ios_info.php"
    elseif self.packageInfo == 6 then --android审核包
        self.cdn_host = self.version_head_url .. "audit/"  --cdn更新路径
        self.server_list_url = self.admincenter_api_url .. ""
    elseif self.packageInfo == -1 then --win
        self.cdn_host = GameConfig.local_admincenter_api_url .. "version/platform/" .. "win/"  --cdn更新路径
        self.server_list_url = self.local_admincenter_api_url .. ""
        GameConfig.real_name_url = GameConfig.local_admincenter_api_url 
    else
        --正式包，带着主版本，因为如果强更的话，需要先行测试，不能影响到线上的包
        self.cdn_host = self.version_head_url .. "version" .. self.mainVersion .. "/"
        self.server_list_url = self.admincenter_api_url .. ""
    end
    
    self.version_url = self.cdn_host .. "version.lua"
    self.pre_version_url = self.version_head_url .. "pre/version.lua"
    if self.packageInfo == -1 then
        self.pre_version_url = GameConfig.local_admincenter_api_url .. "version/platform/pre/version.lua"
    end


    if GameConfig.phoneVersionUrl ~= "" then
        self.version_url = GameConfig.phoneVersionUrl
    end
end


GameConfig.isAutoLogin = false --是否自动登录
GameConfig.isInitRoleInfo = false --是否已经初始化好数据

GameConfig.isInitSDKFinish = false --是否初始化SDK完毕，初始化完毕后，才能弹出登录界面
--
--String.xml配置 
GameConfig.autoLoginDebug = false --登录测试，在Android平台上也通过输入账号登录
GameConfig.isShowLogo = true
GameConfig.logoId = 0
GameConfig.isTriggerGuide = true --是否触发引导 默认true
GameConfig.isFullPackage = true  --是否整包 false则会走分包流程-->

GameConfig.isActivation = true  --是否激活 没有激活的话，需要走激活流程

GameConfig.get_version_info_path = GameConfig.admincenter_api_url .. "get_version_info.php"
GameConfig.payCallbackURL = GameConfig.admincenter_api_url .. "pay.php" 
GameConfig.statistics_url = GameConfig.admincenter_api_url .. "statistics.php" 
GameConfig.testPayCallbackURL = GameConfig.admincenter_api_url .. "test/charge_test.php" 

GameConfig.gameId = "102"
GameConfig.userId = 0

GameConfig.game_Id = "119"  --对应AndroiManifest.xml的3KWAN_GAMEID，直接写成119

--通过手机外部信息配置获取
GameConfig.platformChanleId = -1 --平台ID
GameConfig.channelId = 0 --子渠道ID
GameConfig.localVersion = 0 --对应热更时的小版本号
GameConfig.isOpenCharge = true

--月卡价格
GameConfig.monthCost = 148
GameConfig.maxEmotionNum = 10

GameConfig.chargePlatId = 0 --充值对应的平台ID，Android平台与平台ID对应，IOS可能会自定义

-- 充值类型
GameConfig.chargeTypeNormal = 0 --普通充值

--ios强更跳转到app store页面
GameConfig.myAppId = "https://itunes.apple.com/cn/app/id1262226160?mt=8"

GameConfig.isNewPlayer = false --玩家没有领取新手礼包

GameConfig.isOpenRealNameVerify = true --实名认证开关, false=已关闭，true=已开启

GameConfig.web_help_url = "http://help.znlgame.com/" --html格式帮助文件地址
