
GeneralAndSoldierPanel = class("GeneralAndSoldierPanel", BasicPanel)
GeneralAndSoldierPanel.NAME = "GeneralAndSoldierPanel"

function GeneralAndSoldierPanel:ctor(view, panelName)
    GeneralAndSoldierPanel.super.ctor(self, view, panelName, true)
    self:setUseNewPanelBg(true)

    self._Proxy = self:getProxy(GameProxys.GeneralAndSoldier)
    self.times = 1
end

function GeneralAndSoldierPanel:finalize()
    GeneralAndSoldierPanel.super.finalize(self)
end

function GeneralAndSoldierPanel:initPanel()
	GeneralAndSoldierPanel.super.initPanel(self)
	self:setTitle(true,"tjqb",true)
    
    self.SOLDIIER_PATH = {"dao_", "qi_", "qiang_", "gong_"}
    self.isDrawSoldier = false 

	local mainPanel = self:getChildByName("mainPanel")
    self:setBgType(ModulePanelBgType.CELESTIALSOLDIER)
	self._helpBtn = self:getChildByName("mainPanel/bgImg/helpBtn")
	self._leftBtn = self:getChildByName("mainPanel/leftPanel/trainBtn")
	self._rightBtn = self:getChildByName("mainPanel/rightPanel/trainBtn")
	self._leftBtn.btnType = 1
	self._rightBtn.btnType = 2
	self._recruitBtn = self:getChildByName("downPanel/recruitBtn")
	self._recruitTenBtn = self:getChildByName("downPanel/recruitTenBtn")
	--self._checkBgImg = self:getChildByName("downPanel/checkBgImg")
	self._soldierImg1 = self:getChildByName("mainPanel/leftPanel/soldierImg")

	for i=1,2 do
		local effNode = self:getChildByName("mainPanel/effectNode"..i)
		--local ccbLayer = UICCBLayer.new("rgb-jones-guanghuan", effNode)
	end
	-- local ccbLayer = UICCBLayer.new("rgb-jones-guanghuan", self._leftBtn)
	-- ccbLayer:setPosition(80,260)
	self._soldierImg2 = self:getChildByName("mainPanel/rightPanel/soldierImg")
	-- ccbLayer = UICCBLayer.new("rgb-jones-guanghuan", self._rightBtn)
	-- ccbLayer:setPosition(58,260)
end

function GeneralAndSoldierPanel:doLayout()
	local mainPanel = self:getChildByName("mainPanel")
	local topPanel = self:topAdaptivePanel()
	NodeUtils:adaptiveUpPanel(mainPanel, topPanel, GlobalConfig.topAdaptive + 20)
	NodeUtils:adaptiveUpPanel(self:getChildByName("downPanel"), mainPanel, 15)
end

function GeneralAndSoldierPanel:registerEvents()
	GeneralAndSoldierPanel.super.registerEvents(self)
	self:addTouchEventListener(self._helpBtn,self.onHelpBtnTouch)
	self:addTouchEventListener(self._leftBtn,self.onTrainBtnTouch)
	self:addTouchEventListener(self._rightBtn,self.onTrainBtnTouch)
	self:addTouchEventListener(self._recruitBtn,self.onRecruitBtnTouch)
	self:addTouchEventListener(self._recruitTenBtn,self.onRecruitTenBtnTouch)
	--self:addTouchEventListener(self._checkBgImg,self.onCheckBgImgTouch)
	self:addTouchEventListener(self._soldierImg2,self.onSoldierImgTouch)
	self:addTouchEventListener(self._soldierImg1,self.onSoldierImgTouch)
end

function GeneralAndSoldierPanel:onClosePanelHandler()
	self:dispatchEvent(GeneralAndSoldierEvent.HIDE_SELF_EVENT)
end

function GeneralAndSoldierPanel:onShowHandler()
	--self:_showReset()
	self:updateThisPanel(0,0)
end

