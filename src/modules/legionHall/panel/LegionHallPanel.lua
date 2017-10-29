
LegionHallPanel = class("LegionHallPanel", BasicPanel)
LegionHallPanel.NAME = "LegionHallPanel"
LegionHallPanel.CONTRIBUTE_GOLD_TYPE = 1 -- 元宝类型
LegionHallPanel.CONTRIBUTE_RES_TYPE = 2  -- 资源类型

local MAXLEVEL = 30 --最高等级

function LegionHallPanel:ctor(view, panelName)
    LegionHallPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function LegionHallPanel:finalize()
    LegionHallPanel.super.finalize(self)
end

function LegionHallPanel:initPanel()
	LegionHallPanel.super.initPanel(self)
	self:setTitle(true,"legionHall", true)
	self:setBgType(ModulePanelBgType.NONE)

	

    self._legionProxy = self:getProxy(GameProxys.Legion)
	self._listview = self:getChildByName("ListView_1")
	local item = self._listview:getItem(0)
	item:setVisible(false)
	self._topPanel = self:getChildByName("topPanel")
	self._topPanel:setVisible(false)
	self._upBtn = self._topPanel:getChildByName("upBtn")
	self._upBtn:setVisible(false)

	self._midPanel = self:getChildByName("midPanel")
	self._midPanel:setVisible(false)
	self._curOwnKey = self._midPanel:getChildByName("txt1_1")--当前拥有
	
	self._bottomImg = self:getChildByName("bottomImg")--最下面哪条线
	self._bottomImg:setVisible(false)

end

function LegionHallPanel:doLayout()
	local topAdaptivePanel = self:topAdaptivePanel()
    -- local tabsPanel = self:getTabsPanel()
	NodeUtils:adaptiveUpPanel(self._topPanel, topAdaptivePanel, GlobalConfig.tabsHeight * 0.5)


	-- NodeUtils:adaptiveTopPanelAndListView(self._topPanel, 
	-- 							nil,GlobalConfig.downHeight,GlobalConfig.topHeight6)

	--NodeUtils:adaptiveUpPanel(self._topPanel,nil,960-GlobalConfig.topHeight6)

	local midPanel = self:getChildByName("midPanel")

	NodeUtils:adaptiveUpPanel(midPanel,self._topPanel,0)

	NodeUtils:adaptiveUpPanel(self._listview,midPanel,0)

    -- NodeUtils:adaptiveListView(self._listview,GlobalConfig.downHeight,midPanel)

    -- local count = self._listview:getChildrenCount()
    -- local lastItem = self._listview:getItem(count-1)

	NodeUtils:adaptiveUpPanel(self._bottomImg,self._listview,0)

    -- NodeUtils:adaptiveUpPanel(self._topPanel,tabsPanel,0)--固定上边缘
    -- NodeUtils:adaptiveUpPanel(self._topPanel,tabsPanel,0)--固定上边缘

end

function LegionHallPanel:registerEvents()
	LegionHallPanel.super.registerEvents(self)
end

-- 关闭
function LegionHallPanel:onClosePanelHandler()
    -- 根据配置表判断
    local goldCount = self._legionProxy:getContributeGold()
    local resCount  = self._legionProxy:getContributeRes()
    --self:showSysMessage( string.format("总共捐献了%d元宝，%d资源", goldCount, resCount) )
    
    local data = {}
    data.gold = goldCount
    data.res  = resCount
    data.panel= 1
    -- 资源上限条件
    local roleProxy = self:getProxy(GameProxys.Role)
    local legionLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_legionLevel)
    local legionConfig = ConfigDataManager:getConfigData(ConfigData.LegionConfig)
    if legionConfig[legionLevel] ~= nil then
        if legionConfig[legionLevel].donateNum > resCount then
            data.res  = 0
        end
    end

    -- 元宝上限条件
    if goldCount < 15 then -- 写死15
        data.gold = 0
    end

    -- 符合条件发送消息
    if data.res ~= 0 or data.gold ~= 0 then    
        self._legionProxy:onTriggerNet220700Req(data)
    end

    -- 发完消息后重置贡献表
    self._legionProxy:clearContributeInfo()
    
    self.view:hideModuleHandler()
