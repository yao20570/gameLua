---------------------------------------------------------------------
-- /**
--  * @Author:	  fzw
--  * @DateTime:	2016-01-12 11:50:10
--  * @Description: 军团总数据代理
--  */
---------------------------------------------------------------------
LegionProxy = class("LegionProxy", BasicProxy)

function LegionProxy:ctor()
    LegionProxy.super.ctor(self)
    self.proxyName = GameProxys.Legion
	
	self._itemConf = {200, 201, 202, 204, 203, 205}	--捐赠资源顺序 金币类型定为200
	self._totalConf = self:initTotalData()
    self.shopList = {}
    self.myContribute = 0
    self.mySalary = 0 --我的俸禄
    self.legionLv = 0
    self._legionBuildingInfo = {}
    self.adviceInfo = {} -- 军情
    self.peopleInfo = {} -- 民情
    self.honourInfo = {} -- 荣耀

    self.taskInfo = nil --同盟任务
    self.lastGetTaskInfoTime = false --上次获取同盟任务信息时间


    self._contributeInfo = {0, 0} -- 贡献情况存储

    self._mineInfo  = {} -- /自己的军团详细信息

	self._sciCurCount = self:initCurCount()
	self._hallCurCount = self:initCurCount()

    self._legionEditKeyList = {"joinType","joinCond1","joinCond2","notice","affiche"}

    self._legionTown={}
    self._legionCapital= {}
    self._legionImperial= {}


end

function LegionProxy:resetAttr()
    self._legionBuildingInfo = {}
    self.adviceInfo = {}
    self.peopleInfo = {}
    self.shopList = {}
    self._totalConf = self:initTotalData()
    self._approvePoint = 0
end

------
-- 初始化接收，目前只有军团福利所领取信息，
function LegionProxy:initSyncData(data)
    -- 如果是nil也可以表示未加入军团
    self._canGetDailyReward = nil 
    for key, value in pairs(data) do
        if key == "isCanGetWelf" then
            self._canGetDailyReward = data.isCanGetWelf.isCanGetWelfInfo
            break
        end
    end
    -- 活跃资源奖励
    self._welfareInsfos = {}
    self._welfareInsfos.panelInfo = data.panelInfo or {}-- 没有则证明没有军团
    self.taskInfo = data.legionTask or nil
end

-- 每日重置次数 待测
function LegionProxy:resetCountSyncData()
    logger:info("每日重置 ··· LegionProxy:resetCountSyncData")

    self._sciCurCount = {}
    self._hallCurCount = {}
    self._sciCurCount = self:initCurCount()    --军团科技捐献次数重置
    self._hallCurCount = self:initCurCount()   --军团大厅捐献次数重置

    local tmpData = {id=0, opt=0, type = 0}
    -- local tmpData2 = {id=0,opt=0, type = 1}
    local roleProxy = self:getProxy(GameProxys.Role)
    if roleProxy:hasLegion() then
        self:onTriggerNet220002Req(tmpData)
        -- self:onTriggerNet220002Req(tmpData2)
        local data = {}
        self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220012, data)
    else
        print("你没有军团，不需要请求军团信息")
end
    


-------------------福利所数据重置---------------------------------

-------------------XXXXXXXXXXXXXX---------------------------------
end

-- 初始化捐献配表，缓存到用restype+num做下标的表，并返回。
function LegionProxy:initTotalData()
	-- body
	local resConf = ConfigDataManager:getConfigData(ConfigData.ResContributeConfig)
	local goldConf = ConfigDataManager:getConfigData(ConfigData.GoldContibuteConfig)

	local tabData = {}

	for k,v in pairs(resConf) do
        local num = v.num
		tabData[v.restype..num] = v
	end

	local restype = 200		--金币自定义类型200
	for k,v in pairs(goldConf) do
		v.restype = restype
		v.reqneed = v.goldneed
        local num = v.num
		tabData[restype..num] = v
	end

	return tabData
end

-- 根据当前捐赠次数curCount，获取对应次数的全部类别资源数据
function LegionProxy:getResData(curCountTab)
	-- body
	local tabData = {}

	for k,v in pairs(self._itemConf) do
        local curCount = curCountTab[v].curCount
        local maxCount = curCountTab[v].maxCount
        if curCount > maxCount then
            curCount = maxCount
            logger:info("curCount="..curCount..",maxCount="..maxCount)
        end
		local data = self._totalConf[v..curCount]
		table.insert(tabData, data)
	end

	return tabData
end

-- 读取玩家当前拥有的各类别资源数据
function LegionProxy:getResNumber()
	local data = {}
	data[200] = {}
	data[201] = {}
	data[202] = {}
	data[204] = {}
	data[203] = {}
	data[205] = {}

	local power = GamePowerConfig.Resource
	local defConf = {
		PlayerPowerDefine.POWER_gold,		--金币(元宝)
		PlayerPowerDefine.POWER_tael,		--银两
		PlayerPowerDefine.POWER_iron,		--铁锭
        PlayerPowerDefine.POWER_stones,     --石料
		PlayerPowerDefine.POWER_wood,		--木材
		PlayerPowerDefine.POWER_food,		--粮食
	}

	local roleProxy = self:getProxy(GameProxys.Role)
	for i=1,#self._itemConf do
		local curNum = nil
		if self._itemConf[i] == 200 then
    		curNum = roleProxy:getRoleAttrValue(defConf[i])--金币(元宝)
		else
			curNum = roleProxy:getRolePowerValue(power,defConf[i]) or 0--当前资源拥有量
		end
		data[self._itemConf[i]] = curNum
	end

    return data
end

-- 初始化科技捐献次数
function LegionProxy:initCurCount()
	-- body
	local tabData = {}
	tabData[200] = {curCount = 0, maxCount = 30}	--金币最多捐献30次
	tabData[201] = {curCount = 0, maxCount = 6}
	tabData[202] = {curCount = 0, maxCount = 6}
	tabData[204] = {curCount = 0, maxCount = 6}
	tabData[203] = {curCount = 0, maxCount = 6}
	tabData[205] = {curCount = 0, maxCount = 6}

	return tabData
end
---------------------------------------------------------------------

