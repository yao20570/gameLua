
ContactPanel = class("ContactPanel", BasicPanel)
ContactPanel.NAME = "ContactPanel"

function ContactPanel:ctor(view, panelName)
    ContactPanel.super.ctor(self, view, panelName, 320)
    
    self:setUseNewPanelBg(true)
end

function ContactPanel:finalize()
    ContactPanel.super.finalize(self)
end

function ContactPanel:initPanel()
	ContactPanel.super.initPanel(self)
    self:setTitle(true,self:getTextWord(1405))
    
	local mainPanel = self:getChildByName("mainPanel")
	
	self.infoTxt = mainPanel:getChildByName("infoTxt")
	self.contactBtn = mainPanel:getChildByName("contactBtn")
	self.contactBtn:setPositionY(self.contactBtn:getPositionY() - 20)
	self.infoTxt:setFontSize(22)
	self.infoTxt:setAnchorPoint(0,0.5)
	self.infoTxt:setPosition(self.infoTxt:getPositionX() + 24, self.infoTxt:getPositionY() + 20)
	self:addTouchEventListener(self.contactBtn, self.onContactBtnTouch)	
end

function ContactPanel:doLayout()
end

function ContactPanel:onShowHandler()
	local platform = GameConfig.platformChanleId
	-- print("...platform",platform)
	if platform < 0 then
		platform = 0
	end

	local config = self:getConfigByID(1)
	-- if config == nil then
	-- 	self.infoTxt:setVisible(false)
	-- 	self.contactBtn:setVisible(false)
	-- 	logger:error("当前渠道 ID:%d 无法获取相关数据",platform)
	-- 	return
	-- end

	self._url = config.url
	self._gmCenter = config.gmCenter
	self.infoTxt:setString(config.info)
	self.contactBtn:setTitleText(config.button)
	if config.buttonShow == 1 then
		self.contactBtn:setVisible(true)
	else
		self.contactBtn:setVisible(false)
	end

end

function ContactPanel:onClosePanelHandler()
	self:hide()
end


function ContactPanel:getConfigByID(ID)
	local config = ConfigDataManager:getInfoFindByOneKey(ConfigData.ServiceContactConfig, "ID", ID)
	return config
end

function ContactPanel:onContactBtnTouch(sender)
    -- 前往客服中心
    if self._gmCenter == 1 then
        logger:error("前往 客服中心")
        SDKManager:openGMCenter()
        self:onClosePanelHandler()
        return
    end

	if self._url then
		--logger:info("前往官网 %s %s",self._url,GameConfig.platformChanleId)
		SDKManager:showWebHtmlView(self._url)
    	self:onClosePanelHandler()
        return
    end

    self:showSysMessage(self:getTextWord(1432))
    self:onClosePanelHandler()
end


