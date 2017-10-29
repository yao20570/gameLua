-------------------------打造界面------------------------------------
PartsGodCreateMainPanel = class("PartsGodCreateMainPanel", BasicPanel)
PartsGodCreateMainPanel.NAME = "PartsGodCreateMainPanel"

function PartsGodCreateMainPanel:ctor(view, panelName)
    PartsGodCreateMainPanel.super.ctor(self, view, panelName)
    self._isPlayFree = nil
    --self._movieChip = nil
end

local showTenList = {0.20,0.25,0.30,0.25,0.20,
                     0.15,0.20,0.25,0.20,0.15,
	                 0.10,0.15,0.20,0.15,0.10,
                     0.02,0.10,0.15,0.10,0.02}


local showTenMoveList = {0.71,0.41,0.30,0.51,0.75,
                         0.21,0.11,0.01,0.21,0.25}

function PartsGodCreateMainPanel:finalize()
	--self._movieChip:finalize()
	--self._movieChip = nil
	if self._texturecycle then
		self._texturecycle:finalize()
	end
    PartsGodCreateMainPanel.super.finalize(self)
end

function PartsGodCreateMainPanel:onClosePanelHandler()
	--self._movieChip:stopAllActions()
	self:dispatchEvent(PartsGodEvent.HIDE_SELF_EVENT)
end

function PartsGodCreateMainPanel:initPanel()
	PartsGodCreateMainPanel.super.initPanel(self)
	self._top_panel = self:getChildByName("top_panel")
	
	self._one_btn = self:getChildByName("bottom_panel/one_btn")
	self._ten_btn = self:getChildByName("bottom_panel/ten_btn")
	self._free_btn = self:getChildByName("bottom_panel/free_btn")
	self._tipinfo_panel = self:getChildByName("tipinfo_panel")
	self._gift_panel = self._top_panel:getChildByName("gift_panel")
	self._twenty_panel = self._top_panel:getChildByName("twenty_panel")
	self._down_panel = self:getChildByName("bottom_panel")
	--self._down_panel = bottom_panel
    
	self._down_panel:setLocalZOrder(10)
	self._free_btn._type = 0
	self._one_btn._type = 1
	self._ten_btn._type = 10

	self._top_panel:setVisible(true)
	self._down_panel:setVisible(true)
	self._tipinfo_panel:setVisible(false)
	self._gift_panel:setVisible(false)
	self._twenty_panel:setVisible(true)

	self:initMoney()
	-- self:adjustBootomBg(bottom_panel, self._top_panel,true)
	TimerManager:addOnce(5,self.onShowAllPartsGoods, self)

	self:preLoadAnimation()
end

	-- local movieChip = UICCBLayer.new("rgb-jxsj-bao", parent, nil, nil, true)
 --    local size = parent:getContentSize()
 --    movieChip:setPosition(size.width / 2, size.height + 45)


-- 预加载特效资源
function PartsGodCreateMainPanel:preLoadAnimation()
    local effectTab = {"rpg-flash"}--, "rpg-handles" }--, "rpg-texturecycle", "rpg-handlescycle"}
    --local effectTab = {"rpg-handles", "rpg-texturecycle", "rpg-handlescycle"}
    local url = nil
    for k,v in pairs(effectTab) do
    	url = "effect/frame/" .. v .. ".plist"
    	-- print(k,v,url)
    	cc.SpriteFrameCache:getInstance():addSpriteFrames(url)
    end
end


function PartsGodCreateMainPanel:registerEvents()
	PartsGodCreateMainPanel.super.registerEvents(self)

	self._info_btn = self._twenty_panel:getChildByName("info_btn")
	--self._rank_btn = self:getChildByName("bottom_panel/rank_btn")
	self._sure_btn = self:getChildByName("Panel_16/sure_btn")
	self._sure_btn:setVisible(false)

	self:addTouchEventListener(self._info_btn,self.onShowTipInfoHandle)
	--self:addTouchEventListener(self._rank_btn,self.onShowPartsGodRankPanelHandle)
	self:addTouchEventListener(self._free_btn,self.onCreatePartsActHandle)
	self:addTouchEventListener(self._one_btn,self.onCreatePartsActHandle)
	self:addTouchEventListener(self._ten_btn,self.onCreatePartsActHandle)
	self:addTouchEventListener(self._tipinfo_panel,self.onShowTipInfoHandle)
	self:addTouchEventListener(self._sure_btn,self.onHideGiftPanelHandle)
