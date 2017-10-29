--
-- Author: zlf
-- Date: 2016年9月2日21:47:05
-- 英雄详细信息界面


HeroInfoPanel = class("HeroInfoPanel", BasicPanel)
HeroInfoPanel.NAME = "HeroInfoPanel"

function HeroInfoPanel:ctor(view, panelName)
    HeroPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function HeroInfoPanel:finalize()
    HeroPanel.super.finalize(self)
end

function HeroInfoPanel:initPanel()
	HeroPanel.super.initPanel(self)
	self:setBgType(ModulePanelBgType.NONE)
	self:setTitle(true, "hero", true)

	self.proxy = self:getProxy(GameProxys.Hero)



	self.attrInfos = {}
	self.stars = {}
	self.attrLabs = {}
	for i=1,6 do
		self.attrInfos[i] = self:getChildByName("topPanel/attrItem"..i)
		if i < 6 then
			self.stars[i] = self:getChildByName("topPanel/starImg"..i)
		end
		if i < 4 then
			self.attrLabs[i] = self:getChildByName("topPanel/attrLab"..i)
		end
	end
	local topPanel = self:getChildByName("topPanel")
	self.heroImg = self:getChildByName("topPanel/heroImg")

	self.heroPos = cc.p(self.heroImg:getPosition())

	self.fightLab = self:getChildByName("topPanel/fightLab")
	self.talentLab = self:getChildByName("topPanel/talentLab")
	-- self.talentLab:ignoreContentAdaptWithSize(false) 
	-- self.talentLab:setContentSize(cc.size(280, 150)) 

    self.listView = self:getChildByName("ListView_66")

	

end

function HeroInfoPanel:doLayout()
	local topPanel = self:getChildByName("topPanel")
	local midPanel = self:getChildByName("midPanel")
	local bestPanel = self:topAdaptivePanel()

    -- NodeUtils:adaptiveTopPanelAndListView(topPanel, nil, nil, bestPanel)
    NodeUtils:adaptiveUpPanel(topPanel,nil,GlobalConfig.topAdaptive1)

    NodeUtils:adaptiveTopPanelAndListView(midPanel, nil, nil, topPanel)

    NodeUtils:adaptiveListView(self.listView, GlobalConfig.downHeight, midPanel, 3)
end

function HeroInfoPanel:registerEvents()
	HeroInfoPanel.super.registerEvents(self)
end

function HeroInfoPanel:onClosePanelHandler()
	self:hide()
end

function HeroInfoPanel:onShowHandler(data)
    if data ~= nil then
       logger:info(" 这个data 是有值得")
       --print(data.fightVal)
    end 
	data = data or self.proxy:getCurInfoPanelData()
	self:initView(data)

end

function HeroInfoPanel:initView(data)
	local heroTianFu = ConfigDataManager:getConfigById(ConfigData.HeroGiftConfig, data.heroId)

	if data ~= nil then
		local icon = self.heroImg.uiIcon
		local iconData = {}
		iconData.num = 1
		iconData.typeid = data.heroId
		iconData.power = 409
		if icon == nil then
			icon = UIIcon.new(self.heroImg, iconData, false, self)
			self.heroImg.uiIcon = icon
		else
			icon:updateData(iconData)
		end
		icon:setTouchEnabled(false)
	end

	-- self.heroImg:setScale(0.5)
	local heroAttrInfo = self.proxy:getHeroAllAttr(data)
	for k,v in pairs(heroAttrInfo) do
		local iconNameLab = self.attrInfos[k]:getChildByName("iconNameLab")
		local iconnumLab = self.attrInfos[k]:getChildByName("iconnumLab")
		-- local iconImg = self.attrInfos[k]:getChildByName("iconImg")
		-- iconImg:setScale(0.85)
		iconNameLab:setString(v.text)
		local baseStr = ""
		if k ~= 4 and k ~= 1 then
			baseStr = (v.base/100).."%"
		else
			baseStr = math.ceil(v.base)
		end
		iconnumLab:setString(baseStr)
		-- local url = self.proxy:getIconPath(k)
		-- TextureManager:updateImageView(iconImg, url)
	end

	local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)
	local offsetsPos = StringUtils:jsonDecode(config.pokedexPos)
	-- self.heroImg:setPosition(self.heroPos.x + offsetsPos[1] * 0.5, self.heroPos.y + offsetsPos[2] * 0.5)
	local talent = StringUtils:jsonDecode(config.talent)
	local talentStr = ""
	for k,v in pairs(talent) do
		local heroTianFu = ConfigDataManager:getConfigById(ConfigData.HeroGiftConfig, v)
		if heroTianFu ~= nil then
			talentStr = talentStr .. heroTianFu.info
		end
	end
	self.talentLab:setString(talentStr)
	
	local nameLab = self:getChildByName("topPanel/nameLab")
	local lvLab = self:getChildByName("topPanel/lvLab")
	nameLab:setString(config.name)
	lvLab:setString(" Lv.".. data.heroLv)

	local starUrl = "images/newGui1/IconStarMini.png"
	local drakUrl = "images/newGui1/IconStarMiniBg.png"
	ComponentUtils:renderStar(self.stars, data.heroStar, starUrl, drakUrl, config.starmax)
	-- ComponentUtils:adjustStarPos(227, self.stars, config.starmax)
	local keys = {"lead", "brave", "sta"}
	local color = ColorUtils:getColorByQuality(config.color) or cc.c3b(255,255,255)
	nameLab:setColor(color)
	local allNum = 0
	for i=1,3 do
		self.attrLabs[i]:setString(config[keys[i]])
		allNum = tonumber(config[keys[i]]) + allNum
		self.attrLabs[i]:setColor(color)
	end
	self.fightLab:setString(string.format("%d",self.proxy:getHeroFight(data.curPos,{})))

	local num = self.proxy:getHeroCommandNumWithData(data)
	local blLab = self:getChildByName("topPanel/blLab")
	blLab:setString("+"..num)

	num = self.proxy:getFirstnum(data.curPos)
	local labXianShouNum = self:getChildByName("topPanel/labXianShouNum")
	labXianShouNum:setString("+" .. num)

	local strategicsData = ConfigDataManager:getConfigData(ConfigData.StrategicsConfig)
	local showData = {}
	local Strategics = StringUtils:jsonDecode(config.Strategics)
	self.heroStrategics = {}
	for k,v in pairs(data.strategicsInfo) do
		self.heroStrategics[v.strategicsId] = v.strategicsLv
	end
	for k,v in pairs(Strategics) do
		table.insert(showData, strategicsData[v])
	end
	self:renderListView(self.listView, showData, self, self.renderItem)
