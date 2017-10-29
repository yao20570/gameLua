
LegionScienceTechPanel = class("LegionScienceTechPanel", BasicPanel)
LegionScienceTechPanel.NAME = "LegionScienceTechPanel"

function LegionScienceTechPanel:ctor(view, panelName)
    LegionScienceTechPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function LegionScienceTechPanel:finalize()
    LegionScienceTechPanel.super.finalize(self)
end

function LegionScienceTechPanel:initPanel()
	LegionScienceTechPanel.super.initPanel(self)
	--self:setTitle(true,"scienceHall",true)
	--self:setBgType(ModulePanelBgType.NONE)
	
	self._listview = self:getChildByName("ListView_1")

	local item = self._listview:getItem(0)
	item:setVisible(false)

	self._topPanel = self:getChildByName("topPanel")
	self._upBtn = self._topPanel:getChildByName("upBtn")
	self._greyUpBtn = self._topPanel:getChildByName("greyUpBtn")
	self._upBtn:setVisible(false)
	self._greyUpBtn:setVisible(false)

	self._topPanel:setVisible(false)



	MAXLEVEL = 30 --最高等级
	self._ItemData = {}
	self._conf = self:getConfig(ConfigData.LegionScienceConfig) -- 策划配置的每项静态表
	self._expConf = self:getConfig(ConfigData.LegionLevelConfig, true) -- 等级经验表
end

function LegionScienceTechPanel:doLayout()
	-- 自适应
	--local topAdaptivePanel = self:topAdaptivePanel()
    --NodeUtils:adaptiveTopPanelAndListView(self._topPanel, nil,GlobalConfig.downHeight)
	NodeUtils:adaptiveListView(self._listview, GlobalConfig.downHeight, self._topPanel)
end

-- 关闭
function LegionScienceTechPanel:onClosePanelHandler()
   -- print("执行了 legionScienceTech 的 onClosePanelHandler")
    --self.view:hideModuleHandler()
end

function LegionScienceTechPanel:getConfig(config, isTrue)
	-- body
	local conf = ConfigDataManager:getConfigData(config)

	if isTrue then
		local tmpConf = {}
		for k,v in pairs(conf) do
			tmpConf[v.type..v.level] = v
		end
		conf = tmpConf
	end

	return conf
end

-- function LegionScienceTechPanel:getTopSciData()
-- 	-- body
-- 	local tabData = {}
-- 	tabData.level = 10		--科技厅等级
-- 	tabData.maxNum = 100	--升级需求
-- 	tabData.curNum = 66		--总建设度
-- 	tabData.selfNum = 50	--个人贡献

-- 	return tabData
-- end

function LegionScienceTechPanel:getSciTechData()
	local tabData = {}
	for k,v in pairs(self._conf) do
		local tmpData = {}
		tmpData.subTechId = v.ID       --科技ID
		tmpData.subTechLv = 0 	--初始化等级
		tmpData.subTechExp = 0  --初始化经验
		tmpData.sort = v.sort
		table.insert(tabData,tmpData)
	end

	return tabData
end

function LegionScienceTechPanel:onAfterActionHandler()
    self:onSciUpgrateResp(self._lastUpgrateResp)
end

function LegionScienceTechPanel:onShowHandler()

	local data = {opt = 0}
	local legionProxy = self:getProxy(GameProxys.Legion)
	legionProxy:onTriggerNet220010Req(data)

	if self._listview then
        -- self._listview:jumpToTop()
    end

	-- print("···onTriggerNet220010Req opt = 6666666666666")
    local panel =self:getPanel(LegionScienceHallPanel.NAME)
    panel:onClosePanelHandler()

	

end

