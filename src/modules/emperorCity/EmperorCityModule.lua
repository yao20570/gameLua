-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
EmperorCityModule = class("EmperorCityModule", BasicModule)

function EmperorCityModule:ctor()
    EmperorCityModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function EmperorCityModule:initRequire()
    require("modules.emperorCity.event.EmperorCityEvent")
    require("modules.emperorCity.view.EmperorCityView")
end

function EmperorCityModule:finalize()
    EmperorCityModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function EmperorCityModule:initModule()
    EmperorCityModule.super.initModule(self)
    self._view = EmperorCityView.new(self.parent)

    self:addEventHandler()
end

function EmperorCityModule:addEventHandler()
    self._view:addEventListener(EmperorCityEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(EmperorCityEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:addEventListener(EmperorCityEvent.GOTO_MAPPOS_REQ, self, self.onGoToMapReq)

    self:addProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_GET_REPORT, self, self.onOpenReport) -- 打开报告界面
    
    self:addProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_RANK_UPDATE, self, self.onUpdateRankPanel) -- 打开排名界面

    self:addProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_INFO_UPDATE, self, self.onUpdateInfoPanel) -- 打开皇城界面
    self:addProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_RANK_REWARD, self, self.onUpdateRankReward) -- 点击领取排名奖励

    
    self:addProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_READ_REPORT_ACT, self, self.updateReportBtnRedPoint) -- 战绩红点推送

end

function EmperorCityModule:removeEventHander()
    self._view:removeEventListener(EmperorCityEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(EmperorCityEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:removeEventListener(EmperorCityEvent.GOTO_MAPPOS_REQ, self, self.onGoToMapReq)
    self:removeProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_GET_REPORT, self, self.onOpenReport)

    self:removeProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_RANK_UPDATE, self, self.onUpdateRankPanel) -- 打开排名界面

    self:removeProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_INFO_UPDATE, self, self.onUpdateInfoPanel) -- 打开皇城界面
    self:removeProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_RANK_REWARD, self, self.onUpdateRankReward) -- 点击领取排名奖励

    self:removeProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_READ_REPORT_ACT, self, self.updateReportBtnRedPoint) -- 战绩红点推送
end

function EmperorCityModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function EmperorCityModule:onShowOtherHandler(data)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end

-- 打开模块
function EmperorCityModule:onOpenModule(extraMsg)
    EmperorCityModule.super.onOpenModule(self)
    local emperorCityProxy = self:getProxy(GameProxys.EmperorCity)
    emperorCityProxy:onTriggerNet550001Req({})
    emperorCityProxy:onTriggerNet550003Req({}) -- 获取红点信息

    -- 进入场景，如果已经在世界界面，不变
    local showModuleList = self:getShowModuleMap()
    for moduleName, module in pairs(showModuleList) do
        if moduleName ==  "MapModule"  then
            return
        end
    end
    local systemProxy = self:getProxy(GameProxys.System)
    systemProxy:onTriggerNet30105Req( { type = 0, scene = GlobalConfig.Scene[4]})
end

function EmperorCityModule:onHideModule()
    EmperorCityModule.super.onHideModule(self)

    local showModuleList = self:getShowModuleMap()
    for moduleName, module in pairs(showModuleList) do
        if moduleName ==  "MapModule"  then
            return
        end
    end

    local systemProxy = self:getProxy(GameProxys.System)
    systemProxy:onTriggerNet30105Req( { type = 1, scene = GlobalConfig.Scene[4]})
end

-- 前往地图跳转
function EmperorCityModule:onGoToMapReq(data)
    self:sendNotification(AppEvent.M2M_MAIN_EVENT, AppEvent.WATCH_WORLD_TILE, {tileX = data.extraMsg.tileX,
        tileY = data.extraMsg.tileY})
    self:sendNotification(AppEvent.MODULE_EVENT,AppEvent.MODULE_OPEN_EVENT,data)

    -- 关闭活动模块
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = "ActivityCenterModule"})

    self:onHideSelfHandler()
end

--打开皇城信息界面
function EmperorCityModule:onUpdateInfoPanel()
    local mainPanel = self:getPanel(EmperorCityPanel.NAME)
    mainPanel:setTabRedPoint()

    local panel = self:getPanel(EmperorCityInfoPanel.NAME)
    panel:onUpdateInfoPanel()
end

-- 打开战报模块
function EmperorCityModule:onOpenReport()
    local panel = self:getPanel(EmperorCityInfoPanel.NAME)
    panel:onOpenReport()
end


-- 打开排名界面
function EmperorCityModule:onUpdateRankPanel()
    local mainPanel = self:getPanel(EmperorCityPanel.NAME)
    mainPanel:setTabRedPoint()

    local panel = self:getPanel(EmperorCityRankPanel.NAME)
    panel:onUpdateRankPanel()
end


-- 点击领取排名奖励
function EmperorCityModule:onUpdateRankReward()
    local mainPanel = self:getPanel(EmperorCityPanel.NAME)
    mainPanel:setTabRedPoint()

    local panel = self:getPanel(EmperorCityRankPanel.NAME)
    panel:onUpdateRankReward()
end

-- 战绩红点推送
function EmperorCityModule:updateReportBtnRedPoint()
    local panel = self:getPanel(EmperorCityInfoPanel.NAME)
    panel:updateReportBtnRedPoint()

    -- 标签红点
    local mainPanel = self:getPanel(EmperorCityPanel.NAME)
    mainPanel:setTabRedPoint()
end



