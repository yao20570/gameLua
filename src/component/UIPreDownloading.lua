--------
---pre预先版本资源加载器
------
UIPreDownloading = class("UIPreDownloading")

function UIPreDownloading:ctor()
    local mainVersion = require("version")
    self.pathToSave = self:createPreFloder(mainVersion)
    self:addTempSearchPath(self.pathToSave)

    self.versionurl = GameConfig.admincenter_api_url .. "version/version.php"

    self._localMainVersion = mainVersion
    self.max_export = 5 --服务端最大的更新包数
end

function UIPreDownloading:setState(state)
    self._state = state
end

function UIPreDownloading:showLoading()
    self._state:showLoading("加载中")
end


function UIPreDownloading:hideLoading(callback)
    self._state:hideLoading(callback)
end

function UIPreDownloading:finalize()
    if self.assetsManager ~= nil then
        self.assetsManager:release()
    end
    self.assetsManager = nil
end

function UIPreDownloading:addTempSearchPath(pathToSave)
    addSearchPath(pathToSave,true)
    addSearchPath(pathToSave .. "/src", true)
    addSearchPath(pathToSave .. "/res", true)
end

function UIPreDownloading:createPreFloder(mainVersion)
    if _G["createDownloadDir"] ~= nil then
        return createDownloadDir("tmppre" .. mainVersion) 
    end
end

function UIPreDownloading:deletPreFloder()
    if _G["deleteDownloadDir"] ~= nil then
        deleteDownloadDir(self.pathToSave)
    end

    self:setPreLocalVersion(0)
end

----当标记为预览版服务器时，
--每次进入游戏前，还需要检测服务器版本
function UIPreDownloading:checkPreServerVersion(callback)
	self._checkCallback = callback
    HttpRequestManager:send(GameConfig.pre_version_url,{}, self, self.onGetPreServerVersionSuccess, self.onGetPreServerVersionFail)
end

-----------------
function UIPreDownloading:onGetPreServerVersionSuccess(info)
	VersionManager:loadServerVersion(info)  --重新刷新版本
	self:checkPreVersion()
end

function UIPreDownloading:enterGame(isUpdate)
	self._checkCallback(isUpdate)
end

--检测预览版版本
function UIPreDownloading:checkPreVersion()

	local mainServerVersion = VersionManager:getMainVersion()
	if mainServerVersion < self._localMainVersion then
		self:enterGame(false)
		return  --本地版本大于服务器版本，直接进入游戏
	end



	if mainServerVersion > self._localMainVersion then --
		local function downNewVersion()

        end    
        self._state:showMessageBox("服务器游戏版本历史太久远无法自动更新，请自行下载最新安装包。", nil, downNewVersion, "知道了")
		return
	end

	--  主版本校验
	local localVersion = self:getLocalVersion()
	local preLocalVersion = self:getPreLocalVersion()
	local preServerVersion = VersionManager:getSubVersion()

	if preLocalVersion > localVersion then
		localVersion = preLocalVersion --以预览版本的为主
	end

    local packageurl = ""
	local function downloadPreVersion()
		self:downloadPreVersion(packageurl)  
	end

	if localVersion < preServerVersion then  --本地版本小于服务器版本
		local downloadPreName = self:getDownloadPreName(preServerVersion, localVersion)

		local info = VersionManager:getPackageInfo(downloadPreName)
        packageurl = info.url
        -----开始下载

        self._state:showMessageBox("服务器游戏版本有更新，是否进行更新？", downloadPreVersion)
    else
        self:enterGame(false)  
	end
end

function UIPreDownloading:downloadPreVersion(packageurl)
    self:getAssetsManager():setPackageUrl(packageurl)
    self:getAssetsManager():update()
end

function UIPreDownloading:getAssetsManager()
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

--下载成功
function UIPreDownloading:onSuccess()

    local preServerVersion = VersionManager:getSubVersion()
    self:setPreLocalVersion(preServerVersion)


    local function call()
        self:enterGame(true)
    end
    self:hideLoading(call)
end

function UIPreDownloading:onProgress(percent)
    self._state:showLoading("加载中 ".."("..percent.."%"..")")
end

function UIPreDownloading:onError(errorCode)
    local reason = ""
    if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
        reason = "没有版本内容可以更新"
        self:enterGame(false) --直接进入该模块
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

--更新失败处理
function UIPreDownloading:updateError(errorCode, reason)
    self.assetsManager:deleteVersion()
    self:deletPreFloder()
    self:createPreFloder(self._localMainVersion) --删除完，还要继续文件夹出来

    -- 下载失败的处理

     --删除完，还要继续文件夹出来
    --同时要把临时文件删除掉，不然没法写

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

--获取要下载的url的Key值
function UIPreDownloading:getDownloadPreName(serverVersion, localVersion)
	if (self.max_export - (serverVersion - localVersion) >= 0) and (serverVersion > localVersion) then
        localVersion = localVersion
    else
        localVersion = 0
    end

    local downloadPreName = "package-" .. localVersion .. "-" .. serverVersion

    return downloadPreName
end

function UIPreDownloading:onGetPreServerVersionFail()
	logger:error("~~~~~~~~~~~~获取预览版版本失败~~~~~~~~~~~~~~~")
end

--获取正式版本地版本
function UIPreDownloading:getLocalVersion()
    local plat = GameConfig.platformChanleId
    local localVersionKey = "localVersion" .. plat .. self._localMainVersion
    local localVerion = cc.UserDefault:getInstance():getIntegerForKey(localVersionKey)
    return localVerion
end

--获取预览版本地版本
function UIPreDownloading:getPreLocalVersion()
	local localVersionKey = self:getPreVersionKey()
    local localVerion = cc.UserDefault:getInstance():getIntegerForKey(localVersionKey)
    return localVerion
end

--设置预览版本地版本
function UIPreDownloading:setPreLocalVersion(version)
	local versionKey = self:getPreVersionKey()
	cc.UserDefault:getInstance():setIntegerForKey(versionKey, version)
end

function UIPreDownloading:getPreVersionKey()
	local plat = GameConfig.platformChanleId
    local localVersionKey = "preLocalVersion" .. plat .. self._localMainVersion
    return localVersionKey
end