end

function PartsGodCreateMainPanel:initMoney()
	local config = ConfigDataManager:getInfoFindByOneKey("OrdnanceForgingConfig","ID",1)
	local one_money_label = self._one_btn:getChildByName("money_label")
	local ten_money_label = self._ten_btn:getChildByName("money_label")
	one_money_label:setString(config.price)
	ten_money_label:setString(config.tenprice)
	self._one_btn.price = config.price
	self._ten_btn.price = config.tenprice
end

-------初始化读配置表显示20个奖励-----------
function PartsGodCreateMainPanel:onShowAllPartsGoods()
	local twenty_panel = self._top_panel:getChildByName("twenty_panel")
	twenty_panel:setVisible(true)
	local proxy = self:getProxy(GameProxys.Activity)
	local activityData = proxy:getLimitActivityDataByUitype( ActivityDefine.LIMIT_ACTION_ORDNANCEFORGING_ID )
	local effectId = activityData.effectId
	local index = 1
	local rewardgroup = ConfigDataManager:getInfoFindByOneKey("OrdnanceForgingConfig","ID", effectId).rewardgroup
	local config = ConfigDataManager:getConfigData(ConfigData.CurrentRewardConfig)
	for _,v in pairs(config) do
		if v.rewardgroup == rewardgroup then
			local Panel = twenty_panel:getChildByName("Panel"..index)
			local x,y = Panel:getPosition()
			Panel._pos = cc.p(x,y)
			self:onUpdateIcon(v.item,Panel,v.ntegral, nil, true)
			index = index + 1
		end
		if index >= 21 then
			break
		end
	end

	local ten_panel = self._gift_panel:getChildByName("ten_panel")
	local PanelOne = self._gift_panel:getChildByName("Panel1")

	--20个物品的移动目标
	self._targetPanel = self:getChildByName("bottom_panel/targetPanel")
	local worldPos = self._targetPanel:getWorldPosition()
	local pos = self._twenty_panel:convertToNodeSpace(worldPos)
	-- print("pos.x===",pos.x)
	-- print("pos.y===",pos.y)
	self._targetPanel._posX = pos.x
	self._targetPanel._posY = pos.y

	--1个奖励的移动目标
	self._targetPanelOne = self:getChildByName("bottom_panel/targetPanel")
	local x,y = self._targetPanelOne:getPosition()
	self._targetPanelOne._pos = pos 

	--10个奖励的移动目标
	self._targetPanelTen = self:getChildByName("bottom_panel/targetPanel")
	local x,y = self._targetPanelTen:getPosition()
	self._targetPanelTen._pos = pos
	
	for index = 1, 10 do
		local Panel = ten_panel:getChildByName("Panel"..index)
		local x,y = Panel:getPosition()
		Panel._pos = cc.p(x,y)
	end
	local x,y = PanelOne:getPosition()
	PanelOne._pos = cc.p(x,y)

	self:onMoveToSrc(ten_panel,10,true,self._targetPanelTen,nil,true)
	self:onMoveToSrc(self._gift_panel,1,true,self._targetPanelOne,nil,true)

    if self._texturecycle == nil then
	    local Image_3 = self:getChildByName("Panel_16/Image_3")
	    local size = Image_3:getContentSize()
	    local movieChip = self:createUICCBLayer("rgb-jxsj-xunhuang", Image_3)
	    movieChip:setPosition(size.width / 2 - 2.5, size.height * 0.35)
	    self._texturecycle = movieChip
    end
end

