
PartsGodView = class("PartsGodView", BasicView)

function PartsGodView:ctor(parent)
    PartsGodView.super.ctor(self, parent)
end

function PartsGodView:finalize()
    PartsGodView.super.finalize(self)
end

function PartsGodView:registerPanels()
    PartsGodView.super.registerPanels(self)

    -- require("modules.partsGod.panel.PartsGodPanel")
    -- self:registerPanel(PartsGodPanel.NAME, PartsGodPanel)

    require("modules.partsGod.panel.PartsGodCreatePanel")
    self:registerPanel(PartsGodCreatePanel.NAME, PartsGodCreatePanel)

    -- require("modules.partsGod.panel.PartsGodGiftPanel")
    -- self:registerPanel(PartsGodGiftPanel.NAME, PartsGodGiftPanel)

    require("modules.partsGod.panel.PartsGodRankPanel")
    self:registerPanel(PartsGodRankPanel.NAME, PartsGodRankPanel)

    require("modules.partsGod.panel.PartsGodRankRewardPanel")
    self:registerPanel(PartsGodRankRewardPanel.NAME, PartsGodRankRewardPanel)

    require("modules.partsGod.panel.PartsGodCreateMainPanel")
    self:registerPanel(PartsGodCreateMainPanel.NAME, PartsGodCreateMainPanel)
end

function PartsGodView:initView()
    local panel = self:getPanel(PartsGodCreatePanel.NAME)
    panel:show()
end


function PartsGodView:onShowView(extraMsg, isInit, isAutoUpdate)
    isInit = true
    isAutoUpdate = true
    PartsGodView.super.onShowView(self,extraMsg, isInit, isAutoUpdate)
   -- local panel = self:getPanel(PartsGodCreatePanel.NAME)
   -- panel:show()
end

function PartsGodView:hideModuleHandler()
    self:dispatchEvent(PartsGodEvent.HIDE_SELF_EVENT, {})
end

function PartsGodView:setActivityId(activityId)
    self._activityId = activityId
end

function PartsGodView:getActivityId()
    return self._activityId
end

function PartsGodView:onGetRewardResp(data)
    local panel = self:getPanel(PartsGodCreatePanel.NAME)
    panel:onGetRewardResp(data)

    self._score = data.jifen
end

function PartsGodView:onGetScore()
    return  self._score
end

function PartsGodView:onChatPersonInfoResp(data)
    local panel = self:getPanel(PartsGodCreatePanel.NAME)
    panel:onChatPersonInfoResp(data)
end

function PartsGodView:onSetPartsGodFree()
    local panel = self:getPanel(PartsGodCreatePanel.NAME)
    panel:onSetPartsGodFree()
end

function PartsGodView:onUpdateRankData()
    local proxy = self:getProxy(GameProxys.Activity)
    if not proxy:isUpdate() then
        return
    end

    local panel = self:getPanel(PartsGodCreatePanel.NAME)
    
    panel:updateRankData()
end