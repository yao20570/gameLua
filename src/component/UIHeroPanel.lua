--
-- Author: zlf
-- Date: 2016年8月29日14:53:29
-- 通用英雄选择界面

--@params  parent 要传有getProxy接口的对象过来
--@params  data 参照Common.proto的heroInfo数据结构
--@params type 说明在下面
--@params otherInfo 材料升级的时候主英雄升级所需的经验值  可传nil
--@params panel 界面自适应的外部参数(node)
--@params panel 界面自适应的外部参数(数字)
--@params canResolve 是否能分解   herohalltrainpanel在显示这个界面的时候是可以分解英雄的  可传nil
--[[
	因为listview要根据有没有标签  有没有底部面板进行尺寸调整
	所以创建完这个通用面板之后自行调用getListView() 和 getBottomPanel()然后对listview进行调整
]]

UIHeroPanel = class("UIHeroPanel", BasicComponent)

--培养界面
UIHeroPanel.Train = 1
--上阵
UIHeroPanel.Battle = 2
--材料
UIHeroPanel.Material = 3

UIHeroPanel.BTN_A_NORMAL = "images/newGui1/BtnMiniGreed1.png"
UIHeroPanel.BTN_A_PRESSE = "images/newGui1/BtnMiniGreed2.png"
UIHeroPanel.BTN_B_NORMAL = "images/newGui1/BtnMiniRed1.png"
UIHeroPanel.BTN_B_PRESSE = "images/newGui1/BtnMiniRed2.png"

function UIHeroPanel:ctor(parent, data, type, otherInfo, panel, canResolve)
	UIHeroPanel.super.ctor(self)

    local function doLayout(uiSkin)
    	self:doLayout(uiSkin)
    end

	local uiSkin = UISkin.new("UIHeroPanel", nil, doLayout)
    uiSkin:setParent(parent)
    self._type = type
    self._panel = panel
    self._parent = parent
    self._uiSkin = uiSkin
    self._canResolve = canResolve

    self.heroProxy = parent:getProxy(GameProxys.Hero)

    local listView = self:getChildByName("topPanel/InfoListView")
    listView:setLocalZOrder(10)

    local bottomPanel = self:getChildByName("bottomPanel")
    bottomPanel:setLocalZOrder(10)
    
    self.moduleName = {[self.Train] = ModuleName.HeroTrainModule}

    self.heroProxy:addEventListener(AppEvent.PROXY_HERO_UPDATE_INFO, self, self.updateData)

    self:updateView(data, type, otherInfo)
end

function UIHeroPanel:initPanel()
end

function UIHeroPanel:doLayout(uiSkin)
	-- print("panel===",self._panel)
	self._uiSkin = uiSkin
	local listView = self:getListView()
	--local bgImg = self:getBgImg()
	local downPanel = self._type == UIHeroPanel.Battle and GlobalConfig.downHeight or self:getBottomPanel()
	--兼容性处理,panel的适配位置不对了
	if type(self._panel) == type(self._uiSkin) then
		NodeUtils:adaptiveListView(listView, downPanel, self._panel)
	elseif type(self._panel) == type(0) then
    	--NodeUtils:adaptiveTopPanelAndListView(listView, nil, downPanel, self._panel)
		 NodeUtils:adaptiveListView(listView, downPanel, self._panel)
	else
    	local tabsPanel = self._parent:getTabsPanel()
    	NodeUtils:adaptiveDownPanel(self:getBottomPanel(),nil,0)
		NodeUtils:adaptiveListView(listView, self:getBottomPanel(), tabsPanel)
	end
	--NodeUtils:adaptivePanelBg(bgImg, 5, GlobalConfig.topHeight)
end

function UIHeroPanel:getChildByName(name)
	return self._uiSkin:getChildByName(name)
end

function UIHeroPanel:getRootNode()
	return self._uiSkin
end

