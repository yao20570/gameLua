
LegionSceneModule = class("LegionSceneModule", BasicModule)

function LegionSceneModule:ctor()
    LegionSceneModule.super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.isFullScreen = true
    
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self:initRequire()

end

function LegionSceneModule:initRequire()
    require("modules.legionScene.event.LegionSceneEvent")
    require("modules.legionScene.view.LegionSceneView")
end

function LegionSceneModule:finalize()
    LegionSceneModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function LegionSceneModule:initModule()
    LegionSceneModule.super.initModule(self)
    self._view = LegionSceneView.new(self.parent)

    self:addEventHandler()
end

-- function LegionSceneModule:onOpenModule()
--     LegionSceneModule.super.onOpenModule(self)

--     local legionProxy = self:getProxy(GameProxys.Legion)
--     -- 初始化数据发送
--     --军团总信息 请求
--     legionProxy:onTriggerNet220200Req()

--     -- 军团建筑等级信息
--     legionProxy:onTriggerNet220000Req()
    
--     local data = {opt = 0}
--     -- 科技大厅信息
--     legionProxy:onTriggerNet220010Req(data)
--     -- 军团大厅信息
--     legionProxy:onTriggerNet220007Req(data)

--     local tmpData = {id=0, opt=0, type = 0}
--     local tmpData2 = {id=0,opt=0, type = 1}
--     legionProxy:onTriggerNet220002Req(tmpData)
--     TimerManager:addOnce(200, self.onUpdateShopInfoReq, self, tmpData2)


--     self:sendServerMessage(AppEvent.NET_M22,AppEvent.NET_M22_C220300, {})

--     --打开再隐藏
--     self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.MainSceneModule})
--     self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.MapModule})

-- end

-- function LegionSceneModule:onUpdateShopInfoReq(data)
--     local legionProxy = self:getProxy(GameProxys.Legion)
--     legionProxy:onTriggerNet220002Req(data)
-- end


function LegionSceneModule:addEventHandler()
    self._view:addEventListener(LegionSceneEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(LegionSceneEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220101, self, self.updateDetailInfoPanel)
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220100, self, self.onLegionAllListResp)               --刷新同盟列表
    self._view:addEventListener(LegionSceneEvent.LEGIONSCENE_SEARCH_REQ , self, self.onSearchResultReq)
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220104, self, self.onSearchResultResp)
    self:addProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHATPERSON_INFO, self, self.onChatPersonInfoResp)
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_INFO_UPDATE, self, self.onLegionInfoUpdate)
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_INFO_INIT, self, self.onLegionAllListResp)          --初始化军团信息
    self:addProxyEventListener(GameProxys.LegionHelp, AppEvent.PROXY_LEGION_HELP_POINT_UPDATE, self, self.onHelpPointUpdate)  --更新互助红点
    self:addProxyEventListener(GameProxys.DungeonX, AppEvent.PROXY_DUNGEONX_TIP_UPDATE, self, self.onBattlePointUpdate)  --更新战争红点
    self:addProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHAT_INFO, self, self.onGetChatInfoResp)             --获取聊天信息
    self:addProxyEventListener(GameProxys.Chat, AppEvent.PROXY_CHAT_RESP, self, self.onGetPrivateChatinfoResp)          --获得私聊作息
    self:addProxyEventListener(GameProxys.Chat, AppEvent.CLEAR_TOOLBAR_CMD, self, self.onClearCmd)
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_INIT_APPLY_INFO, self, self.onLegionApproveResp) -- 审核列表初始化
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_INIT_APPLY_INFO_CHANGE, self, self.onLegionApprove)  --审核后同意刷新列表


    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_UPDATE_WELFARE_TIP, self, self.onWelfarePointUpdate)  --更新福利红点
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220210, self, self.updateLegionSceneAffiche)          --更新公告
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220204, self, self.onLegionApproveClearResp)          --清空审核列表
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_APPROVE_POINT_UPDATE, self, self.onLegionApprovePointUpdate) --更新审核小红点
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_MEMBER_UPDATE, self, self.onLegionMemberUpdate)             --更新军团成员列表
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220221, self, self.onSetJobResp)                      --编辑职位后关闭当前界面
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220201, self, self.onMemberOptResp)                   --转移职位后关闭当前界面
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220008, self, self.onDevoteResp)                      --刷新贡献度
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220007, self, self.onDevoteResp)  
    self:addEventListener(AppEvent.NET_CHATNOTICE,AppEvent.CHAT_NOSEE_UPDATE,self,self.updateNoSeeChatNum)          --刷新未读聊天信息
    self:addEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220013, self, self.onUpdateAllList) -- 福利所升级
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_SCITECH_UPDATE, self, self.onUpdateAllList) -- 科技所升级

    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_M220810_REWARDREDPOINT, self, self.updateRedPoint)

   
