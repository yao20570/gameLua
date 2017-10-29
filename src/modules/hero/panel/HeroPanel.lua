--
-- Author: zlf
-- Date: 2016年8月29日14:48:03
-- 英雄主界面


HeroPanel = class("HeroPanel", BasicPanel)
HeroPanel.NAME = "HeroPanel"



--记录当前显示那个page在中间   初始是2
local curCenterIndex = 2

local scaleTime = 0.2
local moveTime = 0.3
local scale_num = 0.8

function HeroPanel:ctor(view, panelName)
    HeroPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function HeroPanel:finalize()
    for i=1,6 do
        local path = string.format("topPanel/lockPanel/item%d/tipImg", i)
        local tipImg = self:getChildByName(path)
        if tipImg.ect ~= nil then
           tipImg.ect:finalize()
           tipImg.ect = nil 
        end
    end

    for i=1,4 do
        local page = self:getChildByName("middlePanel/Panel_97/panel"..i)
        if page.effectQueue ~= nil then
            for k,v in pairs(page.effectQueue) do
                v:finalize()
            end
        end
        page.effectQueue = nil
    end

    for i=1, 4 do
        self._uiHeroCard[i]:finalize()
    end
    self._uiHeroCard = {}

    if self.rightEct ~= nil then
        self.rightEct:finalize()
        self.rightEct = nil
    end
    if self.leftEct ~= nil then
        self.leftEct:finalize()
        self.leftEct = nil
    end

    if self.uiHeroPanel ~= nil then
    	self.uiHeroPanel:destory()
    	self.uiHeroPanel = nil
    end
    if self._selectBox ~= nil then
    	self._selectBox:removeFromParent()
    	self._selectBox:release()
    	self._selectBox = nil
    end

    if self._btnEffect ~= nil then
        self._btnEffect:finalize()
        self._btnEffect = nil
    end

    if self._arrowEffect ~= nil then
        self._arrowEffect:finalize()
        self._arrowEffect = nil
    end

    HeroPanel.super.finalize(self)
end

function HeroPanel:initPanel()
	HeroPanel.super.initPanel(self)
	self:setBgType(ModulePanelBgType.NONE)
	self:setTitle(true, "hero", true)

    -- local tujianImg = self:getChildByName("bottomPanel/tujianImg")
    local btnTujian = self:getChildByName("bottomPanel/btnTujian")
	-- local img = self:getChildByName("bottomPanel/tujianImg/Image_30_1")
    --img:setVisible(false)
	self:addTouchEventListener(btnTujian, self.showTreasurePanel)

	local btnTrain = self:getChildByName("bottomPanel/btnTrain")
    -- self.trainBtn = self:getChildByName("bottomPanel/trainImg/trainBtn")
	self:addTouchEventListener(btnTrain, self.showTrainPanel)

	local btnChange = self:getChildByName("bottomPanel/btnChange")
	self:addTouchEventListener(btnChange, self.showChangePanel)

	local rightBtn = self:getChildByName("middlePanel/rightBtn")
    local size = rightBtn:getContentSize()
    self.rightEct = self:createUICCBLayer("rgb-fanye", rightBtn)
    -- rightBtn:setScaleX(-1)
    self.rightEct:setPosition(size.width/2, size.height/2)

	rightBtn.dir = -1
	local leftBtn = self:getChildByName("middlePanel/leftBtn")
    self.leftEct = self:createUICCBLayer("rgb-fanye", leftBtn)
	leftBtn.dir = 1
    self.leftEct:setPosition(size.width/2, size.height/2)

	self.btnBuZhen = self:getChildByName("middlePanel/Panel_97/btnBuZhen")
	self:addTouchEventListener(self.btnBuZhen, self.showTeamPanel)

    self.jiangJunBtn=self:getChildByName("middlePanel/Panel_97/jiangJunBtn")
    self:addTouchEventListener(self.jiangJunBtn,self.onJiangJunBtnTouch)

    self._uiHeroCard = {}
    for i=1,4 do
        local panel = self:getChildByName("middlePanel/Panel_97/panel"..i)
        local imgHeroCard = panel:getChildByName("imgHeroCard")        
        self._uiHeroCard[i] = UIHeroCard.new(self, imgHeroCard)
        self._uiHeroCard[i]:setBtnCommentVisible(true)
        panel.heroCard = self._uiHeroCard[i]
    end

	self.parentPanel = self:getChildByName("middlePanel/Panel_97")
	self.descPanel = self:getChildByName("pnlQingShangZhen")
    self.descPanel:setVisible(false)

    self._ImageBarBg = self:getChildByName("middlePanel/Panel_97/pnlHeroVal/ImageBarBg")
    self._barExp = self._ImageBarBg:getChildByName("barExp")
    self._labBarVal = self._ImageBarBg:getChildByName("labBarVal")

	self:addTouchEventListener(rightBtn, self.dirBtnTouch)
	self:addTouchEventListener(leftBtn, self.dirBtnTouch)

	-- self.allEffectName = {"rpg-wujiangpinzhi-lu", "rpg-wujiangpinzhi-lan", "rpg-wujiangpinzhi-zi", "rpg-wujiangpinzhi-huang"}
	self.effectNode = self:getChildByName("middlePanel/Image_66")
	
	self.proxy = self:getProxy(GameProxys.Hero)

    --写死4个位置
    self._allPos = {}
    self._allPos[1] = {0, 640, 1280, -640}
    self._allPos[2] = {-640, 0, 640, 1280}
    self._allPos[3] = {1280, -640, 0, 640}
    self._allPos[4] = {640, 1280, -640, 0}

	self.talentLab = self:getChildByName("middlePanel/Panel_97/talentLab")
	self.talentLab:ignoreContentAdaptWithSize(false) 
	-- self.talentLab:setContentSize(500,65) 
	self.talentLab:setLocalZOrder(3)

    local touchPanel = self:getChildByName("middlePanel")

	ComponentUtils:addTouchEventListener(touchPanel, self.endCall, nil, self)

	self.items = {}
	self.attrInfos = {}
    local pnlHeroVal = self:getChildByName("middlePanel/Panel_97/pnlHeroVal")
	for i=1,6 do
		self.attrInfos[i] = pnlHeroVal:getChildByName("item"..i)
		self.items[i] = self:getChildByName("topPanel/lockPanel/item"..i)
		self.items[i].id = i
		self:addTouchEventListener(self.items[i], self.updateHeroInfo)
        self["btnItem" .. i] = self.items[i]
	end

    self.attrInfos[7] = pnlHeroVal:getChildByName("item7")
    self.attrInfos[8] = pnlHeroVal:getChildByName("item8")

    
    

    self._treasureBox1 = self:getChildByName("middlePanel/treasureBox1")
    self._treasureBox2 = self:getChildByName("middlePanel/treasureBox2")

    --暂时屏蔽宝具
    self._treasureBox1:setVisible(false)
    self._treasureBox2:setVisible(false)

    local treasureBox1Top = self:getChildByName("middlePanel/treasureBox1Top")
    local treasureBox2Top = self:getChildByName("middlePanel/treasureBox2Top")
    self:addTouchEventListener(treasureBox1Top, self.operateHeroTreasure1)
    self:addTouchEventListener(treasureBox2Top, self.operateHeroTreasure2)
    self.tuJianBtn = self:getChildByName("middlePanel/Panel_97/tuJianBtn")
	self:addTouchEventListener(self.tuJianBtn, self.showImgPanel)
	--现在版本
