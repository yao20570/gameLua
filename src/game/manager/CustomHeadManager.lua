------------------------------------

CustomHeadStatus = {} --自定义头像状态
CustomHeadStatus.NORMAL = 0  --无自定义头像
CustomHeadStatus.OWN = 1   --已拥有自定义头像
CustomHeadStatus.FIRST_AUDIT = 2  --第一次审核 从0变化
CustomHeadStatus.AGAIN_AUDIT = 3  --重新审核 从1变化
CustomHeadStatus.ONCE_OWN = 4  --曾经拥有

CustomHeadManager = {}

CustomHeadManager.CUSTOM_HEAD_ID = 99999 --自定义头像ID

function CustomHeadManager:init(game)
    self._game = game

    self._downloadCallbackMap = {}
end

function CustomHeadManager:checkAndroidVersionNotSupport(isShowSys)
    -- 乐视渠道屏蔽自定义头像
    if GameConfig.platformChanleId == 110 then
        if isShowSys then
            self:showSysMessage(TextWords:getTextWord(142011))
        end
        return false
    end

    local isNotSupport = GameConfig.mainVersion <= 10 and GameConfig.localVersion < 28
    if isNotSupport and isShowSys then
        self:showSysMessage(TextWords:getTextWord(142011))
    end
    return isNotSupport
end


function CustomHeadManager:getGame()
    return self._game
end

function CustomHeadManager:addDownloadCallback(key, callback)
    if callback == nil then
        return
    end
    if self._downloadCallbackMap[key] == nil then
        self._downloadCallbackMap[key] = {}
    end
    table.insert(self._downloadCallbackMap[key], callback)

    logger:error("~~~~~addDownloadCallback~~key:%s~", key)
end

function CustomHeadManager:triggerDownloadCallback(key)
    logger:error("~~~~~triggerDownloadCallback~~~key:%s~~~~~", key)
    local callbackAry = self._downloadCallbackMap[key]
    if callbackAry == nil then
        return
    end

    for _, callback in pairs(callbackAry) do
        callback()
    end

    self._downloadCallbackMap[key] = nil
end

function CustomHeadManager:showSysMessage(content)
    local chatProxy = self._game:getProxy(GameProxys.Chat)
    chatProxy:showSysMessage(content)
end

function CustomHeadManager:onTriggerNet140201Req()
    local chatProxy = self._game:getProxy(GameProxys.Chat)
    chatProxy:onTriggerNet140201Req() --请求服务端，告之已经头像上传成功了
end

function CustomHeadManager:showSelectPicUpload(selectType)
    require("json")
    local info = {}
    info["headInfo"] = self:getCustomHeadInfo(CustomHeadManager.CUSTOM_HEAD_ID, GameConfig.actorid)
    info["selectType"] = selectType
    local infoJson = json.encode(info)
    SDKManager:showSelectPicUpload(infoJson)
end

function CustomHeadManager:clearHeadCache()
    local roleProxy = self._game:getProxy(GameProxys.Role)
    local playerId = roleProxy:getPlayerId()
    local filename = self:getCustomHeadFileName(CustomHeadManager.CUSTOM_HEAD_ID, playerId)

    -- logger:error("~~~~~~~~~clearHeadCache~~~:%s~~~~", filename)

    TextureManager:updeteCacheId(filename)
    cc.Director:getInstance():getTextureCache():removeTextureForKey(filename)
end

--这个会自动设置自定义头像
function CustomHeadManager:updateHeadPanel()
    self:clearHeadCache()
    local roleProxy = self._game:getProxy(GameProxys.Role)
    roleProxy:sendNotification(AppEvent.PROXY_UPDATE_ROLE_CUSTOM_HEAD, {})
    roleProxy:sendNotification(AppEvent.PROXY_UPDATE_ROLE_HEAD, {rs = 0})
end

--重新下载自己的头像资源
function CustomHeadManager:redownloadSelfCustomHead()
    local roleProxy = self._game:getProxy(GameProxys.Role)
    local playerId = roleProxy:getPlayerId()

    local headInfo = self:getCustomHeadInfo(CustomHeadManager.CUSTOM_HEAD_ID, playerId)
    SDKManager:downloadHeadPic(headInfo)
end

function CustomHeadManager:downloadCallback(headFileName)
    local roleProxy = self._game:getProxy(GameProxys.Role)
    local playerId = roleProxy:getPlayerId()
    local selfHeadFileName = self:getCustomHeadInfo(CustomHeadManager.CUSTOM_HEAD_ID, playerId)
    if selfHeadFileName == headFileName then  --下载的是自己的
        local chatProxy = self._game:getProxy(GameProxys.Chat)
        chatProxy:onTriggerNet140203Req()

        self:clearHeadCache()
        -- CustomHeadManager:updateHeadPanel()
    end

    self:triggerDownloadCallback(headFileName)