end

function LegionSceneModule:removeEventHander()
    self._view:removeEventListener(LegionSceneEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(LegionSceneEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220100, self, self.onLegionAllListResp)
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220101, self, self.updateDetailInfoPanel)
    self._view:removeEventListener(LegionSceneEvent.LEGIONSCENE_SEARCH_REQ , self, self.onSearchResultReq)
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220104, self, self.onSearchResultResp)
    self:removeProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHATPERSON_INFO, self, self.onChatPersonInfoResp)
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_INFO_INIT, self, self.onLegionAllListResp)
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_INFO_UPDATE, self, self.onLegionInfoUpdate)
    self:removeProxyEventListener(GameProxys.LegionHelp, AppEvent.PROXY_LEGION_APPROVE_POINT_UPDATE, self, self.onHelpPointUpdate) 
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_UPDATE_WELFARE_TIP, self, self.onWelfarePointUpdate)
    self:removeProxyEventListener(GameProxys.DungeonX, AppEvent.PROXY_DUNGEONX_TIP_UPDATE, self, self.onBattlePointUpdate)
    self:removeProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHAT_INFO, self, self.onGetChatInfoResp)
    self:removeProxyEventListener(GameProxys.Chat, AppEvent.PROXY_CHAT_RESP, self, self.onGetPrivateChatinfoResp)
    self:removeProxyEventListener(GameProxys.Chat, AppEvent.CLEAR_TOOLBAR_CMD, self, self.onClearCmd)
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_INIT_APPLY_INFO, self, self.onLegionApproveResp) -- 审核列表初始化
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_INIT_APPLY_INFO_CHANGE, self, self.onLegionApprove)  --审核后同意刷新列表


    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220210, self, self.updateLegionSceneAffiche)
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220204, self, self.onLegionApproveClearResp)
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_APPROVE_POINT_UPDATE, self, self.onLegionApprovePointUpdate)
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_MEMBER_UPDATE, self, self.onLegionMemberUpdate)
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220221, self, self.onSetJobResp)
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220201, self, self.onMemberOptResp)
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220008, self, self.onDevoteResp)
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220007, self, self.onDevoteResp)
    self:removeEventListener(AppEvent.NET_CHATNOTICE,AppEvent.CHAT_NOSEE_UPDATE,self,self.updateNoSeeChatNum)
    self:removeEventListener(AppEvent.NET_M22, AppEvent.NET_M22_C220013, self, self.onUpdateAllList) -- 福利所升级
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_SCITECH_UPDATE, self, self.onUpdateAllList) -- 科技所升级

    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_M220810_REWARDREDPOINT, self, self.updateRedPoint)
end

function LegionSceneModule:onOpenModule(extraMsg)
    LegionSceneModule.super.onOpenModule(self, extraMsg)
    self._view:setTabItemCount()

    --城池系统小红点
    local legionProxy = self:getProxy(GameProxys.Legion)
    legionProxy:onTriggerNet220810Req()

end


function LegionSceneModule:onHideSelfHandler()
    local legionProxy = self:getProxy(GameProxys.Legion)
    legionProxy:closeLegionSoUpdateTip()

    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function LegionSceneModule:onShowOtherHandler(data)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end

function LegionSceneModule:onLegionAllListResp(data)
    self._view:onLegionAllListResp(data.shortInfos)
end

--更新公告
function LegionSceneModule:updateLegionSceneAffiche(data)
    if data.rs >= 0 then
        for k , v in pairs(data.updateList) do
            if v == 5 then
                self._view:updateLegionSceneAffiche(data)
            end
        end
    end