---[[
    self._treasureBox1:setVisible(false)
    self._treasureBox2:setVisible(false)
	treasureBox1Top:setVisible(false)
	treasureBox2Top:setVisible(false)

	-- self.tuJianBtn:setVisible(false)
	--]]
	--下版本（开启宝具）	
	
	-- for i=1,3 do
	-- 	self.attrLab[i]:setVisible(false)
	-- end
	-- self.fightLab:setVisible(false)
	-- local Image_11 = self:getChildByName("middlePanel/Panel_97/Image_11")
	-- local Image_11_0 = self:getChildByName("middlePanel/Panel_97/Image_11_0")
	-- local Image_11_0_1 = self:getChildByName("middlePanel/Panel_97/Image_11_0_1")
	-- local Image_11_0_1_2 = self:getChildByName("middlePanel/Panel_97/Image_11_0_1_2")
	-- Image_11:setVisible(false)
	-- Image_11_0:setVisible(false)
	-- Image_11_0_1:setVisible(false)
	-- Image_11_0_1_2:setVisible(false)


end
function HeroPanel:operateHeroTreasure1(sender)
    local roleProxy = self:getProxy(GameProxys.Role)
    local isOpen = roleProxy:isFunctionUnLock(46,true)
    if isOpen then
        if self._treasureLeftData.putData == "none" then
            local panel = self:getPanel(HeroTreasurePanel.NAME)
            self._curOpenTreasurePosition = 0
            panel:show(self._treasureLeftData) 
         else
            self.proxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.HeroTreaPutModule, extraMsg = self._treasureLeftData})
        end
    end
    
end
function HeroPanel:operateHeroTreasure2(sender)
    local roleProxy = self:getProxy(GameProxys.Role)
    local isOpen = roleProxy:isFunctionUnLock(46,true)
    if isOpen then
        if self._treasureRightData.putData == "none" then
            local panel = self:getPanel(HeroTreasurePanel.NAME)
            self._curOpenTreasurePosition = 1
            panel:show(self._treasureRightData) 
        else
            self.proxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.HeroTreaPutModule, extraMsg = self._treasureRightData})
        end
    end
end

function HeroPanel:doLayout()    
    local topPanel = self:getChildByName("topPanel")
    local bottomPanel = self:getChildByName("bottomPanel")
    local middlePanel = self:getChildByName("middlePanel")
    local pnlQingShangZhen = self:getChildByName("pnlQingShangZhen")

    NodeUtils:adaptiveTopY(topPanel, LayoutConfig.TopSpace56)
    NodeUtils:adaptiveTopY(middlePanel,LayoutConfig.TopSpace270)
    NodeUtils:adaptiveUpPanel(bottomPanel,middlePanel)

    NodeUtils:adaptiveDownPanel(pnlQingShangZhen,bottomPanel,100)

    self:setMask(false)

    --//null
    --pnlQingShangZhen:setVisible(false)
    
end

function HeroPanel:registerEvents()
	HeroPanel.super.registerEvents(self)
end

--关闭在有uiheropanel的情况下，先关闭uiheropanel
function HeroPanel:onClosePanelHandler()
	if self.uiHeroPanel ~= nil then
		local node = self.uiHeroPanel:getRootNode()
		if node:isVisible() then
			self:setTitle(true, "hero", true)
			node:setVisible(false)
            self:showContentEnable(true)
			if not self.isChangeHero then 
				local heroData = self.proxy:getHeroInfoWithPos(self.curPos)
				if heroData == nil then
					self:changePosUpdate(1)
				end
			end
			return
		end
	end
	self.view:dispatchEvent(HeroEvent.HIDE_SELF_EVENT)
end

function HeroPanel:onShowHandler()
	self:initPosData() -- 位置解锁等
	self:initPosState() -- 是否可上阵
	self.curPos = 1
	self:initView(self.items[1].data)
    self._isHave = true
    self._canTouch = true

    --宝具
    -- local roleProxy = self:getProxy(GameProxys.Role)
    -- local isOpen = roleProxy:isFunctionUnLock(46,false)
    -- if isOpen == true then
    --     self._treasureBox1:setVisible(true)
    --     self._treasureBox2:setVisible(true)
    --     local treasureBox1Top = self:getChildByName("middlePanel/treasureBox1Top")
    --     local treasureBox2Top = self:getChildByName("middlePanel/treasureBox2Top")
    --     treasureBox1Top:setVisible(true)
    --     treasureBox2Top:setVisible(true)
    -- end

    self:doLayout()
end