end

function CustomHeadManager:downloadHeadPic(icon, playerId, callback)
    local headInfo = self:getCustomHeadInfo(icon, playerId)
    local roleProxy = self._game:getProxy(GameProxys.Role)
    local selfPlayerId = roleProxy:getPlayerId()
    if selfPlayerId == playerId then
        local customHeadStatus = roleProxy:getCustomHeadStatus()
        if customHeadStatus == CustomHeadStatus.NORMAL then --标记了，没有自定义头像的，自己的不下载了
            return
        end
    end
    SDKManager:downloadHeadPic(headInfo)

    self:addDownloadCallback(headInfo, callback) --添加回调，先聊天加上回调，因为模块不会释放掉，所以不怕释放问题
end

function CustomHeadManager:showUploadProcess(progress)
    local state = self._game:getCurState()

    local msg = string.format(TextWords:getTextWord(142008), tostring(progress))
    state:showLoading(msg)
end

function CustomHeadManager:hideUploadProcess()
    local state = self._game:getCurState()
    state:hideLoading()
end

----------全局的方法
_G["uploadPicResult"] = function(result)

    CustomHeadManager:hideUploadProcess()
    if result == "success" then  --上传成功
        --------请求客户端
        logger:error("!!!!!!上传成功!!!!!!")
        CustomHeadManager:showSysMessage(TextWords:getTextWord(142005)) --TODO 这个有问题，需要调试
        CustomHeadManager:onTriggerNet140201Req()

        --将个性头像Cache删除掉，使得可以进行更新
        CustomHeadManager:updateHeadPanel()
        
    else
        --提示
        logger:error("!!!!!上传失败!!!!!!!!")
        CustomHeadManager:showSysMessage(TextWords:getTextWord(142006))
    end
end

_G["uploadPicProgress"] = function(progress)
    CustomHeadManager:showUploadProcess(progress)
end

--下载成功才会回调，返回的是playerId
_G["downloadPicSuccess"] = function(headFileName)
    logger:error("~~~~downloadPicSuccess~~~headFileName:%s~~~~~", headFileName)
    CustomHeadManager:downloadCallback(headFileName)
end

CustomHeadManager.ErrorCode = {}
CustomHeadManager.ErrorCode.AlbumPermissionDenied = 1 --相册无权限
CustomHeadManager.ErrorCode.CameraPermissionDenied = 2 --相机无权限
_G["G_CustomHeadError"] = function(errorCode)
    errorCode = tonumber(errorCode)
    local state = CustomHeadManager:getGame():getState(GameStates.Scene)
    if state then
        if errorCode == CustomHeadManager.ErrorCode.AlbumPermissionDenied then
            state:showMessageBox(TextWords:getTextWord(142012), function() end)
        elseif errorCode == CustomHeadManager.ErrorCode.CameraPermissionDenied then
            state:showMessageBox(TextWords:getTextWord(142013), function() end)
        end
    end
end

-------------------------------
--获取自定义头像路径
function CustomHeadManager:getCustomHeadCachePath()
    local path = AppFileUtils:getWritablePath() .. "customHead/"
    if createAbsoluteDir ~= nil then
        createAbsoluteDir(path)
    end
    return path
end

--
function CustomHeadManager:getCustomHeadFileName(icon, playerId)
    local path = self:getCustomHeadCachePath()
    local headInfo = self:getCustomHeadInfo(icon, playerId)
    return path .. headInfo
end

function CustomHeadManager:getCustomHeadInfo(icon, playerId)
    --local headInfo = GameConfig.serverId .. "-" .. StringUtils:fixed64ToNormalStr(playerId)
    local headInfo = StringUtils:fixed64ToServerId(playerId) .. "-" .. StringUtils:fixed64ToNormalStr(playerId)
    return "head" .. icon .. "-" .. headInfo .. ".jpg"
end

--对应的自定义头像资源，是否存在
function CustomHeadManager:isCustomHeadExist(icon, playerId)
    if playerId == nil then
        return false
    end
    local filename = self:getCustomHeadFileName(icon, playerId)
    local isFileExist = cc.FileUtils:getInstance():isFileExist(filename)
    -- logger:error("isCustomHeadExist~~~filename:%s isFileExist:%s", filename, tostring(isFileExist))
    return isFileExist, filename
end

--删除自定义头像
function CustomHeadManager:delCustomHead(icon, playerId)
    local isFileExist, filename = self:isCustomHeadExist(icon, playerId)
    if isFileExist then
        if _G["deleteDownloadDir"] ~= nil then
            deleteDownloadDir(filename)
        end
    end
end

---------------------------