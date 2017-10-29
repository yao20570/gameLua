--进阶
HeroTreaAdvancePanel = class("HeroTreaAdvancePanel", BasicPanel)
HeroTreaAdvancePanel.NAME = "HeroTreaAdvancePanel"

function HeroTreaAdvancePanel:ctor(view, panelName)
    HeroTreaAdvancePanel.super.ctor(self, view, panelName)
    self.advanceSuccess = false --当进阶成功之后设为true
    self.advanceFail = false--当进阶失败之后设为true
    self.isAdvancing = false--正在进阶
end

function HeroTreaAdvancePanel:finalize()
    if self.treasureEffect ~= nil then
        self.treasureEffect:finalize()
        self.treasureEffect = nil
    end
    if self.treasureQianEffect ~= nil then
        self.treasureQianEffect:finalize()
        self.treasureQianEffect = nil
    end
    HeroTreaAdvancePanel.super.finalize(self)
end

function HeroTreaAdvancePanel:initPanel()
	HeroTreaAdvancePanel.super.initPanel(self)
	self.proxy = self:getProxy(GameProxys.HeroTreasure)

    --宝具名称图
	self._treasureNameImg = self:getChildByName("topPanel/treasureNameImg")
    --宝具颜色图
	self._treasureColorImg = self:getChildByName("topPanel/treasureColorImg")
    --宝具阶级
	self._treasureStageNumImg = self:getChildByName("topPanel/stageNumImg")
    --宝具图标
	self._treasureImg = self:getChildByName("topPanel/treasureImg/img")
    --宝具图标特效节点
    self._treasureEffectNode = self:getChildByName("topPanel/treasureImg/effectNode")
    self._treasureImgPanel = self:getChildByName("topPanel/treasureImg")
    --基础属性
    for i=1,3 do
		self["_basalAttImg" .. i] = self:getChildByName("bottomPanel/middlePanel/infoPanel/basalAttPanel/basalAttPanel".. i .."/iconImg/img")
		self["_basalAttNameLab" .. i] = self:getChildByName("bottomPanel/middlePanel/infoPanel/basalAttPanel/basalAttPanel".. i .."/descLab")
		self["_basalAttNumLab" .. i] = self:getChildByName("bottomPanel/middlePanel/infoPanel/basalAttPanel/basalAttPanel".. i .."/addLab")
		self["_basalAttNumAddLab" .. i] = self:getChildByName("bottomPanel/middlePanel/infoPanel/basalAttPanel/basalAttPanel".. i .."/otherLab")
	end
    for i=1,3 do
		self["_basalAttPanel" .. i] = self:getChildByName("bottomPanel/middlePanel/infoPanel/basalAttPanel/basalAttPanel".. i)
	end
	--洗炼属性说明
	self._highAttAddDescLab = self:getChildByName("bottomPanel/middlePanel/infoPanel/descriptionLab")
	--进阶消耗材料
    for i=1,3 do
		self["_material" .. i] = self:getChildByName("bottomPanel/middlePanel/materialPanel/materialImg".. i)
	end
    --祝福进度条
    self._wishBar = self:getChildByName("bottomPanel/middlePanel/infoPanel/wishPanel/wishBarBgImg/wishBar")
    self._wishBarExpLab = self:getChildByName("bottomPanel/middlePanel/infoPanel/wishPanel/wishBarBgImg/expLab")
    self._fullImg = self:getChildByName("bottomPanel/middlePanel/infoPanel/wishPanel/fullImg")
    --按钮
    self._autoAdvanceBtn = self:getChildByName("bottomPanel/autoAdvanceBtn")
    self._advanceOnceBtn = self:getChildByName("bottomPanel/advanceOnceBtn")
    self:addTouchEventListener(self._autoAdvanceBtn, self.autoAdvanceBtnHandler)
    self:addTouchEventListener(self._advanceOnceBtn, self.advanceOnceBtnHandler)
        --武器与坐骑偏移不一
    self._treasureImgYOffset = {400,350}
    --特效
    self.allJianEffectName = {"rgb-jianlv-hou", "rgb-jianlan-hou", "rgb-jianzi-hou", "rgb-jianhuang-hou"}
    self.allMaEffectName = {"rgb-malv-hou", "rgb-malan-hou", "rgb-mazi-hou", "rgb-mahuang-hou"}
    self.allJianQianEffectName = {"rgb-jianlv-qian", "rgb-jianlan-qian", "rgb-jianzi-qian", "rgb-jianhuang-qian"}
    self.allMaQianEffectName = {"rgb-malv-qian", "rgb-malan-qian", "rgb-mazi-qian", "rgb-mahuang-qian"}