-- 科技升级
function LegionScienceTechPanel:onSciUpgrateResp(data)
    
    self._lastUpgrateResp = data
	if self:isModuleRunAction() then
        return
    end
    if self._lastUpgrateResp == nil then
    	return
    end

	local legionProxy = self:getProxy(GameProxys.Legion)
	legionProxy:removeInitSciData()
	legionProxy:updateSciCurCount(data.resInfo)

	local techInfo = data.techInfo

	self._topData = {}
	self._topData.level = techInfo.techLv		--科技厅等级
	self._topData.maxNum = techInfo.buildNeed	--升级需求
	self._topData.curNum = techInfo.allBuild		--总建设度
	self._topData.selfNum = techInfo.myContribute	--个人贡献
	
	local listData = self:getSciTechData()
	for k,v in pairs(techInfo.subTech) do
		-- print("科技subTech.... ID, subTechLv, subTechExp", v.ID, v.subTechLv, v.subTechExp)
		
		if listData[v.subTechId] == nil then
			logger:info("/********************************/科技id错误 ID=%d", v.subTechId)
			break
		end 
		local sort = listData[v.subTechId].sort
		listData[v.subTechId] = v
		listData[v.subTechId].sort = sort
	end


	self:onTopPanel(self._topData)
	self:onSciTechList(listData)
end


function LegionScienceTechPanel:onTopPanel(topData)
	-- body
	self._topPanel:setVisible(true)
	local txt1 = self._topPanel:getChildByName("txt1")
	local txt2 = self._topPanel:getChildByName("txt2")
	local txt3 = self._topPanel:getChildByName("txt3")
	local txt4 = self._topPanel:getChildByName("txt4")
	local val1 = self._topPanel:getChildByName("val1") --大厅等级
	local val2 = self._topPanel:getChildByName("val2") --需求
	local val3 = self._topPanel:getChildByName("val3") --建设度
	local val4 = self._topPanel:getChildByName("val4") --个人贡献

	local maxNum = topData.maxNum
	local curNum = topData.curNum
	local selfNum = topData.selfNum
	local level = topData.level

	val1:setString(string.format(self:getTextWord(3200),level))
	val3:setString(curNum)
	val4:setString(selfNum)
	
    local legionProxy = self:getProxy(GameProxys.Legion)
    local mineJob = legionProxy:getMineJob()    --自己的职位
    -- 权限显示
    self._upBtn:setVisible(legionProxy:getShowStateByJob(mineJob, "buildLevel"))

	if self._upBtn:isVisible() then
		if curNum >= maxNum then
			NodeUtils:setEnable(self._upBtn, true)
			self:addTouchEventListener(self._upBtn,self.onTopUpBtn)
		else
            NodeUtils:setEnable(self._upBtn, false)
		end
    end
    

	-- 满级显示
	if level >= MAXLEVEL then
		val2:setString(self:getTextWord(3027))
		val2:setColor(ColorUtils.wordColorLight03)
		self._upBtn:setVisible(false)
	else
		val2:setString(maxNum)
	end

	if topData.maxNum<=topData.curNum then
		val2:setColor(ColorUtils:color16ToC3b("#2BA532"))
	else
		val2:setColor(ColorUtils:color16ToC3b("#BF4949"))
	end

end

function LegionScienceTechPanel:onSciTechList(listData)
	-- body
	-- local tabData = self:getSciTechData()
	table.sort( listData, function(a,b) return a.sort<b.sort end)
	self:renderListView(self._listview, listData, self, self.onRenderItem,nil,nil,GlobalConfig.listViewRowSpace)
end

