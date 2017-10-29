
ArenaView = class("ArenaView", BasicView)

function ArenaView:ctor(parent)
    ArenaView.super.ctor(self, parent)
end

function ArenaView:finalize()
    ArenaView.super.finalize(self)
end

function ArenaView:registerPanels()
    ArenaView.super.registerPanels(self)

    require("modules.arena.panel.ArenaPanel")
    self:registerPanel(ArenaPanel.NAME, ArenaPanel)
    require("modules.arena.panel.ArenaMainPanel")
    self:registerPanel(ArenaMainPanel.NAME, ArenaMainPanel)
    require("modules.arena.panel.ArenaSqurePanel")
    self:registerPanel(ArenaSqurePanel.NAME, ArenaSqurePanel)
    -- require("modules.arena.panel.ArenaChoosePanel")
    -- self:registerPanel(ArenaChoosePanel.NAME, ArenaChoosePanel)
    require("modules.arena.panel.ArenaRewPanel")
    self:registerPanel(ArenaRewPanel.NAME, ArenaRewPanel)
end

function ArenaView:initView()
    local panel = self:getPanel(ArenaPanel.NAME)
    panel:show()
end

function ArenaView:hideModuleHandler()
	self:dispatchEvent(ArenaEvent.HIDE_SELF_EVENT, {})
end

function ArenaView:setOpenModule(type,status)
	local panel = self:getPanel(ArenaPanel.NAME)
    panel:setOpenModule(type,status)

    -- if type == true then
    --     local proxy = self:getProxy(GameProxys.System)
    --     panel = self:getPanel(ArenaPanel.NAME)
    --     panel:onUpdateColdTime(proxy:getRemainTime(23,0,0))
    -- end
end

function ArenaView:onGetAllInfosResp(data)
    self._data = data
    local panel = self:getPanel(ArenaMainPanel.NAME)
    panel:onUpdateDownInfo(data)
    if panel:isInitUI() == true then
        panel:onUpdateInfo(data)
    end
    
    panel = self:getPanel(ArenaRewPanel.NAME)
    if panel:isInitUI() == true then
        panel:updateBtnStatus(data)
    end


    if data ~= nil then
        self._count = data.wintimes
    end

end

-- 连胜次数
function ArenaView:onGetCount() 
    return self._count  
end


function ArenaView:onGetData()
    return self._data
end

function ArenaView:updateLevel(level)
    -- local panel = self:getPanel(ArenaSqurePanel.NAME)
    -- if panel:isInitUI() == true then
    --     panel:setOpenPosBylevel(level)
    -- end
end

function ArenaView:updateMaxFightSoldierCount()
    local panel = self:getPanel(ArenaMainPanel.NAME)
    panel:updateScoreTxt()
    -- if panel:isInitUI() == true then
    --     panel:setSolderCount()
    -- end

    -- panel = self:getPanel(ArenaChoosePanel.NAME)
    -- if panel:isInitUI() == true then
    --     panel:onUpdateMaxCount()
    -- end
end

function ArenaView:onGetRewResp()
    local panel = self:getPanel(ArenaRewPanel.NAME)
    panel:onGetRewResp()
    local proxy = self:getProxy(GameProxys.Arena)
    self:onGetAllInfosResp(proxy:getAllInfos())
end

function ArenaView:onBuyCountResp(data)
    local panel = self:getPanel(ArenaMainPanel.NAME)
    panel:onBuyCountResp(data)
end

function ArenaView:onChatPersonInfoResp(data)
    local panel = self:getPanel(ArenaMainPanel.NAME)
    panel:onChatPersonInfoResp(data)
end

function ArenaView:onUpdateRed()
    --local panel = self:getPanel(ArenaSqurePanel.NAME)
    -- local panel = self:getPanel(ArenaMainPanel.NAME)
    -- panel:updateEquipAndParts()
end

function ArenaView:onUpdateAllEquips()
    --local panel= self:getPanel(ArenaSqurePanel.NAME)
    -- local panel = self:getPanel(ArenaMainPanel.NAME)
    -- panel:updateEquipAndParts()
end

function ArenaView:onConsuGoReq(data)
    -- local panel = self:getPanel(ArenaSqurePanel.NAME)
    -- if panel:isInitUI() == true then
    --     panel:onConsuGoReq(data)
    -- end
end

-- function ArenaView:onShowView(msg, isInit)
--     ArenaView.super.onShowView(self, msg, isInit, true)
--     local proxy = self:getProxy(GameProxys.Arena)
--     local name = ArenaSqurePanel.NAME
--     if proxy:onGetIsSquire() then
--         name = ArenaPanel.NAME
--     end
--     local panel = self:getPanel(name)
--     panel:show()
-- end