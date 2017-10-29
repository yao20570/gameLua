
LordCityView = class("LordCityView", BasicView)

function LordCityView:ctor(parent)
    LordCityView.super.ctor(self, parent)
end

function LordCityView:finalize()
    LordCityView.super.finalize(self)
end

function LordCityView:registerPanels()
    LordCityView.super.registerPanels(self)

    require("modules.lordCity.panel.LordCityPanel")
    self:registerPanel(LordCityPanel.NAME, LordCityPanel)

    require("modules.lordCity.panel.LordCityInfoPanel")
    self:registerPanel(LordCityInfoPanel.NAME, LordCityInfoPanel)

    require("modules.lordCity.panel.LordCityBuffPanel")
    self:registerPanel(LordCityBuffPanel.NAME, LordCityBuffPanel)

    require("modules.lordCity.panel.LordCityBattlePanel")
    self:registerPanel(LordCityBattlePanel.NAME, LordCityBattlePanel)

    require("modules.lordCity.panel.LordCityDefeatPanel")
    self:registerPanel(LordCityDefeatPanel.NAME, LordCityDefeatPanel)

    require("modules.lordCity.panel.LordCityVotePanel")
    self:registerPanel(LordCityVotePanel.NAME, LordCityVotePanel)

    require("modules.lordCity.panel.LordCityVoteRewardPanel")
    self:registerPanel(LordCityVoteRewardPanel.NAME, LordCityVoteRewardPanel)

    require("modules.lordCity.panel.LordCityTeamSetPanel")
    self:registerPanel(LordCityTeamSetPanel.NAME, LordCityTeamSetPanel)

    require("modules.lordCity.panel.LordCityTeamInfoPanel")
    self:registerPanel(LordCityTeamInfoPanel.NAME, LordCityTeamInfoPanel)

    require("modules.lordCity.panel.LordCityPowerPanel")
    self:registerPanel(LordCityPowerPanel.NAME, LordCityPowerPanel)

    require("modules.lordCity.panel.LordCityMainPanel")
    self:registerPanel(LordCityMainPanel.NAME, LordCityMainPanel)
end

function LordCityView:initView()
    local panel = self:getPanel(LordCityPanel.NAME)
    panel:show()
end

--------------------------------------------------------------------
-- 聊天
function LordCityView:onGetChatInfoResp(data)
    local panel = self:getPanel(LordCityMainPanel.NAME)
    if panel:isVisible() == true then
        panel:updateChatInfos(data.chats)
    end
    local panel = self:getPanel(LordCityBattlePanel.NAME)
    if panel:isVisible() == true then
        panel:updateChatInfos(data.chats)
    end
end

function LordCityView:onUpdateBarrage(data)
    local panel = self:getPanel(LordCityMainPanel.NAME)
    if panel:isVisible() == true then
        panel:onUpdateBarrage(data)
    end
    local panel = self:getPanel(LordCityBattlePanel.NAME)
    if panel:isVisible() == true then
       panel:onUpdateBarrage(data)
    end

end
function LordCityView:onGetPrivateChatInfoResp(_data)
    local data = {}
    data[1] = {name = _data.name,playerId = _data.playerId,type = _data.type,iconId = _data.iconId,context = _data.context}

    local panel = self:getPanel(LordCityMainPanel.NAME)
    if panel:isVisible() == true then
        panel:updateChatInfos(data)
    end

    local panel = self:getPanel(LordCityBattlePanel.NAME)
    if panel:isVisible() == true then
        panel:updateChatInfos(data)
    end
end

--------------------------------------------------------------------
-- 来自通知的更新
--------------------------------------------------------------------
function LordCityView:onDefMapUpdate()
    local panel = self:getPanel(LordCityDefeatPanel.NAME)
    if panel:isVisible() then
        panel:onDefMapUpdate()
    end
end

function LordCityView:onPlayerInfoUpdate()
    local panel = self:getPanel(LordCityDefeatPanel.NAME)
    if panel:isVisible() then
        panel:onPlayerInfoUpdate()
    end
end

