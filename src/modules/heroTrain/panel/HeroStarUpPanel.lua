--
-- Author: zlf
-- Date: 2016年8月31日14:11:23
-- 英雄升星主界面


HeroStarUpPanel = class("HeroStarUpPanel", BasicPanel)
HeroStarUpPanel.NAME = "HeroStarUpPanel"

function HeroStarUpPanel:ctor(view, panelName)
	HeroStarUpPanel.super.ctor(self, view, panelName)
        
    self:setUseNewPanelBg(true)
end

function HeroStarUpPanel:initPanel()
	HeroStarUpPanel.super.initPanel(self)
	self.proxy = self:getProxy(GameProxys.Hero)
    self._roleProxy = self:getProxy(GameProxys.Role)
	self:getChildByName("bottomPanel/numLab"):setVisible(false)
	self.attrInfos = {}
	for i=1,6 do
		self.attrInfos[i] = self:getChildByName("middlePanel/pnlInfo/item"..i)
	end

--	self.heroName = self:getChildByName("middlePanel/pnlHead/labName")
--	self.argZhangLi = self:getChildByName("middlePanel/pnlHead/imgZhanLiBg/artZhanLi")
--	self.imgGuo = self:getChildByName("middlePanel/pnlHead/imgGuo")

    -- hero卡片容器
    self._imgHeroCard = self:getChildByName("middlePanel/pnlHead/imgHeroCard")
    self._uiHeroCard = UIHeroCard.new(self, self._imgHeroCard)
end

function HeroStarUpPanel:doLayout()
	local tabsPanel = self:getTabsPanel()
	local middlePanel = self:getChildByName("middlePanel")
	local pnlUse = self:getChildByName("pnlUse")
	local bottomPanel = self:getChildByName("bottomPanel")

	NodeUtils:adaptiveUpPanel(middlePanel,tabsPanel,GlobalConfig.topTabsHeight)
	NodeUtils:adaptiveUpPanel(pnlUse,middlePanel,0)
	NodeUtils:adaptiveUpPanel(bottomPanel,pnlUse,0)
	-- NodeUtils:adaptiveDownPanel(bottomPanel,nil,GlobalConfig.downHeight)
	-- NodeUtils:adaptiveCenterPanel(bottomPanel,pnlUse,0)
end

function HeroStarUpPanel:finalize()
	-- for i=1,5 do
	-- 	if self.icons[i].uiIcon ~= nil then
	-- 		self.icons[i].uiIcon:finalize()
	-- 		self.icons[i].uiIcon = nil
	-- 	end
	-- end

    if self._uiHeroCard ~= nil then
        self._uiHeroCard:finalize()
        self._uiHeroCard = nil
    end

	if self.uiRechargePanel ~= nil then
        self.uiRechargePanel:finalize()
        self.uiRechargePanel = nil
    end

    HeroStarUpPanel.super.finalize(self)
end

function HeroStarUpPanel:registerEvents()
    self._insteadArrowImg = self:getChildByName("pnlUse/insteadArrowImg")
    if self._insteadArrowImg._oldX == nil then
	    self._insteadArrowImg._oldX = self._insteadArrowImg:getPositionX()
	end


    self._insteadSoulCb = self:getChildByName("bottomPanel/insteadSoulCb")
    self._insteadSoulTxt = self:getChildByName("bottomPanel/insteadSoulCb/insteadSoulTxt")
    self:addTouchEventListener(self._insteadSoulCb, self.onInsteadSoulCb)
end

function HeroStarUpPanel:onShowHandler()
    self._insteadSoulTxt:setString(self:getTextWord(290081))
	local data = self.view:readCurData()
	self.heroBaseData = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)

	--[[
	self.icons = {}
	for i=1,3 do
		self["star"..i] = {}
		for j=1,5 do
			local starName = string.format("middlePanel/otherImg%d/starPanel/starImg%d", i, j)
			self["star"..i][j] = self:getChildByName(starName)
			self.icons[j] = self:getChildByName("bottomPanel/iconImg"..j)
		end
	end
	--]]


