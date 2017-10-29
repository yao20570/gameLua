--
-- Author: zlf
-- Date: 2016年9月22日22:55:56
-- 英雄查看信息界面

--@params canResolve 是否能分解   herohalltrainpanel在显示这个界面的时候是可以分解英雄的  可传nil

UIHeroInfoPanel = class("UIHeroInfoPanel")


--parent  要有 getProxy的接口
function UIHeroInfoPanel:ctor(parent, typeid, isShare, isHave, canResolve)
	local uiSkin = UISkin.new("UIHeroInfoPanel")
    uiSkin:setParent(parent:getParent())
    uiSkin:setLocalZOrder(100)

    self.secLvBg = UISecLvPanelBg.new(uiSkin:getRootNode(), self)
    self.secLvBg:setContentHeight(500)
    self.secLvBg:setTitle("武将信息")
    self.secLvBg:setBackGroundColorOpacity(120)
    
    self._uiSkin = uiSkin
    self.parent = parent

    self.heroProxy = self.parent:getProxy(GameProxys.Hero)
    self.heroProxy:addEventListener(AppEvent.PROXY_HERO_POS_RESOLVE, self, self.closeSelf)
    
    -- 自适应分辨率
    local scale = NodeUtils:getAdaptiveScale()
    local mainPanel = self:getChildByName("mainPanel")

    local shareBtn = self:getChildByName("mainPanel/shareBtn")
    shareBtn:setVisible(isShare == nil and isHave ~= nil)
    ComponentUtils:addTouchEventListener(shareBtn, self.onShare, nil, self)

    local resolveBtn = self:getChildByName("mainPanel/resolveBtn")
    resolveBtn:setVisible(isShare == nil and canResolve ~= nil)
    resolveBtn:setTitleText(TextWords[290070])

    if isShare == nil then
    	if isHave ~= nil and canResolve == nil then
    		shareBtn:setPositionX(320)
    	elseif isHave == nil and canResolve ~= nil then
    		resolveBtn:setPositionX(320)
    	end
    end

    ComponentUtils:addTouchEventListener(resolveBtn, self.onResolve, nil, self)

    mainPanel:setScale(1/scale)

    self:updateView(typeid)
end

