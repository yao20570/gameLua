
ArenaPanel = class("ArenaPanel", BasicPanel)
ArenaPanel.NAME = "ArenaPanel"

function ArenaPanel:ctor(view, panelName)
    ArenaPanel.super.ctor(self, view, panelName,true)

    self:setUseNewPanelBg(true)
end

function ArenaPanel:finalize()
    ArenaPanel.super.finalize(self)
end

function ArenaPanel:initPanel()
	ArenaPanel.super.initPanel(self)

    local function callback(panel, panelName, oldPanelName) 
        local state = false
        if self._isOpen == nil then
            state = true
        else
            if self._isOpen == false then
                self:showSysMessage(self:getTextWord(19001))
            end
            state = self._isOpen
        end

        if state then
            if panelName == ArenaSqurePanel.NAME then
	            self:setBgType(ModulePanelBgType.TEAM)
            else
	            self:setBgType(ModulePanelBgType.NONE)
            end
        end
        return state
    end

	self._tabControl = UITabControl.new(self, callback)
    self._ownTabsPanel = self._tabControl:getTabsPanel()
    self._tabControl:addTabPanel(ArenaMainPanel.NAME, self:getTextWord(1806))
    self._tabControl:addTabPanel(ArenaSqurePanel.NAME, self:getTextWord(1807))
    self:setTitle(true,"yanwuchang",true)

    self:setBgType(ModulePanelBgType.TEAM)
end

--function ArenaPanel:onSetOpenPanel(panelName, oldPanelName)
--    local state = false
--    if self._isOpen == nil then
--        state = true
--    else
--        if self._isOpen == false then
--            self:showSysMessage(self:getTextWord(19001))
--        end
--        state = self._isOpen
--    end

--    if state then
--        if panelName == ArenaSqurePanel.NAME then
--	        self:setBgType(ModulePanelBgType.TEAM)
--        else
--	        self:setBgType(ModulePanelBgType.NONE)
--        end
--    end
--     return state
--end

function ArenaPanel:getOwnTabsPanel()
    return self._ownTabsPanel
end

function ArenaPanel:onClosePanelHandler()
	local panel = self:getPanel(ArenaMainPanel.NAME)
	panel:onClickItemHandle()
	self.view:hideModuleHandler()
end

function ArenaPanel:setOpenModule(type,status)
    if status ~= nil then
        self._isOpen = true
    else
        self._isOpen = type
    end
    
	if type == true then
		self._tabControl:changeTabSelectByName(ArenaMainPanel.NAME)
	else
		self._tabControl:changeTabSelectByName(ArenaSqurePanel.NAME)
	end
    if status ~= nil then
        self._isOpen = false
    end
end