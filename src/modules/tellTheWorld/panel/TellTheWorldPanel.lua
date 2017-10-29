-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
TellTheWorldPanel = class("TellTheWorldPanel", BasicPanel)
TellTheWorldPanel.NAME = "TellTheWorldPanel"

function TellTheWorldPanel:ctor(view, panelName)
    TellTheWorldPanel.super.ctor(self, view, panelName,30)

    self.richText_1 = nil
    self.richText_2 = nil

    self.ccbEffect = {
    	["rpg-zgtx-tou"] = nil,
    	["rpg-zgtx-zhong"] = nil,
    	["rpg-zgtx-wei"] = nil,
	}
end

function TellTheWorldPanel:finalize()

	if self.richText_1 then
		self.richText_1:dispose()
		self.richText_1 = nil
	end

	if self.richText_2 then
		self.richText_2:dispose()
		self.richText_2 = nil
	end 

	--释放特效
	for k,v in pairs(self.ccbEffect) do
		if v then
			v:finalize()
		end 
	end 
	self.ccbEffect = nil

    TellTheWorldPanel.super.finalize(self)
end

function TellTheWorldPanel:initPanel()
	TellTheWorldPanel.super.initPanel(self)
	self:setLocalZOrder(PanelLayer.UI_Z_ORDER_1)

	self._panelBg = self:getChildByName("panelBg")
	self._mainPanel = self:getChildByName("mainPanel")
    NodeUtils:adaptive(self._panelBg)
    -- TextureManager:updateImageViewFile(self._panelBg, "bg/newGuiBg/BgPanel.pvr.ccz")

	self.windowBg = self:getChildByName("mainPanel/windowBg")
	local readBtn = self.windowBg:getChildByName("readBtn")
	self:addTouchEventListener(readBtn, self.isReadBtnTap)

	self.roleProxy = self:getProxy(GameProxys.Role)
end

function TellTheWorldPanel:registerEvents()
	TellTheWorldPanel.super.registerEvents(self)
end

function TellTheWorldPanel:runCCBEffect_1()
	local function callBack()
		-- self:runCCBEffect_2()
		self.windowBg:setVisible(true)
	end 
	self.ccbEffect["rpg-zgtx-tou"] = UICCBLayer.new( "rpg-zgtx-tou", self._mainPanel,nil, callBack, true)
	self.ccbEffect["rpg-zgtx-tou"]:setPosition(self._mainPanel:getContentSize().width/2,self._mainPanel:getContentSize().height/2 + 330)

end

--这个特效无用
function TellTheWorldPanel:runCCBEffect_2()
	local function endCallBack()
		-- self:runCCBEffect_3()
	end 
	self.ccbEffect["rpg-zgtx-zhong"] = UICCBLayer.new( "rpg-zgtx-zhong", self._mainPanel,nil, endCallBack, true)
	self.ccbEffect["rpg-zgtx-zhong"]:setPosition(self._mainPanel:getContentSize().width/2,self._mainPanel:getContentSize().height/2 + 330)
end

function TellTheWorldPanel:runCCBEffect_3()
	local function endCallBack()
		self:closeThisModule()
	end 
	self.ccbEffect["rpg-zgtx-wei"] = UICCBLayer.new( "rpg-zgtx-wei", self._mainPanel,nil,endCallBack, true)
	self.ccbEffect["rpg-zgtx-wei"]:setPosition(self._mainPanel:getContentSize().width/2,self._mainPanel:getContentSize().height/2 + 330)
end

