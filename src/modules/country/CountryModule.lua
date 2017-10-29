-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
CountryModule = class("CountryModule", BasicModule)

function CountryModule:ctor()
    CountryModule.super.ctor(self)

    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function CountryModule:initRequire()
    require("modules.country.event.CountryEvent")
    require("modules.country.view.CountryView")
end

function CountryModule:finalize()
    CountryModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function CountryModule:initModule()
    CountryModule.super.initModule(self)
    self._view = CountryView.new(self.parent)
   
    self:addEventHandler()
end

function CountryModule:addEventHandler()
    self._view:addEventListener(CountryEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(CountryEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    self:addProxyEventListener(GameProxys.Country, AppEvent.PROXY_COUNTRY_CHANGE_DYNASTY, self, self.setDynasty)-- 刷新朝代
    
    self:addProxyEventListener(GameProxys.Country, AppEvent.PROXY_COUNTRY_ALL_ROYAL, self, self.onUpdateRoyalPanel)-- 获取全部皇族信息
    
    
    self:addProxyEventListener(GameProxys.Country, AppEvent.PROXY_COUNTRY_APPOINT_SUCCEED, self, self.onAppointSucceedResp) -- 任命成功
    self:addProxyEventListener(GameProxys.Country, AppEvent.PROXY_COUNTRY_REMOVE_SUCCEED, self, self.onAppointRemoveResp) -- 卸任成功
    self:addProxyEventListener(GameProxys.Country, AppEvent.PROXY_CHOOSE_LEGION_MEMBERS, self, self.onNewChooseLegionMember) -- 获取成员列表成功
    self:addProxyEventListener(GameProxys.Country, AppEvent.PROXY_COUNTRY_ALL_PRISON, self, self.onUpdataPrisonPanel) -- 获取监狱列表成功
    
    self:addProxyEventListener(GameProxys.Country, AppEvent.PROXY_COUNTRY_WANTED_SUCCEED, self, self.onWantedSucceedResp) -- 通缉成功
    self:addProxyEventListener(GameProxys.Country, AppEvent.PROXY_COUNTRY_REMOVE_WANTED, self, self.onWantedRemoveResp) -- 撤销成功
    self:addProxyEventListener(GameProxys.Country, AppEvent.PROXY_COUNTRY_GET_SKILLINFO, self, self.onOpenUseSkillBox) -- 打开技能使用box
    self:addProxyEventListener(GameProxys.Country, AppEvent.PROXY_COUNTRY_USED_SKILL, self, self.onUsedSkillResp) -- 使用技能成功回调

end

function CountryModule:removeEventHander()
    self._view:removeEventListener(CountryEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(CountryEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Country, AppEvent.PROXY_COUNTRY_CHANGE_DYNASTY, self, self.setDynasty)-- 刷新朝代
    self:removeProxyEventListener(GameProxys.Country, AppEvent.PROXY_COUNTRY_ALL_ROYAL, self, self.onUpdateRoyalPanel)-- 获取全部皇族信息
    
    self:removeProxyEventListener(GameProxys.Country, AppEvent.PROXY_COUNTRY_APPOINT_SUCCEED, self, self.onAppointSucceedResp) -- 任命成功
    self:removeProxyEventListener(GameProxys.Country, AppEvent.PROXY_COUNTRY_REMOVE_SUCCEED, self, self.onAppointRemoveResp) -- 卸任成功
    self:removeProxyEventListener(GameProxys.Country, AppEvent.PROXY_CHOOSE_LEGION_MEMBERS, self, self.onNewChooseLegionMember) -- 获取成员列表成功
    self:removeProxyEventListener(GameProxys.Country, AppEvent.PROXY_COUNTRY_ALL_PRISON, self, self.onUpdataPrisonPanel) -- 获取监狱列表成功

    self:removeProxyEventListener(GameProxys.Country, AppEvent.PROXY_COUNTRY_WANTED_SUCCEED, self, self.onWantedSucceedResp) -- 通缉成功
    self:removeProxyEventListener(GameProxys.Country, AppEvent.PROXY_COUNTRY_REMOVE_WANTED, self, self.onWantedRemoveResp) -- 撤销成功
    self:removeProxyEventListener(GameProxys.Country, AppEvent.PROXY_COUNTRY_GET_SKILLINFO, self, self.onOpenUseSkillBox) -- 打开技能使用box
    self:removeProxyEventListener(GameProxys.Country, AppEvent.PROXY_COUNTRY_USED_SKILL, self, self.onUsedSkillResp) -- 使用技能成功回调
end

function CountryModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function CountryModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end



function CountryModule:onOpenModule()
    CountryModule.super.onOpenModule(self)
    local countryProxy = self:getProxy(GameProxys.Country)
    countryProxy:onTriggerNet560001Req({})
end


-- 
function CountryModule:setDynasty()
    local panel = self:getPanel(CountryRoyalPanel.NAME)
    panel:setDynasty()
end

-- 560001Resp皇族界面信息resp
function CountryModule:onUpdateRoyalPanel()
    local panel = self:getPanel(CountryRoyalPanel.NAME)
    panel:onUpdateRoyalPanel()
end

-- 560004 任职成功返回
--function CountryModule:onUpdateCheckRole()

--    local prisonCheckPanel = self:getPanel(CountryPrisonCheckPanel.NAME)
--    prisonCheckPanel:onUpdatePrisonCheckRole()
--end

-- 562001 任命成功
function CountryModule:onAppointSucceedResp()
    local checkPanel = self:getPanel(CountryCheckPanel.NAME)
    checkPanel:onAppointSucceedResp()
end

-- 563003Resp卸任官职
function CountryModule:onAppointRemoveResp()
    local checkPanel = self:getPanel(CountryCheckPanel.NAME)
    checkPanel:onAppointSucceedResp()
end

-- 562003 获取同盟成员列表成功
function CountryModule:onNewChooseLegionMember()
    local checkPanel = self:getPanel(CountryCheckPanel.NAME)
    checkPanel:onNewChooseLegionMember()
end

-- 560002 获取监狱数据列表成功
function CountryModule:onUpdataPrisonPanel()
    local prisonPanel = self:getPanel(CountryPrisonPanel.NAME)
    prisonPanel:onUpdataPrisonPanel()
end

-- 563001Resp通缉成功
function CountryModule:onWantedSucceedResp()
    local panel = self:getPanel(CountryPrisonCheckPanel.NAME)
    panel:onWantedSucceedResp()
end


-- 563002Resp撤销成功
function CountryModule:onWantedRemoveResp()
    local panel = self:getPanel(CountryPrisonCheckPanel.NAME)
    panel:onWantedSucceedResp()
end

-- 560005Resp
function CountryModule:onOpenUseSkillBox()
    local panel = self:getPanel(CountryPrisonCheckPanel.NAME)
    panel:onOpenUseSkillBox()
end

-- 563004Resp
function CountryModule:onUsedSkillResp()
    local panel = self:getPanel(CountryPrisonCheckPanel.NAME)
    panel:onUsedSkillResp()
end

