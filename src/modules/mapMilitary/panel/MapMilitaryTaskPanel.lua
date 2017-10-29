-- /**
--  * @Author:
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description:
--  */
MapMilitaryTaskPanel = class("MapMilitaryTaskPanel", BasicPanel)
MapMilitaryTaskPanel.NAME = "MapMilitaryTaskPanel"

local UrlTimesSprite = { }
UrlTimesSprite[1] = "images/mapMilitary/SpTimes1.png"
UrlTimesSprite[2] = "images/mapMilitary/SpTimes2.png"
UrlTimesSprite[3] = "images/mapMilitary/SpTimes3.png"
UrlTimesSprite[4] = "images/mapMilitary/SpTimes4.png"
UrlTimesSprite[5] = "images/mapMilitary/SpTimes5.png"

function MapMilitaryTaskPanel:ctor(view, panelName)
    MapMilitaryTaskPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function MapMilitaryTaskPanel:finalize()
    if self._ccbXiang ~= nil then
        self._ccbXiang:finalize()
        self._ccbXiang = nil
    end

    if self._ccbProgress ~= nil then
        self._ccbProgress:finalize()
        self._ccbProgress = nil
    end

    if self._ccbDianji ~= nil then
        self._ccbDianji:finalize()
        self._ccbDianji = nil
    end

    if self._ccbBaoji ~= nil then
        self._ccbBaoji:finalize()
        self._ccbBaoji = nil
    end

    if self._panelMain ~= nil then
        self._panelMain:unscheduleUpdate()
        self._panelMain = nil
    end

    if self._ccbDot ~= nil then
        for _, l in pairs(self._ccbDot) do
            if l ~= nil then
                for k, v in pairs(l) do
                    if v ~= nil then
                        v:finalize()
                        l[k] = nil
                    end
                end
            end
        end
        self._ccbDot = nil
    end

    MapMilitaryTaskPanel.super.finalize(self)
end

function MapMilitaryTaskPanel:initPanel()
    MapMilitaryTaskPanel.super.initPanel(self)

    self:setIsShowAndHideAction(false)
    
    self._proxy = self:getProxy(GameProxys.MapMilitary)
    self._roleProxy = self:getProxy(GameProxys.Role)

    self._awardGroup = {}

    self._panelMain = self:getChildByName("panelMain")

    self._txtMilityry = self._panelMain:getChildByName("txtMilityry")
    self._btnReset = self._panelMain:getChildByName("btnReset")

    -- ��������
    self._panelProgress = self._panelMain:getChildByName("panelProgress")
    self._progressBar = self._panelProgress:getChildByName("progressBar")
    self._imgProgressBg = self._panelProgress:getChildByName("imgProgressBg")
    self._boxNodeClone = self._panelProgress:getChildByName("imgNode")
    self._boxNodeClone:setVisible(false)
    if self._ccbProgress == nil then
        self._ccbProgress = self:createUICCBLayer("rgb-jdt-lv", self._panelProgress)
        self._ccbProgress.initPosX = self._progressBar:getPositionX() - self._progressBar:getContentSize().width / 2
        self._ccbProgress:setPositionX(self._ccbProgress.initPosX)
        self._ccbProgress:setPositionY(self._progressBar:getPositionY())
        self._ccbProgress:setLocalZOrder(3)
    end


    local panelInfo = self._panelMain:getChildByName("panelInfo")
    local imgInfoBg = panelInfo:getChildByName("imgInfoBg")
    local txtTip2 = panelInfo:getChildByName("txtTip2")
    self._txtTip1 = panelInfo:getChildByName("txtTip1")
    TextureManager:updateImageViewFile(imgInfoBg, "bg/mapMilitary/mapMilitaryPanelBg.png")
    txtTip2:setString(self:getTextWord(540001))


    -- ������Ч����
    self._imgCCBNode = self._panelMain:getChildByName("imgCCBNode")
    local size = self._imgCCBNode:getContentSize()
    if self._ccbXiang == nil then
        self._ccbXiang = self:createUICCBLayer("rgb-jg-xiang", self._imgCCBNode)
        self._ccbXiang:setPosition(size.width / 2, size.height / 2)
    end
    self._fontNum = self._imgCCBNode:getChildByName("fontNum")

    --5����
    self._fiveChoose = self._imgCCBNode:getChildByName("fiveCheck")
    self._fiveChoose:setSelectedState(false)

