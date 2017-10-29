------------
----增益Buff Proxy
-- TODO 用type+powerId做定时器的key，然后有个待优化的问题是，例如全面开采道具，就会创建5个定时器，结束时连续请求5次

ItemBuffProxy = class("ItemBuffProxy ", BasicProxy)


function ItemBuffProxy:ctor()
    ItemBuffProxy.super.ctor(self)
    self.proxyName = GameProxys.ItemBuff

    self._itemBuffMap = {}
end

function ItemBuffProxy:resetAttr()
end

------------------------------------------------------------------------------
-- 初始化
------------------------------------------------------------------------------
function ItemBuffProxy:initSyncData(data)
    ItemBuffProxy.super.initSyncData(self, data)

	self._bufferShowIds = data.bufferShowIds

    local key = nil
    for k,v in pairs(data.itemBuffInfo) do
    	key,key2 = self:getKey(v.itemId, v.type, v.powerId)
    	if v.remainTime == 0 then
    		-- 删除
    		self._itemBuffMap[key] = nil				
    	else
    		-- 更新、新增

    		-- v.remainTime = 40 --TODO 测试代码

    		self._itemBuffMap[key] = v
    		self:updateItemBuffTime(v.type, v.powerId, key2, v.remainTime,v.buffType)
    	end
    end
    logger:info("")
end

-------------------------------------------------------------------------------
-- -- 主要检查某些buff道具会对多个属性生效，改为为1个key1个定时器。
-- function ItemBuffProxy:checkKey(itemId, key)
-- 	-- body
-- 	logger:info("checkKey(itemId, key).../// itemId =%d, key =%s", itemId, key)

-- 	local key2 = key

-- 	local itemBuffInfos = clone(self._itemBuffMap)
-- 	if table.size(itemBuffInfos) > 0 then
-- 		local tmpTab = {}
-- 		for k,v in pairs(itemBuffInfos) do
-- 			if v.itemId == itemId then
-- 				v.key = k
-- 				table.insert(tmpTab, v)
-- 				-- logger:info("checkkey...k, v.powerId", k, v.powerId)
-- 			end
-- 		end

-- 		if #tmpTab > 0 then
--     		table.sort(tmpTab, function(a,b) return a.powerId<b.powerId end)

