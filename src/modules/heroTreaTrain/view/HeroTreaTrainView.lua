
HeroTreaTrainView = class("HeroTreaTrainView", BasicView)

function HeroTreaTrainView:ctor(parent)
    HeroTreaTrainView.super.ctor(self, parent)
end

function HeroTreaTrainView:finalize()
    HeroTreaTrainView.super.finalize(self)
end

function HeroTreaTrainView:registerPanels()
    HeroTreaTrainView.super.registerPanels(self)

    require("modules.heroTreaTrain.panel.HeroTreaTrainPanel")
    self:registerPanel(HeroTreaTrainPanel.NAME, HeroTreaTrainPanel)

    require("modules.heroTreaTrain.panel.HeroTreaAdvancePanel")
    self:registerPanel(HeroTreaAdvancePanel.NAME, HeroTreaAdvancePanel)

    require("modules.heroTreaTrain.panel.HeroTreaPurifyPanel")
    self:registerPanel(HeroTreaPurifyPanel.NAME, HeroTreaPurifyPanel)
    
end

function HeroTreaTrainView:initView()
    local panel = self:getPanel(HeroTreaTrainPanel.NAME)
    panel:show()
end

function HeroTreaTrainView:saveCurTreasureData(data)
    self.curData = data
end
function HeroTreaTrainView:getCurTreasureData()
    return self.curData
end
function HeroTreaTrainView:treasureInfoChange()
    local proxy = self:getProxy(GameProxys.HeroTreasure)
    local newDate = proxy:getTreasureInfoByDbId(self.curData.id)
    self:saveCurTreasureData(newDate)
    local heroTreaAdvancePanel = self:getPanel(HeroTreaAdvancePanel.NAME)
    heroTreaAdvancePanel:updateView()
    local heroTreaPurifyPanel = self:getPanel(HeroTreaPurifyPanel.NAME)
    heroTreaPurifyPanel:updateView()
end
function HeroTreaTrainView:postInfoChange()
    -- proxy = self:getProxy(GameProxys.HeroTreasure)
    --local newDate = proxy:getTreasureInfoByDbId(self.curData.id)
    --self:saveCurTreasureData(newDate)
    local heroTreaAdvancePanel = self:getPanel(HeroTreaAdvancePanel.NAME)
    heroTreaAdvancePanel:updateView()
    local heroTreaPurifyPanel = self:getPanel(HeroTreaPurifyPanel.NAME)
    heroTreaPurifyPanel:updateView()
end
function HeroTreaTrainView:purifySuccessHandler()
    local heroTreaPurifyPanel = self:getPanel(HeroTreaPurifyPanel.NAME)
    heroTreaPurifyPanel:purifySuccess()
end
function HeroTreaTrainView:advanceSuccessHandler(time)
    local heroTreaAdvancePanel = self:getPanel(HeroTreaAdvancePanel.NAME)
    heroTreaAdvancePanel:advanceSuccessHandler(time)
end
function HeroTreaTrainView:advanceFailHandler(data)
    local heroTreaAdvancePanel = self:getPanel(HeroTreaAdvancePanel.NAME)
    heroTreaAdvancePanel:advanceFailHandler(data)
end