------
-- 每个卡片属性设置
function LegionScienceTechPanel:onRenderItem(itempanel, info, index)
	-- body
    -- print("===========onRenderItem===========", index)
	itempanel:setVisible(true)

	local itemName = itempanel:getChildByName("itemName")
	local itemValue = itempanel:getChildByName("itemValue")
	local itemLocked = itempanel:getChildByName("itemLocked")
	local barbg = itempanel:getChildByName("barbg")
	local progressbar = barbg:getChildByName("progressbar")
	local barValue = progressbar:getChildByName("barValue")
	local tipBtn = itempanel:getChildByName("tipBtn")
	local upBtn = itempanel:getChildByName("upBtn")
	-- local greyUpBtn = itempanel:getChildByName("greyUpBtn")

    local ID = info.subTechId
    local level = info.subTechLv
    local curNum = info.subTechExp

    local conf = self._conf

    local iconInfo = {}
    iconInfo.power = GamePowerConfig.Other
    iconInfo.typeid = conf[ID].icon
    iconInfo.num = 0

    local icon = itempanel.icon
    if icon == nil then
		local iconImg = itempanel:getChildByName("icon")
        icon = UIIcon.new(iconImg,iconInfo,false)
        itempanel.icon = icon
    else
        icon:updateData(iconInfo)
    end


	itemName:setString(conf[ID].name)

	local levelConfigData = ConfigDataManager:getInfoFindByTwoKey(ConfigData.LegionLevelConfig, "type", conf[ID].type, "level", level)
    	
    local topData = self._topData
	local unLockLevel = conf[ID].seciencelv
	
    if topData.level >= unLockLevel then
		-- 已解锁
		itemValue:setString(string.format(self:getTextWord(3200), level))
        
        
        local reqExp = levelConfigData.reqexp

		local curExp = curNum	
		local per = nil
		if curExp >= reqExp then
			per = 100
		else
			per = curExp/reqExp * 100
		end
		progressbar:setPercent(per)
		barValue:setString(curExp.."/"..reqExp)


		-- itemName:setColor(ColorUtils.wordWhiteColor)
		-- itemValue:setColor(ColorUtils.wordWhiteColor)
		barbg:setVisible(true)
		progressbar:setVisible(true)
		barValue:setVisible(true)
		itemLocked:setVisible(false)
		
		if level < topData.level then
			-- 科技可捐献升级
			-- upBtn:setVisible(true)
			-- greyUpBtn:setVisible(false)
			upBtn.conf = conf[ID]
			upBtn.info = info
			upBtn.reqExp = reqExp
			NodeUtils:setEnable(upBtn,true)
			self:addTouchEventListener(upBtn,self.onItemUpBtn)
		else
			-- 科技等级不能超过科技大厅等级
			-- upBtn:setVisible(false)
			-- greyUpBtn:setVisible(true)
			NodeUtils:setEnable(upBtn,false)
		end

		local tmpData = {}
		tmpData.conf = conf[ID]
		tmpData.info = info
		tmpData.reqExp = reqExp
		self._ItemData[ID] = tmpData

	else
		-- 未解锁
		itemLocked:setString( string.format(self:getTextWord(3202), unLockLevel))
		itemValue:setString(self:getTextWord(3201))
		-- itemName:setColor(ColorUtils.wordRedColor)
		-- itemValue:setColor(ColorUtils.wordRedColor)
		itemLocked:setColor(ColorUtils.wordRedColor)
		barbg:setVisible(false)
		progressbar:setVisible(false)
		barValue:setVisible(false)
		itemLocked:setVisible(true)
		NodeUtils:setEnable(upBtn,false)
		-- upBtn:setVisible(false)
		-- greyUpBtn:setVisible(true)
		-- self:addTouchEventListener(greyUpBtn,self.onItemGreyUpBtn)
	end

    --//增加一个科技上限  与科技所上限 判断区分
    local typeLevelTop = self:getTypeScienceMaxLevel(conf[ID].type)
    logger:info("当前科技 等级上限 "..typeLevelTop)
    -- 当前的等级超上限了
    if level >= typeLevelTop then
       barValue:setString(TextWords:getTextWord(3218)) -- 最高级
       NodeUtils:setEnable(upBtn,false)
    else
       ---NodeUtils:setEnable(upBtn,true)
    end


	tipBtn:setTouchEnabled(false)
	icon:setTouchEnabled(false)
	-- itempanel:setTouchEnabled(true)

	local size = itemValue:getContentSize()
	local x = itemValue:getPositionX()
	tipBtn:setPositionX(x + size.width + 20)


	itempanel.conf = conf[ID]
	itempanel.info = info
	itempanel.expConf = levelConfigData


    if itempanel.isAddEvent == true then
        return
    end
    itempanel.isAddEvent = true
	self:addTouchEventListener(itempanel,self.onItemTipBtn)
end