function HeroPanel:initView(data, dir)
    --有英雄和没英雄的时候显示不一样
	local isShow = false
	for i=1, 6 do
		local numBg = self.items[i]:getChildByName("numBg")
        local numLab = numBg:getChildByName("numLab")
		local heroData = self.proxy:getHeroInfoWithPos(i)
		self.items[i].data = heroData
        numLab:setVisible(heroData ~= nil and self.posData[i])
		numBg:setVisible(heroData ~= nil and self.posData[i])
		if numLab:isVisible() then
			numLab:setString(heroData.heroLv)
		end

        local tipImg = self.items[i]:getChildByName("tipImg")
        tipImg:setVisible(heroData ~= nil)

        if tipImg:isVisible() then
            if tipImg.ect == nil then--箭头特效
                tipImg.ect = self:createUICCBLayer("rgb-jiantou", tipImg)
                -- tipImg.ect = self:createUICCBLayer("rgb-wj-anniu", tipImg)

            end
            
            local isHaveExpCard = self.proxy:isHaveExpCard() -- 是否有经验卡
            local heroConfig = ConfigDataManager:getConfigById(ConfigData.HeroConfig, heroData.heroId)
            local canStarUp = self.proxy:isCanStarUp(heroData) -- 是否可升星(星级和升星材料是否满足)

            canStarUp = heroData.heroLv > 20 and canStarUp
            -- 显示控制
            local state = false
            if isHaveExpCard and self:isCanLevelUp(heroData.heroLv, heroConfig.lvmax) then
                state = true
            elseif canStarUp then
                state = true
            end
            tipImg:setVisible(state)
        end
	end

    isShow = self.items[self.curPos].data ~= nil
	
    self.parentPanel:setVisible(isShow)

    --进度条处理
    if isShow then
        self._ImageBarBg:setVisible(true)

        local data = self.items[self.curPos].data

        local nextLvExp = self:getNextLvExp(data)

        local nowPencent = data.heroExp/nextLvExp*100 > 100 and 100 or data.heroExp/nextLvExp*100
        local percent = nextLvExp == 0 and 100 or nowPencent
        self._barExp:setPercent(percent)
        self._labBarVal:setString(string.format("%d/%d",data.heroExp,nextLvExp))
    else
        self._ImageBarBg:setVisible(false)
    end



	self.parentPanel:setVisible(isShow)

	if self._selectBox == nil then
		-- self._selectBox = TextureManager:createImageView("images/component/select_box.png")
		-- self._selectBox:retain()
		-- self.parentPanel:addChild(self._selectBox)

        self._selectBox = cc.Node:create()
        self._selectBox:retain()
        self:createUICCBLayer("rgb-wj-xuanzhong", self._selectBox)
        self.parentPanel:addChild(self._selectBox)
	end
	-- self.flagImg:setVisible(not isShow)
    -- self._commentBtn:setVisible(isShow)
	self.descPanel:setVisible(not isShow)
    local bottomPanel=self:getChildByName("bottomPanel")
    bottomPanel:setVisible(isShow)

    local heroTreasureProxy = self:getProxy(GameProxys.HeroTreasure)
    -------------------宝具begin
    local treasureLockImg1  = self:getChildByName("middlePanel/treasureBox1/bgImg/treasureLockImg")
    local treasureLockImg2  = self:getChildByName("middlePanel/treasureBox2/bgImg/treasureLockImg")
    local starPanel1 = self:getChildByName("middlePanel/treasureBox1/starPanel")
    local starPanel2 = self:getChildByName("middlePanel/treasureBox2/starPanel")
    local treasureBox1TopAdvLevelLab = self:getChildByName("middlePanel/treasureBox1Top/advLevelLab")
    local treasureBox2TopAdvLevelLab = self:getChildByName("middlePanel/treasureBox2Top/advLevelLab")
    local curPostLevelInfos =  heroTreasureProxy:getPostLevelInfosByPos(self.curPos)
    if curPostLevelInfos[0] > 0 then
        treasureBox1TopAdvLevelLab:setVisible(true)
        treasureBox1TopAdvLevelLab:setString("+" .. curPostLevelInfos[0])
    else
        treasureBox1TopAdvLevelLab:setVisible(false)
    end
    if curPostLevelInfos[1] > 0 then
        treasureBox2TopAdvLevelLab:setVisible(true)
        treasureBox2TopAdvLevelLab:setString("+" .. curPostLevelInfos[1])
    else
        treasureBox2TopAdvLevelLab:setVisible(false)
    end



    local roleProxy = self:getProxy(GameProxys.Role)
    local isTreasureOpen = roleProxy:isFunctionUnLock(46,false)
    if isTreasureOpen then
        treasureLockImg1:setVisible(false)
        treasureLockImg2:setVisible(false)
        starPanel1:setVisible(true)
        starPanel2:setVisible(true)

        local treasureBgImg1 = self._treasureBox1:getChildByName("bgImg")
        local treasureBgImg2 = self._treasureBox2:getChildByName("bgImg")

        
        local treasureTable = heroTreasureProxy:getTreasureInfoByHeroPostId(self.curPos)
        --宝具小红点
        local treasureTipImg1 = self:getChildByName("middlePanel/treasureBox1/bgImg/treasureTipImg")
        local treasureTipImg2 = self:getChildByName("middlePanel/treasureBox2/bgImg/treasureTipImg")
        --武器
        if treasureTable["0"] then
                treasureTipImg1:setVisible(false)
                local data = {}
                data.power = GamePowerConfig.HeroTreasure 
                data.typeid = treasureTable["0"].typeid
                data.parts = treasureTable["0"]
                data.equip = 1
                if self.LeftHTuiIcon == nil then
                    local uiIcon = UIIcon.new(self._treasureBox1,data,false, self)
                    uiIcon:setPosition(treasureBgImg1:getPositionX(), treasureBgImg1:getPositionY())
                    self.LeftHTuiIcon = uiIcon
                else
                    self.LeftHTuiIcon:updateData(data)
                end 
                --0级以上的洗炼属性为黄星，0级的灰星
                local showYellowStarNum = 0
                local showGrayStarNum = 0
                local curBaseInfoNum = #treasureTable["0"].baseInfo
                showGrayStarNum = curBaseInfoNum
                showGrayStarNum = showGrayStarNum == 3 and 4 or curBaseInfoNum
                for _,v in ipairs(treasureTable["0"].baseInfo) do
                    if v.level > 0 then
                        showYellowStarNum = showYellowStarNum + 1
                    end
                end
                for i=1,4 do
                    local starImg = self:getChildByName("middlePanel/treasureBox1/starPanel/starImg" .. i)
                    local starHuiImg = self:getChildByName("middlePanel/treasureBox1/starPanel/starHuiImg" .. i)
                    if i <= showYellowStarNum then
                        starImg:setVisible(true)
                    else
                        starImg:setVisible(false)
                    end
                    if i <= showGrayStarNum then
                        starHuiImg:setVisible(true)
                    else
                        starHuiImg:setVisible(false)
                    end
                end
            --TextureManager:updateImageView(treasureBgImg1,ComponentUtils:getTreasureIconImgUrl(treasureTable["0"].typeid))
            self._treasureLeftData = treasureTable["0"]
            self._treasureLeftData.putData = "none"
            else
                treasureTipImg1:setVisible(heroTreasureProxy:isCanPutOn(0))
                if self.LeftHTuiIcon ~= nil then
                    self.LeftHTuiIcon:finalize()
                    self.LeftHTuiIcon = nil
                end
                for i=1,4 do
                    local starImg = self:getChildByName("middlePanel/treasureBox1/starPanel/starImg" .. i)
                    local starHuiImg = self:getChildByName("middlePanel/treasureBox1/starPanel/starHuiImg" .. i)
                    starImg:setVisible(false)
                    starHuiImg:setVisible(false)

                end
                --TextureManager:updateImageView(treasureBgImg1,"images/newGui1/none.png")
                self._treasureLeftData = {}
                local tempData = {}
                tempData.postId = self.curPos
                tempData.post = 0
                self._treasureLeftData.putData = tempData


        end
        --马驹
        if treasureTable["1"] then
                treasureTipImg2:setVisible(false)
                local data = {}
                data.power = GamePowerConfig.HeroTreasure 
                data.typeid = treasureTable["1"].typeid
                data.parts = treasureTable["1"]
                data.equip = 1
                self._enableTouch = false
                if self.RightHTuiIcon == nil then
                    local uiIcon = UIIcon.new(self._treasureBox2,data,false, self)
                    uiIcon:setPosition(treasureBgImg2:getPositionX(), treasureBgImg2:getPositionY())
                    self.RightHTuiIcon = uiIcon
                else
                    self.RightHTuiIcon:updateData(data)
                end 
                --0级以上的洗炼属性为黄星，0级的灰星
                local showYellowStarNum = 0
                local showGrayStarNum = 0
                local curBaseInfoNum = #treasureTable["1"].baseInfo
                showGrayStarNum = curBaseInfoNum
                showGrayStarNum = showGrayStarNum == 3 and 4 or curBaseInfoNum
                for _,v in ipairs(treasureTable["1"].baseInfo) do
                    if v.level > 0 then
                        showYellowStarNum = showYellowStarNum + 1
                    end
                end
                for i=1,4 do
                    local starImg = self:getChildByName("middlePanel/treasureBox2/starPanel/starImg" .. i)
                    local starHuiImg = self:getChildByName("middlePanel/treasureBox2/starPanel/starHuiImg" .. i)
                    if i <= showYellowStarNum then
                        starImg:setVisible(true)
                    else
                        starImg:setVisible(false)
                    end
                    if i <= showGrayStarNum then
                        starHuiImg:setVisible(true)
                    else
                        starHuiImg:setVisible(false)
                    end
                end
            --TextureManager:updateImageView(treasureBgImg2, ComponentUtils:getTreasureIconImgUrl(treasureTable["1"].typeid))
                self._treasureRightData = treasureTable["1"]
                self._treasureRightData.putData = "none"
            else
                treasureTipImg2:setVisible(heroTreasureProxy:isCanPutOn(1))
                 if self.RightHTuiIcon ~= nil then
                    self.RightHTuiIcon:finalize()
                    self.RightHTuiIcon = nil
                end
                for i=1,4 do
                    local starImg = self:getChildByName("middlePanel/treasureBox2/starPanel/starImg" .. i)
                    local starHuiImg = self:getChildByName("middlePanel/treasureBox2/starPanel/starHuiImg" .. i)
                    starImg:setVisible(false)
                    starHuiImg:setVisible(false)
                end
            --TextureManager:updateImageView(treasureBgImg2, "images/newGui1/none.png")
            self._treasureRightData = {}
            local tempData = {}
            tempData.postId = self.curPos
            tempData.post = 1
            self._treasureRightData.putData = tempData
        end
        local heroTreasurePanel = self:getPanel(HeroTreasurePanel.NAME)
        if self._curOpenTreasurePosition == 0 then
            if treasureTable["0"] and #treasureTable["0"] > 0 then
                heroTreasurePanel:updateView(treasureTable["0"])
                else
                heroTreasurePanel:hide()
            end
            
        elseif self._curOpenTreasurePosition == 1 then
            if treasureTable["1"] and #treasureTable["1"] > 0 then
                heroTreasurePanel:updateView(treasureTable["1"])
                else
                heroTreasurePanel:hide()
            end
            
        end
    else
        treasureLockImg1:setVisible(true)
        treasureLockImg2:setVisible(true)
        starPanel1:setVisible(false)
        starPanel2:setVisible(false)
        treasureBox1TopAdvLevelLab:setVisible(false)
        treasureBox2TopAdvLevelLab:setVisible(false)
        
    end

    --暂时屏蔽宝具  2016年11月23日15:12:24
    -- for i=1,2 do
    --     local treasureBox = self:getChildByName("middlePanel/treasureBox".. i .. "Top")
    --     treasureBox:setVisible(false)
    -- end
	
    -------------------宝具end

    
    --retain来改变选中框的去向
    self._selectBox:removeFromParent()
	local boxParent = self.items[self.curPos]
	boxParent:addChild(self._selectBox)
	self._selectBox:setLocalZOrder(10)
    self._selectBox:setPosition(41,41)

    -- self:updateBtnEffect()

	if not isShow then
        self._canTouch = true
		return
	end
	if data == nil then
		for i=1,6 do
			local heroData = self.proxy:getHeroInfoWithPos(i)
			if heroData ~= nil then
				data = heroData
				self.curPos = i
				break
			end
		end
	end
	if data == nil then
		self.trainBtn.data = nil
        self._canTouch = true
		return
	end

    --更新英雄的基本信息
    local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)
    local page = self:getChildByName("middlePanel/Panel_97/panel"..curCenterIndex)
    page.effectQueue = page.effectQueue or {}

    local pnlHeroVal = self:getChildByName("middlePanel/Panel_97/pnlHeroVal")
    local LvLab = pnlHeroVal:getChildByName("LvLab")
    local firstNumTxt = pnlHeroVal:getChildByName("item8"):getChildByName("addLab")--pnlHeroVal:getChildByName("firstNumTxt") -- 先手值
    local commandTxt  = pnlHeroVal:getChildByName("item7"):getChildByName("addLab")--pnlHeroVal:getChildByName("commandTxt")  -- 带兵量

    LvLab:setString("Lv. " .. data.heroLv)

    firstNumTxt:setString(self.proxy:getFirstnum(self.curPos))
    commandTxt:setString(self.proxy:getHeroCommandNumWithData(data))


    --print("英雄id :" .. data.heroId)
    
    local cardData = { }
    cardData.heroId = data.heroId
    cardData.starNum = data.heroStar
    cardData.fightting = self.proxy:getHeroFight(self.curPos,{})
    self._uiHeroCard[curCenterIndex]:updateData(cardData)

    -- local scaleNum = 1
    -- heroImg:setScale(scaleNum)
    -- local heroPos = heroImg.pos or cc.p(heroImg:getPosition())
    -- heroImg.pos = heroPos
    -- local size = heroImg:getContentSize()
    -- heroImg:setContentSize(size.width*scaleNum, size.height*scaleNum)

	self.trainBtn = data

    --[[动作特效需求:
         1.触发移动的时候 pnlHeroVal 透明度为0
         2.等待头像移动到结束为止 pnlHeroVal 直接出来,
             下面的item从上到下依次错位+渐变出现
    ]]
    if self.talentImg == nil then
        self.talentImg = self:getChildByName("middlePanel/Panel_97/talentImg")
    end
    pnlHeroVal:stopAllActions();

    local otherNodes = {
        pnlHeroVal,
        self.talentLab,
        self.talentImg,
        self.tuJianBtn,
        self.btnBuZhen,
        self.jiangJunBtn
    }

    self:setAllChildrenOpacity(pnlHeroVal,0)
    self:setAllChildrenOpacity(self.talentLab,0)
    self:setAllChildrenOpacity(self.talentImg,0)

    self:setAllChildrenOpacity(self.tuJianBtn,0)
    self:setAllChildrenOpacity(self.btnBuZhen,0)
    self:setAllChildrenOpacity(self.jiangJunBtn,0)
    

    local function moveEndCall()
        local nodes_tb = {
            {
                self._ImageBarBg,
                LvLab,
            },
            {self.attrInfos[7]},
            {self.attrInfos[8]},
            {self.attrInfos[1]},
            {self.attrInfos[4]},
            {self.attrInfos[2]},
            {self.attrInfos[5]},
            {self.attrInfos[6]},
            {self.attrInfos[3]},
            {self.talentImg},
            {self.talentLab},
            -- {self._commentBtn},
            {
                self.tuJianBtn,
                self.btnBuZhen,
                self.jiangJunBtn
            }
        }
        local names = {
            "imgHuiDi1",
            "imgHuiDi2",
            "imgJinBian1",
            "imgJinBian2"
        }
        pnlHeroVal:setOpacity(255)

        local offset_x = 50
        if dir then
            offset_x = offset_x * dir
        end
        local time = 0.1  --移动和fadein的时间


        for i = 1,#nodes_tb do
            local nodes = nodes_tb[i]
            for j = 1,#nodes do
                local node = nodes[j]
                node:stopAllActions()
                node:setOpacity(0)
            end
        end


        for i = 1,#names do
            local node = pnlHeroVal:getChildByName(names[i])
            node:stopAllActions()
            -- node:setOpacity(0)
        end


        local function initDongHua()
            for i = 1,#nodes_tb do
                local nodes = nodes_tb[i]
                for j = 1,#nodes do
                    local node = nodes[j]
                    if node.origin_x == nil then
                        node.origin_x = node:getPositionX()
                    end
                    node:stopAllActions()
                    node:setPositionX(node.origin_x + offset_x)
                end
            end


            for i = 1,#names do
                local node = pnlHeroVal:getChildByName(names[i])
                node:stopAllActions()
                node:runAction(cc.FadeIn:create(time))
            end

        end

        local function offsetMove(ref)
            for i = 1,#nodes_tb do
                local nodes = nodes_tb[i]
                for j = 1,#nodes do
                    local node = nodes[j]
                    local function moveFadeIn()
                        node:runAction(cc.MoveTo:create(time,cc.p(node.origin_x,node:getPositionY())))
                        self:setAllChildrenFadeIn(node,time)
                    end
                    node:runAction(
                        cc.Sequence:create(
                            cc.DelayTime:create(i*0.02)
                            -- ,cc.MoveTo:create(0.8,cc.p(node.origin_x,node:getPositionY()))
                            ,cc.CallFunc:create(moveFadeIn)
                        ))
                end
            end
        end

        pnlHeroVal:runAction(cc.Sequence:create(
                cc.CallFunc:create(initDongHua),
                cc.CallFunc:create(offsetMove)
            ))

    end

    --缓存特效，不删除
    for k,v in pairs(page.effectQueue) do
        v:setVisible(false)
    end

	local talentData = StringUtils:jsonDecode(config.talent)
	local talentStr = ""
	for k,v in pairs(talentData) do
		local heroTianFu = ConfigDataManager:getConfigById(ConfigData.HeroGiftConfig, v)
		if heroTianFu ~= nil then
			talentStr = talentStr .. heroTianFu.info
		end
	end
	talentUrl = string.format("images/hero/talent%d.png", config.color)


	self.talentLab:setString(talentStr)

    self._typeId   = config.ID
    self._heroName = config.name


    if self.talentImg == nil then
        self.talentImg = self:getChildByName("middlePanel/Panel_97/talentImg")
    end
	self.talentImg:setLocalZOrder(3)

	-- local talentIcon = self:getChildByName("middlePanel/Panel_97/talentImg/Image_64")
	-- TextureManager:updateImageView(talentIcon, talentUrl)

	local roleProxy = self:getProxy(GameProxys.Role)
	local level = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)

	local heroAttrInfos = self.proxy:getHeroAllAttr(data)
    local treasureAttAddInfos = heroTreasureProxy:getTreasureAttAddToHero(data.heroPosition)
    local treasureAttAddPlusInfos = heroTreasureProxy:getTreasureAttAddToHeroPlus(data.heroPosition)
    
	for k,v in pairs(heroAttrInfos) do
		local addLab = self.attrInfos[k]:getChildByName("addLab")
		local otherLab = self.attrInfos[k]:getChildByName("otherLab")
		local descLab = self.attrInfos[k]:getChildByName("descLab")
		local Image_62 = self.attrInfos[k]:getChildByName("Image_62")
		local iconImg = Image_62:getChildByName("iconImg")
		descLab:setString(v.text)
		otherLab:setString("")
		local baseStr = ""
		if k == 1 then
            baseStr = math.ceil(v.base*treasureAttAddPlusInfos.hpRate*0.0001 + v.base) 
        elseif k == 4 then
            baseStr = math.ceil(v.base*treasureAttAddPlusInfos.attackRate*0.0001 + v.base)
        elseif k == 7 or k == 8 then--先手和带兵
		else
            baseStr = ((v.base+treasureAttAddInfos[k].base)/100).."%"
		end
		addLab:setString(baseStr)
		-- local url = self.proxy:getIconPath(k)
		-- TextureManager:updateImageView(iconImg, url)
	end


    local posArr = self._allPos[curCenterIndex]

    for i=1,4 do
        local panel = self:getChildByName("middlePanel/Panel_97/panel"..i)
        panel:setVisible(i == curCenterIndex)
        panel:setScale(1)
    end

    --initview的时候判断没个page要不要做动作
    --每个page都能触摸，触摸只是做改变curCenterIndex的操作和改变self.curpos的操作
    --剩下的动画，信息的变更全部放在Initview里面做
    local endIndex = 1
    for i=1,4 do
        local panel = self:getChildByName("middlePanel/Panel_97/panel"..i)
        panel.index = i
        local posX = panel:getPosition()
        if dir == nil then
            panel:setPositionX(posArr[i])
            if i == 4 then
                moveEndCall()
            end
        else
            local visible
            --防止其他panel在移动造成界面闪烁
            if dir == 1 and curCenterIndex == 1 then
                visible = (i == 4 or i == 1)
            elseif dir == -1 and curCenterIndex == 4 then
                visible = (i == 4 or i == 1)
            else
                visible = math.abs(posX - posArr[i]) <= 640
            end
            panel:setVisible(visible)

            local move = cc.EaseBackOut:create(cc.MoveTo:create(moveTime, cc.p(posArr[i], panel:getPositionY())))
            local call = cc.CallFunc:create(function(sender)
                -- sender:setScale(scale_num)
            end)
            local moveEnd = cc.CallFunc:create(function(sender)
                sender:setScale(1)
                sender:setPositionX(posArr[sender.index])
                endIndex = endIndex + 1
                if endIndex == 4 then
                    TimerManager:addOnce(80, function()
                        self._canTouch = true
                    end, self)
                    moveEndCall()
                end
            end)
            local spawn = cc.Spawn:create(move, call)
            local action = cc.Sequence:create(spawn, moveEnd)
            panel:runAction(action)
        end
        self:addTouchEventListener(panel, self.movePanel)
    end

    if dir == nil then
        self._canTouch = true
    end

