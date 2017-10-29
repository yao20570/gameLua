GameLoader = class("GameLoader")

function GameLoader:ctor(loaderModule)
    self._module = loaderModule
    
    self.targetPlatform = cc.Application:getInstance():getTargetPlatform()
    self.winSize = cc.Director:getInstance():getWinSize()

    
    if cc.PLATFORM_OS_WINDOWS == self.targetPlatform then
        self:enterGame()
        return
    end

    if _G["createDownloadDir"] == nil then
--        print("======createDownloadDir======function==not==exist===")
        self:enterGame()
        return
    end
    
    self:startCheckVersion()
end

function GameLoader:finalize()
    if self.assetsManager ~= nil then
        self.assetsManager:release()
    end
    
--    framework.coro.CoroutineManager:stopCoroutine(self._task)
    
    self.assetsManager = nil
end

function GameLoader:startCheckVersion()
    local mainVersion = require("version")

--    local writablePath = cc.FileUtils:getInstance():getWritablePath()
--    local sdkPath = writablePath .. "/" .. "tmpdir" .. mainVersion
--    local result = framework.platform.FileUtils:isFolderExists(sdkPath)
--    if result == false then
        self.pathToSave = createDownloadDir("tmpdir" .. mainVersion)
        
--    else
--        for version=1, mainVersion - 1 do
--            framework.platform.FileUtils:deleteFolder(writablePath .. "tmpdir" .. version)
--        end
--        self.pathToSave = sdkPath
--    end
    self:addTempSearchPath()

    self.packageurl = GameConfig.cdn_host .. "package.zip" --不用了
    self.versionurl = GameConfig.version_url

    self.max_export = 5 --服务端最大的更新包数
    self.package_per_name = GameConfig.cdn_host .. "packages/package-"

    self._serverSrcVersion = nil
    self._packagesInfo = nil
    self._downloadPreName = nil

    self._isGetServerVersion = false
    self._checkMaxCount = 10
    self._curCheckCount = 0
    self._isCheckFiles = true

--    self:onProgress(0)
    self:setStateLabel("开始下载更新")
    self:getVersion()
    
    TimerManager:add(3000, self.countDown, self, -1)  --3秒请求一次--ps:无网络的时候，XMLHttpRequest什么反应没有，需要定时检查网络情况
end

function GameLoader:countDown()   
    
    if self._isGetServerVersion == true then
        TimerManager:remove(self.countDown, self)
        return
    end
    
    self:checkGetServerVersionState()
--    while true do
--        if self._isGetServerVersion == true then
--            break
--        end
--        coroutine.yield(30)
--        self:checkGetServerVersionState()
--    end
end

local tryCount = 0
--检测获取服务器版本状态
--超过一定时间，则默认表示网络连接失败
--重新获取服务器版本
function GameLoader:checkGetServerVersionState()
    self._curCheckCount = self._curCheckCount + 1
    if self._isGetServerVersion ~= true then

        self:setStateLabel("网络异常，尝试重连" .. tryCount)
        self._curCheckCount = 0
        tryCount = tryCount + 1
        
        if tryCount % 3 == 0 then --一分钟一次提醒
            -- self._module:showMessageBox("当前网络异常，请检查网络， 尝试重新进入游戏！", function()end,function()end)
        end
        
        self:getServerVersion(true)  --直接重连了 3秒还没有拿到

        self._module:showSysMessage("正在努力获取版本信息，请主公稍安片刻！")

        if self._curCheckCount >= self._checkMaxCount then
            self._module:showMessageBox("当前网络繁忙， 请重新尝试进入游戏！", function()end,function()end)
        end
    end
end

function GameLoader:addTempSearchPath()
    addSearchPath(self.pathToSave,true)
    addSearchPath(self.pathToSave .. "/src", true)
    addSearchPath(self.pathToSave .. "/res", true)
end

--更新失败处理
function GameLoader:updateError(reason)
    self.assetsManager:deleteVersion()
    
    
    -----将本地版本还原，并将补丁文件夹删除掉
    local localPackageVersion = GameConfig.localVersion
    cc.UserDefault:getInstance():setIntegerForKey(self._localVersionKey, localPackageVersion)
    self:deletPatchFloder()
    
    local function delayTryUpdateAgain()
--        framework.coro.CoroutineManager:startCoroutine(self.delayTryUpdateAgain, self)
        TimerManager:addOnce(90 * 30,self.delayTryUpdateAgain, self)
    end
    
    self._module:showMessageBox("更新异常，请检测网络", 
        delayTryUpdateAgain,
        delayTryUpdateAgain)
    
    --重新尝试下载