--	self.star = {}
--	for i = 1,5 do
--		local starName = string.format("middlePanel/pnlHead/starPanel/starImg%d", i)
--		self.star[i] = self:getChildByName(starName)
--	end

	if self.bigStar == nil then
		self.bigStar = {}
		for i = 1,5 do
			local starName = string.format("middlePanel/pnlStars/imgStar%d", i)
			self.bigStar[i] = self:getChildByName(starName)
			self.bigStar[i].oldPos = cc.p(self.bigStar[i]:getPosition())
		end
	end


	self.icons = {}
	for j=1,5 do
		self.icons[j] = self:getChildByName("pnlUse/iconImg"..j)
	end

	local upBtn = self:getChildByName("bottomPanel/autoAddBtn")
	self:addTouchEventListener(upBtn, self.sendStarUpReq)


	self:init(data)
end

function HeroStarUpPanel:init(data)

	--heroStarData:在0星的时候为nil
	--nextStarData:在满星的时候为nil
	local heroStarData = ConfigDataManager:getInfoFindByTwoKey(ConfigData.HeroStarConfig, "heroID", data.heroId, "star", data.heroStar)     -- 当前表数据
	local nextStarData = ConfigDataManager:getInfoFindByTwoKey(ConfigData.HeroStarConfig, "heroID", data.heroId, "star", data.heroStar + 1) -- 下一级表数据
	
	self.nextStarData = nextStarData

	local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)
	
	local pnlInfo = self:getChildByName("middlePanel/pnlInfo")
	local itemDaiBing = pnlInfo:getChildByName("itemDaiBing")

	local daiBingLab = itemDaiBing:getChildByName("addLab")--带兵

	local nextDaiBingLab = itemDaiBing:getChildByName("otherLab")-- 第二个带兵文本
	
	local itemXianShou = pnlInfo:getChildByName("itemXianShou")
	local labXianShou = itemXianShou:getChildByName("addLab")--先手
	local labXianShouOther = itemXianShou:getChildByName("otherLab")--先手加成
	local descLab = self:getChildByName("middlePanel/pnlInfo/itemDengJi/descLab")
	local needLvLab = self:getChildByName("middlePanel/pnlInfo/itemDengJi/labCurLv")--self:getChildByName("middlePanel/otherImg1/lvLab")
	local needLvLab1 = self:getChildByName("middlePanel/pnlInfo/itemDengJi/labNeedLv")

--	--战力
--    local info = self.proxy:getInfoById(data.heroDbId)
--    if info and info.heroPosition then
--        local fightVal = self.proxy:calculateHeroFight(info,{})--self.curHeroId
--        if self.argZhangLi then
--            self.argZhangLi:setString(string.format("%d",fightVal))
--        end
--    end
    
--    --国家
--    TextureManager:updateImageView(self.imgGuo, string.format("images/heroBgIcon/TxtGuo%d.png",config.countryIcon)) 

	local starUrl = "images/newGui1/IconStarMini.png"
	local drakUrl = "images/newGui1/IconStarMiniBg.png"
	local color = ColorUtils:getColorByQuality(self.heroBaseData.color) or cc.c3b(255,255,255)
--	--panel有3个英雄界面   这里初始化数据，位置调整
--	local heroImgPanel = self:getChildByName("middlePanel/pnlHead")
--	local img = heroImgPanel:getChildByName("imgHead")
--	TextureManager:updateImageViewFile(img, ComponentUtils:getHeroHalfBodyUrl(data.heroId))

--	self.heroName:setString(self.heroBaseData.name)
--	-- self.heroName:setColor(color)
--	local imgKuang = self:getChildByName("middlePanel/pnlHead/imgKuang") -- 已满新
--	local path = string.format("images/heroBgIcon/bgHeroColor%d.png",self.heroBaseData.color)
--	TextureManager:updateImageView(imgKuang, path)

