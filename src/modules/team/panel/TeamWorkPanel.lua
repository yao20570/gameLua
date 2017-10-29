
TeamWorkPanel = class("TeamWorkPanel", BasicPanel)
TeamWorkPanel.NAME = "TeamWorkPanel"

function TeamWorkPanel:ctor(view, panelName)
    TeamWorkPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function TeamWorkPanel:finalize()
    TeamWorkPanel.super.finalize(self)
end

function TeamWorkPanel:initPanel()
	TeamWorkPanel.super.initPanel(self)
    self._listview = self:getChildByName("workListView") 
    self._worldProxy= self:getProxy(GameProxys.World)
    self._soldierProxy = self:getProxy(GameProxys.Soldier)
    local retreatConfig = ConfigDataManager:getConfigById(ConfigData.WorldReCallTeamConfig, 1)
    self._retreatMinTime = retreatConfig.minTime
    self._retreatValue   = retreatConfig.percentage/100
end

function TeamWorkPanel:doLayout()
	local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._listview , GlobalConfig.downHeight,tabsPanel)
end

function TeamWorkPanel:onShowHandler()
--    local data = self.view:getWorkData()
--	if data ~= nil then

    local soldierProxy = self:getProxy(GameProxys.Soldier)
    local data = soldierProxy:getSelfTaskTeamInfo()

	self:onUpdateData(data)
--	end
end

function TeamWorkPanel:onUpdateData(data)
	self._beginIndex = 0
	self._infoData = data
	
	self._workItemMap = {}
	self:renderListView(self._listview, data, self, self.registerItemEvents)
	self:update()
--	if #data > 0 then
--        CountDownManager:add(1000000000, self.onUpdate, self)
--	end
end

function TeamWorkPanel:registerItemEvents(item, data, index)


    self._workItemMap[data.id] = { item = item, data = data }

    --    print(data.x )
    --    print(data.y )
    --    print(data.startx )
    --    print(data.starty )


    item:setVisible(true)
    local name = item:getChildByName("name")
    local person = item:getChildByName("person")        -- 图
    local speedBtn = item:getChildByName("speedBtn")    -- 加速
    local backBtn = item:getChildByName("backBtn")      -- 返回
    local infoBtn = item:getChildByName("infoBtn")      -- !
    local proImg = item:getChildByName("proImg")
    local perTxt = proImg:getChildByName("perTxt")      -- 进度条里的文字
    local status = item:getChildByName("status")        -- 状态
    local posLable = item:getChildByName("posLable")    -- 坐标
    person:setScale(1.3)

    -- 撤军按钮
    local retreatBtn = item:getChildByName("retreatBtn")

    -- 采集完成的时间
    local timeLable = item:getChildByName("timeLable")
    timeLable:setString("")

    -- 设置颜色
    --logger:info("当前的item的民忠值：" .. data.loyaltyCount)
    local loyaltyCount = data.loyaltyCount
    name:setColor(self._worldProxy:getColorValueByLoyalty(loyaltyCount))


    speedBtn.data = data
    infoBtn.data = data
    backBtn.data = data
    retreatBtn.data = data
    speedBtn.type = SoldierProxy.March_Atk
    infoBtn.type = SoldierProxy.March_Ret

    local url
    if data.type == SoldierProxy.March_Go_Help then
        -- 加速的
        url = "images/team/daily_1.png"

    elseif data.type == SoldierProxy.March_Help_Other then
        -- 帮别人驻防
        url = "images/team/daily_5.png"

    else
        url = "images/team/daily_" .. data.type .. ".png"
    end

    TextureManager:updateImageView(person, url)
    if data.level < 0 then
        name:setString(data.name)
        -- .."("..data.x..","..data.y..")")
    else
        if data.targetType == SoldierProxy.Target_Player then
            -- 1玩家
            name:setString(data.name .. "Lv" .. data.level)

        elseif data.targetType == SoldierProxy.Target_Rebels then
            -- 4 是叛军
            name:setString(data.name .. "Lv" .. data.level)

        else
            name:setString(data.name)

        end
    end

    -- 坐标
    posLable:setString("(" .. data.x .. "," .. data.y .. ")")

    -- 进度时间
    local soleierProxy = self:getProxy(GameProxys.Soldier)
    local key = "teamTask" .. data.id
    local remainTime = soleierProxy:getRemainTime(key)
    -- print("时间啊啊===",data.totalTime - remainTime)

    if data.type == SoldierProxy.March_Atk
        or data.type == SoldierProxy.March_Ret
        or data.type == SoldierProxy.March_Go_Help
    then
        -- 进入，返回,出发驻防
        proImg:setPercent(100 *(data.totalTime - remainTime) / data.totalTime)
        perTxt:setString(TimeUtils:getStandardFormatTimeString6(remainTime, true))
        backBtn:setVisible(false)
        speedBtn:setVisible(true)
        if data.type == SoldierProxy.March_Ret then
            -- 返回
            status:setString("")
            timeLable:setString("")

        else
            -- 出发
            status:setString("")
            timeLable:setString("")
        end

    elseif data.type == SoldierProxy.March_Dig then
        -- 采集中
        proImg:setPercent(100 *(data.totalTime - remainTime) * data.product / data.load)
        perTxt:setString(StringUtils:formatNumberByK((data.totalTime - remainTime) * data.product) .. "/" .. StringUtils:formatNumberByK(data.load))
        backBtn:setVisible(true)
        speedBtn:setVisible(false)
        status:setString("")

    elseif data.type == SoldierProxy.March_Help_Other then
        -- 驻防中
        backBtn:setVisible(true)
        speedBtn:setVisible(false)
        proImg:setPercent(0)
        perTxt:setString("")
        status:setString(self:getTextWord(7053))
        timeLable:setString("")

    elseif data.type == SoldierProxy.March_Legion_Fight or data.type == SoldierProxy.March_Imperial_Fight then -- 盟战、皇城战准备开战
        -- 盟战,等待开战
        proImg:setPercent(0)
        perTxt:setString("")
        timeLable:setString("")
        status:setVisible(true)
        status:setString(self:getTextWord(471025))
        -- 驻防中"等待开战"
        timeLable:setString("")

        backBtn:setVisible(true)
        speedBtn:setVisible(false)
    end

    -- 撤军按钮显示
    retreatBtn:setVisible(data.type == SoldierProxy.March_Atk or data.type == SoldierProxy.March_Go_Help)
    self:addTouchEventListener(retreatBtn, self.onRetreatBtnHandle)

    item.isFirstOpen = true
    self:addInfoBtnTouch(speedBtn)
    self:addBackBtnTouch(backBtn)

    local size = name:getContentSize()
    local x, y = name:getPosition()
    infoBtn:setPosition(x + size.width + 20, y)

    local x1, y1 = infoBtn:getPosition()
    local infoBtnSize = infoBtn:getContentSize()

    item.data = data
    item.type = SoldierProxy.March_Ret
    self:addInfoBtnTouch(item)
