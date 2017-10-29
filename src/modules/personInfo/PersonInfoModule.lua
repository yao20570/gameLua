
PersonInfoModule = class("PersonInfoModule", BasicModule)

function PersonInfoModule:ctor()
    PersonInfoModule .super.ctor(self)

    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function PersonInfoModule:initRequire()
    require("modules.personInfo.event.PersonInfoEvent")
    require("modules.personInfo.view.PersonInfoView")
end

function PersonInfoModule:finalize()
    PersonInfoModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function PersonInfoModule:initModule()
    PersonInfoModule.super.initModule(self)
    self._view = PersonInfoView.new(self.parent)
      
    self:addEventHandler()
end

function PersonInfoModule:addEventHandler()
    self._view:addEventListener(PersonInfoEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(PersonInfoEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:addEventListener(PersonInfoEvent.HIDE_OTHER_EVENT, self, self.onHideOtherHandler)

    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoHandler)


    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_LEGION_MAINSCENE_BUILDING_UPDATE, self, self.updateLegionName)

    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_ITEMINFO_UPDATE, self, self.onItemUpdateResp)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_POWER, self, self.updateRolePowerHandler)
    self:addProxyEventListener(GameProxys.Skill, AppEvent.PROXY_SKILL_INFO_UPDATE, self, self.skillUpdateHandler)
    self:addProxyEventListener(GameProxys.Building, AppEvent.PROXY_BUILDING_MULT_UPDATE, self, self.buildingUpdateHandler)
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_INFO_UPDATE, self, self.onLegionInfoUpdate)
    self:addProxyEventListener(GameProxys.Building, AppEvent.BUILDING_AUTO_UPGRATE, self, self.onAutoUpgrateUpdate)
    self:addProxyEventListener(GameProxys.System, AppEvent.TIME_AUTO_UPGRATE, self, self.onUpgrateTimeHandle)
    --国策兵法
    self:addProxyEventListener(GameProxys.Talent, AppEvent.PROXY_TALENT_UPDATE, self, self.onTalentUpdate)
    self:addProxyEventListener(GameProxys.Talent, AppEvent.PROXY_TALENT_UPDATE_SINGLE, self, self.onTalentUpdateSingle)
    self:addProxyEventListener(GameProxys.Talent, AppEvent.PROXY_TALENT_USED, self, self.onTalentUsed)

    --背包数量变化
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_BUFF_NUM, self, self.onBagNumChang)
    -- 头像修改
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_HEAD, self, self.onRoleHeadUpdate)
    --特效提示显示变化
    self:addProxyEventListener(GameProxys.Skill,AppEvent.PROXY_UPDATE_ICON_EFFECT,self,self.updateEffectIcon)

    self._view:addEventListener(PersonInfoEvent.Energy_Buy_Req, self, self.onSendEnergyBuy)
    self._view:addEventListener(PersonInfoEvent.Energy_Can_Buy_Req, self, self.onSendCanBuyEnergy)
    self._view:addEventListener(PersonInfoEvent.Item_Reward_Req, self, self.onSendItemBtnMsg)
    self._view:addEventListener(PersonInfoEvent.Item_Skill_Req, self, self.onSendSkillMsg)
    self._view:addEventListener(PersonInfoEvent.Build_Upgrate_Req, self, self.onSendBuildUpgrate)
    self._view:addEventListener(PersonInfoEvent.Build_Upgrate_Buy_Vip_Req, self, self.buyVipBuilding)--vip

    self:addEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20001, self, self.onDetailsMRResp)
    self:addEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20003, self, self.onDetailsBoomResp)
    self:addEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20004, self, self.onDetailsCommandResp)
    self:addEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20005, self, self.onDetailsPrestigeResp)
    -- self:addEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20011, self, self.onDetailsEnergyResp)
    -- self:addEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20013, self, self.onCanBuyEnergyResp)

    -- self:addEventListener(AppEvent.NET_M10,AppEvent.NET_M10_C100001, self, self.onBuildUpgrateResp)
    self:addEventListener(AppEvent.NET_M10,AppEvent.NET_M10_C100003, self, self.onBuildUpgrateCancelResp)
    self:addEventListener(AppEvent.NET_M10,AppEvent.NET_M10_C100004, self, self.onBuildUpgrateAccelerateResp)