-- 缓存科技捐献次数
function LegionProxy:updateSciCurCount(data)
	-- body
	for k,v in pairs(data) do
        if self._sciCurCount[v.resType] ~= nil then
            self._sciCurCount[v.resType].curCount = v.curCount
            -- print("科技次数update: restype="..v.resType..",curCount="..v.curCount)
        end
    end
end

-- 获取科技已捐献次数
function LegionProxy:getSciCurCount()
    -- body
    return self._sciCurCount
end

-- 获取科技已捐献次数
function LegionProxy:getSciTotalCount()
    local totalCount = 0
    for _,v in pairs(self._sciCurCount) do
        totalCount = totalCount + v.curCount
    end
	return totalCount
end


-- 缓存大厅捐献次数
function LegionProxy:updateHallCurCount(data)
	-- body
    for k,v in pairs(data) do
        if self._hallCurCount[v.resType] ~= nil then
            self._hallCurCount[v.resType].curCount = v.curCount
            -- print("大厅次数update: restype="..v.resType..",curCount="..v.curCount)
        end
    end
end

-- 获取大厅已捐献次数
function LegionProxy:getHallCurCount()
	-- body
	return self._hallCurCount
end


---------------------------------------------------------------------
---------------------------------------------------------------------
-- 以下部分预留来处理协议相关数据
---------------------------------------------------------------------
---------------------------------------------------------------------
-- function LegionProxy:registerNetEvents()
--     self:registerNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220200, self, self.onTriggerNet220200Resp)
--     self:registerNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220210, self, self.onTriggerNet220210Resp)
--     self:registerNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220203, self, self.onTriggerNet220203Resp)
--     self:registerNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220201, self, self.onTriggerNet220201Resp)
--     self:registerNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220221, self, self.onTriggerNet220221Resp)
--     self:registerNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220220, self, self.onTriggerNet220220Resp)
--     self:registerNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220002, self, self.onTriggerNet220002Resp)
--     -- self:registerNetEvent(AppEvent.NET_M21, AppEvent.NET_M21_C210000, self, self.onTriggerNet210000Resp)
--     self:registerNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220010, self, self.onTriggerNet220010Resp)--科技大厅信息
--     self:registerNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220007, self, self.onTriggerNet220007Resp)--军团大厅信息
--     self:registerNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220013, self, self.onTriggerNet220013Resp)--福利院信息
--     self:registerNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220000, self, self.onTriggerNet220000Resp)
--     self:registerNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220300, self, self.onTriggerNet220300Resp)
--     self:registerNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220205, self, self.onTriggerNet220205Resp)  --审批小红点
--     self:registerNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220400, self, self.onTriggerNet220400Resp)  --军团招募
--     self:registerNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220009, self, self.onTriggerNet220009Resp)  --军团科技捐献
-- end

-- function LegionProxy:unregisterNetEvents()
--     self:unregisterNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220200, self, self.onTriggerNet220200Resp)
--     self:unregisterNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220210, self, self.onTriggerNet220210Resp)
--     self:unregisterNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220203, self, self.onTriggerNet220203Resp)
--     self:unregisterNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220201, self, self.onTriggerNet220201Resp)
--     self:unregisterNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220221, self, self.onTriggerNet220221Resp)
--     self:unregisterNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220220, self, self.onTriggerNet220220Resp)
--     self:unregisterNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220002, self, self.onTriggerNet220002Resp)
--     -- self:unregisterNetEvent(AppEvent.NET_M21, AppEvent.NET_M21_C210000, self, self.onTriggerNet210000Resp)
--     self:unregisterNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220010, self, self.onTriggerNet220010Resp)--科技大厅升级
--     self:unregisterNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220007, self, self.onTriggerNet220007Resp)--军团大厅信息
--     self:unregisterNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220013, self, self.onTriggerNet220013Resp)--福利院信息
--     self:unregisterNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220000, self, self.onTriggerNet220000Resp)
--     self:unregisterNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220300, self, self.onTriggerNet220300Resp)
--     self:unregisterNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220205, self, self.onTriggerNet220205Resp)  --审批小红点
--     self:unregisterNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220400, self, self.onTriggerNet220400Resp)  --军团招募
--     self:unregisterNetEvent(AppEvent.NET_M22, AppEvent.NET_M22_C220009, self, self.onTriggerNet220009Resp)  --军团科技捐献
-- end

-------------------------------------------------------------------------
-- 请求协议
-------------------------------------------------------------------------
--军团编辑请求，这里会做一次校验
function LegionProxy:onTriggerNet220210Req(data)
    local reqData = {}
    local updateList = {}
    for _, key in pairs(self._legionEditKeyList) do
        if data[key] ~= self._mineInfo[key] then
            reqData[key] = data[key]
            local index = table.indexOf(self._legionEditKeyList, key)
            table.insert(updateList,index)
        end
    end
    reqData.updateList = updateList
    data.updateList = updateList
    
    if #updateList > 0 then
        self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220210, reqData)
        
        -- self:onTriggerNet220210Resp(data) --自己的，直接更新
    else
        self:showSysMessage( TextWords:getTextWord(3008) )
    end
end

-- 请求220012，福利所信息,保证数据最新
function LegionProxy:onTriggerNet220012Req()
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220012, {})
end


--请求审核列表
function LegionProxy:onTriggerNet220202Req()
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220202, {})
end

function LegionProxy:onTriggerNet220203Req(data)
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220203, data)
end

function LegionProxy:onTriggerNet220204Req(data)
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220204, data)
end

--军团成员操作
function LegionProxy:onTriggerNet220201Req(data)
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220201, data)
end

function LegionProxy:onTriggerNet220220Req(data)
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220220, data)
end

function LegionProxy:onTriggerNet220221Req(data)
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220221, data)
end

-- 请求科技大厅升级
function LegionProxy:onTriggerNet220010Req(data)
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220010, data)
end

-- 请求军团商店
function LegionProxy:onTriggerNet220002Req(data)
    logger:info("请求军团商店 220002Req>> data.type=%d", data.type)
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220002, data)
end

--请求科技捐献
function LegionProxy:onTriggerNet220009Req(data)
    self:syncNetReq(AppEvent.NET_M22,AppEvent.NET_M22_C220009, data)
end

