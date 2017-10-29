
HeroTrainView = class("HeroTrainView", BasicView)

function HeroTrainView:ctor(parent)
    HeroTrainView.super.ctor(self, parent)
end

function HeroTrainView:finalize()
    HeroTrainView.super.finalize(self)
end

function HeroTrainView:registerPanels()
    HeroTrainView.super.registerPanels(self)

    require("modules.heroTrain.panel.HeroTrainPanel")
    self:registerPanel(HeroTrainPanel.NAME, HeroTrainPanel)

    require("modules.heroTrain.panel.HeroLvUpPanel")
    self:registerPanel(HeroLvUpPanel.NAME, HeroLvUpPanel)

    require("modules.heroTrain.panel.HeroStarUpPanel")
    self:registerPanel(HeroStarUpPanel.NAME, HeroStarUpPanel)

    require("modules.heroTrain.panel.HeroStrategicsPanel")
    self:registerPanel(HeroStrategicsPanel.NAME, HeroStrategicsPanel)

    require("modules.heroTrain.panel.HeroStrategicsUpPanel")
    self:registerPanel(HeroStrategicsUpPanel.NAME, HeroStrategicsUpPanel)

    require("modules.heroTrain.panel.HeroStrategicsCheckPanel")
    self:registerPanel(HeroStrategicsCheckPanel.NAME, HeroStrategicsCheckPanel)
end

function HeroTrainView:initView()
    local panel = self:getPanel(HeroTrainPanel.NAME)
    panel:show()
end

function HeroTrainView:updateLvUpView(data)
    local panel = self:getPanel(HeroLvUpPanel.NAME)
    panel:updateLvUpView(data)
end

function HeroTrainView:saveCurData(data)
    self.curData = data
    local TrainPanel = self:getPanel(HeroTrainPanel.NAME)
    TrainPanel:checkHeroLv()
end

function HeroTrainView:readCurData()
    return self.curData
end

function HeroTrainView:lvUpSuccess()
    local TrainPanel = self:getPanel(HeroTrainPanel.NAME)
    TrainPanel:checkHeroLv()
    local panel = self:getPanel(HeroLvUpPanel.NAME)
    panel:lvUpSuccess()
    local starPanel = self:getPanel(HeroStarUpPanel.NAME)
    starPanel:starUpSuccess()
    local strategicsPanel = self:getPanel(HeroStrategicsPanel.NAME)
    strategicsPanel:onUpdateView()
end

function HeroTrainView:updateBfView()
    local strategicsPanel = self:getPanel(HeroStrategicsPanel.NAME)
    strategicsPanel:closeInfoPanel()
end

function HeroTrainView:setCurTrainType(TrainType)
    self.curTrainType = TrainType
end

function HeroTrainView:getCurTrainType()
    return self.curTrainType
end

function HeroTrainView:updateLv()
    local panel = self:getPanel(HeroLvUpPanel.NAME)
    panel:updateLv()
end