-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2016-12-08
--  * @Description: 春节活动-爆竹酉礼活动页
--  */
SpringSquibMainPanel = class("SpringSquibMainPanel", BasicPanel)
SpringSquibMainPanel.NAME = "SpringSquibMainPanel"

function SpringSquibMainPanel:ctor(view, panelName)
    SpringSquibMainPanel.super.ctor(self, view, panelName)

end

function SpringSquibMainPanel:finalize()

	for i=1,6 do
		if self["tipEffect" .. i] ~= nil then
			self["tipEffect" .. i]:finalize()
    		self["tipEffect" .. i] = nil
		end
		if self["tip2Effect" .. i] ~= nil then
			self["tip2Effect" .. i]:finalize()
    		self["tip2Effect" .. i] = nil
		end
		if self["SquibEffect" .. i] ~= nil then
			self["SquibEffect" .. i]:finalize()
    		self["SquibEffect" .. i] = nil
		end
	end
	if self.progressBarEffect ~= nil then
		self.progressBarEffect:finalize()
		self.progressBarEffect = nil
	end

    SpringSquibMainPanel.super.finalize(self)
end

function SpringSquibMainPanel:initPanel()
	SpringSquibMainPanel.super.initPanel(self)


	for i=1,6 do
		local img = self:getChildByName("topPanel/imgPanel/panel" .. i)
		img.pos = i
		self:addTouchEventListener(img, self.onTouchImgHandler)
	end
	local infoLab = self:getChildByName("topPanel/infoPanel/infoLab")
	infoLab:setString(self:getTextWord(390002))


	self.proxy = self:getProxy(GameProxys.Activity)

	self.effectShowing = false
	--记录六个爆竹特效状态 0未初始化或者重置 1未点燃的爆竹初始化时的静态 2随机摆动的为点燃的爆竹 3正在点燃的爆竹 4点燃后的爆竹盒子
	for i=1,6 do
		self["SquibEffectState" .. i] = 0
	end


end

function SpringSquibMainPanel:onShowHandler()
	self:updateMainPanel()
end

