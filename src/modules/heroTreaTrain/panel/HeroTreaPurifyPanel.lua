--洗炼
HeroTreaPurifyPanel = class("HeroTreaPurifyPanel", BasicPanel)
HeroTreaPurifyPanel.NAME = "HeroTreaPurifyPanel"

function HeroTreaPurifyPanel:ctor(view, panelName)
    HeroTreaPurifyPanel.super.ctor(self, view, panelName)
    self.effectTime = 0.25

end

function HeroTreaPurifyPanel:finalize()
    if self.treasureEffect ~= nil then
        self.treasureEffect:finalize()
        self.treasureEffect = nil
    end
    if self.treasureQianEffect ~= nil then
        self.treasureQianEffect:finalize()
        self.treasureQianEffect = nil
    end
    if self.uITreasureSelect then
    	self.uITreasureSelect:removeFromParent()
    	self.uITreasureSelect = nil
    end
    HeroTreaPurifyPanel.super.finalize(self)
end

function HeroTreaPurifyPanel:initPanel()
    HeroTreaPurifyPanel.super.initPanel(self)
	self.proxy = self:getProxy(GameProxys.HeroTreasure)

    --宝具名称图
	self._treasureNameImg = self:getChildByName("topPanel/infoPanel/treasureNameImg")
    --宝具颜色图
	self._treasureColorImg = self:getChildByName("topPanel/infoPanel/treasureColorImg")
    --宝具阶级
	self._treasureStageNumImg = self:getChildByName("topPanel/infoPanel/stageNumImg")
    --宝具图标
	self._treasureImg = self:getChildByName("topPanel/infoPanel/treasureImg/img")
    --宝具图标特效节点
    self._treasureEffectNode = self:getChildByName("topPanel/infoPanel/treasureImg/effectNode")
    self._treasureImgPanel = self:getChildByName("topPanel/infoPanel/treasureImg")
    --洗炼属性
    for i=1,4 do
        self["_highAttPanel" .. i] = self:getChildByName("topPanel/highAttPanel/highAttPanel".. i)
		self["_highAttImg" .. i] = self:getChildByName("topPanel/highAttPanel/highAttPanel".. i .."/iconImg/img")
		self["_highAttEffectNameLab" .. i] = self:getChildByName("topPanel/highAttPanel/highAttPanel".. i .."/effectLab")
		self["_highAttlevelLab" .. i] = self:getChildByName("topPanel/highAttPanel/highAttPanel".. i .."/levelLab")
        self["_highAttNumLab" .. i] = self:getChildByName("topPanel/highAttPanel/highAttPanel".. i .."/numLab")
        self["_highAttNumPlusLab" .. i] = self:getChildByName("topPanel/highAttPanel/highAttPanel".. i .."/numPlusLab")
	end
    self.highAttPanel = self:getChildByName("topPanel/highAttPanel")
    --今天已经洗炼次数
	self._fullTimeLab = self:getChildByName("bottomPanel/timeTodayLab")
    --普通洗炼按钮
    local normalPurifyBtn = self:getChildByName("bottomPanel/bgImg/normalPurifyBtn")
    self:addTouchEventListener(normalPurifyBtn, self.normalPurifyBtnHandler)
    self._normalPurifyNeedNum =  self:getChildByName("bottomPanel/consumePanel1/numLab")
    --至尊洗炼按钮
   	self.luxuryPurifyBtn = self:getChildByName("bottomPanel/bgImg/luxuryPurifyBtn")
    self:addTouchEventListener(self.luxuryPurifyBtn, self.luxuryPurifyBtnHandler)
    self.luxuryPurifyBtn.needNum = 0
    self._luxuryPurifyNeedNum =  self:getChildByName("bottomPanel/consumePanel2/numLab")
    --恢复按钮
   	local restoreBtn = self:getChildByName("topPanel/restoreBtn")
    self:addTouchEventListener(restoreBtn, self.restoreBtnHandler)
        --武器与坐骑偏移不一
    self._treasureImgYOffset = {130,40}
    --特效
    self.allJianEffectName = {"rgb-jianlv-hou", "rgb-jianlan-hou", "rgb-jianzi-hou", "rgb-jianhuang-hou"}
    self.allMaEffectName = {"rgb-malv-hou", "rgb-malan-hou", "rgb-mazi-hou", "rgb-mahuang-hou"}
    self.allJianQianEffectName = {"rgb-jianlv-qian", "rgb-jianlan-qian", "rgb-jianzi-qian", "rgb-jianhuang-qian"}
    self.allMaQianEffectName = {"rgb-malv-qian", "rgb-malan-qian", "rgb-mazi-qian", "rgb-mahuang-qian"}

