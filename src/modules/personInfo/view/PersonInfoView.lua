
PersonInfoView = class("PersonInfoView", BasicView)

function PersonInfoView:ctor(parent)
    PersonInfoView.super.ctor(self, parent)
end

function PersonInfoView:finalize()
    PersonInfoView.super.finalize(self)
end

function PersonInfoView:registerPanels()
    PersonInfoView.super.registerPanels(self)

    require("modules.personInfo.panel.PersonInfoPanel")
    self:registerPanel(PersonInfoPanel.NAME, PersonInfoPanel)

    require("modules.personInfo.panel.PersonInfoDetailsPanel")
    self:registerPanel(PersonInfoDetailsPanel.NAME,PersonInfoDetailsPanel)
    
    require("modules.personInfo.panel.PersonInfoSkillPanel")
    self:registerPanel(PersonInfoSkillPanel.NAME,PersonInfoSkillPanel)
    
    require("modules.personInfo.panel.PersonInfoBuildPanel")
    self:registerPanel(PersonInfoBuildPanel.NAME,PersonInfoBuildPanel)

    require("modules.personInfo.panel.PersonInfoMRRewardPanel")
    self:registerPanel(PersonInfoMRRewardPanel.NAME,PersonInfoMRRewardPanel)

    require("modules.personInfo.panel.PersonInfoTalentPanel")
    self:registerPanel(PersonInfoTalentPanel.NAME,PersonInfoTalentPanel)

    
    require("modules.personInfo.panel.PersonInfoTalentTipPanel")
    self:registerPanel(PersonInfoTalentTipPanel.NAME,PersonInfoTalentTipPanel)

end

function PersonInfoView:initView()
    self._rewardFlag = nil
    local panel = self:getPanel(PersonInfoPanel.NAME)
    panel:show()
    panel:setHtmlStr("html/help_player.html")
end

function PersonInfoView:setFirstPanelShow()
    local panel = self:getPanel(PersonInfoPanel.NAME)
    panel:setFirstPanelShow()
end

function PersonInfoView:showOtherModule(moduleName)
    self:dispatchEvent(PersonInfoEvent.SHOW_OTHER_EVENT,moduleName)
end
------------------------------------------------------------------
-- all msg req
function PersonInfoView:hideModuleHandler()
    self:dispatchEvent(PersonInfoEvent.HIDE_SELF_EVENT, {})
end

function PersonInfoView:onSendCanEnergyBuy(data)
    self:dispatchEvent(PersonInfoEvent.Energy_Can_Buy_Req, data)
end

function PersonInfoView:onSendEnergyBuy(data)
    self:dispatchEvent(PersonInfoEvent.Energy_Buy_Req, data)
end

function PersonInfoView:onSendItemBtn(data)
    self:dispatchEvent(PersonInfoEvent.Item_Reward_Req,data)
end

function PersonInfoView:onSendSkill(data)
    self:dispatchEvent(PersonInfoEvent.Item_Skill_Req,data)
end

function PersonInfoView:onSendBuild(data)
    self:dispatchEvent(PersonInfoEvent.Build_Upgrate_Req,data)
end

---------------------------------------------------------------------
-- details resp

function PersonInfoView:onShowMRPanel()
    -- body 打开授勋界面
    local panel = self:getPanel(PersonInfoMRRewardPanel.NAME)
    panel:show()
end

function PersonInfoView:onShowAllPanel()
    local panel = self:getPanel(PersonInfoPanel.NAME)
    panel:changeDefaultTabPanel()
end

function PersonInfoView:onHiteAllPanel()
    local panel = self:getPanel(PersonInfoDetailsPanel.NAME)
    panel:hide()
end

function PersonInfoView:onMRRewardResp(data)
    -- body 更新授勋界面
    local panel = self:getPanel(PersonInfoMRRewardPanel.NAME)
    if panel:isInitUI() then
        panel:onMRRewardResp(data)   
    end
end



function PersonInfoView:onLegionInfoUpdate()
    -- body 更新军团信息
    local panelDetails = self:getPanel(PersonInfoDetailsPanel.NAME)
    if panelDetails:isVisible() then
        panelDetails:onLegionInfoUpdate()
    end
end

function PersonInfoView:updateRolePowerHandler(data)
    -- body 
    local panel = self:getPanel(PersonInfoDetailsPanel.NAME)
    if panel:isVisible() then
        panel:updateRolePowerHandler(data)
    end
end

function PersonInfoView:onRoleInfoUpdateResp()
    -- body 更新详细、技能面板数据
    local panelDetails = self:getPanel(PersonInfoDetailsPanel.NAME)
    if panelDetails:isVisible() then
        panelDetails:onUpdateDetailsInfo()
    end
    
    local panelSkill = self:getPanel(PersonInfoSkillPanel.NAME)
    if panelSkill:isVisible() then
        panelSkill:onUpdateSkillInfo()    
    end

    local panelBuild = self:getPanel(PersonInfoBuildPanel.NAME)
    if panelBuild:isVisible() then
        panelBuild:onUpdateBuildInfo()    
    end
    