end

function LegionHallPanel:getHallListData()
	-- body
	local tabData = {}

	return tabData
end

function LegionHallPanel:onAfterActionHandler()
    self:onHallInfoResp(self._lastHallUpgrateData)
end

function LegionHallPanel:onShowHandler()
	--print("onTriggerNet220007Req opt = 0")
	local data = {opt = 0}
	local legionProxy = self:getProxy(GameProxys.Legion)
	legionProxy:onTriggerNet220007Req(data)

end

-- 军团大厅220007更新
function LegionHallPanel:onHallInfoResp( data )
	self._lastHallUpgrateData = data
	if self:isModuleRunAction() ~= false then
        return
    end
    -- print("~~~~~~~~~~~~onHallUpdate~~~~~~~~~~~~~~", self:isModuleRunAction(), debug.traceback()) 	
 	if self._lastHallUpgrateData == nil then
 		return
 	end

 	self:onHallUpdate(data)
 	self:onHallList()
end

-- 军团大厅初始化or更新
function LegionHallPanel:onHallUpdate(data)

	local legionProxy = self:getProxy(GameProxys.Legion)
	-- legionProxy:removeInitHallData()
	legionProxy:updateHallCurCount(data.resInfo)

	self._topData = data.armyInfo
	self:onTopPanel()
	
end

-- 大厅捐献回调，确认贡献成功
function LegionHallPanel:onHallContributeResp(data)
	self:showSysMessage( string.format(self:getTextWord(3217), self._contributeInfo.contribute, self._contributeInfo.score))
    
    -- 添加贡献数据数据
    self._legionProxy:addContributeInfo(self._reqContributeType, self._resNeedCount)

	if self:isVisible() ~= true then
		return
	end
	logger:info("···onHallContributeResp line：90")
	
	self:onHallUpdate(data)
	self:updateRoleInfoHandler()
end


function LegionHallPanel:onTopPanel()
	-- body

    self._topPanel:setVisible(true)
	local txt1 = self._topPanel:getChildByName("txt1")
	local txt2 = self._topPanel:getChildByName("txt2")
	local txt3 = self._topPanel:getChildByName("txt3")
	local txt4 = self._topPanel:getChildByName("txt4")
	local val1 = self._topPanel:getChildByName("val1") --军团名
	local val2 = self._topPanel:getChildByName("val2") --等级
	local val3 = self._topPanel:getChildByName("val3") --需求
	local val4 = self._topPanel:getChildByName("val4") --建设度

	local name = self._topData.armyName
	local level = self._topData.armyLv
	local needNum = self._topData.buildNeed
	local curNum = self._topData.allBuild

	val1:setString(name)
	val2:setString(string.format(self:getTextWord(3200),level))
	val4:setString(curNum)

    local legionProxy = self:getProxy(GameProxys.Legion)
    local mineJob = legionProxy:getMineJob()    --自己的职位

	local color = ColorUtils.wordGreenColor
    -- 权限显示
    self._upBtn:setVisible(self._legionProxy:getShowStateByJob(mineJob, "buildLevel"))

	if self._upBtn:isVisible() then
		if curNum >= needNum then
			color = ColorUtils.wordGreenColor
			NodeUtils:setEnable(self._upBtn,true)
			self:addTouchEventListener(self._upBtn,self.onTopUpBtn)
		else
			color = ColorUtils.wordRedColor
			NodeUtils:setEnable(self._upBtn,false)
		end
	else
		if curNum >= needNum then
			color = ColorUtils.commonColor.c3bGreen--ColorUtils.wordGreenColor
		else
			color = ColorUtils.commonColor.c3bRed--ColorUtils.wordRedColor
		end
	end
	val3:setColor(color)	

	-- 满级显示
	if level >= MAXLEVEL then
		val3:setString(self:getTextWord(3027))
		val3:setColor(ColorUtils.commonColor.c3bGreen)
		self._upBtn:setVisible(false)
	else
		val3:setString(needNum)
	end
end

