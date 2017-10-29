--
-- Author: zlf
-- Date: 2016年6月2日15:36:36
-- 每日转盘界面

--[[
	self.finish:转盘停止
	self.Stop:协议返回
]]

DayTurntableMainPanel = class("DayTurntableMainPanel", BasicPanel)
DayTurntableMainPanel.NAME = "DayTurntableMainPanel"

function DayTurntableMainPanel:ctor(view, panelName)
    DayTurntableMainPanel.super.ctor(self, view, panelName)
end

function DayTurntableMainPanel:finalize()
    -- if self.moveAction then
    -- 	self.moveAction:finalize()
    -- end
    if self.movieChip then
    	self.movieChip:finalize()
    end
    if self.uiResourceGet then
		self.uiResourceGet:removeFromParent()
		self.uiResourceGet = nil
	end
    DayTurntableMainPanel.super.finalize(self)
end

function DayTurntableMainPanel:initPanel()
	DayTurntableMainPanel.super.initPanel(self)
	self.proxy = self:getProxy(GameProxys.Activity)
	--self:setTitle(true,"dayturntable", true)
	-- self:adjustBootomBg(self:getChildByName("topPanel"), self:getChildByName("bottomPanel"))
	--self:setBgType(ModulePanelBgType.NONE)
	self.spendLab = self:getChildByName("topPanel/spendLab")
	--self.checkBox = self:getChildByName("topPanel/tenCB")
    --
	--self:addTouchEventListener(self.checkBox, self.checkBoxTouch)

	self:getChildByName("bottomPanel"):setLocalZOrder(2)
	self.circleImg = self:getChildByName("bottomPanel/circleImg")
	self.numLab = self:getChildByName("topPanel/numLab")
	local allLabel = self:getChildByName("topPanel/allLabel")
	local lotteryLab = self:getChildByName("topPanel/lotteryLab")
	--local tenLab = self:getChildByName("topPanel/tenLab")
	self.timeLab = self:getChildByName("topPanel/timeLab")

	--tenLab:setString(TextWords:getTextWord(280000))
	lotteryLab:setString(TextWords:getTextWord(280001))
	allLabel:setString(TextWords:getTextWord(280002))

	self.allIcon = {}
	self.iconBg = {}
	for i=1,12 do
		table.insert(self.allIcon, self.circleImg:getChildByName("iconImg"..i))
		table.insert(self.iconBg, self.circleImg:getChildByName("imgEffect"..i))
	end
	self.Stop = false
	self.finish = true
	self.canClose = true

	--local rankBtn = self:getChildByName("topPanel/rankBtn")
	-- self.startBtn = self:getChildByName("bottomPanel/startImg")
	-- self.BtnBg = self:getChildByName("bottomPanel/startBtn")
	self.startBtn = self:getChildByName("bottomPanel/startBtn")
    self.startBtn.times = 1
	self._btnDownImg = self.startBtn:getChildByName("btnDown")
	self.startBtn.parent = self
	self.startBtn:addTouchEventListener(self.onReqReward)
    --ComponentUtils:addTouchEventListener(self.startBtn, self.onReqReward, nil, self)
	self.btnTenDraw = self:getChildByName("bottomPanel/btnTenDraw")
    self.btnTenDraw.times = 10
	self.btnTenDraw.parent = self
	self.btnTenDraw:addTouchEventListener(self.onReqReward)
    --ComponentUtils:addTouchEventListener(self.btnTenDraw, self.onReqReward, nil, self)

	--self:addTouchEventListener(rankBtn, self.showRankPanel)

	self.pointer = self:getChildByName("bottomPanel/startBtn")

	local tipBtn = self:getChildByName("topPanel/tipBtn")
	self:addTouchEventListener(tipBtn, self.onShowTips)

	local topPanel = self:getChildByName("topPanel")
	topPanel:setLocalZOrder(2)

	local tipsLab = topPanel:getChildByName("tenLab_1")
	tipsLab:setString(TextWords:getTextWord(280009))

	-- self:getChildByName("bottomPanel"):setVisible(false)
	-- self:getChildByName("topPanel"):setVisible(false)
	
end

