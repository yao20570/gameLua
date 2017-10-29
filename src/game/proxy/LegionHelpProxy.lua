LegionHelpProxy = class("LegionHelpProxy", BasicProxy)

function LegionHelpProxy:ctor()
    LegionHelpProxy.super.ctor(self)
    self.proxyName = GameProxys.LegionHelp
    self.helpInfos = {}
    self.allhelpinfos = {}
    self._helpAllReq = false
end

function LegionHelpProxy:initSyncData(data)
	LegionHelpProxy.super.initSyncData(self, data)
	if data.helpInfos then
		self.helpInfos = data.helpInfos  
	end
	if data.allhelpinfos then
		self.allhelpinfos = data.allhelpinfos
		for k, v in pairs(self.allhelpinfos) do
			self.allhelpinfos[k].currentTime = os.time()	
		end
	end

end

function LegionHelpProxy:afterInitSyncData()
	local roleProxy = self:getProxy(GameProxys.Role)
	local name = roleProxy:getLegionName()
	if name == "" then
		return
	end
	--local legionProxy = self:getProxy(GameProxys.Legion)
	--legionProxy:onTriggerNet220000Req()
end

--退出军团清空数据
function LegionHelpProxy:deleteAllOtherHelpInfos()
	self.allhelpinfos = {}
end

-- 求助飘字
function LegionHelpProxy:showHelp()
	self:showSysMessage(TextWords:getTextWord(8406))
end

-- 帮助成功飘字
function LegionHelpProxy:onTriggerNet220501Resp(data)
	if data.rs == 0 then
		if self._helpAllReq == true then
			self._helpAllReq = false
			self:showSysMessage(TextWords:getTextWord(8407))
		else
			self:showSysMessage(TextWords:getTextWord(8408))
		end
	end
end


-- 更新帮助信息
function LegionHelpProxy:onTriggerNet220502Resp(data )
	if data.rs == 0 then
		self:updateAllHelpInfos(data.infos)
	end
end

function LegionHelpProxy:removinfo(id)
	for k,v in pairs(self.allhelpinfos) do
		if v.id == id  then
			table.remove(self.allhelpinfos, k)
		end
	end
end

function LegionHelpProxy:updateAllHelpInfos(infos)
	for _, info in pairs(infos) do
		info.currentTime = os.time()
		local mark = true
		for k, v in pairs(self.allhelpinfos) do
			if v.id == info.id then
				self.allhelpinfos[k] = info
				mark = false
			end
		end
		if mark then
			table.insert(self.allhelpinfos, info)
		end

		self:beHelpShowMsg(info)
	end
	self:sendNotification(AppEvent.PROXY_LEGION_HELP_POINT_UPDATE, infos)
end

function LegionHelpProxy:beHelpShowMsg(info)
	local roleProxy = self:getProxy(GameProxys.Role)
	local selfName = roleProxy:getRoleName()
	if info.name == selfName and info.helpnum > 0 then
		-- print("..............function LegionHelpProxy:beHelpShowMsg(info)...0",info.name,selfName)
		local helpname = rawget(info,"helpname")
		if helpname ~= nil and helpname ~= "" then
			-- print("..............function LegionHelpProxy:beHelpShowMsg(info)...1",helpname)
			local BuildingProxy = self:getProxy(GameProxys.Building)
			local buildingInfo = BuildingProxy:getBuildingConfigInfo(info.buildtype, 1)
			if buildingInfo and rawget(buildingInfo,"name") ~= nil then
				-- print("..............function LegionHelpProxy:beHelpShowMsg(info)...2",buildingInfo.name)
				local str = string.format(TextWords:getTextWord(8409),helpname,buildingInfo.name)
				self:showSysMessage(str)
			end
		end
	end

end

-- 军团帮助按钮小红点计数
function LegionHelpProxy:isCanHelp()
	local roleProxy = self:getProxy(GameProxys.Role)
	local name = roleProxy:getRoleName()
	local num = 0
	local now = os.time()
	for k, v in pairs(self.allhelpinfos) do
		if v.time + v.currentTime  - now > 0 then
			if name ~= v.name then
				if self:getMaxHelp() > v.helpnum then
					num = num + 1
				end
			end
		end
	end
	return num
end

function LegionHelpProxy:getMaxHelp()
	local roleProxy = self:getProxy(GameProxys.Role)
	local lv = roleProxy:getLegionLevel()
	
	local legionConfig = ConfigDataManager:getConfigData(ConfigData.LegionConfig)
	if legionConfig[lv] ~= nil then
		return legionConfig[lv].helpNum
	end
	return 0
end

-- 一键帮助全部成员
function LegionHelpProxy:helpOthersBuildings()
	local data = {}
	data.ids = {}
	local tmpdata = {}
	local roleProxy = self:getProxy(GameProxys.Role)
	local name = roleProxy:getRoleName()
	for k, v in pairs(self.allhelpinfos) do
		if v.time + v.currentTime  - os.time() > 0 then
			if name ~= v.name then
				if self:getMaxHelp() > v.helpnum then
					table.insert(data.ids,v.id)
				end
			else
				table.insert(tmpdata,v)
			end
		end
	end
	if #data.ids > 0 then
		self._helpAllReq = true
		self:onTriggerNet220501Req(data)
	else
		self._helpAllReq = false
	end
	self.allhelpinfos = tmpdata
end


-- 添加建筑升级的帮助信息
function LegionHelpProxy:addHelpInfos(index,buildingType)
	local helpInfo = {index = index,buildingType = buildingType}
	table.insert(self.helpInfos,helpInfo)
end

-- 删除建筑升级的帮助信息
function LegionHelpProxy:deleteHelpInfos(index,buildingType)
	for k,v in pairs(self.helpInfos) do
		if v.index == index and v.buildingType == buildingType then
			table.remove(self.helpInfos,k)
		end
	end
end

-- 是否属于建筑升级的帮助信息 ？？
function LegionHelpProxy:isBuildingHelped(index, buildingType)
	for k, v in pairs(self.helpInfos) do
		if v.index == index and v.buildingType == buildingType then
			return false
		end
	end
	return true
end

-- 初始化帮助信息
function LegionHelpProxy:onTriggerNet220500Req()
	local data = {}
	self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220500, data)
end

-- 帮助其他军团成员
function LegionHelpProxy:onTriggerNet220501Req(data)
	self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220501, data)
end