end

function HeroPanel:showImgPanel(sender)
	self.proxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.HeroPokedexModule})

end
function HeroPanel:showTreasurePanel(sender)
    --暂时屏蔽宝具
    self:showSysMessage(self:getTextWord(290054))
    -- local roleProxy = self:getProxy(GameProxys.Role)
    -- local isOpen = roleProxy:isFunctionUnLock(46,true)
    -- if isOpen then
	   -- self.proxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.HeroTreaWarehouseModule})
    -- end
end

function HeroPanel:showTrainPanel(sender)
	local heroData = self.proxy:getHeroInfoWithPos(self.curPos or 1)
	if heroData == nil then
		return
	end
	local data = {}
	data.moduleName = ModuleName.HeroTrainModule
	data.extraMsg = {}
	data.extraMsg.heroData = heroData
	data.extraMsg.TrainType = 1
	self.proxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end

function HeroPanel:showChangePanel(sender)
    
	self.isChangeHero = sender ~= nil
    --topAdaptivePanel 位置不对了,改用数字 兼容性处理
	local panel = GlobalConfig.topHeight3--self:topAdaptivePanel()
	panel = GlobalConfig.topHeight
	local data = clone(self.proxy:getAllHeroData())
    self:showContentEnable(false)
    self.descPanel:setVisible(false)

	if self.uiHeroPanel == nil then
		self.uiHeroPanel = UIHeroPanel.new(self, data, 2, nil, panel) -- 类型：上阵 = 2
	else
		self.uiHeroPanel:updateView(data, 2)
	end

	self:setTitle(true, "heroChoose", true)
	self.uiHeroPanel:getRootNode():setLocalZOrder(100)