--function PartsGodCreateMainPanel:onPlayRankRpg()
--	if not self._movieChip then
--		self._movieChip = UIMovieClip.new("rpg-listof")
--		self._movieChip:setParent(self._rank_btn)
--		self._movieChip:setLocalZOrder(10)
--		local size = self._rank_btn:getContentSize()
--		self._movieChip:setPosition(size.width / 2, size.height / 2)
--	end
--	self._movieChip:play(true)
--end

function PartsGodCreateMainPanel:onShowHandler()
	--TimerManager:addOnce(5,self.onPlayRankRpg, self)
	local proxy = self:getProxy(GameProxys.Activity)
	self._partsGodInfos = proxy:getPartsGodInfos()

    --local isVisible = self._gift_panel:isVisible()
    --if isVisible == false then
	--    self:onShowBtnStatus()
    --end
     
    self.isFinish = true--上次的动画是否播放完毕

	local isShow = false
	local noShow = true
	local canUsefreeTime = proxy:getPartsGodFreeTime()
	if canUsefreeTime > 0 then
		isShow = true
		noShow = false
		self._isPlayFree = true
	end
	-- if rawget(self._partsGodInfos,"ordnanceTime")  ~= nil then --查看当前是否是免费锻造
	-- 	isShow = true
	-- 	noShow = false
	-- 	self._isPlayFree = true
	-- end
	self._free_btn:setVisible(isShow)
	self._one_btn:setVisible(noShow)

	local time_label = self._twenty_panel:getChildByName("time_label")
	-- local benginTime = TimeUtils:setTimestampToString(self._partsGodInfos.startTime)
	-- local endTime = TimeUtils:setTimestampToString(self._partsGodInfos.endTime)
	-- time_label:setString(benginTime.." - "..endTime)
	time_label:setString(TimeUtils.getLimitActFormatTimeString(self._partsGodInfos.startTime,self._partsGodInfos.endTime))
	local descLab = self._twenty_panel:getChildByName("descLab")
	descLab:setString(self:getTextWord(260001))
    descLab:setColor(cc.c3b(244,244,244))
end

-------是否显示小提示界面-----------
function PartsGodCreateMainPanel:onShowTipInfoHandle(sender)
	if sender == self._info_btn then
		self._tipinfo_panel:setVisible(true)
	else
		self._tipinfo_panel:setVisible(false)
	end
end

-------隐藏奖励界面-----------
function PartsGodCreateMainPanel:onHideGiftPanelHandle(sender)
	self._down_panel:setVisible(true)
	--self:setCloseBtnStatus(true)
	sender:setVisible(false)
	self:onShowBtnStatus(false)

	local function call()
		self._twenty_panel:setVisible(true)
		self._gift_panel:setVisible(false)
		self:onMoveToSrc(self._twenty_panel,20,false,nil,true)
		--local function showBtn()
		-- 	self:onShowBtnStatus()
		--end
		--TimerManager:addOnce(500,showBtn,self)
		self:onShowBtnStatus()
	end
	
	if self._sendType ~= 10 then
		self:onMoveToSrc(self._gift_panel,1,true,self._targetPanelOne,nil,true,call)
	else
		local ten_panel = self._gift_panel:getChildByName("ten_panel")
		self:onMoveToSrc(ten_panel,10,true,self._targetPanelTen,nil,true,call)
	end
	-- self._handlescycle:removeFromParent()
	--self._texturecycle:removeFromParent()
end

