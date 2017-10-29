--
-- Author: zlf
-- Date: 2016年8月9日 14:51:55
-- 世界Boss

--[[
	self.bossDie  服务端推320005通知boss死。这个标记让320004不处理
]]

require "modules.worldBoss.modelFactory.SoldiersFactory"

WorldBossPanel = class("WorldBossPanel", BasicPanel)
WorldBossPanel.NAME = "WorldBossPanel"

local ENTER_CODE = 1
local EXIT_CODE = 2
local myRank = 0
local runSpeed = 200
--可调控参数
--Boss移动的总长度（像素点）
local moveDistance = 200
--撤军总时间
local bossMoveTime = 2400
--boss的缩放系数
local bossScale = 1.1
--boss说话的时间间隔
local bossTalkTime = 6000
--boss说话的label持续显示的时间
local talkLabShowTime = 2000

function WorldBossPanel:ctor(view, panelName)
    WorldBossPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function WorldBossPanel:finalize()
	self._frameQueue:finalize()
    self._frameQueue = nil
    self._attackQueue:finalize()
    self._attackQueue = nil
    self.bossEffect:finalize()
    self.bossEffect = nil
    self._uiParticle:finalize()
    self._uiParticle = nil
    self.rootNode = nil
    if self.bossPanel.model ~= nil then
    	self.bossPanel.model:finalize()
    	self.bossPanel.model = nil
    end
    for i=1,4 do
    	if self["panel"..i].model ~= nil then
    		self["panel"..i].model:destory()
    		self["panel"..i].model = nil
    	end
    end

    if self._hpEffect ~= nil then
    	self._hpEffect:finalize()
    	self._hpEffect = nil
    end


    WorldBossPanel.super.finalize(self)
end

function WorldBossPanel:initPanel()
	WorldBossPanel.super.initPanel(self)

	local topPanel = self:getChildByName("topPanel")
	topPanel:setLocalZOrder(10)

	local tipsBtn = self:getChildByName("bottomPanel/tipsBtn")
	self:addTouchEventListener(tipsBtn, self.showTips)

	self.setBtn = self:getChildByName("bottomPanel/setBtn")
	self:addTouchEventListener(self.setBtn, self.showTeamPanel)

	self.proxy = self:getProxy(GameProxys.BattleActivity)
	self.roleProxy = self:getProxy(GameProxys.Role)
	self.autoCB = self:getChildByName("bottomPanel/titleBgImg/autoCB")
	self:addTouchEventListener(self.autoCB, self.autoBattle)

	self.attackBtn = self:getChildByName("bottomPanel/attackBtn")
	self.inspireBtn = self:getChildByName("bottomPanel/inspireBtn")
	local bottomPanel = self:getChildByName("bottomPanel")
	bottomPanel:setLocalZOrder(10)

	self.rankBtn = self:getChildByName("bottomPanel/rankBtn")

	self:addTouchEventListener(self.attackBtn, self.sendAttackReq)
	self:addTouchEventListener(self.inspireBtn, self.sendInspireReq)
	self:addTouchEventListener(self.rankBtn, self.showRankPanel)

	self.numLab = self:getChildByName("bottomPanel/titleBgImg/numLab")
	self.posX = self.numLab:getPositionX()
	self.descLab = self:getChildByName("bottomPanel/titleBgImg/descLab")

	self.nameLab = self:getChildByName("topPanel/infoPanel/titleBgImg/nameLab")
	self.timeLab = self:getChildByName("topPanel/infoPanel/titleBgImg/timeLab")

	self.HpNode = self:getChildByName("topPanel/infoPanel/HpBgImg")

	self.headIcon = self:getChildByName("topPanel/infoPanel/headIconImg")



	local autoLab = self:getChildByName("bottomPanel/titleBgImg/autoLab")
	autoLab:setString(TextWords:getTextWord(280173))

	local countLab = self:getChildByName("topPanel/infoPanel/titleBgImg/numLab")
	local percentLab = self.HpNode:getChildByName("percentLab")
	countLab:setLocalZOrder(3)
	percentLab:setLocalZOrder(3)
	self._frameQueue = FrameQueue.new(0.3)
	self._attackQueue = FrameQueue.new(0.2)

	for i=1,3 do
		self["panel"..i] = self:getChildByName("middlePanel/Panel_"..i)
		self["pos"..i] = cc.p(self["panel"..i]:getPosition())
		-- self["eff"..i] = UIMovieClip.new("rgb-hit-bing")
		-- self["eff"..i]:setParent(self["panel"..i]:getParent())
		-- self["eff"..i]:setLocalZOrder(15)
		-- self["eff"..i]:setVisible(false)
		-- self["eff"..i]:setAnchorPoint(0, 0)
	end

	for i=1,6 do
		self["kill"..i] = self:getChildByName("descPanel/bg_info"..i)
	end

	self["panel4"] = self:getChildByName("middlePanel/Panel_My")
	self["pos4"] = cc.p(self["panel4"]:getPosition())
	-- self.eff4 = UIMovieClip.new("rgb-hit-bing")
	-- self["eff4"]:setParent(self["panel4"]:getParent())
	-- self["eff4"]:setLocalZOrder(15)
	-- self["eff4"]:setVisible(false)
	-- self["eff4"]:setAnchorPoint(0, 0)

	self.bossPanel = self:getChildByName("middlePanel/bossPanel")
	self.bossPos = cc.p(self.bossPanel:getPosition())
	self.bossPanel:setVisible(false)
	self:setTitle(true, "worldBoss", true)
	self:setBgType(ModulePanelBgType.BATTLE)
    self:updateTopTitleBg("images/common/SPActivityHead.png")
    self:setCloseMultiBtn(true)


	self:setBossPosition()
	self:setOtherPosition()

	-- self.effect0 = UIMovieClip.new("rgb-hit-a")
 --    self.effect0:setParent(self.bossPanel)
 --    self.effect0:setLocalZOrder(15)
 --    self.effect0:setPosition(-40, 70)
 --    self.effect0:setVisible(false)

 --    self.effectPos = cc.p(-40, 70)

    -- self.effect1 = UIMovieClip.new("rgb-hit-b")
    -- self.effect1:setParent(self.bossPanel)
    -- self.effect1:setLocalZOrder(15)
    -- self.effect1:setPosition(-40, 70)
    -- self.effect1:setVisible(false)

    self.bossEffect = self:createUICCBLayer("rgb-boss-smoke", self.bossPanel)
    self.bossEffect:setBlendAdditive(false)
    self.bossEffect:setVisible(false)

    local uiParticle = UIParticle.new(self, "huohua")
    local x, y = NodeUtils:getCenterPosition()
    uiParticle:setPosition(x,y)
    self._uiParticle = uiParticle
    self.rootNode = uiParticle:getRootNode()
    self.rootNode:setLocalZOrder(100)
    self.rootNode:setVisible(false)

    self.bossTips = self:getChildByName("middlePanel/bossPanel/teamImg/talkImg")

    self.MyName = self.roleProxy:getRoleName()

    local descPanel = self:getChildByName("descPanel")
	descPanel:setVisible(false)