end

function PersonInfoModule:removeEventHander()
    self._view:removeEventListener(PersonInfoEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(PersonInfoEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:removeEventListener(PersonInfoEvent.HIDE_OTHER_EVENT, self, self.onHideOtherHandler)

    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoHandler)

    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_LEGION_MAINSCENE_BUILDING_UPDATE, self, self.updateLegionName)

    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_ITEMINFO_UPDATE, self, self.onItemUpdateResp)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_POWER, self, self.updateRolePowerHandler)
    self:removeProxyEventListener(GameProxys.Skill, AppEvent.PROXY_SKILL_INFO_UPDATE, self, self.skillUpdateHandler)
    self:removeProxyEventListener(GameProxys.Building, AppEvent.PROXY_BUILDING_MULT_UPDATE, self, self.buildingUpdateHandler)
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_INFO_UPDATE, self, self.onLegionInfoUpdate)
    self:removeProxyEventListener(GameProxys.Building, AppEvent.BUILDING_AUTO_UPGRATE, self, self.onAutoUpgrateUpdate)
    self:removeProxyEventListener(GameProxys.System, AppEvent.TIME_AUTO_UPGRATE, self, self.onUpgrateTimeHandle)
    
    self:removeProxyEventListener(GameProxys.Talent, AppEvent.PROXY_TALENT_UPDATE, self, self.onTalentUpdate)
    self:removeProxyEventListener(GameProxys.Talent, AppEvent.PROXY_TALENT_UPDATE_SINGLE, self, self.onTalentUpdateSingle)
    self:removeProxyEventListener(GameProxys.Talent, AppEvent.PROXY_TALENT_USED, self, self.onTalentUsed)
    --背包数量变化
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_BUFF_NUM, self, self.onBagNumChang)
    -- 头像修改
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_HEAD, self, self.onRoleHeadUpdate)
    --特效提示修改
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ICON_EFFECT, self,self.updateEffectIcon)

    self._view:removeEventListener(PersonInfoEvent.Energy_Buy_Req, self, self.onSendEnergyBuy)
    self._view:removeEventListener(PersonInfoEvent.Energy_Can_Buy_Req, self, self.onSendCanBuyEnergy)
    self._view:removeEventListener(PersonInfoEvent.Item_Reward_Req, self, self.onSendItemBtnMsg)
    self._view:removeEventListener(PersonInfoEvent.Item_Skill_Req, self, self.onSendSkillMsg)
    self._view:removeEventListener(PersonInfoEvent.Build_Upgrate_Req, self, self.onSendBuildUpgrate)
    self._view:removeEventListener(PersonInfoEvent.Build_Upgrate_Buy_Vip_Req, self, self.buyVipBuilding)

    self:removeEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20001, self, self.onDetailsMRResp)
    self:removeEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20003, self, self.onDetailsBoomResp)
    self:removeEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20004, self, self.onDetailsCommandResp)
    self:removeEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20005, self, self.onDetailsPrestigeResp)
    -- self:removeEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20011, self, self.onDetailsEnergyResp)
    -- self:removeEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20013, self, self.onCanBuyEnergyResp)

    -- self:removeEventListener(AppEvent.NET_M10,AppEvent.NET_M10_C100001, self, self.onBuildUpgrateResp)
    self:removeEventListener(AppEvent.NET_M10,AppEvent.NET_M10_C100003, self, self.onBuildUpgrateCancelResp)
    self:removeEventListener(AppEvent.NET_M10,AppEvent.NET_M10_C100004, self, self.onBuildUpgrateAccelerateResp)

end

function PersonInfoModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function PersonInfoModule:onShowOtherHandler(data)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end

function PersonInfoModule:onHideOtherHandler(data)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, data)
end

function PersonInfoModule:onOpenModule()
    PersonInfoModule.super.onOpenModule(self)
    self:updateRoleInfoHandler({})
    self._view:setFirstPanelShow()

    --声望领取状态
    --TODO 最好就服务端主动推送更新
    self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20010, {state=0})

    local skillProxy =self:getProxy(GameProxys.Skill)
    skillProxy:isLevelUpSkill()
end


function PersonInfoModule:onSendCanBuyEnergy(data)
    -- self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20013, {})
end

