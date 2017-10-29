
DungeonView = class("DungeonView", BasicView)

function DungeonView:ctor(parent)
    DungeonView.super.ctor(self, parent)
end

function DungeonView:finalize()
    DungeonView.super.finalize(self)
end

function DungeonView:registerPanels()
    DungeonView.super.registerPanels(self)

    require("modules.dungeon.panel.DungeonPanel")
    self:registerPanel(DungeonPanel.NAME, DungeonPanel)
    
    require("modules.dungeon.panel.DungeonMapPanel")
    self:registerPanel(DungeonMapPanel.NAME, DungeonMapPanel)
    
    require("modules.dungeon.panel.DungeonCityPanel")
    self:registerPanel(DungeonCityPanel.NAME, DungeonCityPanel)
    
    require("modules.dungeon.panel.DungeonRewardPanel")
    self:registerPanel(DungeonRewardPanel.NAME, DungeonRewardPanel)
    
    require("modules.dungeon.panel.DungeonCityInfoPanel")
    self:registerPanel(DungeonCityInfoPanel.NAME, DungeonCityInfoPanel)
end

function DungeonView:initView()
    local panel = self:getPanel(DungeonMapPanel.NAME)
    panel:show()
end

function DungeonView:updateBgImg(bgIcon)
    local panel = self:getPanel(DungeonMapPanel.NAME)
    panel:updateBgImg(bgIcon)
end

function DungeonView:onDungeonInfoResp(data,type,info)
    local panel = self:getPanel(DungeonMapPanel.NAME)
    panel:setVisible(true)
    panel:onDungeonInfoResp(data,type,info)
end

function DungeonView:onUpdateTili(data)
    local panel = self:getPanel(DungeonMapPanel.NAME)
    panel:setVisible(true)
    panel:updateEnergy(data)
end

function DungeonView:hideCityPanle()
    local panel = self:getPanel(DungeonCityPanel.NAME)
    panel:hide()
end

function DungeonView:isShowRechargeUI(price)
    local panel = self:getPanel(DungeonMapPanel.NAME)
    panel:isShowRechargeUI(price)
end

function DungeonView:getBoxRewardResp(data)
    local panel = self:getPanel(DungeonMapPanel.NAME)
    panel:setBoxesStatus(data.boxes)
    -- panel = self:getPanel(DungeonRewardPanel.NAME)
    -- panel:onRewardBtnStatus()
end

function DungeonView:onBuyTimes(type,index)
    -- local panel = self:getPanel(DungeonMapPanel.NAME)
    -- panel:onBuyTimes(type,index)
end

function DungeonView:onResetData(data)
    local panel = self:getPanel(DungeonMapPanel.NAME)
    panel:onResetData(data)
end

function DungeonView:onBuyTimesResp(data)
    local panel = self:getPanel(DungeonMapPanel.NAME)
    if panel:isVisible() then
        panel:onBuyTimesResp(data)
    end
    
    -- local cityPanel = self:getPanel(DungeonCityPanel.NAME)
    -- if cityPanel:isVisible() then
    --     cityPanel:updateChallengeTimes(data)
    -- end
end

function DungeonView:onFirstPassResp()
    local panel = self:getPanel(DungeonMapPanel.NAME)
    panel:onFirstPassResp()
end

function DungeonView:updateData()
    local panel = self:getPanel(DungeonMapPanel.NAME)
    panel:updateEnergyData()
end

function DungeonView:onGetNewGift()
    local panel = self:getPanel(DungeonMapPanel.NAME)
    panel:onGetNewGift()
end

--------------------------------------------------------------------
function DungeonView:onShowView(extraMsg, isInit)
    DungeonView.super.onShowView(self,extraMsg, isInit)
end