end

-- 统率升级成功飘字
function PersonInfoView:onDetailsCommandResp()
    -- body
    local panel = self:getPanel(PersonInfoDetailsPanel.NAME)
    panel:onDetailsCommandResp() 
end

-- 军衔升级成功飘字
function PersonInfoView:onDetailsMRResp()
    -- body
    local panel = self:getPanel(PersonInfoDetailsPanel.NAME)
    panel:onDetailsMRResp() 
end

-- 体力购买弹框
function PersonInfoView:onCanBuyEnergyResp()
    -- body
    local panel = self:getPanel(PersonInfoDetailsPanel.NAME)
    panel:onEnergyBuy() 
end

-- 体力购买成功
function PersonInfoView:onDetailsEnergyResp()
    -- body
    local panel = self:getPanel(PersonInfoDetailsPanel.NAME)
    panel:onDetailsEnergyResp() 
end

---------------------------------------------------------------------
-- 道具数量更新 resp
function PersonInfoView:onItemUpdateResp()
    -- 战法秘籍更新
    local panel = self:getPanel(PersonInfoSkillPanel.NAME)
    if panel:isInitUI() then
        panel:onUpdateSkillInfo()
        -- return    
    end

    -- 统率令更新
    panel = self:getPanel(PersonInfoDetailsPanel.NAME)
    if panel:isVisible() then
        panel:onUpdateCMDBook()
        -- return    
    end

end

function PersonInfoView:onSkillListResp(data)
    -- body 技能列表
    local panel = self:getPanel(PersonInfoSkillPanel.NAME)
    panel:onSkillListResp(data)
end

function PersonInfoView:onSkillUpResp(data)
    -- body 升级
    local panel = self:getPanel(PersonInfoSkillPanel.NAME)
    panel:onSkillUpResp(data)    
end

function PersonInfoView:onSkillResetResp(data)
    -- body 重置
    local panel = self:getPanel(PersonInfoSkillPanel.NAME)
    panel:onSkillResetResp(data)    
end

---------------------------------------------------------------------
-- build resp
-- function PersonInfoView:onBuildUpgrateResp(data)
--     -- body 升级
--     local panel = self:getPanel(PersonInfoBuildPanel.NAME)
--     panel:onBuildUpgrateResp(data)    
-- end

function PersonInfoView:onBuildUpgrateCancelResp(data)
    -- body 取消升级
    local panel = self:getPanel(PersonInfoBuildPanel.NAME)
    panel:onBuildUpgrateCancelResp(data)    
end

function PersonInfoView:onBuildUpgrateAccelerateResp(data)
    -- body 加速升级
    local panel = self:getPanel(PersonInfoBuildPanel.NAME)
    panel:onBuildUpgrateAccelerateResp(data)    
end

function PersonInfoView:buildingUpdateResp(data)
    -- body 加速升级
    local panel = self:getPanel(PersonInfoBuildPanel.NAME)
    panel:buildingUpdateResp(data)    
end

function PersonInfoView:onAutoUpgrateUpdate(data)
    -- body 自动升级建筑
    local panel = self:getPanel(PersonInfoBuildPanel.NAME)
    if panel:isVisible() then
        panel:onAutoUpgrateUpdate(data)    
    end
end

function PersonInfoView:onUpgrateTimeHandle(data)
    -- body 自动升级建筑倒计时
    local panel = self:getPanel(PersonInfoBuildPanel.NAME)
    if panel:isVisible() then
        panel:onUpgrateTimeHandle(data)    
    end
end


--------------------------------------------------------------------
function PersonInfoView:onShowView(extraMsg, isInit)
    PersonInfoView.super.onShowView(self,extraMsg, isInit)
end

function PersonInfoView:updateLegionName()
    local panel = self:getPanel(PersonInfoDetailsPanel.NAME)
    panel:updateLegionName()
end

--国策-------------------
function PersonInfoView:onTalentUpdate()
    local panel = self:getPanel( PersonInfoTalentPanel.NAME )
    panel:renderPanel()
end

function PersonInfoView:onTalentLevelup(data)
    local panel = self:getPanel( PersonInfoTalentPanel.NAME )
    panel:renderSingleItem(data)
end

function PersonInfoView:onTalentTipHide()
    local panel = self:getPanel( PersonInfoTalentTipPanel.NAME )
    panel:hide()
end
function PersonInfoView:onBagNumChang()
    local panel = self:getPanel( PersonInfoTalentTipPanel.NAME )
    panel:renderCostItem()
end


function PersonInfoView:renderItemIcon( icon, bg, isMiniIcon, id )
    local proxy = self:getProxy(GameProxys.Talent)
    local iconUrl = ""
    local bgUrl = "images/personInfo/skillbg1.png"
    if isMiniIcon then
        bgUrl = "images/personInfo/skillbg2.png"
    end
    TextureManager:updateImageView( icon, "images/personInfoTalentIcon/"..id..".png" )
    TextureManager:updateImageView( bg, bgUrl )
end