-- /**
--  * @Author:    fzw
--  * @DateTime:    2016-08-24 22:05:23
--  * @Description: 挂机界面
--  */

UITeamSleepPanel = class("UITeamSleepPanel")

function UITeamSleepPanel:ctor(parent, panel, data)
    local uiSkin = UISkin.new("UITeamSleepPanel")
    self._uiSkin = uiSkin
    self._parent = parent
    self._panel = panel

    local father = parent:getParent()
    local grandFather = father:getParent()
    self._father = father
    self._grandFather = grandFather
    uiSkin:setParent(grandFather)
    uiSkin:setTouchEnabled(false)
    -- --start 二级弹窗 -------------------------------------------------------------------
    local extra = {}
    extra["closeBtnType"] = 1
    extra["callBack"] = self.onHideSelfTouch
    extra["obj"] = self

    self.secLvBg = UISecLvPanelBg.new(grandFather, self, extra)
    self.secLvBg:setBackGroundColorOpacity()
    self.secLvBg:setContentHeight(700)
    self.secLvBg:setTitle(TextWords:getTextWord(7060))
    self.secLvBg:setLocalZOrder(3)
    self.secLvBg:setTouchEnabled(true)
    -- --end 二级弹窗 --------------------------------------------------------------------
    self._uiSkin:setLocalZOrder(10)
    


    self._dungeonProxy = self._father:getProxy(GameProxys.Dungeon)
    self._roleProxy = self._father:getProxy(GameProxys.Role)
    self._soldierProxy = self._father:getProxy(GameProxys.Soldier)
    self._teamDetailProxy = self._father:getProxy(GameProxys.TeamDetail)

	self:initPanel()
	self:registerEvent()
    self:registerProxyEvent()
	self:onShowAction()
end

function UITeamSleepPanel:finalize()
	self:removeProxyEvent()
    self._uiSkin:finalize()
end


function UITeamSleepPanel:registerProxyEvent()
    -- self._dungeonProxy:addEventListener(AppEvent.PROXY_DUNGEON_BUY_TIMES, self, self.onBuyTimesResp)
end

function UITeamSleepPanel:removeProxyEvent()
    -- self._dungeonProxy:removeEventListener(AppEvent.PROXY_DUNGEON_BUY_TIMES, self, self.onBuyTimesResp)
end

function UITeamSleepPanel:isVisible()
	-- body
	return self._uiSkin:isVisible()
end

function UITeamSleepPanel:onShowAction()
    self._uiSkin:setVisible(true)
    self.secLvBg:setVisible(true)

    -- local bgPanel = self._uiSkin:getChildByName("bgPanel")
    -- if self._isScale == nil then
    --     bgPanel:setScale(0.1)
    -- end
    -- self._uiSkin:setVisible(true)
    -- self.secLvBg:setVisible(true)
    -- local scale = cc.ScaleTo:create(0.1,1.0)
    -- bgPanel:runAction(scale)
end

function UITeamSleepPanel:onHideSelfTouch(sender)
	self:onResetData(sender)
    TimerManager:addOnce(60,self.onHideAction,self)
end

function UITeamSleepPanel:onHideAction()
    self._uiSkin:setVisible(false)
    self.secLvBg:setVisible(false)

    -- local bgPanel = self._uiSkin:getChildByName("bgPanel")
    -- local function call()
    --     self._isScale = true
    --     self._uiSkin:setVisible(false)
    --     self.secLvBg:setVisible(false)
    -- end
    -- local scale = cc.ScaleTo:create(0.1,0.1)
    -- local fun = cc.CallFunc:create(call)
    -- bgPanel:runAction(cc.Sequence:create(scale,fun))
end

function UITeamSleepPanel:onResetData(sender)
    self._closeSelf = true
	self._stopNow = 1
	self._sendIndex = 0
end


function UITeamSleepPanel:initPanel()
	self._listview = self._uiSkin:getChildByName("bgPanel/ListView_11")
	local map = {0,2,4,6}
	for _,v in pairs(map) do
		local item = self._uiSkin:getChildByName("bgPanel/ItemPanel"..v)
		item:setVisible(false)
	end

    local tipShowTxt = self._uiSkin:getChildByName("bgPanel/imgSaoDangBg/tipShowTxt")
    tipShowTxt:setString(TextWords:getTextWord(143))
end