--请求军团大厅捐献
function LegionProxy:onTriggerNet220008Req(data)
    self:syncNetReq(AppEvent.NET_M22,AppEvent.NET_M22_C220008, data)
end

--请求军团大厅信息or升级
function LegionProxy:onTriggerNet220007Req(data)
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220007, data) --军团大厅信息
end

--请求军团列表
function LegionProxy:onTriggerNet220100Req(data)
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220100, {}) --军团列表
end

--请求保存内部公告
function LegionProxy:onTriggerNet220211Req(data)
    self._lastAfficheReqStr = data.affiche
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220211, data)
end

--请求查看军团详细信息
function LegionProxy:onTriggerNet220101Req(data)
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220101, data)
end

--请求自己的军团信息
function LegionProxy:onTriggerNet220200Req()
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220200, {}) --军团信息
end

--请求军团建筑等级信息
function LegionProxy:onTriggerNet220000Req()
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220000, {}) --军团建筑等级信息
end

--请求战事福利列表
function LegionProxy:onTriggerNet220016Req()
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220016, {})
end

function LegionProxy:onTriggerNet220503Req()
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220503, {})
end

function LegionProxy:onTriggerNet220600Req()
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220600, {})
end
-- 军团公告请求推送
function LegionProxy:onTriggerNet220700Req(data)
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220700, data)
end

-------------------------------------------------------------------------
-- 接收协议
-------------------------------------------------------------------------
----------------------------军团信息-------------------------------------
--初始化获取自己的军团总信息，每次打开军团信息请求
function LegionProxy:onTriggerNet220200Resp(data)
    if data.rs == 0 then
        self._mineInfo = data.mineInfo
        
        -- print("个人贡献值···mineInfo.myContribute",data.mineInfo.myContribute) --TODO 测试新字段

        self._memberInfoMap = {}
        for _, memberInfo in pairs(data.memberInfos) do
            self._memberInfoMap[memberInfo.id] = memberInfo
        end

        self.allPerSonData = data.memberInfos
        
        self._customJobMap = {}
        for _, jobInfo in pairs(data.mineInfo.customJobInfos) do
            self._customJobMap[jobInfo.index] = jobInfo
        end
        
        self:sendNotification(AppEvent.PROXY_LEGION_INFO_UPDATE, {})
    end
end

function LegionProxy:onTriggerNet220600Resp(data)
    if data.rs == 0 then
        self._mineInfo = data.mineInfo

        self._welfareInsfos.panelInfo = data.panelInfo  --同盟活跃信息
        self._canGetDailyReward = data.iscangetWelf -- 是否可领取每日福利
        self._shortInfos = data.shortInfos
        self._dungeonInfos = data.dungeonInfos
        self._armyInfo = data.armyInfo
        if data.armyInfo.armyLv ~= nil then
            self:_updateLegionBuildingInfo(2,data.armyInfo.armyLv)
        end
        
        self._memberInfoMap = {}
        for _, memberInfo in pairs(data.memberInfos) do
            self._memberInfoMap[memberInfo.id] = memberInfo
        end

        self.allPerSonData = data.memberInfos
        
        self._customJobMap = {}
        for _, jobInfo in pairs(data.mineInfo.customJobInfos) do
            self._customJobMap[jobInfo.index] = jobInfo
        end
        local dataTemp = {}
        dataTemp.shortInfos = data.shortInfos
        self:sendNotification(AppEvent.PROXY_LEGION_INFO_INIT, dataTemp)
        --self:sendNotification(AppEvent.PROXY_LEGION_INFO_UPDATE, {})
    end
end

--军团团长解散军团
function LegionProxy:onTriggerNet220503Resp(data)
    if data.rs >= 0 then
        data.message = 1 --团长要飘的字
        self:_onExitLegionHandler(data)
    end
end

--更新成员列表贡献度
function LegionProxy:onTriggerNet220018Resp(data)
    if data == nil or self._memberInfoMap == nil then
        return 
    end

    for k , v in pairs(self._memberInfoMap) do 
        if v.id == data.id then 
            self._memberInfoMap[k].devotoWeek = data.devotoWeek
            break
        end
    end
end


--编辑推送
function LegionProxy:onTriggerNet220210Resp(data)
    if data.rs == 0 then
        if #data.updateList > 0 then
            local updateMap = {}
            for _, index in pairs(data.updateList) do
                local key = self._legionEditKeyList[index]
                
                local tmpData = {}
                tmpData[key] = data[key]
                table.insert(updateMap, tmpData)
            end
            
            self:_updateMineLegionInfo(updateMap)
        end
    end
end

