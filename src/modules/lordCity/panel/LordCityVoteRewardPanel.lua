--[[
城主战：投票奖励弹窗
]]
LordCityVoteRewardPanel = class("LordCityVoteRewardPanel", BasicPanel)
LordCityVoteRewardPanel.NAME = "LordCityVoteRewardPanel"

function LordCityVoteRewardPanel:ctor(view, panelName)
    LordCityVoteRewardPanel.super.ctor(self, view, panelName, 300)
end

function LordCityVoteRewardPanel:finalize()
    LordCityVoteRewardPanel.super.finalize(self)
end

function LordCityVoteRewardPanel:initPanel()
	LordCityVoteRewardPanel.super.initPanel(self)
	self:setTitle(true,self:getTextWord(370028))
end

function LordCityVoteRewardPanel:registerEvents()
	LordCityVoteRewardPanel.super.registerEvents(self)
end

function LordCityVoteRewardPanel:onClosePanelHandler()
	self:hide()
end

function LordCityVoteRewardPanel:onShowHandler()
    if self._uiLordCityReward == nil then
        self._uiLordCityReward = UILordCityReward.new(self)
    end
    self._uiLordCityReward:onLordCityRewardUpdate()
end

function LordCityVoteRewardPanel:onVoteRewardUpdate()
    if self._uiLordCityReward then
        self._uiLordCityReward:onVoteRewardUpdate()
    end
end
