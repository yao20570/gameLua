-- /**
--  * @Author:	  fzw
--  * @DateTime:	2016-04-26 10:34:54
--  * @Description: 任务
--  */
TaskProxy = class("TaskProxy", BasicProxy)

function TaskProxy:ctor()
    TaskProxy.super.ctor(self)
    self.proxyName = GameProxys.Task
    self._taskInfoMap = {}
    self._mainTaskList = {} 
    self._mainTaskList2 = {} --二维数组存储主线任务
    self._dailyTaskList = {}
    self._activeTaskList = {}
    self._exploitTaskList = {}   --战功任务状态表
    self._exploitHasget = {}  --战功领取表
    self._exploitHasgetSort = {}  --战功任务已领取sort表
    self._dailynum = nil     --日常任务已完成次数
    self._activeID = 1
    self._dailyStatus = nil --日常任务放弃按钮标记：0变灰不可点击，1变亮可点击(接受按钮复用此变量)
    self._taskType = {1,2,3,4} --任务类型 1，主线任务，2每日任务，3每日活跃 ,4军功任务

	self._mainConf = ConfigDataManager:getConfigData(ConfigData.MainMissionConfig)
	self._dailyConf = ConfigDataManager:getConfigData(ConfigData.DayMissionConfig)
	self._activeConf = ConfigDataManager:getConfigData(ConfigData.DayActiveConfig)
    self._exploitConfig = ConfigDataManager:getConfigData(ConfigData.ActiveMissionRewardConfig)

end

function TaskProxy:resetAttr()
    self._taskInfoMap = {}
    self._mainTaskList = {}
    self._mainTaskList2 = {}
    self._dailyTaskList = {}
    self._activeTaskList = {}
    self._exploitTaskList = {}
    self._exploitHasget = {}
    self._exploitHasgetSort = {}  --战功任务已领取sort表
end

function TaskProxy:onReconnect()
	logger:info("== 断线重连 成功 清除任务数据 ！！ ==")
    self:resetAttr()
end

function TaskProxy:initSyncData(initData)
    TaskProxy.super.initSyncData(self, initData)
	self._initData = initData
end

--延迟初始化数据
function TaskProxy:afterInitSyncData()
	local data = self._initData.taskList
    self._heroMission = true

	local taskInfo = data.taskInfos
	self._dailynum = data.dayliynum
	self:_updateTaskInfo(taskInfo, data.dayActivityId)
	self._activeMaxID = data.hasGetMaxId
	self._exploitHasget = data.exploitHasget
	self:initExploitHasgetSort()
    self:sendNotification(AppEvent.PROXY_TASK_INFO_UPDATE, {})
    self:updateRedPoint()
end

-- 每日重置次数 待测
function TaskProxy:resetCountSyncData()
	-- logger:info("每日重置 ··· TaskProxy:resetCountSyncData")
	self._dailynum = 0     --日常任务已完成次数
	self._activeMaxID = 0  --日常活跃已领奖次数

    local roleProxy = self:getProxy(GameProxys.Role)
    roleProxy:setRoleAttrValue(PlayerPowerDefine.POWER_active, 0)
    roleProxy:setRoleAttrValue(PlayerPowerDefine.POWER_exploits, 0)
    
    local acticeTaskList = self._activeTaskList or {}
    for _, task in pairs(acticeTaskList) do
    	task.num = 0
        if task.state == 1 or task.state == 2 then --已经完成 重置
    	    task.state = 0
    	end
    end
    -- self._exploitTaskList = {}
    for k,v in pairs(self._exploitTaskList) do
    	self._exploitTaskList[k].finishTimes = 0
    	self._exploitTaskList[k].num = 0
    end
    self._exploitHasget = {}
    self._exploitHasgetSort = {}
    self.ItemsData = nil
    self:data2ItemData(true)
	self:sendNotification(AppEvent.PROXY_TASK_INFO_UPDATE, {})
end

-----------------------------------------------------------------------------
-- 请求协议
-----------------------------------------------------------------------------
-- 任务信息初始化/更新
function TaskProxy:onTriggerNet190000Req(data)
	self:syncNetReq(AppEvent.NET_M19, AppEvent.NET_M19_C190000, data)
end

-- 领取任务奖励
function TaskProxy:onTriggerNet190001Req(data)
	self:syncNetReq(AppEvent.NET_M19, AppEvent.NET_M19_C190001, data)
end

-- 请求日常任务信息/领奖
function TaskProxy:onTriggerNet190002Req(data)
	self:syncNetReq(AppEvent.NET_M19, AppEvent.NET_M19_C190002, data)
end

-- 领取活跃任务奖励
function TaskProxy:onTriggerNet190003Req(data)
	self:syncNetReq(AppEvent.NET_M19, AppEvent.NET_M19_C190003, data)
end

function TaskProxy:onTriggerNet190004Req(id)
	local data = {id = id}
	self:syncNetReq(AppEvent.NET_M19, AppEvent.NET_M19_C190004, data)
end