function LegionProxy:onTriggerNet220203Resp(data)
    if data.rs == 0 then
        -- 刷新申请列表 begin
        if self._applyInfos ~= nil then -- 如果是会长才有这个审批数据
            for k, v in pairs(self._applyInfos) do
                if v.id == data.id then
                    table.remove(self._applyInfos, k)
                    break
                end
            end
        end
        self:sendNotification(AppEvent.PROXY_LEGION_INIT_APPLY_INFO_CHANGE, data)-- 刷新申请列表 end 

        if data.type == 1 then  --增加了一个成员
            local memberInfos = data.memberInfo

            local roleProxy = self:getProxy(GameProxys.Role)
            if data.id == roleProxy:getPlayerId()  then --自己进入军团了 改变
                local atom = StringUtils:fined64ToAtom(data.legionId) --TODO 容错，使用32位就行了
                roleProxy:setLegionId(data.legionId)
                roleProxy:setRoleAttrValue(PlayerPowerDefine.POWER_LegionId, atom.low)
                roleProxy:sendNotification(AppEvent.PROXY_LEGION_MAINSCENE_BUILDING_UPDATE, {})
                roleProxy:sendNotification(AppEvent.PROXY_UPDATE_ROLE_INFO, {PlayerPowerDefine.POWER_LegionId})
                self:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.LegionApplyModule})
                return
            else
                self:showSysMessage(TextWords:getTextWord(3012))
            end

            -- self:_updateMemberInfo(memberInfo.id, memberInfo)
            for i=1,#memberInfos - 1 do
                local v = memberInfos[i]
                self:_updateMemberInfo(v.id, v, true)
            end
            local lastData = memberInfos[#memberInfos]
            self:_updateMemberInfo(lastData.id, lastData)
            

            -- local curNum = self._mineInfo["curNum"]
            -- self:_updateMineLegionInfo({curNum = curNum + 1})

            -- self._mineInfo["curNum"] = self._mineInfo["curNum"] + 1
            
            local curNum = self._mineInfo["curNum"]
            local updateMap = {}
            table.insert(updateMap, {curNum = curNum + 1})
            self:_updateMineLegionInfo(updateMap)
        end
    end
end

--成员操作，发过来的ID，需要跟自己的ID进行校验，处理各种情况
function LegionProxy:onTriggerNet220201Resp(data)
    if data.rs == 0 then
        local type = data.type
        local roleProxy = self:getProxy(GameProxys.Role)
        local ownPlayerId = roleProxy:getPlayerId()

        --全更成员数据   之后再分类处理   保持军团成员数据是最新的
        self._memberInfoMap = self._memberInfoMap or {}
        for k,v in pairs(data.info) do
            self._memberInfoMap[v.id] = v
        end

        if type == 1 then --踢出军团
            if data.id == ownPlayerId then  --自己给踢出去了
                self:_onExitLegionHandler()
                self:resetAttr()
            else
                self:_updateMemberInfo(data.id, nil)

                --军团成员数量减1
                local curNum = self._mineInfo["curNum"]
                local updateMap = {}
                table.insert(updateMap, {curNum = curNum - 1})
                self:_updateMineLegionInfo(updateMap)
            end
        elseif type == 2 then --转让团长
          --只有自己为团长时，才会有该操作
            local myInfo = self:getMemberInfo(ownPlayerId) -- 自己的
            local optInfo = self:getMemberInfo(data.id)    -- 对方的
            -- myInfo.job = LegionJobConfig.NORMAL_JOB

            myInfo.job = myInfo.job --对方职位给自己
            optInfo.job = LegionJobConfig.LEADER_JOB --对方变团长

            -- 更新自己的职位
            self._mineInfo.mineJob = myInfo.job
            self._mineInfo.leaderName = optInfo.name -- 更新盟主信息
            self:_updateMemberInfo(data.id, optInfo) --更新对方的数据
            self:_updateMemberInfo(ownPlayerId, myInfo,true) --更新自己的数据
            
        elseif type == 3 then --退出军团
            if data.id == ownPlayerId then  --自己退出军团了
                self:_onExitLegionHandler()
            else
                self:_updateMemberInfo(data.id, nil)
                --军团成员数量减1
                local curNum = self._mineInfo["curNum"]
                local updateMap = {}
                table.insert(updateMap, {curNum = curNum - 1})
                self:_updateMineLegionInfo(updateMap)
            end
            self:resetAttr()
        elseif type == 4 then --解散军团
            if data.id == ownPlayerId then
                self:resetAttr()
                local legionData = {}
                legionData.message = 2 --团长要飘的字
                self:_onExitLegionHandler(legionData)
            end
        end
    end
end

-- 升职or设置职位
function LegionProxy:onTriggerNet220221Resp(data)
    if data.rs == 0 then

        --升职成为盟主的时候，重新设置盟主的名字，推送更新要遍历
        if table.size(data.info) == 2 then
            for k , v in pairs(data.info) do
                if v.job == 7 then 
                    self._mineInfo.leaderName = v.name
                    break
                end
            end
        end

        local roleProxy = self:getProxy(GameProxys.Role)
        local mineID = roleProxy:getPlayerId()
        if data.id == mineID then

            -- 自己的职位有变化，要请求刷新军团的信息
            if self._mineInfo.mineJob ~= data.job then
                self:onTriggerNet220200Req()
            end

            -- 更新自己的职位
            self._mineInfo.mineJob = data.job

        end

        local infos = data.info
        for _,info in pairs(infos) do
            self:_updateMemberInfo(info.id, info, true) --只更新数据
        end
        
        local memberInfo = self:getMemberInfo(data.id)
        memberInfo.job = data.job
        self:_updateMemberInfo(data.id,memberInfo)
        
    end
end


--TODO 职位编辑的推送处理
function LegionProxy:onTriggerNet220220Resp(data)
    if data.rs == 0 then
        -- self._customJobMap = {}
        for _, jobInfo in pairs(data.infos) do
            self._customJobMap[jobInfo.index].index = jobInfo.index
            self._customJobMap[jobInfo.index].name = jobInfo.name
        end
    end

end

-- 军团建筑等级
function LegionProxy:onTriggerNet220000Resp(data)
    -- body
    if data.rs == 0 then
        for k,v in pairs(data.info) do
            self._legionBuildingInfo[v.id] = v.level
        end
        -- self._legionBuildingInfo = data.info
        self:_legionBuildingUpdate()
    end
end

--军团公告编辑成功
function LegionProxy:onTriggerNet220211Resp(data)
    if data.rs == 0 then
        self._mineInfo.affiche = self._lastAfficheReqStr
    end
end

-- 科技大厅建筑更新
function LegionProxy:onTriggerNet220010Resp(data)
    -- body
    if data.rs == 0 then
        self._sciData = data
        if data.techInfo.techLv ~= nil then
            self:_updateLegionBuildingInfo(1,data.techInfo.techLv)
        end

        self:sendNotification(AppEvent.PROXY_LEGION_SCITECH_UPDATE, data)
    end
end

-- 科技捐献返回
function LegionProxy:onTriggerNet220009Resp(data)
    -- body
    if data.rs == 0 then
        if data.techInfo ~= nil then
            self.myContribute = data.techInfo.myContribute
        end
        self:sendNotification(AppEvent.PROXY_LEGION_CONTRIBUTE_UPDATE, data)
    end
end

-- 军团大厅建筑
function LegionProxy:onTriggerNet220007Resp(data)
    -- body
    if data.rs == 0 then
        self._hallData = data

        if data.armyInfo.armyLv ~= nil then
            self:_updateLegionBuildingInfo(2,data.armyInfo.armyLv)
        end
    end
end


-- 福利院信息
function LegionProxy:onTriggerNet220012Resp(data)
    self._welfareInsfos = data
    self._canGetDailyReward = data.iscangetWelf -- 是否可领取每日福利
    self:sendNotification(AppEvent.PROXY_LEGION_UPDATE_WELFARE_TIP, {} ) -- 更新每日福利感叹号
end

-- 福利院建筑
function LegionProxy:onTriggerNet220013Resp(data)
    -- body
    if data.rs == 0 then
        if data.panelInfo.welfarelv ~= nil then
            self:_updateLegionBuildingInfo(3,data.panelInfo.welfarelv)
            -- 更新每日福利信息
            self._canGetDailyReward = data.iscangetWelf -- 每日福利领取状态
            self:sendNotification(AppEvent.PROXY_LEGION_UPDATE_WELFARE_TIP, {} ) -- 更新每日福利感叹号
        end
    end
end

-- 福利院信息
function LegionProxy:onTriggerNet220016Resp(data)
	print("返回 战事福利列表data.rs", data.rs, data.list)
	-- , #data.list)
	if data.rs == 0 then
		self._welfareLists = data.list
        self._memberInfoMap = self._memberInfoMap or {}
		for _, memberInfo in pairs(data.memberInfos) do
			self._memberInfoMap[memberInfo.id] = memberInfo
            --print("##########"..memberInfo.name.."#########"..memberInfo.welfareTimes)
            --self._updateMemberInfo(memberInfo.id,memberInfo)
		end
		self:sendNotification(AppEvent.PROXY_LEGION_ALLOT_UPDATE, { })
	end
end


--军团商店更新
function LegionProxy:onTriggerNet220002Resp(data)
    if data.rs==100 then
        self:showSysMessage(TextWords:getTextWord(3305))
    end

    -- logger:info("商店更新 220002Resp>> data.type=%d", data.type)

    self.legionLv = data.legionlv
    self.myContribute = data.myContribute
    self.mySalary = data.mySalary

    --[[
        --新版珍品面板信息里包含（物品面板和珍品面板信息）  都通过type == 0 下推
    ]]
    if data.type == 0 then --物品面板
        -- logger:info("更新物品 220002Resp>> data.type == 00000")

        self.shopList[1] = {}
        local info = ConfigDataManager:getConfigData(ConfigData.LegionFixShopConfig)
        -- local configInfo = ConfigDataManager:getInfosFilterByOneKey(ConfigData.LegionFixShopConfig,"consumeType",1)
        -- local info = {}
        -- for k,v in pairs(configInfo) do
        --     info[v.ID] = v
        -- end 

        for k,v in pairs(info) do
            info[k].isCanExchange = false
            info[k].todayNum = 0
        end
        for i=1,#data.canGet do
            info[data.canGet[i].canGetId].isCanExchange = true
            info[data.canGet[i].canGetId].todayNum = data.canGet[i].num
            -- local tmpList = {}
            -- tmpList = info[data.canGet[i].canGetId]
            -- info[data.canGet[i].canGetId]  = info[i]
            -- info[i] = tmpList
        end
        self.shopList[1] = info

    --[[
    --老版的珍品面板丢弃不用  此处屏蔽
    elseif data.type == 1 then --珍品面板
        -- logger:info("更新珍品 220002Resp>> data.type == 11111")

        self.shopList[2] = {}
        local oneTimeData = {}
        local info = ConfigDataManager:getConfigData(ConfigData.LegionRandShopConfig)
        -- local configInfo = ConfigDataManager:getInfosFilterByOneKey(ConfigData.LegionFixShopConfig,"consumeType",2)
        
        -- for k,v in pairs(configInfo) do
        --     info[v.ID] = v
        -- end

        if #data.canGet > 0 then
            for i=1,#data.canGet do
                info[data.canGet[i].canGetId].isCanExchange = true
                info[data.canGet[i].canGetId].todayNum = data.canGet[i].num
                table.insert(oneTimeData,info[data.canGet[i].canGetId])
            end
        end
        self.shopList[2] = oneTimeData
        -- self.shopList[2] = info
    --]]
    end

    local tmpData = {}
    self:sendNotification(AppEvent.PROXY_LEGION_SHOP_INFO_UPDATE, tmpData)
end


---军团情报站
function LegionProxy:onTriggerNet220300Resp(data)
    self.adviceInfo = {}
    self.peopleInfo = {}
    self.honourInfo = {}

    local tmp = data.stinfos
    if #tmp <= 0 then 
        return
    end
    table.sort(tmp,function(a,b) return a.time>b.time end) -- 时间排序
    local lastData1 = {}
    local lastData2 = {}
    local lastData3 = {}

    for i=1,#tmp do
        if tmp[i].bigtype == 1 then
            table.insert(lastData1,tmp[i])
        elseif tmp[i].bigtype == 2 then
            table.insert(lastData2,tmp[i])
        elseif tmp[i].bigtype == 3 then
            table.insert(lastData3,tmp[i])
        end
    end

    self.adviceInfo = lastData1
    self.peopleInfo = lastData2
    self.honourInfo = lastData3

    self:sendNotification(AppEvent.PROXY_LEGION_ADVICE_INFO_UPDATE, {})
end

-- 审批小红点
function LegionProxy:onTriggerNet220205Resp(data)
    if data.rs == 0 then
        self._approvePoint = data.num
        self:sendNotification(AppEvent.PROXY_LEGION_APPROVE_POINT_UPDATE, {})
    end
end

function LegionProxy:onTriggerNet220400Resp(data)
end

function LegionProxy:onTriggerNet210000Resp(data)
end

-- 军团公告请求推送
function LegionProxy:onTriggerNet220700Resp(data)
    logger:info("接收到军团公告推送返回")
end

-------------------------------------------------------------------------
-- 私有接口
-------------------------------------------------------------------------
-- 建筑id  （1=科技大厅，2=军团大厅，3=福利院）
function LegionProxy:_updateLegionBuildingInfo(id,level)
    -- body
    if self._legionBuildingInfo[id] ~= nil then
        self._legionBuildingInfo[id] = level
        self:_legionBuildingUpdate()
    end
end

-- 通知更新军团的建筑等级
function LegionProxy:_legionBuildingUpdate()
    -- body
    self:sendNotification(AppEvent.PROXY_LEGION_BUILDING_UPDATE, {})
end

--统一处理退出军团的操作
function LegionProxy:_onExitLegionHandler(data)
    --TODO 退出军团操作
    self:sendNotification(AppEvent.PROXY_LEGION_EXIT_INFO, {})

    local roleProxy = self:getProxy(GameProxys.Role)
    roleProxy:setLegionId(StringUtils:int32ToFixed64(0))
    roleProxy:setRoleAttrValue(PlayerPowerDefine.POWER_LegionId, 0)
    roleProxy:sendNotification(AppEvent.PROXY_LEGION_MAINSCENE_BUILDING_UPDATE, data) -- 
    roleProxy:sendNotification(AppEvent.PROXY_UPDATE_ROLE_INFO, {PlayerPowerDefine.POWER_LegionId})

    --退出军团，要把军团长的世界坐标设置成-1
    roleProxy:setLegionLeaderWorldTilePos(-1, -1)

    --退出军团清除同盟致富活动数据，刷新小红点
    local proxy  = self:getProxy(GameProxys.Activity)
    proxy:setLegionRichInfos({})

end

--统一更新军团信息 key->value
function LegionProxy:_updateMineLegionInfo(updateMap)
    for _, data in pairs(updateMap) do
        for key, var in pairs(data) do
            self._mineInfo[key] = var
        end
    end
    
    self:sendNotification(AppEvent.PROXY_LEGION_INFO_UPDATE, {})
end

--更新军团成员信息 增 删 改
function LegionProxy:_updateMemberInfo(memberId, memberInfo, isNotSendUpdate, is220203)
    self._memberInfoMap = self._memberInfoMap or {}
    self._memberInfoMap[memberId] = memberInfo

    if isNotSendUpdate ~= true then
        self:sendNotification(AppEvent.PROXY_LEGION_MEMBER_UPDATE, {})
        self:sendNotification(AppEvent.PROXY_LEGION_ALLOT_MEMBER_UPDATE, {})
    end
end


-------------------------------------------------------------------------
-- 公共接口
-------------------------------------------------------------------------
function LegionProxy:removeInitSciData()
    -- body
    self._sciData = nil
end

function LegionProxy:removeInitHallData()
    -- body
    self._hallData = nil
end

-------------------------------------------------------------------------
-- 实例变量
-------------------------------------------------------------------------
-- 军团建筑信息
function LegionProxy:getLegionBuildingInfo()
    -- body
    return self._legionBuildingInfo
end

-- 玩家自己的军团信息
function LegionProxy:getMineInfo()
    return self._mineInfo
end

-- 玩家自己的军团职位
function LegionProxy:getMineJob()
    if self._mineInfo == nil or self._mineInfo.mineJob == nil then
        return nil
    end
    return self._mineInfo.mineJob
end

-- 自定义职位信息
function LegionProxy:getCustomJobInfos()
    return self._customJobMap
end

-- 获取自己的军团个人贡献
function LegionProxy:getMineContribute()
    return self.myContribute
end

--获取职位名称 自定义1234 5普通 6 副团长 7团长
function LegionProxy:getJobName(job)
    local jobName = ""
    --print("LegionProxy:getJobName-->> job = "..job)
    if job == nil then
        jobName = TextWords:getTextWord(3130 + 5)
    elseif job == 0 then -- 如果是0就显示同盟名字,兼容
        local roleProxy = self:getProxy(GameProxys.Role)
        jobName = roleProxy:getLegionName()
    elseif job <= 4 then
        jobName = self._customJobMap[job].name
    else
        jobName = TextWords:getTextWord(3130 + job)
    end
    return jobName
end

-- 获取同盟聊天职位名称 自定义1234 5普通 6 副团长 7团长
function LegionProxy:getChatJobName(job)
    local jobName = ""
    if job == 0 then
        local roleProxy = self:getProxy(GameProxys.Role)
        jobName = roleProxy:getLegionName()
    elseif job <= 4 then
        jobName = self._customJobMap[job].name
    elseif job == 5 then
        jobName = TextWords:getTextWord(3037) -- 特殊处理“普通”职务的玩家显示职务时显示“成员”
    else
        jobName = TextWords:getTextWord(3130 + job)
    end
    return jobName
end

------
-- 职位权限
function LegionProxy:getShowStateByJob(positionType, keyName)
    local showState = 0 -- 不可见
    local legionPowerConfig = ConfigDataManager:getConfigData(ConfigData.LegionPowerConfig)
    for i, configInfo in pairs (legionPowerConfig) do
        if configInfo.positionType == positionType then
            showState = configInfo[keyName]
            break
        end
    end
    return showState == 1
end


-- （已排序+自己放首位）：军团成员列表、贡献排名列表
function LegionProxy:getSortedList(listData,type)
    if #listData <= 1 then
        return listData
    end
    if type == 1 then
        -- 成员排序
        table.sort(listData, function(a,b) return a.capityrank < b.capityrank end)
    elseif type == 2 then
        -- 贡献排序
        table.sort(listData, function(a,b) return a.devoterank < b.devoterank end)
    end

    -- local roleProxy = self:getProxy(GameProxys.Role)
    -- local mineID = roleProxy:getPlayerId()

    -- local tmpData = {}
    -- for k,v in pairs(listData) do
    --     if v.id == mineID then
    --         local selfData = v
    --         table.remove(listData, k)
    --         table.insert(listData, 1, selfData)
    --         return listData
    --     end
    -- end

    return listData
end

-- （未排序）军团成员列表
function LegionProxy:getMemberInfoList(isSelf)
    if isSelf == nil then
        return TableUtils:map2list(self._memberInfoMap or {})
        -- return self.allPerSonData
        -- return self._memberInfoMap
    else
        local data = {}
        local proxy = self:getProxy(GameProxys.Role)
        local selfName = proxy:getRoleName()
        -- 判空，self._menberInfoMap == nil 时直接返回,修复邮件添加联系人出错
        if self._memberInfoMap == nil then
            return data
        end
        for _,v in pairs(self._memberInfoMap) do
            if v.name ~= selfName then
                table.insert(data,v)
            end
        end
        return data
    end
end

-- 单个军团成员信息
function LegionProxy:getMemberInfo(memberId)
    if self._memberInfoMap then
        return self._memberInfoMap[memberId]
    end

    return nil
end

-- 单个军团成员信息
function LegionProxy:getMemberInfoSize()
    if self._memberInfoMap then
        return #self._memberInfoMap
    end
    return 0
end


-- 科技捐献大厅信息
function LegionProxy:getInitSciData()
    -- body
    return self._sciData
end

-- 军团捐献大厅信息
function LegionProxy:getInitHallData()
    -- body
    return self._hallData
end

-- 军团商店相关信息
function LegionProxy:getShopList(index)
    return self.shopList[index],self.myContribute,self.legionLv
end

--获取我的俸禄
function LegionProxy:getMysalary()
    return self.mySalary
end 

-- 军团情报军情信息
function LegionProxy:getAdviceInfo()
    return self.adviceInfo
end

-- 军团情报民情信息
function LegionProxy:getPeopleInfo()
    return self.peopleInfo
end

-- 军团情报荣耀信息
function LegionProxy:getHonourInfo()
    return self.honourInfo
end

function LegionProxy:getWelfareInfo()
    return self._welfareInsfos 
end

-- 同盟活跃的等级
function LegionProxy:getLegionActivityLevel()
    if self._welfareInsfos and self._welfareInsfos.panelInfo then
        return self._welfareInsfos.panelInfo.activityLv
    end
    return 0
end

-- 战事福利列表
function LegionProxy:getWelfareLists()
    return self._welfareLists
end

-- 审批小红点数量
function LegionProxy:getApprovePoint()
    return self._approvePoint
end


----------------------------------------------------------------------
----------------没加入军团时候的可见军团列表,数据池存储-----------------
function LegionProxy:setLegionApplyList(data) 

    self._applyList = data
end

function LegionProxy:getLegionApplyList()
    return self._applyList
end



function LegionProxy:setNewRecommendList(data) 
    self._newRecommendList = data
end

function LegionProxy:getNewRecommendList() 
    return self._newRecommendList
end

-- 请求推荐列表
function LegionProxy:onTriggerNet220105Req()
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220105, {})
end