function UIHeroPanel:updateView(data, viewType, otherInfo)
	self._uiSkin:setVisible(true)
	self.otherInfo = otherInfo
	self._chooseData = {}
	self._curChooseNum = 0

	viewType = viewType or self.Train
	self._viewType = viewType
	local bottomPanel = self:getChildByName("bottomPanel")
	local listView = self:getChildByName("topPanel/InfoListView")
	bottomPanel:setVisible(viewType == self.Material or viewType == self.Train)
	--隐藏部分ui
	for k,v in pairs(bottomPanel:getChildren()) do
		local name = v:getName()
		if name == "zrBtn" then
			v:setVisible(viewType == self.Train)
		elseif name == "Image_26" then
			v:setVisible(true)
		else
			v:setVisible(viewType == self.Material )
		end
	end

	-- local sureBtn = bottomPanel:getChildByName("sureBtn")
	local zrBtn = bottomPanel:getChildByName("zrBtn")
	self._haveHeroNum = zrBtn:getChildByName("haveNum")
	self._maxHeroNum = zrBtn:getChildByName("allNum")
	self._maxHeroNum:setString("/"..GameConfig.Hero.MaxNum)
	zrBtn.moduleName = ModuleName.HeroModule
	
	-- ComponentUtils:addTouchEventListener(sureBtn, self.chooseHeroOver, nil, self)
	ComponentUtils:addTouchEventListener(zrBtn, self.onOpenModule, nil, self)
	if viewType == self.Material  then
		--获得经验
		-- local expLab = bottomPanel:getChildByName("expLab")
		-- expLab:setString(0)
		--升级所需
		-- local lvLab = bottomPanel:getChildByName("lvLab")
		-- lvLab:setString(otherInfo)
	end
	local cloneData = {}
	local allExps = {}

	local function addExpData(value, param)
		local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, value.heroId)
		rawset(value, "color", config.color)
		table.insert(param, value)
	end


	--isInsertOtherData 最前面插入上阵英雄？
	local isInsertOtherData = viewType ~= self.Material 
	--上阵和培养要去掉经验卡
	if viewType ~= self.Material then
		for k,v in pairs(data) do
			if self.heroProxy:isExpCar(v) then
				addExpData(v, allExps)
				data[k] = nil
			elseif v.heroPosition == 0 then
				addExpData(v, cloneData)
			end
		end
	else
		--材料要去掉上阵的英雄
		for i=1,6 do
			local heroData = self.heroProxy:getHeroInfoWithPos(i)
			if heroData ~= nil then
				data[heroData.heroDbId] = nil
			end
		end
		--经验卡先不放进去，下面在放进去，因为要插在最前面
		for k,v in pairs(data) do
			if self.heroProxy:isExpCar(v) then
				addExpData(v, allExps)
			else
				addExpData(v, cloneData)
			end
		end
	end
	table.sort( cloneData, function(a, b)
		return a.color > b.color
	end)
	--未上阵英雄数量
	local 
	haveHeorNum = table.size(cloneData)
	if isInsertOtherData then
		for i=6, 1, -1 do
			local heroData = self.heroProxy:getHeroInfoWithPos(i)
			if heroData ~= nil then
				table.insert(cloneData, 1, heroData)
			end
		end
	end
	--材料前面插入经验卡
	if viewType == self.Material or viewType == self.Train then
		--武经叠加逻辑，暂时屏蔽
		-- local expData = {} --记录经验书的数量
		-- local expDataProxy = {} --去重过的经验书
		-- for k,v in pairs(allExps) do
		-- 	if expData[v.heroId] == nil then
		-- 		expData[v.heroId] = 1
		-- 		table.insert(expDataProxy, v)
		-- 	else
		-- 		expData[v.heroId] = expData[v.heroId] + 1
		-- 	end
		-- end

		-- for k,v in pairs(expDataProxy) do
		-- 	--设置经验书的数量
		-- 	rawset(expDataProxy[k], "expNum", expData[v.heroId])
		-- end
		-- --重新复制allExps
		-- allExps = expDataProxy

		table.sort(allExps, function(a, b)
			return a.color > b.color
		end)
		for i=#allExps, 1, -1 do
			if viewType == self.Train then
				table.insert(cloneData,allExps[i])
			else
				table.insert(cloneData, 1, allExps[i])
			end
		end
	end
	--未上阵英雄和经书数
	haveHeorNum = haveHeorNum + table.size(allExps)
	self._haveHeroNum:setString(haveHeorNum)
	self._maxHeroNum:setPositionX(self._haveHeroNum:getPositionX()+self._haveHeroNum:getContentSize().width)
	self:renderListView(listView, cloneData, self, self.renderItem,nil,nil,GlobalConfig.listViewRowSpace)