--function GeneralAndSoldierPanel:_showReset()
--	self._Proxy:updateCurActivityData()
--	self.times = 1
--	local checkImg = self:getChildByName("downPanel/checkImg")
--	checkImg:setVisible(false)
--	local price = self._Proxy:getPrice()
--	local goldValueLab = self:getChildByName("downPanel/goldValueLab")
--	goldValueLab:setString(self._Proxy:getIsFree() <= 0 and price or 0)
--	self.cost = price
--end

function GeneralAndSoldierPanel:updateThisPanel()
    self._Proxy:updateCurActivityData()
	local timeLab = self:getChildByName("mainPanel/bgImg/timeLab")
	timeLab:setString(self._Proxy:getLimitTimeStr())
	local descLab = self:getChildByName("mainPanel/bgImg/descLab")
    descLab:setColor(cc.c3b(244,244,244))
	descLab:setString(self:getTextWord(260009))
	local infos = self._Proxy:getSuipianInfos()
	local node = self:getChildByName("mainPanel/leftPanel")
	self:setInfos(infos[1],node)
	node = self:getChildByName("mainPanel/rightPanel")
	self:setInfos(infos[2],node)
	self._infos = infos
	local goldValueLab = self:getChildByName("downPanel/goldValueLab")
	-- goldValueLab:setString(self._Proxy:getIsFree() <= 0 and self.cost or 0)
	if self.times == 1 and self._Proxy:getIsFree() > 0 then
		goldValueLab:setString(0)
	else
		goldValueLab:setString(self.cost)
	end

	self:setBtn()
end

function GeneralAndSoldierPanel:setBtn()
    self.isDrawSoldier = false 
	if self._Proxy:getIsFree() > 0 then
        TextureManager:updateButtonNormal(self._recruitBtn, "images/newGui1/BtnMaxGreen1.png")
        TextureManager:updateButtonPressed(self._recruitBtn, "images/newGui1/BtnMaxGreen2.png")
		self._recruitBtn:setTitleText(TextWords:getTextWord(1876))
		-- self._recruitBtn:setTitleText("")
	else
        TextureManager:updateButtonNormal(self._recruitBtn, "images/newGui1/BtnMaxYellow1.png")
        TextureManager:updateButtonPressed(self._recruitBtn, "images/newGui1/BtnMaxYellow2.png")
		self._recruitBtn:setTitleText("")
	end

    local lab1 = self._recruitBtn:getChildByName("lab1")
    local lab2 = self._recruitBtn:getChildByName("lab2")
    if self._Proxy:getIsFree() > 0 then
	    lab1:setVisible(false)
	    lab2:setVisible(false)
	else
		lab1:setVisible(true)
	    lab2:setVisible(true)   	
    end
    
	local str = TextWords:getTextWord(1873)
	lab1:setString(str)
	local str = string.format(TextWords:getTextWord(1875), 1)
    lab2:setString(str)

    local price,tenprice = self._Proxy:getPrice()
    local goldValueLab = self:getChildByName("downPanel/goldValueLab")
	goldValueLab:setString(self._Proxy:getIsFree() <= 0 and price or 0)

    --十连抽
    lab1 = self._recruitTenBtn:getChildByName("lab1")
    lab2 = self._recruitTenBtn:getChildByName("lab2")
    
	local str = TextWords:getTextWord(1877)
	lab1:setString(str)
	local str = string.format(TextWords:getTextWord(1875), 10)
    lab2:setString(str)

    goldValueLab = self:getChildByName("downPanel/goldValueLab_0")
	goldValueLab:setString(tenprice)
end

function GeneralAndSoldierPanel:xunlianAction(type)
	local effect
    local cloneObj = nil
	if type%2 == 1 then
		effect = self:createUICCBLayer("rgb-jones-upgrade", self._soldierImg1)
        local size = self._soldierImg1:getContentSize()
	    effect:setPosition(size.width * 0.5, -30)
        cloneObj = self._soldierImg1:clone()
        self._soldierImg1:getParent():addChild(cloneObj)
	else 
		effect = self:createUICCBLayer("rgb-jones-upgrade", self._soldierImg2)
        local size = self._soldierImg2:getContentSize()
	    effect:setPosition(size.width * 0.5, -30)
        cloneObj = self._soldierImg2:clone()
        self._soldierImg2:getParent():addChild(cloneObj)
	end
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    local act = cc.Spawn:create(cc.ScaleTo:create(0.4, 1.1), cc.FadeOut:create(0.4), cc.MoveBy:create(0.4, cc.p(0, 20)))
    cloneObj:runAction(act)
    cloneObj:setLocalZOrder(0)
    --cloneObj:setScale(2)
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	local function callback()
		effect:finalize()
        cloneObj:removeFromParent()
	end
	TimerManager:addOnce(1500, callback,self)