--    ---[[加入品质特效
--    if imgKuang.ccb then
--        imgKuang.ccb:finalize()
--        imgKuang.ccb = nil
--    end

--    if GlobalConfig.HeroColor2Effect[config.color] then
--        imgKuang.ccb = self:createUICCBLayer(
--        		GlobalConfig.HeroColor2Effect[self.heroBaseData.color], imgKuang)
--        local size = imgKuang:getContentSize()
--        imgKuang.ccb:setPosition(size.width-15,size.height/2-19)
--    end
--    --]]

	local maxStarImg = self:getChildByName("middlePanel/maxStarImg") -- 已满星
	maxStarImg:setVisible(nextStarData == nil)

    --//null 满星的时候隐藏需求等级
    local itemDengJi=self:getChildByName("middlePanel/pnlInfo/itemDengJi")
    print("----------------------Name:"..itemDengJi:getName())
    if nextStarData == nil then 
    itemDengJi:setVisible(false)
    else
    itemDengJi:setVisible(true)
    end



	local bottomPanel = self:getChildByName("bottomPanel") -- 底部层显示
	bottomPanel:setVisible(nextStarData ~= nil)

	local pnlUse = self:getChildByName("pnlUse") -- 消耗
	pnlUse:setVisible(true)

	for i=1,5 do 
		self.icons[i]:setVisible(nextStarData ~= nil) -- 星星显示
	end

	local heroAttrInfos = self.proxy:getHeroStarUpAttr(data, nextStarData, heroStarData)
	for k,v in pairs(heroAttrInfos) do
		local addLab = self.attrInfos[k]:getChildByName("addLab") -- 当前星级的属性
		-- local iconImg = self.attrInfos[k]:getChildByName("iconImg") -- 属性图标
		-- iconImg:setScale(0.85)
		local otherLab = self.attrInfos[k]:getChildByName("otherLab") -- 下一级加成文本
		local descLab = self.attrInfos[k]:getChildByName("descLab") -- 属性文本，不是解锁文本
		descLab:setString(v.text)
		otherLab:setVisible(v.add ~= 0)

		local addStr = ""
		local baseStr = ""
		if k ~= 1 and k ~= 4 then
			local addNum = StringUtils:getPreciseDecimal((v.add/100), 2)
			addStr = "+"..addNum.."%"
			baseStr = (v.base/100).."%"
		else
			addStr = "+".. ( math.ceil(v.add))
			baseStr = math.ceil(v.base)
		end

		otherLab:setString(addStr)
		addLab:setString(baseStr)
		local labX = addLab:getPositionX() + addLab:getContentSize().width
		otherLab:setPositionX(labX + 5)
		local url = self.proxy:getIconPath(k)
		-- TextureManager:updateImageView(iconImg, url)
	end
	-- 调整星星位置
	-- for i=1,3 do
	-- 	ComponentUtils:adjustStarPos(163, self["star"..i], self.heroBaseData.starmax)
	-- end
	local bigStarUrl = "images/newGui1/IconStar.png"
	local bigDrakUrl = "images/newGui1/IconStarBg.png"

    --战力
    local fightVal = 0
    local info = self.proxy:getInfoById(data.heroDbId)
    if info and info.heroPosition then
        fightVal = self.proxy:calculateHeroFight(info,{})--self.curHeroId
    end

	--满级
	if nextStarData == nil then
        
