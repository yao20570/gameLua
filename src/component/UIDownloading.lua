--------
---资源加载器
------
UIDownloading = class("UIDownloading")

function UIDownloading:ctor()
    local mainVersion = require("version")
    self.packageurl = GameConfig.cdn_host .. "package.zip" --不用了
    self.versionurl = GameConfig.admincenter_api_url .. "version/version.php"
    
    self._mainVersion = mainVersion
    
    self.preTmpResName = "tmpres"
    if GameConfig.isPre then  --是预览版的，用这个目录
        self.preTmpResName = "tmppreres"
    end

    self.pathToSave = self:createPatchFloder(mainVersion) --资源的保存目录 跟core包不一样 独立
    self:addTempSearchPath()
end

function UIDownloading:addTempSearchPath()
    addSearchPath(self.pathToSave,true)
    addSearchPath(self.pathToSave .. "/src", true)
    addSearchPath(self.pathToSave .. "/res", true)
end

function UIDownloading:setGame(state)
    self._state = state
end

function UIDownloading:showLoading()
    self._state:showLoading("加载中")
end



function UIDownloading:hideLoading(callback)
    self._state:hideLoading(callback)
end

function UIDownloading:finalize()
    if self.assetsManager ~= nil then
        self.assetsManager:release()
    end
    self.assetsManager = nil
end

function UIDownloading:checkModule(moduleName, callback,isExtras)
    -- local path = cc.FileUtils:getInstance():getSearchPaths()
    -- for _,v in pairs(path) do
    --     print("=======path=======    %s",v)
    --     logger:error("=======path=======    %s",v)
    -- end
    -- local fullPath = cc.FileUtils:getInstance():fullPathForFilename("gui_ui_resouce_big_0")
    -- logger:error("[[[[[[[[[[[[gui_ui_resouce_big_0      %s",fullPath)

    -- local fullPath = cc.FileUtils:getInstance():fullPathForFilename("legionScene_ui_resouce_big_0")
    -- logger:error("[[[[[[[[[[[[legionScene_ui_resouce     %s",fullPath)

    --print("$$$$$$$$$$$      传进来的模块名   %s",moduleName)
    logger:error("$$$$$$$$$$$      分包传进来的模块名:   %s",moduleName)
    if isExtras == nil then
        logger:error("$$$$$$$$$$$      分包传进来的:   isExtras = nil")
    else
        logger:error("$$$$$$$$$$$      分包传进来的:   isExtras = %d",isExtras)
    end
    self._checkCallback = callback
    self._isExtras = isExtras
    
    local keyModuleName,isFinish
    local versionInfo = VersionManager:getModuleVersionInfo(moduleName)
    if versionInfo == nil then  --需要下载资源的模块
        local result = self:getSubcontract(moduleName,isExtras)  --需要找模块集合验证,找到主模块的名称
        if result ~= nil then
            keyModuleName = result[1]
            isFinish = result[2]
            if isFinish == true then  --已经更新过了
                --logger:error("$$$$$$$$$$$  已经更新过了finish = true   直接进入callback")
                callback(true)
                return
            end
        else
            callback(false)
            return
        end
        versionInfo = VersionManager:getModuleVersionInfo(keyModuleName)
    end

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_IPHONE == targetPlatform or 
        cc.PLATFORM_OS_IPAD == targetPlatform then
        if versionInfo == nil then  --该模块没有配置分包，默认不走分包流程了
            callback(true)
        return
        end
    end
    

    if keyModuleName then  --集合中主模块名称
        --print("=======keyModuleName=======   %s",keyModuleName)
        --logger:error("=======keyModuleName=======   %s",keyModuleName)
        moduleName = keyModuleName
    end
    
    --cc.UserDefault:getInstance():setIntegerForKey(moduleName, -1)
    
    versionInfo.moduleName = moduleName
    local localKey = self:getLocalKey(moduleName)
    local localVerion = cc.UserDefault:getInstance():getIntegerForKey(localKey,-100)

    local serverVersion = versionInfo.version

    self._localVerion = localVerion
    self._moduleName = moduleName
    
    --print("&&&&&&&&&&&&&&&&  serverVersion: %d     localVerion:%d",serverVersion,localVerion)
    --logger:error("&&&&&&&&&&&&&&&&  serverVersion: %d     localVerion:%d",serverVersion,localVerion)
    
    if serverVersion == localVerion then --版本一致，直接进行模块加载逻辑
        --print("==========版本一致，直接进行模块加载逻辑============")
        --logger:error("&&&&&&&&&&&&&&&&  serverVersion: %d     localVerion:%d",serverVersion,localVerion)
        callback(true)
        return
    end
    
    if serverVersion ~= localVerion then  --版本不一致，下载资源
        self._serverVersion = serverVersion
        --print("++++++++++++++++++++  版本不一致，下载资源 +++++++++++++++++++")
        logger:error("++++版本不一致，下载资源serverVersion:%d   localVerion:%d+++++++++++++++++++",serverVersion,localVerion)
        self:downloadRes(versionInfo)
    end