--    self:setStateLabel("更新异常，重新尝试下载更新包")
    self:setStateLabel(reason .. "，请重新尝试下载更新包")
    
--    local infos = {}
--    infos["reason"] = reason
--    infos["version"] = self._serverSrcVersion
--    framework.platform.AppUtils:onEventTCAgent(game.log.LogDefine.GAME_UPDATE, game.log.LogDefine.GAME_UPDATE_FAIL, infos)
end

function GameLoader:delayTryUpdateAgain()
    self:startCheckVersion()
end

function GameLoader:onError(errorCode)
    local reason = ""
    if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
        reason = "没有版本内容可以更新"
--        self:setStateLabel(reason)
--        logger:error(reason)
--        self:updateError(reason)
        self:enterGame() --直接进入游戏
    elseif errorCode == cc.ASSETSMANAGER_UNCOMPRESS then
        reason = "解压失败"
        self:setStateLabel(reason)
        logger:error(reason)
        self:updateError(reason)
    elseif errorCode == cc.ASSETSMANAGER_NETWORK then
        reason = "网络异常"
        self:setStateLabel(reason)
        logger:error(reason)
        self:updateError(reason)
    else
        reason = "未知错误：" .. errorCode
        self:setStateLabel(reason)
        logger:error(reason)
        self:updateError(reason)
    end
end

function GameLoader:onProgress( percent )
    local progress = string.format("%d%%",percent)
    self:setStateLabel("下载资源中:" .. progress)
    print("下载资源中:" .. progress)
    
    self._module:setProgress(percent)
end

function GameLoader:onSuccess()
    
    local result = self:checkVersionFile()
    if result == true then
    
        --TODO 写日志，成功热更
        
        self:setStateLabel("更新完毕，准备进入游戏")
        cc.UserDefault:getInstance():setIntegerForKey(self._localVersionKey, self.serverVersion)
        cc.UserDefault:getInstance():flush()
        self:enterGame(true)
        
    else
        local reason = "校验失败，重新更新"
        self:setStateLabel(reason)
        self:updateError(reason)
    end
    
end

function GameLoader:getAssetsManager()
    local function onError(errorCode)
        self:onError(errorCode)
    end
    local function onProgress(percent)
        self:onProgress(percent)
    end
    local function onSuccess(errorCode)
        self:onSuccess()
    end
    if nil == self.assetsManager then
        self.assetsManager = cc.AssetsManager:new(self.packageurl,
            self.versionurl,
            self.pathToSave)
        self.assetsManager:retain()
        self.assetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR )
        self.assetsManager:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
        self.assetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
        self.assetsManager:setConnectionTimeout(10)
    end

    return self.assetsManager
end

function GameLoader:getVersion()
    self:setStateLabel("获取本地版本")
    self._localMainVersion = require("version")
    local plat = GameConfig.platformChanleId
    self._localVersionKey = "localVersion" .. plat .. self._localMainVersion
    
    local localVersion = GameConfig.localVersion    --ps:GameConfig.localVersion初始化的时候  从手机拿到的，例如安卓包里面的strings.xml中localVersion
    local tempVerion = cc.UserDefault:getInstance():getIntegerForKey(self._localVersionKey)
    self.localVersion = tempVerion == 0 and localVersion or tempVerion   --ps:如果tempVerion是0，则等于localVersion，否则等于tempVerion
    if tempVerion == 0 then
        cc.UserDefault:getInstance():setIntegerForKey(self._localVersionKey, localVersion)
    end
    
    GameConfig.clientVersion = self._localMainVersion .. "." .. self.localVersion
    self:getServerVersion()
end

function GameLoader:getServerVersion(isTry)
    if self._isGetServerVersion == true then
        return
    end
    if isTry ~= true then
        self:setStateLabel("获取服务器版本")
    end
    local url = self.versionurl
    local xhr = XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET", url)

    local function onReadyStateChange()
        if self._isGetServerVersion == true then
            return
        end
        if xhr.status ~= 200 then
            self._module:showSysMessage("获取版本信息异常，重新获取版本" .. xhr.status)
            self:setStateLabel("网络异常，尝试重连")
            xhr:send()
            return
        end
        self:setStateLabel("成功获取服务器版本")
        self._isGetServerVersion = true