------
-- 接收新推荐列表
function LegionProxy:onTriggerNet220105Resp(data)
    self:setNewRecommendList(data.recommendInfos) 
    -- 刷新推荐列表
    self:sendNotification(AppEvent.PROXY_LEGION_UPDATE_RECOMMEND, data)
end

-- 更新列表单个数据
function LegionProxy:onTriggerNet220206Resp(data)
    self:setUpdateApplyList(data)
end

-----------------------------
-- 审批列表
function LegionProxy:onTriggerNet220202Resp(data)
    self._applyInfos = {}
    local applyInfos = data.applyInfos
    self._applyInfos = applyInfos
    self:sendNotification(AppEvent.PROXY_LEGION_INIT_APPLY_INFO, {})
end


function LegionProxy:getApplyInfos()
    return self._applyInfos
end




------
-- 更新实时申请数据
function LegionProxy:setUpdateApplyList(data)
    -- 更新总表
    for k, v in pairs(self._applyList) do
        if v.id == data.id then
            self._applyList[k].applyState = data.type
        end
    end
    -- 更新推荐表
    if self._newRecommendList ~= nil then
        for k, v in pairs(self._newRecommendList) do
            if v.id == data.id then
                self._newRecommendList[k].applyState = data.type
            end
        end
    end
end