function LegionHallPanel:onHallList()
	-- body

	-- self._listItem = {}
	local tabData = self:getHallListData()

	local legionProxy = self:getProxy(GameProxys.Legion)
	self._resCurNumber = legionProxy:getResNumber()
	self._curCount = legionProxy:getHallCurCount()
	local tabData = legionProxy:getResData(self._curCount)

	if self._list == nil then
		self._midPanel:setVisible(true)
		self:renderListView(self._listview, tabData, self, self.onRenderItemFirst,nil,true,0)
	else
		self:onRenderItemAll(tabData)
	end
	self._bottomImg:setVisible(true)
end

--刷新单个数据
function LegionHallPanel:updateRoleInfoHandler()
	local legionProxy = self:getProxy(GameProxys.Legion)
	self._resCurNumber = legionProxy:getResNumber()
	self._curCount = legionProxy:getHallCurCount()
	local tabData = legionProxy:getResData(self._curCount)

	if self.index and self.restype then
		local item = self._list[self.index+1]
		local info = item.info
		info = tabData[self.index+1]
		if info.restype == self.restype then
			self:onRenderItem(item,info,self.index)
		end
	end
end

function LegionHallPanel:onRenderItemAll(tabData)

	self._midPanel:setVisible(true)
	for k,itempanel in pairs(self._list) do
		self:onRenderItem(itempanel, tabData[itempanel.index+1], itempanel.index)
	end
end

function LegionHallPanel:onRenderItemFirst(itempanel, info, index)
	if itempanel == nil or info == nil then
		return
	end

	if self._list == nil then
		self._list = {}
	end
	if self._list[index+1] == nil then
		itempanel.info = info
		itempanel.index = index
		table.insert(self._list,itempanel)
		self:onRenderItem(itempanel, info, index)
	end
end



function LegionHallPanel:onRenderItem(itempanel, info, index)
	-- body
	itempanel:setVisible(true)
	local curNum = self._resCurNumber[info.restype]
	--print("................渲染 restype,curNum",info.restype,curNum)

	local needValue = itempanel:getChildByName("needValue")
	local curValue = itempanel:getChildByName("curValue")
	local buildValue = itempanel:getChildByName("buildValue")
	local contribute = itempanel:getChildByName("contribute")
	local upBtn = itempanel:getChildByName("upBtn")
	local yes = itempanel:getChildByName("yes")
	local no = itempanel:getChildByName("no")

	local bgImg1 = itempanel:getChildByName("bgImg1")
	local bgImg2 = itempanel:getChildByName("bgImg2")

	if index % 2 == 0 then
		bgImg1:setVisible(true)
		bgImg2:setVisible(false)
	else
		bgImg1:setVisible(false)
		bgImg2:setVisible(true)
	end

    -- resource icon
    local power = GamePowerConfig.Resource
    local typeId = info.restype
    if info.restype == 200 then
    	power = GamePowerConfig.Resource
    	typeId = 206
    end
    local iconInfo = {}
    iconInfo.power = power
    iconInfo.typeid = typeId
    iconInfo.num = 0
    iconInfo.isRes = false

    local icon = itempanel._iconImg
    if icon == nil then
		local iconImg = itempanel:getChildByName("iconImg")
        icon = UIIcon.new(iconImg, iconInfo, false)
        itempanel._iconImg = icon
    else
        icon:updateData(iconInfo)
    end

	needValue:setString(StringUtils:formatNumberByK3(info.reqneed, nil))
	curValue:setString(StringUtils:formatNumberByK3(curNum, nil))
	buildValue:setString("+"..info.score)
	contribute:setString("+"..info.contribute)

	--yes no curValue 三个节点 "中心"对齐self._curOwnKey
	--NodeUtils:centerNodesGlobal(self._curOwnKey,{yes,no,curValue})
    NodeUtils:alignNodeL2R(yes,curValue)
	local isEnough = nil
	local color = nil
	if info.reqneed > curNum then
		-- 资源不足
		color = ColorUtils.commonColor.c3bRed--ColorUtils.wordRedColor
		isEnough = false
		yes:setVisible(false)
		no:setVisible(true)

	else
		-- 资源足够
		color = ColorUtils.commonColor.c3bGreen--ColorUtils.wordGreenColor
		isEnough = true
		yes:setVisible(true)
		no:setVisible(false)
	end
	curValue:setColor(color)


	local curCount = self._curCount[info.restype].curCount
	local maxCount = self._curCount[info.restype].maxCount

	if curCount <= maxCount then
		-- 次数未满
		NodeUtils:setEnable(upBtn,true)
		upBtn.isEnough = isEnough
		upBtn.info = info
		upBtn.index = index
		self:addTouchEventListener(upBtn,self.onUpgrateBtn)
	else
		-- 次数已满
		NodeUtils:setEnable(upBtn,false)
        self:addTouchEventListener(upBtn,self.onUpNotChance)
	end	