function DayTurntableMainPanel:doLayout()
    local topPanel = self:getChildByName("topPanel")
    local bottomPanel = self:getChildByName("bottomPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(topPanel, nil, bottomPanel, tabsPanel)
end

function DayTurntableMainPanel:registerEvents()
	DayTurntableMainPanel.super.registerEvents(self)
end

function DayTurntableMainPanel:onShowHandler()
	local data = self.proxy.curActivityData
	if not self.movieChip then
		self.movieChip = UIMovieClip.new("rpg-listof")
    	local mainPanel = self:getChildByName("topPanel/rankBtn")
    	self.movieChip:setParent(mainPanel)
    	self.movieChip:setLocalZOrder(10)
    	local size = mainPanel:getContentSize()
    	self.movieChip:setPosition(size.width / 2, size.height / 2)
    end
    self.movieChip:play(true)

	self.canClose = true
	local parent = self:getParent()
	if parent.uiResourceGet then
		parent.uiResourceGet:hide()
	end
	self.rotated = 0
	self.allAngle = 0
	self.circleImg:stopAllActions()
	self.circleImg:setRotation(0)
	self:rotatePointer(1)
	self.startBtn.reqData = {times = 1, activityId = data.activityId}
	self.btnTenDraw.reqData = {times = 10, activityId = data.activityId}
	--self.checkBox:setSelectedState(false)
	self.finish = true
	self.Stop = false
	
	self:initView(data)
	--local action = cc.Sequence:create(cc.RotateBy:create(0.1, 0.5) ,cc.CallFunc:create(function()
	--	self:rotateBg()
	--end))
	--self.circleImg:runAction(action)
end

function DayTurntableMainPanel:onClosePanelHandler()
	if not self.finish then
		logger:error("防止网络延迟导致再次打开协议才返回又点了抽奖造成界面混乱")
		self:showSysMessage(TextWords:getTextWord(280010))
		return
	end
	self.circleImg:stopAllActions()
	self.pointer:stopAllActions()
	self.movieChip:stopAllActions()
	-- self.moveAction:stopAllActions()
 --    self.moveAction:setVisible(false)
    self.view:dispatchEvent(DayTurntableEvent.HIDE_SELF_EVENT)
end

--显示排行榜界面
--function DayTurntableMainPanel:showRankPanel(sender)
--	if not self.canClose then
--		self:showSysMessage(TextWords:getTextWord(280010))
--		return
--	end
--	
--	self.circleImg:stopAllActions()
--	self.pointer:stopAllActions()
--	self.movieChip:stopAllActions()
--
--	local rankData = self.proxy:getTurnTableInfo(self.proxy.curActivityData.activityId)
--	local num = self.proxy.allJifen or rankData.jifen
--
--	local rankInfo = self.proxy:getRankInfoById()
--	local rankingID = self.proxy:getCurActivityData().rankId
--	local configData = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, rankingID)
--	local rankingreward = configData.rankingreward
--
--	local text = string.format(TextWords:getTextWord(280003), configData.ntegralcondition, configData.levelcondition, configData.number)
--	if self.rankPanel == nil then
--		self.rankPanel = UIRankPanel.new(self:getParent(), self, function()
--			self:onShowHandler()
--		end, {rankData = rankInfo, num = num, tipText = text, rankID = rankingreward})
--		self.rankPanel:setTitle(true,"dayturntable",true)
--	else
--		self.rankPanel:updateData({rankData = rankInfo, num = num, tipText = text, rankID = rankingreward})
--	end
--
--end

function DayTurntableMainPanel:onShowTips(sender)
	local parent = self:getParent()
	local uiTip = UITip.new(parent)
	self.limit = self.limit or 199
	local text = {{{content = string.format(TextWords:getTextWord(280004), self.limit), foneSize = ColorUtils.tipSize20, color = ColorUtils.commonColor.MiaoShu}},
                    {{content = string.format(TextWords:getTextWord(280013), self.limit), foneSize = ColorUtils.tipSize20, color = ColorUtils.commonColor.Green}}}
    uiTip:setAllTipLine(text)
    uiTip:setTitle(TextWords:getTextWord(7502))
end

