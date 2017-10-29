
PopularSupportPanel = class("PopularSupportPanel", BasicPanel)
PopularSupportPanel.NAME = "PopularSupportPanel"

function PopularSupportPanel:ctor(view, panelName)
    local layer = view:getLayer(ModuleLayer.UI_Z_ORDER_5)
    PopularSupportPanel.super.ctor(self, view, panelName, 600, layer)
    self._Proxy = self:getProxy(GameProxys.PopularSupport)
    self.ids = { }

    self:setUseNewPanelBg(true)
end

function PopularSupportPanel:finalize()
    PopularSupportPanel.super.finalize(self)
end

function PopularSupportPanel:initPanel()
	PopularSupportPanel.super.initPanel(self)
	self:setTitle(true,TextWords:getTextWord(70103))
	-- self:updatePanel()
end

function PopularSupportPanel:registerEvents()
	PopularSupportPanel.super.registerEvents(self)
	self._pos = {}
	for i=1, 3 do

		local item = self:getChildByName("mainPanel/infoPanel/item"..i)
		self._pos[i] = cc.p(item:getPosition())
		local btn = self:getChildByName("mainPanel/infoPanel/item"..i.."/getBtn")
		btn.index = i
		self:addTouchEventListener(btn, self.onGetBtnTouch)
	end
	local tipImg = self:getChildByName("mainPanel/tipImage")
	self:addTouchEventListener(tipImg, self.onTipsBtnHandler)
	local refreshBtn = self:getChildByName("mainPanel/refreshBtn")
	self:addTouchEventListener(refreshBtn, self.onRefreshBtnTouch)

	self:getChildByName("mainPanel"):setTag(456789)
end

function PopularSupportPanel:onTipsBtnHandler(sender)
    local parent = self:getParent()
    local uiTip = UITip.new(parent)
    local lines = {}
    for i=0, 4 do
        lines[i] = {{content = TextWords:getTextWord(70107 + i), foneSize = ColorUtils.tipSize18, color = ColorUtils.commonColor.MiaoShu}}
    end
    uiTip:setAllTipLine(lines)
end

function PopularSupportPanel:onRefreshBtnTouch()
	-- self:setMask(true)
    --获取是否还有免费刷新
    local times,yb,strDescrib = self._Proxy:getRefreshTimes()
    
    --刷新需要的元宝
    local price = (1-times)*yb
    if price>GlobalConfig.maxRefreshPrice then
        price = GlobalConfig.maxRefreshPrice
    end
    
    --回调：刷新
    local function refreshBtnTouch()
   
    	local refreshBtn = self:getChildByName("mainPanel/refreshBtn")
        refreshBtn:stopAllActions()
        refreshBtn:setRotation(0)
        local act = cc.RotateTo:create(0.5, 180)
        local sequence = cc.Sequence:create(act)
        refreshBtn:runAction(sequence)
        -- NodeUtils:addSwallow()
        self:setMask(true)
        self._Proxy:onTriggerNet20600Req()
    end
    
    --确定花费元宝刷新
    local function okCallback()
    	self:setMask(true)
        refreshBtnTouch()
    end
    
    --取消刷新
    local function canCelcallback()
    end
   
    --times<0:不再免费刷新
    if times<=0 then
    	-- self:setMask(false)
        self:showMessageBox(string.format(self:getTextWord(70106),price), okCallback, canCelcallback)
    else
        refreshBtnTouch()
    end
end

function PopularSupportPanel:onHideHandler()
	self:dispatchEvent(PopularSupportEvent.HIDE_SELF_EVENT)
end

function PopularSupportPanel:onGetBtnTouch(sender)
	local playerProxy = self:getProxy(GameProxys.Role)
	local curSupport = playerProxy:getRoleAttrValue(PlayerPowerDefine.POWER_support)
	if curSupport > 0 then
		self._Proxy:onTriggerNet20601Req(self.ids[sender.index])
	else
		self:showSysMessage(TextWords:getTextWord(70102))
	end
end

function PopularSupportPanel:onShowHandler()
	self:updatePanel()
end

function PopularSupportPanel:updatePanel(dely)
	self:updateNums()
	local times,yb,strDescrib = self._Proxy:getRefreshTimes()
	local refreshTimesLab = self:getChildByName("mainPanel/refreshTimesLab")
	local describLab = self:getChildByName("mainPanel/describLab")
	describLab:setString(strDescrib)
	if times > 0 then
		refreshTimesLab:setString(string.format(TextWords:getTextWord(70104),times))
	else
		local price = (1 - times) *  yb
		if price > GlobalConfig.maxRefreshPrice then
			price = GlobalConfig.maxRefreshPrice  --20元宝封顶
		end
		refreshTimesLab:setString(string.format(TextWords:getTextWord(70105),price))
	end


	local infos = self._Proxy:getInfos()

	for i=1, 3 do
		self.ids[i] = infos[i].id
	end

	local function func()
		for i=1, 3 do
			local node = self:getChildByName("mainPanel/infoPanel/item"..i)
			self:renderItem(node,infos[i],i)
		end
	end
	if dely then
		TimerManager:addOnce(GameConfig.POPULARSUPPORT.MISS_TIME * 1000,func, self)
	else
		func()
	end