end

function TeamWorkPanel:addBackBtnTouch(infoBtn)
	if infoBtn.isAdd == true then
		return
	end
	infoBtn.isAdd = true
	self:addTouchEventListener(infoBtn,self.onBackClickHandle)
end

function TeamWorkPanel:onBackClickHandle(sender)
	local function callBack()
		local parent = sender:getParent()
		local speedBtn = parent:getChildByName("speedBtn")
		self:dispatchEvent(TeamEvent.ADDSPEED_REQ,{id = sender.data.id})		
	end

	local soleierProxy = self:getProxy(GameProxys.Soldier)
    local key = "teamTask"..sender.data.id
    local remainTime = soleierProxy:getRemainTime(key)
	if (sender.data.totalTime - remainTime) < sender.data.totalTime then
		if sender.data.type == SoldierProxy.March_Help_Other then
			self:showMessageBox(self:getTextWord(7071),callBack)--确定要返回驻军部队吗？

        elseif sender.data.type == SoldierProxy.March_Legion_Fight then -- 盟战等待
            self:showMessageBox(self:getTextWord(7096),callBack) -- "盟战待命中，是否确认返回？"
        elseif sender.data.type == SoldierProxy.March_Imperial_Fight then -- 皇城等待
            self:showMessageBox(self:getTextWord(7097),callBack) -- "皇城待命中，是否确认返回？"
		else
            if (sender.data.totalTime - remainTime * sender.data.product)  >= sender.data.load then
				callBack()
			else
				self:showMessageBox(self:getTextWord(7067),callBack)--采集未满确认要返回?
			end
		end
	else
        if sender.data.type == SoldierProxy.March_Legion_Fight then -- 盟战等待
            self:showMessageBox(self:getTextWord(7096),callBack) -- "盟战待命中，是否确认返回？"
        elseif sender.data.type == SoldierProxy.March_Imperial_Fight then -- 皇城等待
            self:showMessageBox(self:getTextWord(7097),callBack) -- "皇城待命中，是否确认返回？"
        else
		    callBack()
        end
	end
end

function TeamWorkPanel:addInfoBtnTouch(infoBtn)
	if infoBtn.isAdd == true or infoBtn.data == nil then
		return
	end
	infoBtn.isAdd = true
	self:addTouchEventListener(infoBtn,self.onInfoClickHandle)
end

