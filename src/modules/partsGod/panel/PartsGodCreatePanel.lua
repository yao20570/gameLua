-------------------------打造界面------------------------------------
PartsGodCreatePanel = class("PartsGodCreatePanel", BasicPanel)
PartsGodCreatePanel.NAME = "PartsGodCreatePanel"

function PartsGodCreatePanel:ctor(view, panelName)
    PartsGodCreatePanel.super.ctor(self, view, panelName,true)

    self:setUseNewPanelBg(true)
end

function PartsGodCreatePanel:finalize()
    PartsGodCreatePanel.super.finalize(self)
end

function PartsGodCreatePanel:onClosePanelHandler()
	self:dispatchEvent(PartsGodEvent.HIDE_SELF_EVENT)
end

function PartsGodCreatePanel:initPanel()
	PartsGodCreatePanel.super.initPanel(self)

	self:addTabControl()
end

function PartsGodCreatePanel:addTabControl()
    local function callback(panel, panelName, oldPanelName) 
        if panelName == PartsGodRankPanel.NAME then
            local partsPanel = self:getPanel(PartsGodCreateMainPanel.NAME)
	        if not partsPanel.isFinish then
	        	self:showSysMessage(TextWords:getTextWord(280010))
	        	return false
	        end
        else
        end
        return true
    end
    
	local proxy = self:getProxy(GameProxys.Activity)
    local isRank = proxy.curActivityData.rankId

    self._tabControl = UITabControl.new(self, callback)
    self._tabControl:addTabPanel(PartsGodCreateMainPanel.NAME, self:getTextWord(18019))
    if isRank ~= 0 then
        self._tabControl:addTabPanel(PartsGodRankPanel.NAME, self:getTextWord(18017))
    end
    self._tabControl:changeTabSelectByName(PartsGodCreateMainPanel.NAME)
    self:setTitle(true, "partsGod", true) 
    self:setBgType(ModulePanelBgType.NONE)
end

function PartsGodCreatePanel:onShowHandler()
    if self._tabControl then
        self._tabControl:changeTabSelectByName(PartsGodCreateMainPanel.NAME)
    end
end

function PartsGodCreatePanel:onGetRewardResp(data)
    local panel = self:getPanel(PartsGodCreateMainPanel.NAME)
    panel:onGetRewardResp(data)
end

function PartsGodCreatePanel:onChatPersonInfoResp(data)
    local panel = self:getPanel(PartsGodRankPanel.NAME)
    panel:onChatPersonInfoResp(data)
end

function PartsGodCreatePanel:onSetPartsGodFree()
    local panel = self:getPanel(PartsGodCreateMainPanel.NAME)
    panel:onShowHandler()
end

function PartsGodCreatePanel:updateRankData()
    local panel = self:getPanel(PartsGodRankPanel.NAME)
    panel:updateRankData()
end