-----------------------------------------------------------------------------
-- 接收协议
-----------------------------------------------------------------------------
function TaskProxy:onTriggerNet190000Resp(data)
	-- body
	if data.rs == 0 then
		local taskInfo = data.taskInfos

		local mains = {}
		for k,v in pairs(taskInfo) do
			if v.tableType == 1 then
				table.insert(mains, v)
			end
		end

		local curMain = nil
		local showIndex = 9999
		for k,v in pairs(mains) do
			local config = self._mainConf[v.typeId]
			if config ~= nil and config.showorder < showIndex then
				showIndex = config.showorder
				curMain = v
			end
		end
		if curMain ~= nil then
			local config = self._mainConf[curMain.typeId]
			if config ~= nil then
				logger:error("当前主线任务是：%s", config.name)
			else
				logger:error("这个主线任务不能读表，id是%s",curMain.typeId)
			end
		else
			logger:error("请求了190000，却拿不到主线任务的数据")
		end
		

		self._dailynum = data.dayliynum
		self:_updateTaskInfo(taskInfo, data.dayActivityId)
		self._activeMaxID = data.hasGetMaxId

		-- local tasks = self:getMainTaskList2()
		-- local curMain = nil
		-- for k,v in pairs(tasks) do
		-- 	if v.tasktype == 1 then

		-- 	end
		-- end

	    self:sendNotification(AppEvent.PROXY_TASK_INFO_UPDATE, {})
	    self:updateRedPoint()
	
--    print("=========onTriggerNet190000Resp==========")
--    print_r(data)

	end
end

function TaskProxy:onTriggerNet190001Resp(data)
	if data.rs == -1 then
		self:onTriggerNet190000Req({})
		return
	end
	if data.rs ~= 0 and data.rs ~= -1 then
		return
	end
	if data.taskInfos == nil then
		return
	end

	local taskInfo = data.taskInfos
	self._dailynum = data.dayliynum
	
	if data.tableType == 1 then
		self:_setMainTaskList(taskInfo)
	elseif data.tableType == 2 then
		self:_setDailyStatus(0)
		self:_setDailyTaskList(taskInfo)
	end
	
--    print("=========onTriggerNet190001Resp==========")
--    print_r(data)

    self:sendNotification(AppEvent.PROXY_TASK_INFO_UPDATE, {})
    self:updateRedPoint()

end

function TaskProxy:onTriggerNet190002Resp(data)
	-- body
	if data.rs ~= 0 or data.taskInfos == nil then
		logger:info("XXX>>>>>>onTriggerNet190002Resp data error (190002)")
		return
	end

	self._dailynum = data.dayliynum

	local dailyTask = data.taskInfos

	local respType = data.type
	if respType == 1 then  --接受任务
		self:_setDailyStatus(0)
		self:_updateDailyTaskList(dailyTask)
		elseif respType == 2 then -- 放弃任务
			self:_setDailyStatus(0)
			self:_updateDailyTaskList(dailyTask)
			elseif respType == 3 then  --重置任务
				self:_setDailyStatus(0)
				self:_setDailyTaskList(dailyTask)
				elseif respType == 4 then --刷新任务
					self:_setDailyStatus(0)
					self:_setDailyTaskList(dailyTask)
					elseif respType == 5 then --快速完成
						self:_setDailyStatus(0)
						self:_setDailyTaskList(dailyTask)
					end

    self:sendNotification(AppEvent.PROXY_TASK_INFO_UPDATE, {})
    self:updateRedPoint()
end

function TaskProxy:onTriggerNet190003Resp(data)
	-- body
	if data.rs ~= 0 or data.taskInfos == nil then
		logger:info("XXX>>>>>>onTriggerNet190003Resp data error (190003)")
		return
	end
	-- self._activeID = data.dayActivityId
	self:_setActiveID(data.dayActivityId)
	self._activeMaxID = data.hasGetMaxId

	local activeTask = data.taskInfos
	if #activeTask > 0 then
		self:_setActiveTaskList(activeTask)
    end
    self:sendNotification(AppEvent.PROXY_TASK_INFO_UPDATE, {})
    self:updateRedPoint()
end