--	    ComponentUtils:renderStar(self.star, data.heroStar, starUrl, drakUrl, self.heroBaseData.starmax)

	    ComponentUtils:renderStar(self.bigStar, data.heroStar, bigStarUrl, bigDrakUrl, self.heroBaseData.starmax)

		daiBingLab:setString(self.proxy:getHeroCommandNumWithData(data))
        --labXianShou:setString(self.proxy:getFirstnum(data.heroPosition))--使用这个有缺陷,如果,是从将军府培养跳转到武将训练模块,有一些武将并没有占坑位
        labXianShou:setString(self.proxy:getFirstnumFromData(data))

        labXianShouOther:setVisible(false)
        nextDaiBingLab:setVisible(false)
        pnlUse:setVisible(false)

        local cardData = { }
        cardData.heroId = data.heroId
        cardData.starNum = data.heroStar
        cardData.fightting = fightVal
        self._uiHeroCard:updateData(cardData)

		return
	--0星读不到数据
	elseif heroStarData == nil then
		daiBingLab:setString(self.proxy:getHeroCommandNumWithData(data))
	else
		daiBingLab:setString(self.proxy:getHeroCommandNumWithData(data))
	end

	nextDaiBingLab:setVisible(true)
	labXianShouOther:setVisible(true)

--	ComponentUtils:renderStar(self.star, data.heroStar, starUrl, drakUrl, self.heroBaseData.starmax)

	ComponentUtils:renderStar(self.bigStar, data.heroStar, bigStarUrl, bigDrakUrl, self.heroBaseData.starmax)


	----[[重置星星位置
	for i = 1,#self.bigStar do
		self.bigStar[i]:setPosition(self.bigStar[i].oldPos)
	end

	local tmp_star = {}
	for i = 1,self.heroBaseData.starmax do
		table.insert(tmp_star,self.bigStar[i])
	end
	NodeUtils:centerNodes(self.bigStar[3], tmp_star)
	--]]

	needLvLab:setString(data.heroLv)

	if nextStarData then
		needLvLab1:setString("/"..nextStarData.lvneed)
		NodeUtils:alignNodeL2R(descLab,needLvLab,needLvLab1)

		local color = data.heroLv >= nextStarData.lvneed and cc.c3b(0, 255, 0) or cc.c3b(255, 0, 0)
		needLvLab:setColor(color)

		nextDaiBingLab:setString("+"..nextStarData.command)
		--先手值 && 下一星先手值
        local nowFirstValue = 0
        if heroStarData ~= nil then --当0星的时候, 这个是nil
            nowFirstValue = heroStarData.firstValueShow
        end
        --labXianShou:setString(self.proxy:getFirstnum(data.heroPosition))--使用这个有缺陷,如果,是从将军府培养跳转到武将训练模块,有一些武将并没有占坑位
        labXianShou:setString(self.proxy:getFirstnumFromData(data))
        labXianShouOther:setString("+" ..nextStarData.firstValueShow-nowFirstValue)
    end

    if nextStarData then

		local needData = StringUtils:jsonDecode(nextStarData.itemneed)
		local roleProxy = self:getProxy(GameProxys.Role)
		--存放升星所需物品和背包有的物品的数量差，用于计算元宝升级
		self.isEnough = {}
		self.isHeroEnough = {}
		self._isNeedHeroSoul = false
	    --渲染icon
		for i=1,#needData do
			local num = roleProxy:getRolePowerValue(needData[i][1], needData[i][2]) -- 当前拥有数量
			self:renderChild(self.icons[i], num, needData[i][3])
			if num < needData[i][3] then
				self.isEnough[needData[i][2]] = needData[i][3] - num -- 存储不够的数量
				self.isHeroEnough[needData[i][1]] = true
			end

			local iconData = {}
			iconData.typeid = needData[i][2]
			iconData.num = needData[i][3]
			iconData.power = needData[i][1]
			if self.icons[i].uiIcon == nil then
				self.icons[i].uiIcon = UIIcon.new(self.icons[i], iconData, false, self, nil, true)
			else
				self.icons[i].uiIcon:updateData(iconData)
			end

	        -- 是否需要魂
	        if needData[i][1] == GamePowerConfig.HeroFragment then
	            self._isNeedHeroSoul = true
	        end
		end
		local heroNeed = StringUtils:jsonDecode(nextStarData.heroneed)
		local len = #needData
		--下面这段代码heroneed的渲染icon  没作用  因为heroneed合并到itemneed字段中
		if #heroNeed ~= 0 then
			self._enableTouch = true

			len = #needData + 1
			local num = self.proxy:getHeroPieceNumByID(heroNeed[2], heroNeed[3], data)
			if num ~= 0 then
				self._enableTouch = nil
			end
			self:renderChild(self.icons[len], num, heroNeed[4], heroNeed[3])
		 	self.icons[len]:setVisible(true)

		 	local iconData = {}
			iconData.typeid = heroNeed[2]
			iconData.num = heroNeed[4]
			iconData.power = heroNeed[1]
			if self.icons[len].uiIcon == nil then
				self.icons[len].uiIcon = UIIcon.new(self.icons[len], iconData, false, self, nil, true)
			else
				self.icons[len].uiIcon:updateData(iconData)
			end
		end
	    for i=len+1,5 do
	        self.icons[i]:setVisible(false)
	    end


		labXianShouOther:setPositionX(labXianShou:getPositionX() + labXianShou:getContentSize().width)

		nextDaiBingLab:setPositionX(daiBingLab:getPositionX() + daiBingLab:getContentSize().width)

	    -- 升星魂功能
	    self._insteadSoulIcon = pnlUse:getChildByName("insteadSoulIcon")
	    if self._insteadSoulIcon._oldX == nil then
	    	self._insteadSoulIcon._oldX = self._insteadSoulIcon:getPositionX()
	    end
	    self:updateInsteadSoul(self._insteadSoulIcon)

	end


    local cardData = { }
    cardData.heroId = data.heroId
    cardData.starNum = data.heroStar
    cardData.fightting = fightVal
    self._uiHeroCard:updateData(cardData)