end

function UIHeroPanel:renderItem(item, data, index)
	local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)
	local LvLab = item:getChildByName("LvLab")
	LvLab:setString(" Lv."..data.heroLv)
    
    logger:info(config.name.. "的数量："..data.num )

	-- local Image_4 = item:getChildByName("Image_4")
	local iconImg = item:getChildByName("iconImg")
	local icon = iconImg.uiIcon
	local iconData = {}
	iconData.num = data.num
	iconData.typeid = data.heroId
	iconData.power = GamePowerConfig.Hero
	iconData.heroDbId = data.heroDbId
	-- self._parent._enableTouch = true
	if icon == nil then
		icon = UIIcon.new(iconImg, iconData, false, self._parent)
		iconImg.uiIcon = icon
	else
		icon:updateData(iconData)
	end
	local isExpCar = self.heroProxy:isExpCar(data) -- 是否为经验卡
	icon:setTouchEnabled(isExpCar)


	local nameLab = item:getChildByName("nameLab")
	nameLab:setString(config.name)

	nameLab:setVisible(not isExpCar)
	LvLab:setVisible(not isExpCar)
	if not isExpCar then
		LvLab:setPositionX(nameLab:getPositionX() + nameLab:getContentSize().width)
	end

	local expName = item:getChildByName("expName")
	expName:setVisible(isExpCar)

	local pnlExpNum = item:getChildByName("pnlExpNum")
	pnlExpNum:setVisible(isExpCar)

	if isExpCar then
		local expNum = data.num -- 每条的数量，message HeroInfo{//英雄信息
        -- expName:setString(config.name .. " *" .. expNum)
        expName:setString(config.name)
        pnlExpNum:getChildByName("labExpBookNumVal"):setString(expNum)
	end

	
	


	local starPanel = item:getChildByName("starPanel")
	starPanel:setTouchEnabled(false)
	local stars = {}
	for i=1,5 do
		stars[i] = starPanel:getChildByName("starImg"..i)
	end
	--otherPanel 含复选框  经验文本
	local otherPanel = item:getChildByName("Panel_35")
	otherPanel:setVisible(self._viewType == self.Material)
	local expNumLab = otherPanel:getChildByName("expNumLab")
	if self._viewType == self.Material then
		local exp = self:getHeroExp(data)
		expNumLab:setString(exp)
	end
	local chooseCB = otherPanel:getChildByName("chooseCB")
	chooseCB:setSelectedState(false)
	chooseCB.data = data
	ComponentUtils:addTouchEventListener(chooseCB, self.chooseMaterial, nil, self)

	local starUrl = "images/newGui1/IconStarMini.png"
	local drakUrl = "images/newGui1/IconStarMiniBg.png"
	ComponentUtils:renderStar(stars, data.heroStar, starUrl, drakUrl, config.starmax)
	local color = ColorUtils:getColorByQuality(config.color) or cc.c3b(255,255,255)
	nameLab:setColor(color)
	expName:setColor(color)
	local keys = {"lead", "brave", "sta"}
	local heroAttPanel = item:getChildByName("heroAttPanel")
	for i=1,3 do
		local lab = heroAttPanel:getChildByName("lab"..i)
		local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)
		lab:setString(config[keys[i]])
		
		-- lab:setColor(color)
	end
	------------------------
	local infoLab = item:getChildByName("infoLab")
	if infoLab.richLabel == nil then
        infoLab.richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        infoLab.richLabel:setPosition(cc.p(infoLab:getPosition()))
        infoLab:getParent():addChild(infoLab.richLabel)
    end

    heroAttPanel:setVisible(not isExpCar)
	if isExpCar then
		local heroInfo = ConfigDataManager:getConfigById(ConfigData.HeroShowConfig, data.heroId)
		infoLab.richLabel:setString(heroInfo.getinfo)
	else
		infoLab.richLabel:setString("")
	end
	--------------------

	local stateImg = item:getChildByName("stateImg")
	local url = data.heroPosition == 0 and "images/component/notBattle.png" or string.format("images/component/hero_%d.png", data.heroPosition)
	TextureManager:updateImageView(stateImg, url)
	stateImg:setVisible(self._viewType ~= self.Material and not isExpCar)


	local trainBtn = item:getChildByName("trainBtn")
	trainBtn:setVisible(self._viewType ~= self.Material)
	local btnText
	if isExpCar then 
		btnText = TextWords:getTextWord(290066)
	    trainBtn:setVisible(false) -- #4243 经验卡改为不能出售
    else
		btnText = TextWords:getTextWord(290003)
        trainBtn:setVisible(true)
	end
    -- trainBtn:setTitleColor(ColorUtils.wordWhiteColor) -- 纯白
    trainBtn:setTitleColor(ColorUtils:color16ToC3b(ColorUtils.commonColor.White))
    -- 还原材质绿色
    TextureManager:updateButtonNormal(trainBtn, UIHeroPanel.BTN_A_NORMAL)
    TextureManager:updateButtonPressed(trainBtn,UIHeroPanel.BTN_A_PRESSE)
	if self._viewType == self.Battle then
		if data.heroPosition == 0 then
			btnText = TextWords:getTextWord(290004) -- 上阵
		else
			btnText = TextWords:getTextWord(290005) -- 卸下
            -- 红色按钮
            TextureManager:updateButtonNormal(trainBtn,  UIHeroPanel.BTN_B_NORMAL)
            TextureManager:updateButtonPressed(trainBtn, UIHeroPanel.BTN_B_PRESSE)
		end
	end
	trainBtn:setTitleText(btnText)

    self._parent["trainBtn" .. (index + 1)] = trainBtn --引导用的

    item.data = data
    
	trainBtn.data = data
	ComponentUtils:addTouchEventListener(trainBtn, self.btnTouch, nil, self)
	ComponentUtils:addTouchEventListener(item, self.itemTouch, nil, self)