function DayTurntableMainPanel.onReqReward(sender, event)
	self = sender.parent
    --sender.reqData.activityId = self.proxy.curActivityData.activityId
    sender.reqData.times = sender.times
    if sender.reqData.times == 1 then
	    if event == ccui.TouchEventType.began then
	    	self._btnDownImg:setVisible(true)
	    end
	    if event == ccui.TouchEventType.canceled then
	    	self._btnDownImg:setVisible(false)
	    end
	    self._btnDownImg:setVisible(false)
    end
    
	if event ~= ccui.TouchEventType.ended then
		return
	end

	if not self.hasCount or (not sender.reqData) then
		return
	end
	if self.uiResourceGet and self.uiResourceGet._uiSkin:isVisible() then
		return
	end
	if not self.finish then
		self:showSysMessage(TextWords:getTextWord(280010))
		return
	end

    -- 直接由服务端弹错误码
--	if self.hasCount < sender.reqData.times then
--		self:showSysMessage(TextWords:getTextWord(280011))
--		return
--	end

    --TODO:改在在协议返回后再播放动画
--    local actionParent = self:getChildByName("bottomPanel/startBtn")
--    local size = actionParent:getContentSize()
--    local moveAction = self:createUICCBLayer("rpg-zp-gq", actionParent, nil, nil, true)--UIMovieClip.new("rpg-mars")
--    self.startBtn.effect = moveAction
--    moveAction:setLocalZOrder(10)
--    moveAction:setPosition(size.width * 0.5, size.height * 0.5)
--    self:playWheelAction()

	--self.circleImg:stopAllActions()
	self.finish = false
	self.canClose = false
	--self.circleImg:runAction(cc.CallFunc:create(function()
	--	self.needData = 0
	--	self.speed = 400
	--	self.Stop = false
	--	self:rotateBg()
	--end))
	if sender.reqData then
		self.proxy:onTriggerNet230022Req(sender.reqData)
	end
end

--刚开始一直在转动的函数，递归调用，累计转动的角度，协议返回时跳出递归。开始加速并计算要转的角度
function DayTurntableMainPanel:rotateBg()
	if self.Stop then
		self.allAngle = self.allAngle%360
		local iconAngle = self.allAngle
		if self.allAngle >= self.angle then
			self.needData = 360 - self.allAngle + self.angle
		else
			self.needData = self.angle - self.allAngle
		end
		self.allAngle = 0
		local allQ =  math.random(3, 4)*360 + self.needData
		local act = cc.EaseSineInOut:create(cc.RotateBy:create(allQ/self.speed, allQ))
		local rotate = cc.Sequence:create(act, cc.CallFunc:create(function()
				self:showReward()			
				self.rotated = self.circleImg:getRotation()%360
				self.finish = true
				self.Stop = false
				self:rotatePointer(1)
		end))
		
		self.circleImg:runAction(rotate)
		self:rotatePointer(0.4)
		return
	end
	self.allAngle = self.allAngle + 0.5
	local action = cc.Sequence:create(cc.RotateBy:create(0.1, 0.5) ,cc.CallFunc:create(function()
		self:rotateBg()
	end))
	self.circleImg:runAction(action)
end

function DayTurntableMainPanel:rotatePointer(time)
	self.pointer:stopAllActions()
	self.pointer:setRotation(0)
	local action1 = cc.RotateBy:create(time, 2)
	local action2 = cc.RotateBy:create(time, -2)
	self.pointer:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)))
end

function DayTurntableMainPanel:initView(data)
    local roleProxy = self:getProxy(GameProxys.Role)

    local config = ConfigDataManager:getConfigById(ConfigData.CoronaConfig, data.effectId)
    self:renderRewardIcon(config.rewardID)
    -- self.proxy.rankingID = config.rankingID
    -- self.rankingID = config.rankingID

    -- 累计消费
    local info = self.proxy:getTurnTableInfo(data.activityId)
    self.spendLab:setString(info.spend)

    -- 活动时间
    local startTime = TimeUtils:setTimestampToString(data.startTime)
    local endTime = TimeUtils:setTimestampToString(data.endTime)
    self.timeLab:setString(startTime .. "-" .. endTime)

    -- 抽奖次数
    if info and GameConfig.serverTime < data.endTime then
        local vipLv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel)
        local vipCount = vipLv > 0 and 1 + config.condition or 1
        self.limit = config.limit
        self.hasCount = math.floor(info.spend / config.limit) - info.times + vipCount
        self.hasCount = self.hasCount < 0 and 0 or self.hasCount
        self.numLab:setString(self.hasCount .. "/" ..(math.floor(info.spend / config.limit) + vipCount))
    else
        self.numLab:setString("0/0")
    end