-------跳转到排行榜界面-----------
--function PartsGodCreateMainPanel:onShowPartsGodRankPanelHandle()
--	local proxy = self:getProxy(GameProxys.Activity)
--	local rankingID = proxy:getCurActivityData().rankId
--	-- local rankingID = ConfigDataManager:getInfoFindByOneKey("OrdnanceForgingConfig","ID",1).rankingID
--	local configData = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, rankingID)
--	local rankingreward = configData.rankingreward
--	local proxy = self:getProxy(GameProxys.Activity)
--	proxy.rankingID = rankingreward
--	local id = self.view:getActivityId()
--	local rankInfo = proxy:getRankInfoById()
--
--
--	-- if self.rewardData == nil then
--	-- 	local config = ConfigDataManager:getConfigData("CRankingRewardConfig")
--	-- 	local rewardData = {}
--	-- 	for k,v in pairs(config) do
--	-- 		if v.rankingreward == rankingreward then
--	-- 			table.insert(rewardData, v)
--	-- 		end
--	-- 	end
--	-- 	table.sort( rewardData, function(a, b)
--	--     	return a.ID < b.ID
--	-- 	end )
--	-- 	self.rewardData = rewardData
--	-- end
--
--
--	local text = string.format(TextWords:getTextWord(280003), configData.ntegralcondition, configData.levelcondition, configData.number)
--
--	if self.rankPanel == nil then
--		self.rankPanel = UIRankPanel.new(self:getParent(), self, nil, {rankData = rankInfo, num = self.view:onGetScore(), tipText = text, rankID = rankingreward})
--		self.rankPanel:setTitle(true,"partsGod",true)
--	else
--		self.rankPanel:updateData({rankData = rankInfo, num = self.view:onGetScore(), tipText = text, rankID = rankingreward})
--	end
--end
--
--function PartsGodCreateMainPanel:updateRankData()
--	if self.rankPanel ~= nil and self.rankPanel._uiSkin:isVisible() then
--		-- local rankingID = ConfigDataManager:getInfoFindByOneKey("OrdnanceForgingConfig","ID",1).rankingID
--		-- local rankingreward = ConfigDataManager:getInfoFindByOneKey("CurrentRankingConfig","ID",rankingID).rankingreward
--		local proxy = self:getProxy(GameProxys.Activity)
--		local rankingID = proxy:getCurActivityData().rankId
--		local configData = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, rankingID)
--		local rankingreward = configData.rankingreward
--		self.rankPanel:updateData({rankingID = rankingreward, num = self.view:onGetScore()})
--	end
--end

-------三种方式的锻造-----------
function PartsGodCreateMainPanel:onCreatePartsActHandle(sender)
	local data = {}
	data.type = sender._type
	self._sendType = sender._type
	data.activityId = self.view:getActivityId()
	if sender._type == 0 then --免费
		self._isPlayFree = nil
		self:dispatchEvent(PartsGodEvent.PARTS_CREATE_REQ, data)
	elseif sender._type == 1 or sender._type == 10 then --单次或者10次
		local roleProxy = self:getProxy(GameProxys.Role)
    	local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0
    	if sender.price > haveGold then  --元宝不足
    		local parent = self:getParent()
        	local rechargePanel = parent.rechargePanel
        	if rechargePanel == nil then
            	local panel = UIRecharge.new(parent, self)
            	parent.rechargePanel = panel
        	else
            	rechargePanel:show()
        	end
        else
        	local function ok()
        		self:dispatchEvent(PartsGodEvent.PARTS_CREATE_REQ, data)
        	end
        	local messageBox = self:showMessageBox(string.format(self:getTextWord(560),sender.price),ok)
        	messageBox:setGameSettingKey(GameConfig.PAYTWOCONFIRM)
    	end
	end
end

function PartsGodCreateMainPanel:onUpdateIcon(data, panel, ntegral, isShowName, isFixReward)
	local iconInfo = {}
	if isFixReward == true then
		local list = StringUtils:jsonDecode(data)
		iconInfo.power = list[1][1]
		iconInfo.typeid = list[1][2]
		iconInfo.num = list[1][3]
		iconInfo.otherInfo = string.format("抽中可获得积分："..ntegral)
	else
		iconInfo = data
		rawset(iconInfo, "otherInfo", string.format("抽中可获得积分：" .. ntegral))
		rawset(iconInfo, "typeid", iconInfo.typeId)
	end

	if panel.uiIcon ~= nil then
		panel.uiIcon:finalize()
		panel.uiIcon = nil
	end

	--if panel.uiIcon == nil then
	local icon
	if isShowName == true then
		icon = UIIcon.new(panel,iconInfo,true,self,nil,true)
	else
		icon = UIIcon.new(panel,iconInfo,true,self)
	end
	panel.uiIcon = icon

    if panel.effectImg == nil then
        panel.effectImg = TextureManager:createSprite("images/partsGod/pinzi-bai.png")
        panel.effectImg:setLocalZOrder(100)
        panel.effectImg:setPosition(cc.p(10, 10))
        panel:addChild(panel.effectImg)
        panel.effectImg:setOpacity(0)
    end
	-- else
	-- 	panel.uiIcon:updateData(iconInfo)
	--end
