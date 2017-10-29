
ArenaMailView = class("ArenaMailView", BasicView)

function ArenaMailView:ctor(parent)
    ArenaMailView.super.ctor(self, parent)
end

function ArenaMailView:finalize()
    ArenaMailView.super.finalize(self)
end

function ArenaMailView:registerPanels()
    ArenaMailView.super.registerPanels(self)

    require("modules.arenaMail.panel.ArenaMailPanel")
    self:registerPanel(ArenaMailPanel.NAME, ArenaMailPanel)

    require("modules.arenaMail.panel.ArenaMailPerPanel")
    self:registerPanel(ArenaMailPerPanel.NAME, ArenaMailPerPanel)

    require("modules.arenaMail.panel.ArenaMailAllPanel")
    self:registerPanel(ArenaMailAllPanel.NAME, ArenaMailAllPanel)

    require("modules.arenaMail.panel.ArenaMailInfoPanel")
    self:registerPanel(ArenaMailInfoPanel.NAME, ArenaMailInfoPanel)
end

function ArenaMailView:initView()
    self._detailInfos = {}
    local panel = self:getPanel(ArenaMailPanel.NAME)
    panel:show()
end

function ArenaMailView:onShowView(msg, isInit, isAutoUpdate)
    ArenaMailView.super.onShowView(self, msg, isInit, true)
end

function ArenaMailView:setOpenModule()
	local panel = self:getPanel(ArenaMailPanel.NAME)
	panel:setOpenModule()
end

function ArenaMailView:hideModuleHandler()
	self:dispatchEvent(ArenaMailEvent.HIDE_SELF_EVENT, {})
end

-- function ArenaMailView:onGetAllInfosResp(data)
--     local panel = self:getPanel(ArenaMailPerPanel.NAME)
--     if panel:isInitUI() == true then
--         panel:onUpdateData(data)
--     end
--     panel = self:getPanel(ArenaMailAllPanel.NAME)
--     if panel:isInitUI() == true then
--         panel:onUpdateData(data)
--     end
--     self._data = data
-- end

-- function ArenaMailView:getData()
--     return self._data
-- end

function ArenaMailView:onReadMailResp(data,type)
    --self._detailInfos[data.id] = data.infos
    local panel = self:getPanel(ArenaMailInfoPanel.NAME)
    panel:show()
    panel:onUpdateData(data,nil,type)
end

-- function ArenaMailView:onDelteMailResp(data)
--     local panel = self:getPanel(ArenaMailPerPanel.NAME)
--     panel:onUpdateData(data)
-- end

-- function ArenaMailView:getDetailData()
--     return self._detailInfos
-- end

function ArenaMailView:onShareFun(data)
    panel = self:getPanel(ArenaMailInfoPanel.NAME)
    panel:show()
    panel:onUpdateData(data,true)
end

function ArenaMailView:onPerMailsUpdate()
    local panel = self:getPanel(ArenaMailPerPanel.NAME)
    local proxy = self:getProxy(GameProxys.Arena)
    local data = proxy:onGetPerMailsMap()
    panel:onUpdateData(data)
end