function TeamWorkPanel:onInfoClickHandle(sender)
    local soleierProxy = self:getProxy(GameProxys.Soldier)
    local key = "teamTask" .. sender.data.id
    local remainTime = soleierProxy:getRemainTime(key)
    if sender.type == SoldierProxy.March_Ret then
        local panle = self:getPanel(TeamInfosPanel.NAME)
        panle:show(sender.data)

    else
    
        -- 不可加速的情况
        local data = sender.data
        if data.type == SoldierProxy.March_Atk 
            and (data.targetType == SoldierProxy.Target_Town_PVP or data.targetType == SoldierProxy.Target_Town_PVE) 
        then
            -- 郡城行军
            -- "郡城行军不能执行加速操作"
            self:showSysMessage(self:getTextWord(471032))
            return
        end

        if data.type == SoldierProxy.March_Atk and (data.targetType == SoldierProxy.Target_Imperial_PVP or data.targetType == SoldierProxy.Target_Imperial_PVE) then -- 皇城行军
            self:showSysMessage(self:getTextWord(550010)) -- "皇城行军不能执行加速操作"
            return 
		end
             
        local time = remainTime or 0
        local cost = TimeUtils:getTimeCost(time)
        local function callBack()
            -- self:dispatchEvent(TeamEvent.ADDSPEED_REQ,{id = sender.data.id})

            local function callFunc()
                -- 确定
                self:dispatchEvent(TeamEvent.ADDSPEED_REQ, { id = sender.data.id })
            end
            sender.callFunc = callFunc
            sender.money = cost
            self:isShowRechargeUI(sender)
        end

   
        if time == 0 then
            callBack()
        end

        -- 你确定要花费
        self:showMessageBox(self:getTextWord(7055) .. cost .. self:getTextWord(7068), callBack)
    end
end


-- 是否弹窗元宝不足
function TeamWorkPanel:isShowRechargeUI(sender)
    -- body
    local needMoney = sender.money

    local roleProxy = self:getProxy(GameProxys.Role)
    local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝

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

-- 去除计时
function TeamWorkPanel:onCloseTimerOpenFun()
    CountDownManager:remove(self.onUpdate,self)
end

function TeamWorkPanel:update()

    for _, workItem in pairs(self._workItemMap) do
    	local v = workItem.data
    	local item = workItem.item
    	
        local soleierProxy = self:getProxy(GameProxys.Soldier)
        local key = "teamTask"..v.id
        local remainTime = soleierProxy:getRemainTime(key)
        
        local proImg = item:getChildByName("proImg")
        local perTxt = proImg:getChildByName("perTxt")
        local status = item:getChildByName("status")
        local timeLable = item:getChildByName("timeLable")
        -- 撤军按钮
        local retreatBtn = item:getChildByName("retreatBtn")

    	if v.type == SoldierProxy.March_Help_Other then
            -- perTxt:setString(self:getTextWord(7052))--采集中
            perTxt:setString("")
            status:setString(self:getTextWord(7053))--驻防中
            proImg:setPercent(0)

        elseif v.type == SoldierProxy.March_Dig then
            local currentProduct = (v.totalTime - remainTime * v.product) 
--            print("======currentProduct============", v.totalTime, v.product, v.alreadyTime, remainTime,  v.totalTime / v.product )
            if currentProduct >= v.load then
                currentProduct = v.load
            end

            perTxt:setString(StringUtils:formatNumberByK(currentProduct).."/"..StringUtils:formatNumberByK(v.load))
            status:setString("")
            proImg:setPercent(100 * (currentProduct) / v.load)

			local time = math.ceil(remainTime)
			if time > 0 then
          		  timeLable:setString(TimeUtils:getStandardFormatTimeString6(time,true))
        	else
        		timeLable:setString("")
        	end

        elseif v.type == SoldierProxy.March_Legion_Fight or v.type == SoldierProxy.March_Imperial_Fight then
            perTxt:setString("")
            status:setString(self:getTextWord(471025))--"等待开战"
            proImg:setPercent(0)

        else
            local restTime = v.totalTime - remainTime
            proImg:setPercent(100 * (restTime) / v.totalTime)
            status:setString("")
            perTxt:setString(TimeUtils:getStandardFormatTimeString6(remainTime,true))

            -- 撤军按钮显示remainTime剩余时间
            retreatBtn:setVisible(v.type == SoldierProxy.March_Atk or v.type == SoldierProxy.March_Go_Help)
            if v.totalTime <= self._retreatMinTime then
                retreatBtn:setVisible(false)
            elseif restTime >= v.totalTime *self._retreatValue then
                retreatBtn:setVisible(false)
            end
    	end
    end
end


------
-- 撤军 
-- @param  args [obj] 参数
function TeamWorkPanel:onRetreatBtnHandle(sender)
    -- 撤军限制
--    if sender.data.totalTime <= 60 then
--        self:showSysMessage("路程小于1min")
--        return
--    end

--    local key = "teamTask"..sender.data.id
--    local remainTime = self._soldierProxy:getRemainTime(key)
--    if sender.data.totalTime - remainTime >= sender.data.totalTime *0.8 then 
--        self:showSysMessage("已出征较长时间，无法撤回")
--        return
--    end

    local data = {}
    data.id = sender.data.id
    self._soldierProxy:onTriggerNet80017Req(data)
end