function PersonInfoModule:onSendEnergyBuy(data)
    -- self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20011, {})
end

-----------------------------------------------------------
-- 发送协议

-- 建筑的请求协议
function PersonInfoModule:onSendBuildUpgrate(data)
    -- body
    local buildingProxy = self:getProxy(GameProxys.Building)
    local sendData = {}
    local inx = data.inx
    if inx == 0 then
        --升级
        sendData.index = data.index --建筑位置
        sendData.type = data.type --1普通升级 2金币升级
        sendData.buildingType = data.buildingType --建筑类型

        buildingProxy:onTriggerNet280001Req(sendData) --请求建筑升级
--        self:sendServerMessage(AppEvent.NET_M10, AppEvent.NET_M10_C100001, sendData)

    elseif inx == 1 then
            --取消
            sendData.buildingType = data.buildingType --建筑类型
            sendData.index = data.index --建筑位置
            sendData.order = data.order --nil表示建筑 -1

        buildingProxy:onTriggerNet280003Req(sendData) --请求建筑取消
--            self:sendServerMessage(AppEvent.NET_M10, AppEvent.NET_M10_C100003, sendData)

        elseif inx == 2 then
                --加速
                sendData.buildingType = data.buildingType --建筑类型
                sendData.index = data.index --建筑位置
                sendData.useType = data.useType --1金币全部加速 2：道具1 3：道具2 4：道具3
                sendData.order = data.order ---1表示建筑

        buildingProxy:onTriggerNet280004Req(sendData) --请求建筑加速
--                self:sendServerMessage(AppEvent.NET_M10, AppEvent.NET_M10_C100004, sendData)
    end

end

function PersonInfoModule:onSendItemBtnMsg(data)
    -- body
    local sendData = {}
    local index = data.index
    if index == 0 then
        self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20001, sendData)
    elseif index == 1 then
            self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20003, sendData)
        elseif index == 2 then
                sendData.type = data.type
                self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20005, sendData)
            elseif index == 3 then
                    sendData.type = data.type
                    self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20004, sendData)
    end
end

function PersonInfoModule:onSendSkillMsg(data)
    -- body
    local sendData = {}
    local proxy = self:getProxy(GameProxys.Skill)
    local index = data.index
    if index == 0 then -- 升级
        sendData.skillId = data.ID
        sendData.type = data.type
        -- self:sendServerMessage(AppEvent.NET_M12, AppEvent.NET_M12_C120001, sendData)
        proxy:onTriggerNet120001Req(sendData)
    elseif index == 1 then -- 重置
        sendData = {}
        -- self:sendServerMessage(AppEvent.NET_M12, AppEvent.NET_M12_C120002, {})
        proxy:onTriggerNet120002Req(sendData)
    end

end

-----------------------------------------------------------
-- 接收协议
-----------------------------------------------------------

-- 军团信息更新
function PersonInfoModule:onLegionInfoUpdate()
    -- body
    self._view:onLegionInfoUpdate()
end


function PersonInfoModule:buildingUpdateHandler(data)
    -- body
    self._view:buildingUpdateResp(data)
end

-- 建筑升级
-- function PersonInfoModule:onBuildUpgrateResp(data)
    -- body
    -- if data.rs == 0 then
    --     -- self._view:buildingUpdateResp(data)
    --     -- self._view:onBuildUpgrateResp(data)
    -- end
-- end

-- 取消建筑升级
function PersonInfoModule:onBuildUpgrateCancelResp(data)
    -- body
    if data.rs == 0 then
        self:showSysMessage(self:getTextWord(543))
    end
end

-- 加速建筑升级
function PersonInfoModule:onBuildUpgrateAccelerateResp(data)
    -- body
    -- if data.rs == 0 then
    -- end
end

function PersonInfoModule:updateRoleInfoHandler(data)
    -- logger:info("------刷新界面PROXY_UPDATE_ROLE_INFO----------")
    self._view:onRoleInfoUpdateResp()   --TODO 全体刷新效率
end

function PersonInfoModule:updateRolePowerHandler(data)
    -- logger:info("------刷新主公界面单个列表项：PROXY_UPDATE_ROLE_POWER----------")
    self._view:updateRolePowerHandler(data)   --TODO 刷新繁荣OR体力
end