function UITeamSleepPanel:registerEvent()
	self._stopBtn = self._uiSkin:getChildByName("bgPanel/controlBtn")
	self._sendIndex = 0
	ComponentUtils:addTouchEventListener(self._stopBtn, self.onStopBtnHandle, nil, self)

end

function UITeamSleepPanel:startSend(type,id,data)
	self:onShowAction()

	self._listview:removeAllItems()
	--self:show()
	self._sendIndex = 0
	self._nextSend = nil
    self._closeSelf = nil
	self._data = data
	self._sendData = {}
	self._sendData.type = type
	self._sendData.id = id
	self._sendData.infos = {}
	self._stopNow = -1
	self._stopBtn:setTitleText(TextWords:getTextWord(7059))
	--self:onSendData()
	self:startAnimation()
end

function UITeamSleepPanel:checkData()
	local checkData = self._soldierProxy:setCheckExample(self._data)
	local data = {}
	for _,v in pairs(checkData) do
		if v.num > 0 then
			table.insert(data,v)
		end
	end
	return data
end

function UITeamSleepPanel:setStopBtnName(type)
	if type == -1 then
		self._stopBtn:setTitleText(TextWords:getTextWord(752))
	else
		self._stopBtn:setTitleText(TextWords:getTextWord(751))
	end
end

function UITeamSleepPanel:updaeEnergyNeedMoney()
	self._stopNow = -1
	self._nextSend = nil
	self._stopBtn:setTitleText(TextWords:getTextWord(7059))
	self:onSendData()
end

function UITeamSleepPanel:onStopBtnHandle(sender)
    -- 如果在读秒，不执行继续扫荡操作
    local nowTitleText = sender:getTitleText()
    if nowTitleText == TextWords:getTextWord(751) then
        if self._isRunning == true then
            self._father:showSysMessage(TextWords:getTextWord(7077))
            return
        end
    end


	if self._stopBtn.canSend == true then
		if self:onFinalCheck() == true then
			self:onSendData()
		end
		return
	end

    if self._sendIndex < 10 then
    	if self._stopNow == 3 or self._stopNow == 4 then
    		self._father:showSysMessage(TextWords:getTextWord(7059 + self._stopNow))
    		return
    	elseif self._stopNow == 2 then  --体力值不足
    		self._roleProxy:getBuyEnergyBox(self, nil, nil, true)
    		return
    	elseif self._stopNow == 5 then  --挑战次数不足
    		local function callbk()
    			self._teamDetailProxy:buyChallengeTimes(2)
    		end
    		self._father:showMessageBox(TextWords:getTextWord(200105)..self._buyCountMoney..TextWords:getTextWord(200106),callbk)
    		return
    	end
		if self._stopNow == 0 then  --次数没达到10次，由于体力什么原因
			--self:showSysMessage("体力值不够或者佣兵数量为0")
			self._stopBtn:setTitleText(TextWords:getTextWord(7060))
			return 
		else
			self._stopNow = 0 - self._stopNow
		end
	else
		self._stopNow = -1
		self._father:showSysMessage(TextWords:getTextWord(750))
		self._stopBtn:setTitleText(TextWords:getTextWord(7060))
		return
	end
	self:setStopBtnName(self._stopNow)
	if self:onFinalCheck() == true then
		self:onSendData()
	end
end

function UITeamSleepPanel:updateData(data)
	self._stopBtn.canSend = true
	if data == nil then
		self._stopBtn:setTitleText(TextWords:getTextWord(7060))
		-- self:onCanNotContinue()
		return
	end

	-- 中原的战役副本，挂机时，无视损兵过多
	if data.continue == 3 then
		self.targetType,_ = self._dungeonProxy:getCurrType()
		if self.targetType == 1 then 
			data.continue = 0
		end
	end


	if data.continue == 1 then  --体力值不足
		self._nextSend = 2
		self._stopBtn.canSend = nil
		self._sendIndex = self._sendIndex + 1
		self:updateItem(data)
	elseif data.continue == 2 then --银币不足
		self._nextSend = 3
		self._stopBtn.canSend = nil
		self._sendIndex = self._sendIndex + 1
		self:updateItem(data)
	elseif data.continue == 3 then --孙兵过多，木有3星
		self._nextSend = 4
		self._stopBtn.canSend = nil
		self._sendIndex = self._sendIndex + 1
		self:updateItem(data)
	elseif data.continue == 4 then --次数不足
		self._nextSend = 5
		self._stopBtn.canSend = nil
		self._sendIndex = self._sendIndex + 1
		self:updateItem(data)
        self._teamDetailProxy:buyChallengeTimes(1)
	elseif data.continue == 7 then --战斗失败
		self._nextSend = 17
		self._stopBtn.canSend = nil
		self._sendIndex = self._sendIndex + 1
		self:updateItem(data)
	elseif data.continue == 0 then
		self._stopBtn.canSend = nil
		self._sendIndex = self._sendIndex + 1
		self:updateItem(data)
		if table.size(data.costInfos) > 0 then
			self._father:showSysMessage(TextWords:getTextWord(755))
		end
	end

	self:updateCurrJewel(data.costTael)