end

function WorldBossPanel:registerEvents()
	WorldBossPanel.super.registerEvents(self)
end



function WorldBossPanel:doLayout()


	-- local Image_30 = self:getChildByName("descPanel/Image_30") 
	-- NodeUtils:adaptiveUpPanelABS(self["kill1"],Image_30,-2)


	-- for i=2,6 do
	-- 	-- self["kill"..i] = self:getChildByName("descPanel/bg_info"..i)
	-- 	NodeUtils:adaptiveUpPanelABS(self["kill" .. i],self["kill" .. (i-1)],0)--固定上边缘
	-- end

	-- local Image_6 = self:getChildByName("descPanel/Image_6") 
	-- NodeUtils:adaptiveUpPanelABS(Image_6,self["kill6"],0)



	-- local imageTop = self:getChildByName("descPanel/Image_30") 
	-- local imageDown = self:getChildByName("descPanel/Image_6") 

	-- local nodes = {}
	-- table.insert(nodes,imageTop)
	-- for i = 1,6 do
	-- 	table.insert(nodes,self["kill" .. i])
	-- end
	-- table.insert(nodes,imageDown)
	-- NodeUtils:alignNodeU2D(unpack(nodes))


end



function WorldBossPanel:onShowHandler()
	self._frameQueue:clear()
	self._attackQueue:clear()
	self.itemData = self.view:getCurActivityData()
	self.proxy:onTriggerNet320000Req({activityId = self.itemData.activityId})
	local coolLab = self:getChildByName("bottomPanel/coolLab")
	coolLab:setVisible(false)
	self.proxy:onTriggerNet320007Req({type = ENTER_CODE})
end

function WorldBossPanel:showTips(sender)
	local parent = self:getParent()
	local uiTip = UITip.new(parent)
    local line = {}
    local lines = {}
    for i=1,16 do
    	line[i] = {{content = self:getTextWord(280105+i), foneSize = ColorUtils.tipSize20, color = ColorUtils.commonColor.MiaoShu}}
    	table.insert(lines, line[i])
    end
    uiTip:setAllTipLine(lines)
end

