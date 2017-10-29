
HeroTreaTrainPanel = class("HeroTreaTrainPanel", BasicPanel)
HeroTreaTrainPanel.NAME = "HeroTreaTrainPanel"

function HeroTreaTrainPanel:ctor(view, panelName)
    HeroTreaTrainPanel.super.ctor(self, view, panelName,true)

end

function HeroTreaTrainPanel:finalize()
    HeroTreaTrainPanel.super.finalize(self)
end

function HeroTreaTrainPanel:initPanel()
	HeroTreaTrainPanel.super.initPanel(self)
	self._tabControl = UITabControlOld.new(self,self.canTurn)
    self._tabControl:addTabPanel(HeroTreaAdvancePanel.NAME, self:getTextWord(3800))
    self._tabControl:addTabPanel(HeroTreaPurifyPanel.NAME, self:getTextWord(3801))
    self._tabControl:setTabSelectByName(HeroTreaAdvancePanel.NAME)
    self:setTitle(true, "baojupeiyang", true)
    --self:setTitle(true, self:getTextWord(3804))
end
function HeroTreaTrainPanel:canTurn(panelName)

    if panelName ==  HeroTreaPurifyPanel.NAME then
        local treasureData = self.view:getCurTreasureData()
        if treasureData.color <= 2 then
            self:showSysMessage(self:getTextWord(3815))
            return false
        end
    end

    return true

end

-- function HeroTreaTrainPanel:onShowHandler()
--     -- self._tabControl._changConditionFunc = self.canTurn
-- end

function HeroTreaTrainPanel:setOldSelectIndex(index)
	index = index or 1
	self._tabControl:setOldSelectIndex(index)
end
function HeroTreaTrainPanel:registerEvents()
	HeroTreaTrainPanel.super.registerEvents(self)
end
function HeroTreaTrainPanel:onClosePanelHandler()
    self.view:dispatchEvent(HeroTreaTrainEvent.HIDE_SELF_EVENT)
end