end
function HeroTreaPurifyPanel:doLayout()
    local topPanel = self:getChildByName("topPanel")
    local downPanel = self:getChildByName("downPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(topPanel, nil, downPanel, tabsPanel)
end
function HeroTreaPurifyPanel:onShowHandler(data)
    self:updateView(data)
end
--界面刷新
function HeroTreaPurifyPanel:updateView(data)
    --洗炼后要存下旧的数据对比新数据给属性变化的特效
    if self.havePurify == true then
       self.oldData =  self.treasureData
    end
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

    --洗炼属性
    local function updateHighAtt(data)
        local purifyNum = #data.baseInfo
        local lockImg = self:getChildByName("topPanel/highAttPanel/highAttPanel4Lock")
        if purifyNum == 3 then
            lockImg:setVisible(true)
        else
            lockImg:setVisible(false)
        end
    
        for i=1,4 do
            self["_highAttPanel" .. i]:setVisible(false)
	    end
        local maxLevel = 0 
        for k,v in pairs(data.baseInfo) do
            local nameInfo = ConfigDataManager:getConfigById(ConfigData.TreasureEnchantConfig, v.typeid)
            self["_highAttPanel" .. k]:setVisible(true)
            self["_highAttEffectNameLab" .. k]:setString(nameInfo.name)
            if v.level == 10 then
                self["_highAttlevelLab" .. k]:setString("满级")
                else
                self["_highAttlevelLab" .. k]:setString(v.level .. "级")
            end
            maxLevel = maxLevel > v.level and maxLevel or v.level
            local numTable = self.proxy:getHighAttInfoByBaseInfo(v)
            self["_highAttNumLab" .. k]:setString("+" .. self.proxy:handleBasalAttNum(numTable))
            --进阶属性的加成百分比显示--begin--

            local postInfo = self.proxy:getPostInfoByTreasureDbID(self.treasureData.id)
            local rank = postInfo.treasurePostLevelInfo.level
            if rank > 0 then
                local advanceInfo = ConfigDataManager:getInfoFindByTwoKey(ConfigData.TreasureClassConfig, "treasurePart",config.part,"rank",rank)
                local advanceAddNumStr = self.proxy:handleBasalAttNumWithPercent(numTable,advanceInfo.lvrate)
                self["_highAttNumPlusLab" .. k]:setString("+" .. advanceAddNumStr .. self:getTextWord(3822))
                else
                self["_highAttNumPlusLab" .. k]:setString("+0" .. self:getTextWord(3822))
            end
                    --调整属性增益与进阶后增益的位置
            local x = self["_highAttNumLab" .. k]:getPositionX()
            local width = self["_highAttNumLab" .. k]:getContentSize().width
            self["_highAttNumPlusLab" .. k]:setPositionX(x+width)

            
            --进阶属性的加成百分比显示--end---
            TextureManager:updateImageView(self["_highAttImg" .. k], self.proxy:getHighAttImgUrl(nameInfo.ID))
        end
        maxLevel = maxLevel == 10 and 10 or maxLevel+1
        local configs = ConfigDataManager:getConfigById(ConfigData.TreasureSophisticationConfig, maxLevel)
        local normalPurifyNeedNum = StringUtils:jsonDecode(configs.freePrice)[1][3]
        self._normalPurifyNeedNum:setString(StringUtils:formatNumberByK3(normalPurifyNeedNum))
	end

    --材料
    --self._fullTimeLab:setString(self.treasureData.washTime .. "次")
    --local normalPurifyNeedNum = self.proxy:getOnePurifyPrice().freePrice*(self.treasureData.washTime+1)

    self._luxuryPurifyNeedNum:setString(self.proxy:getOnePurifyPrice().payprice)
    self.luxuryPurifyBtn.needNum = self.proxy:getOnePurifyPrice().payprice

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
        --剑需要浮动动画
        self:playAction("jian_fudong")
        self._treasureImgPanel:setScale(0.7)
        self._treasureImgPanel:setPositionY(self._treasureImgYOffset[1])  
        if color > 1 then
            self.treasureEffect = UICCBLayer.new(self.allJianEffectName[color-1], self._treasureEffectNode)
            local size = self._treasureImg:getContentSize()
            self.treasureEffect:setPosition(0, size.height*0.5)
            self.treasureQianEffect = UICCBLayer.new(self.allJianQianEffectName[color-1], self._treasureImgPanel)
            self.treasureQianEffect:setPosition(0, size.height*0.5)
            
        end

    else
        self:stopAction("jian_fudong")
        self._treasureImgPanel:setScale(0.9)
        self._treasureImgPanel:setPositionY(self._treasureImgYOffset[2])  
        if color > 1 then
            self.treasureEffect = UICCBLayer.new(self.allMaEffectName[color-1], self._treasureEffectNode)
            local size = self._treasureImg:getContentSize()
            self.treasureEffect:setPosition(size.width*0.1, size.height*0.2)
            self.treasureQianEffect = UICCBLayer.new(self.allMaQianEffectName[color-1], self._treasureImgPanel)
            self.treasureQianEffect:setPosition(0, size.height*0.2)
        end
    end
    --获取洗炼属性升级切换状态
    local function getUpdateAndChangeTable(oldData,newData)
        local updateState = {}
        for i=1,4 do
            if newData.baseInfo[i] == nil and oldData.baseInfo[i] == nil then
                updateState[i] = false
            elseif newData.baseInfo[i] ~= nil and oldData.baseInfo[i] ~= nil then
                if newData.baseInfo[i].level ~=  oldData.baseInfo[i].level then
                    updateState[i] = true
                else
                    updateState[i] = false
                end
            else
                updateState[i] = false
            end
        end
        local changeState = {}
        for i=1,4 do
            if newData.baseInfo[i] == nil and oldData.baseInfo[i] == nil then
                    changeState[i] = false
                elseif newData.baseInfo[i] ~= nil and oldData.baseInfo[i] ~= nil then
                    if newData.baseInfo[i].typeid ==  oldData.baseInfo[i].typeid then
                        if newData.baseInfo[i].level ==  oldData.baseInfo[i].level then
                            changeState[i] = false
                            else
                            changeState[i] = true
                        end
                        else
                            changeState[i] = true
                    end
                else
                    changeState[i] = true
            end
        end
        return updateState,changeState
    end

    
    local function effectFunc(effectState)
        for i=1,4 do
            if effectState[i] == 1 then
                local size = self["_highAttPanel" .. i]:getContentSize()
                local x, y = self["_highAttPanel" .. i]:getPosition()
                local aEffect = UICCBLayer.new("rgb-bj-xilianshengji", self.highAttPanel, nil, nil, true)
                aEffect:setPosition(x+size.width/2, y+size.height*0.65)
                aEffect:setLocalZOrder(10)
            elseif effectState[i] == 2 then
                local size = self["_highAttPanel" .. i]:getContentSize()
                local x, y = self["_highAttPanel" .. i]:getPosition()
                local aEffect = UICCBLayer.new("rgb-bj-xilianqiehuan", self.highAttPanel, nil, nil, true)
                aEffect:setPosition(x+size.width/2, y+size.height*0.65)
                aEffect:setLocalZOrder(10)
            end
        end
    end
    if self.havePurify == true then
        -- updateHighAtt(self.oldData)
        local delayTime = 0.5
        local updateState,changeState = getUpdateAndChangeTable(self.oldData,self.treasureData)
        local effectState = {}
        -- 0没有特效 1升级特效 2切换特效
        for i=1,4 do
            if changeState[i] == true then
                effectState[i] = 2
                if updateState[i] == true then
                    effectState[i] = 1
                end
            else
                effectState[i] = 0
            end
        end
	    local act = cc.Sequence:create(
            cc.CallFunc:create(function ()
                effectFunc(effectState)
            end),
            cc.DelayTime:create(delayTime),
		    cc.CallFunc:create(function ()
                updateHighAtt(self.treasureData)
            end)
            )
	    self._skin:runAction(act)
    else
        updateHighAtt(self.treasureData)
    end

    self.havePurify = false
    self.oldData = nil
end
function HeroTreaPurifyPanel:normalPurifyBtnHandler(sender)
    if self.playing then
        self:showSysMessage(self:getTextWord(3813))
    else
        local sendData = {}
        sendData.treasuredId = self.treasureData.id
        sendData.type =  0
        self.proxy:onTriggerNet350001Req(sendData)
    end

end
function HeroTreaPurifyPanel:purifySuccess()
    self.havePurify = true

    local function handler()
        local size = self._treasureImg:getContentSize()
        local infoPanel = self:getChildByName("topPanel/infoPanel")
        local x, y = self._treasureImgPanel:getPosition()
        local size = self._treasureImg:getContentSize()
        local function complete()
             self.playing = nil
             EffectQueueManager:completeEffect()
        end
        if self.treasureData.part == 0 then
            local mainEffect = UICCBLayer.new("rgb-bjjian-xilian", infoPanel, nil, complete, true)
            mainEffect:setPosition(x, y+size.height*0.35)
            mainEffect:setLocalZOrder(10)
            --self.playing = ""
        else
            local mainEffect = UICCBLayer.new("rgb-bjma-xilian", infoPanel, nil,complete, true)
            mainEffect:setPosition(x, y+size.height*0.5)
            mainEffect:setLocalZOrder(10)
            --self.playing = ""
        end
    end
    EffectQueueManager:addEffect(EffectQueueType.TREASURE_ADVANCE, handler,nil,false)


end
function HeroTreaPurifyPanel:luxuryPurifyBtnHandler(sender)

    if self.playing then
        self:showSysMessage(self:getTextWord(3813))
    else
        --
        local roleProxy = self:getProxy(GameProxys.Role)
        local curNum = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝
        if sender.needNum > curNum then
            local parent = self:getParent()
            local panel = parent.panel
            if panel == nil then
                local panel = UIRecharge.new(parent, self)
                parent.panel = panel
            else
                panel:show()
            end
        else
            local sendData = {}
            sendData.treasuredId = self.treasureData.id
            sendData.type =  1
            self.proxy:onTriggerNet350001Req(sendData)
        end  
    end
end
function HeroTreaPurifyPanel:restoreBtnHandler(sender)
   --最优四条属性信息
    self.bestInfos = nil
    self.bestInfos = self.proxy:packBestInfos(self.treasureData.bestInfos)
    if #self.bestInfos > 0 then
    	if not self.uITreasureSelect then
		    self.uITreasureSelect = UITreasureSelect.new(self.parent, self, true,self.selectHandler)
	    end
        self.uITreasureSelect:show(self.bestInfos)
       else
        self:showSysMessage(self:getTextWord(3811))

    end

    -- local sendData = {}
    -- sendData.treasuredId = self.treasureData.id
    -- sendData.bestId = 1
    -- self.proxy:onTriggerNet350002Req(sendData)
end
function HeroTreaPurifyPanel:selectHandler(num)
    --print("selectHandler")
    if num then

        local sendData = {}
        sendData.treasuredId = self.treasureData.id
        sendData.bestId = num
        self.proxy:onTriggerNet350002Req(sendData)
        else
        --self:showSysMessage(self:getTextWord(3812))
    end
end





function HeroTreaPurifyPanel:registerEvents()
    HeroTreaPurifyPanel.super.registerEvents(self)
end