function LordCityView:onCityInfoMapUpdate()
    local panel = self:getPanel(LordCityMainPanel.NAME)
    if panel:isVisible() then
        panel:onCityInfoMapUpdate()
    end
end

function LordCityView:onBuffMapUpdate()
    local panel = self:getPanel(LordCityBuffPanel.NAME)
    if panel:isVisible() then
        panel:onBuffMapUpdate()
    end
end

function LordCityView:onBuffUpUpdate()
    local panel = self:getPanel(LordCityBuffPanel.NAME)
    if panel:isVisible() then
        panel:onBuffUpUpdate()
    end
end

-- 投票竞猜
function LordCityView:onVoteInfoUpdate()
    local panel = self:getPanel(LordCityVotePanel.NAME)
    if panel:isVisible() then
        panel:onVoteInfoUpdate()
    end
end

-- 投票参与奖励
function LordCityView:onVoteRewardUpdate()
    local panel = self:getPanel(LordCityVoteRewardPanel.NAME)
    if panel:isVisible() then
        panel:onVoteRewardUpdate()
    end
end

function LordCityView:onCityInfoUpdate()
    local panel = self:getPanel(LordCityBattlePanel.NAME)
    if panel:isVisible() then
        panel:onCityInfoUpdate()  --主要是更新战场界面信息
    end

    local panel = self:getPanel(LordCityInfoPanel.NAME)
    if panel:isVisible() then
        panel:onCityInfoUpdate()
    end
end

function LordCityView:onDefTeamUpdate()
    local panel = self:getPanel(LordCityDefeatPanel.NAME)
    if panel:isVisible() then
        panel:onDefTeamUpdate()  --主要是更新玩家阵型信息
    end

    panel = self:getPanel(LordCityTeamSetPanel.NAME)
    if panel:isVisible() then
        panel:onClosePanelHandler()  --关闭设置阵型界面
    end

end

function LordCityView:onStateUpdate(data)
    local panel = self:getPanel(LordCityMainPanel.NAME)
    if panel:isVisible() then
        panel:onStateUpdate(data)  --更新主界面城池的开启状态显示
    end
end

function LordCityView:onStateChangeUpdate(data)
    local panel = self:getPanel(LordCityBattlePanel.NAME)
    if panel:isVisible() then
        panel:onStateChangeUpdate(data)  --更城池占领状态
    end

    panel = self:getPanel(LordCityInfoPanel.NAME)
    if panel:isVisible() then
        panel:hide()
    end
    panel = self:getPanel(LordCityDefeatPanel.NAME)
    if panel:isVisible() then
        panel:hide()
    end    
    panel = self:getPanel(LordCityVoteRewardPanel.NAME)
    if panel:isVisible() then
        panel:hide()
    end
    panel = self:getPanel(LordCityTeamSetPanel.NAME)
    if panel:isVisible() then
        panel:hide()
    end

end

function LordCityView:onRewardUpdate(data)
    local panel = self:getPanel(LordCityMainPanel.NAME)
    if panel:isVisible() then
        panel:onRewardUpdate(data)  --更新主界面城池的宝箱领取状态
    end
end

function LordCityView:onDefTeamDie()
    local panel = self:getPanel(LordCityBattlePanel.NAME)
    if panel:isVisible() then
        panel:onDefTeamDie()  --防守部队被击杀发出通知
    end
end

function LordCityView:onPowerUpdate(data)
    local panel = self:getPanel(LordCityPowerPanel.NAME)
    if panel:isVisible() then
        panel:onPowerUpdate(data)
    end
    local panel = self:getPanel(LordCityMainPanel.NAME)
    if panel:isVisible() then
        panel:onQualifyUpdate()
    end
end

--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
function LordCityView:onShowView(extraMsg, isInit)
    LordCityView.super.onShowView(self,extraMsg, isInit, true)

    local LordCity = self:getProxy(GameProxys.LordCity)
    if LordCity:getIsReconnect() then
        LordCity:setIsReconnect(false)
        local panel = self:getPanel(LordCityBattlePanel.NAME)
        panel:hide()
        local panel = self:getPanel(LordCityMainPanel.NAME)
        panel:show()
    end
end
--------------------------------------------------------------------