
SettingPanel = class("SettingPanel", BasicPanel)
SettingPanel.NAME = "SettingPanel"

function SettingPanel:ctor(view, panelName)
    SettingPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function SettingPanel:finalize()
    SettingPanel.super.finalize(self)
end

function SettingPanel:initPanel()
	SettingPanel.super.initPanel(self)
	-- self:setBgType(ModulePanelBgType.BLACKFULL)
    self:setBgType(ModulePanelBgType.NONE)
    self:setTitle(true,"setting", true)
    
end

function SettingPanel:doLayout()
	local mainPanel = self:getChildByName("mainPanel")
	local panel = self:topAdaptivePanel()
    NodeUtils:adaptiveTopPanelAndListView(mainPanel, nil,GlobalConfig.downHeight,panel)
    NodeUtils:adaptivePanelBg(self._uiPanelBg._bgImg5, 5, panel)
end

function SettingPanel:onShowHandler()
	self._btnMap = {}
	local mainPanel = self:getChildByName("mainPanel")
	
	local gameBtn = mainPanel:getChildByName("gameBtn")
	local headBtn = mainPanel:getChildByName("headBtn")
	local contactBtn = mainPanel:getChildByName("contactBtn")
    local changeBtn = mainPanel:getChildByName("changeBtn")
    local secBtn = mainPanel:getChildByName("secBtn")
    local trueBtn = mainPanel:getChildByName("trueBtn")
    local helpBtn = mainPanel:getChildByName("helpBtn")

    local btnMap = {}
    btnMap[1] = gameBtn  	--游戏设置
    btnMap[2] = headBtn  	--头像设置
    btnMap[3] = contactBtn  --联系我们
    btnMap[4] = secBtn  	--安全设置
    btnMap[5] = trueBtn  	--实名认证
    btnMap[6] = helpBtn     --游戏帮助
    btnMap[7] = changeBtn  	--切换账号
    


    secBtn:setVisible(false)  --安全設置


    -- 运营需求：VIVO渠道屏蔽切换账号按钮
    if GameConfig.platformChanleId == 22 then
        changeBtn:setVisible(false)
    end

	contactBtn:setTitleText(self:getTextWord(1405))
    contactBtn:setVisible(true)
    -- if GameConfig.platformChanleId == 22 then
        -- contactBtn:setVisible(false)
    -- end
    -- self:showBtnByPlatform(contactBtn, "contactBtnShow")
    
    
    if GameConfig.isOpenRealNameVerify == nil then
    	self:showBtnByPlatform(trueBtn, "trueBtnShow")
    else
        -- 设置实名认证按钮的显示状态
    	trueBtn:setVisible(GameConfig.isOpenRealNameVerify)
    end
    -- 开放等级还没到隐藏按钮
    local openLevel = ConfigDataManager:getConfigById(ConfigData.RealNameConfig, 1).openLevel
    local curLevel  = self:getProxy(GameProxys.Role):getRoleAttrValue(PlayerPowerDefine.POWER_level)
    if trueBtn:isVisible() then
        if curLevel < openLevel then
            trueBtn:setVisible(false)
        end
    end

	gameBtn.panelName = GameSettingPanel.NAME
	self:addTouchEventListener(gameBtn, self.onShowOtherPanel)
	self:addTouchEventListener(headBtn, self.onShowHeadAndPendant)
	self:addTouchEventListener(contactBtn, self.onContactBtnTouch)
    self:addTouchEventListener(changeBtn, self.onChangeBtnTouch)
    self:addTouchEventListener(trueBtn, self.onTrueBtnTouch)
    self:addTouchEventListener(helpBtn,self.onHelpBtnTouch)
   
	
    self["headBtn"] = headBtn
    -- self["contactBtn"] = contactBtn   

    
    self:updateBtnPosY(btnMap)
end

function SettingPanel:updateBtnPosY(btnMap)
	if btnMap == nil or table.size(btnMap) <= 1 then
		return		
	end

	local iniY = btnMap[1]:getPositionY()
	local dy = 100
	local index = 0
	for i=1,table.size(btnMap) do
		local btn = btnMap[i]
		local isVisible = btn:isVisible()
		if isVisible == true then
			btn:setPositionY( iniY - dy * index )
			index = index + 1
		end
	end

end

function SettingPanel:onShowOtherPanel(sender)
	-- body

	self.view:onShowOtherPanel(sender.panelName)
end
function SettingPanel:onShowHeadAndPendant(sender)
    self:dispatchEvent(SettingEvent.SHOW_OTHER_EVENT,ModuleName.HeadAndPendantModule)
end

function SettingPanel:onChangeBtnTouch(sender)
--    SDKManager:showReLogionView()
    
   if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
        _G["onGameLogoutHandler"]()
    else
        SDKManager:sdkLogOut()
   end
    
end


function SettingPanel:onClosePanelHandler()
    self:dispatchEvent(SettingEvent.HIDE_SELF_EVENT, {})
end


function SettingPanel:updateContactBtn()
	local config = ConfigDataManager:getInfoFindByOneKey(ConfigData.ServiceContactConfig, "ID", 1)
end

function SettingPanel:onContactBtnTouch(sender)
	local panel = self:getPanel(ContactPanel.NAME)
	panel:show()
end

function SettingPanel:onTrueBtnTouch(sender)  --实名认证按钮
--	-- http://realname.kkk5.com/?ac=realname_verify&game_id=1&server_id=1&role_id=19&role_name=234799

--	local game_id = tostring(GameConfig.game_Id) --游戏id
--	local server_id = tostring(GameConfig.serverId)  --服id
--	local role_id = StringUtils:fixed64ToNormalStr(GameConfig.actorid)  --角色id
--	local role_name = tostring(GameConfig.actorName)  --角色昵称

--	local url = "http://realname.kkk5.com/?ac=realname_verify&game_id=%s&server_id=%s&role_id=%s&role_name=%s"
--	url = string.format(url, game_id, server_id, role_id, role_name)
--	logger:info("url = %s",url)

--	SDKManager:showWebHtmlView(url)
    

--    local state = 0
--    if GameConfig.isOpenRealNameVerify then
--        state = 1
--    end
--    local realNameProxy = self:getProxy(GameProxys.RealName)
--    realNameProxy:onTriggerNet460001Req({switchState = state})


    self:onRealNameOpen()
end

-- 打开实名认证界面
function SettingPanel:onRealNameOpen()
    self:dispatchEvent(SettingEvent.SHOW_OTHER_EVENT, ModuleName.RealNameModule)
    -- ModuleJumpManager:jump(ModuleName.RealNameModule, "RealNamePanel")
end


-- -- 联系客服按钮显示状态，根据渠道配表来控制
-- -- 实名认证按钮显示状态，根据渠道配表来控制
function SettingPanel:showBtnByPlatform(btn, key)
    local platform = GameConfig.platformChanleId
    if platform < 0 then
    	platform = 0
    end

    local config = ConfigDataManager:getInfoFindByOneKey(ConfigData.ServiceContactConfig, "platform", platform)
    if config == nil or config[key] == nil then
    	btn:setVisible(false)
    	logger:error("当前渠道 ID:%d 无法获取相关数据",platform)
    else
    	btn:setVisible(config[key] == 1)
    end
end

function SettingPanel:onHelpBtnTouch(sender)

    SDKManager:showWebHtmlView("html/help.html")
end