---------------------------------------------------------------------
-- 私有接口
-- 实例变量
---------------------------------------------------------------------
function TaskProxy:_updateTaskInfo(data, activeID)
	-- body
	local mainTask = {}
	local dailyTask = {}
	local activeTask = {}
	for k,v in pairs(data) do
		--print("task··· tableType typeId num state accept", v.tableType, v.typeId, v.num, v.state, v.accept)
		if v.tableType == self._taskType[1] then
			local config = self._mainConf[v.typeId]
			if config ~= nil then
				if config.stype == 47 then
					if v.state == 0 then
						self._heroMission = false
					end
				end
			end
			table.insert( mainTask, v )
		elseif v.tableType == self._taskType[2] then
			table.insert( dailyTask, v )
		elseif v.tableType == self._taskType[3] then
			table.insert( activeTask, v )
		elseif v.tableType == self._taskType[4] then
			self._exploitTaskList[v.typeId] = v
			-- local flag = false
			-- for exploitIndex, exploitInfo in pairs(self._exploitTaskList) do
			-- 	if exploitInfo.typeId == v.typeId then
			-- 		self._exploitTaskList[exploitIndex] = v
			-- 		flag = true
			-- 	end
			-- end
			-- if not flag then
			-- 	table.insert(self._exploitTaskList, v)
			-- end
		end
	end
	self:data2ItemData()
	if #mainTask > 0 then
		if #self._mainTaskList > 0 then
			mainTask = self:onProcessData(mainTask,self._mainTaskList)
		end
		self:_setMainTaskList(mainTask)
	end


	if #dailyTask > 0 then

		if #dailyTask < 5 then
			if #self._dailyTaskList > 0 then
				dailyTask = self:onProcessDailyData(dailyTask,self._dailyTaskList)
			end
		end

		self:_setDailyTaskList(dailyTask)
	end


	if #activeTask > 0 then
		if #self._activeTaskList > 0 then
			activeTask = self:onProcessData(activeTask,self._activeTaskList)
		end
		self:_setActiveTaskList(activeTask)
		self:_setActiveID(activeID)
	end
	-- logger:info("mainTask len = "..#mainTask)
	-- logger:info("dailyTask len = "..#dailyTask)
	-- logger:info("activeTask len = "..#activeTask)
end

function TaskProxy:onProcessData(tabData,selfData)
	-- body
	for k,v in pairs(selfData) do
		for i = #tabData,1,-1 do
			if tabData[i].typeId == v.typeId then
				selfData[k] = tabData[i]
				table.remove( tabData, i )
			end
		end
	end

	for k,v in pairs(tabData) do
		table.insert( selfData, v )
	end

	return selfData
end

function TaskProxy:onProcessDailyData(tabData,selfData)
	-- body
	for k,v in pairs(selfData) do
		for i = #tabData,1,-1 do
			-- if tabData[i].typeId == v.typeId and tabData[i].state == 3 then
			if tabData[i].typeId == v.typeId then
				if tabData[i].num > 0 or tabData[i].state == 3 then
					selfData[k] = tabData[i]
					table.remove( tabData, i )
				end
			end
		end
	end

	for k,v in pairs(tabData) do
		table.insert( selfData, v )
	end

	return selfData
end


-- 日常任务不需要客户端手动领奖
function TaskProxy:_mainTaskRewardInfo(taskInfo)
	-- body
	local Task = {}

	for k,v in pairs(taskInfo) do
		if v.tableType == self._taskType[1] then --主线领奖
			self:updateMainT(v)
		end
	end
end

function TaskProxy:_activeTaskRewardInfo(taskInfo)
	-- body
	local Task = {}

	for k,v in pairs(taskInfo) do
		if v.tableType == self._taskType[3] then --活跃领奖
			self:updateActiveT(v)
		end
	end
end

function TaskProxy:updateMainT(data)
	-- body
	local tabData = self._mainTaskList
	for k,v in pairs(tabData) do
		if v.typeId == data.typeId then
			tabData[k] = data
			break
		else
			table.insert(tabData,data)
			break
		end
	end

	self:_setMainTaskList(tabData)	
end


function TaskProxy:updateActiveT(data)
	-- body
	local tabData = self._activeTaskList
	for k,v in pairs(tabData) do
		if v.typeId == data.typeId then
			if data.state == 2 then
				tabData[k] = data
			end
		end
	end
	self:_setActiveTaskList(tabData)
end

function TaskProxy:_updateDailyTaskList(data)
	-- body
	if #self._dailyTaskList <= 0 then
		self:_setDailyTaskList(data)
	else
		for k,v in pairs(self._dailyTaskList) do
			if v.typeId == data[1].typeId then
				self._dailyTaskList[k] = data[1]
				break
			end
		end
		self._dailyTaskList = self:rankDailyTask(self._dailyTaskList)
	end
end

function TaskProxy:_setMainTaskList(data)
	-- body
	local info = {}
	local info,info2,info3 = self:rankMainTask(data)
	self._mainTaskList = info
	self._mainTaskList2 = info2
	self._mainTaskTitleList = info3
end

function TaskProxy:_setDailyTaskList(data)
	-- body
	local info = {}
	info = self:rankDailyTask(data)
	self._dailyTaskList = info
end

-- 设置日常任务放弃按钮状态
function TaskProxy:_setDailyStatus(status) -- 0=未接受，1=已接受，2=可领奖
	-- body
	self._dailyStatus = status
end

function TaskProxy:_setActiveID(activeID)
	-- body
	if activeID ~= nil and activeID > self._activeID then
		self._activeID = activeID
	end
end

function TaskProxy:_setActiveTaskList(data)
	-- body
	local info = {}
	info = self:rankActiveTask(data,nil)
	self._activeTaskList = info
end


-- 删除任务
function TaskProxy:delTask(tabData)
	-- body
	-- (从后往前)
	for i=#tabData,1,-1 do
		if tabData[i].state == 3 then
			table.remove(tabData,i)
		end
	end
	return tabData
end

-- 删除任务 tableType
function TaskProxy:delOtherTypeTask(tabData, tableType)
	-- body
	-- (从后往前)
	for i=#tabData,1,-1 do
		if tabData[i].tableType ~= tableType then
			table.remove(tabData,i)
		end
	end
	return tabData
end

function TaskProxy:TabAdd(info1,info2,info3)
	local tabData = {} -- info1
    for k,v in pairs(info1) do
        table.insert(tabData, v)            
    end 
	for k,v in pairs(info2) do
		table.insert(tabData, v)			
	end		
	for k,v in pairs(info3) do
		table.insert(tabData, v)			
	end		

	return tabData
end

-- 主线任务排序
function TaskProxy:rankMainTask(tabData)
	-- body

	--先清理state=3的任务
	tabData = self:delTask(tabData)

	-- 按任务ID重新排序
	table.sort(tabData, function(a,b) return a.typeId<b.typeId end )

	local conf = self._mainConf
	local info1 = {} --类1：基地建设-- (type=1:已完成->未完成)
	local info2 = {} --类2：角色任务-- (type=2:已完成->未完成)
	local info3 = {} --类3：资源产量-- (type=3:已完成->未完成)
	local finishFlag = {0,0,0}  --已完成的类要置顶，1=该类有已完成 0=该类没有已完成

	for k,v in pairs(tabData) do
		if v.state == 1 and v.tableType == 1 then --已完成
            local tasktype = conf[v.typeId].type
            v.tasktype = tasktype
			if tasktype == 1 then
				table.insert(info1, v)
				finishFlag[1] = 1
				elseif tasktype == 2 then
					table.insert(info2, v)	
					finishFlag[2] = 1
					elseif tasktype == 3 then
						table.insert(info3, v)
						finishFlag[3] = 1
			end
		end
	end

	local unDoneInfo2 = {}  --未完成的任务 type=2
	for k,v in pairs(tabData) do
		if v.state == 0 and v.tableType == 1 then --未完成
            local tasktype = conf[v.typeId].type
            v.tasktype = tasktype
			if tasktype == 1 then
				table.insert(info1, v)
				elseif tasktype == 2 then
					table.insert(unDoneInfo2, v)	
					elseif tasktype == 3 then
						table.insert(info3, v)
			end
		end
	end


	-- 支线任务未完成的按配表showorder排序
	local function camps(a, b)
		return conf[a.typeId].showorder < conf[b.typeId].showorder
	end
	table.sort(unDoneInfo2, camps)
	for _,v in pairs(unDoneInfo2) do
		table.insert(info2, v)
	end


	-- logger:error("主线任务>>>>>任务分类后>>主城发展 任务数量 = %d", #info2)
	-- logger:error("主线任务>>>>>任务分类后>>主公任务 任务数量 = %d", #info1)
	-- logger:error("主线任务>>>>>任务分类后>>资源产量 任务数量 = %d", #info3)

	-- 排序和显示的优先级别均为（2＞1＞3）
	-- -- 主线任务已完成的大类置顶
	local Flag = {finishFlag[2],finishFlag[1],finishFlag[3]}
	local tmp1 = info2
	local tmp2 = info1
	local tmp3 = info3

	local tmpInfo1 = tmp1
	local tmpInfo2 = tmp2
	local tmpInfo3 = tmp3

	-- print("----------(finishFlag1:---------",Flag[1])
	-- print("----------(finishFlag2:---------",Flag[2])
	-- print("----------(finishFlag3:---------",Flag[3])

	if Flag[1] == Flag[2] == Flag[3] then
		-- print("----------(Flag: 1=2=3 )---------",Flag[1])
	else

		-- if Flag[1] == 1 then
		-- 	if Flag[2] == 1 then --110
		-- 	elseif Flag[3] == 1 then --101
		-- 		tmpInfo2 = tmp3
		-- 		tmpInfo3 = tmp2
		-- 	end
		-- else
			-- if Flag[2] == 1 then
				tmpInfo1 = tmp2
				if Flag[3] == 1 then --011
					tmpInfo2 = tmp3
					tmpInfo3 = tmp1
				else --010
					tmpInfo1 = tmp2
					tmpInfo2 = tmp1
				end
			-- else
		-- 		if Flag[3] == 1 then --001
		-- 			tmpInfo1 = tmp3
		-- 			tmpInfo2 = tmp1
		-- 			tmpInfo3 = tmp2
		-- 		else

		-- 		end
		-- 	end

		-- end

	end

	-- if #tmpInfo1 > 0 then
	-- 	logger:error("主线任务>>>>>分类排序后>(1=主公任务 2=主城发展 3=资源产量)>分类%d>任务数量 = %d", tmpInfo1[1].tasktype, #tmpInfo1)
	-- end
	-- if #tmpInfo2 > 0 then
	-- 	logger:error("主线任务>>>>>分类排序后>(1=主公任务 2=主城发展 3=资源产量)>分类%d>任务数量 = %d", tmpInfo2[1].tasktype, #tmpInfo2)
	-- end
	-- if #tmpInfo3 > 0 then
	-- 	logger:error("主线任务>>>>>分类排序后>(1=主公任务 2=主城发展 3=资源产量)>分类%d>任务数量 = %d", tmpInfo3[1].tasktype, #tmpInfo3)
	-- end

	tabData = self:TabAdd( tmpInfo1, tmpInfo2, tmpInfo3)
	local tabData2, titleData = self:changeToList2( tmpInfo1, tmpInfo2, tmpInfo3)

	return tabData, tabData2, titleData
end


function TaskProxy:changeToList2(tab1, tab2, tab3)
	-- body
	-- 1=主公任务 2=主城发展 3=资源产量
	local tabData = {}
	local titleData = {}
	
	if #tab1 > 0 then
		-- print("-------tabData tab1[1].tasktype--------",tab1[1].tasktype)
		table.insert(tabData, tab1)
		table.insert(titleData, {tasktype = tab1[1].tasktype})
	end
	
	if #tab2 > 0 then
		-- print("-------tabData tab2[1].tasktype--------",tab2[1].tasktype)
		table.insert(tabData, tab2)
		table.insert(titleData, {tasktype = tab2[1].tasktype})
	end
	if #tab3 > 0 then
		-- print("-------tabData tab3[1].tasktype--------",tab3[1].tasktype)
		table.insert(tabData, tab3)
		table.insert(titleData, {tasktype = tab3[1].tasktype})
	end

	return tabData, titleData
end


-- 日常任务排序
function TaskProxy:rankDailyTask(tabData)
	-- body
	--先清理state=3的任务
	 tabData = self:delTask(tabData)

	-- 1:按任务ID重新排序
	table.sort(tabData, function(a,b) return a.typeId<b.typeId end )

	-- 2:给任务添加星级字段
	-- local confTab = "DayMissionConfig"
	local conf = self._dailyConf
	local status = self:getDailyStatus()
	for k,v in pairs(tabData) do
		v.star = conf[v.typeId].star
		if v.accept == 1 and status ~= 2 and v.tableType == 2 then
			if v.state == 1 then
				status = 2 --可领奖
			else
				status = 1 --已接受
			end
		end
	end
	
	-- 如果全部任务accept=0，则status=0
	local noAccept = true
    for k,v in pairs(tabData) do
    	if v.accept ~= 0 or v.state ~= 0 then
    		noAccept = false
    	end
    end
	if noAccept == true then
	   status = 0
	end
	
	self:_setDailyStatus(status)
	
	-- 3:按任务星级重新排序
	table.sort(tabData, function(a,b) return a.star>b.star end )

	-- 4:按任务接受状态重新排序 (已接受>未接受)
	local info = nil
	local accept = false
	for k,v in pairs(tabData) do
		if v.accept == 1 then
			info = v
			accept = true
			table.remove(tabData,k)
			break
		end
	end
	if accept == true then
		table.insert( tabData, 1, info )
	end

	return tabData
end

-- 日常活跃排序
-- 作为外部调用接口会更好！！
function TaskProxy:rankActiveTask(tabData,config)
	-- body

	-- 1：按任务ID重新排序
	table.sort(tabData, function(a,b) return a.typeId<b.typeId end )

	local roleProxy = self:getProxy(GameProxys.Role)
	local playerLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
	-- logger:info("playerLevel = "..playerLevel)
	local conf = self._activeConf
	local info1 = {} --未完成
	local info2 = {} --已完成
	local info3 = {} --未解锁

	-- 2：给全部任务插入解锁标记字段
	for k,v in pairs(tabData) do
		if v.state == 1 or v.state == 2 then
			v.isOpen = true
			table.insert(info2, v) -- 已完成
		elseif v.state == 0 and conf[v.typeId] ~= nil then --conf[v.typeId] ~= nil才可以执行
			-- logger:info("v.typeId = "..v.typeId)
			if conf[v.typeId].opencond <= playerLevel then
				v.isOpen = true
				table.insert(info1, v) -- 未完成
			else
				v.isOpen = false
				table.insert(info3, v) -- 未解锁
			end
		end
	end	

	-- 3：给未完成任务插入完成度百分比字段
	for k,v in pairs(info1) do
		local cur = tonumber(v.num) or 0
		local max = conf.finishcond2 or 0
		local per = nil
		if cur >= max then
			per = 100
		else
			per = cur / max * 100
		end
		v.per = per
	end
	-- 4：未完成任务按完成度从高到低排序
	table.sort(info1, function(a,b) return a.per>b.per end)


	-- 5：未解锁任务插入解锁等级字段
	for k,v in pairs(info3) do
		v.opencond = conf[v.typeId].opencond
	end
	-- 6：未解锁任务按解锁等级从低到高排序
	table.sort(info3, function(a,b) return a.opencond<b.opencond end)


	tabData = self:TabAdd( info1, info2, info3)
	return tabData
end

-------------------------------------------------------------------------------
-- 公共接口
-------------------------------------------------------------------------------
-- 首先：通过sendNotification给模块发事件通知，不发数据过去
-- 然后：在模块中自行调用以下接口获取对应的更新数据
-------------------------------------------------------------------------------

-- 获取最新主线任务列表数据(已排序)--二维结构
-- 转换：TaskProxy:changeToList2(tab1, tab2, tab3)
-- tabData[1] = {} --1=基地建设
-- tabData[2] = {} --2=角色任务 
-- tabData[3] = {} --3=资源产量
function TaskProxy:getMainTaskList2()
	-- body
	return self._mainTaskList2, self._mainTaskTitleList
end

--获取任务类型为type的主线任务 toolbar 任务快捷显示
-- type=1主线 type=2支线
function TaskProxy:getMainTaskListByType(type)
	local mainTaskLists = self:getMainTaskList2()
	local taskListType1 = {}
	for _, tasklist in pairs(mainTaskLists) do
		for _,taskInfo in pairs(tasklist) do
			if taskInfo.tasktype == type then
				taskInfo.conf = self._mainConf[taskInfo.typeId]
				table.insert(taskListType1,taskInfo)
			end
		end
	end

	local taskInfo = nil
	for k,v in pairs(taskListType1) do
		if taskInfo then
			if taskInfo["conf"].showorder > v["conf"].showorder then
				if type == 2 then
					--支线 优先显示已完成，再显示showorder最小的
					if v.state > taskInfo.state then
						taskInfo = v
					end
				else
				    --主线
					taskInfo = v
				end
			end
		else
			taskInfo = v
		end
	end

	-- print(".......................... task list size :",type,#taskInfo)
	return taskInfo
end

-- 获取最新主线任务列表数据(已排序)
function TaskProxy:getMainTaskList()
	-- body
	return self._mainTaskList
end

-- 获取最新日常任务列表数据(不用排序)
function TaskProxy:getDailyTaskList()
	-- body
	return self._dailyTaskList
end
-- 获取最新日常活跃列表数据(已排序)
function TaskProxy:getActiveTaskList()
	-- body
	return self._activeTaskList
end
-- 获取日常任务任务完成数
function TaskProxy:getDailyFinishNumber()
	-- body
	return self._dailynum
end
-- 获取日常任务放弃按钮状态
function TaskProxy:getDailyStatus()  -- 0=未接受，1=已接受，2=可领奖
	-- body
	return self._dailyStatus
end
-- 获取日常活跃Id(id:匹配表ActiveRewardConfig)
function TaskProxy:getActiveID()
	-- body
	return self._activeID
end
-- 获取日常活跃max Id
function TaskProxy:getActiveMaxID()
	-- body
	return self._activeMaxID
end

-- 活跃可领取奖励状态
function TaskProxy:getActiveState()
	-- body
	-- if self._activeID == nil then
	-- 	self._activeID = 1
	-- end
	local conf = ConfigDataManager:getConfigById("ActiveRewardConfig",self._activeID)
	local roleProxy = self:getProxy(GameProxys.Role)
	local cur = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_active)
	local max = conf.activeneed

	local ActiveState = false --不可领取
	if cur >= max then
		ActiveState = true --可领取
	end

	return ActiveState
end

-------------------------------------------------------------------------------
-- 测试接口
-------------------------------------------------------------------------------
-- 模拟190000发来的数据
function TaskProxy:RandomMain()
	-- body
	local info = {}
    info.tableType = 1
    info.typeId = math.random(2101,2140)
    info.num = 0
    info.state = math.random(4) - 1
    info.accept = 0

    return info
end

function TaskProxy:testMain()
	-- body
	local info = {}

    math.randomseed(os.clock())
	for i=1,10 do
		info[i] = self:RandomMain()	
	end

	info,info2,info3 = self:rankMainTask(info)
	return info
end


--小红点更新
function TaskProxy:updateRedPoint()
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:checkTaskRedPoint() 
end

--获取战功列表
function TaskProxy:getExploitTaskList()
	return self._exploitTaskList
end	


--获取战功ItemData
function TaskProxy:getItemsData()
	return self.ItemsData
end

function TaskProxy:getExploitHasget()
	return self._exploitHasget
end

function TaskProxy:addExploitHasget(id)
	table.insert(self._exploitHasget, id)
	self:addExploitHasgetSort(id)
end

-- 是否已领取过同个sort的奖励
function TaskProxy:isCanGetEexploitReward(id)
	local config = ConfigDataManager:getConfigById(ConfigData.ActiveMissionRewardConfig, id)
	for k,v in pairs(self._exploitHasgetSort) do
		if v == config.sort then
			-- logger:info("已经领取过的sort %d %d",v,id)
			return true
		end
	end
	-- logger:info("没领取过的 %d ",id)
	return false
end

function TaskProxy:initExploitHasgetSort()
	for k,v in pairs(self._exploitHasget) do
		self:addExploitHasgetSort(v)
	end
end

function TaskProxy:addExploitHasgetSort(id)
	local config = ConfigDataManager:getConfigById(ConfigData.ActiveMissionRewardConfig, id)
	local isNew = true
	for k,v in pairs(self._exploitHasgetSort) do
		if v == config.sort then
			isNew = false
			break
		end
	end
	if isNew == true then
		table.insert(self._exploitHasgetSort, config.sort)
	end
end

-- 战功宝箱所需额度值根据等级改变而改变
function TaskProxy:getConfigByPlayerLevel()
    if self._exploitConfig == nil then
        self._exploitConfig = ConfigDataManager:getConfigData(ConfigData.ActiveMissionRewardConfig)
    end
    local roleProxy = self:getProxy(GameProxys.Role)
    local playerLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    local tempMap = {}
    for k,v in pairs(self._exploitConfig) do
        local level = StringUtils:jsonDecode(v.level)
        if level[1] <= playerLevel and level[2] >= playerLevel then
            -- logger:info("--战功任务 level : %d %d",level[1],level[2])
           table.insert(tempMap,v)
            -- tempMap[v.ID] = v
        end
    end
    return tempMap
end


--主线任务小红点数量
function TaskProxy:getCont1()
	local count = 0
	local mainTaskLists = self:getMainTaskList2()
	for _, tasklist in pairs(mainTaskLists) do
		for _,taskInfo in pairs(tasklist) do
			if taskInfo.state == 1 then
				count = count + 1
			end
		end
	end
	return count
end

--战功任务小红点数量
function TaskProxy:getCont2()
	local configInfos = self:getConfigByPlayerLevel()
	local currentValue = self:getExploitValue()
	local count = 0
	for k,v in pairs(configInfos) do
		if currentValue >= v.activeneed then
			count = count + 1
		end
	end
	for k,v in pairs(self._exploitHasgetSort) do
		count = count - 1
	end
	return count
end

function TaskProxy:getExploitValue()
	local roleProxy = self:getProxy(GameProxys.Role)
	local ExploitValue = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_exploits) or 0
	return ExploitValue
end
	
function TaskProxy:data2ItemData(reset)
    local roleProxy = self:getProxy(GameProxys.Role)
    local playerLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    local lockTaskList = {}
    local unFinish = {}
    local Finished = {}

    local exploitTaskList = self:getExploitTaskList()

    local config = ConfigDataManager:getConfigData(ConfigData.ActiveMissionConfig)
    for k,v in pairs(config) do
    	local taskInfo = exploitTaskList[v.ID]
    	local completionTime = 0
    	if taskInfo ~= nil then
    		completionTime = taskInfo.completionTime or 0
    	end
    	rawset(v, "completionTime", completionTime)
    	--等级低属于未解锁
    	if v.opencond > playerLevel then
    		table.insert(lockTaskList, v)
    	else
    		--没发也是未解锁
    		if taskInfo == nil then
    			table.insert(lockTaskList, v)
    		else
    			if reset ~= nil then
    				table.insert(unFinish, v)
    			else
    				--解锁的，区分完成和未完成
		    		if taskInfo.finishTimes < v.finishNum then
		    			table.insert(unFinish, v)
		    		else
		    			table.insert(Finished, v)
		    		end
    			end
    		end
    	end
    end

    table.sort(Finished, function(a, b)
    	return a.completionTime > b.completionTime
    end)

    table.sort(unFinish, function(a, b)
    	return a.sort < b.sort
    end)

    if #lockTaskList >0 then
    	table.sort(lockTaskList, function(a, b)
    		return a.opencond < b.opencond
    	end)
    end

    local taskData = {}

    --先插入解锁未完成
    for i=1,#unFinish do
    	table.insert(taskData, unFinish[i])
    end

    --插入解锁完成
    for i=1,#Finished do
    	table.insert(taskData, Finished[i])
    end


    --未解锁
    for i=1,#lockTaskList do
    	table.insert(taskData, lockTaskList[i])
    end

    local infos = TableUtils:splitData(taskData, 3)
 
    self.ItemsData = infos
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- 任务引导跟踪
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function TaskProxy:registerNetEvents()
    self:addEventListener(AppEvent.PROXY_TASK_INFO_UPDATE, self, self.updateRoleInfoRsp)
end

function TaskProxy:unregisterNetEvents()
    self:removeEventListener(AppEvent.PROXY_TASK_INFO_UPDATE, self, self.updateRoleInfoRsp)
end

function TaskProxy:updateRoleInfoRsp()
	if self:getMainTaskGuideFlag() == true then
		if self:isCanShowMsgBox() == true then
			if self:isFinishMainTask() == true then
				self:showRewardMainTaskBox()
			end
		end
	end
end

-- 主线任务判定字段windscontrol 0不弹，1弹
function TaskProxy:isCanShowMsgBox()
	local isShow
	local taskInfo = self:getMainTaskListByType(1)
	if taskInfo.conf.windscontrol == 0 then
		isShow = false
	else
		isShow = true
	end
	return isShow
end

-- 是否已完成主线任务
function TaskProxy:isFinishMainTask()
	local isFinishMainTask
	local guideInfo = self:getMainTaskGuide()
	local taskInfo = self:getMainTaskListByType(1)
	if guideInfo == nil or guideInfo.tasktype ~= taskInfo.tasktype or guideInfo.typeId ~= taskInfo.typeId then
		isFinishMainTask = false  --不是同一个任务
		self:setMainTaskGuideFlag(nil)
	else
		if taskInfo.conf.finishcond2 <= taskInfo.num then
			-- 已完成
			isFinishMainTask = true
		else
			-- 未完成
			isFinishMainTask = false
		end
	end

	return isFinishMainTask
end

function TaskProxy:getBuildingModuleName(jumpModuleName)
	local buildingProxy = self:getProxy(GameProxys.Building)
	local buildingConfigInfo, name = buildingProxy:getBuildConfigByModuleName(jumpModuleName)
	if buildingConfigInfo == nil and  name == nil then
	    -- self:showSysMessage(TextWords:getTextWord(356))
	    return nil
	end
	if buildingConfigInfo ~= nil then
	    jumpModuleName = name
	end
	return jumpModuleName
end

-- 弹窗显示是否领取主线任务奖励
function TaskProxy:showRewardMainTaskBox()
	local taskInfo = self:getMainTaskGuide()
	local jumpModuleName = taskInfo.conf.jumpmodule
	local panelName = taskInfo.conf.reaches
	local guideID = taskInfo.conf.guideID
	print(".....................引导任务",jumpModuleName,panelName,guideID)

	-- if guideID then
	-- 	if guideID == 225 or guideID == 226 then  --主城空地建造建造引导
	-- 		self:setMainTaskGuideFlag(nil)
	-- 		return
	-- 	end
	-- end

	if jumpModuleName ~= nil then
		local moduleName = self:getBuildingModuleName(jumpModuleName)
		if moduleName == nil then
			self:showSysMessage(TextWords:getTextWord(356))
			return
		else
			if moduleName == ModuleName.RegionModule then

			elseif self:isModuleShow(moduleName) == false then
				self:setMainTaskGuideFlag(nil)
				return
			end
		end
	end

	
	local function yesCallback()
		self:setMainTaskGuideFlag(nil)
		local curShowModuleName = self:getCurShowModuleName()
		if curShowModuleName == ModuleName.MapModule or guideID ~= nil then
			-- 世界地图 OR 引导任务 不走建筑类型判定
		else
			jumpModuleName = self:getBuildingModuleName(jumpModuleName)
			if jumpModuleName == nil then
				self:showSysMessage(TextWords:getTextWord(356))
			end
		end

		if jumpModuleName == ModuleName.MainSceneModule then  
			--当前是主城，只关闭对应panel
			-- jumpModuleName = curShowModuleName
			self:sendNotification(AppEvent.PROXY_TASK_GUIDE,{panelName = panelName})
		
		elseif jumpModuleName == ModuleName.RegionModule or guideID == 105 then  --TODO 副本任务引导 待处理 先写死ID
			--写死两个模块
			self:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = ModuleName.RegionModule, unlink = true})
            self:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = ModuleName.DungeonModule, unlink = true})
			-- self:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = curShowModuleName , unlink = true})
			-- self:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = jumpModuleName , unlink = true})
			self:showModule({ moduleName = ModuleName.MainSceneModule })

		else
		    --关闭当前模块，并打开主城模块  --TODO 副本关闭未处理
			self:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = jumpModuleName })
			self:showModule({ moduleName = ModuleName.MainSceneModule })
		end

        EffectQueueManager:completeEffect()
	end

	local function noCallback()
		self:setMainTaskGuideFlag(nil)
        EffectQueueManager:completeEffect()
	end


	--local str = string.format(TextWords:getTextWord(1338),taskInfo.conf.name)
	--self:showMessageBox(str,yesCallback,noCallback)

    local function openMessageBox()
        local str = string.format(TextWords:getTextWord(1338), taskInfo.conf.name)
	    self:showMessageBox(str,yesCallback,noCallback)
    end
    EffectQueueManager:addEffect(EffectQueueType.MessageBox, openMessageBox)
