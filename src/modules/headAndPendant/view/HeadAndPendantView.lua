
HeadAndPendantView = class("HeadAndPendantView", BasicView)

function HeadAndPendantView:ctor(parent)
    HeadAndPendantView.super.ctor(self, parent)
end

function HeadAndPendantView:finalize()
    HeadAndPendantView.super.finalize(self)
end

function HeadAndPendantView:registerPanels()
    HeadAndPendantView.super.registerPanels(self)

    require("modules.headAndPendant.panel.HeadAndPendantPanel")
    self:registerPanel(HeadAndPendantPanel.NAME, HeadAndPendantPanel)

    require("modules.headAndPendant.panel.HeadSettingPanel")
    self:registerPanel(HeadSettingPanel.NAME, HeadSettingPanel)

    require("modules.headAndPendant.panel.PendantSettingPanel")
    self:registerPanel(PendantSettingPanel.NAME, PendantSettingPanel)

    require("modules.headAndPendant.panel.TitleSettingPanel")
    self:registerPanel(TitleSettingPanel.NAME, TitleSettingPanel)

    require("modules.headAndPendant.panel.TopFramePanel")
    self:registerPanel(TopFramePanel.NAME, TopFramePanel)
end

function HeadAndPendantView:initView()
    local panel = self:getPanel(HeadAndPendantPanel.NAME)
    panel:show()
end
function HeadAndPendantView:getCurSelectedPendantId()
--[[
    if self._CurSelectedPendantId == nil then
        local roleProxy = self:getProxy(GameProxys.Role)
        local playerPendantId = roleProxy._pendantId
        if playerPendantId == 0 then
            playerPendantId  = 101
        end
        self._CurSelectedPendantId = playerPendantId
    end
    ]]
    
    return self._CurSelectedPendantId 
end
function HeadAndPendantView:setCurSelectedPendantId(id)
    -- self._oldSelectedPendantId = self._CurSelectedPendantId
    self._oldSelectedPendantId = id
    self._CurSelectedPendantId = id
end
function HeadAndPendantView:getOldSelectedPendantId()

    return self._oldSelectedPendantId
end
function HeadAndPendantView:onHeadSettingReq(data)
    -- body
    self:dispatchEvent(HeadAndPendantEvent.HEAD_SET_REQ,data)
end