end

-- 大厅升级按钮
function LegionHallPanel:onTopUpBtn(sender)
	-- body
	-- print("top up btn")
    local function okCallBack()
	    local data = {opt = 1}
	    local legionProxy = self:getProxy(GameProxys.Legion)
	    legionProxy:onTriggerNet220007Req(data)
    end
    local function cancelCallBack()
    end
    local content = self:getTextWord(3212)
    self:showMessageBox(content,okCallBack,cancelCallBack,self:getTextWord(100),self:getTextWord(101))    	
end

-- 大厅捐献按钮 restype == 200 元宝；202银锭
function LegionHallPanel:onUpgrateBtn(sender)
    local isEnough = sender.isEnough
    local info = sender.info
    local restype = sender.info.restype -- 发送给服务端的类型数据
    self._resNeedCount = sender.info.reqneed -- 本次的预捐献数目
    self.index = sender.index
    self.restype = restype
    --print("捐献类型：".. restype)
    if isEnough ~= nil and isEnough == true then
    	-- 发送请求
        local data = {}
        data.power = restype    	
    	--print("................捐献按钮 req: power,restype = "..data.power,restype)

    	self._contributeInfo = info
    	if restype == 200 then
    		-- 元宝捐献弹提示框
    		local function okCallBack()

    	    	local function callFunc()
    	    	    -- 请求
					local legionProxy = self:getProxy(GameProxys.Legion)
			    	legionProxy:onTriggerNet220008Req(data)
                    -- self._legionProxy:addContributeInfo(LegionHallPanel.CONTRIBUTE_GOLD_TYPE, resNeedCount) -- 1元宝
    	    	    self._reqContributeType = LegionHallPanel.CONTRIBUTE_GOLD_TYPE
                end
    	    	sender.callFunc = callFunc
    	    	sender.money = info.reqneed
    	    	self:isShowRechargeUI(sender)
    		end
    		local content = string.format(self:getTextWord(3213), info.reqneed)
    		self:showMessageBox(content,okCallBack)
    	else
    		-- 非元宝捐献
			local legionProxy = self:getProxy(GameProxys.Legion)
	    	legionProxy:onTriggerNet220008Req(data)
            -- self._legionProxy:addContributeInfo(LegionHallPanel.CONTRIBUTE_RES_TYPE, resNeedCount) -- 2资源
    	    self._reqContributeType = LegionHallPanel.CONTRIBUTE_RES_TYPE
        end

    elseif isEnough ~= nil and isEnough == false then
    	if restype == 200 then
    		-- 元宝不足
    		local function callFunc()
    		    -- 请求
    			self:showSysMessage(self:getTextWord(3208))
    		end
    		sender.callFunc = callFunc
    		sender.money = info.reqneed
    		self:isShowRechargeUI(sender)
    		
    	else
	    	-- 提示资源不足
	    	self:showSysMessage(self:getTextWord(3208)) -- [[操作失败，资源不足]]
    	end
    end

end

-- 按钮灰色，达到次数上限
function LegionHallPanel:onUpNotChance()
    self:showSysMessage(self:getTextWord(3158)) -- [[您的捐献次数已达上限了]]
end


-- 是否弹窗元宝不足
function LegionHallPanel:isShowRechargeUI(sender)
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