--        self:versionInfoHandler(xhr.response)
        local versionConfig = VersionManager:loadServerVersion(xhr.response)
        self._serverSrcVersion = VersionManager:getServerSrcVersion()
        
        local version = self._serverSrcVersion
        GameConfig.version = version
        local versionAry = StringUtils:splitString(version,".")
        local mainVersion = tonumber(versionAry[1])
        local serverVersion = tonumber(versionAry[2])
        self._serverMainVersion = mainVersion
        if self._localMainVersion < mainVersion then --本地包版本 小于服务器版本 需要强更
            self:setStateLabel("安装包 " .. self._localMainVersion .. "版本不匹配，请安装最新版本" )
            
            local function downNewVersion()
                self:downNewVersion()
            end
            
            -- downNewVersion() --直接跳转下载
            self._module:showMessageBox("您当前游戏版本历史太久远无法自动更新，请自行下载最新安装包。", nil, downNewVersion, "知道了")
--            component.MessageBox:show("系统信息","安装包版本不匹配，无法进入游戏", downNewVersion, downNewVersion)
        elseif self._localMainVersion > mainVersion then --本地版本高于服务器版本，直接进入游戏 兼容
            self:enterGame()
        else --版本一致，检测子版本，进行热更
            self:handlerVersionPackage(serverVersion, self.localVersion)
        end
        
--        local serverVersion =  tonumber(xhr.response)
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send()
end

function GameLoader:versionInfoHandler(versionInfo)
    local infoAry = StringUtils:splitString(versionInfo,",")
    local version = infoAry[1]
    local packagesInfo = {}
    local index = 2
    while index <= #infoAry do
        local packageName = infoAry[index]
        local count = infoAry[index + 1]
        packagesInfo[packageName] = count
        index = index + 2 
    end
    
    if #infoAry <= 2 then
        self._isCheckFiles = false
    end
    
    self._serverSrcVersion = version
    self._packagesInfo = packagesInfo
end

function GameLoader:downNewVersion()
    --local url = GameConfig.newApkURL
    --TODO Android平台，直接退出游戏
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then  --直接退出游戏
        SDKManager:exitApp()
        return
    end
    local info = {}
    info.url = GameConfig.myAppId
    AppUtils:openAppStore(info)
--    framework.platform.AppUtils:openURL(url)
end

function GameLoader:handlerVersionPackage(serverVersion, localVersion)
    self:setStateLabel("处理版本信息")
    
    self._module:setLocalVersionLabel(self._localMainVersion .. "." .. localVersion)
    self._module:setServerVersionLabel(self._serverMainVersion .. "." .. serverVersion)

    if serverVersion <= localVersion or serverVersion == 0 then  --本地版本可以超过服务器版本
        self:handerDowningPatch(serverVersion)
        self:enterGame()
        return
    end
    if (self.max_export - (serverVersion - localVersion) >= 0) and (serverVersion > localVersion) then
        localVersion = localVersion
    else
        localVersion = 0
    end
    
    if localVersion > serverVersion then
        localVersion = 0
    end

    self.serverVersion = serverVersion
--    self.packageurl = self.package_per_name .. localVersion .. "-" .. serverVersion .. ".zip"
    
    self._downloadPreName = "package-" .. localVersion .. "-" .. serverVersion
    local info = VersionManager:getPackageInfo(self._downloadPreName)
    self.packageurl = info.url
    
    self._module:setUpdateFileSize(info.filesize)
    
    self:getAssetsManager():setPackageUrl(self.packageurl)
    
    self:update()

end

function GameLoader:handerDowningPatch(serverVersion)
    local localPackageVersion = GameConfig.localVersion
    if serverVersion <= localPackageVersion then  --本地包的版本跟服务器的版本一致 需要将补丁目录删除掉
        self:deletPatchFloder()
    end
end

function GameLoader:deletPatchFloder()
--    local result = framework.platform.FileUtils:isFolderExists(self.pathToSave)
--    if result == true then
--        framework.platform.FileUtils:deleteFolder(self.pathToSave)
--    end
    
    if _G["deleteDownloadDir"] ~= nil then
        deleteDownloadDir(self.pathToSave)
    end
end

function GameLoader:checkVersionFile()
    if self._isCheckFiles ~= true then --不检测版本
        return true
    end
    self:setStateLabel("检测版本数据")
    local result = VersionManager:checkDownloadFile(self._downloadPreName)
    
    return result
end

function GameLoader:update(isTry)
    self:setStateLabel("开始更新")
    if isTry == true then
        self:setStateLabel("重新尝试下载更新")
    end
    
    self:getAssetsManager():update()
    
    --TODO 记录日志，客户端开始热更新
end

function GameLoader:reset(sender)

end

function GameLoader:enter(sender)

end

function GameLoader:setStateLabel(label)
    self._module:setStateLabel(label)
end

--加载完毕后 进入游戏
function GameLoader:enterGame(isReloadGame)
    self._module:enterGame(isReloadGame)
end