end

-- 返回军团详细信息
function LegionSceneModule:updateDetailInfoPanel(data)
    -- body
    if data.rs == 0 then
        self._view:updateDetailInfoPanel(data.detailInfo)
    end    
end

--搜索军团请求
function LegionSceneModule:onSearchResultReq(data)
    -- logger:info("onSearchResultReq:",data.name)
    self:sendServerMessage(AppEvent.NET_M22, AppEvent.NET_M22_C220104, data)
end

--搜索军团返回
function LegionSceneModule:onSearchResultResp(data)
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

function LegionSceneModule:onChatPersonInfoResp(data)
    if data.rs == 0 then
        self._view:onChatPersonInfoResp(data)
    end
end

function LegionSceneModule:onLegionInfoUpdate(data)
        self._view:onLegionInfoUpdate()
end

--更新审核列表
function LegionSceneModule:onLegionApproveResp(data)
    self._view:onUpdateApplyInfos()
end

-- 返回审批清除列表：拒绝成功
function LegionSceneModule:onLegionApproveClearResp(data)

    if data.rs == 0 then
        self:showSysMessage(self:getTextWord(3010))
    end    
end

function LegionSceneModule:onLegionApprovePointUpdate()
    self._view:onLegionApprovePointUpdate()
end

-- 审批的操作：同意/拒绝  type:操作类型 1同意 2拒绝
-- Resp:220203
function LegionSceneModule:onLegionApprove(data)
    -- body
    if data.rs == 0 then
        if data.type == 1 then
            local roleProxy = self:getProxy(GameProxys.Role)
            roleProxy:sendNotification(AppEvent.PROXY_UPDATE_ROLE_INFO, {})
        elseif data.type == 2 then
            self:showSysMessage(self:getTextWord(3010)) -- [[拒绝成功]]
        end
        self._view:onLegionApproveOptResp(data)
    end    
end



--更新军团列表成员
function LegionSceneModule:onLegionMemberUpdate(data)
    self._view:onLegionMemberUpdate()
end

--编辑职位后关闭当前界面
function LegionSceneModule:onSetJobResp(data)
    -- body
    if data.rs == 0 then
        if data.type == 1 then
            self:showSysMessage(self:getTextWord(3014))
        elseif data.type == 2 then
            self:showSysMessage(self:getTextWord(3013))
        end
        self._view:onSetJobResp(data)
    end    
end


--转移职位后关闭当前界面
function LegionSceneModule:onMemberOptResp(data)
    -- body
    if data.rs == 0 then
        if data.type == 2 then
            self:showSysMessage(self:getTextWord(3017))
        end
        --退出同盟或者解散同盟，就不用刷新界面了
        if data.type ~=3 and data.type ~=4 then
            self._view:onMemberOptResp(data)
        end
    end    
end

--更新互助小红点
function LegionSceneModule:onHelpPointUpdate(data)
    self._view:onHelpPointUpdate() 
end

--更新福利红点
function LegionSceneModule:onWelfarePointUpdate(data)
    self._view:onWelfarePointUpdate() 
end

--更新福利红点
function LegionSceneModule:onBattlePointUpdate(data)
    self._view:onBattlePointUpdate() 
end

-- 更新贡献度
function LegionSceneModule:onDevoteResp(data)
    if data.rs == 0 then
        self._view:onDevoteResp(data.armyInfo)
    end
end


--更新聊天
function LegionSceneModule:onGetChatInfoResp(data)
    self._view:onGetChatInfoResp(data)
end

--获取私人聊天信息
function LegionSceneModule:onGetPrivateChatinfoResp(data)
    self._view:onGetPrivateChatInfoResp(data)
end

 --刷新未读聊天信息
function LegionSceneModule:updateNoSeeChatNum(data)
    self._view:updateNoSeeChatNum(data)
end


function LegionSceneModule:onClearCmd()
    self._view:onClearCmd()
end

-- 升级完毕请求最新军团数据
function LegionSceneModule:onUpdateAllList()
    local legionProxy = self:getProxy(GameProxys.Legion)
    legionProxy:onTriggerNet220600Req({})
end

function LegionSceneModule:updateRedPoint(data) 
        self._view:updateRedPoint(data)
end