
GameActivityModule = class("GameActivityModule", BasicModule)

--[[
作者:
1 首冲模板
2 投资计划
3 通用模板A
4 充值类模板
5 排行榜类模板
6 纯文字类模板
7 通用模板B
8 限购模板
9 双排行活动
10 cdk兑换
11 拉霸类活动
12 有福同享类
13 buff增益+限购
14 红包大派送类
15 vip特权宝箱
16 军械神匠
17 vip总动员
18 每日轮盘
20 周卡
--]]
GameActivityModule.UI_TYPE_SHOU_CHONG = 1 
GameActivityModule.UI_TYPE_TOU_ZI = 2
GameActivityModule.UI_TYPE_TONG_YONG_A = 3
GameActivityModule.UI_TYPE_CHONG_ZHI = 4
GameActivityModule.UI_TYPE_PAI_HANG_BANG = 5
GameActivityModule.UI_TYPE_CHUN_WEN_ZI = 6
GameActivityModule.UI_TYPE_TONG_YONG_B = 7
GameActivityModule.UI_TYPE_XIAN_GOU = 8
GameActivityModule.UI_TYPE_SHUANG_PAI_HANG = 9
GameActivityModule.UI_TYPE_CDK = 10
GameActivityModule.UI_TYPE_LA_BA = 11
GameActivityModule.UI_TYPE_YOU_FU_TONG_XIANG = 12
GameActivityModule.UI_TYPE_BUFF_INC_AND_XIAN_GOU = 13
GameActivityModule.UI_TYPE_HONG_BAO_DA_PAI_SONG = 14
GameActivityModule.UI_TYPE_VIP_TE_QUAN_BAO_XIANG = 15
GameActivityModule.UI_TYPE_JUN_XIE_SHEN_JIANG = 16
GameActivityModule.UI_TYPE_VIP_ZONG_DONG_YUAN = 17
GameActivityModule.UI_TYPE_MEI_RI_LUN_PAN = 18
GameActivityModule.UI_TYPE_ZHOU_KA = 20




function GameActivityModule:ctor()
    GameActivityModule .super.ctor(self)
    
    -- self.isFullScreen = true
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function GameActivityModule:initRequire()
    require("modules.gameActivity.event.GameActivityEvent")
    require("modules.gameActivity.view.GameActivityView")
end

function GameActivityModule:finalize()
    GameActivityModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function GameActivityModule:initModule()
    GameActivityModule.super.initModule(self)
    self._view = GameActivityView.new(self.parent)

    self:addEventHandler()
end

function GameActivityModule:addEventHandler()
    self._view:addEventListener(GameActivityEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(GameActivityEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_ACTIVITY_INFO, self, self.onUpdateAllData)
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_ONE, self, self.onUpdateOnceData)
    --490000通知购买周卡
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_ACTIVITY_CANBUY_WEEKCARD, self, self.onOpenSDKWeekCard)
    --490002{周卡数据刷新
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_ACTIVITY_WEEKCARD_UPDATE, self, self.onWeekCardUpdate)
end

function GameActivityModule:removeEventHander()
    self._view:removeEventListener(GameActivityEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(GameActivityEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_ACTIVITY_INFO, self, self.onUpdateAllData)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_ONE, self, self.onUpdateOnceData)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_ACTIVITY_CANBUY_WEEKCARD, self, self.onOpenSDKWeekCard)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_ACTIVITY_WEEKCARD_UPDATE, self, self.onWeekCardUpdate)
end

function GameActivityModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function GameActivityModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

--重写onOpen函数，因为有两个入口
function GameActivityModule:onOpenModule(extraMsg, isPerLoad)
    GameActivityModule.super.onOpenModule(self, extraMsg, isPerLoad)
    -- TimerManager:add(300000, self.sendRankReq, self, -1) 
--    if extraMsg ~= nil then -- 跳转到特定目标活动
--        self:jumpToActivity(extraMsg)
--    end
    self:sendRankReq()
end

function GameActivityModule:onHideModule()
    GameActivityModule.super.onHideModule(self)
    TimerManager:remove(self.sendRankReq, self)
end

function GameActivityModule:sendRankReq() 
    local proxy = self:getProxy(GameProxys.Activity)
    proxy:onTriggerNet230013Req({})
end

function GameActivityModule:onUpdateOnceData(data)
    self._view:onUpdateOnceData(data)
end

function GameActivityModule:onUpdateAllData(data)
    self._view:onUpdateAllData(data)
end
function GameActivityModule:onOpenSDKWeekCard(data)
    self._view:onOpenSDKWeekCard(data)
end
function GameActivityModule:onWeekCardUpdate(data)
    self._view:onWeekCardUpdate(data)
end

--function GameActivityModule:jumpToActivity(extraMsg)
--    local panel = self:getPanel(GameActivityPanel.NAME)
--    panel:show(extraMsg)
--end