end

--显示/隐藏我这个panle的内容
function HeroPanel:showContentEnable(bool)
    -- if bool then
    --     print("显示内容")
        self:getChildByName("topPanel"):setVisible(bool)
        self:getChildByName("bottomPanel"):setVisible(bool)
        self.descPanel:setVisible(not bool)
        self:getChildByName("middlePanel"):setVisible(bool)
    -- else
    --     print("隐藏内容")
    -- end
end

function HeroPanel:updateHeroInfo(sender)
	local id = sender.id
	local state = self.posData[id]
	if not state then
        local soldierProxy = self:getProxy(GameProxys.Soldier)
        local _, notOpenInfo = soldierProxy:isTroopsOpen(id)
		local text = string.format(self:getTextWord(290055), notOpenInfo)
		self:showSysMessage(text)
		return
	end
	self.curPos = id
	--解锁，但是没有英雄
	if sender.data == nil then
		self:showChangePanel()
	else
		self:initView(sender.data)
	end
end

function HeroPanel:dirBtnTouch(sender)
    if not self._canTouch then
        return
    end
    self._canTouch = false
    local dir = sender.dir * -1
    local data = self.proxy:getHeroInfoWithPos(self.curPos)
    if data == nil then
        curCenterIndex = curCenterIndex or 2
        curCenterIndex = curCenterIndex > 4 and 1 or curCenterIndex
        curCenterIndex = curCenterIndex < 1 and 4 or curCenterIndex

        local posArr = self._allPos[curCenterIndex] or self._allPos[1]
        for i=1,4 do
            local panel = self:getChildByName("middlePanel/Panel_97/panel"..i)
            panel:setPositionX(posArr[i])
            panel:setScale(1)
        end
        self:changePosUpdate(dir, true)
    else
        
        curCenterIndex = curCenterIndex + dir
        curCenterIndex = curCenterIndex > 4 and 1 or curCenterIndex
        curCenterIndex = curCenterIndex < 1 and 4 or curCenterIndex
        self:changePosUpdate(dir)
    end