--请求320000后刷新界面
function WorldBossPanel:showView(isNotOpen)
	self:stopBgMove()
	if isNotOpen == nil then
		local function callback()
			self.activityData = self.proxy:getBossInfoById(self.itemData.activityId)
			myRank = StringUtils:formatNumberByK(self.activityData.myDamage)
			local state = self.proxy:getStateById(self.itemData.activityId)
			if state ~= 0 then
				self:bgShow()
			end
			bossMoveTime = self.activityData.endActivityTime
			self:initView()
			self.init = true
		end
		TimerManager:addOnce(30, callback, self)
	else -- 为true self:sendNotification(AppEvent.PROXY_WORLDBOSS_SHOW_VIEW, true)
		--活动未开启，返回错误码。也要刷新界面
		self.rootNode:setVisible(false)
		self:stopBgMove()
		local descPanel = self:getChildByName("descPanel")
		descPanel:setVisible(true)
		local infoPanel = self:getChildByName("topPanel/infoPanel")
		infoPanel:setVisible(false)
		self.inspireBtn:setTouchEnabled(false)
		self.attackBtn:setTouchEnabled(false)
        local mDamage = 0
		self.numLab:setString(mDamage)
		--local x = self.posX + self.numLab:getContentSize().width
		--self.descLab:setPositionX(x + 3)
		self:setKillInfo({})

	end
end

function WorldBossPanel:onClosePanelHandler()
	-- 重连没有走这边
    self:dispatchEvent(WorldBossEvent.HIDE_SELF_EVENT)
end

function WorldBossPanel:initView()
	local data = self.activityData

    self.proxy:initMyRank(self.activityData.myRank) -- 根据数据初始化rank值

	local myDamage = StringUtils:formatNumberByK(data.myDamage)
	self.numLab:setString(myDamage)
	--local x = self.posX + self.numLab:getContentSize().width
	--self.descLab:setPositionX(x + 3)

	local myRankStr = self.proxy:getMyRank() <= 0 and TextWords:getTextWord(1706) or string.format(TextWords:getTextWord(280140), tostring(self.proxy:getMyRank()))
	self.descLab:setString(myRankStr)
	local descPanel = self:getChildByName("descPanel")
	descPanel:setVisible(false)
	local infoPanel = self:getChildByName("topPanel/infoPanel")
	infoPanel:setVisible(true)
	self.battleState = self.activityData.autoFight
	self.autoCB:setSelectedState(self.battleState == 1)
	self.bossTips:setVisible(false)


	--鼓舞按钮在未开启状态无法点击
	self.inspireBtn:setTouchEnabled(true)
	self.rankBtn:setTouchEnabled(true)
	self.attackBtn:setTouchEnabled(true)
	self.bossPanel:setVisible(false)
	local state = self.proxy:getStateById(self.itemData.activityId)
	if state == 0 then
		self.bossEffect:setVisible(false)
		for i=1,3 do
			self["panel"..i]:stopAllActions()
			self["panel"..i].moveing = false
			self["panel"..i]:setPosition(self["pos"..i])
			if self["panel"..i].model ~= nil then
				self["panel"..i].model:destory()
				self["panel"..i].model = nil
			end
		end
		self.bossPanel:setVisible(false)
		descPanel:setVisible(true)
		infoPanel:setVisible(false)
		self.inspireBtn:setTouchEnabled(false)
		self.attackBtn:setTouchEnabled(false)
		self:setKillInfo(self.activityData.killerName)
		return
	end
	self.bossDie = false
	--准备状态boss信息要显示出来，倒计时为xx秒后开启
	if state == 1 then
		descPanel:setVisible(false)
		self.bossEffect:setVisible(false)
		infoPanel:setVisible(true)
		-- self.attackBtn:setTouchEnabled(false)
		self.bossPanel:setPosition(self.bossPos)
	-- else
		
	end
	local time = self.proxy:getRemainTime(self.proxy.timeKey .. "end" .. self.itemData.activityId)
	time = time == 0 and bossMoveTime or time
	local remainTime = bossMoveTime - time
	self.bossPanel:setPositionX(self.bossPos.x + remainTime/bossMoveTime * moveDistance)
	
	local url = string.format("images/barrack2Icon/%d.png", data.bossIcon)
	TextureManager:updateImageView(self.headIcon, url)

	local bossName = self:getChildByName("topPanel/infoPanel/titleBgImg/nameLab")

	bossName:setString(data.name)

	local nameBgImg = self.bossPanel:getChildByName("nameBgImg")
	local nameLab = nameBgImg:getChildByName("teamNameLab")

	self.rootNode:setVisible(state ~= 1)

	if state == 2 then
		TimerManager:add(bossTalkTime, self.showBossTalk, self, -1)
	end

	nameLab:setString(data.name)

	local teamImg = self.bossPanel:getChildByName("teamImg")
	local bossModel = self.bossPanel.model
	if bossModel ~= nil then
		bossModel:finalize()
		self.bossPanel.model = nil
	end  
	bossModel = SpineModel.new(data.bossIcon, teamImg)
	self.bossPanel.model = bossModel 
	bossModel:playAnimation("run", true)
	local modelSize = bossModel:getContentSize()
	nameBgImg:setPositionY(nameBgImg:getContentSize().height/2 + modelSize.height*bossScale)
	nameBgImg:setPositionX(-13*bossScale)

	self.bossTips:setPosition(-modelSize.width/2 *bossScale, self.bossTips:getContentSize().height/2 + modelSize.height*bossScale)
	bossModel._modelNode:setScale(bossScale)
	self.bossEffect:setPosition(20*bossScale, modelSize.height*bossScale*0.5)
	self.bossPanel:setVisible(true)
	self:updateBossInfo(data)