end

function GeneralAndSoldierPanel:zhengzhaoAciton(data)
	local posIndex = 1 
	local posJin = 1
	local posYin = 1
	local m, n = 0, 0
	for k,v in pairs(data) do
		if v.type%2 == 1 then
			n = v.times
		else
			m = v.times
		end
	end
	--if m == 0 and n == m then 
	--	if self.luo then
	--		self.luo:finalize()
	--	end
	--	local panel = self:getChildByName("mainPanel/actPanel")
	--	self.luo = UICCBLayer.new("rgb-beat-drum", panel)
	--	return 
	--end
	local imgJin = self:getChildByName("mainPanel/actPanel/effectNode2/effectEndPos")
	local imgYin = self:getChildByName("mainPanel/actPanel/effectNode1/effectEndPos")
	local x1,y1 = imgJin:getPosition()
	local x2,y2 = imgYin:getPosition()
	local jindou = {}
	local yindou = {}
	local function jinseDot()
		local panel = self:getChildByName("mainPanel/actPanel/effectNode2")
        if m > 0 then
		    local effect = self:createUICCBLayer("rgb-jones-jiang", self._soldierImg2)
            local size = self._soldierImg2:getContentSize()
		    effect:setPosition(size.width * 0.5, -30)
        end
		for i = 1, m do
			jindou[i] = self:createUICCBLayer("rgb-energy-jinse", panel)
            --jindou[i]:setPosition(GameConfig.TJQB_2[posIndex])
			local function effectRigth()
				local huan = self:createUICCBLayer("rgb-jones-quan", imgJin)
				if i == m then 
					local leftFlash = self:getChildByName("mainPanel/rightPanel/loadingbar")
					local flash = self:createUICCBLayer("rgb-jones-tixing", leftFlash)
                    local size = leftFlash:getContentSize()
					flash:setPosition(size.width * 0.5, size.height * 0.5)
				end
				local function callback()
					huan:finalize()
					if flash ~= nil then 
						flash:finalize()
					end
				end
				--huan:setPosition(20,20)
				TimerManager:addOnce(500, callback,self)
				jindou[i]:finalize()
			end
			local act1 = cc.MoveTo:create(GameConfig.TJQB.TIME1, GameConfig.TJQB_2[posIndex])
			act1 = cc.Sequence:create(act1, cc.MoveBy:create(GameConfig.TJQB.TIME2,cc.p(0,0)))
			local time = math.random(GameConfig.TJQB.TIME3*10,GameConfig.TJQB.TIME4*10)
			local poss = {GameConfig.TJQB.BEZIER_POINTS_JIN[posJin][1],
						 GameConfig.TJQB.BEZIER_POINTS_JIN[posJin][2],
						 cc.p(x1 ,y1)}
			local act = cc.BezierTo:create(time/10, poss)
			act = cc.EaseSineOut:create(act)
			act = cc.Sequence:create(act1,act)
			act = cc.Sequence:create(act,cc.CallFunc:create(effectRigth))
			jindou[i]:runAction(act)
			posIndex = posIndex + 1
			posJin = 1 + posJin
		end
	end
	local function yinseDot()
		local panel = self:getChildByName("mainPanel/actPanel/effectNode1")
        if n > 0 then
		    local effect = self:createUICCBLayer("rgb-jones-jiang", self._soldierImg1)
            local size = self._soldierImg1:getContentSize()
		    effect:setPosition(size.width * 0.5, -30)
        end
		for i=1,n do
			yindou[i] = self:createUICCBLayer("rgb-energy-jinse", panel)
            --yindou[i]:setPosition(GameConfig.TJQB_1[posIndex])
			local function effectLeft()
				local yin = self:createUICCBLayer("rgb-jones-quan", imgYin)
				if i == n then 
					local leftFlash = self:getChildByName("mainPanel/leftPanel/loadingbar")
					local flash = self:createUICCBLayer("rgb-jones-tixing", leftFlash)
                    local size = leftFlash:getContentSize()
					flash:setPosition(size.width * 0.5, size.height * 0.5)
				end
				local function callback()
					yin:finalize()
					if flash ~= nil then 
						flash:finalize()
					end
				end
				--yin:setPosition(20,20)
				TimerManager:addOnce(500, callback,self)
				yindou[i]:finalize()
			end
			local act1 = cc.MoveTo:create(GameConfig.TJQB.TIME1, GameConfig.TJQB_1[posIndex])
			act1 = cc.Sequence:create(act1, cc.MoveBy:create(GameConfig.TJQB.TIME2,cc.p(0,0)))
			local time = math.random(GameConfig.TJQB.TIME3*10,GameConfig.TJQB.TIME4*10)
			local poss = {GameConfig.TJQB.BEZIER_POINTS_YIN[posYin][1],
						 GameConfig.TJQB.BEZIER_POINTS_YIN[posYin][2],
						 cc.p(x2 ,y2)}
			local act = cc.BezierTo:create(time/10, poss)
			act = cc.EaseSineOut:create(act)
			act = cc.Sequence:create(act1,act)
			act = cc.Sequence:create(act,cc.CallFunc:create(effectLeft))
			yindou[i]:runAction(act)
			posIndex = posIndex + 1
			posYin = 1 + posYin
		end
	end
	--if self.luo then
	--	self.luo:finalize()
	--end
	--local panel = self:getChildByName("mainPanel/actPanel")
	--self.luo = UICCBLayer.new("rgb-beat-drum", panel)
	--TimerManager:addOnce(600 , jinseDot, self)-----------为何要延迟
	--TimerManager:addOnce(600 , yinseDot, self)
	jinseDot()
	yinseDot()