end

function HeroPanel:changePosUpdate(dir, noAction)
    
	self.curPos = self.curPos + dir
	self.curPos = self.curPos < 1 and self.curPosNum or self.curPos
	self.curPos = self.curPos > self.curPosNum and 1 or self.curPos
   

	local data = self.proxy:getHeroInfoWithPos(self.curPos)
    if noAction then
        dir = nil
    end
	self:initView(data, dir)
end

--位置解锁了没有  state状态决定
--self.posData[pos] = state
function HeroPanel:initPosData()
	self.posData = {}
	local roleProxy = self:getProxy(GameProxys.Role)
    local soldierProxy = self:getProxy(GameProxys.Soldier)
	local level = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
	for i=1,6 do
		local state = soldierProxy:isTroopsOpen(i)
		self.posData[i] = state

		local imgLock = self.items[i]:getChildByName("imgLock")
		local bgImg = self.items[i]:getChildByName("bgImg")
		local url = ""
		if not state then
			bgImg:setVisible(false)
			-- url = "images/newGui2/Icon_lock.png"
            imgLock:setVisible(true)
		else
			local heroData = self.proxy:getHeroInfoWithPos(i)
			url = heroData == nil and string.format("images/hero/%d.png", i) or "images/newGui1/none.png"
			bgImg:setVisible(heroData ~= nil)
			if heroData ~= nil then
				local icon = bgImg.uiIcon
				local iconData = {}
				iconData.num = 1
				iconData.typeid = heroData.heroId
				iconData.power = 409
				if icon == nil then
					icon = UIIcon.new(bgImg, iconData, false, self)
					bgImg.uiIcon = icon
				else
					icon:updateData(iconData)
				end
				icon:setTouchEnabled(false)
			end
            imgLock:setVisible(false)

		end
	end
	local panel = self:getPanel(HeroTeamPanel.NAME)
	if panel:isVisible() then
		panel:initPosView(self.posData)
	end
    --开了多少出站槽
    self.curPosNum = 0
    for j=1,6 do
        if self.posData[j] == true then
            self.curPosNum = self.curPosNum + 1
        end
    end