end

function WorldBossPanel:setKillInfo(data)
	local cloneData = clone(data)
	local nums = {"一", "二", "三", "四", "五", "头目"}
	for i=1,6 do
		local killInfo = data[i]
		local bossinfo = self["kill"..i]:getChildByName("bossinfo")
		local playerinfo = self["kill"..i]:getChildByName("playerinfo")
		local text = string.format("击杀敌军%s：", nums[i])
		bossinfo:setString(text)
		local bossText = killInfo == nil and "未被击杀" or string.format("%s", killInfo)
		playerinfo:setString(bossText)
	end
end

function WorldBossPanel:showBossTalk()
	self.bossTips:setVisible(true)
	local ID = math.random(1, 3)
	local text = TextWords:getTextWord(280169 + ID)
	local textLab = self.bossTips:getChildByName("textLab")
	textLab:setString(text)

	TimerManager:addOnce(talkLabShowTime, function()
		self.bossTips:setVisible(false)
	end, self)
end

--更新Boss血条和百分比文字
function WorldBossPanel:updateBossInfo(data)
	local countLab = self:getChildByName("topPanel/infoPanel/titleBgImg/numLab")
	local percentLab = self.HpNode:getChildByName("percentLab")
	local curHp = data.nowHp*6/data.totalHp
	curHp = curHp < 1 and 1 or curHp
	curHp = math.ceil(curHp)
	curHp = curHp > 6 and 6 or curHp
	
	local percent = string.format("%.2f", (data.nowHp/data.totalHp*100)) 
	percent = tonumber(percent)
	curHp = percent <= 0 and 0 or curHp
	percent = percent < 0 and 0 or percent
	
	countLab:setString("×"..curHp)
	--三个进度条，交替换
	--curHp剩下几段血
	--剩下1段的时候，下层的进度条置空
	--0的时候，所有进度条置空
	if self.bossEffect == nil then
		self.bossEffect = self:createUICCBLayer("rgb-feixu", self.bossPanel)
	end
	self.bossEffect:setVisible(curHp == 1)

    -- TODO，是否需要更换特效，现在特效不匹配，屏蔽了
	if self._hpEffect == nil then
		local headBgImg = self:getChildByName("topPanel/infoPanel/headBgImg")
		local size = headBgImg:getContentSize()
		self._hpEffect = self:createUICCBLayer("rpg-xielian", headBgImg)
		self._hpEffect:setLocalZOrder(20)
		self._hpEffect:setPosition(size.width / 2 , size.height / 2 - 10)
	end

	local hpNum = 100
	if curHp ~= 0 then
		--(data.nowHp - (curHp-1)*(data.totalHp/6))  算当前这段血还剩下的数量  
		--(data.totalHp/6)  每一段的总量
		--然后计算百分比
		local hpPercent = (data.nowHp - (curHp-1)*(data.totalHp/6))/(data.totalHp/6)*100
		hpPercent = hpPercent > 100 and 100 or hpPercent
		hpPercent = hpPercent < 0 and 0 or hpPercent
		hpNum = hpPercent
		percentLab:setString(StringUtils:getPreciseDecimal(hpPercent, 2) .. "%")
		local function adjustBar(ID)
			local IDS = {[1] = 1, [2] = 3, [3] = 2}
			for i=1,3 do
				local bar = self.HpNode:getChildByName("HpBar"..i)
				local showBarID = IDS[ID + 1]
				if showBarID == i then
					bar:setPercent((data.nowHp - (curHp-1)*(data.totalHp/6))/(data.totalHp/6)*100)
					bar:setLocalZOrder(2)
				else
					local nextID = showBarID + 1 > 3 and 1 or showBarID + 1
					local zOrder = nextID == i and 1 or 0
					bar:setLocalZOrder(zOrder)
					local hpPercent = curHp == 1 and 0 or 100
					bar:setPercent(hpPercent)
				end
			end
		end
		local curShowID = curHp % 3
		adjustBar(curShowID)
	else
		for i=1,3 do
			local bar = self.HpNode:getChildByName("HpBar"..i)
			bar:setPercent(0)
		end
		percentLab:setString("0%")
	end

    --血量≤5%的时候，头像和血条框要有闪动的特效
	self._hpEffect:setVisible(hpNum <= 5)
end

