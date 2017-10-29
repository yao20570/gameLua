--
-- Author: zlf
-- Date: 2016年8月30日16:02:41
-- 英雄升级主界面


HeroLvUpPanel = class("HeroLvUpPanel", BasicPanel)
HeroLvUpPanel.NAME = "HeroLvUpPanel"

HeroLvUpPanel.ListPanel = {}
HeroLvUpPanel.ListPanel.JingYanShuIdx = 1
HeroLvUpPanel.ListPanel.YingXiongIdx = 2

function HeroLvUpPanel:ctor(view, panelName)
	HeroLvUpPanel.super.ctor(self, view, panelName)
	self.effectTime = 0.25
	self.actionTime = 0.15
    self.addingDelayTime = 0.24
    
    self:setUseNewPanelBg(true)
end

function HeroLvUpPanel:initPanel()
	HeroLvUpPanel.super.initPanel(self)

	self.topPanel = self:getChildByName("topPanel")

	local middlePanel = self:getChildByName("middlePanel")
    self._middelPanel = middlePanel


	self.proxy = self:getProxy(GameProxys.Hero)
	--self.labName = middlePanel:getChildByName("pnlHead"):getChildByName("labName")
	self.lvLab = self:getChildByName("middlePanel/pnlBar/lvLab")
    self.lvMaxLab = self:getChildByName("middlePanel/pnlBar/lvMaxLab")
    self.lvDiffLab = self:getChildByName("middlePanel/pnlBar/lvDiffLab")


    -- hero卡片容器
    self._imgHeroCard = self:getChildByName("middlePanel/pnlHead/imgHeroCard")
    self._uiHeroCard = UIHeroCard.new(self, self._imgHeroCard)

    
    --self.heroImg = middlePanel:getChildByName("pnlHead"):getChildByName("imgHead")

	--self.heroPos = cc.p(self.heroImg:getPosition())

	self.maxLvImg = self:getChildByName("middlePanel/pnlBar/maxLvImg")

    self.labDianJiShiYong = self:getChildByName("posListPanel/listPanel/labDianJiShiYong")
    --头像框
    --self.imgKuang = self:getChildByName("middlePanel/pnlHead/imgKuang")
    --带兵
    self.labDaiBing = self:getChildByName("middlePanel/infoPanel/item7/addLab")
    --先手
    self.labXianShou = self:getChildByName("middlePanel/infoPanel/item8/addLab")
    --国
    --self.imgGuo = self:getChildByName("middlePanel/pnlHead/imgGuo")

    --战力
    --self.labZhanLi = self:getChildByName("middlePanel/pnlHead/imgZhanLiBg/artZhanLi")

	self.expBar = self:getChildByName("middlePanel/pnlBar/Image_50/expBar")
	self.effBar = self:getChildByName("middlePanel/pnlBar/Image_50/effBar")
	self.effBar:setPercent(0)
	self.expLab = self:getChildByName("middlePanel/pnlBar/Image_50/expLab")

	--self.stars = {}
	self.attrInfos = {}
	for i=1,5 do
		self["otherImg"..i] = middlePanel:getChildByName("otherImg"..i)
		--self.stars[i] = self:getChildByName("middlePanel/pnlHead/starPanel/starImg"..i)
		self.attrInfos[i] = self:getChildByName("middlePanel/infoPanel/item"..i)
	end
	self.attrInfos[6] = self:getChildByName("middlePanel/infoPanel/item6")

	self.expKey = {"wexpneed", "gexpneed", "bexpneed", "pexpneed", "oexpneed"}

    -- 新的材料选择界面
    self._posListPanel = self:getChildByName("posListPanel")
    local listPanel = self._posListPanel:getChildByName("listPanel")
    self._cardListView = listPanel:getChildByName("cardList")
    self._heroListView = listPanel:getChildByName("heroList")


    -- 状态初始化
    self._cardListView:setVisible(false)
    self._heroListView:setVisible(false)
    self._listPanelIndex = HeroLvUpPanel.ListPanel.JingYanShuIdx

    -- 初始化两边的箭头特效
    self:setEdgeEff()
end





function HeroLvUpPanel:doLayout()
	local tabsPanel = self:getTabsPanel()
	-- NodeUtils:adaptiveTopPanelAndListView(self.topPanel, nil, nil, tabsPanel)

    local middlePanel = self:getChildByName("middlePanel")
    local posListPanel = self:getChildByName("posListPanel")

    NodeUtils:adaptiveUpPanel(middlePanel,tabsPanel,GlobalConfig.topTabsHeight)
    NodeUtils:adaptiveUpPanel(posListPanel,middlePanel,0)