end

function UIHeroPanel:itemTouch(sender)
	--UIHeroInfoPanel属于关闭立即释放的
	local isExpCar = self.heroProxy:isExpCar(sender.data)
	if isExpCar then
		return
	end

	local heroInfoPanel = UIHeroInfoPanel.new(self._parent, sender.data, nil, true, self._canResolve)
	heroInfoPanel:setLocalZOrder(120)
end

--item按钮回调，可能要根据type不同来进行判断
function UIHeroPanel:btnTouch(sender)
	local data = sender.data
	if self._viewType == self.Train then

		if self.heroProxy:isExpCar(data) then
			local panel = self._parent:getPanel(HeroHallSalePanel.NAME)
			panel:show(sender.data)
		else
			local name = self.moduleName[self._viewType] or ModuleName.HeroTrainModule
			local openData = {}
			openData.moduleName = name
			openData.extraMsg = {}
			openData.extraMsg.TrainType = 2
			openData.extraMsg.heroData = data
			self.heroProxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, openData)
		end 

	else

		if data.heroPosition ~= 0 then
			--卸下，检测英雄数量是否已满
			local heroProxy = self._parent:getProxy(GameProxys.Hero)
			local heroNum = heroProxy:getAllHeroNum()
			if heroNum >= GameConfig.Hero.MaxNum then 
				self.heroProxy:showSysMessage(TextWords:getTextWord(290064))
				return
			end
		end

		local sendData = {}
		local pos = data.heroPosition == 0 and self._parent:getCurPos() or 0
		sendData.position = pos
		sendData.heroId = data.heroDbId
		
		self.heroProxy:onTriggerNet300000Req(sendData)
	end