end

function HeroInfoPanel:renderItem(item, data)
	local iconImg = item:getChildByName("iconImg")
	local nameLab = item:getChildByName("nameLab")
	local lockLab = item:getChildByName("lockLab")

	
	nameLab:setString(data.name)
	local level = self.heroStrategics[data.ID]
	local lvLab = item:getChildByName("lvLab")
	local lvStr = level ~= nil and "Lv."..level or data.open
	-- local color = level ~= nil and ColorUtils:color16ToC3b("#FFEB9B17") or cc.c3b(255,0,0)
	local color = level ~= nil and 
				ColorUtils:color16ToC3b(ColorUtils.commonColor.BiaoTi) or 
				ColorUtils:color16ToC3b(ColorUtils.commonColor.Red)
	lvLab:setString(lvStr)
	lvLab:setColor(color)
	if iconImg.img == nil then
		iconImg.img = ccui.ImageView:create()
		local size = iconImg:getContentSize()
		iconImg.img:setPosition(size.width*0.5, size.height*0.5)
		iconImg:addChild(iconImg.img)
	end
	local url = level ~= nil and string.format("images/heroWarcraft/%d.png", data.ID) or "images/newGui2/Icon_lock.png"
	TextureManager:updateImageView(iconImg.img, url)
	local isNotOpen = level == nil
	level = level or 1
	local otherData = ConfigDataManager:getInfoFindByTwoKey(ConfigData.StrategicsLvConfig, "StrategicsID", data.ID, "lv", level)
	local addInfo = StringUtils:jsonDecode(otherData.property)

	local roleProxy = self:getProxy(GameProxys.Role)
	local comNum = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)

	-- local add1 = addInfo[1][2]*comNum
	-- local add2 = addInfo[2][2]*comNum
	local infoStr = StringUtils:getSymmetricStr(otherData.info, "%b##", comNum)
	-- if lockLab.richLab == nil then
	-- 	lockLab.richLab = ComponentUtils:createRichLabel("", nil, nil, 2)
	-- 	lockLab:getParent():addChild(lockLab.richLab)
	-- end
	-- local x, y = lockLab:getPosition()
	-- lockLab.richLab:setPosition(x, y)
	-- lockLab:setVisible(not isNotOpen)
	-- lockLab.richLab:setVisible(isNotOpen)
	-- local text = nil
	-- if isNotOpen then
	-- 	text = {{{data.open, 20, ColorUtils.wordColorDark1604},{"   "..otherData.info, 20, ColorUtils.wordColorDark1603}}}
	-- 	lockLab.richLab:setString(text)
	-- end
	lockLab:setColor(ColorUtils:color16ToC3b(ColorUtils.commonColor.MiaoShu))
	lockLab:setString(infoStr)

end