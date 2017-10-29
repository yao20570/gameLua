
LegionApplyModule = class("LegionApplyModule", BasicModule)

function LegionApplyModule:ctor()
    LegionApplyModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    -- self.isFirstDelayAction = true
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function LegionApplyModule:initRequire()
    require("modules.legionApply.event.LegionApplyEvent")
    require("modules.legionApply.view.LegionApplyView")
end

function LegionApplyModule:finalize()
    LegionApplyModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function LegionApplyModule:initModule()
    LegionApplyModule.super.initModule(self)
    self._view = LegionApplyView.new(self.parent)

    self:addEventHandler()
end

function LegionApplyModule:addEventHandler()
    self._view:addEventListener(LegionApplyEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(LegionApplyEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    --请求
    self._view:addEventListener(LegionApplyEvent.LEGION_DETAIL_REQ, self, self.onGetLegionInfoReq)
    self._view:addEventListener(LegionApplyEvent.LEGION_SEARCH_REQ, self, self.onSearchResultReq)
    self._view:addEventListener(LegionApplyEvent.LEGION_APPLY_REQ, self, self.onApplyResultReq)
    self._view:addEventListener(LegionApplyEvent.LEGION_CREATE_REQ, self, self.onCreateResultReq)
    
    --接收
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220100, self, self.onGetLegionListResp)
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220101, self, self.onGetLegionInfoResp)
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220102, self, self.onApplyResultResp)
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220103, self, self.onCreateResultResp)
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220104, self, self.onSearchResultResp)
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_UPDATE_RECOMMEND, self, self.updateRecommendResp)
    self:addProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_360049, self, self.updateChildLegion49)
end

function LegionApplyModule:removeEventHander()
    self._view:removeEventListener(LegionApplyEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(LegionApplyEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    self._view:removeEventListener(LegionApplyEvent.LEGION_DETAIL_REQ, self, self.onGetLegionInfoReq)
    self._view:removeEventListener(LegionApplyEvent.LEGION_SEARCH_REQ, self, self.onSearchResultReq)
    self._view:removeEventListener(LegionApplyEvent.LEGION_APPLY_REQ, self, self.onApplyResultReq)
    self._view:removeEventListener(LegionApplyEvent.LEGION_CREATE_REQ, self, self.onCreateResultReq)
    
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220100, self, self.onGetLegionListResp)
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220101, self, self.onGetLegionInfoResp)
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220102, self, self.onApplyResultResp)
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220103, self, self.onCreateResultResp)
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220104, self, self.onSearchResultResp)
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_UPDATE_RECOMMEND, self, self.updateRecommendResp)
    self:removeProxyEventListener(GameProxys.LordCity, AppEvent.PROXY_LORDCITY_360049, self, self.updateChildLegion49)
end

function LegionApplyModule:onOpenModule(extraMsg)
    LegionApplyModule.super.onOpenModule(self, extraMsg)
    self:onGetLegionListReq({})
    self._view:updateTabs()
    -- if extraMsg ~= nil and extraMsg.noticeTxt ~= nil then
    --     self:showSysMessage(extraMsg.noticeTxt)
    -- end
end

--------------------收到数据-------------------------

--军团列表
function LegionApplyModule:onGetLegionListResp(data)
    if data.rs == 0 then
        -- 存储数据表 --提供给第军团列表初始化用
        local legionProxy = self:getProxy(GameProxys.Legion)
        legionProxy:setLegionApplyList(data.shortInfos)

        self._view:updateLegionRecommend() -- 没有在数据表中存储
    end
end

------
-- 刷新推荐列表
function LegionApplyModule:updateRecommendResp(data)
    if data.rs == 0 then
        self._view:updateLegionRecommend(data.recommendInfos)
    end
end



--军团详细信息
function LegionApplyModule:onGetLegionInfoResp(data)
    if data.rs == 0 then
        print("onGetLegionInfoResp(data)")
        self._view:onGetLegionInfo(data.detailInfo)
    end