function WorldBossPanel:showTeamPanel(sender)
	local isJoin = self:isCanJoin()
	if not isJoin then
		return
	end
	if not self.init then
		return
	end

	local panel = self:getPanel(WorldBossTeamSetPanel.NAME)
	panel:show(self.activityData.name)

end

-- --通用部队面板的保存阵型回调
-- function WorldBossPanel:onTouchProtectBtnHandle(data)
-- 	local sendInfo = {}
-- 	for k,v in pairs(data.info.members) do
-- 		if v.num ~= 0 and v.num ~= nil then
-- 			sendInfo[k] = v
-- 		end
-- 	end
-- 	self.proxy:onTriggerNet320003Req({members = sendInfo})
-- end

--勾选自动战斗回调
function WorldBossPanel:autoBattle(sender)
	if not self.init then
		sender:setSelectedState(true)
		return
	end
	local isJoin = self:isCanJoin()
	if not isJoin then
		sender:setSelectedState(true)
		return
	end

	local vipLv = self.roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel)
	if vipLv < 6 then
		sender:setSelectedState(true)
		self:showSysMessage(TextWords:getTextWord(280125))
		return
	end


	local state = sender:getSelectedState()
	if state then
		local content = TextWords:getTextWord(280124)
		self:showMessageBox(content, function()
			self.proxy:onTriggerNet320008Req({type = 0})
		end, function()
			--取消弹窗，要还原checkbox的状态
			sender:setSelectedState(self.battleState == 1)
		end)
	else
		local soldierProxy = self:getProxy(GameProxys.Soldier)
		local teamInfo = soldierProxy:onGetTeamInfo()[4].members
		local isCanSend = false
		if teamInfo == nil then
		else
			for k,v in pairs(teamInfo) do
				if v.num ~= 0 and v.num ~= nil then
					isCanSend = true
					break
				end
			end
		end
		if not isCanSend then
			self:showSysMessage(TextWords:getTextWord(280126))
			sender:setSelectedState(true)
			return
		end
		self.proxy:onTriggerNet320008Req({type = 1})
	end
end

--请求战斗，检查冷却
function WorldBossPanel:sendAttackReq(sender)
	if not self.init then
		return
	end
	if not self:isCanJoin() then
		return
	end

	local state = self.proxy:getStateById(self.itemData.activityId)
	if state == 1 then
		self:showSysMessage(TextWords:getTextWord(280179))
		return
	end

	if self.battleState == 1 then
		self:showSysMessage(TextWords:getTextWord(280127))
		return
	end

	if self.panel4.moveing then
		self:showSysMessage(TextWords:getTextWord(280180))
		return
	end

	local soldierProxy = self:getProxy(GameProxys.Soldier)
	local teamInfo = soldierProxy:onGetTeamInfo()[4].members
	local isCanSend = false
	if teamInfo ~= nil then
		for k,v in pairs(teamInfo) do
			if v.num ~= 0 and v.num ~= nil then
				isCanSend = true
				break
			end
		end
	end
	if not isCanSend then
		self:showSysMessage(TextWords:getTextWord(280126))
		return
	end

	-- 按钮冷却中
	if self.isColdDowning then
		local needCoin = self.proxy:getRemainTime(self.proxy.coldDownTimeKey .. self.itemData.activityId)
		local content = string.format(TextWords:getTextWord(280128), needCoin)
	    local function callback()
	    	local coldDownTime = self.proxy:getRemainTime(self.proxy.coldDownTimeKey .. self.itemData.activityId)
			if coldDownTime == nil or coldDownTime == 0 then
				self:showSysMessage(TextWords:getTextWord(280129))
				return
			end
		    self.proxy:onTriggerNet320009Req({})
	    end
	    self:showMessageBox(content, callback)
		return
	end
	local data = {}
	data.icon = self.activityData.teamIcon
	data.damage = 0
	data.name = self.MyName
	self:createAction(data, false, true)

    local battleProxy = self:getProxy(GameProxys.Battle)
    battleProxy:startWorldBossAttack()
	self.proxy:onTriggerNet320001Req({})  --攻击的时候，直接请求战斗了，等自己的动画结束后，再播战斗
end

function WorldBossPanel:sendInspireReq(sender)
	if not self.init then
		return
	end
	if not self:isCanJoin() then
		return
	end
	local panel = self:getPanel(InspirePanel.NAME)
	panel:show()
end

function WorldBossPanel:showRankPanel(sender)
	if not self.init then
		return
	end
	self.proxy:onTriggerNet320006Req({monsterId = self.activityData.monsterId})
	TimerManager:add(300000, self.sendRankInfoReq, self, -1)
end

