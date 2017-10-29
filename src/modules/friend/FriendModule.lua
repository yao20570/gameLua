
FriendModule = class("FriendModule", BasicModule)

function FriendModule:ctor()
    FriendModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function FriendModule:initRequire()
    require("modules.friend.event.FriendEvent")
    require("modules.friend.view.FriendView")
end

function FriendModule:finalize()
    FriendModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function FriendModule:initModule()
    FriendModule.super.initModule(self)
    self._view = FriendView.new(self.parent)

    self:addEventHandler()
end

function FriendModule:addEventHandler()
    self._view:addEventListener(FriendEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(FriendEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    self._view:addEventListener(FriendEvent.SEARCH_ROLE_REQ, self, self.onSearchRoleHandler)

    self:addProxyEventListener(GameProxys.Friend,AppEvent.PROXY_FRIEND_INFO_UPDATE, self, self.onFriendInfoUpdate)
    self:addProxyEventListener(GameProxys.Friend,AppEvent.PROXY_FRIEND_SEARCH,self, self.onFriendSearch)
    self:addProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHATPERSON_INFO, self, self.onChatPersonInfoResp)
    self:addProxyEventListener(GameProxys.Friend,AppEvent.PROXY_FRIEND_BLESS_UPDATE,self, self.onBlessUpdate)
end

function FriendModule:removeEventHander()
    self._view:removeEventListener(FriendEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(FriendEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    self._view:removeEventListener(FriendEvent.SEARCH_ROLE_REQ, self, self.onSearchRoleHandler)
    
    self:removeProxyEventListener(GameProxys.Friend,AppEvent.PROXY_FRIEND_INFO_UPDATE, self, self.onFriendInfoUpdate)
    self:removeProxyEventListener(GameProxys.Friend,AppEvent.PROXY_FRIEND_SEARCH,self, self.onFriendSearch)
    self:removeProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHATPERSON_INFO, self, self.onChatPersonInfoResp)
    self:removeProxyEventListener(GameProxys.Friend,AppEvent.PROXY_FRIEND_BLESS_UPDATE,self, self.onBlessUpdate)
end


-- 每次open都走这条
function FriendModule:onOpenModule()
    FriendModule.super.onOpenModule(self)

    --好友信息
    -- self:sendServerMessage(AppEvent.NET_M17, AppEvent.NET_M17_C170000, {})
    self._view:onUpdateCount()
    local data = {}
    self:onFriendInfoUpdate(data)
end

--------------------
function FriendModule:onFriendInfoUpdate(data)
    self._view:onFriendInfoUpdate(data)
end

--获取搜索结果
function FriendModule:onFriendSearch(data)
    self._view:onFriendSearch(data)
end

function FriendModule:onBlessUpdate(data)
    self._view:onBlessUpdate(data)
    self._view:onUpdateCount()    
end

function FriendModule:onChatPersonInfoResp(data)
    if data.rs == 0 then 
        self._view:onWatchPlayerInfo(data)
    end
end

--------------
function FriendModule:onSearchRoleHandler(data)
    self:sendServerMessage(AppEvent.NET_M17, AppEvent.NET_M17_C170002, data)
end

-----------------
function FriendModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function FriendModule:onShowOtherHandler(data)
    if data.moduleName == ModuleName.MapModule then
        self:sendNotification(AppEvent.M2M_MAIN_EVENT, AppEvent.WATCH_WORLD_TILE, 
            {tileX = data.extraMsg.tileX, tileY = data.extraMsg.tileY})
    end
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end

-- 关闭好友模块的时候，刷新缓存数据 
function FriendModule:onHideModule()
     local friendProxy = self:getProxy(GameProxys.Friend)
     friendProxy:setIsShowCollectSysMsg(false)
     friendProxy:synWorldCollectionInfo()
end