end

function HeroLvUpPanel:finalize()
    if self._uiHeroCard ~= nil then
        self._uiHeroCard:finalize()
        self._uiHeroCard = nil
    end

    if self.uiHeroPanel ~= nil then
    	self.uiHeroPanel:destory()
    	self.uiHeroPanel = nil
    end

    if self.listenner ~= nil then
        local eventDispatcher = self._touchLayer:getEventDispatcher()
        eventDispatcher:removeEventListenersForTarget(self._touchLayer)
        self.listenner = nil
    end

    if self._touchLayer ~= nil then
    	self._touchLayer:removeFromParent()
    	self._touchLayer = nil
    end

    
    if self.leftEct ~= nil then
        self.leftEct:finalize()
        self.leftEct = nil
    end

    if self.rightEct ~= nil then
        self.rightEct:finalize()
        self.rightEct = nil
    end

    HeroLvUpPanel.super.finalize(self)
end

function HeroLvUpPanel:registerEvents()
    local listPanel = self._posListPanel:getChildByName("listPanel")
    self._toCardBtn = listPanel:getChildByName("toCardBtn")
    self._toCardBtn.index = 1

    self._toHeroBtn = listPanel:getChildByName("toHeroBtn")
    
    self._toHeroBtn.index = 2
    self:addTouchEventListener(self._toCardBtn, self.changeList)
    self:addTouchEventListener(self._toHeroBtn, self.changeList)
end

function HeroLvUpPanel:changeList(sender)
    if self._listPanelIndex ~= sender.index then
        self._listPanelIndex = sender.index
    else
        return
    end

    --logger:info("当前的页面是："..self._listPanelIndex)
    self:showListCtrl(self._listPanelIndex, true)
end


function HeroLvUpPanel:setTabBtnState(btn, state)
    if state then
        -- btn:loadTextures("images/heroTrain/change_pres_btn.png", "images/heroTrain/change_pres_btn.png", "", 1)
        btn:loadTextures("images/newGui9Scale/SpTab2.png", "images/newGui9Scale/SpTab2.png", "", 1)
        --btn:setTouchEnabled(false)
    else
        -- btn:loadTextures("images/heroTrain/change_none_btn.png", "images/heroTrain/change_pres_btn.png", "", 1)
        btn:loadTextures("images/newGui9Scale/SpTab1.png", "images/newGui9Scale/SpTab1.png", "", 1)
        --btn:setTouchEnabled(true)
    end
end

-- 显示
--@index
-- true
function HeroLvUpPanel:showListCtrl(index, isRender)
    if index == HeroLvUpPanel.ListPanel.JingYanShuIdx then
        if not self._cardListView:isVisible() then
            self._cardListView:setVisible(true)
            self._heroListView:setVisible(false)
            self.labDianJiShiYong:setVisible(false)
        end
    elseif index == HeroLvUpPanel.ListPanel.YingXiongIdx then
        if not self._heroListView:isVisible() then
            self._cardListView:setVisible(false)
            self._heroListView:setVisible(true)
            self.labDianJiShiYong:setVisible(false)
        end
    end

    -- 按钮选中
    if index == HeroLvUpPanel.ListPanel.JingYanShuIdx then
        self._toCardBtn:setTitleColor(ColorUtils.commonColor.c3bWhite)
        self._toHeroBtn:setTitleColor(ColorUtils.commonColor.c3bMiaoShu)
        self:setTabBtnState(self._toCardBtn, true)
        self:setTabBtnState(self._toHeroBtn, false)
    elseif index == HeroLvUpPanel.ListPanel.YingXiongIdx then
        self._toCardBtn:setTitleColor(ColorUtils.commonColor.c3bMiaoShu)
        self._toHeroBtn:setTitleColor(ColorUtils.commonColor.c3bWhite)
        self:setTabBtnState(self._toCardBtn, false)
        self:setTabBtnState(self._toHeroBtn, true)
    end


    
    if isRender then
        if index == HeroLvUpPanel.ListPanel.JingYanShuIdx then
            self:renderCardList()
        elseif index == HeroLvUpPanel.ListPanel.YingXiongIdx then
            self:renderHeroList()
        end
    end

end

-- 切换英雄的时候也会调用
function HeroLvUpPanel:onShowHandler(param)
	self._isHave = true
    self._hadLevelUp = false -- 重置
	local data = self.view:readCurData()

	self.playing = nil
	self.curHeroId = data.heroDbId
	self:initMainHeroData(data)
	self:initView(param)

    -- 材料选择界面
    self:showListCtrl(self._listPanelIndex, true)

	self:addTouchLayer()