function SpringSquibMainPanel:updateMainPanel()
	--今天充值数
	local moneyLab = self:getChildByName("topPanel/infoPanel/moneyLab")
	--今天剩余点燃次数
	local remainLab = self:getChildByName("topPanel/infoPanel/remainLab")
	local remainLabTitle = self:getChildByName("topPanel/infoPanel/numLab_2")
	local tipLab = self:getChildByName("topPanel/infoPanel/tipLab")
	local topPanel = self:getChildByName("topPanel")

	local progressBar = self:getChildByName("topPanel/infoPanel/barPanel/progressBar")
	local barEffectPanel = self:getChildByName("topPanel/infoPanel/barPanel/barEffectPanel")
	local tailImg = self:getChildByName("topPanel/infoPanel/barPanel/barEffectPanel/tailImg")
	local imgPanel = self:getChildByName("topPanel/imgPanel")

	local gotLabArr = {}
	for i=1,6 do
		local gotLab = self:getChildByName("topPanel/infoPanel/gotLab" .. i)
		table.insert(gotLabArr, gotLab)
	end


	local roleProxy = self:getProxy(GameProxys.Role)
	local chargeValue = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_today_charge)
	moneyLab:setString(chargeValue)
	local activityProxy = self:getProxy(GameProxys.Activity)

	--获得获得数据
	self.myData = self.proxy:getCurActivityData()

	local posInfo = self.proxy:getSquibPosInfos(self.myData.activityId)
    -- print(posInfo == {})
    -- for key, var in pairs(posInfo) do
    --     print(key,var)
    -- end
	local timeDescLab = self:getChildByName("topPanel/infoPanel/timeInfoLab")
	-- local startTime = self:timestampToString(self.myData.startTime)
	-- local endTime = self:timestampToString(self.myData.endTime)
	-- if startTime == 0 or endTime == 0 then
	-- 	timeDescLab:setString("")
	-- else
	-- 	timeDescLab:setString(string.format("%s%s%s%s", self:getTextWord(392006),startTime,self:getTextWord(392008),endTime))
	-- end
	timeDescLab:setString(TimeUtils.getLimitActFormatTimeString(self.myData.startTime,self.myData.endTime,true))
	--点过就有数据
	----[[

	for index=1,6 do
		local inArr = false
		for _,pos in ipairs(posInfo) do
			if tonumber(pos) == index then
				inArr = true
				break
			end
		end
		if inArr == true then
			local img = self:getChildByName("topPanel/imgPanel/panel" .. index)
			local imgSize = img:getContentSize()
			if self["SquibEffectState" .. index] == 0 then
				self["SquibEffect" .. index] = UICCBLayer.new("rgb-cjhd-hezi", img)
				self["SquibEffectState" .. index] = 4  
			    self["SquibEffect" .. index]:setPosition(imgSize.width*0.5,imgSize.height*0.64)
			elseif self["SquibEffectState" .. index] == 4 then
			else
				self["SquibEffect" .. index]:finalize()
				self["SquibEffect" .. index] = UICCBLayer.new("rgb-cjhd-hezi", img)
				self["SquibEffectState" .. index] = 4  
			    self["SquibEffect" .. index]:setPosition(imgSize.width*0.5,imgSize.height*0.64)
			end
		else				
			if self["SquibEffect" .. index] ~= nil then
				self["SquibEffect" .. index]:finalize()
			end
			self["SquibEffectState" .. index] = 0
		end
	end
	for i=1,6 do
		if self["SquibEffectState" .. i] == 0 then
			local img = self:getChildByName("topPanel/imgPanel/panel" .. i)
			local imgSize = img:getContentSize()
			self["SquibEffect" .. i] = UICCBLayer.new("rgb-cjhd-yaobaidan", img)
			self["SquibEffectState" .. i] = 1  
		    self["SquibEffect" .. i]:setPosition(imgSize.width*0.5,imgSize.height*0.64)
		end
	end
	--]]
	--延时将状态1的转换成状态2
	self:delayChangeState()

	-- print("posInfo" .. #posInfo)

	--进度条
	local config = ConfigDataManager:getConfigData(ConfigData.FirecrackerConfig)
	local percentNum = self:percentHandler(chargeValue,config)
	progressBar:setPercent(	percentNum)
	tailImg:setVisible(false)
	-- tailImg:setPosition(barEffectPanel:getContentSize().width*percentNum/100,barEffectPanel:getContentSize().height*0.3)
	if percentNum < 100  then
		if self.progressBarEffect == nil then
			self.progressBarEffect = UICCBLayer.new("rgb-cjhd-jidutiao", barEffectPanel)
			self.progressBarEffect:setPosition(barEffectPanel:getContentSize().width*percentNum/100,barEffectPanel:getContentSize().height*0.5)
			self.progressBarEffect:setLocalZOrder(5)
		else
			self.progressBarEffect:setPosition(barEffectPanel:getContentSize().width*percentNum/100,barEffectPanel:getContentSize().height*0.5)
		end
	else
		if self.progressBarEffect ~= nil then
			self.progressBarEffect:finalize()
    		self.progressBarEffect = nil
		end
	end


	-- self.progressBarEffect = UICCBLayer.new("rgb-cjhd-jidutiao", tailImg, nil, nil,false)

    -- self["tipEffect" .. i]:setPosition(size.width*(i/6) + tailImg:getContentSize().width/2,size.height*0.8 + tailImg:getContentSize().height/2)
    -- self.progressBarEffect:setLocalZOrder(10)




	--进度条上的能点的提示特效
	local canTouchNum = self.proxy:getSquibCanTouchTime(self.myData.activityId)
	local frontNum = self:getNumOfFront()

	remainLab:setString(canTouchNum)
	--显示已点文本的个数
	local showTipsNum = frontNum - canTouchNum
	for i=1,6 do
		if i <= showTipsNum then
			gotLabArr[i]:setVisible(true)
		else
			gotLabArr[i]:setVisible(false)
		end
	end

	----今天6个爆竹都被点燃后，不再显示小鞭炮
	if frontNum == 6 and canTouchNum == 0 then
		-- tailImg:setVisible(false)
		if self.progressBarEffect ~= nil then
			self.progressBarEffect:finalize()
    		self.progressBarEffect = nil
		end
		remainLab:setVisible(false)
		remainLabTitle:setVisible(false)
		tipLab:setVisible(true)
		--已点文本
		for i,lab in ipairs(gotLabArr) do
			lab:setVisible(false)
		end
	else
		-- tailImg:setVisible(true)
		remainLab:setVisible(true)
		remainLabTitle:setVisible(true)
		tipLab:setVisible(false)
	end
	----
	local utilTable =  self:getUtilTable(canTouchNum,frontNum)
	for i,v in ipairs(utilTable) do
		if v == false then
			if self["tipEffect" .. i] ~= nil then
				self["tipEffect" .. i]:finalize()
        		self["tipEffect" .. i] = nil
			end
			if barEffectPanel:getChildByName("i" .. i) then
				barEffectPanel:removeChildByName("i" .. i)
			end
		elseif v == true then
			if self["tipEffect" .. i] == nil then
				local size = barEffectPanel:getContentSize()
				if barEffectPanel:getChildByName("i" .. i) == nil then
					local aImg =  tailImg:clone()
					aImg:setVisible(true)
					barEffectPanel:addChild(aImg,8,"i" .. i)
					aImg:setPosition(size.width*(i/6),size.height*0.3)
				end

				self["tipEffect" .. i] = UICCBLayer.new("rgb-cjhd-sanguang", barEffectPanel)

			    self["tipEffect" .. i]:setPosition(size.width*(i/6) + tailImg:getContentSize().width/2,size.height*0.8 + tailImg:getContentSize().height/2)
			    self["tipEffect" .. i]:setLocalZOrder(10)
			end
		end
	
	end
	--爆竹上的能点提示特效
	----[[
	if canTouchNum > 0 then
		for i=1,6 do
			if self["SquibEffectState" .. i] == 1 or self["SquibEffectState" .. i] == 2 then
				local img = self:getChildByName("topPanel/imgPanel/panel" .. i)
				local imgSize = img:getContentSize()
				if self["tip2Effect" .. i] == nil then
					self["tip2Effect" .. i] = UICCBLayer.new("rgb-cjhd-tixing", imgPanel)
				    local x,y = img:getPosition()
				    self["tip2Effect" .. i]:setPosition(x + imgSize.width*0.6,y + imgSize.height*0.6)
				    self["tip2Effect" .. i]:setLocalZOrder(10)
				end
			else
				if self["tip2Effect" .. i] ~= nil then
					self["tip2Effect" .. i]:finalize()
	        		self["tip2Effect" .. i] = nil
				end

			end
		end
	else
		for i=1,6 do
			if self["tip2Effect" .. i] ~= nil then
				self["tip2Effect" .. i]:finalize()
        		self["tip2Effect" .. i] = nil
			end
		end
	end
	--]]



end
--点燃后（领取后）处理（播放动画刷新页面）
function SpringSquibMainPanel:afterKindle(pos)
	----[[

	local img = self:getChildByName("topPanel/imgPanel/panel" .. pos)
	local imgSize = img:getContentSize()

	local function complete()

	end 
	--特效
	local function handler()
		--[[
		self.effectShowing = true
		local oneEffect = UICCBLayer.new("rgb-cjhd-bianpao", imgPanel, nil, complete,true)
	    local size = afterImg:getContentSize()
	    local x,y = afterImg:getPosition()
	    oneEffect:setPosition(x,y + size.height*0.123)
	    oneEffect:setLocalZOrder(10)
	    ]]

	    -------
		local owner = {}
	    owner["complete"] = function() 
			self.effectShowing = false
			self:updateMainPanel()
			--获得物品特效
			local config = ConfigDataManager:getConfigData(ConfigData.FirecrackerConfig)
			local posInfo = self.proxy:getSquibPosInfos(self.myData.activityId)
			local rewardArr = RewardManager:jsonRewardGroupToArray(config[#posInfo].reward)
			AnimationFactory:playAnimationByName("GetGoodsEffect", rewardArr)
	    end
		if self["SquibEffectState" .. pos] == 1 or self["SquibEffectState" .. pos] == 2 then
			self["SquibEffect" .. pos]:finalize()
			self["SquibEffect" .. pos] = UICCBLayer.new("rgb-cjhd-bianpao", img,owner)
			self["SquibEffectState" .. pos] = 3  
		    self["SquibEffect" .. pos]:setPosition(imgSize.width*0.5,imgSize.height*0.64)
		end


	end


    handler()
--]]

end


function SpringSquibMainPanel:doLayout()
    local panelBg = self:getChildByName("topPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(panelBg, nil, GlobalConfig.downHeight, tabsPanel)
end
function SpringSquibMainPanel:registerEvents()
	SpringSquibMainPanel.super.registerEvents(self)
end
function SpringSquibMainPanel:onTouchImgHandler(sender)

----[[
	if self["SquibEffectState" .. sender.pos] ~= 1 and self["SquibEffectState" .. sender.pos] ~= 2 then
		return
	end
	-- print(sender.pos)
 	local num = self.proxy:getSquibCanTouchTime(self.myData.activityId)
	if num > 0 then
		if self.effectShowing == false then
			local sendData = {}
			sendData.activityId = self.myData.activityId
			sendData.pos = sender.pos
			self.proxy:onTriggerNet230026Req(sendData)
		else
			self:showSysMessage(self:getTextWord(390005))
		end
	
	else
		-- self:showSysMessage(self:getTextWord(390004))
    	local function sureFun()
    		ModuleJumpManager:jump(ModuleName.RechargeModule, "RechargePanel")
    	end
    	self:showMessageBox(self:getTextWord(390004),sureFun)
	end
	--]]

	
end
--计算进度条显示所用的百分比(返回值未除以100)
function SpringSquibMainPanel:percentHandler(num,config)
	table.sort(config,function ( a,b )
		return a.ID < b.ID
	end)

	if num >= config[#config].recharge then
		return 100
	elseif num == 0 then
		return 0
	else
		--所在段前面有n段
		local n = 0
		for k,v in pairs(config) do
			if num > config[k]["recharge"] and num < config[k + 1]["recharge"] then
				n = k
				break
			end
		end		
		
		--本段的百分占比
		local localPercent = 0
		--显示百分比
		local realPercent = 0

		if n > 0 then
			localPercent = (num - config[n].recharge)/(config[n+1].recharge - config[n].recharge) *100/#config
			realPercent = localPercent + n*100/#config
		else
			localPercent = num / config[1].recharge * 100 / #config
			realPercent = localPercent
		end
	
		return realPercent
	end
	
end
--获得当前位置前面有几段
function SpringSquibMainPanel:getNumOfFront()
    --计算当前充值金额前面有段
    local n = 0
    local config = ConfigDataManager:getConfigData(ConfigData.FirecrackerConfig)
    local roleProxy = self:getProxy(GameProxys.Role)
    local chargeValue = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_today_charge)
    table.sort(config,function ( a,b )
        return a.ID < b.ID
    end)

    if chargeValue >= config[#config].recharge then
        n = 6
    elseif chargeValue <= 0 then
        n = 0
    else
        for k,v in pairs(config) do
            if chargeValue > config[k]["recharge"] and chargeValue < config[k + 1]["recharge"] then
                n = k
                break
            end
        end
    end
    return n
end
--爆竹进度条可以点燃提示特效赋值数组,形如{false,false,true}
function SpringSquibMainPanel:getUtilTable(canTouchNum,frontNum)
	local tempTable = {}
	for i=1,frontNum do
		if i <= canTouchNum then
			table.insert(tempTable,true)
		else
			table.insert(tempTable,false)
		end
	end
	--reverse
	local reTable = {}
	for i,v in ipairs(tempTable) do
		table.insert(reTable, tempTable[#tempTable - i + 1])
	end
	for i=1,6 do
		if reTable[i] == nil then
			reTable[i] = false
		end
	end
	return reTable
end
--随机飘动特效
function SpringSquibMainPanel:randomAction(posInfo)

	local randNum = math.random(1,6)
	local imgPanel = self:getChildByName("topPanel/imgPanel")
	local img = self:getChildByName("topPanel/imgPanel/img" .. randNum)
    if img:isVisible() ~= true then
        return
    end
    img:setVisible(false)
	local owner = {}
    owner["complete"] = function() 
    	for _,v in ipairs(posInfo) do
    		if v == randNum then
    			return
    		end
    		img:setVisible(true)
    	end
    end
	local effectTest = UICCBLayer.new("rgb-cjhd-yaobai", imgPanel, owner)
    local size = img:getContentSize()
    local imgX,imgY = img:getPosition()
    effectTest:setPosition(imgX+size.width*0.493,imgY+size.height*0.6222)
    effectTest:setLocalZOrder(10)
end
function SpringSquibMainPanel:delayChangeState()
	local tag = 1
	local function changefun()
		if self["SquibEffectState" .. tag] == 1 then
			local img = self:getChildByName("topPanel/imgPanel/panel" .. tag)
			local imgSize = img:getContentSize()
			self["SquibEffect" .. tag]:finalize()
			self["SquibEffect" .. tag] = UICCBLayer.new("rgb-cjhd-yaobai", img)
			self["SquibEffectState" .. tag] = 2  
		    self["SquibEffect" .. tag]:setPosition(imgSize.width*0.5,imgSize.height*0.64)

		end
		tag = tag + 1
	end
	TimerManager:add(3300, changefun, self, 6)
end
function SpringSquibMainPanel:timestampToString(srcTimestamp)
    if srcTimestamp <= 0 then
        return 0
    end

    local tab = os.date("*t",srcTimestamp)
	local hour = string.format("%02d",tab.hour)
    local min = string.format("%02d",tab.min)
    return tab.year .. self:getTextWord(392009) .. tab.month .. self:getTextWord(392010) .. tab.day .. self:getTextWord(392011) .. hour ..":".. min
end