-- 大厅升级
function LegionScienceTechPanel:onTopUpBtn(sender)
	-- body
	-- logger:info("top up btn!!!")
	local function okCallBack()
		local legionProxy = self:getProxy(GameProxys.Legion)
		legionProxy:onTriggerNet220010Req({opt = 1})
	end
	local function cancelCallBack()
	end
	local content = self:getTextWord(3211)
	self:showMessageBox(content,okCallBack,cancelCallBack,self:getTextWord(100),self:getTextWord(101))

end

function LegionScienceTechPanel:onItemTipBtn(sender)
	-- body
	self:onShowTip(sender)
end

-- tip
function LegionScienceTechPanel:onShowTip(sender)
	-- body
	local parent = self:getParent()
    local uiTip = UITip.new(parent)
    local lines = {}

	local info = sender.info
	local conf = sender.conf
	local expConf = sender.expConf
	local topData = self._topData

	local content1 = conf.name
	local content2 = string.format(self:getTextWord(3214), info.subTechLv)
	local content3 = conf.info
	local content4 = self:getTextWord(3204) --升级需求

	local color4 = ColorUtils.wordColorDark1601
	local color5 = ColorUtils.wordColorDark1601
	-- if topData.level < expConf.level then
	-- 	color4 = ColorUtils.wordColorDark1604
	-- end
	if info.subTechExp < expConf.reqexp then
		color5 = ColorUtils.wordColorDark1604
	end

	local level = info.subTechLv + 1
	if topData.level <= info.subTechLv then
		color4 = ColorUtils.wordColorDark1604
	end

    local line1 = {{content = content1, foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601},{content = content2, foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    local line2 = {{content = content3, foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    local line3 = {{content = content4, foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1602}}

    table.insert(lines, line1)
    table.insert(lines, line2)
    table.insert(lines, line3)	    

    -- 满级显示tip
    if info.subTechLv < self:getTypeScienceMaxLevel(conf.type) then 
    	-- 未满级
		local content5 = string.format(self:getTextWord(3205), level) --科技所LV.00
		local content6 = string.format(self:getTextWord(3206), expConf.reqexp)

	    local line4 = {{content = content5, foneSize = ColorUtils.tipSize20, color = color4}}
	    local line5 = {{content = content6, foneSize = ColorUtils.tipSize20, color = color5}}
	    table.insert(lines, line4)	    
	    table.insert(lines, line5)	    
    else
    	--当前科技满级
	    local line4 = {{content = self:getTextWord(3215), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1603}}
	    table.insert(lines, line4)	    
    end

    uiTip:setAllTipLine(lines)	
end

function LegionScienceTechPanel:onItemUpBtn(sender)
	-- body

	local data = {}
	data.info = sender.info
	data.conf = sender.conf
	data.reqExp = sender.reqExp
	data.techInfo = self._topData
	local panel = self:getPanel(ScienceTechUpgratePanel.NAME)
	panel:show(data)

end

function LegionScienceTechPanel:onItemGreyUpBtn(sender)
	-- body
	-- print("grey up btn!!!")
end


-- 科技捐献
function LegionScienceTechPanel:onSciContributeResp(data)
	if self:isVisible() ~= true then
		return
	end

	self:onSciUpgrateResp(data)

	local techId = data.techId    --科技ID
	-- local power = data.power	  --捐献的资源类型

	local dataS = {}
	dataS.info = self._ItemData[techId].info
	dataS.conf = self._ItemData[techId].conf
	dataS.reqExp = self._ItemData[techId].reqExp
	dataS.techInfo = data.techInfo

    local panel = self:getPanel(ScienceTechUpgratePanel.NAME)
	if panel:isVisible() ~= true then
		return
	end    
    panel:onSciContributeResp(dataS)

end

-------
-- 获取类型科技的最大等级
function LegionScienceTechPanel:getTypeScienceMaxLevel(scienceType)
    local configTable = ConfigDataManager:getInfosFilterByOneKey(ConfigData.LegionLevelConfig,"type", scienceType)
    local maxLevel = configTable[#configTable].level
    return maxLevel
end