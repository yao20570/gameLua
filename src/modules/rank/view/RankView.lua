
RankView = class("RankView", BasicView)

function RankView:ctor(parent)
    RankView.super.ctor(self, parent)
end

function RankView:finalize()
    RankView.super.finalize(self)
end

function RankView:registerPanels()
    RankView.super.registerPanels(self)

    require("modules.rank.panel.RankPanel")
    self:registerPanel(RankPanel.NAME, RankPanel)

    require("modules.rank.panel.RankResPanel")
    self:registerPanel(RankResPanel.NAME, RankResPanel)
end

function RankView:initView()
    local panel = self:getPanel(RankPanel.NAME)
    panel:show()
end

function RankView:hideModuleHandler()
    self:dispatchEvent(RankEvent.HIDE_SELF_EVENT, {})
end

function RankView:onPlayerInfoResp(data)
	-- body
    local panel = self:getPanel(RankPanel.NAME)
    panel:onPlayerInfoResp(data)
end

function RankView:updateRankHandler()
    -- body
	local panel = self:getPanel(RankPanel.NAME)
	panel:updateRankHandler()

end

--------------------------------------------------------------------
function RankView:onShowView(extraMsg, isInit)
    RankView.super.onShowView(self,extraMsg, isInit, true)
end

function RankView:updateResRankView()
    local panel = self:getPanel(RankResPanel.NAME)
    panel:onShowHandler()
end