end

function MapMilitaryTaskPanel:registerEvents()
    MapMilitaryTaskPanel.super.registerEvents(self)

    self:addTouchEventListener(self._btnReset, self.onResetTimes)
    self:addTouchEventListener(self._imgCCBNode, self.onOpenBox)
end

function MapMilitaryTaskPanel:onShowHandler()
    self:setPlayAnima(false)

    self:updateUI()
end

function MapMilitaryTaskPanel:onHideHandler()
    if self:isPlayAnima() == true then
        self:showSysMessage(TextWords:getTextWord(540013))
    else
        if self._panelMain ~= nil then
            self._panelMain:unscheduleUpdate()
        end
    end
end

function MapMilitaryTaskPanel:setPlayAnima(b)
    self._isPlayAnima = b
end

function MapMilitaryTaskPanel:isPlayAnima()
    return self._isPlayAnima or false
end

function MapMilitaryTaskPanel:updateUI()

    local curPlayerMilitaryValue = self._proxy:getCurMilitaryValue()
    local maxNeedMilitaryValue = self._proxy:getMaxMilitaryValue()

    -- �����ѻ�ñ���
    local strTip = string.format(self:getTextWord(540002), self._proxy:getTotalReward())
    self._txtTip1:setString(strTip)

    -- ��ǰӵ�еı���
    self._fontNum:setString(self._proxy:getRewardNum())

    -- ���վ���
    local strValue = 0
    if curPlayerMilitaryValue > 9999999 then
    strValue = StringUtils:formatNumberByGMKFloor(curPlayerMilitaryValue)
    else
    strValue = StringUtils:formatNumberByK4Floor(curPlayerMilitaryValue)
    end
    self._txtMilityry:setString(strValue)

    -- ����ֵΪ0ʱ�޷�����
    NodeUtils:setEnable(self._btnReset, curPlayerMilitaryValue ~= 0)

    -- ��Ϊ��������������Ҫ��ڵ������̬��
    self._awardGroup = self._proxy:getMilitaryAwardGroup()
    self:initProgressNode(self._awardGroup)

    -- ����������
    self:playGetValueRecord()

end

function MapMilitaryTaskPanel:playGetValueRecord()
    local oldValue = self._proxy:getOldMilitaryValue()
    local curValue = self._proxy:getCurMilitaryValue()

--    local maxNeedMilitaryValue = self._proxy:getMaxMilitaryValue()
--    self._actionPer = math.min(oldValue / maxNeedMilitaryValue * 100, 100)

    self._actionPer = self:getPerByMilitaryValue(oldValue)

    self._valueOffset = curValue - oldValue
    if self._valueOffset > 0 then
        -- ÿ֡+����ٷֱ�
        local addPer = 1

        local function handler(dt)
            self:updateProgress(dt, addPer)
        end
        self._panelMain:scheduleUpdateWithPriorityLua(handler, 0)
    else
        self:updateProgress(dt, 0)
    end
end

function MapMilitaryTaskPanel:initProgressNode()
    local awardCount = #self._awardGroup

    local progressBgSize = self._imgProgressBg:getContentSize()
    local progressBgPosX = self._imgProgressBg:getPositionX()

    self._boxNodeAry = self._boxNodeAry or { }

    for i = 1, awardCount do
        local awardData = self._awardGroup[i]
        local boxNode = self._boxNodeAry[i]

        -- �����ڵ�
        if boxNode == nil then
            self._boxNodeAry[i] = self._boxNodeClone:clone()
            boxNode = self._boxNodeAry[i]
            self._boxNodeClone:getParent():addChild(boxNode)

            -- �ڵ�
            local sprFull = TextureManager:createSprite("images/mapMilitary/SpProgressNodeFull.png")
            sprFull.initWidth = sprFull:getContentSize().width
            sprFull:setAnchorPoint(0, 0)
            sprFull:setPositionX(0.5)
            boxNode:addChild(sprFull)
            boxNode.sprFull = sprFull

            -- ��������Y����
            boxNode.imgBox = boxNode:getChildByName("imgBox")
            local nodeSize = boxNode:getContentSize()
            if i % 2 == 1 then
                boxNode.imgBox:setPositionY(nodeSize.height / 2 + 42)
            else
                boxNode.imgBox:setPositionY(nodeSize.height / 2 - 42 - 5)
            end

            -- ������
            boxNode.fontNum = boxNode.imgBox:getChildByName("fontNum")

            -- �ı�(txtActiveneedҪ�ڽ�����Ч������)
            local txtActiveneed = boxNode:getChildByName("txtActiveneed")
            txtActiveneed:setPositionY(boxNode:getPositionY())
            txtActiveneed:retain()
            txtActiveneed:removeFromParent()
            txtActiveneed:setLocalZOrder(4)
            boxNode:getParent():addChild(txtActiveneed)
            txtActiveneed:release()
            boxNode.txtActiveneed = txtActiveneed
        end

        -- ���ýڵ�
        boxNode:setVisible(true)
        boxNode:setPositionX(progressBgPosX - progressBgSize.width / 2 + progressBgSize.width / awardCount * i)
        boxNode.txtActiveneed:setPositionX(boxNode:getPositionX() - boxNode:getContentSize().width / 2)
    end

    -- �����������
    for i = awardCount + 1, #self._boxNodeAry do
        self._boxNodeAry:setVisible(false)
    end