end

function HeroLvUpPanel:addTouchLayer()
    if self.listenner ~= nil then
        return
    end

    if self._touchLayer == nil then
    	self._touchLayer = cc.Layer:create()
        
    	local bottomParent = self:getChildByName("middlePanel")
    	bottomParent:addChild(self._touchLayer)
    	self._touchLayer:setLocalZOrder(100)
    end

    local x = 0
    self.listenner = cc.EventListenerTouchOneByOne:create()
    self.listenner:setSwallowTouches(false)

    self.listenner:registerScriptHandler(function(touch, event)    
        local location = touch:getLocation()   
        x = location.x
        if self.playing ~= nil then
        	return false
        end
        if self.uiHeroPanel ~= nil then
        	return (not self.uiHeroPanel:getRootNode():isVisible())
        end

        return self:isModuleVisible() and self:isVisible()
    end, cc.Handler.EVENT_TOUCH_BEGAN )

    self.listenner:registerScriptHandler(function(touch, event)
        local location = touch:getLocation() 
        if location.x - x > 30 then
            self:touchEnded(-1)
        elseif location.x - x < -30 then
            self:touchEnded(1)
        end
    end, cc.Handler.EVENT_TOUCH_ENDED ) 
    local eventDispatcher = self._touchLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.listenner, self._touchLayer)
end

function HeroLvUpPanel:touchEnded(dir)
	if #self.allData == 1 then
		return
	end
	self.curIndex = self.curIndex + dir
	self.curIndex = self.curIndex > 1 and self.curIndex or 1
	self.curIndex = self.curIndex < #self.allData and self.curIndex or #self.allData
	self.view:saveCurData(self.allData[self.curIndex])
	self:onShowHandler(true)
end

function HeroLvUpPanel:getOtherPanel()
	return self.uiHeroPanel
end

function HeroLvUpPanel:closeCallBack()

end

--初始化主英雄UI
function HeroLvUpPanel:initMainHeroData(data)
	local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)
	local nextLvExp = self:getNextLvExp(data)
	self.maxLvImg:setVisible(config.lvmax <= data.heroLv)
    

	local expStr = string.format("%d/%d", data.heroExp, nextLvExp)
	self.expLab:setVisible(nextLvExp ~= 0)

	--local heroUrl = ComponentUtils:getHeroHalfBodyUrl(data.heroId) 
	--TextureManager:updateImageViewFile(self.heroImg, heroUrl)

	--local offsetsPos = StringUtils:jsonDecode(config.pokedexPos)
	-- self.heroImg:setPosition(self.heroPos.x + offsetsPos[1] * 0.7, self.heroPos.y + offsetsPos[2] * 0.7)
    --self.maxLvImg:setPosition(self.heroPos.x - offsetsPos[1] * 0.7 + 65, self.heroPos.y - offsetsPos[2] * 0.7)
	--self.maxLvImg:setVisible(true)
    self.expLab:setString(expStr)
	
	--self.labName:setString(config.name)
	-- local color = ColorUtils:getColorByQuality(config.color) or cc.c3b(255,255,255)
	-- self.labName:setColor(color)
	local nowPencent = data.heroExp/nextLvExp*100 > 100 and 100 or data.heroExp/nextLvExp*100
	local percent = nextLvExp == 0 and 100 or nowPencent
	self.expBar:setPercent(percent)
    
--    local path = string.format("images/heroBgIcon/bgHeroColor%d.png",config.color)
--    TextureManager:updateImageView(self.imgKuang, path)



    --加入品质特效
--    if self.imgKuang.ccb then
--        self.imgKuang.ccb:finalize()
--        self.imgKuang.ccb = nil
--    end

--    if GlobalConfig.HeroColor2Effect[config.color] then
--        self.imgKuang.ccb = self:createUICCBLayer(GlobalConfig.HeroColor2Effect[config.color], self.imgKuang)
--        local size = self.imgKuang:getContentSize()
--        self.imgKuang.ccb:setPosition(size.width-15,size.height/2-19)
--    end

    -- 
    self:setAddingHeroAttr(0, self.curHeroId)
    --
    
    if config.lvmax <= data.heroLv then
        self:setMaxLvBarShow() -- 满级后进度条的特殊显示
    end
	
--    local starUrl = "images/newGui1/IconStarMini.png"
--	local drakUrl = "images/newGui1/IconStarMiniBg.png"
--	ComponentUtils:renderStar(self.stars, data.heroStar, starUrl, drakUrl, config.starmax)
	-- ComponentUtils:adjustStarPos(163, self.stars, config.starmax)