end

function UITeamSleepPanel:onFinalCheck()
	if self._sendIndex == 10 then  --次数限制10到了
		-- self._father:showMessageBox(TextWords:getTextWord(750))
		self._listview:jumpToPercentVertical(100)
		self._stopBtn:setTitleText(TextWords:getTextWord(7060))
		return
	end
	if self._stopNow == 1 then  --忽然点击了停止按钮
		return
	end
	return true
end

-- 请求挂机
function UITeamSleepPanel:onSendData()
	if self._uiSkin:isVisible() ~= true then
		logger:info("UITeamSleepPanel未显示，方法onSendData()不执行！")
		return
	end

	local data = self:checkData()
	if #data > 0 then
		self._sendData.infos = data
		-- print("请求挂机 from UITeamSleepPanel")
		self._teamDetailProxy:onTriggerNet60005Req(self._sendData)
	else
		self._father:showSysMessage(TextWords:getTextWord(753))
	end
end

function UITeamSleepPanel:updateItem(data)
	local item,typeCount = self:selectItem(data)
	item:retain()
	local title = item:getChildByName("title")
	local index = title:getChildByName("index")
	index:setString(TextWords:getTextWord(7065)..self._sendIndex..TextWords:getTextWord(7066))
	item:setVisible(true)
	self._listview:pushBackCustomItem(item)

    --//null
    local x=self._sendIndex
    print("index item------------------------------"..x)
   
    self._listview:jumpToPercentVertical(100)
    
    --//null
    if  self._sendIndex == 1  then
    self._listview:jumpToPercentVertical(0)

     print("index item-----------------------------------"..x)
    end


	self:wirteData(item,data,typeCount)
end

function UITeamSleepPanel:wirteData(item,data,typeCount)
	local Item = item:getChildByName("Item")
	Item:setVisible(false)

	local index = 1
	for _,v in pairs(data.rewards) do
		local item = Item:getChildByName("item"..index)
		
		local person = item:getChildByName("person")
		item:setVisible(true)

		local icon = person.icon
        if icon == nil then
            icon = UIIcon.new(person, v, true, self._panel, nil, true)
        	icon:getNameChild():setFontSize(20)
            person.icon = icon
        else
            icon:updateData(data)
        end

		index = index + 1
	end

	for i = index,4 do
		local item = Item:getChildByName("item"..i)
		item:setVisible(false)
	end

	if self.targetType ~= 1 then  --非中原战役显示银币治疗信息
		local repaire = Item:getChildByName("repaire")
		repaire:setString(StringUtils:formatNumberByK(data.costTael))		
	end

	index = 1

	for _,v in pairs(data.costInfos) do
		local _repaire = Item:getChildByName("repaire"..index)
		local name = _repaire:getChildByName("name")
		local count = _repaire:getChildByName("count")
		local person = _repaire:getChildByName("person")

		local info = ConfigDataManager:getConfigById(ConfigData.ArmKindsConfig,v.typeid)
		name:setString(info.name)

        if v.num ~= nil then
		    count:setString(v.num) 
        end

		person:setScale(GlobalConfig.UITeamDetailSoldierScale) --佣兵图片缩放大小
        TextureManager:onUpdateSoldierImg(person,v.typeid)

		_repaire:setVisible(true)
		index = index + 1
	end

	for i = index,typeCount do
		local _repaire = Item:getChildByName("repaire"..i)
		_repaire:setVisible(false)
	end

	local function callBk()
		self:startAnimation(item)
	end
    self._isRunning = true
	TimerManager:addOnce(800, callBk, self)
end