end

function GeneralAndSoldierPanel:setInfos(info,node)

	local armKind = ConfigDataManager:getInfoFindByOneKey(ConfigData.ArmKindsConfig, "ID", info.typeid)
	local color = ColorUtils:getColorByQuality(armKind.color)

    
    local soldierType, soldierLevel = math.modf(info.icon / 100)
    soldierLevel = soldierLevel * 100

    local imgType = node:getChildByName("iconType")--士兵TypeIcon
    TextureManager:updateImageView(imgType, "images/newGui1/IconBingYing" .. soldierType .. ".png")

	local nameLab = node:getChildByName("nameLab")
	nameLab:setString(info.name)
	nameLab:setColor(color)

	local levelBg = node:getChildByName("levelBg")
	local levelIcon = levelBg:getChildByName("levelIcon")

	--TextureManager:updateImageView(levelBg,"images/newGui2/Icon_bg_level"..armKind.type..".png")
    

	--local levelNum = armKind.model % 100
	TextureManager:updateImageView(levelIcon,"images/newGui2/Icon_level"..soldierLevel..".png")
    
	local soldierImg = node:getChildByName("soldierImg")
	local url = "bg/barrack/" .. self.SOLDIIER_PATH[soldierType] .. soldierLevel .. ".png"--"images/barrackIcon/"..info.icon..".png"
	soldierImg.typeid = info.typeid
	TextureManager:updateImageViewFile(soldierImg,url)
    if soldierLevel > 5 then
        soldierImg:setScale(0.8)
        soldierImg:setPositionY(280)
    else
        soldierImg:setScale(1.0)
        soldierImg:setPositionY(306)
    end
    
	local loadingLab = node:getChildByName("loadingLab")
	loadingLab:setString(info.currentNum.."/"..info.needNum)
	local loadingbar = node:getChildByName("loadingbar")
	local Percent = 0
	Percent = info.currentNum * 100 / info.needNum
	if info.currentNum > info.needNum then
		Percent = 100
	end
	loadingbar:setPercent(Percent)
	local trainBtn = node:getChildByName("trainBtn")
	-- trainBtn:setBright(Percent==100)
	-- trainBtn:setTouchEnabled(Percent==100)
	NodeUtils:setEnable(trainBtn, Percent==100)