end

function UIHeroPanel:chooseMaterial(sender)
	local state = sender:getSelectedState()
	local maxNum = self.heroProxy:getChooseMaxNum()
	local ID = sender.data.heroDbId
	if state then
		self._curChooseNum = self._curChooseNum - 1 > 0 and self._curChooseNum - 1 or 0
		self._chooseData[ID] = nil
	else
		if sender.data.heroPosition ~= 0 then
			sender:setSelectedState(true)
			self.heroProxy:showSysMessage(TextWords:getTextWord(290024))
			return
		end
		if self._curChooseNum >= maxNum then
			sender:setSelectedState(true)
			self.heroProxy:showSysMessage(TextWords:getTextWord(290006))
			return
		end
		self._chooseData[ID] = sender.data
		self._curChooseNum = self._curChooseNum + 1
	end
	self:updateExpData()
end

function UIHeroPanel:destory()

	self.heroProxy:removeEventListener(AppEvent.PROXY_HERO_UPDATE_INFO, self, self.updateData)
	self._uiSkin:finalize()
	UIHeroPanel.super.finalize(self)
end


function UIHeroPanel:chooseHeroOver(sender)
	self.heroProxy:sendNotification(AppEvent.PROXY_HEROLVUP_UPDATE_VIEW, self._chooseData)
	self._uiSkin:setVisible(false)
end

function UIHeroPanel:updateExpData()
	local exp = 0
	for k,v in pairs(self._chooseData) do
		exp = exp + self:getHeroExp(v)
	end
	-- local expLab = self:getChildByName("bottomPanel/expLab")
	-- expLab:setString(exp)
end

--单个英雄的经验值，item和总的都在这里拿
function UIHeroPanel:getHeroExp(data)
	local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)
	local exp = 0
	if self.heroProxy:isExpCar(data) then
		exp = config.eatedExp
	else
		local expKey = {"wexpoffer", "gexpoffer", "bexpoffer", "pexpoffer", "oexpoffer"}
		local levelConfig = ConfigDataManager:getConfigById(ConfigData.HeroLevelConfig, data.heroLv)
		local key = expKey[config.color]
		exp = levelConfig[key]
	end
	return exp
end

function UIHeroPanel:updateData()
	if self._uiSkin:isVisible() then
		local data = clone(self.heroProxy:getAllHeroData())
		self:updateView(data, self._viewType, self.otherInfo)
	end
end

function UIHeroPanel:getListView()
	local listView = self:getChildByName("topPanel/InfoListView")
	return listView
end

function UIHeroPanel:getBottomPanel()
	local bottomPanel = self:getChildByName("bottomPanel")
	return bottomPanel
end


function UIHeroPanel:onOpenModule(sender)
	local name = sender.moduleName

	-- if name == ModuleName.PubModule then
	-- 	local lotteryProxy = self._parent:getProxy(GameProxys.Lottery)
	-- 	if lotteryProxy:isUnlockHeroLottery(true) == false then  --判定战将探宝是否已开放，未开放则飘字提示
	-- 	    return
	-- 	end
	-- end

    --//null  反正这个代码逻辑 叫我再看我是看不懂  太绕了 6677 
    local parentModule = self._parent.view:getParent().module
	local bool = parentModule:isModuleShow(ModuleName.HeroModule)

    if bool == true then
    self._parent.view:dispatchEvent(HeroEvent.HIDE_SELF_EVENT)
	else
	self.heroProxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = name, extraMsg = true})
	end

end