end
function HeroTreaAdvancePanel:doLayout()
    local topPanel = self:getChildByName("topPanel")
    local downPanel = self:getChildByName("downPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(topPanel, nil, downPanel, tabsPanel)
end
function HeroTreaAdvancePanel:onShowHandler()
    self.advanceSuccess = false
    self.advanceFail = false
    self.isAdvancing = false
    self:updateView()
end
--界面刷新
function HeroTreaAdvancePanel:updateView(data)

    self.treasureData = data or self.view:getCurTreasureData()
    local config = ConfigDataManager:getConfigById(ConfigData.TreasureBaseConfig, self.treasureData.typeid)


    local  treasureNameImgUrl = self.proxy:getTreasureNameImgUrl(self.treasureData.typeid)
    TextureManager:updateImageView(self._treasureNameImg, treasureNameImgUrl)

    local  colorImgUrl = self.proxy:getTreasureColorImgUrl(self.treasureData.typeid)
    TextureManager:updateImageView(self._treasureColorImg, colorImgUrl)

    local  stageNumImgUrl = self.proxy:getTreasureStageNumImgUrl(self.treasureData.id)
    TextureManager:updateImageView(self._treasureStageNumImg, stageNumImgUrl)

    local  treasureImgUrl = self.proxy:getTreasureImgUrl(self.treasureData.typeid)
    TextureManager:updateImageView(self._treasureImg, treasureImgUrl)

    local postInfo = self.proxy:getPostInfoByTreasureDbID(self.treasureData.id)



    --基础属性
    for i=1,3 do
		self["_basalAttPanel" .. i]:setVisible(false)
	end
    local addInfo = self.proxy:getBasalAttInfoByTreasureDbID(self.treasureData.id)
    local rateInfo = StringUtils:jsonDecode(config.rate)
    for k,v in pairs(addInfo) do
        local nameInfo = ConfigDataManager:getConfigById(ConfigData.ResourceConfig, v[1])
        self["_basalAttNameLab" .. k]:setString(nameInfo.name)
        self["_basalAttNumLab" .. k]:setString("+" .. self.proxy:handleBasalAttNum(v))
        TextureManager:updateImageView(self["_basalAttImg" .. k], self.proxy:getBasalAttImgUrl(nameInfo.ID))
        self["_basalAttNumAddLab" .. k]:setString("+" .. self.proxy:handleBasalAttNum(rateInfo[k]))
        self["_basalAttNumAddLab" .. k]:setVisible(true)
        self["_basalAttPanel" .. k]:setVisible(true)
        --调整属性增益与进阶后增益的位置
        local x = self["_basalAttNumLab" .. k]:getPositionX()
        local width = self["_basalAttNumLab" .. k]:getContentSize().width
        self["_basalAttNumAddLab" .. k]:setPositionX(x+width)
    end
    --洗炼属性
    if self.advanceSuccess == true then
        self.oldRank = self.rank
    end

    self.rank = postInfo.treasurePostLevelInfo.level + 1
    local mnLab = self:getChildByName("bottomPanel/middlePanel/materialPanel/needLab")
    if self.rank > 10 then
        mnLab:setVisible(false)
        --self._fullImg:setVisible(false)
        if self.oldRank then
            self._fullImg:setVisible(false)
        else
            self._fullImg:setVisible(true)
        end
        self._highAttAddDescLab:setString("")
        self._wishBar:setPercent(0)
        self._wishBarExpLab:setString("")
        for k=1,3 do
    		self["_material" .. k]:setVisible(false)
            self["_basalAttNumAddLab" .. k]:setVisible(false)
    	end
        if self.rank == 11 then
            local advanceInfo = ConfigDataManager:getInfoFindByTwoKey(ConfigData.TreasureClassConfig, "treasurePart",config.part,"rank",10)
            self._highAttAddDescLab:setString("提升当前洗练属性" .. advanceInfo.lvrate .. "%")
        end
        if self.advanceSuccess == true then
            --进阶成功存下原来的祝福值用于特效
            self.oldWishNum  = self.wishNum
            self.oldWishAll = self.wishAll
            self.oldPercentNum = self.wishNum/self.wishAll
        end

    else
        mnLab:setVisible(true)
        self._fullImg:setVisible(false)
        local advanceInfo = ConfigDataManager:getInfoFindByTwoKey(ConfigData.TreasureClassConfig, "treasurePart",config.part,"rank",self.rank)

        self._highAttAddDescLab:setString("升阶后提升当前洗练属性" .. advanceInfo.lvrate .. "%")
    
        if self.advanceSuccess == true then
            --进阶成功存下原来的祝福值用于特效
            self.oldWishNum  = self.wishNum
            self.oldWishAll = self.wishAll
            self.oldPercentNum = self.wishNum/self.wishAll
        end
        --祝福值
        self.wishNum = postInfo.treasurePostWishInfo.wish
        self.wishAll = advanceInfo.fullblessing
        self.percentNum = self.wishNum/self.wishAll
        if self.advanceSuccess == true then
        else
            self._wishBar:setPercent(self.percentNum*100)
            self._wishBarExpLab:setString(self.wishNum .. "/" .. self.wishAll)
        end

        if self.advanceFail == true then
            local function failComplete()
                self.isAdvancing = false
                --self._fullImg:setVisible(true)
            end

            local wishBarTopImg = self:getChildByName("bottomPanel/middlePanel/infoPanel/wishPanel/wishBarBgImg/Panel_64")
            local wishBarTopImgSize = wishBarTopImg:getContentSize()
            local aEffect = UICCBLayer.new("rgb-bj-jinjiezhufu", wishBarTopImg, nil,failComplete, true)
            aEffect:setPosition(wishBarTopImgSize.width*self.wishNum/self.wishAll, wishBarTopImgSize.height*0.45)
            aEffect:setLocalZOrder(10)
        end
        self.advanceFail = false


        --材料
        for k=1,3 do
		    self["_material" .. k]:setVisible(false)
	    end
        local materialDataTable = StringUtils:jsonDecode(advanceInfo.useprops)
	    local roleProxy = self:getProxy(GameProxys.Role)
	    for i=1,#materialDataTable do
		    local haveNum =  roleProxy:getRolePowerValue(materialDataTable[i][1], materialDataTable[i][2])
		    self:renderChild(self["_material" .. i], haveNum, materialDataTable[i][3])
		    local iconData = {}
		    iconData.typeid = materialDataTable[i][2]
		    iconData.num = materialDataTable[i][3]
		    iconData.power = materialDataTable[i][1]
		    if self["_material" .. i].uiIcon == nil then
			    self["_material" .. i].uiIcon = UIIcon.new(self["_material" .. i], iconData, false, self, nil, true)
		    else
			    self["_material" .. i].uiIcon:updateData(iconData)
		    end
            self["_material" .. i]:setVisible(true)
	    end
    end
    if self.treasureEffect ~= nil then
        self.treasureEffect:finalize()
        self.treasureEffect = nil
    end
    if self.treasureQianEffect ~= nil then
        self.treasureQianEffect:finalize()
        self.treasureQianEffect = nil
    end
    local color = config.color or 1
    if self.treasureData.part == 0 then
        self._treasureImgPanel:setPositionY(self._treasureImgYOffset[1])  
        --剑需要浮动动画
        self:playAction("jian_fudong")
        if color > 1 then
            self.treasureEffect = UICCBLayer.new(self.allJianEffectName[color-1], self._treasureEffectNode)
            local size = self._treasureImg:getContentSize()
            self.treasureEffect:setPosition(0, size.height*0.5)
            self.treasureQianEffect = UICCBLayer.new(self.allJianQianEffectName[color-1], self._treasureImgPanel)
            self.treasureQianEffect:setPosition(0, size.height*0.5)
            
        end
    else
        self:stopAction("jian_fudong")
        self._treasureImgPanel:setPositionY(self._treasureImgYOffset[2])  
        if color > 1 then
            self.treasureEffect = UICCBLayer.new(self.allMaEffectName[color-1], self._treasureEffectNode)
            local size = self._treasureImg:getContentSize()
            self.treasureEffect:setPosition(size.width*0.1, size.height*0.2)
            self.treasureQianEffect = UICCBLayer.new(self.allMaQianEffectName[color-1], self._treasureImgPanel)
            self.treasureQianEffect:setPosition(0, size.height*0.2)
        end
    end
    local function handler()
        local function delayTest()
            self.autoAdvanceTime = self.autoAdvanceTime - 1
            --print("delayTest!!")
            --祝福值
            self.oldWishNum = self.oldWishNum + 1
            self.oldWishNum = self.oldWishNum > self.oldWishAll and self.oldWishAll or self.oldWishNum
            self.oldPercentNum = self.oldWishNum/self.oldWishAll
            self._wishBar:setPercent(self.oldPercentNum*100)
            self._wishBarExpLab:setString(self.oldWishNum .. "/" .. self.oldWishAll)
            if self.autoAdvanceTime <= 0 then
                self.isAdvancing = false
                local function zhufuComplete()
                    if self.rank < 11 then
                        self._wishBar:setPercent(0)
                        self._wishBarExpLab:setString(0 .. "/" .. self.wishAll)
                    else
                        self._fullImg:setVisible(true)
                        self._wishBar:setPercent(0)
                        self._wishBarExpLab:setString("")
                        self.oldRank = nil
                    end
                end
                --祝福条特效
                local wishBarTopImg = self:getChildByName("bottomPanel/middlePanel/infoPanel/wishPanel/wishBarBgImg/Panel_64")
                local wishBarTopImgSize = wishBarTopImg:getContentSize()
                local aaEffect = UICCBLayer.new("rgb-bj-jinjiezhufu", wishBarTopImg, nil,zhufuComplete, true)
                aaEffect:setPosition(wishBarTopImgSize.width*self.oldWishNum/self.oldWishAll, wishBarTopImgSize.height*0.45)
                aaEffect:setLocalZOrder(10)
                --进阶特效
                local size = self._treasureImg:getContentSize()
                if self.treasureData.part == 0 then
                    local function complete()
                        EffectQueueManager:completeEffect()
                        --self.isAdvancing = false
                        --self._wishBar:setPercent(0)
                        --self._wishBarExpLab:setString(0 .. "/" .. self.wishAll)
                    end
                    local aEffect = UICCBLayer.new("rgb-bj-jinjiejian", self._treasureImgPanel, nil,complete, true)
                    aEffect:setPosition(size.width*0, -size.height*0.1)
                    aEffect:setLocalZOrder(10)
                else
                    local function complete()
                        EffectQueueManager:completeEffect()
                        --self.isAdvancing = false
                        --self._wishBar:setPercent(0)
                        --self._wishBarExpLab:setString(0 .. "/" .. self.wishAll)
                    end
                    local aEffect = UICCBLayer.new("rgb-bj-jinjiema", self._treasureImgPanel, nil,complete, true)
                    aEffect:setPosition(size.width*0.08, size.height*0.1)
                    aEffect:setLocalZOrder(10)
                end

                TimerManager:remove(delayTest, self)
            end
        end

        TimerManager:add(20, delayTest, self)



        
    end
    if self.advanceSuccess == true then

        EffectQueueManager:addEffect(EffectQueueType.TREASURE_ADVANCE, handler,nil,false)

    end

    self.advanceSuccess = false


end

function HeroTreaAdvancePanel:autoAdvanceBtnHandler(sender)
	--print("autoAdvanceBtnHandler")

    if self.isAdvancing == true then
        self:showSysMessage(self:getTextWord(3823))
    else
        self.isAdvancing = true
        local sendData = {}
        sendData.postId = self.treasureData.postId
        sendData.treasurePostId = self.treasureData.part
        sendData.typeId = 0
        self.proxy:getHeroProxy():onTriggerNet300006Req(sendData)
        
    end

end
function HeroTreaAdvancePanel:advanceOnceBtnHandler(sender)
	--print("advanceOnceBtnHandler")
    if self.isAdvancing == true then
        self:showSysMessage(self:getTextWord(3823))
    else
        self.isAdvancing = true
        local sendData = {}
        sendData.postId = self.treasureData.postId
        sendData.treasurePostId =  self.treasureData.part
        sendData.typeId = 1
        self.proxy:getHeroProxy():onTriggerNet300006Req(sendData)
    end
    
end

function HeroTreaAdvancePanel:registerEvents()
	HeroTreaAdvancePanel.super.registerEvents(self)
end
function HeroTreaAdvancePanel:renderChild(item, haveNum, needNum)
	local haveLab = item:getChildByName("haveLab")
	local needLab = item:getChildByName("needLab")
	local color = haveNum >= needNum and cc.c3b(0, 255, 0) or cc.c3b(255, 0, 0)
	haveLab:setColor(color)
	haveLab:setString(haveNum)
	needLab:setString("/" .. needNum)
end

function HeroTreaAdvancePanel:advanceSuccessHandler(time)
    self.advanceSuccess = true
    self.advanceFail = false
    local config = ConfigDataManager:getConfigById(ConfigData.TreasureBaseConfig, self.treasureData.typeid)
    local postInfo = self.proxy:getPostInfoByTreasureDbID(self.treasureData.id)
    local rank = postInfo.treasurePostLevelInfo.level
    local advanceInfo2 = ConfigDataManager:getInfoFindByTwoKey(ConfigData.TreasureClassConfig, "treasurePart",config.part,"rank",rank+1)
    self.autoAdvanceTime = advanceInfo2.fallrate*time
    local offsetNum = self.wishAll  - self.wishNum
    self.autoAdvanceTime = self.autoAdvanceTime > offsetNum and offsetNum or self.autoAdvanceTime
end
function HeroTreaAdvancePanel:advanceFailHandler(data)
    if data.rs == -3 then
        --进阶失败
        self.advanceSuccess = false
        self.advanceFail = true
        if data.time then
            local config = ConfigDataManager:getConfigById(ConfigData.TreasureBaseConfig, self.treasureData.typeid)
            local postInfo = self.proxy:getPostInfoByTreasureDbID(self.treasureData.id)
            local rank = postInfo.treasurePostLevelInfo.level
            local advanceInfo2 = ConfigDataManager:getInfoFindByTwoKey(ConfigData.TreasureClassConfig, "treasurePart",config.part,"rank",rank+1)
            self.autoAdvanceTime = advanceInfo2.fallrate*data.time  
        end
        
    elseif data.rs == -4 then
        --材料不足
        self.isAdvancing = false
        self.advanceSuccess = false
        self.advanceFail = true
        if data.time then
            local config = ConfigDataManager:getConfigById(ConfigData.TreasureBaseConfig, self.treasureData.typeid)
            local postInfo = self.proxy:getPostInfoByTreasureDbID(self.treasureData.id)
            local rank = postInfo.treasurePostLevelInfo.level
            local advanceInfo2 = ConfigDataManager:getInfoFindByTwoKey(ConfigData.TreasureClassConfig, "treasurePart",config.part,"rank",rank+1)
            self.autoAdvanceTime = advanceInfo2.fallrate*data.time  
        end
    else
        --满阶，或者宝具不存在
        self.isAdvancing = false
    end

end