end


--这里有滑动切换武将的功能
--用curType区分是武将府跳进这个模块还是从培养模块跳转过来的。
--用self.alldata记录可以切换的所有武将
function HeroLvUpPanel:initView(param)

	if not param then
		self.allData = {}
		local index = 1
		local curType = self.view:getCurTrainType()
		local allHeroData = clone(self.proxy:getAllHeroInfo())
		if curType == 1 then
			for i=1,6 do
				local heroData = self.proxy:getHeroInfoWithPos(i)
				if heroData ~= nil then
					if heroData.heroDbId == self.curHeroId then
						self.curIndex = index
					end
					index = index + 1
					table.insert(self.allData, heroData)
				end
			end
		else
			for k,v in pairs(allHeroData) do
				if not self.proxy:isExpCar(v) and v.heroPosition == 0 then
					local heroConfig = ConfigDataManager:getConfigById(ConfigData.HeroConfig, v.heroId)
					rawset(v, "color", heroConfig.color)
					table.insert(self.allData, v)
				end
			end
			table.sort( self.allData, function(a, b)
	            return a.color > b.color
			end )
			for i=6,1,-1 do
				local heroData = self.proxy:getHeroInfoWithPos(i)
				if heroData ~= nil then
					table.insert(self.allData, 1, heroData)
				end
			end
			for i=1,#self.allData do
				local v = self.allData[i]
				if v.heroDbId == self.curHeroId then
					self.curIndex = index
				end
				index = index + 1
			end
		end
	end

end


--20007推送刷新
function HeroLvUpPanel:lvUpSuccess()
    self._lastTypeId = nil -- 控制最后一个不发消息的关键变量

	self:initView()
	local data = self.proxy:getInfoById(self.curHeroId)
    
    self._hadLevelUp = data.heroLv ~= self.view:readCurData().heroLv -- 本次有没有升级

	self:playMainEffect(self._hadLevelUp) -- 只有升级才播

	self.view:saveCurData(data)

	self:initMainHeroData(data)

    -- 材料选择表
    self:showListCtrl(self._listPanelIndex, true)

    self._hadLevelUp = false -- 重置 状态
end

function HeroLvUpPanel:updateLv()
	self.playing = nil
end

function HeroLvUpPanel:getNextLvExp(data)
	local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)
	local nextLv = data.heroLv + 1 > config.lvmax and config.lvmax or data.heroLv
	local levelConfig = ConfigDataManager:getConfigById(ConfigData.HeroLevelConfig, nextLv)
	local key = self.expKey[config.color]
--    logger:info("当前取的nextLv是："..nextLv)
--    logger:info("当前取的key是："..key)
	local nextLvExp = levelConfig[key]
	return nextLvExp
end
-- 计算经验
function HeroLvUpPanel:getAllExp()
	local exp = 0
	for k,data in pairs(self._chooseData) do
		local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)
		if self.proxy:isExpCar(data) then
			exp = exp + config.eatedExp
		else
			local expKey = {"wexpoffer", "gexpoffer", "bexpoffer", "pexpoffer", "oexpoffer"}
			local levelConfig = ConfigDataManager:getConfigById(ConfigData.HeroLevelConfig, data.heroLv)
			local key = expKey[config.color]
			exp = exp + levelConfig[key]
		end
	end
	return exp
end