end

-- 记录引导的任务
function TaskProxy:setMainTaskGuide(data,flag)
	self._mainTaskGuide = data
	self:setMainTaskGuideFlag(flag)
end

-- 获取引导的任务
function TaskProxy:getMainTaskGuide()
	return self._mainTaskGuide
end

-- 设置引导状态
function TaskProxy:setMainTaskGuideFlag(flag)
	self._mainTaskGuideFlag = flag
end

-- 获取引导状态
function TaskProxy:getMainTaskGuideFlag()
	return self._mainTaskGuideFlag
end

--设置引导的副本信息
function TaskProxy:setGuideDungeonInfo(dungeonId)
	--通过副本ID获取章节ID
	local event = ConfigDataManager:getConfigById(ConfigData.EventConfig, dungeonId)

	self._guideChapter = event.chapter
	self._guideDungeonId = event.sort
end

--获取引导的副本信息
function TaskProxy:getGuideDungeonInfo()
	return self._guideChapter, self._guideDungeonId
end

function TaskProxy:setGuideFlag(chapter)
	self._flag = chapter
end
function TaskProxy:getGuideFlag()
	return self._flag
end

--获得英雄图鉴任务的完成情况
--false  打开图鉴面板需要请求协议
function TaskProxy:getHeroMissionFlag()
	return self._heroMission
end

-- 
function TaskProxy:setBarrackRecruitGuide(taskInfo)
    self._barrackRecruitTaskInfo = taskInfo
end

-- 
function TaskProxy:getBarrackRecruitGuide()
    return self._barrackRecruitTaskInfo
end