end

function MapMilitaryTaskPanel:updateProgressNode(progressPercent)
    local awardCount = #self._awardGroup

    local progressBgSize = self._imgProgressBg:getContentSize()
    local progressBgPosX = self._imgProgressBg:getPositionX()

    self._boxNodeAry = self._boxNodeAry or { }

    for i = 1, awardCount do
        local awardData = self._awardGroup[i]
        local boxNode = self._boxNodeAry[i]

        -- �ڵ���Ȳü�
        local sprFull = boxNode.sprFull
        local rect = sprFull:getTextureRect()

        local nodeEndPer = i / awardCount * 100
        local nodeStartPer = nodeEndPer - sprFull.initWidth / progressBgSize.width * 100

        if nodeEndPer <= progressPercent then
            rect.width = sprFull.initWidth
            NodeUtils:setGray(boxNode.imgBox, false)
        elseif nodeStartPer >= progressPercent then
            rect.width = 0
            NodeUtils:setGray(boxNode.imgBox, true)
        else
            rect.width =(progressPercent - nodeStartPer) / 100 * progressBgSize.width
            NodeUtils:setGray(boxNode.imgBox, true)
        end
        sprFull:setTextureRect(rect)

        -- ������
        boxNode.fontNum:setString(awardData.awardNumber)

        -- �������ֵ
        local need = StringUtils:formatNumberByK4(awardData.activeNeed)
        boxNode.txtActiveneed:setString(need)
    end
end