-- 			key2 = tmpTab[1].key
-- 			logger:info("···#tmpTab =%d, key2 =%d",#tmpTab, key2)
-- 		end
-- 	end

-- 	return key,key2
-- end


function ItemBuffProxy:getBufferShowIds()
	return self._bufferShowIds
end

function ItemBuffProxy:getKey(itemId, type, powerId)
	-- body
	local key = nil
	if type ~= nil and powerId ~= nil then
		key = "key_buff_"..itemId.."_"..type.."_"..powerId
	end

	-- key,key2 = self:checkKey(itemId, key) --似乎多余了 o(╯□╰)o
	return key,key
end

function ItemBuffProxy:getBuffsByItem(itemInfo)
	-- body
	local buffTab = {}
	for k,v in pairs(self._itemBuffMap) do
		if v.type == itemInfo.type and v.powerId == itemInfo.powerId then
			table.insert(buffTab, v)
		end
	end

	return buffTab
end

-- 获取相同道具类型的所有道具Buff
function ItemBuffProxy:getBuffsByType(itemType)
	local buffTab = {}
	for k,v in pairs(self._itemBuffMap) do
		if v.type == itemType then
			table.insert(buffTab, v)
		end
	end

	return buffTab
end

function ItemBuffProxy:updateItemBuffInfo(call, itemInfo, info)
	-- body
	local tmpTab = self:getBuffsByItem(itemInfo)

	-- 新增buff
	if table.size(tmpTab) == 0 and info ~= nil then
		local key,key2 = self:getKey(info.itemId, info.type, info.powerId)
		tmpTab[key] = info
		self._itemBuffMap[key] = info
		logger:error("···新增buff itemId =%d, key =%s, remainTime =%d", info.itemId, key, info.remainTime)
	end
	

	local key,key2,remainTime = nil,nil,nil
	for _,v in pairs(tmpTab) do
		key,key2 = self:getKey(v.itemId, v.type, v.powerId)
		
		if call == 1 then --更新buff信息
			if info ~= nil then
				key,key2 = self:getKey(info.itemId, info.type, info.powerId)
			end
			self._itemBuffMap[key] = info

		elseif call == 2 then  --只更新buff的倒计时
			self._itemBuffMap[key].remainTime = info
		end
		

		if info == nil then
			remainTime = 0
			if v.buffType == 1 then 
				table.removeValue(self._itemBuffMap,v)
			end
		elseif type(info) == "table" then
			remainTime = info.remainTime
		else
			remainTime = info
		end		
		logger:error("···更新buff  itemId =%d, key =%s, type =%d, powerId =%d, remainTime =%d", v.itemId, key, v.type, v.powerId, remainTime)
		self:updateItemBuffTime(v.type, v.powerId, key2, remainTime,v.buffType)
		

	end

end

------------------------------------------------------------------------------
-- 请求协议
------------------------------------------------------------------------------
--buff倒计时完的请求
function ItemBuffProxy:onTriggerNet90002Req(sendData)
	-- logger:info("buff结束发请求···onTriggerNet90002Req : type =%d, powerId =%d",sendData.type, sendData.powerId)
	self:syncNetReq(AppEvent.NET_M9, AppEvent.NET_M9_C90002, sendData)
end

------------------------------------------------------------------------------
-- 接收协议
------------------------------------------------------------------------------

--buff倒计时完的返回
function ItemBuffProxy:onTriggerNet90002Resp(data)
	if data.rs == 0 then
		local remainTime = data.remainTime
		-- logger:info("buff倒计时完的返回 ...onTriggerNet90002Resp remainTime =%d", remainTime)

		if remainTime == nil or remainTime <= 0 then --TODO 服务器会发负数的过来
			-- 删除定时器
			self:updateItemBuffInfo(1, data, nil)

		else
			-- 时间不同步，更新为服务端的时间
			self:updateItemBuffInfo(2, data, remainTime)
		end
		self:sendNotification(AppEvent.ITEM_BUFF_UPDATE, {}) --TODO 需要优化


	elseif data.rs == -2 then  --TODO 暂时处理rs=-2问题
		local remainTime = data.remainTime
		-- logger:info("buff倒计时完的返回 ...onTriggerNet90002Resp data.rs == -2")

		if remainTime == nil or remainTime == 0 then
			-- 删除定时器
			self:updateItemBuffInfo(1, data, nil)
		end
		self:sendNotification(AppEvent.ITEM_BUFF_UPDATE, {}) --TODO 需要优化
	end
end

function ItemBuffProxy:onTriggerNet20801Resp(data)
	self:sendNotification(AppEvent.BUFF_SHOW_UPDATE, data)
end


function ItemBuffProxy:onTriggerNet90003Req(data)
	--self:onTriggerNet90003Resp(data)
end

-- message ItemBuffInfo{//道具buff信息
-- 	required int32 itemId =1;   //道具Id（普通道具buff读item表，全服性buff读buffShow）
-- 	required int32 type =2;    	//道具类型
-- 	required int32 powerId =3;  //要加成效果的powerId
-- 	required int32 value =4;    //加成效果（百分比）
-- 	required int32 time =5;	    //buff有效时间
-- 	required int32 remainTime = 6; //剩余时间
-- 	required int32 buffType = 7; //0 普通道具buff  1 全服性buff
-- }


--更新推送道具buff加成效果 只推送新增、更新的self._itemBuffMap
function ItemBuffProxy:onTriggerNet90003Resp(data)
	if data.rs == 0 then

		-- 全部Buff刷新
		if data.allRefresh == 1 then
			-- logger:info("-- 全部Buff刷新 ")
			for k,v in pairs(self._itemBuffMap) do
				-- logger:info("-- 移除Buff ")
                self:updateItemBuffInfo(1, v, nil)
			end

			for k,v in pairs(data.itemBuffInfo) do
				-- logger:info("-- 新增Buff ")
				self:updateItemBuffInfo(1, v, v)
			end

			self:sendNotification(AppEvent.ITEM_BUFF_UPDATE, {})
			return
		end

		-- if table.size(data.itemBuffInfo) == 0 then
		-- 	self:removeAllHonourBuff()
		-- 	self:sendNotification(AppEvent.ITEM_BUFF_UPDATE, {})
		-- 	return
		-- end

		--没有同盟，有buff数据，要校验删除城主战buff，但是不删除乱军奖励的
		local roleProxy = self:getProxy(GameProxys.Role)
		local legionName = roleProxy:getLegionName()
		if legionName == "" and table.size(data.itemBuffInfo) > 0 then
			self:removeAllCityBuff()
			-- self:sendNotification(AppEvent.ITEM_BUFF_UPDATE, {})
			-- return
		end


		-- -- 测试代码 start-------------------------------------------------
		-- for _,v in pairs(data.itemBuffInfo) do
		-- 	print("onTriggerNet90003Resp-->itemId, type, powerId, time, remainTime",v.itemId,v.type,v.powerId,v.time,v.remainTime)
		-- end
		-- -- 测试代码 end-------------------------------------------------

		for k,v in pairs(data.itemBuffInfo) do
			if v.remainTime == nil or v.remainTime == 0 then
				-- 删除
				self:updateItemBuffInfo(1, v, nil)

			else
				-- 任何时候只有一个外观道具Buff生效,已有的外观Buff要移除
				if v.type == 18 then
					local tmpTab = self:getBuffsByType(v.type)
					if table.size(tmpTab) ~= 0 then
						for _,itemBuff in pairs(tmpTab) do
							logger:info("已有的外观Buff要移除:itemId %d, type %d, powerId %d, buffType %d, time %d, remainTime %d",
								itemBuff.itemId,itemBuff.type,itemBuff.powerId,itemBuff.buffType,itemBuff.time,itemBuff.remainTime)
							self:updateItemBuffInfo(1, itemBuff, nil)
						end
					end
				end

				-- 更新、新增
				self:updateItemBuffInfo(1, v, v)
			end
		end

		self:sendNotification(AppEvent.ITEM_BUFF_UPDATE, {})

	end
end

--移除全部荣誉Buff
function ItemBuffProxy:removeAllHonourBuff()
    local buffShowConfig = ConfigDataManager:getConfigData(ConfigData.BuffShowConfig)
    for k,v in pairs(self._itemBuffMap) do
        if v.buffType == 1 then 
            for j, i in pairs(buffShowConfig) do
                if v.itemId == i.ID then
                    -- print("移除荣誉Buff ",v.powerId,v.type,v.time, v.remainTime)
                    self:updateItemBuffInfo(1, v, nil)
                end
            end
        end
    end
end

-- 逻辑太奇怪了，要修改 todo
--移除全部城主战Buff（除了技能buff保留）-- （普通道具buff读item表，全服性buff读buffShow）
function ItemBuffProxy:removeAllCityBuff()
    local config = ConfigDataManager:getConfigData(ConfigData.CityBattleSkillConfig)

    for _,v in pairs(self._itemBuffMap) do
        if v.buffType == 1 then --技能是全服Buff
            for _, i in pairs(config) do
                local buff = StringUtils:jsonDecode(i.buff)
                for _, id in pairs(buff) do
                    if v.itemId ~= id then -- 这边的id表示的是buff里面的【141，142】
                        if self:isCityBuff(v) then
	                        self:updateItemBuffInfo(1, v, nil)
                            logger:info("成功清除"..v.powerId)
                        end
                    end
                end
            end
        end
    end

    logger:info("成功清除城主战的buff")
end

------
-- 判断增益是否为城主战的buff
function ItemBuffProxy:isCityBuff(info)
    local state = true
    local configData = ConfigDataManager:getConfigData(ConfigData.BuffShowConfig)
    local configInfo = configData[info.itemId]
    if configInfo then
        if configInfo.title == TextWords:getTextWord(401302) then -- "乱军奖励"
            state = false
        end
        if configInfo.title == TextWords:getTextWord(401303) then -- "郡城增益"
            state = false
        end

        -- 技能暂时写死，技能id，30017 ~ 30020
        if info.powerId >= 30017 and info.powerId <=30020 then
            state = false
        end
    end
    return state
end



function ItemBuffProxy:isNeedUpdateProtect()
	-- 有保护罩并且打开世界地图，则通知世界地图更新保护罩显示
	local isShow = self:isModuleShow(ModuleName.MapModule)
	if isShow == true then
		-- 道具保护罩
	    local itemId = self:getBuffItemId(4, 91)
	    local remainTime = self:getBuffRemainTimeByMore(itemId, 4, 91)
		if remainTime > 0 then
			-- logger:info("-- 有保护罩并且打开世界地图，则通知世界地图更新保护罩显示")  
			return true
		end
		
		-- 新手保护罩
		local isHave = self:isHaveNewRoleBuff()
		return  isHave
	end

	return false
end

-- 是否有道具保护罩在生效
function ItemBuffProxy:isHaveProtectBuff()
    local itemId = self:getBuffItemId(4, 91)
	local remainTime = self:getBuffRemainTimeByMore(itemId, 4, 91)
	if remainTime > 0 then
		return true
	end
	return false
end

-- 获取itemId,注：服务端下发的itemId做过处理，两个时间不一样效果相同的道具，以第一个使用的itemId为准
function ItemBuffProxy:getBuffItemId(type, powerId)
    local itemId = 0
    for i, info in pairs(self:getItemBuffInfos()) do
        if info.type == type and info.powerId == powerId then
            itemId = info.itemId
            break
        end
    end
    return itemId
end



------------------------------------------------------------------------------
-- 实例变量
------------------------------------------------------------------------------
function ItemBuffProxy:getItemBuffInfos()
	-- -- 测试代码 start-------------------------------------------------
	-- print_r(self._itemBuffMap)
	return self._itemBuffMap  
end

------------------------------------------------------------------------------
-- 定时器
------------------------------------------------------------------------------
-- 更新某个道具的倒计时
function ItemBuffProxy:updateItemBuffTime(type, powerId, key, remainTime,buffType)
	-- body
	local sendData = {}
	sendData.type = type
	sendData.powerId = powerId
	sendData.buffType =buffType

	if key ~= nil then
		logger:error("... 增益Buff pushRemainTime: type =%d, powerId =%d, key =%s, remainTime =%d", type, powerId, key, remainTime)
		self:pushRemainTime(key, remainTime, AppEvent.NET_M9_C90002, sendData, self.remainTimeCompleteCall)
	end
end

-- 倒计时结束回调
function ItemBuffProxy:remainTimeCompleteCall(sendDataList)
	-- body

	for _,sendData in pairs(sendDataList) do
		self:onTriggerNet90002Req(sendData)
	end
end

-------------------------------------------------------------------------------
function ItemBuffProxy:getTimeKeyByMore(itemId, type, powerId)
	-- body
	local key,key2 = self:getKey(itemId, type, powerId)
	local info = self._itemBuffMap[key]

	if info ~= nil then
		return key2
	else
		return nil
	end
end

-- 获取1个道具的倒计时(公共接口)
function ItemBuffProxy:getBuffRemainTimeByMore(itemId, type, powerId)
	-- body
	local key = self:getTimeKeyByMore(itemId, type, powerId)
	local remainTime = self:getRemainTime(key)
	return remainTime
end


-------------------------------------------------------------------------------
-- 新手保护罩 特殊buff 客户端手动添加
-------------------------------------------------------------------------------
function ItemBuffProxy:addNewRoleBuff()
	return {ID = 10, icon = 10603, info = '新手保护期不会被攻击和侦查', value = '[0]', type = 20, sort = 10, power = '[91]', change = 10000, showtype = 1}
end

function ItemBuffProxy:isHaveNewRoleBuff()
	local isHave = true
	local roleProxy = self:getProxy(GameProxys.Role)
	local commandLv = roleProxy:getRolePowerValue(GamePowerConfig.Command, 1)  --官邸等级
	local attackPlayerTimes = self:getProxy(GameProxys.Soldier):getAttackPlayerTimes()
	local config = self:getNewRoleConfig()

    local protectTimeValue =ConfigDataManager:getInfoFindByOneKey(ConfigData.MiscellanyConfig,"describe","protectTime")
    local protectLevelValue =ConfigDataManager:getInfoFindByOneKey(ConfigData.MiscellanyConfig,"describe","protectLevel")

	local curTime = os.time()
	local lessTime = curTime - GameConfig.roleCreateTime
	-- logger:info("-- 新手时间  %d %d %d",lessTime,curTime,GameConfig.roleCreateTime)
	if lessTime <= protectTimeValue.number and commandLv < protectLevelValue.number and attackPlayerTimes == 0 then
		-- 等级未超过，时间未结束
		-- logger:info("-- 等级未超过，时间未结束  %d %d %d",lessTime,curTime,GameConfig.roleCreateTime)
		lessTime = protectTimeValue.number - lessTime
		self:pushRemainTime("new_role_buff", lessTime)
	else
		-- 时间已结束
		-- logger:info("-- 时间已结束")
		self:pushRemainTime("new_role_buff", 0)
		isHave = false
	end
	return isHave
end

-- 获取新手保护罩倒计时
function ItemBuffProxy:getNewRoleRemainTime()
	local remainTime = self:getRemainTime("new_role_buff")
	-- logger:info("-- 获取新手保护罩倒计时 %d", remainTime)
	return remainTime
end

function ItemBuffProxy:getNewRoleConfig()
	-- local config = ConfigDataManager:getConfigById(ConfigData.MiscellanyConfig,1)

	local config = ConfigDataManager:getConfigDataBySortKey(ConfigData.MiscellanyConfig)

	return config
end

function ItemBuffProxy:getValueFromConfigByDescribe(key)
    local value  = ConfigDataManager:getInfoFindByOneKey(ConfigData.MiscellanyConfig,"describe",key)
    return value
end

-------------------------------------------------------------------------------
function ItemBuffProxy:registerNetEvents()
    self:addEventListener(AppEvent.ATTACK_TIMES_UPDATE, self, self.clearNewRoleBuff)
    self:addEventListener(AppEvent.PROXY_BUILDING_UPDATE, self, self.updateBuildingInfo)
end
function ItemBuffProxy:unregisterNetEvents()
    self:removeEventListener(AppEvent.ATTACK_TIMES_UPDATE, self, self.clearNewRoleBuff)
    self:removeEventListener(AppEvent.PROXY_BUILDING_UPDATE, self, self.updateBuildingInfo)
end

-- 首次攻打世界玩家成功推送,清除新手保护罩Buff显示
function ItemBuffProxy:clearNewRoleBuff()
	local attackPlayerTimes = self:getProxy(GameProxys.Soldier):getAttackPlayerTimes()
	if attackPlayerTimes ~= 0 then
		self:pushRemainTime("new_role_buff", 0)
	end
end

-- 官邸达到指定等级，清除保护罩
function ItemBuffProxy:updateBuildingInfo(buildingInfo)
	local config = self:getNewRoleConfig()
    local protectLevel =ConfigDataManager:getInfoFindByOneKey(ConfigData.MiscellanyConfig,"describe","protectLevel")

    local buildingType = buildingInfo.buildingType
    local index = buildingInfo.index
    local level = buildingInfo.level
    if buildingType == 1 and index == 1 and level == protectLevel.number then
		self:pushRemainTime("new_role_buff", 0)
    end
end
-------------------------------------------------------------------------------