end
--军团申请/取消
function LegionApplyModule:onApplyResultResp(data)
    if data.rs == 0 then
        if data.type == 1 then --申请成功，等待审批
            local tempStr = self:getTextWord(3148)
            self:showSysMessage(tempStr)
            self._view:onApplyResultInfo(data.id,data.type)
            -- 同步申请信息
            self:getProxy(GameProxys.Legion):setUpdateApplyList(data)
        elseif data.type == 3 then --申请成功，直接加入
            self:sendServerMessage(AppEvent.NET_M22, AppEvent.NET_M22_C220012, {})
            local tempStr = self:getTextWord(3149)
            self:showSysMessage(tempStr)
            local moduleName = ModuleName.LegionSceneModule
            self:onShowOtherHandler(moduleName)
            self:onHideSelfHandler()
            --local temp = StringUtils:isFixed64Zero(data.id)
        else -- 取消申请
            -- 同步申请信息
            self:getProxy(GameProxys.Legion):setUpdateApplyList(data)
            local tempStr = self:getTextWord(3150)
            self:showSysMessage(tempStr)
            self._view:onApplyResultInfo(data.id,data.type)
        end 
    end
end
--创建军团结果
function LegionApplyModule:onCreateResultResp(data)
    if data.rs == 0 then
        local atom = StringUtils:fined64ToAtom(data.legionId) --TODO 容错，使用32位就行了
        local roleProxy = self:getProxy(GameProxys.Role)
        roleProxy:setLegionId(data.legionId)
        roleProxy:setRoleAttrValue(PlayerPowerDefine.POWER_LegionId, atom.low)
        roleProxy:sendNotification(AppEvent.PROXY_UPDATE_ROLE_INFO, {})
        self:sendServerMessage(AppEvent.NET_M22, AppEvent.NET_M22_C220012, {})
        local tempStr = self:getTextWord(3151)
        self:showSysMessage(tempStr)
        local moduleName = ModuleName.LegionSceneModule
        self:onShowOtherHandler(moduleName)
        self:onHideSelfHandler()
    end
end
--搜索军团
function LegionApplyModule:onSearchResultResp(data)
    if data.rs == 0 then
        local tempStr = self:getTextWord(3152)
        if data.infos == nil or #data.infos == 0 then
            tempStr = self:getTextWord(3153)
        else
            self._view:onSearchLegionInfos(data.infos)
        end 
        self:showSysMessage(tempStr)
    end
end

--------------------------------------------------
--任命附团推送
function LegionApplyModule:updateChildLegion49(data)
    self._view:updateChildLegion49(data)
end
--------------------------------------------------


----------------------发送请求-------------------------------
function LegionApplyModule:onGetLegionListReq(data)
    print("onGetLegionListReq:")
    self:sendServerMessage(AppEvent.NET_M22, AppEvent.NET_M22_C220100, data) -- 打开发送请求
end

function LegionApplyModule:onGetLegionInfoReq(data)
    print("onGetLegionInfoReq:",data.id)
    self:sendServerMessage(AppEvent.NET_M22, AppEvent.NET_M22_C220101, data)
end

function LegionApplyModule:onApplyResultReq(data)
    --print("onApplyResultReq",data.id,data.type)
    self:sendServerMessage(AppEvent.NET_M22, AppEvent.NET_M22_C220102, data)
end

function LegionApplyModule:onCreateResultReq(data)
    --print("onCreateResultReq:",data.way,data.joinway,data.name)
    self:sendServerMessage(AppEvent.NET_M22, AppEvent.NET_M22_C220103, data)
end

function LegionApplyModule:onSearchResultReq(data)
    --print("onSearchResultReq:",data.name)
    self:sendServerMessage(AppEvent.NET_M22, AppEvent.NET_M22_C220104, data)
end

---------------

function LegionApplyModule:onHideSelfHandler()
    local lordCityProxy = self:getProxy(GameProxys.LordCity)
    lordCityProxy:clearChildLegion()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function LegionApplyModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end


