
LoaderModule = class("LoaderModule", BasicModule)

function LoaderModule:ctor(stateName)
    LoaderModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_TOP_LAYER
    if stateName == GameStates.Scene then  --场景的加载界面
        self.uiLayerName = GameLayer.popLayer
    end
    
    self._view = nil
    self._loginData = nil
    self.isFullScreen = false
    
    self:initRequire()
end

function LoaderModule:initRequire()
    require("modules.loader.event.LoaderEvent")
    require("modules.loader.view.LoaderView")
    require("modules.loader.GameLoader")  --更新加载界面
end

function LoaderModule:finalize()
     LoaderModule.super.finalize(self)
    if self._gameLoader ~= nil then
        self._gameLoader:finalize()
    end
    self._gameLoader = nil
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function LoaderModule:initModule()
    LoaderModule.super.initModule(self)
    self._view = LoaderView.new(self.parent)

    self:addEventHandler()
    
    local gameState = self:getGameState()
    if gameState.name == GameStates.Scene then
        self:setLocalZOrder(2001)
    else
        self._view:setIsUpdateLoader(true)
        self._gameLoader = GameLoader.new(self)
    end
    
end

function LoaderModule:addEventHandler()
    self._view:addEventListener(LoaderEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(LoaderEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    self:addEventListener(AppEvent.LOADER_MAIN_EVENT, AppEvent.LOADER_UPDATE_PROGRESS, self, self.setProgressHandler)
    self:addEventListener(AppEvent.LOADER_MAIN_EVENT, AppEvent.LOADER_UPDATE_STATE, self, self.setStateLabel)
    
end

function LoaderModule:removeEventHander()
    self._view:removeEventListener(LoaderEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(LoaderEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    self:removeEventListener(AppEvent.LOADER_MAIN_EVENT, AppEvent.LOADER_UPDATE_PROGRESS, self, self.setProgressHandler)
    self:removeEventListener(AppEvent.LOADER_MAIN_EVENT, AppEvent.LOADER_UPDATE_STATE, self, self.setStateLabel)
end

function LoaderModule:setProgress(percent)
    self._view:setProgress(percent)
end

function LoaderModule:setProgressHandler(data)
    self._view:setProgress(data.percent, data.noAction, data.delay)
end

function LoaderModule:setStateLabel(label)
    self._view:setStateLabel(label)
end

--设置更新的文件大小
function LoaderModule:setUpdateFileSize(filesize)
    self._view:setUpdateFileSize(filesize)
end

function LoaderModule:setLocalVersionLabel(version)
end

function LoaderModule:setServerVersionLabel(version)
end

function LoaderModule:enterGame(isReloadGame)
    if isReloadGame == true then  --有更新，则重新进入游戏
        local gameMain = require("GameMain")
        gameMain:reLoadGame()
        return
    end

    local data = {}
    data["moduleName"] = ModuleName.LoaderModule
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, data)

    local data = {}
    data["stateName"] = GameStates.Login
    self:sendNotification(AppEvent.STATE_EVENT, AppEvent.STATE_CHANGE_EVENT, data)
end


function LoaderModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function LoaderModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end