function HeroLvUpPanel:renderCardList()
    local cardData = self.proxy:getHeroByType(1) -- cardType == 1
    self:showEmptyTxt(#cardData == 0)

    table.sort(cardData,
    function(item01, item02)

        local config01 = ConfigDataManager:getConfigById(ConfigData.HeroConfig, item01.heroId)
        local color01 = config01.color

        local config02 = ConfigDataManager:getConfigById(ConfigData.HeroConfig, item02.heroId)
        local color02 = config02.color
        if color01 == color02 then
            return item01.heroId < item02.heroId 
        else
            -- 卡片品质从高到低
            return color01 > color02
        end
    end)

    self:renderListView(self._cardListView, cardData, self, self.renderCardItem, 10)
end

function HeroLvUpPanel:renderHeroList()
    local heroData = self.proxy:getHeroByType(0) -- heroType == 0
    
    local newHeroData = {}
    -- 不能包括已上阵和当前显示英雄
    for key, value in pairs(heroData) do  -- 遍历删除自身元素会造成中断，方法，删除时遍历value
        if value.heroPosition == 0 and value.heroDbId ~= self.curHeroId then
            table.insert(newHeroData, value)
        end
    end
    self:showEmptyTxt(#newHeroData == 0)

    table.sort(newHeroData,
    function(item01, item02)

        local config01 = ConfigDataManager:getConfigById(ConfigData.HeroConfig, item01.heroId)
        local color01 = config01.color

        local config02 = ConfigDataManager:getConfigById(ConfigData.HeroConfig, item02.heroId)
        local color02 = config02.color
        if color01 == color02 then
            return item01.heroId < item02.heroId 
        else
            -- 武将品质从低到高
            return color01 < color02
        end
    end)

    self:renderListView(self._heroListView, newHeroData, self, self.renderCardItem, 10)
end

function HeroLvUpPanel:showEmptyTxt(isVisible)
    local listPanel = self._posListPanel:getChildByName("listPanel")
    local emptyTxt  = listPanel:getChildByName("emptyTxt")
    -- local emptyImg  = listPanel:getChildByName("emptyImg")
    emptyTxt:setVisible(isVisible)
    -- emptyImg:setVisible(isVisible)
end

-- 卡片渲染
function HeroLvUpPanel:renderCardItem(itemPanel, itemData, index)
    -- local itemBtn = itemPanel:getChildByName("itemBtn") 
    -- local iconImg = itemBtn:getChildByName("iconImg")
    local useBtn  = itemPanel:getChildByName("useBtn")
    local iconImg = itemPanel:getChildByName("iconImg")
    -- local useBtn  = itemPanel:getChildByName("useBtn")
    -- local pnlBtn  = itemPanel:getChildByName("pnlBtn")
    
    local iconData = {}
    iconData.num = itemData.num
    iconData.typeid = itemData.heroId
    iconData.power = GamePowerConfig.Hero
    iconData.heroDbId = itemData.heroDbId


    if iconImg.uiIcon == nil then
        local icon = UIIcon.new(iconImg, iconData, true, self, nil, true)
		iconImg.uiIcon = icon
        iconImg.iconData = iconData -- 图标数量减少效果
    else
        iconImg.uiIcon:updateData(iconData)
        iconImg.iconData = iconData -- 图标数量减少效果
    end

    -- 按钮点击
    useBtn.itemData = itemData
    -- pnlBtn.itemData = itemData
    self:setUseBtnEvent(useBtn)
    -- self:setUseBtnEvent(pnlBtn)
end


function HeroLvUpPanel:setUseBtnEvent(useBtn)
    local itemData = useBtn.itemData
    local hadNum   = useBtn.itemData.num -- 拥有个数

    -- useBtn.itemData
    useBtn.index = 0  -- 增加数量
    useBtn.eachExp = self.proxy:getEachEatenExp(itemData) -- 每个加的经验

    -- 点击函数
    local isTouching = false -- 是否在按
    -- 响应回调
    --1.当玩家点击持续5秒后，每次吞噬数量升为5本
    --2.当玩家点击持续10秒后，每次吞噬数量变为10本
    local function addNum()
        if hadNum > useBtn.index then
            local diffTime = os.time() - self._beginTime
            if diffTime <= 3 then                     -- 当玩家点击少于3秒，每次吞噬数量1本
                useBtn.index = useBtn.index + 1
            elseif diffTime >3 and diffTime <= 6 then -- 当玩家点击持续3秒后，每次吞噬数量从1本升为5本
                useBtn.index = useBtn.index + 5
            else                                      -- 当玩家点击持续6秒后，每次吞噬数量从1本变为10本
                useBtn.index = useBtn.index + 10
            end

            -- 溢出设置为最大值
            if hadNum < useBtn.index then
                useBtn.index = hadNum
            end

            self:addingExpValue(useBtn) -- 当前预览经验
            self:addingIconUpdate(useBtn) -- 减少效果
            self:addingMaxLv(useBtn) -- 判断是否到满级
        elseif hadNum == useBtn.index then
            logger:info("已满")
        end
        logger:info("点击增加："..useBtn.index)
    end

    -- 执行动作
    local function addNumAction()
        if isTouching then -- 在按
            addNum() -- 响应回调
            
            -- 判断是否遇到升级，如果升级就触发发送事件
            if self:isAddingLvUp() then
                -- 重置，并发送
                self:useReq(useBtn)
                useBtn.index = 0 -- 重置为0
                return
            end

            local delayTime = cc.DelayTime:create(self.addingDelayTime)
            local callFun   = cc.CallFunc:create(addNumAction)
            useBtn:runAction( cc.Sequence:create(delayTime, callFun))
        else
            if useBtn.index > 0 then -- userBtn.index == 0 表示被自动升级逻辑重置了
                -- 重置，并发送
                self:useReq(useBtn)
                useBtn.index = 0 -- 重置为0
            end
        end
    end

    --点击英雄头像
    local function onUseTouchHeroBtn(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            if self:isHeroMaxLevel() then -- 已满级直接做中断
                self:showSysMessage(self:getTextWord(290074))
                return 
            end

            if self:isCanLevelUp(self.view:readCurData().heroLv) == false then
                self:showSysMessage(self:getTextWord(290082)) -- "武将等级已经达到上限，请升级主公等级"
                return 
            end

            self._beginTime = os.time()
            isTouching = true
            sender:stopAllActions()
            addNumAction()
        elseif eventType == ccui.TouchEventType.moved then

        elseif eventType == ccui.TouchEventType.ended then -- 在按钮上放开，有屏蔽自动执行
            isTouching = false
            sender:stopAllActions()
            addNumAction()
        elseif  eventType == ccui.TouchEventType.canceled then -- 非按钮放开，，有屏蔽自动执行
            isTouching = false
            sender:stopAllActions()
            addNumAction()
        end
    end


    -- 点击经验书事件
    local function onUseJingYanShuBtn(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            if self:isHeroMaxLevel() then -- 已满级直接做中断
                self:showSysMessage(self:getTextWord(290074))
                return 
            end

            if self:isCanLevelUp(self.view:readCurData().heroLv) == false then
                self:showSysMessage(self:getTextWord(290082)) -- "武将等级已经达到上限，请升级主公等级"
                return 
            end

            self._beginTime = os.time()
            isTouching = true
            sender:stopAllActions()
            addNumAction()
        elseif eventType == ccui.TouchEventType.moved then

        elseif eventType == ccui.TouchEventType.ended then -- 在按钮上放开，有屏蔽自动执行
            isTouching = false
            sender:stopAllActions()
            addNumAction()
        elseif  eventType == ccui.TouchEventType.canceled then -- 非按钮放开，，有屏蔽自动执行
            isTouching = false
            sender:stopAllActions()
            addNumAction()
        end
    end

    if self._listPanelIndex == HeroLvUpPanel.ListPanel.JingYanShuIdx then
        useBtn:addTouchEventListener(onUseJingYanShuBtn)
    elseif self._listPanelIndex == HeroLvUpPanel.ListPanel.YingXiongIdx then
        useBtn:addTouchEventListener(onUseTouchHeroBtn)
    end
end

-- 发送消息
function HeroLvUpPanel:useReq(useBtn)
    if useBtn.index == 0 then -- 如果是0中断
        return
    end
    logger:info("一共使用了："..useBtn.index)
    
    local useNum = useBtn.index -- 用的数量， 不超过拥有上限

    local data = {}
    data.heroId = self.curHeroId
    data.upType = 1
    data.useInfo = {}

    local info = {}
    info.heroId = useBtn.itemData.heroDbId
    info.num    = useNum
    table.insert(data.useInfo, info)
    
    local function reqUse()
        -- 防止：单个材料位数量剩余最后一个时，快速点击使用，会出现提示有不存在武将
        if useBtn.itemData.heroId == self._lastTypeId and self._lastRemainNum == 1 then
            self._lastTypeId = nil
            return
        end
        self._lastTypeId = useBtn.itemData.heroId
        self._lastRemainNum    = self.proxy:getHeroNumById(self._lastTypeId)
        
        self.proxy:onTriggerNet300001Req(data)
        logger:info("发送的useNum == ::".. useNum)
    end

    local function cancleUse()
        self:setAddingHeroAttr(0, self.curHeroId)
    end

    -- 材料书直接用、英雄做提示
    if self._listPanelIndex == HeroLvUpPanel.ListPanel.JingYanShuIdx then
        reqUse()
    elseif self._listPanelIndex == HeroLvUpPanel.ListPanel.YingXiongIdx then
        local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, useBtn.itemData.heroId)
        local color  = config.color
        if color > 2 then
            local content = self:getTextWord(290072)
            self:showMessageBox(content, reqUse, cancleUse)
        else
            reqUse()
        end
    end

end

-- 当前加的预览经验
function HeroLvUpPanel:addingExpValue(useBtn)

    local addingExp = useBtn.index *useBtn.eachExp
    
    self:setAddingHeroAttr(addingExp, self.curHeroId)
    
    self:addingMainEffect()
end

-- 图标数量减少效果
function HeroLvUpPanel:addingIconUpdate(useBtn)
    local btnParent = useBtn:getParent()
    local iconImg = btnParent:getChildByName("iconImg")
    if iconImg.uiIcon then
        local iconData = {}
        iconData.num = iconImg.iconData.num - useBtn.index
        iconData.typeid = iconImg.iconData.typeid
        iconData.power = GamePowerConfig.Hero
        iconImg.uiIcon:updateData(iconData)
    end
end

-- 判断是否到满级
function HeroLvUpPanel:addingMaxLv(useBtn)
    

end

-- 经验加成和属性表现
function HeroLvUpPanel:setAddingHeroAttr(addingExp, curHeroId)
    logger:info("当前增加经验："..addingExp)
    local data = self.proxy:getInfoById(curHeroId)
	local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)
	local exp = addingExp
	local heroAttrInfos, canUpLevel = self.proxy:getHeroLvUpAttr(data, config.lvmax <= data.heroLv, exp)
	--local lvStr = string.format("%d/%d", data.heroLv, config.lvmax)
	local function getAction()
		local FadeOut = cc.FadeOut:create(self.actionTime)
		local FadeIn = cc.FadeIn:create(self.actionTime)
		local seq = cc.Sequence:create(FadeOut, FadeIn)
		local action = cc.RepeatForever:create(seq)
		return action
	end

    local nextLvExp = self:getNextLvExp(data)
	local expStr = string.format("%d/%d", (data.heroExp + exp), nextLvExp)
	self.expLab:setString(expStr)
	self.effBar:setVisible(true)
	if canUpLevel > 0 then
		self.expBar:setPercent(100)
		self.expBar:runAction(getAction())	
		self.effBar:stopAllActions()
		self.effBar:setOpacity(255)
		self.effBar:setVisible(false)	
		--lvStr = lvStr .. string.format("(+%d)", canUpLevel)
        self.lvDiffLab:setVisible(true)
	else
		local nowPencent = (data.heroExp + exp)/nextLvExp*100 > 100 and 100 or (data.heroExp + exp)/nextLvExp*100
		self.effBar:setPercent(nowPencent)
		if exp == 0  then
			self.expBar:stopAllActions()
			self.expBar:setOpacity(255)
			self.expBar:setVisible(true)
			self.expBar:setPercent(nowPencent)

			self.effBar:stopAllActions()
			self.effBar:setOpacity(255)
			self.effBar:setVisible(false)
		else
			self.effBar:runAction(getAction())
		end

        self.lvDiffLab:setVisible(false)
	end
	
	self.lvLab:setString(data.heroLv)
    self.lvMaxLab:setString("/"..config.lvmax)
    self.lvDiffLab:setString( string.format("(+%d)", canUpLevel))
    NodeUtils:alignNodeL2R(self.lvLab, self.lvMaxLab)
    NodeUtils:alignNodeL2R(self.lvMaxLab, self.lvDiffLab, 5)

    self:playSetAttr(heroAttrInfos, self._hadLevelUp)

    local fightVal = 0

    local heroProxy = self:getProxy(GameProxys.Hero)
    local info = heroProxy:getInfoById(self.curHeroId)
    if info and info.heroPosition then
        -- local fightVal = heroProxy:getHeroFight(info.heroPosition,{})--self.curHeroId
        fightVal = heroProxy:calculateHeroFight(info,{})--self.curHeroId
--        if self.labZhanLi then
--            self.labZhanLi:setString(string.format("%d",fightVal))
--        end
    end
    --TextureManager:updateImageView(self.imgGuo, string.format("images/heroBgIcon/TxtGuo%d.png",config.countryIcon)) 

    local cardData = { }
    cardData.heroId = data.heroId
    cardData.starNum = data.heroStar
    cardData.fightting = fightVal
    self._uiHeroCard:updateData(cardData)
end

function HeroLvUpPanel:playSetAttr(heroAttrInfos, hadLevelUp)
    local count = #heroAttrInfos
    local k = 1
    local function playing()
        local v = heroAttrInfos[k]
        local addLab = self.attrInfos[k]:getChildByName("addLab")
		local iconImg = self.attrInfos[k]:getChildByName("iconImg")
		-- iconImg:setScale(0.85)
        local otherLab = self.attrInfos[k]:getChildByName("otherLab")
		local descLab = self.attrInfos[k]:getChildByName("descLab")
		descLab:setString(v.text)
		otherLab:setVisible(v.add ~= 0)

        local info = self.proxy:getInfoById(self.curHeroId)
        if info and info.heroPosition then
            --self.labXianShou:setString(self.proxy:getFirstnum(info.heroPosition))--使用这个有缺陷,如果,是从将军府培养跳转到武将训练模块,有一些武将并没有占坑位
            self.labXianShou:setString(self.proxy:getFirstnumFromData(info))
            self.labDaiBing:setString(self.proxy:getHeroCommandNumWithData(info))
        end

        local addStr = ""
		local baseStr = ""
		if k ~= 1 and k ~= 4 then
			local addNum = StringUtils:getPreciseDecimal((v.add/100), 1)
			addStr = "+"..addNum.."%"
			baseStr = (v.base/100).."%"
		else
			addStr = "+".. (math.ceil(v.add))
			baseStr = math.ceil(v.base)
		end
		otherLab:setString(addStr)
		addLab:setString(baseStr)
		local url = self.proxy:getIconPath(k)
		-- TextureManager:updateImageView(iconImg, url)
        NodeUtils:alignNodeL2R(addLab,otherLab)

        
        k = k + 1
        if k <= count then
            if hadLevelUp then
                TimerManager:addOnce(100, playing, self)
            else
                playing()
            end
        else
            NodeUtils:removeSwallow() -- 去除
        end
    end

    if hadLevelUp then
        NodeUtils:addSwallow()
        TimerManager:addOnce(500, playing, self)
    else
        playing()
    end
end



-- 播放升级成功后的特效
function HeroLvUpPanel:playMainEffect(isCanPlay02)
    local bgImg = self:getChildByName("middlePanel")
    bgImg:stopAllActions()
    
    local function play01()
        if isCanPlay02 then -- 升级才播放
            local pnlHead = self:getChildByName("middlePanel/pnlHead")
            local mainEffect = self:createUICCBLayer("rgb-wjsj-shengji", bgImg, nil, function()
            end, true)
            -- local x1, y1 = self.heroImg:getPosition()
            -- mainEffect:setPosition(x1, y1 + 120)
            local x1, y1 = pnlHead:getPosition()
            local size = pnlHead:getContentSize()
            mainEffect:setPosition(x1+size.width/2, y1+size.height/2)
            mainEffect:setLocalZOrder(100)
        end
    end

    local function addFontEff(node)
        local eff = UICCBLayer.new("rgb-wjsj-zi" ,node, nil, nil, true)
        --eff:setPosition(eff:getPositionX(), node:getPositionY())
        eff:setPosition(node:getPositionX() - 50, node:getPositionY() + 10)
    end

    -- 有升级才播放
    local index = 1
    local function play02()
        if isCanPlay02 then
            addFontEff(self.attrInfos[index]:getChildByName("addLab"))
            index = index + 1
            if index <= #self.attrInfos then
                TimerManager:addOnce(70, play02, self)
            end
        end
    end

    local call01 = cc.CallFunc:create(play01)
    local call02 = cc.CallFunc:create(play02)
    local playDelayAction = cc.DelayTime:create(0.5)
    local playAction = cc.Sequence:create(call01, playDelayAction, call02)
    bgImg:runAction(playAction)
end

-- 点击加闪
function HeroLvUpPanel:addingMainEffect()
    ---[[
    -- local bgImg = self:getChildByName("middlePanel")

    local mainEffect = self:createUICCBLayer("rgb-wjsj-jingyan", self._imgHeroCard, nil, nil, true)

    local x1, y1 = mainEffect:getPosition()
    local size = self._imgHeroCard:getContentSize()
    mainEffect:setPosition(x1+size.width/2, y1 + size.height/2)
    mainEffect:setLocalZOrder(10)
    --]]
end

-- 两边的特效
function HeroLvUpPanel:setEdgeEff() 
    local listPanel = self._posListPanel:getChildByName("listPanel")
    local leftImg = listPanel:getChildByName("leftImg")
    local rightImg = listPanel:getChildByName("rightImg")
    self.leftEct = UICCBLayer.new("rgb-fanye", leftImg)
    self.rightEct = UICCBLayer.new("rgb-fanye", rightImg)
end

-- 加到是否升级
function HeroLvUpPanel:isAddingLvUp()
    local state = false


    if self.lvDiffLab:isVisible() then
        state = true
    end

    return state
end

-- 是否到达满级
function HeroLvUpPanel:isHeroMaxLevel()
    return self.maxLvImg:isVisible()
end


-- 是否可以继续升级
function HeroLvUpPanel:isCanLevelUp(heroLevel)
    local state = true
    local level = self.proxy:getHeroCanImproveLevel()
    if level == nil then
        return state
    end

    if level ~= nil then
        if level <= heroLevel then
            state = false
        end
    end
    return state
end

-- 满级后进度条的特殊显示
function HeroLvUpPanel:setMaxLvBarShow()
    self.expBar:setPercent(0)
    self.expLab:setString("0/0")
    self.expLab:setVisible(true)
end

