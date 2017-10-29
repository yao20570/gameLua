-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
LegionTaskPanel = class("LegionTaskPanel", BasicPanel)
LegionTaskPanel.NAME = "LegionTaskPanel"

function LegionTaskPanel:ctor(view, panelName)
    LegionTaskPanel.super.ctor(self, view, panelName,true)
    require("modules.legionTask.panel.LegionTaskRewarShowPanel")
    self:setUseNewPanelBg(true)
    self._boxNodeAry = {}
    self._view = view

    self.maxValue = 0 --最大绩效值
    self.state = {} --进度条几个阶段
end

function LegionTaskPanel:finalize()
	self._boxNodeAry = {}
	TimerManager:remove(self.sendUpdateDataReq, self)
	if self._UITabForTanChuang then
        self._UITabForTanChuang:finalize()
        self._UITabForTanChuang = nil
    end

    LegionTaskPanel.super.finalize(self)
end

function LegionTaskPanel:initPanel()
	LegionTaskPanel.super.initPanel(self)
	self:setTitle(true,"legionTask",true)
	self:setBgType(ModulePanelBgType.NONE)

	self._panelTop = self:getChildByName("panelTop")
	self._panelTab = self._panelTop:getChildByName("PanelTab")
	self._panelProgress = self._panelTop:getChildByName("panelProgress")

	self.tipBtn = self._panelTop:getChildByName("tipBtn")

	self.imgProgressBg = self._panelProgress:getChildByName("imgProgressBg") --进度条底图
	self.progressBar = self._panelProgress:getChildByName("progressBar") --进度条
	self.imageNode = self._panelProgress:getChildByName("imageNode")
	self.imageBox = self.imageNode:getChildByName("imageBox")
	self.imageNode:setVisible(false)
	--重新加载资源
	TextureManager:updateImageView(self.imgProgressBg, "images/mapMilitary/SpProgressBg.png")
	TextureManager:updateImageView(self.progressBar, "images/mapMilitary/SpProgress.png")
	TextureManager:updateImageView(self.imageNode, "images/mapMilitary/SpProgressNodeEmpty.png")
	TextureManager:updateImageView(self.imageBox, "images/mapMilitary/SpBox.png")

	self.legionProxy = self:getProxy(GameProxys.Legion)
	self:initConfigInfo() --初始化配置表数据（进度条一共有几个阶段）
	self:initProgress()
end

function LegionTaskPanel:registerEvents()
	LegionTaskPanel.super.registerEvents(self)

	self:addTouchEventListener(self.tipBtn, self.helpBtnOnTap)
end

function LegionTaskPanel:doLayout()
	local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveUpPanel(self._panelTop,tabsPanel,GlobalConfig.tabsAdaptive)
end

function LegionTaskPanel:onClosePanelHandler()
	TimerManager:remove(self.sendUpdateDataReq, self)
	self.view:hideModuleHandler()
end

function LegionTaskPanel:onShowHandler()
	if not self._UITabForTanChuang then

		local function callbackFunc(panelName)
			-- if panelName == LegionTaskListPanel.NAME then
			-- 	self:updateLegionTaskInfo()
			-- elseif panelName == LegionTaskPerformancePanel.NAME then
			-- 	self:updateLegionTaskInfo()
			-- end 
		end

        self._UITabForTanChuang = UITabForTanChuang.new( {
            adaptivePanel = self._panelTab,
            basicPanel = self,
            -- callback = callbackFunc,
        } )

        self._UITabForTanChuang:addTabPanel(LegionTaskListPanel.NAME,TextWords:getTextWord(560200))
        self._UITabForTanChuang:addTabPanel(LegionTaskPerformancePanel.NAME,TextWords:getTextWord(560201))
        self._UITabForTanChuang:setSelectTabIdx(1)
    end

    self:updateLegionTaskInfo()
    --300000
    TimerManager:add(300000, self.sendUpdateDataReq, self, -1)
end

function LegionTaskPanel:initConfigInfo()
	local config,configLen = ConfigDataManager:getConfigDataAndLength(ConfigData.LegionTaskPerformanceConfig)
	for k,v in pairs(config) do
		if v.performanceRequire > self.maxValue then
			self.maxValue = v.performanceRequire
		end
		self.state[v.ID] = v
	end 
end

local function sortFunc(a,b)
	return a.index < b.index
end 

--根据需求初始化进度条
function LegionTaskPanel:initProgress()
	
	local stateNum = #self.state --奖励分为几个阶段
	local progressBgSize = self.imgProgressBg:getContentSize()
	local progressBgPosX = self.imgProgressBg:getPositionX()
	for k,v in pairs(self.state) do
		local imageNode = self.imageNode:clone()
		self.imageNode:getParent():addChild(imageNode)
		imageNode:setVisible(true)
		imageNode:setPositionX(progressBgPosX - progressBgSize.width / 2 + (k / stateNum) * progressBgSize.width)
		local txtActiveneed = imageNode:getChildByName("txtActiveneed")
		txtActiveneed:setString(tostring(v.performanceRequire))
		imageNode.needValue = v.performanceRequire
		imageNode.index = v.ID

		local imageBox = imageNode:getChildByName("imageBox") --宝箱

		local function onTapImageBoxBtn()
			local rewardId = v.rewardID --奖励id
			local myJob = self.legionProxy:getMineJob() --同盟职位
			local configInfo = ConfigDataManager:getInfoFindByTwoKey("LegionTaskSalaryConfig", "rewardID", rewardId, "positionID",myJob)
			if configInfo then --有奖励信息
				local reward = StringUtils:jsonDecode(configInfo.reward)
				self:showTaskGoods(rewardId,myJob,nil)
			end 
		end

		self:addTouchEventListener(imageBox,onTapImageBoxBtn)

		-- table.insert(self._boxNodeAry,imageNode)
		self._boxNodeAry[v.ID] = imageNode
	end
	table.sort(self._boxNodeAry,sortFunc)
	self.progressBar:setPercent(0/self.maxValue)