end

------
-- 升星魂功能
function HeroStarUpPanel:updateInsteadSoul(node)
    local iconData = {}
	iconData.power = GamePowerConfig.HeroFragment
    iconData.typeid = 28 -- 升星魂
	iconData.num = self.proxy:getHeroPieceNumByID(iconData.typeid)
    local needInsteadNum = self:getNeedInsteadNum() -- 缺少的武将魂数量
    local rich01Color = ColorUtils.wordGreenColor16
    if needInsteadNum > iconData.num then
        rich01Color = ColorUtils.wordRedColor16
    end
    iconData.customNumStr = {{{ needInsteadNum, 14, rich01Color}, { "/"..iconData.num, 14, ColorUtils.wordWhiteColor16}  }}
    if node.uiIcon == nil then
        
        node.uiIcon = UIIcon.new(node, iconData, true, self, nil, true)
    else

        node.uiIcon:updateData(iconData)
    end

    -- 显示初始化控制
    self._insteadSoulIcon:setVisible(false)
    self._insteadArrowImg:setVisible(false)
    self._insteadSoulCb:setSelectedState(false)
end

------
-- 
function HeroStarUpPanel:onInsteadSoulCb(sender)
    -- 需要武将魂而且不够的情况才给点
    if self:getNeedInsteadNum() > 0 then
        local state = sender:getSelectedState()
        if state then
            self._insteadSoulIcon:setVisible(false)
            self._insteadArrowImg:setVisible(false)
        else
            self._insteadSoulIcon:setVisible(true)
            self._insteadArrowImg:setVisible(true)


			local needData = StringUtils:jsonDecode(self.nextStarData.itemneed)
			local len = #needData
			if len >= 4 then
				self._insteadArrowImg:setPositionX(self._insteadArrowImg._oldX)
				self._insteadSoulIcon:setPositionX(self._insteadSoulIcon._oldX)
			elseif len == 3 then
				self._insteadArrowImg:setPositionX(self.icons[4]:getPositionX())
				self._insteadSoulIcon:setPositionX(self._insteadArrowImg._oldX)
			else
				self._insteadArrowImg:setPositionX(self.icons[len+1]:getPositionX())
				self._insteadSoulIcon:setPositionX(self.icons[len+2]:getPositionX())
			end
			
        end
    else
        if self._isNeedHeroSoul then
            self:showSysMessage(self:getTextWord(290078)) -- "武将升星所需将魂足够，不需要升星魂"
        else
            self:showSysMessage(self:getTextWord(290079)) -- "武将升星不需要升星魂"
        end
        self._insteadSoulCb:setSelectedState(true)
    end