function PersonInfoModule:onItemUpdateResp(data)
    -- body
    -- logger:info("------道具更新：战法秘籍更新OR统率令----------")
    self._view:onItemUpdateResp() 
end

-- 是否可以购买体力
function PersonInfoModule:onCanBuyEnergyResp(data)
    -- body
    if data.rs >= 0 then
        -- local roleProxy = self:getProxy(GameProxys.Role)
--        roleProxy:setEnergyNeedMoney(data.price)
        self._view:onCanBuyEnergyResp()
    end
end

-- 体力
function PersonInfoModule:onDetailsEnergyResp(data)
    -- logger:info("------onDetailsEnergyResp-----体力---rs="..data.rs)
    if data.rs == 0 then
        self:showSysMessage(self:getTextWord(541))
        self._view:onDetailsEnergyResp()
        
        -- local roleProxy = self:getProxy(GameProxys.Role)
        -- roleProxy:setEnergyNeedMoney(money)
    end
end

-- 军衔
function PersonInfoModule:onDetailsMRResp(data)
    -- logger:info("------onDetailsMRResp----军衔------rs="..data.rs)
    if data.rs == 0 then
        self._view:onDetailsMRResp()
    end
end

-- 繁荣
function PersonInfoModule:onDetailsBoomResp(data)
    -- logger:info("------onDetailsBoomResp------繁荣----rs="..data.rs)
    if data.rs == 0 then
        self:showSysMessage(self:getTextWord(538))
    end
end

-- 统率  
function PersonInfoModule:onDetailsCommandResp(data)
    -- logger:info("------onDetailsCommandResp-----统率升级-----rs="..data.rs)
    if data.rs == 0 then
        self._view:onDetailsCommandResp()
    end
end

-- 声望
function PersonInfoModule:onDetailsPrestigeResp(data)
    -- logger:info("------onDetailsPrestigeResp-----声望-----rs="..data.rs)
    if data.rs == 0 then
        local roleProxy = self:getProxy(GameProxys.Role)
        roleProxy:setPrestigeState(1)


        -- print("-----声望 data.type------",data.type)
        local conf = ConfigDataManager:getConfigById(ConfigData.PrestigeGiveConfig, data.type)
        self:showSysMessage(string.format(self:getTextWord(561), conf.prestige))


        self._view:onMRRewardResp(data)
    end
end

-- 技能
function PersonInfoModule:skillUpdateHandler(data)
    -- body
    local msg = data[1]
    if msg == 120000 then
        self._view:onSkillListResp(data)-- -- 技能信息
    elseif msg == 120001 then
        self._view:onSkillUpResp(data)-- -- 技能升级
    elseif msg == 120002 then
        self._view:onSkillResetResp(data)-- -- 技能重置
    end
end

function PersonInfoModule:onAutoUpgrateUpdate(data)
    -- body
    self._view:onAutoUpgrateUpdate(data)
end

--计时器更新自动升级建筑的倒计时
function PersonInfoModule:onUpgrateTimeHandle()
    self._view:onUpgrateTimeHandle()    
end


--请求购买vip
function PersonInfoModule:buyVipBuilding(sender)
    local buildingProxy = self:getProxy(GameProxys.Building)
    buildingProxy:buyVipBuilding()
--    self:sendServerMessage(AppEvent.NET_M10, AppEvent.NET_M10_C100009,{})
end

function PersonInfoModule:updateLegionName()
    self._view:updateLegionName()    
end

function PersonInfoModule:onTalentUpdate( data )
    self._view:onTalentUpdate()
end

function PersonInfoModule:onTalentUpdateSingle( data )
    self._view:onTalentLevelup(data)
end

function PersonInfoModule:onTalentUsed( data )
    self._view:onTalentUpdate()
    self._view:onTalentTipHide()
end

function PersonInfoModule:onBagNumChang()
    self._view:onBagNumChang()
end

------
-- 头像更新
function PersonInfoModule:onRoleHeadUpdate()
    local panel = self._view:getPanel(PersonInfoDetailsPanel.NAME)
    panel:onRoleHeadUpdate()
end

function PersonInfoModule:updateEffectIcon()
    local panel=self._view:getPanel(PersonInfoPanel.NAME)
    panel:updateLevelUpTip()
    logger:info("图标刷新提示到位")
end