--各种倒计时，按钮冷却倒计时、准备到开启倒计时、boss撤军倒计时
function WorldBossPanel:update(dt)
	if not self.init then return end
	local state = self.proxy:getStateById(self.itemData.activityId)
	if state == 1 then
		local time = self.proxy:getRemainTime(self.proxy.timeKey.."read"..self.itemData.activityId)
		local remainTime = string.format(TextWords:getTextWord(280131), TimeUtils:getStandardFormatTimeString6(time))
		self.timeLab:setString(remainTime)
		self.timeLab:setVisible(time ~= 0 and time ~= nil)
		local x = self.bossPanel:getPositionX()
		self.bossPanel:setPositionX(x + moveDistance/bossMoveTime)
		if time == 0 or time == nil then
			--重新初始化界面
			self.bossDie = false
			self:initView()
		end
	end

	if state == 2 then
		local time = self.proxy:getRemainTime(self.proxy.timeKey.."end"..self.itemData.activityId)
		local remainTime = string.format(TextWords:getTextWord(280132), TimeUtils:getStandardFormatTimeString6(time))
		self.timeLab:setString(remainTime)
		self.timeLab:setVisible(time ~= nil and time ~= 0)
		local x = self.bossPanel:getPositionX()
		self.bossPanel:setPositionX(x + moveDistance/bossMoveTime)
	end

	local coldDownTime = self.proxy:getRemainTime(self.proxy.coldDownTimeKey .. self.itemData.activityId)
	local coolLab = self:getChildByName("bottomPanel/coolLab")
	coolLab:setVisible(coldDownTime ~= nil and coldDownTime > 0)
	if coldDownTime ~= nil and coldDownTime > 0 then
		self.isColdDowning = true
		coolLab:setString(string.format(TextWords:getTextWord(280133), TimeUtils:getStandardFormatTimeString6(coldDownTime)))
	else
		self.isColdDowning = false
	end
end

--服务端推送战斗信息，飘字
function WorldBossPanel:updateView(data) 
	if self.activityData == nil then return end

    self.activityData.myRank = data.myRank -- 实时更新排名
    self.proxy:initMyRank(self.activityData.myRank)

	local myRankStr = self.proxy:getMyRank() <= 0 and TextWords:getTextWord(1706) or string.format(TextWords:getTextWord(280140), tostring(self.proxy:getMyRank()))
	self.descLab:setString(myRankStr)

	local info = {}
	info.totalHp = self.activityData.totalHp
	info.nowHp = data.nowHp
	self:updateBossInfo(info)
	if self.bossDie then
		return
	end
	self:startAction(data.infos)
end

--递归展示其他玩家攻击boss、飘血
function WorldBossPanel:startAction(info)
	local lenght = #info
	local indexArr = {}
	if lenght > 3 then
		for i=1,lenght do
			indexArr[i] = i
		end
		for i=1,lenght do
			local randomIndex = math.random(1, lenght)
			indexArr[i], indexArr[randomIndex] = indexArr[randomIndex], indexArr[i]
		end
		for i=1,3 do
			self._attackQueue:pushParams(self.commonShowAction, self, info[indexArr[i]])
		end
		--剩余的飘血
		for i=4,lenght do
			local v = info[indexArr[i]]
			self._frameQueue:pushParams(self.showDamgeText, self, v.damage)
		end
	else
		for i=1,lenght do
			self._attackQueue:pushParams(self.commonShowAction, self, info[i])
		end
	end
end

--自己和其他人的攻击动画都在这里
function WorldBossPanel:commonShowAction(data)
	--屏蔽自己的手动战斗
	if data.name == self.MyName and self.battleState ~= 1 then
		return
	end
	self:createAction(data, true, false)
end

