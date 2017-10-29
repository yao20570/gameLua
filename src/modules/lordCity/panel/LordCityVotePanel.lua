--[[
城主战：投票弹窗
]]
LordCityVotePanel = class("LordCityVotePanel", BasicPanel)
LordCityVotePanel.NAME = "LordCityVotePanel"

function LordCityVotePanel:ctor(view, panelName)
    LordCityVotePanel.super.ctor(self, view, panelName, 810)

end

function LordCityVotePanel:finalize()
    LordCityVotePanel.super.finalize(self)
end

function LordCityVotePanel:initPanel()
	LordCityVotePanel.super.initPanel(self)

	self:setTitle(true,self:getTextWord(370027))

	self._lordCityProxy = self:getProxy(GameProxys.LordCity)

    self._uiLordCityVote = nil
end

function LordCityVotePanel:registerEvents()
	LordCityVotePanel.super.registerEvents(self)
end

function LordCityVotePanel:onClosePanelHandler()
	self:hide()
end

function LordCityVotePanel:onShowHandler()

    if self._uiLordCityVote == nil then
        self._uiLordCityVote = UILordCityVote.new(self)
        self._uiLordCityVote:setCallbackReward(function() 
            local panel = self:getPanel(LordCityVoteRewardPanel.NAME)
            panel:show() 
        end)
    end
    self._uiLordCityVote:onLordCityVoteUpdate()
end

---- 协议更新列表信息
function LordCityVotePanel:onVoteInfoUpdate()
	self:onShowHandler()
end