end

-- function LegionTaskPanel:onTapImageBoxBtn(sender)
-- end

--更新进度条
function LegionTaskPanel:updateProgress(current)
	local current = current or 0
	local arrive
	for k,v in pairs(self._boxNodeAry) do
		local imageNodeUrl 
		if current >= v.needValue then
			imageNodeUrl = "images/mapMilitary/SpProgressNodeFull.png"
			--添加对宝箱的处理（宝箱的颜色  以及宝箱的状态）
			if not arrive then
				arrive = v
			end 
			if v.index > arrive.index then
				arrive = v
			end

			if self._boxNodeAry[v.index - 1] then
				local box = self._boxNodeAry[v.index - 1]:getChildByName("imageBox")
				NodeUtils:setEnableColor(box, true)
				box:setVisible(false)
			end 
		else
			imageNodeUrl = "images/mapMilitary/SpProgressNodeEmpty.png"
			local box = v:getChildByName("imageBox")
			box:setVisible(true)
			NodeUtils:setEnableColor(box, false)
		end
		TextureManager:updateImageView(v,imageNodeUrl)
	end

	local percent
	if arrive then
		local box = arrive:getChildByName("imageBox")
		NodeUtils:setEnableColor(box, true)
		
		local nextArrive = self.state[arrive.index + 1]
		if nextArrive then 
			percent = ( (arrive.index/(#self.state)) + ((current - arrive.needValue)/(nextArrive.performanceRequire - arrive.needValue)/#self.state) ) * 100
		else
			percent = 100
		end
	else
		local nextArrive = self.state[1]
		if nextArrive then
			percent = current/nextArrive.performanceRequire/(#self.state) * 100
		end
	end 
	self.progressBar:setPercent(percent)
end

--更新任务列表
function LegionTaskPanel:updateTaskListPanel(data)
	local panel = self:getPanel(LegionTaskListPanel.NAME)--self._view:getPanel(LegionTaskListPanel.NAME)
	panel:updateList(data)
end

--更新绩效排名
function LegionTaskPanel:updatePerformancePanel(data)
	local panel =  self:getPanel(LegionTaskPerformancePanel.NAME)--self._view:getPanel(LegionTaskPerformancePanel.NAME)
	panel:updateList(data)
end 

function LegionTaskPanel:updatePanelInfo(data)
	local scrollBgImg = self._panelTop:getChildByName("scrollBgImg")
	local leaderNameLab = scrollBgImg:getChildByName("leaderNameLab") --同盟周绩效
	local leaderRankLab = scrollBgImg:getChildByName("leaderRankLab") --盟主排名
	local legionPerformance = scrollBgImg:getChildByName("legionPerformance") --同盟日绩效
	local myPerformance = scrollBgImg:getChildByName("myPerformance") --我的绩效

	local dayNum = data.dayNum --同盟日绩效
	local weekNum = data.weekNum --同盟周绩效
	local myNum = data.myNum --我的绩效
	local rank = data.rank --盟主排名
	local taskList = data.taskList --任务列表
	local rankInfo = data.rankInfo --绩效排名

	leaderNameLab:setString(weekNum)
	leaderRankLab:setString(rank)
	legionPerformance:setString(dayNum)
	myPerformance:setString(myNum)

	self:updateProgress(dayNum)
	self:updateTaskListPanel(taskList)
	self:updatePerformancePanel(rankInfo)
end

--请求数据  刷新数据（严格执行五分钟刷新请求一次   服务端下推数据之后  重置定时器）
function LegionTaskPanel:sendUpdateDataReq()
	print("请求刷新数据  sendUpdateDataReq")
	self.legionProxy:onTriggerNet590000Req()
end 

--同盟数据刷新
function LegionTaskPanel:updateLegionTaskInfo()
	local taskInfo = self.legionProxy:getLegionTaskInfo()
	if taskInfo then
		self:updatePanelInfo(taskInfo)
	end

	TimerManager:remove(self.sendUpdateDataReq, self)
	TimerManager:add(300000, self.sendUpdateDataReq, self, -1)
end

function LegionTaskPanel:showTaskGoods(rewardId,positionID,callback)
    if not self.LegionTaskRewarShowPanel then
        local parent = self:getParent()
        self.LegionTaskRewarShowPanel = LegionTaskRewarShowPanel.new(parent, self)
    end
    self.LegionTaskRewarShowPanel:updateInfos_Ex(rewardId,positionID,callback)
end

function LegionTaskPanel:helpBtnOnTap()
	local parent = self:getParent()
    local uiTip = UITip.new(parent)
    local lines = {
    	[0] = { { content = TextWords:getTextWord(560210) , foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601 } },
    	[1] = { { content = TextWords:getTextWord(560211), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601 } },
    	[2] = { { content = TextWords:getTextWord(560212), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601 } },
    	[3] = { { content = TextWords:getTextWord(560213), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601 } },
    	[4] = { { content = TextWords:getTextWord(560214), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601 } },
    }
    uiTip:setAllTipLine(lines)
end 