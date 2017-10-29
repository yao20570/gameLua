-- /**
--  * @Author:    fzw
--  * @DateTime:    2016-11-02 15:06:30
--  * @Description: 城主战模块
--  */
LordCityModule = class("LordCityModule", BasicModule)

function LordCityModule:ctor()
    LordCityModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function LordCityModule:initRequire()
    require("modules.lordCity.event.LordCityEvent")
    require("modules.lordCity.view.LordCityView")
end

function LordCityModule:finalize()
    LordCityModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function LordCityModule:initModule()
    LordCityModule.super.initModule(self)
    self._view = LordCityView.new(self.parent)

    self:addEventHandler()
end

function LordCityModule:addEventHandler()
    self._view:addEventListener(LordCityEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(LordCityEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHAT_INFO, self, self.onGetChatInfoResp)
    self:addProxyEventListener(GameProxys.Chat, AppEvent.PROXY_CHAT_RESP, self, self.onGetPrivateChatinfoResp)

    self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_UPDATE, self, self.onCityInfoMapUpdate)
    self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_BUFFUP, self, self.onBuffUpUpdate)
    self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_BUFFMAP, self, self.onBuffMapUpdate)
    self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_VOTEINFO, self, self.onVoteInfoUpdate)
    self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_INFO, self, self.onCityInfoUpdate)
    self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_DEFMAP, self, self.onDefMapUpdate)
    self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_VOTEREWARD, self, self.onVoteRewardUpdate)
    self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_DEFTEAM, self, self.onDefTeamUpdate)
    self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_UPDATESTATE, self, self.onStateUpdate)
    self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_STATECHANGE, self, self.onStateChangeUpdate)
    self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_REWARDUPDATE, self, self.onRewardUpdate)
    self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_QUALIFY, self, self.onPowerUpdate)
    self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_TEAMDIE, self, self.onDefTeamDie)
    self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_PLAYERINFOMap, self, self.onPlayerInfoUpdate)

    self:addProxyEventListener(GameProxys.Chat,AppEvent.PROXY_GET_CHAT_INFO_BARRAGE,self,self.onUpdateBarrage)                  --弹幕推送
end

function LordCityModule:removeEventHander()
    self._view:removeEventListener(LordCityEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(LordCityEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHAT_INFO, self, self.onGetChatInfoResp)
    self:removeProxyEventListener(GameProxys.Chat, AppEvent.PROXY_CHAT_RESP, self, self.onGetPrivateChatinfoResp)

    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_UPDATE, self, self.onCityInfoMapUpdate)
    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_BUFFUP, self, self.onBuffUpUpdate)
    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_BUFFMAP, self, self.onBuffMapUpdate)
    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_VOTEINFO, self, self.onVoteInfoUpdate)
    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_INFO, self, self.onCityInfoUpdate)
    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_DEFMAP, self, self.onDefMapUpdate)
    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_VOTEREWARD, self, self.onVoteRewardUpdate)
    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_DEFTEAM, self, self.onDefTeamUpdate)
    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_UPDATESTATE, self, self.onStateUpdate)
    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_STATECHANGE, self, self.onStateChangeUpdate)
    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_REWARDUPDATE, self, self.onRewardUpdate)
    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_QUALIFY, self, self.onPowerUpdate)
    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_TEAMDIE, self, self.onDefTeamDie)
    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_PLAYERINFOMap, self, self.onPlayerInfoUpdate)

    self:removeProxyEventListener(GameProxys.Chat,AppEvent.PROXY_GET_CHAT_INFO_BARRAGE,self,self.onUpdateBarrage)
end

function LordCityModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function LordCityModule:onShowOtherHandler(data)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end

function LordCityModule:onGetChatInfoResp(data)
    self._view:onGetChatInfoResp(data)
end

function LordCityModule:onUpdateBarrage(data)
	if #data == 0 then
		return
	end
	self._view:onUpdateBarrage(data)
end
function LordCityModule:onGetPrivateChatinfoResp(data)
    self._view:onGetPrivateChatInfoResp(data)
end

-------------------------------------------------------------------------------
function LordCityModule:onCityInfoMapUpdate(data)
    self._view:onCityInfoMapUpdate()
end

function LordCityModule:onBuffMapUpdate(data)
    self._view:onBuffMapUpdate()
end

function LordCityModule:onBuffUpUpdate(data)
    self._view:onBuffUpUpdate()
end

function LordCityModule:onVoteInfoUpdate(data)
    self._view:onVoteInfoUpdate()
end

function LordCityModule:onCityInfoUpdate(data)
    self._view:onCityInfoUpdate()
end

function LordCityModule:onDefMapUpdate(data)
    self._view:onDefMapUpdate()
end

function LordCityModule:onVoteRewardUpdate(data)
    self._view:onVoteRewardUpdate()
end

function LordCityModule:onDefTeamUpdate(data)
    self._view:onDefTeamUpdate()
end

function LordCityModule:onStateUpdate(data)
    self._view:onStateUpdate(data)
end

function LordCityModule:onStateChangeUpdate(data)
    self._view:onStateChangeUpdate(data)
end

function LordCityModule:onRewardUpdate(data)
    self._view:onRewardUpdate(data)
end

function LordCityModule:onPowerUpdate(data)
    self._view:onPowerUpdate(data)
end

function LordCityModule:onDefTeamDie(data)
    self._view:onDefTeamDie()
end

function LordCityModule:onPlayerInfoUpdate(data)
    self._view:onPlayerInfoUpdate()
end

-------------------------------------------------------------------------------
function LordCityModule:onOpenModule(extraMsg)
    LordCityModule.super.onOpenModule(self)
    local lordCityProxy = self:getProxy(GameProxys.LordCity)
    lordCityProxy:onTriggerNet360010Req()
end