function WorldBossPanel:createAction(data, isShowText, isSendBattle)
	local v = data
	local teamIcon = v.icon
	local damage = v.damage
	local teamName = v.name
	local curModelID = nil

	if isSendBattle then
		if not self["panel4"].moveing then
			self["panel4"].moveing = true
			curModelID = 4
		end
	else
		for i=1,3 do
			if not self["panel"..i].moveing then
				curModelID = i
				self["panel"..i].moveing = true
				break
			end
		end
	end
	if curModelID ~= nil then
		self["panel"..curModelID]:stopAllActions()
		self["panel"..curModelID]:setPosition(self["pos"..curModelID])
		if self["panel"..curModelID].model ~= nil then
			self["panel"..curModelID].model:destory()
			self["panel"..curModelID].model = nil
		end

		local icon = self["panel"..curModelID]:getChildByName("teamImg")
		local name = icon:getChildByName("teamNameLab")
		local img = icon:getChildByName("stateImg")

		local maxNum = 1000
		local percent = 0.4
		local isShowImg = math.random(1, maxNum)
		img:setVisible(isShowImg <= maxNum*percent)

		local scale1 = cc.ScaleTo:create(0.8, 0.6)
		local scale2 = cc.ScaleTo:create(0.8, 1)
		local actQue = cc.Sequence:create(scale1, scale2)
		local imgAction = cc.RepeatForever:create(actQue)
		img:runAction(imgAction)

		name:setString(teamName)
		local model = SoldiersFactory:create(icon, teamIcon)
		img:setPosition(model:getPosX() + model:getMaxWidth() * 0.4, model:getMaxHeight() - img:getContentSize().height/2)
		name:setPosition(model:getPosX(), model:getMinHeight() - name:getContentSize().height/10)
		self["panel"..curModelID].model = model
		self["panel"..curModelID].code = curModelID
		model:runAction("run",true)

		local x, y = self.bossPanel:getPosition()
		local size = nil
		if self.bossPanel.model ~= nil then
			size = self.bossPanel.model:getContentSize()
		end
		if size ~= nil then
			if curModelID == 1 then
				x = x - size.width * 0.9
				y = y + size.height * 0.01
			elseif curModelID == 2 then
				x = x - size.width * 0.9
			else
				x = x - size.width * 0.9
				y = y - size.height * 0.01
			end
		end
		local distance = cc.pGetDistance(cc.p(x, y), self["pos"..curModelID])
		distance = math.abs(distance)
		local move = cc.MoveTo:create(distance/runSpeed, cc.p(x, y))
		-- self["eff"..curModelID]:setScale(1)
		-- self["eff"..curModelID]:setPosition(x, y)
		local callback = cc.CallFunc:create(function(sender)
			self.bossPanel.model._modelNode:setColor(cc.c3b(219,76,76))
			TimerManager:addOnce(250, function()
				self.bossPanel.model._modelNode:setColor(cc.c3b(255,255,255))
			end, self)

			local code = sender.code
			-- local randomX = math.random(-40, 40)
			-- local randomY = math.random(-35, 55)
			-- local effectx = self.effectPos.x + randomX
			-- local effecty = self.effectPos.y + randomY
			-- self["effect"..(code%2)]:setPosition(effectx, effecty)
			-- self["effect"..(code%2)]:setVisible(true)
   --  		self["effect"..(code%2)]:play(false,function () self["effect"..(code%2)]:setVisible(false) end)

   --  		self["eff"..code]:setVisible(true)
    		
		        img:setVisible(false)
			-- self["eff"..code]:play(false, function()
				self["panel"..code]:setPosition(self["pos"..code])
				if code ~= 4 then
					self["panel"..code].moveing = false
				end
				self["panel"..code].model:destory()
				self["panel"..code].model = nil
				
				-- self["eff"..code]:setVisible(false)
				if isSendBattle then
				    local battleProxy = self:getProxy(GameProxys.Battle)
                    battleProxy:getWorldBossBattle()
				end
			-- end)
			if isShowText then
				self:showDamgeText(damage)
			end
			
		end)
		local action = cc.Sequence:create(cc.EaseSineIn:create(move), callback)
		self["panel"..curModelID]:runAction(action)
	end
end

function WorldBossPanel:showDamgeText(damage)
	--下面3个参数，策划调
	--飘字起始横坐标
	local hurtLabelPosX = math.random(-50, 50)
	--飘字的距离
	local distance = 180
	--飘字的时间
	local time = 0.7


	local size = self.bossPanel.model:getContentSize()
	local damageText = ComponentUtils:createTextAtlas(self.bossPanel, "num_attack_2", 34, 46)
	damageText:setString(damage)
	damageText:setPositionY(size.height + damageText:getContentSize().height*0.5*bossScale)
	local moveBy = cc.MoveBy:create(time, cc.p(hurtLabelPosX, distance))
	local hideAction = cc.CallFunc:create(function()
		damageText:removeFromParent()
	end)
	damageText:runAction(cc.Sequence:create(moveBy, hideAction))
end

--玩家攻击通知（只处理刷新玩家伤害信息），所有更新Boss信息都等320004，死亡也等320005
function WorldBossPanel:showMyAttack(data)
	if self.activityData == nil then
		return
	end
	if data == nil then
		self["panel4"].moveing = false
		return 
	end
	
    self.activityData.myDamage = data.myDamage -- 将伤害数据存储

	local myDamage = StringUtils:formatNumberByK(data.myDamage)
	self.numLab:setString(myDamage)
	--local x = self.posX + self.numLab:getContentSize().width
	--self.descLab:setPositionX(x + 3)
	myRank = myDamage
	TimerManager:addOnce(2500, function()
		self["panel4"].moveing = false
	end, self)
	
	self.init = data.state == 2
end

--更新自动战斗状态
function WorldBossPanel:updateAutoBattleState(data)
	if data.rs == 0 then
		local state = data.type
		self.activityData.autoFight = data.type
		self.autoCB:setSelectedState(state == 1)
		self.battleState = state
		local showText = ""
		if state == 1 then
			showText = TextWords:getTextWord(280134)
		else
			showText = TextWords:getTextWord(280135)
		end
		self:showSysMessage(showText)
	else
		--协议返回不成功，还原checkbox的状态
		self.autoCB:setSelectedState(self.battleState == 1)
	end