end

-------锻造返回的奖励-----------
function PartsGodCreateMainPanel:onGetRewardResp(data)
    self.isFinish = false
	--print("======end time=====",os.clock())
	--self._rank_btn:setVisible(false)
	self._rewardData = data
	self._down_panel:setVisible(false)
	--self:setCloseBtnStatus(false)
	self:onPlayAnimation()
end

function PartsGodCreateMainPanel:onFinallyGetReward()
    self.isFinish = true
	self._gift_panel:setVisible(true)
	local ten_panel = self._gift_panel:getChildByName("ten_panel")
	local PanelOne = self._gift_panel:getChildByName("Panel1")
	local iconInfo = {}

	local function showSureBtn()
		self._sure_btn:setVisible(true)
	end
	local showSureBtnFun =  cc.CallFunc:create(showSureBtn)
    
    local actionTime = 0.2
	if table.size(self._rewardData.ordnanceInfo) == 10 then  --十连抽效果
		ten_panel:setVisible(true)
		PanelOne:setVisible(false)
		local index = 1
		for _,v in pairs(self._rewardData.ordnanceInfo) do
			local Panel = ten_panel:getChildByName("Panel"..index)
			self:onUpdateIcon(v, Panel, v.integral, true)
			--local time = math.random()
			local fadeIn = cc.FadeIn:create(0.01)
			local bezierSum = {cc.p(334, 48),cc.p(329,154),Panel._pos}
    		local bezierTo = cc.BezierTo:create(actionTime, bezierSum)
    		local scaleTo = cc.ScaleTo:create(actionTime,1.0)

    		local spawn = cc.Spawn:create(bezierTo,scaleTo)
    		--local moveto = cc.MoveTo:create(0.5,Panel._pos)
    		-- local function showFunAcytion()
    		-- 	Panel:setVisible(true)
    		-- end
    		-- local showFun = cc.CallFunc:create(showFunAcytion)
    		local function hideFalsh()
    			-- print("播放放加加1")
    			self:onShowflashAction(Panel)
    		end
    		local hideFun = cc.CallFunc:create(hideFalsh)
    		local delayAll = cc.DelayTime:create(showTenMoveList[index])
    		if index == 10 then
    			local delay = cc.DelayTime:create(1.0)
    			Panel:runAction(cc.Sequence:create(delayAll,cc.MoveTo:create(0.01, cc.p(334, 48)), fadeIn,spawn,hideFun,delay,showSureBtnFun)) 
    		else
    			local delay = cc.DelayTime:create(0.5)
    			Panel:runAction(cc.Sequence:create(delayAll,cc.MoveTo:create(0.01, cc.p(334, 48)), fadeIn,spawn,hideFun))
    		end
            Panel.effectImg:setOpacity(255)
            Panel.effectImg:runAction(cc.Sequence:create(cc.FadeTo:create(actionTime * 2.5, 180), cc.FadeOut:create(0.2)))
			index = index + 1
		end
	else
		ten_panel:setVisible(false)
		PanelOne:setVisible(true)
		-- print("self._rewardData.rewardId[1]===",self._rewardData.rewardId[1])		
		self:onUpdateIcon(self._rewardData.ordnanceInfo[1], PanelOne, self._rewardData.ordnanceInfo[1].integral, true)
		local time =  0.5--math.random()
		local fadeIn = cc.FadeIn:create(0.01)
		local bezierSum = {cc.p(334, 48),cc.p(329,154),PanelOne._pos}
    	local bezierTo = cc.BezierTo:create(time, bezierSum)
    	local delay = cc.DelayTime:create(0.2)
    	local scaleTo = cc.ScaleTo:create(time,1.0)

    	local spawn = cc.Spawn:create(bezierTo,scaleTo)
    	local function hideFalsh()
    		--self:onShowflashAction(PanelOne)
    		local size = PanelOne:getContentSize()
    		local movieChip = self:createUICCBLayer("rgb-jxsj-wupin", PanelOne, nil, nil, true)
			--movieChip:setPosition(size.width / 2-12, size.height-20 )
			movieChip:setPosition(size.width / 2, size.height - 10)
    	end
    	local hideFun = cc.CallFunc:create(hideFalsh)
    	PanelOne:runAction(cc.Sequence:create(cc.MoveTo:create(0.01, cc.p(334, 48)), fadeIn,spawn,delay,hideFun,showSureBtnFun))
        PanelOne.effectImg:setOpacity(255)
        PanelOne.effectImg:runAction(cc.Sequence:create(cc.FadeTo:create(time, 180), cc.FadeOut:create(0.2)))
	end
