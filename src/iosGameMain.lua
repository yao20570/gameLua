

local iosGameMain = {}

local INSTALL_STATE = {
    FIRST_INSTALL = 0, 
    UNZIPPING_INSTALL = 1,--上次解压未成功
    UNZIP_FINISH = 2,--解压完成
}


function iosGameMain:init()

    self:initPhoneInfo()

	local packageUrl = cc.FileUtils:getInstance():fullPathForFilename("source.zip")
    local storagePath = createDownloadDir("zipres")
    addSearchPath(storagePath .. "/src", true)
    addSearchPath(storagePath .. "/res", true)
    addSearchPath(storagePath .. "/res/ccb/ccbi", true)
    addSearchPath(storagePath,true)


    local key = self:getFirstInstallKey()
    local state = cc.UserDefault:getInstance():getIntegerForKey(key)
    print("状态: state = " .. state)
    if state == INSTALL_STATE.UNZIP_FINISH then
        self:enterGame()
        return false
    end

    require "AudioEngine" 
    local musicPath = cc.FileUtils:getInstance():fullPathForFilename("BGM_login.aac")
    AudioEngine.playMusic(musicPath, true)

    self:renderSkin()
    self:zipSource()

    return true
end

--解压资源
function iosGameMain:zipSource()

	local packageUrl = cc.FileUtils:getInstance():fullPathForFilename("source.zip")
    local storagePath = createDownloadDir("zipres")
    addSearchPath(storagePath .. "/src", true)
    addSearchPath(storagePath .. "/res", true)
    addSearchPath(storagePath,true)
    

    local function errorCallback(errorCode)
            print("iosGameMain:init() errorCallback:",errorCode)
    end
    local function progressCallback(precent)
        print("iosGameMain:init() progressCallback:", precent)
        self:updatePrecent(precent)
    end
    local function successCallback(precent)
        print("iosGameMain:init() successCallback")

        local key = self:getFirstInstallKey()
        cc.UserDefault:getInstance():setIntegerForKey(key, INSTALL_STATE.UNZIP_FINISH)
        self:enterGame()
         -- zip_manager:release()
    end

    local zip_manager = cc.ZipFileManager:new(packageUrl, storagePath .. "/") 
    zip_manager:retain()

    zip_manager:setDelegate(progressCallback, 0)
    zip_manager:setDelegate(successCallback, 1)
    zip_manager:setDelegate(errorCallback, 2)
        
    zip_manager:execute()

end

function iosGameMain:updatePrecent(precent)
    local loadTime = 0.05
    self._actionProgressBar:stopAllActions()
    local progressFrom = self._actionProgressBar:getPercentage()
    self._actionProgressBar:setPercentage(progressFrom)
    local to = cc.ProgressFromTo:create(loadTime, progressFrom, precent)
    self._actionProgressBar:runAction(to)

    if precent >= 99 then
    	self:setStateLabel("正在进入游戏中...")
    end
end

function iosGameMain:renderSkin()
    self:setDesignResolutionSize()

    local scene = self:getScene()
    local skin = ccs.GUIReader:getInstance():widgetFromJsonFile("firstSrc/LoaderPanel.ExportJson")
    scene:addChild(skin)

    local mainPanel = skin:getChildByName("bgPanel")
    local versionTxt = skin:getChildByName("versionTxt")
    versionTxt:setVisible(false)

    local panel = skin:getChildByName("mainPanel")
    local progressBar = panel:getChildByName("stateBar")
    self:addLoadProgress(progressBar)

    local stateTxt = panel:getChildByName("stateTxt")
    stateTxt:setString("正在加载资源中，加载过程中不消耗流量")
    self._stateTxt = stateTxt


    require "CCBReaderLoad"
    local x, y = self:getCenterPosition()
    local  proxy = cc.CCBProxy:create()
    local  layer01  = CCBReaderLoad("firstSrc/ccb/rgb-piantou-kaiji.ccbi", proxy, {})
    mainPanel:addChild(layer01)
    layer01:setPosition(x, y * 2 - 1138 / 2)


    proxy = cc.CCBProxy:create()
    local layer02 = CCBReaderLoad("firstSrc/ccb/rgb-piantou-logo.ccbi", proxy, {})
    layer02:setPosition(x, y * 2 - 250 / 2 - 45)
    mainPanel:addChild(layer02)
end

function iosGameMain:addLoadProgress(progressBar)
    local posx, posy = progressBar:getPosition()
    local zOrder = progressBar:getLocalZOrder()
    local parent = progressBar:getParent()
    parent:removeChild(progressBar, true)

    local sprite = cc.Sprite:createWithSpriteFrameName("images/loader/Bg_bar2.png")

    local actionProgressBar = cc.ProgressTimer:create(sprite)
    actionProgressBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    actionProgressBar:setMidpoint(cc.p(0,0))
    actionProgressBar:setBarChangeRate(cc.p(1, 0))
    actionProgressBar:setPercentage(0)
    actionProgressBar:setPosition(posx, posy)
    actionProgressBar:setLocalZOrder(zOrder)
    parent:addChild(actionProgressBar)

    self._actionProgressBar = actionProgressBar
end

function iosGameMain:setStateLabel(str)
    self._stateTxt:setString(str)
end

--进入解压界面
function iosGameMain:getScene()
    local scene = cc.Scene:create()
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(scene)
    else
        cc.Director:getInstance():runWithScene(scene)
    end

    return scene
end

function iosGameMain:setDesignResolutionSize()
    local director = cc.Director:getInstance()
    local winSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local  rate = winSize.height / winSize.width

    --小于3:2采用
    if rate < 1.5 then
        director:getOpenGLView():setDesignResolutionSize(640, 960, cc.ResolutionPolicy.SHOW_ALL)
    else
        director:getOpenGLView():setDesignResolutionSize(640, 960, cc.ResolutionPolicy.NO_BORDER)
    end
end

--获取屏幕中心位置
function iosGameMain:getCenterPosition()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    return visibleSize.width / 2, visibleSize.height / 2
end

function iosGameMain:initPhoneInfo()

    local phoneInfo = ""
    local args = nil
    local luaoc = require "luaoc"
    local className = "LuaObjectCBridge"
    local ok,ret  = luaoc.callStaticMethod(className,"getPhoneInfo",args)
    if not ok then
    else
        print("========getPhoneInfo=========")
        phoneInfo = ret
    end

    -- logger:error("==not==error==initPhoneInfo=========:%s====", phoneInfo)
    require("json")
    local function decode()
        local result = json.decode(phoneInfo)
        return result
    end
    local status, phoneInfoData = pcall(decode)
    if status ~= true then
        logger:error("~~~~~~~initPhoneInfo解析失败~~~~~~~~~~~~~~~")
        phoneInfoData = {}
    end

    self._localVersion = phoneInfoData.localVersion or 0
end

function iosGameMain:getLocalVersion()
    return self._localVersion
end

--采用本地版本为key值，避免新版本用覆盖安装，导致新版本没有解压而出现的版本问题
function iosGameMain:getFirstInstallKey()  
    return "is_first_install" .. self._localVersion
end

--正常进入游戏
function iosGameMain:enterGame()
	addTempSearchPath()
    require("GameMain")
end



iosGameMain:init()