------
-- 资源已经领取
function LegionProxy:updateWelfareResourceData()
    self._welfareInsfos.panelInfo.cangettael = 0
    self._welfareInsfos.panelInfo.cangetiron = 0
    self._welfareInsfos.panelInfo.cangetstone= 0
    self._welfareInsfos.panelInfo.cangetwood = 0
    self._welfareInsfos.panelInfo.cangetfood = 0
    self:sendNotification(AppEvent.PROXY_LEGION_UPDATE_WELFARE_TIP, {} ) -- 更新每日福利感叹号
end

---------------------军团感叹号判断逻辑
------
-- 福利院每日福利是否可以领取
-- @param  args [obj] 参数
-- @return state
function LegionProxy:canGetDailyReward()
    local state = self._canGetDailyReward == 0 -- 为0表示可以领取
    return state
end


------
-- 获取福利领取状态参数
-- @param  args [obj] 参数
-- @return 
function LegionProxy:getDailyReward()
    return self._canGetDailyReward -- 为nil时表示未开放或没加入军团
end

------
-- 福利所有没有可领取资源
function LegionProxy:canGetResourceNum()
    self._welfareInsfos = self._welfareInsfos or {}
    local panelInfo = self._welfareInsfos.panelInfo
    if panelInfo == nil then
        return 0
    end
    local num1 = panelInfo.cangettael --银两
    local num2 = panelInfo.cangetiron --石油-铁锭
    local num3 = panelInfo.cangetstone--石头
    local num4 = panelInfo.cangetwood --木材
    local num5 = panelInfo.cangetfood --食物

    local temp = num1 + num2 + num3 +num4 +num5
    return temp