end

function HeroStarUpPanel:sendStarUpReq(sender)
	self.isEnough = self.isEnough or {}
	self.isHeroEnough = self.isHeroEnough or {}
	for k,v in pairs(self.isHeroEnough) do -- 
		if k == GamePowerConfig.HeroFragment then
			if self._insteadSoulIcon:isVisible() then
                if self.proxy:getHeroPieceNumByID(28) < self:getNeedInsteadNum() then
                    self:showSysMessage(self:getTextWord(290080))
			        return
                end
            else
                self:showSysMessage(self:getTextWord(290080))
			    return
		    end
        end
	end

	local function starUp()
		local data = self.view:readCurData()
		local sendData = {}
		sendData.heroId = data.heroDbId
		sendData.upType = 2
        sendData.useSuper = self._insteadSoulIcon:isVisible() and 1 or 0
		self.proxy:onTriggerNet300001Req(sendData)
	end

	if table.size(self.isEnough) > 0 then
		local context = TextWords:getTextWord(290017)
		self.proxy:CommonLvUpEnough(self.isEnough, self, starUp, context)
	else
		starUp()
	end

	
end
-- 播放升星动画，由HeroTrainView:lvUpSuccess()调用
function HeroStarUpPanel:starUpSuccess()
    -- 数据获取
    local data = self.view:readCurData()
    local ID = data.heroDbId
	local newData = self.proxy:getInfoById(ID)
	self.view:saveCurData(newData)

	local middlePanel = self:getChildByName("middlePanel")
	-- local effect = UICCBLayer.new("rgb-wjsx", middlePanel, nil, nil, true)
	-- effect:setLocalZOrder(10)
	-- local x = middlePanel:getContentSize().width/2
	-- local y = middlePanel:getChildByName("otherImg1"):getPositionY() + 20
	-- effect:setPosition(x, y)
    
    -- 延迟执行函数
    local function updateView()
	    self:init(newData)
    end

    -- 计算下一级的数据，满级的话特殊化处理
    local nextStarData = ConfigDataManager:getInfoFindByTwoKey(ConfigData.HeroStarConfig, "heroID", newData.heroId, "star", newData.heroStar + 1) -- 下一级表数据
    if nextStarData == nil then
        -- 延迟等特效播完
        TimerManager:addOnce(1500, updateView, self)
    else
        updateView()
    end
end

function HeroStarUpPanel:renderChild(item, haveNum, needNum, isHero)
	local haveLab = item:getChildByName("haveLab")
	local needLab = item:getChildByName("needLab")
	local starImg = item:getChildByName("starImg")
	local numImg = item:getChildByName("numImg")
	haveLab:setLocalZOrder(10)
	needLab:setLocalZOrder(10)
	starImg:setLocalZOrder(10)
	numImg:setLocalZOrder(10)
	numImg:setVisible(isHero ~= nil)
	starImg:setVisible(isHero ~= nil)
	local url = string.format("images/heroTrain/0%d.png", isHero or 1)
	TextureManager:updateImageView(numImg, url)
	local color = haveNum >= needNum and cc.c3b(0, 255, 0) or cc.c3b(255, 0, 0)
	haveLab:setColor(color)
	haveLab:setString(haveNum)
	needLab:setString("/"..needNum)
end

-- 获取缺少的武将魂数量
-- == 0 武将升星所需将魂足够，不需升星魂
-- == -1 武将升星不需要升星魂
function HeroStarUpPanel:getNeedInsteadNum()
    local needNum = 0
    for typeId, need in pairs(self.isEnough) do
        if typeId == self.heroBaseData.ID then
            needNum = need
            break
        end
    end
    return needNum
end