function UIHeroInfoPanel:updateView(data)
	local typeid
	local heroData
	local lvLab = self:getChildByName("mainPanel/infoPanel/lvLab")
   
   --//null
    local starPanel=self:getChildByName("mainPanel/infoPanel/starPanel")
    local daiNumLab=self:getChildByName("mainPanel/infoPanel/decNewPanel/daiNumLab")
    local xianNumLab=self:getChildByName("mainPanel/infoPanel/decNewPanel/xianNumLab")
    local stars = {}
	for i=1,5 do
		stars[i] = starPanel:getChildByName("starImg"..i)
	end
    local starUrl = "images/newGui1/IconStarMini.png"
    local drakUrl = "images/newGui1/IconStarMiniBg.png"

    print("..................."..type(data))
    if type(data) == "number" then
    starPanel:setVisible(false)
    daiNumLab:getParent():setVisible(false)
    else
    starPanel:setVisible(true)
    daiNumLab:getParent():setVisible(true)
    local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)
    ComponentUtils:renderStar(stars, data.heroStar, starUrl, drakUrl, config.starmax)
    xianNumLab:setString(self.heroProxy:getFirstnumFromData(data))
    daiNumLab:setString(self.heroProxy:getHeroCommandNumWithData(data))
    end


	if type(data) == "number" then
		typeid = data
		self._curTypeid = typeid
		heroData = {heroId = typeid, heroStar = 0, heroLv = 1}
		lvLab:setString("Lv.1")
	else
		typeid = data.heroId
		heroData = data
		lvLab:setString("Lv."..data.heroLv)
		self._curTypeid = data.heroDbId
	end

	self._heroData = data

	local heroBaseData = ConfigDataManager:getConfigById(ConfigData.HeroConfig, typeid)
	
	local nameTxt = self:getChildByName("mainPanel/infoPanel/nameTxt")
	local iconImg = self:getChildByName("mainPanel/infoPanel/iconImg/icon")
	nameTxt:setString(heroBaseData.name)
	local color = ColorUtils:color16ToC3b(ColorUtils:getRichColorByQuality(heroBaseData.color))
	nameTxt:setColor(color)

	--//null
    ----------------------------------6337
    --print("----------------------------"..nameTxt:getPositionY())
    NodeUtils:alignNodeL2R(nameTxt,lvLab,starPanel)
    --print("----------------------------"..nameTxt:getPositionY())
    starPanel:setPositionY(nameTxt:getPositionY()+12)
    --print("----------------------------"..starPanel:getPositionY())

    ----------------------------------6337



	local keys = {"lead", "brave", "sta"}
	for index,key in pairs(keys) do
		local attrLab = self:getChildByName("mainPanel/infoPanel/attrLab"..index)
		local attrStr = heroBaseData[key]
		attrLab:setString(attrStr)
	end
    local iconData = {}
    iconData.power  = 409
    iconData.typeid = typeid
    iconData.num    = 1
    local icon = iconImg.uiIcon
    if icon == nil then
		icon = UIIcon.new(iconImg, iconData, false, nil)
		iconImg.uiIcon = icon
	else
		icon:updateData(iconData)
	end


	
	--假英雄数据

	local baseAttrInfo = self.heroProxy:getHeroAllAttr(heroData)
	for k,v in pairs(baseAttrInfo) do
		local node = self:getChildByName("mainPanel/attrImg"..k)
		local path = self.heroProxy:getIconPath(k)
		local attrIcon = node:getChildByName("iconImg")
		-- TextureManager:updateImageView(attrIcon, path)
		local nameLab = node:getChildByName("nameLab")
		local addLab = node:getChildByName("addLab")
		local baseStr = ""
		if k ~= 4 and k ~= 1 then
			baseStr = (v.base/100).."%"
		else
			baseStr = math.ceil(v.base)
		end
		addLab:setString(baseStr)
		nameLab:setString(v.text)
	end

	local talentLab = self:getChildByName("mainPanel/talentPanel/talentLab")
	-- talentLab:ignoreContentAdaptWithSize(false) 
	-- talentLab:setContentSize(cc.size(460, 200))
	local talentStr = ""

	local talentData = StringUtils:jsonDecode(heroBaseData.talent)
	for k,v in pairs(talentData) do
		local talentConfig = ConfigDataManager:getConfigById(ConfigData.HeroGiftConfig, v)
		talentStr = talentStr .. talentConfig.info
	end
	-- talentStr = string.gsub(talentStr, "\\n", " ")
	talentLab:setString(talentStr)

	-- local talentIcon = self:getChildByName("mainPanel/talentPanel/tbalentImg/icon")
	-- local talentUrl = string.format("images/hero/talent%d.png", heroBaseData.color)
	-- TextureManager:updateImageView(talentIcon, talentUrl)
end

function UIHeroInfoPanel:getChildByName(name)
	return self._uiSkin:getChildByName(name)
end

function UIHeroInfoPanel:finalize()
	if self._uiSharePanel ~= nil then
		self._uiSharePanel:finalize()
		self._uiSharePanel = nil
	end
	self.heroProxy:removeEventListener(AppEvent.PROXY_HERO_POS_RESOLVE, self, self.closeSelf)

    self._uiSkin:finalize()
    self._uiSkin = nil
end

function UIHeroInfoPanel:hide()
	TimerManager:addOnce(1, self.finalize, self)
end

function UIHeroInfoPanel:onShare(sender)
	if self._uiSharePanel == nil then
        self._uiSharePanel = UISharePanel.new(sender, self.parent)
    end
    
    local data = {}
    data.type = ChatShareType.HERO_TYPE
    data.id = self._curTypeid
    self._uiSharePanel:showPanel(sender, data)
end

function UIHeroInfoPanel:onResolve(sender)
    -- 手动遣散
	self.heroProxy:setResolveId(self._heroData.heroDbId)
	self.heroProxy:onTriggerNet300102Req({id = self._heroData.heroDbId})
end

function UIHeroInfoPanel:closeSelf()
	if self._uiSkin:isVisible() then
		self:hide()
	end
end

function UIHeroInfoPanel:setLocalZOrder(num)
	self._uiSkin:setLocalZOrder(num)
end