end

function DayTurntableMainPanel:resetView()
	self:initView(self.proxy.curActivityData)
end

function DayTurntableMainPanel:renderRewardIcon(rewardID)
	local data = self:readExcelData(rewardID)
	self.index = {}
	local rewardData = {}
	for k,v in pairs(data) do
		self.index[v.ID] = k
		local fixId = StringUtils:jsonDecode(v.item)
--		for key,value in pairs(fixId) do
--			local reInfo = ConfigDataManager:getRewardConfigById(value)
            local reInfo = {}
            reInfo.power = fixId[1][1]
		    reInfo.typeid = fixId[1][2]
		    reInfo.num = fixId[1][3]
			reInfo.otherInfo = string.format(TextWords:getTextWord(280012)..v.ntegral)
			table.insert(rewardData, reInfo)
--		end
	end
    		
	for k,v in pairs(self.allIcon) do
		if rewardData[k] then
    		local icon = v.icon
    		if not icon then
    			icon = UIIcon.new(v, rewardData[k], true, self)
    			v.icon = icon
    		else
    			icon:updateData(rewardData[k])
    		end
    		icon:setPosition(v:getContentSize().width/2, v:getContentSize().height/2)
		end
	end
end

function DayTurntableMainPanel:updateView(data)--获得奖励更新
--	self.canClose = true
	if #data == 0 then
		-- self.moveAction:stopAllActions()
  --   	self.moveAction:setVisible(false)
		self.finish = true
		return
    else
        -- 播放动画
        local actionParent = self:getChildByName("bottomPanel/startBtn")
        local size = actionParent:getContentSize()
        local moveAction = self:createUICCBLayer("rpg-zp-gq", actionParent, nil, nil, true)--UIMovieClip.new("rpg-mars")
        self.startBtn.effect = moveAction
        moveAction:setLocalZOrder(10)
        moveAction:setPosition(size.width * 0.5, size.height * 0.5)
        self:playWheelAction()
	end
	self.Stop = true
	self.showData = data
	local id = data[#data]--竟然是只取了最后一个显示
	self.rewardIndex = self.index[id] or 1
	self.angle = 360-(self.rewardIndex - 1)*30 - self.rotated
	
	self:initView(self.proxy.curActivityData)

    
end

--显示获得的奖励，关闭后继续转动
function DayTurntableMainPanel:showReward()
	if (not self.showData) then return end

	local rewardData = {}
	for k,v in pairs(self.showData) do
		local data = ConfigDataManager:getConfigById(ConfigData.CurrentRewardConfig, v)

        local ary = StringUtils:jsonDecode(data.item)

        local reInfo = {}
        reInfo.power = ary[1][1]
        reInfo.typeid = ary[1][2]
        reInfo.num = ary[1][3]
		reInfo.otherInfo = string.format(TextWords:getTextWord(280012)..data.ntegral)
		table.insert(rewardData, reInfo)
		
	end
	local parent = self:getParent()
	function callback()
		--self.circleImg:stopAllActions()
		--local action = cc.Sequence:create(cc.RotateBy:create(0.1, 0.5) ,cc.CallFunc:create(function()
		--	self:rotateBg()
		--end))
		--self.circleImg:runAction(action)
	end
	if not self.uiResourceGet then
		self.uiResourceGet = UIGetProp.new(parent, self, true, callback)
	end
	self.uiResourceGet:show(rewardData, callback)

end

--function DayTurntableMainPanel:checkBoxTouch(sender)
--	local state = sender:getSelectedState()
--	local reqData = {}
--	if not state then
--		reqData.times = 10
--	else
--		reqData.times = 1
--	end
--	reqData.activityId = self.proxy.curActivityData.activityId
--	self.startBtn.reqData = reqData
--end



function DayTurntableMainPanel:readExcelData(rewardID)
	local config = ConfigDataManager:getConfigData(ConfigData.CurrentRewardConfig)
	local data = {}
	for k,v in pairs(config) do
		if v.rewardgroup == rewardID then
			table.insert(data, v)
		end
	end
	table.sort( data, function(a, b)
         return a.ID < b.ID
	end )
	return data
end

--self.allIcon
function DayTurntableMainPanel:playWheelAction()
    local dy = 0.2

    local times = 1
    local timesMax = 10000
    local index = 1
    local amount = #self.allIcon
    local isReset = true
    local isBreake = false
    
    local function callback()
        if self.Stop and isReset then--协议返回后再跑多至少5圈吧
            --dy = 0.2
            times = 1
            timesMax = 3
            isReset = false
        end
        
        if not isReset then
            if index == amount then-- 减速
                dy = dy + 0.01
            end

            if dy > 0.08 and times == 1 then
                dy = dy - 0.02
            end
        end

        if index > amount then
            times = times + 1
            index = 1
            if times > timesMax then--
                isBreake = true
            end
        end
        if isBreake then
            dy = dy + 0.02
            if index >= self.rewardIndex then
                --还要跑到对应的奖励那里 
                local delayAct = cc.DelayTime:create(0.2)
                local act = cc.Sequence:create(delayAct, cc.CallFunc:create(function()
			    	self:showRewardEffect()
                end))
                self:getChildByName("bottomPanel"):runAction(act)
                self:showIconBgByIndex(index)
                return
            end
        end
    	local icon = self.allIcon[index]
        self:showIconBgByIndex(index)
        local function playEffect()
    	    local size = icon:getContentSize()
    	    local efft = self:createUICCBLayer("rpg-zp-zd", icon, nil, nil, true)--rpg-zp-zd---rpg-zp-hq
    	    efft:setLocalZOrder(10)
    	    efft:setPosition(size.width * 0.5, size.height * 0.5)
        end
        local delayAct = cc.DelayTime:create(dy)
        local act = cc.Sequence:create(cc.CallFunc:create(playEffect), delayAct, cc.CallFunc:create(callback))
        icon:runAction(act)
        index = index + 1
    end
    callback()
end

function DayTurntableMainPanel:showRewardEffect()--获得道具特效
    --self.showData---		self.showData	{[1]=28 [2]=28 [3]=25 [4]=29 [5]=22 [6]=23 [7]=29 [8]=21 [9]=23 [10]=25 }	
    --+		self.index	{[21]=1 [22]=2 [23]=3 [24]=4 [25]=5 [26]=6 [27]=7 [28]=8 [29]=9 [30]=10 [31]=11 [32]=12 }	
    if self.startBtn.effect then
        self.startBtn.effect:finalize()
        self.startBtn.effect = nil
    end
    --for i = 1, #self.iconBg do
    --    self.iconBg[i]:setVisible(false)
    --end
    local function getIndexById(id)   
        for k, v in pairs(self.index) do
            if k == id then
                return v
            end
        end
    end

    --去重
    local data = {}
    for k, v in pairs(self.showData) do
        data[v] = v
    end

    
    local function playEffect(idx)
        local icon = self.allIcon[idx]
        local size = icon:getContentSize()
        local efft = self:createUICCBLayer("rpg-zp-hq", icon, nil, nil, true)--rpg-zp-zd---rpg-zp-hq
        efft:setLocalZOrder(10)
        efft:setPosition(size.width * 0.5, size.height * 0.5)
    end

    for k, v in pairs(data) do
        local index = getIndexById(data[k])
        if self.allIcon[index] then 
            playEffect(index)
        end
    end

    
    local delayAct = cc.DelayTime:create(1)
    local act = cc.Sequence:create(delayAct, cc.CallFunc:create(function()
	    self.finish = true
        self:showReward()
    end))
    self:getChildByName("bottomPanel"):runAction(act)
	--self:showReward()--应该延时弹出奖励
end

function DayTurntableMainPanel:showIconBgByIndex(idx)
    --for i = 1, #self.iconBg do
    --    if i == idx then
    --        self.iconBg[i]:setVisible(true)
    --    else
    --        self.iconBg[i]:setVisible(false)
    --    end
    --end
    if self.iconBg[idx] then
        self.iconBg[idx]:setOpacity(255)
        self.iconBg[idx]:runAction(cc.FadeTo:create(0.2, 0))
    end
end