end

function PopularSupportPanel:renderItem(node,data,index)
	self.ids[index] = data.id
	local imgContainer = node:getChildByName("iconPanel")
	local Label_16 = node:getChildByName("Label_16")
	local Image_15 = node:getChildByName("Image_15")
	local url = "images/popularSupport/jia.png"
	if data.quality == 2 then
		url = "images/popularSupport/yi.png"
	elseif data.quality == 3  then
		url = "images/popularSupport/bing.png"
	end
	local conf = ConfigDataManager:getConfigByPowerAndID(data.infos.power,data.infos.typeid)
	TextureManager:updateImageView(Image_15, url)
	local function delySetString()
	    local colorStr = ColorUtils:getColorByQuality(conf.color)
	    local function to16( num)
		    local str = string.format("%#x",num)
		    return string.sub(str,3)
	    end
	    colorStr = "#"..to16(colorStr.r)..to16(colorStr.g)..to16(colorStr.b)
	    local info =  {{{conf.name, 22,colorStr}, {"*"..data.infos.num, 22, ColorUtils.commonColor.FuBiaoTi}}}
	    local rickLabel = Label_16.rickLabel
        if rickLabel == nil then
            rickLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
            rickLabel:setPosition(cc.p(0,20))
            Label_16:addChild(rickLabel)
            Label_16.rickLabel = rickLabel
	    end
	    rickLabel:setString(info)
	    Label_16:setString("")
	end

	delySetString()
	if node.UIIcon then
		node.UIIcon:updateData(data.infos)
	else
		node.UIIcon = UIIcon.new(imgContainer,data.infos, true,self)
		node.UIIcon:setPosition(40,40)
	end
	if index == 3 then 
		-- self:setMask(false)
	end
end

function PopularSupportPanel:updateNums()
	local playerProxy = self:getProxy(GameProxys.Role)
	local curSupport = playerProxy:getRoleAttrValue(PlayerPowerDefine.POWER_support)
	local currentNumLab = self:getChildByName("mainPanel/currentNumLab")
	currentNumLab:setString(curSupport)
	local maxSupport = playerProxy:getRoleAttrValue(PlayerPowerDefine.POWER_supportLimit)
	local maxNumLab = self:getChildByName("mainPanel/maxNumLab")
	maxNumLab:setString("/"..maxSupport)

	if curSupport > 0 then
        local c3b = ColorUtils:color16ToC3b(ColorUtils.commonColor.BiaoTi)
		currentNumLab:setColor(c3b)
	else
        local c3b = ColorUtils:color16ToC3b(ColorUtils.commonColor.Red)
		currentNumLab:setColor(c3b)
	end

    local labPopular = self:getChildByName("mainPanel/labPopular")
    
	NodeUtils:alignNodeL2R(labPopular, currentNumLab, maxNumLab, 2)
end

function PopularSupportPanel:getAction()
	local index = self._Proxy:getIndex() 
	local itemPanel = self:getChildByName("mainPanel/infoPanel/item"..index)
	itemPanel:setPosition(self._pos[index])
	itemPanel:setOpacity(255)
	itemPanel:stopAllActions()
	local pos = cc.p(itemPanel:getPosition())
	local function setPanelPosition()
		itemPanel:setPosition(pos)
	end
	local act = cc.Sequence:create(
		cc.Spawn:create(cc.MoveBy:create(GameConfig.POPULARSUPPORT.MISS_TIME, cc.p(600 ,0)), cc.FadeTo:create(GameConfig.POPULARSUPPORT.MISS_TIME, 0)),
		cc.CallFunc:create(setPanelPosition),
		cc.FadeTo:create(GameConfig.POPULARSUPPORT.FADE_TIME, 255)
		)
	itemPanel:runAction(act)
end

function PopularSupportPanel:refreshAction()
	self:setMask(true)
	for index = 1, 3 do
		local itemPanel = self:getChildByName("mainPanel/infoPanel/item"..index)
		itemPanel:setPosition(self._pos[index])
		itemPanel:setOpacity(255)
		itemPanel:stopAllActions()
		local pos = cc.p(itemPanel:getPosition())
		local function setPanelPosition()
			itemPanel:setPosition(pos)
			if index == 3 then 
				-- self:setMask(false)
			end
		end
        local function removeSwallow()
            if index == 3 then 
            	self:setMask(false)
				-- NodeUtils:removeSwallow()
			end
        end
		local function delayFunc()
			local act = cc.Sequence:create(
				cc.Spawn:create(cc.MoveBy:create(GameConfig.POPULARSUPPORT.MISS_TIME, cc.p(600 ,0)), cc.FadeTo:create(GameConfig.POPULARSUPPORT.MISS_TIME, 0)),
				cc.CallFunc:create(setPanelPosition),
				cc.FadeTo:create(GameConfig.POPULARSUPPORT.FADE_TIME, 255),
                cc.CallFunc:create(removeSwallow)
			)
			itemPanel:runAction(act)
		end
		TimerManager:addOnce(30 + (index - 1) * GameConfig.POPULARSUPPORT.INTERVAL_TIME * 1000, delayFunc, self)
	end
end