end

function HeroPanel:updateBtnEffect()
    -- 添加按钮特效
    if self._btnEffect == nil then
        self._btnEffect = self:createUICCBLayer("rgb-peiyang", self.trainBtn)
        local size = self.trainBtn:getContentSize()
        self._btnEffect:setPosition(size.width/2 - 2, size.height/2 - 11)
        
        self._arrowEffect = self:createUICCBLayer("rgb-jiantou", self.trainBtn) -- 箭头特效
        self._arrowEffect:setPosition(size.width * 0.76, size.height * 0.76)
    end


    
    local isHaveExpCard, count = self.proxy:isHaveExpCard()
    self.curPos = self.curPos or 1
    local data = self.proxy:getHeroInfoWithPos(self.curPos)
    local isCanStarUp = self.proxy:isCanStarUp(data)
    
    if data == nil then
        self._btnEffect:setVisible(false)
        self._arrowEffect:setVisible(false)
    else
        -- 根据tipImg的显示来判断两个特效的显示
        local tipImg = self.items[self.curPos]:getChildByName("tipImg")
        local isVisible = tipImg:isVisible() and tipImg.ect ~= nil 
        self._btnEffect:setVisible(isVisible)
        self._arrowEffect:setVisible(isVisible)
    end
    
end

function HeroPanel:updateView()
    
	local data = self.proxy:getHeroInfoWithPos(self.curPos or 1)
	self:initPosData()
    
	self:initView(data)
    self:initPosState() -- 是否可上阵
	local panel = self:getPanel(HeroTeamPanel.NAME)
	if panel:isVisible() then
		panel:initPosView(self.posData)
	end
end

function HeroPanel:getCurPos()
	return self.curPos or 1
end

function HeroPanel:onClosePanel()
	if self.uiHeroPanel ~= nil then
		self.uiHeroPanel:getRootNode():setVisible(false)
        self:showContentEnable(true)
	end
end

--滑动回调，更改curCenterIndex重新initview
function HeroPanel:endCall(sender, value, dir)
    dir = dir * -1
	if dir ~= 0 then
        curCenterIndex = curCenterIndex or 2
        curCenterIndex = curCenterIndex > 4 and 1 or curCenterIndex
        curCenterIndex = curCenterIndex < 1 and 4 or curCenterIndex

        local posArr = self._allPos[curCenterIndex] or self._allPos[1]
        for i=1,4 do
            local panel = self:getChildByName("middlePanel/Panel_97/panel"..i)
            panel:setPositionX(posArr[i])
            panel:setScale(1)
        end
		self:changePosUpdate(dir, true)
	end
end

function HeroPanel:showTeamPanel(sender)
	local panel = self:getPanel(HeroTeamPanel.NAME)
	panel:show(self.posData)
end

function HeroPanel:onJiangJunBtnTouch(sender)

	local parentModule = self.view:getParent().module
	local bool = parentModule:isModuleShow(ModuleName.HeroHallModule)
	if bool == true then
    self.view:dispatchEvent(HeroEvent.HIDE_SELF_EVENT)
	else
		local proxy = self:getProxy(GameProxys.Hero)
		proxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, { moduleName = ModuleName.HeroHallModule, extraMsg = true })
	end