end

function GeneralAndSoldierPanel:onHelpBtnTouch()
	local parent = self:getParent()
	local uiTip = UITip.new(parent)
	local lines = {}
	for i=1,4 do
		lines[i] = {{content = TextWords:getTextWord(230300 + i), foneSize = ColorUtils.tipSize20, color = ColorUtils.commonColor.MiaoShu}}
	end
	uiTip:setAllTipLine(lines)
end

function GeneralAndSoldierPanel:onTrainBtnTouch(sender)
	print("onTrainBtnTouch")
	local type = sender.btnType
	local info = self._infos[type]
	if info.currentNum < info.needNum then
		self:showSysMessage(self:getTextWord(230305))
		return
	end
	self._Proxy:onTriggerNet230025Req(info.ID)
end

function GeneralAndSoldierPanel:onRecruitBtnTouch(sender)
	if self.isDrawSoldier then
        self:showSysMessage(TextWords:getTextWord(280010))
		return
	end
    local price,tenprice = self._Proxy:getPrice()
	self.times = 1 
	self.cost = price

	if self._Proxy:getIsFree() > 0 then
	    self.cost = 0
    self.isDrawSoldier = true 
		self._Proxy:onTriggerNet230024Req(self.times)
		self._Proxy:usefree()
		return
	end

    self:drawSoldier(sender)
end

function GeneralAndSoldierPanel:onRecruitTenBtnTouch(sender)
	if self.isDrawSoldier then
        self:showSysMessage(TextWords:getTextWord(280010))
		return
	end
    local price,tenprice = self._Proxy:getPrice()
	self.cost = tenprice
	self.times = 10
    
    self:drawSoldier(sender)
end

function GeneralAndSoldierPanel:drawSoldier(sender)
	local function callFunc()
        self.isDrawSoldier = true 
		self._Proxy:onTriggerNet230024Req(self.times)
	end
	local function okCallBack()
		sender.callFunc = callFunc
		sender.money = self.cost
		self:isShowRechargeUI(sender)
	end
	local messageBox = self:showMessageBox(string.format(self:getTextWord(230115), self.cost),okCallBack)
    messageBox:setGameSettingKey(GameConfig.PAYTWOCONFIRM)
end

function GeneralAndSoldierPanel:onSoldierImgTouch(sender)
	local typeid = sender.typeid
	local soldierProxy = self:getProxy(GameProxys.Soldier)
    local soldier = soldierProxy:getSoldier(typeid)
    if self._uiSoldierInfo == nil then
        local parent = self:getLayer(ModuleLayer.UI_TOP_LAYER)
        self._uiSoldierInfo = UISoldierInfo.new(parent, self)
    end

    self._uiSoldierInfo:updateSoldierInfo(typeid, soldier)
end

--function GeneralAndSoldierPanel:onCheckBgImgTouch()
--	-- print("onCheckBgImgTouch")
--	local checkImg = self:getChildByName("downPanel/checkImg")
--	local visible = checkImg:isVisible()
--	checkImg:setVisible(not visible)
--	local price,tenprice = self._Proxy:getPrice()
--	local goldValueLab = self:getChildByName("downPanel/goldValueLab")
--	if visible then
--		self.times = 1 
--		goldValueLab:setString(self._Proxy:getIsFree() <= 0 and price or 0)
--		self.cost = price
--	else 
--		goldValueLab:setString(tenprice)
--		self.cost = tenprice
--		self.times = 10
--	end
--	self:setBtn()
--end

function GeneralAndSoldierPanel:isShowRechargeUI(sender)
    local needMoney = sender.money
    local roleProxy = self:getProxy(GameProxys.Role)
    local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0

    if needMoney > haveGold then
        local parent = self:getParent()
        local panel = parent.panel
        if panel == nil then
            local panel = UIRecharge.new(parent, self)
            parent.panel = panel
        else
            panel:show()
        end
    else
        sender.callFunc()
    end
end