function UITeamSleepPanel:selectItem(data)
	local num = #data.costInfos
	local item,count
	if num >= 5 then
		item = self._uiSkin:getChildByName("bgPanel/ItemPanel6")
		count = 6
	elseif num >= 3 then
		item = self._uiSkin:getChildByName("bgPanel/ItemPanel4")
		count = 4
	elseif num >= 1 then
		item = self._uiSkin:getChildByName("bgPanel/ItemPanel2")
		count = 2
	else
		item = self._uiSkin:getChildByName("bgPanel/ItemPanel0")
		count = 0
	end
	-- print("孙兵种类 num, count",num,count)
	return item:clone(),count	
end

function UITeamSleepPanel:startAnimation(item)
    -- local count = self._uiSkin:getChildByName("bgPanel/count")
    local imgSaoDangBg = self._uiSkin:getChildByName("bgPanel/imgSaoDangBg")
	local artTime = self._uiSkin:getChildByName("bgPanel/imgSaoDangBg/artTime")
	imgSaoDangBg.artTime = artTime
	local function endFun( )
	    if self._closeSelf == true then
	       self._closeSelf = nil

           self._isRunning = false
	       return
	    end
		-- count:setVisible(false)
		imgSaoDangBg:setVisible(false)

		local tmpLabel
		if item ~= nil then
			local loading = item:getChildByName("loading")
			local Item = item:getChildByName("Item")
			local Label_16 = Item:getChildByName("Label_16")
			loading:setVisible(false)
			Label_16:setVisible(true)
			Item:setVisible(true)
			tmpLabel = Label_16
		end
		if self._nextSend ~= nil then
			tmpLabel:setVisible(false)
			self._stopNow = self._nextSend
			self._stopBtn:setTitleText(TextWords:getTextWord(7060))
			self._father:showMessageBox(TextWords:getTextWord(7059 + self._nextSend))

            self._isRunning = false
			return
		end
		if self:onFinalCheck() == true then
			self:onSendData()
		else
			-- count:setVisible(false)
			imgSaoDangBg:setVisible(false)
		end
		if item ~= nil then
			item:release()
		end

        -- 
        self._isRunning = false
	end
	-- count:setVisible(true)
	imgSaoDangBg:setVisible(true)
	-- count._count = 3
	imgSaoDangBg._count = 3
    local function startFun()
		--count:setString(count._count)
        -- TextureManager:updateImageView(count, ("images/component/SPCountdown_" .. count._count .. ".png"))
		-- count._count = count._count - 1
		imgSaoDangBg.artTime:setString(tostring(imgSaoDangBg._count))
		imgSaoDangBg._count = imgSaoDangBg._count - 1

	end
	
    local startFun0 = cc.CallFunc:create(startFun) 
	local startFun1 = cc.CallFunc:create(startFun) 
	local startFun2 = cc.CallFunc:create(startFun) 

	local delay = cc.DelayTime:create(0.7)
	local delay1 = cc.DelayTime:create(0.7)
	local delay2 = cc.DelayTime:create(0.7)

	local _endFun = cc.CallFunc:create(endFun)
	if self._sendIndex <= 10 and self._sendIndex > 0 then
		-- count:runAction(cc.Sequence:create(startFun0,delay,startFun1,delay1,startFun2,delay2,_endFun))
		imgSaoDangBg:runAction(cc.Sequence:create(startFun0,delay,startFun1,delay1,startFun2,delay2,_endFun))
	else
		endFun()
	end
end

-- 当前剩余银币
function UITeamSleepPanel:updateCurrJewel(costTael)
	local curMoney = self._uiSkin:getChildByName("bgPanel/curMoney")
	local count = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_tael)
	curMoney:setString(StringUtils:formatNumberByK(count))
end

function UITeamSleepPanel:update()
	if self._sendIndex <= 10 and self._stopBtn:getTitleText() == TextWords:getTextWord(7059) then
		self._listview:jumpToPercentVertical(100)

         if  self._sendIndex == 1  then
            self._listview:jumpToPercentVertical(0)
         end
	end
end

-- 购买挑战次数更新
function UITeamSleepPanel:onBuyTimesResp(data)
	-- print("购买次数成功 UITeamSleepPanel onBuyTimesResp")
	if data.type == 1 then
	    self._buyCountMoney = data.money
	elseif data.type == 2 then
		self:updaeEnergyNeedMoney()
	end
end