end

--------奖励闪闪发光的特效------------十连抽
function PartsGodCreateMainPanel:onShowflashAction(parent)
    parent.effectImg:setOpacity(0)
	local movieChip = self:createUICCBLayer("rgb-jxsj-wupin", parent, nil, nil, true)
    --movieChip:setParent(parent)
    --parent.movieChip = movieChip
    local size = parent:getContentSize()
    movieChip:setPosition(size.width * 0.5 , size.height - 10)
    --movieChip:play(false,function () movieChip:removeFromParent() end)
end


function PartsGodCreateMainPanel:onShowBtnStatus(status)
	if status ~= nil then
		self._one_btn:setVisible(status)
		self._free_btn:setVisible(status)
		self._ten_btn:setVisible(status)
		return
	end

	if self._isPlayFree == nil then
		self._one_btn:setVisible(true)
		self._free_btn:setVisible(false)
		-- rawset(self._partsGodInfos,"ordnanceTime",nil)
	else
		self._one_btn:setVisible(false)
		self._free_btn:setVisible(true)
	end
	self._ten_btn:setVisible(true)
	--self._rank_btn:setVisible(true)
end

-------物品位置移动-------------1.parent:物品的父节点 2.count:物品数目 3.是否移动到下面火炉目标的位置 4.火炉目标 5和6.是否执行Fade动作
function PartsGodCreateMainPanel:onMoveToSrc(parent,count,isMoveToTarget,target,isFadeIn,isFadeOut,FadeOutFun)
	if isMoveToTarget == true then  --移动到下面的位置
		for index = 1,count do
			local item = parent:getChildByName("Panel"..index)
			--item:setPosition(target._pos)
			if isFadeOut == true then
				--local time = math.random()
				local fadeOut = cc.FadeOut:create(showTenList[index])
				local moveto = cc.MoveTo:create(0.001,target._pos)
				local scaleTo = cc.ScaleTo:create(0.001,0.2)
				if index ~= 1 then
					item:runAction(cc.Sequence:create(fadeOut,moveto,scaleTo))
				else
					local function callFun()
						if FadeOutFun ~= nil then
							FadeOutFun()
						end
					end
					local fun = cc.CallFunc:create(callFun)
					item:runAction(cc.Sequence:create(fadeOut,moveto,scaleTo,fun))
				end
			else
				item:setVisible(false)
			end
		end
	else --还原到原来的位置
		for index = 1,count do
			local item = parent:getChildByName("Panel"..index)
            item.effectImg:setOpacity(0)
            item:setScale(1.0)
			item:setPosition(item._pos)
			if isFadeIn == true then
				local time = math.random()
				local fadeIn = cc.FadeIn:create(time)
				item:runAction(fadeIn)
			end
		end
	end
end