-- ���Ŵ򿪱����ý�������
function MapMilitaryTaskPanel:playGetAwardAnima(data)

	local isMultiple = 0
	-- isMultiple  0 ������  1 ����
	local rewards = data.rewards
	for k, v in pairs(rewards) do
		if v.multiple > 1 then
			isMultiple = 1
		end
	end

	local size = self._imgCCBNode:getContentSize()
	-- �����Ч              ��ͨ
	if isMultiple == 0 then

		local owner = { }
		owner["complete"] = function()
			self._ccbDianji:finalize()
			self._ccbDianji = nil
			self._ccbXiang:setVisible(true)
		end
		owner["pause"] = function()
		end
		self._ccbDianji = self:createUICCBLayer("rgb-jg-dianji", self._imgCCBNode, owner)
		self._ccbDianji:setPosition(size.width / 2, size.height / 2)
		self._ccbXiang:setVisible(false)
	elseif isMultiple == 1 then
        logger:info("------------------------------������---------------------------")
		local owner = { }
		owner["complete"] = function()
			self._ccbBaoji:finalize()
			self._ccbBaoji = nil
			self._ccbXiang:setVisible(true)
		end
		self._ccbBaoji = UICCBLayer.new("rgb-jg-baoji", self._imgCCBNode, owner)
		self._ccbBaoji:setPosition(size.width / 2, size.height / 2)
		self._ccbXiang:setVisible(false)
	end

	---- ������Ч
	-- if data.multiple > 1 then

	--    --local guideTxt = tolua.cast(owner["nameTxt"], "cc.Sprite")
	--    --TextureManager:updateSprite(guideTxt, UrlTimesSprite[data.multiple])
	-- end
    local rewardList = {}
    for k,v in pairs (data.rewards) do
        local multiple = v.multiple
        for k,reward in pairs (v.rewards) do
             reward.multiple = multiple                         --��ÿһ��� һ����������
             reward.mulUrl = UrlTimesSprite[multiple]
             table.insert(rewardList,reward)
        end
    end

    logger:info(" rewardList  "..#rewardList)
	-- �����Ʒ��Ч
	AnimationFactory:playAnimationByName("GetGoodsEffect", rewardList)

	-- ��ǰӵ�еı���
	self._fontNum:setString(self._proxy:getRewardNum())
end

-- ����ת��Ϊ�������ϵĽ���
function MapMilitaryTaskPanel:getPerByMilitaryValue(militaryValue)
    -- �����б�
    local awardGroup = self._awardGroup

    -- ����ֵ����
    local maxNeedMilitaryValue = self._proxy:getMaxMilitaryValue()

    -- ��ȡ�������ڵ�����
    local awardCount = #awardGroup
    local index = awardCount
    for i = 1, awardCount, 1 do
        if militaryValue <= awardGroup[i].activeNeed then
            index = i
            break
        end
    end


    local preNeed =((index == 1) and 0 or awardGroup[index - 1].activeNeed)
    local preMax = awardGroup[index].activeNeed - preNeed

    -- ת��Ϊ�µİٷֱ�(�߻�˵���䲻һ���ȱȵ�)
    local newPer =(((militaryValue - preNeed) / preMax +(index - 1)) / awardCount) * 100
    newPer = math.min(newPer, 100)
    newPer = math.max(newPer, 0)

    return newPer
end

-- ֡���½�����
function MapMilitaryTaskPanel:updateProgress(dt, addPer)
    -- �����б�
    local awardGroup = self._awardGroup

    -- ��ǰ����ֵ
    local curValue = self._proxy:getCurMilitaryValue()
        
    -- ��ǰ�����ٷֱ�
    local curPer = self:getPerByMilitaryValue(curValue)
    
    -- ����һ���ڵ㣬���Ż�ȡ���ӵ���Ч
    local len = 100 / #awardGroup
    local preNodeIndex = math.floor(self._actionPer / len)
    local curNodeIndex = math.floor((self._actionPer + addPer) / len)
    if curNodeIndex > preNodeIndex then
        self:playGetBoxAnima(curNodeIndex)
    end

    -- �ж��Ƿ�ﵽ���½��ȣ��ﵽ��ȡ��֡����
    self._actionPer = self._actionPer + addPer
    if self._actionPer >= curPer then
        self._actionPer = curPer

        self._panelMain:unscheduleUpdate()
    end

    local maxNeedMilitaryValue = self._proxy:getMaxMilitaryValue()
    self._proxy:setOldMilitaryValue(self._actionPer / 100 * maxNeedMilitaryValue)

    -- ���ý��ȣ�������Чλ��
    self._progressBar:setPercent(self._actionPer)
    self._ccbProgress:setPositionX(self._ccbProgress.initPosX + self._progressBar:getContentSize().width / 100 * self._actionPer)

    -- ��Ⱦ���еı���
    self:updateProgressNode(self._actionPer)

    
end

-- ���Ż�ȡ����Ķ���
function MapMilitaryTaskPanel:playGetBoxAnima(curNodeIndex)
    -- �������ϵĶ���
    local curNode = self._boxNodeAry[curNodeIndex]
    local nodeSize = curNode:getContentSize()
    local worldPosStart = curNode:convertToWorldSpace(cc.p(nodeSize.width / 2, nodeSize.height / 2))
    local startPos = self._panelMain:convertToNodeSpace(worldPosStart);
    local ccbShoujiA = self:createUICCBLayer("rgb-jg-shoujia", self._panelMain, nil, nil, true)
    ccbShoujiA:setPositionX(startPos.x)
    ccbShoujiA:setPositionY(startPos.y)
    ccbShoujiA:setLocalZOrder(10)

    -- Ʈ���ĵ�Ķ���
    local size = self._imgCCBNode:getContentSize()
    local endX, endY = self._imgCCBNode:getPosition()
    --    endX = endX + size.width / 2
    --    endY = endY + size.height / 2
    self._ccbDot = self._ccbDot or { }
    self._ccbDot[curNodeIndex] = self._ccbDot[curNodeIndex] or { }
    for i = 1, 3 do
        local ccbDot = self._ccbDot[curNodeIndex][i]
        if ccbDot == nil then
            ccbDot = self:createUICCBLayer("rgb-energy-jinse", self._panelMain)
            self._ccbDot[curNodeIndex][i] = ccbDot
        end

        ccbDot:setPositionX(startPos.x)
        ccbDot:setPositionY(startPos.y)

        local m1 = cc.MoveTo:create(0.3, cc.p(startPos.x + 20 *(i - curNodeIndex), startPos.y + 30 + math.random(0, 20)))
        local m2 = cc.MoveTo:create(1, cc.p(endX, endY))
        local c = cc.CallFunc:create( function()
            local ccbShoujiB = self:createUICCBLayer("rgb-jg-shoujib", self._imgCCBNode, nil, nil, true)
            ccbShoujiB:setPositionX(size.width / 2)
            ccbShoujiB:setPositionY(size.height / 2)
            ccbShoujiB:setLocalZOrder(100)

            local s1 = cc.ScaleTo:create(0.1, 1.1)
            local s2 = cc.ScaleTo:create(0.1, 1)
            self._imgCCBNode:runAction(cc.Sequence:create(s1, s2))

            self._ccbDot[curNodeIndex][i]:finalize()
            self._ccbDot[curNodeIndex][i] = nil
        end )
        local seq = cc.Sequence:create(m1, m2, c)
        ccbDot:runAction(seq)
    end

    -- logger:info("startPosX:%s, startPosY:%s, endX:%s, endY:%s", startPos.x, startPos.y, endX, endY)


end


-- ���ð�ť
function MapMilitaryTaskPanel:onResetTimes(sender)
    if self:isPlayAnima() then
        self:showSysMessage(self:getTextWord(540013))
        return
    end

    if self._proxy:isMaxResetTimes() then
        -- �Ѵ�������ô���
        self:showSysMessage(self:getTextWord(540011))
    else
        if self._proxy:isNeedUpgradeVip() then
            -- ��Ҫ����vip���������ô���
            local vipLevel = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel) or 0
            local timesData = ConfigDataManager:getInfoFindByOneKey(ConfigData.MilitaryExploitMissionConfig, "VIP", vipLevel)

            -- local data = {}
            -- data.content = string.format(self:getTextWord(540012), timesData.resetTimes)
            -- data.tip = TextWords:getTextWord(540018)
            self:showMessageBox(string.format(self:getTextWord(540012), timesData.resetTimes)
            , function() ModuleJumpManager:jump(ModuleName.RechargeModule, "RechargePanel") end
            , nil
            , TextWords:getTextWord(540019))
        else
            if self._proxy:isGoldEnoughToReset() then
                -- �����㹻��gold������
                local data = { }
                data.content = string.format(TextWords:getTextWord(540014), self._proxy:getResetGlod())
                data.tip = TextWords:getTextWord(540016)
                data.num = string.format(TextWords:getTextWord(540017), self._proxy:getRemianResetTimes())
                self:showMessageBox(data, function() self._proxy:onTriggerNet530001Req() end)
            else
                -- gold���㣬�򿪳�ֵ���
                self:showRechargeUI()
                --ModuleJumpManager:jump(ModuleName.RechargeModule, "RechargePanel")
            end
        end
    end
end

-- ������
function MapMilitaryTaskPanel:onOpenBox(sender)
	if self:isPlayAnima() then
		self:showSysMessage(self:getTextWord(540013))
		return
	end

	local times = 1
	if self._fiveChoose:getSelectedState() then
		times = 5
	end
	-- logger:info("��������� timesData   "..times)

	-- ʣ�౦���������� ��ȫ����
	local fontNum = self._proxy:getRewardNum()
	if fontNum < times then
		times = fontNum
	end

    if times == 0 then
    return 
    end
	local data = { }
	data.times = times
	self._proxy:onTriggerNet530000Req(data)

end

-- �򿪳�ֵ���
function MapMilitaryTaskPanel:showRechargeUI()
    local parent = self:getParent()
    local panel = parent.panel
    if panel == nil then
        local panel = UIRecharge.new(parent, self)
        parent.panel = panel
    else
        panel:show()
    end
end
