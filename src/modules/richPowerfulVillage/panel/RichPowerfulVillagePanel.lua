-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
RichPowerfulVillagePanel = class("RichPowerfulVillagePanel", BasicPanel)
RichPowerfulVillagePanel.NAME = "RichPowerfulVillagePanel"

function RichPowerfulVillagePanel:ctor(view, panelName)
    RichPowerfulVillagePanel.super.ctor(self, view, panelName, true)
    self:setUseNewPanelBg(true)
end

function RichPowerfulVillagePanel:finalize()
    RichPowerfulVillagePanel.super.finalize(self)
end

function RichPowerfulVillagePanel:initPanel()
	RichPowerfulVillagePanel.super.initPanel(self)
	self:addTabControl()
end

function RichPowerfulVillagePanel:registerEvents()
	RichPowerfulVillagePanel.super.registerEvents(self)
end

function RichPowerfulVillagePanel:addTabControl()
	local function callback(panel, panelName)
        if panelName == OpenningPanel.NAME then
	        self:setBgType(ModulePanelBgType.RICHPOWERFULVILLAGE)
        elseif panelName == ExchangePanel.NAME then
        	local openningPanel = self:getPanel(OpenningPanel.NAME)
	        if openningPanel.isInAction then
	        	self:showSysMessage(TextWords:getTextWord(540054))
	        	return
	        end
	        
	        self:setBgType(ModulePanelBgType.NONE)
        end
        return true
    end
    self._tabControl = UITabControl.new(self,callback)
    self._tabControl:addTabPanel(OpenningPanel.NAME, self:getTextWord(540030)) --开盘
    self._tabControl:addTabPanel(ExchangePanel.NAME, self:getTextWord(540031)) --兑换  
    self._tabControl:setTabSelectByName(OpenningPanel.NAME) --默认选择开盘界面
    self._tabControl:setChainVisbale(false)
    
    self:setTitle(true, "fuguihaozhuang", true)
    self:setBgType(ModulePanelBgType.RICHPOWERFULVILLAGE)
end

function RichPowerfulVillagePanel:onClosePanelHandler()
    self:dispatchEvent(RichPowerfulVillageEvent.HIDE_SELF_EVENT)
end

function RichPowerfulVillagePanel:onItemUpdate()
	local curPanelName = self._tabControl:getCurPanelName()
    local panel = self:getPanel(curPanelName)
    panel:updateItemNum()
end

function RichPowerfulVillagePanel:startOrChangeResp(param)
	local curPanelName = self._tabControl:getCurPanelName()
	if curPanelName == OpenningPanel.NAME then
		local panel = self:getPanel(curPanelName)
		panel:startOrChangeResp(param)
	end 
end

function RichPowerfulVillagePanel:confirmResultResp(param)
	local curPanelName = self._tabControl:getCurPanelName()
	if curPanelName == OpenningPanel.NAME then
		local panel = self:getPanel(curPanelName)
		panel:confirmResultResp(param)
	end 
end 

function RichPowerfulVillagePanel:exchangeItemResp(param)
	local curPanelName = self._tabControl:getCurPanelName()
	if curPanelName == ExchangePanel.NAME then
		local panel = self:getPanel(curPanelName)
		panel:exchangeItemResp(param)
	end 
end

function RichPowerfulVillagePanel:onUpdateGold()
	local curPanelName = self._tabControl:getCurPanelName()
	if curPanelName == OpenningPanel.NAME then
		local panel = self:getPanel(curPanelName)
		panel:onUpdateGold()
	end 
end 