-------奖励出来的动画-----------
function PartsGodCreateMainPanel:onPlayAnimation()
	local funMap = {}
	for index = 1, 20 do
			local Panel = self._twenty_panel:getChildByName("Panel"..index)
			local time = 0.3 
			local fadeout = cc.FadeOut:create(time)
			local bezierSum = {cc.p(329,154),cc.p(334, 48),cc.p(self._targetPanel._posX,self._targetPanel._posY)}
    		local actionTime = 0.5
    		if index ~= 20 then
    			local bezierTo = cc.BezierTo:create(time, bezierSum)
    			local delay
    			--if index ~= 1 then
    			--	delay = cc.DelayTime:create(showTenList[index])
    			--else
    			--	delay = cc.DelayTime:create(0.01)
    			--end
                delay = cc.DelayTime:create(showTenList[index])
                local scale = cc.ScaleTo:create(time, 0.4)

                local moveFadeOut = cc.Spawn:create(bezierTo, fadeout, scale)
    			local seq = cc.Sequence:create(delay, moveFadeOut)
    			--local speed = cc.Speed:create(seq,2*index)
				Panel:runAction(seq)
			else
				local bezierTo = cc.BezierTo:create(time, bezierSum)
				local Image_3 = self:getChildByName("Panel_16/Image_3")
				local size = Image_3:getContentSize()

				local function showHandleAndCycleAction()
			    	local movieChip = self:createUICCBLayer( "rgb-jxsj-bao", Image_3, nil, nil, true ) --UIMovieClip.new("rpg-handles")
			    	-- movieChip:setParent(Image_3)
			    	movieChip:setLocalZOrder(20)
			    	-- movieChip:play(false,function () movieChip:removeFromParent() end)
			    	movieChip:setPosition(size.width / 2, size.height *0.45)
			    	-- self._handles = movieChip
    			end

    			local fireAction = cc.CallFunc:create(showHandleAndCycleAction)

    			local function showGiftAction()
    				self:onFinallyGetReward()
    			end
    			local giftAction = cc.CallFunc:create(showGiftAction)

			    local function handlesFun()
			    	-- local movieChip = UIMovieClip.new("rpg-texturecycle")
			    	-- movieChip:setParent(Image_3)
			    	-- movieChip:play(true)
			    	-- movieChip:setPosition(size.width / 2 - 2.5, size.height / 2.7-2)
			    	-- self._texturecycle = movieChip

			    	-- local movieChip = UIMovieClip.new("rpg-handlescycle")
			    	-- movieChip:setParent(Image_3)
			    	-- movieChip:play(true)
			    	-- movieChip:setPosition(size.width / 2, size.height + 45)
			    	-- self._handlescycle = movieChip

			    	--self:onFinallyGetReward()
    			end
    			local _handlesFun = cc.CallFunc:create(handlesFun)

    			local delayHanles = cc.DelayTime:create(0.5)
    			local delayLay = cc.DelayTime:create(0.35)

    			--local seqAction = cc.Sequence:create(fireAction,delayHanles,_handlesFun,delayLay,giftAction)
    			local seqAction = cc.Sequence:create(fireAction, giftAction)

				local delay = cc.DelayTime:create(0.3)

				local function hideTwenty( )
					self._twenty_panel:setVisible(false)
				end

				local hideTwentyAction = cc.CallFunc:create(hideTwenty)

				local delay2 = cc.DelayTime:create(0.03)
                
				local delay3 = cc.DelayTime:create(0.1)

                local delay0 = cc.DelayTime:create(showTenList[index])
                
                local scale = cc.ScaleTo:create(time, 0.4)

                local moveFadeOut = cc.Spawn:create(bezierTo, fadeout, scale)
				Panel:runAction(cc.Sequence:create(delay0, moveFadeOut,delay,hideTwentyAction, delay3, seqAction))
			end
            Panel.effectImg:setOpacity(180)
            Panel.effectImg:runAction(cc.FadeTo:create(actionTime * 2, 255))
	end
end