end

--更新排行榜数据
function WorldBossPanel:updateRankView(info)
	--更新我的排名
	local myRankStr = self.proxy:getMyRank() <= 0 and TextWords:getTextWord(1706) or string.format(TextWords:getTextWord(280140), tostring(self.proxy:getMyRank()))
	self.descLab:setString(myRankStr)
	local data = info.ranks
	local rank = self.proxy:getMyRank()
	for k,v in pairs(data) do
		rawset(data[k], "rankValue", v.damage)
	end
	local rankInfo = {}
	rankInfo.activityRankInfos = data
	rankInfo.myRankInfo = {rank = rank, rankValue = myRank}
	
	if self.rankPanel ~= nil then
		self.rankPanel:updateData({rankData = rankInfo, num = myRank, rankID = info.rankId, titleText = TextWords:getTextWord(280130)})
	else
		self.rankPanel = UIRankPanel.new(self:getParent(), self, function()
			TimerManager:remove(self.sendRankInfoReq, self)
		end, {rankData = rankInfo, num = myRank, rankID = info.rankId, titleText = TextWords:getTextWord(280130)})
	end
end

function WorldBossPanel:sendRankInfoReq()
	self.proxy:onTriggerNet320006Req({monsterId = self.activityData.monsterId})
end

--活动等级限制
function WorldBossPanel:isCanJoin()
	local result = self.proxy:isUnlock(true) ----判定是否够等级开启
	return result
end

--设置阵型通知修改队伍图标
function WorldBossPanel:setTeamIcon(data)
	self.activityData.teamIcon = data
end

--Boss死亡通知
function WorldBossPanel:bossDied(data)
	self.activityData.killerName = data.killerName
	self.bossDie = true
	self:resetData(data.isKill == 1)
end

--消除冷却
function WorldBossPanel:cancelColdDown()
	self.proxy:cancelColdDown(self.activityData.activityId)
	self.isColdDowning = false
	local coolLab = self:getChildByName("bottomPanel/coolLab")
	coolLab:setVisible(false)
end

--撤军
function WorldBossPanel:activityEnd()
-- 	self.activityData.killerName = ""
-- 	self.bossDie = true
-- 	self:resetData()
end

--活动结束，重置数据
function WorldBossPanel:resetData(isDied)
	TimerManager:remove(self.showBossTalk, self)
	self:stopBgMove()
	self.rootNode:setVisible(false)
	self.autoCB:setSelectedState(false)
	self.battleState = 0
	self.activityData.autoFight = 0
	self.proxy:setStateById(self.activityData.activityId, 0)
	self.proxy:updateActivityState(self.activityData.activityId)
	self:cancelColdDown(self.activityData.activityId)
	local proxy = self:getProxy(GameProxys.Soldier)
	proxy:resetWorldBossTeam()

	for i=1,4 do
		self["panel"..i]:stopAllActions()
		self["panel"..i].moveing = false
		self["panel"..i]:setPosition(self["pos"..i])
		if self["panel"..i].model ~= nil then
			self["panel"..i].model:destory()
			self["panel"..i].model = nil
		end
	end
	if isDied then
		if self.bossPanel.model ~= nil then
			local function callback()
				self:initView()
			end
			self.bossPanel.model:playAnimation("die", false, callback)
		end
	else
		self:initView()
	end
	
end

--策划调整位置
function WorldBossPanel:setBossPosition()
    self.bossPanel:setPosition(400,300)
    self.bossPos = cc.p(400,300)
end

--策划调整位置
function WorldBossPanel:setOtherPosition()
    self["panel1"]:setPosition(-200,400)
    self["panel2"]:setPosition(-200,250)
    self["panel3"]:setPosition(-200,100)
    self["panel4"]:setPosition(-200,100)
    self.pos4 = cc.p(-200,100)
    self.pos1 = cc.p(-200,400)
    self.pos2 = cc.p(-200,250)
    self.pos3 = cc.p(-200,100)
end

-- 模块关闭事件回调
function WorldBossPanel:hideModuleHandler()
    TimerManager:remove(self.sendRankInfoReq, self)
    TimerManager:remove(self.showBossTalk, self) 
    self:stopBgMove() -- 关闭模块的时候进行去除定时器，stop

	self._frameQueue:clear()
	self._attackQueue:clear()
	for i=1,3 do
		local img = self:getChildByName("middlePanel/Panel_"..i.."/teamImg/stateImg")
		img:stopAllActions()
		img:setScale(1)
	end
	self.proxy:onTriggerNet320007Req({type = EXIT_CODE})
	self.init = false
end