end

------
-- 是否有资源可以领取, true表示可领取
function LegionProxy:checkGetResourceState()
    local num = self:canGetResourceNum()
    local state = num ~= 0 
    return state
end


------
-- 军团感叹号红点状态
-- @param  args [obj] 参数
-- @return nil
function LegionProxy:checkLegionBuildTip()
    local state = false
    -- 是否开启
    local canGetDailyReward = self:getDailyReward()
    if canGetDailyReward == nil then
        return false
    end

    -- 是否加入了军团
    local name = self:getProxy(GameProxys.Role):getLegionName()
    if name == "" then
        return false
    end

    -- 检查每日福利
    local dailyState = self:canGetDailyReward()
    if dailyState then
        state = true
    end

    -- 检查活跃领取
    local resourceState  = self:checkGetResourceState()
    if resourceState then
        state = true
    end

    -- 检查领取箱子
    local boxState = self:getProxy(GameProxys.DungeonX):checkRewardBoxState()
    if boxState then
        state = true
    end

    -- 检查剩余攻打次数
--    local fightState = self:getProxy(GameProxys.DungeonX):checkFightCurState()
--    if fightState then
--        state = true
--    end

    return state
end

-- 关闭军团，刷新感叹号
function LegionProxy:closeLegionSoUpdateTip()
    self:sendNotification(AppEvent.PROXY_LEGION_CLOSE_UPDATE_MAINSCENE_TIP, {}) -- 刷新感叹号
