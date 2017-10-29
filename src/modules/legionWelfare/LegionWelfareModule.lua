
LegionWelfareModule = class("LegionWelfareModule", BasicModule)

function LegionWelfareModule:ctor()
    LegionWelfareModule .super.ctor(self)
    
    self._view = nil
    self._loginData = nil
    
    --
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    --
    self.showActionType = ModuleShowType.Left
    self:initRequire()
end

function LegionWelfareModule:initRequire()
    require("modules.legionWelfare.event.LegionWelfareEvent")
    require("modules.legionWelfare.view.LegionWelfareView")
end

function LegionWelfareModule:finalize()
    LegionWelfareModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function LegionWelfareModule:initModule()
    LegionWelfareModule.super.initModule(self)
    self._view = LegionWelfareView.new(self.parent)

    self:addEventHandler()
end
function LegionWelfareModule:onOpenModule(extraMsg)
    LegionWelfareModule.super.onOpenModule(self, extraMsg)
    -- self:onWelfareInfoReq()
    local legionProxy = self:getProxy(GameProxys.Legion)
    local welfareInsfos = legionProxy:getWelfareInfo()
    if welfareInsfos ~= nil then
        self:onWelfareInfoResp(welfareInsfos)
    end
end

function LegionWelfareModule:addEventHandler()
    self._view:addEventListener(LegionWelfareEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(LegionWelfareEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    self._view:addEventListener(LegionWelfareEvent.WELFARE_INFO_REQ, self, self.onWelfareInfoReq)
    self._view:addEventListener(LegionWelfareEvent.WELFARE_UP_REQ, self, self.onWelfareUpReq)
    self._view:addEventListener(LegionWelfareEvent.GET_WELFARE_REQ, self, self.onGetWelfareReq)
    self._view:addEventListener(LegionWelfareEvent.GET_RESOURCE_REQ, self, self.onGetResourceReq)

    --self._view:addEventListener(LegionWelfareEvent.WELFARE_ALLOT_LIST_REQ, self, self.onResourceAllotRep)
    self._view:addEventListener(LegionWelfareEvent.WELFARE_ALLOT_REQ, self, self.onAllotWelfareRep)
    
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220012, self, self.onWelfareInfoResp)
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220013, self, self.onWelfareUpResp)
   -- self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220014, self, self.onWelfareGetResp)
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220015, self, self.onResourceGetResp)
    --self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220016, self, self.onAllotWelfareResp)
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220017, self, self.onAllotWelfareResp)
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_UPDATE_WELFARE_TIP, self, self.onWelfarePointUpdate)
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_ALLOT_UPDATE, self, self.onResourceAllotResp)
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_ALLOT_MEMBER_UPDATE, self, self.onAllotMemberListResp)
end

function LegionWelfareModule:removeEventHander()
    self._view:removeEventListener(LegionWelfareEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(LegionWelfareEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    self._view:removeEventListener(LegionWelfareEvent.WELFARE_INFO_REQ, self, self.onWelfareInfoReq)
    self._view:removeEventListener(LegionWelfareEvent.GET_WELFARE_REQ, self, self.onGetWelfareReq)
    self._view:removeEventListener(LegionWelfareEvent.GET_RESOURCE_REQ, self, self.onGetResourceReq)
    self._view:removeEventListener(LegionWelfareEvent.WELFARE_UP_REQ, self, self.onWelfareUpReq)
    --self._view:removeEventListener(LegionWelfareEvent.WELFARE_ALLOT_LIST_REQ, self, self.onResourceAllotRep)
    self._view:removeEventListener(LegionWelfareEvent.WELFARE_ALLOT_REQ, self, self.onAllotWelfareRep)
    
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220012, self, self.onWelfareInfoResp)
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220013, self, self.onWelfareUpResp)
   -- self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220014, self, self.onWelfareGetResp)
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220015, self, self.onResourceGetResp)
    --self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220016, self, self.onAllotWelfareResp)
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220017, self, self.onAllotWelfareResp)
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_UPDATE_WELFARE_TIP, self, self.onWelfarePointUpdate)
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_ALLOT_UPDATE, self, self.onResourceAllotResp)
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_ALLOT_MEMBER_UPDATE, self, self.onAllotMemberListResp)
end

function LegionWelfareModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function LegionWelfareModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

----------------接收数据--------------
function LegionWelfareModule:onWelfareInfoResp(data)
    if self._view ~= nil then
        self._view:updateWelfareDailyInfo(data.panelInfo) -- --更新日常福利数据
        self._view:onWelfareGetResp(data.iscangetWelf)
        self._view:updateMenberActivity(data.menberInfo)
    end
end 
function LegionWelfareModule:onWelfareUpResp(data)
    if data.rs == 0 then
        if data.type == 2 then
            self:showSysMessage(self:getTextWord(3413)) --升级成功
        else
            self:showSysMessage(self:getTextWord(3414)) --领取成功
        end
        if self._view ~= nil then
            self._view:updateWelfareDailyInfo(data.panelInfo)
            self._view:onWelfareGetResp(data.iscangetWelf)
        end
    end 
end
function LegionWelfareModule:onWelfareGetResp(data)
    if data.rs == 0 then
        if self._view ~= nil then
            self:showSysMessage(self:getTextWord(3414))
            self._view:onWelfareGetResp()
        end
    end 
end 
function LegionWelfareModule:onResourceGetResp(data)
    if data.rs == 0 then
        self:showSysMessage(self:getTextWord(3414))
        if self._view ~= nil then
            self._view:onResourceGetResp()
        end
        local legionProxy = self:getProxy(GameProxys.Legion)
        -- 领取完毕 刷新红点福利所红点
        legionProxy:updateWelfareResourceData() -- 外界感叹号
        local panel = self:getPanel(LegionWelfarePanel.NAME) -- 内部红点
        panel:onShowHandler()
    end 
end

--战事福利列表
function LegionWelfareModule:onResourceAllotResp()
    if self._view ~= nil then
        self._view:updateWelfarList()
    end
end

--分配界面刷新
function LegionWelfareModule:onAllotMemberListResp()
    if self._view ~= nil then
        self._view:updateAllotMemberList()
    end
end

--福利分配返回
function LegionWelfareModule:onAllotWelfareResp(data)
    if data.rs == 0 then
        if self._view ~= nil then
            self:showSysMessage(self:getTextWord(3033))
            self._view:updateWelfarList()
            self._view:updateAllotPanel( data.type or 0, data.num or 0)
        end
    end
end
----------------发送请求--------------
--福利院总信息
function LegionWelfareModule:onWelfareInfoReq(data)
    local data = {}
    self:sendServerMessage(AppEvent.NET_M22, AppEvent.NET_M22_C220012, data)
end
--福利院升级
function LegionWelfareModule:onWelfareUpReq(data)
    local data = {}
    data.type = 2
    self:sendServerMessage(AppEvent.NET_M22, AppEvent.NET_M22_C220013, data)
end 
--领取福利
function LegionWelfareModule:onGetWelfareReq(data)
    
    self:sendServerMessage(AppEvent.NET_M22, AppEvent.NET_M22_C220013, data)
end 
--领取资源
function LegionWelfareModule:onGetResourceReq(data)
    local data = {}
    self:sendServerMessage(AppEvent.NET_M22, AppEvent.NET_M22_C220015, data)
end
-- --战事福利列表
-- function LegionWelfareModule:onResourceAllotRep( )
--     print("请求战事福利列表onResourceAllotRep")
--     self:sendServerMessage(AppEvent.NET_M22, AppEvent.NET_M22_C220016, {})
-- end
--请求分配福利\
function LegionWelfareModule:onAllotWelfareRep( data )
    self:sendServerMessage(AppEvent.NET_M22, AppEvent.NET_M22_C220017, data)
end

function LegionWelfareModule:onWelfarePointUpdate()
    if self._view ~= nil then 
        self._view:onWelfarePointUpdate()
    end
end