--info  = {eventId = 1,winnerInfo = 胜利者信息,loserInfo = 失败者信息}
function TellTheWorldPanel:updateViewInfo(info)
	local winnerInfo,loserInfo
	local configData
	if info.eventId then
		configData = ConfigDataManager:getConfigById(ConfigData.EventEndConfig,info.eventId)
		loserInfo = {}
		loserInfo.icon = configData.icon
		loserInfo.name = configData.name
	end

	--这里暂时没有做拥有胜利者数据的处理   目前无需求  后期拓展
	if not info.winnerInfo then 
		winnerInfo = {}
		winnerInfo.icon = self.roleProxy:getHeadId()
		winnerInfo.name = self.roleProxy:getRoleName()
	end 

	-- local loserInfo = {}
	-- loserInfo.num = 1
	-- loserInfo.typeid = 205 
	-- loserInfo.power = GamePowerConfig.Counsellor
	
	-- local configInfo = ConfigDataManager:getConfigByPowerAndID(loserInfo.power,loserInfo.typeid)
	-- loserInfo.icon = configInfo.headIcon
	-- loserInfo.name = configInfo.name

	local winnerName = self.windowBg:getChildByName("winnerName")
	winnerName:setString(winnerInfo.name)
	local loserName = self.windowBg:getChildByName("loserName")
	loserName:setString(loserInfo.name)

	local winnerIcon = self.windowBg:getChildByName("winnerIcon")
	local loserIcon = self.windowBg:getChildByName("loserIcon")

    local winner = UIHeadImg.new(winnerIcon, winnerInfo, self)
    winner:setScale(0.8)

    local url = "images/tellTheWorld/" .. loserInfo.icon .. ".png"
    TextureManager:updateImageView(loserIcon,url)
    -- local loser = UIHeadImg.new(loserIcon, loserInfo, self)
    -- loser:setScale(0.8)

    -- if loserIcon.iconHead == nil then
    --     loserIcon.iconHead = UIIcon.new(loserIcon, loserInfo, false, self)
    --     loserIcon.iconHead:setTouchEnabled(false)
    -- else
    --     loserIcon.iconHead:updateData(loserInfo)
    -- end

    local titleLab = self.windowBg:getChildByName("titleLab")
    titleLab:setString(configData.title)

	local desLab = self.windowBg:getChildByName("desLab")
	desLab:setString("")
	
	local args = {}
    args[1] = {txt = configData.activityDescribes, color = "9C724C", fontSize = 22}
    if self.richText_1 then
        self.richText_1:setData(args, 400)
    else
        self.richText_1 = RichTextMgr:getInstance():getRich(args, 400)
        self.windowBg:addChild(self.richText_1)
    end
    self.richText_1:setAnchorPoint(0, 1)
    self.richText_1:setPosition(desLab:getPosition())

    local param = configData.titleDescribes
    for k,v in pairs(param) do
    	if v.txt == "name" then
    		v.txt = winnerInfo.name
    		if not v.isUnderLine then
    			v.isUnderLine = 1
    		end 
    	end
    	if not v.fontSize then
    		v.fontSize = 20
    	end 
    end 
    -- param[1] = {txt = TextWords:getTextWord(540111), color = "3D2815", fontSize = 20}
    -- param[2] = {txt = winnerInfo.name, color = "FDEB03", isUnderLine = 1,fontSize = 20}
    -- param[3] = {txt = TextWords:getTextWord(540112), color = "3D2815",fontSize = 20}
    -- param[4] = {txt = loserInfo.name, color = "FD0101", isUnderLine = 1,fontSize = 20}
    -- param[5] = {txt = TextWords:getTextWord(540113), color = "3D2815",fontSize = 20}
    if self.richText_2 then
        self.richText_2:setData(param, 400)
    else
        self.richText_2 = RichTextMgr:getInstance():getRich(param, 400)
        self.windowBg:addChild(self.richText_2)
    end
    self.richText_2:setAnchorPoint(0, 0)
    self.richText_2:setPosition(desLab:getPositionX(),desLab:getPositionY() + 55)
end 

function TellTheWorldPanel:onShowHandler(extraMsg)
	self:setDefaultBgVisible(false)
	self:updateViewInfo(extraMsg)
	self.windowBg:setVisible(false)
	self:runCCBEffect_1()
end

function TellTheWorldPanel:isReadBtnTap()
	self.windowBg:setVisible(false)
	self:runCCBEffect_3()
end

function TellTheWorldPanel:closeThisModule()
	self:dispatchEvent(TellTheWorldEvent.HIDE_SELF_EVENT)
end 