end

function LegionProxy:getArmyInfo()
    return self._armyInfo
end

-- 计算可领取箱子总数量
function LegionProxy:canGetAllCurBoxCount()
    local allCurBoxCount = 0
    if self._dungeonInfos ~= nil then -- 有数据用原数据
        for key, value in pairs(self._dungeonInfos) do
            allCurBoxCount = value.curBoxCount + allCurBoxCount
        end
    end
    return allCurBoxCount
end

------
-- 贡献情况数据
-- @param  infoType [int] 类型，1元宝，2资源
-- @param  count [int] 数目参数
function LegionProxy:addContributeInfo(infoType, count)
    self._contributeInfo[infoType] = self._contributeInfo[infoType] + count 
end

-- 清空贡献表
function LegionProxy:clearContributeInfo()
    self._contributeInfo = {0, 0}
end

-- 获取贡献表
function LegionProxy:getContributeInfo()
    return self._contributeInfo
end

-- 获取贡献表
function LegionProxy:getContributeGold()
    return self._contributeInfo[1]
end

function LegionProxy:getContributeRes()
    return self._contributeInfo[2]
end

---[[
--同盟任务

--更新同盟任务信息
function LegionProxy:updateLegionTaskInfo(data)
    self.lastGetTaskInfoTime = os.time()
    if not self.taskInfo then 
        self.taskInfo = data
        self:sendNotification(AppEvent.PROXY_LEGION_TASKINFO_UPDATE)
        return 
    end 
    
    --这里的处理很奇葩  但是我也没办法   add by jy
    if data.taskList and #data.taskList > 0 then
        self.taskInfo = data
    else
        self.taskInfo.dayNum = data.dayNum
        self.taskInfo.weekNum = data.weekNum
        self.taskInfo.myNum = data.myNum
        self.taskInfo.rank = data.rank
        self.taskInfo.rankInfo = data.rankInfo
    end 
    self:sendNotification(AppEvent.PROXY_LEGION_TASKINFO_UPDATE)
end

function LegionProxy:getLastGetTaskInfoTime()
    return self.lastGetTaskInfoTime
end 

--获取同盟任务信息
function LegionProxy:getLegionTaskInfo()
    return self.taskInfo
end 

--完成任务时推送一次同盟任务信息
function LegionProxy:onTriggerNet590000Resp(data)
    if data.rs == 0 then 
        self:updateLegionTaskInfo(data.info)
    end 
end

--每5分钟请求一次最新数据
function LegionProxy:onTriggerNet590000Req()
    self:syncNetReq(AppEvent.NET_M59, AppEvent.NET_M59_C590000,{})
end

-- function LegionProxy:onTriggerNet590001Resp(data)
--     if data.rs == 0 then
--         self:updateLegionTaskInfo(data.info)
--     end 
-- end
--]]



--郡城信息推送
function LegionProxy:onTriggerNet220800Req()
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220800,{})
end

function LegionProxy:onTriggerNet220800Resp(data)
      self._legionTown = data.cityAllList
      logger:info("220800 返回了数据")
      self:sendNotification(AppEvent.PROXY_M220800_TOWN,data)
end


--都城信息推送
function LegionProxy:onTriggerNet220803Req()
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220803,{})
end

function LegionProxy:onTriggerNet220803Resp(data)
    self._legionCapital = data.cityAllList
    logger:info("220803 返回了数据")
    self:sendNotification(AppEvent.PROXY_M220803_CAPITAL,data)
    
end


--皇城城信息推送
function LegionProxy:onTriggerNet220804Req()
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220804,{})
end

function LegionProxy:onTriggerNet220804Resp(data)
    self._legionImperial=data.cityAllList
    logger:info("220804 返回了数据")
    self:sendNotification(AppEvent.PROXY_M220804_IMPERIAL,data)
end


--个人分红奖励推送
function LegionProxy:onTriggerNet220801Req(data)
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220801,data)
end

function LegionProxy:onTriggerNet220801Resp(data)
	if data.rs == 0 then
		if data.panel == 47 then
           self:onTriggerNet220800Req()
		elseif data.panel == 36 then
            self:onTriggerNet220803Req()
		elseif data.panel == 55 then
            self:onTriggerNet220804Req()
		end
	end

end

--城市小红点
function LegionProxy:onTriggerNet220810Req(data)
    self:syncNetReq(AppEvent.NET_M22,AppEvent.NET_M22_C220810,{})
    
end

--小红点返回数据
function LegionProxy:onTriggerNet220810Resp(data)
    if data.rs == 0 then
    self._rewardRedList = data.redPoint
    self:sendNotification(AppEvent.PROXY_M220810_REWARDREDPOINT,data)
    end
end


--单个城池状态刷新
function LegionProxy:onTriggerNet220802Resp(data)
    if data.rs ==0 then 
        self:updateList(data)
    end
end

function LegionProxy:onTriggerNet220802Req(data)
    self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220802,{})
end


function LegionProxy:updateList(data)
        if data.panel == 47 then
           if self._legionTown ~= nil then
                for k,v in pairs(self._legionTown) do
                    if data.cityInfo.cityId == v.cityId then
                        self._legionTown[k] = data.cityInfo
                       self:sendNotification(AppEvent.PROXY_M220802_CITYINFO,{self._legionTown,data.panel})
                       return 
                    end
                end
           end
		elseif data.panel == 36 then
             if self._legionCapital ~= nil then
                for k,v in pairs(self._legionCapital) do
                    if data.cityInfo.cityId == v.cityId then
                       self._legionCapital[k]=data.cityInfo
                       self:sendNotification(AppEvent.PROXY_M220802_CITYINFO,{self._legionCapital,data.panel})
                       return 
                    end
                end
           end
		elseif data.panel == 55 then
             if self._legionImperial ~= nil then
                for k,v in pairs(self._legionImperial) do
                    if data.cityInfo.cityId == v.cityId then
                       self._legionImperial[k] = data.cityInfo
                       self:sendNotification(AppEvent.PROXY_M220802_CITYINFO,{self._legionImperial,data.panel})
                       return
                    end
                end
           end
		end 
end