end
------
-- 红点提示：“可上阵”
function HeroPanel:initPosState()
    local unAddDate = self.proxy:getUnAddHero()
    local url = "images/hero/underAdd.png"
    local url1= "images/hero/TxtKeShangZhen.png"
    local soldierProxy = self:getProxy(GameProxys.Soldier)

    for i = 1, #self.items do
        local addTxt = self.items[i]:getChildByName("addTxt")
        local bgImg = self.items[i]:getChildByName("bgImg")
        local ImgKeShangZhen = self.items[i]:getChildByName("ImgKeShangZhen")
        addTxt:setString("")

        if soldierProxy:isTroopsOpen(i) then--是否解锁
            if self.proxy:getHeroInfoWithPos(i) then--是否有英雄站坑
                ImgKeShangZhen:setVisible(false)
                addTxt:setString("")
            else
               -- print("underNum  ".. #unAddDate)
                if #unAddDate > 0 then
                ImgKeShangZhen:setVisible(true)
                TextureManager:updateImageView(ImgKeShangZhen, url1)
                else
                --ImgKeShangZhen:setVisible(false)
                TextureManager:updateImageView(ImgKeShangZhen, url)
                end
            end
        else
            ImgKeShangZhen:setVisible(false)
            addTxt:setString("")
        end

        -- if self.proxy:getHeroInfoWithPos(i) then
        --     ImgKeShangZhen:setVisible(false)
        --     addTxt:setString("")
        -- elseif soldierProxy:isTroopsOpen(i) then
        -- else
        --     ImgKeShangZhen:setVisible(true)
        -- end

        --[[
        -- 判断能不能设置文字，根据未上阵英雄数和位置判断
        if #unAddDate > 0 and self.posData[i] == true then
            if not bgImg.uiIcon then
                -- addTxt:setString(self:getTextWord(290023))
                ImgKeShangZhen:setVisible(true)
            elseif bgImg.uiIcon and bgImg:isVisible() == false then -- 存在且bgimg为隐藏
                -- addTxt:setString(self:getTextWord(290023))
                ImgKeShangZhen:setVisible(true)
            end
        else
            ImgKeShangZhen:setVisible(false)
            addTxt:setString("")
        end
        --]]
    end
end

--滑动回调，更改curCenterIndex重新initview
--如果没移动判断相交，是否显示infopanel
function HeroPanel:movePanel(sender, value, dir)
    if not self._canTouch then
        return
    end
    dir = dir * -1
    curCenterIndex = curCenterIndex + dir
    curCenterIndex = curCenterIndex > 4 and 1 or curCenterIndex
    curCenterIndex = curCenterIndex < 1 and 4 or curCenterIndex
    if dir ~= 0 then
        self._canTouch = false
        self:changePosUpdate(dir)
    else
        local panel = sender
        local size = panel.heroCard:getContentSize()
        local imgHeroCard = panel:getChildByName("imgHeroCard")
        local rect = { }
        rect.x = imgHeroCard:getPositionX() - size.width / 2
        rect.y = imgHeroCard:getPositionY() - size.height / 2
        rect.width = size.width
        rect.height = size.height

        local endPos = panel:getTouchEndPosition()
        endPos = panel:convertToNodeSpace(endPos)
        if cc.rectContainsPoint(rect, endPos) then
            local data = self.proxy:getHeroInfoWithPos(self.curPos) 
            data.curPos=self.curPos
            if data ~= nil then
                local panel = self:getPanel(HeroInfoPanel.NAME)
                panel:show(data)
                --print(data.fightVal)
            end
        end
    end
end

--关闭图鉴模块，刷新一下界面   防止分包导致不刷新的原因
--没有直接调用Initview是因为initview做了太多东西
--基本就是图片更新，lvlab  namelab  stars位置调整
function HeroPanel:updateHeroImg()
    if type(curCenterIndex) == "number" then
        
        local heroData = self.proxy:getHeroInfoWithPos(self.curPos or 1)
        if heroData == nil then
            return
        end

        local fightVal = self.proxy:getHeroFight(self.curPos,{})
        local cardData = { }
        cardData.heroId = heroData.heroId
        cardData.starNum = heroData.heroStar
        cardData.fightting = fightVal
        self._uiHeroCard[curCenterIndex]:updateData(cardData)

    end
end

function HeroPanel:getNextLvExp(data)
    local expKey = {"wexpneed", "gexpneed", "bexpneed", "pexpneed", "oexpneed"}
    local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)
    local nextLv = data.heroLv + 1 > config.lvmax and config.lvmax or data.heroLv
    local levelConfig = ConfigDataManager:getConfigById(ConfigData.HeroLevelConfig, nextLv)
    local key = expKey[config.color]
--    logger:info("当前取的nextLv是："..nextLv)
--    logger:info("当前取的key是："..key)
    local nextLvExp = levelConfig[key]
    return nextLvExp
end


-- 是否可以继续升级(等级限制不可，满级不可)
function HeroPanel:isCanLevelUp(heroLevel, maxLevel)
    local state = true
    local level = self.proxy:getHeroCanImproveLevel()
    
    -- 是否等级限制
    if level ~= nil then
        if level <= heroLevel then
            state = false
        end
    end

    -- 是否满级
    if heroLevel == maxLevel then
        state = false
    end

    return state
end


--对节点下的所有节点,包括自己,全部一起设置透明度
--@param:父节点
--@param:透明度
function HeroPanel:setAllChildrenOpacity(node,opacity_val)
    local children = node:getChildren()
    node:setOpacity(opacity_val)
    for i = 1,#children do 
        local child = children[i]
        self:setAllChildrenOpacity(child,opacity_val)
    end
end

--对节点下的所有节点,包括自己,全部一起加入渐变action
--@param:父节点
--@param:透明度
function HeroPanel:setAllChildrenFadeIn(node,time)
    if node then
        local children = node:getChildren()
        node:runAction(cc.FadeIn:create(time or 1))
        for i = 1,#children do 
            local child = children[i]
            self:setAllChildrenFadeIn(child,opacity_val)
        end
    end
end