end

function UIDownloading:getLocalKey(moduleName)
    local localKey = moduleName .. self._mainVersion
    if GameConfig.isPre then
        localKey = "pre" .. localKey  ----预览版Key
    end
    return localKey
end

function UIDownloading:downloadRes(versionInfo)
    self:getAssetsManager(versionInfo):setPackageUrl(versionInfo.url)
    self:getAssetsManager(versionInfo):update()
end

function UIDownloading:onSuccess(versionInfo)
    local localKey = self:getLocalKey(self._moduleName)
    cc.UserDefault:getInstance():setIntegerForKey(localKey, self._serverVersion)
    --print("=== UIDownloading:onSuccess===   %s   %d",self._moduleName,self._serverVersion)
    logger:error("=== UIDownloading:onSuccess===   %s   %d",self._moduleName,self._serverVersion)
    GlobalConfig.Subcontract[self._isExtras].finish = true
    local function call()
        self._checkCallback(true)
    end
    self:hideLoading(call)
end

function UIDownloading:onProgress(percent)
    self._state:showLoading("加载中 ".."("..percent.."%"..")")
end

function UIDownloading:onError(errorCode)
    local reason = ""
    if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
        reason = "没有版本内容可以更新"
        self._checkCallback(true) --直接进入该模块
        return
    elseif errorCode == cc.ASSETSMANAGER_UNCOMPRESS then
        reason = "解压失败"
        logger:error(reason)
    elseif errorCode == cc.ASSETSMANAGER_NETWORK then
        reason = "网络异常"
        logger:error(reason)
    elseif errorCode == 0 then
        reason = "创建文件失败"
        logger:error(reason)
    else
        reason = "未知错误：" .. errorCode
        logger:error(reason)
    end
    self:updateError(errorCode, reason)
end

function UIDownloading:getAssetsManager(versionInfo)
    local function onError(errorCode)
        self:onError(errorCode)
    end
    local function onProgress(percent)
        self:onProgress(percent)
    end
    local function onSuccess(errorCode)
        self:onSuccess(versionInfo)
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

--更新失败处理
function UIDownloading:updateError(errorCode, reason)
    self.assetsManager:deleteVersion()
    self:removeAllSubcontract()
    self:deletPatchFloder()
    self:createPatchFloder(self._mainVersion) --删除完，还要继续文件夹出来
    --同时要把临时文件删除掉，不然没法写
    logger:error("&&&&&&&&&&& 分包失败了===========  模块:%s",self._moduleName)
    self:hideLoading(function() end)
    local function delayTryUpdateAgain()
        -- TimerManager:addOnce(10 * 30,self.delayTryUpdateAgain, self) --不尝试下载了
    end

    local content = "您当前的网络环境不稳定，无法下载资源"
    if errorCode == 0 then
        content = "网络异常，下载文件失败"
    end
    self._state:showMessageBox(content, delayTryUpdateAgain, delayTryUpdateAgain)
end

--移除掉某个
function UIDownloading:removeSubcontract(moduleName)
    for key,value in pairs(GlobalConfig.Subcontract) do
        local modules = value.modules
        if table.indexOf(modules, moduleName) >= 0 then
            local keyName = value.moduleName or modules[1]
            local localKey = self:getLocalKey(keyName)
            cc.UserDefault:getInstance():setIntegerForKey(localKey, -1000)
            GlobalConfig.Subcontract[key].finish = false
            break
        end
    end
end

function UIDownloading:removeAllSubcontract()
    GlobalConfig:removeAllSubcontract()
end

function UIDownloading:deletPatchFloder()
    if _G["deleteDownloadDir"] ~= nil then
        deleteDownloadDir(self.pathToSave)
    end
end

function UIDownloading:createPatchFloder(mainVersion)
    if _G["createDownloadDir"] ~= nil then
        return createDownloadDir(self.preTmpResName .. mainVersion) 
    end
end

function UIDownloading:delayTryUpdateAgain()
    self:addTempSearchPath()
    self:checkModule(self._moduleName, self._checkCallback,self._isExtras)
end

--模块的集合 例如军团10个模块分包在一起
function UIDownloading:getSubcontract(name,isExtras)
    local sub = GlobalConfig.Subcontract[isExtras]
    if sub then
        local modules = sub.modules
        for k,v in pairs(modules) do
            if v == name then
                return {sub.moduleName,sub.finish}
            end
        end
    end
end
