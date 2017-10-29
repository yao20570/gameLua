EquipProxy = class("EquipProxy ", BasicProxy)

-----------------------------------------------------------------------
--zf,2015.12.2,装备的定义：穿在身上的武将，仓库中的武将，仓库中的装备卡
-----------------------------------------------------------------------

function EquipProxy:ctor()
    EquipProxy.super.ctor(self)
    self.proxyName = GameProxys.Equip
    self._allGoods = {}   		--所有的武将,包括穿在身上，仓库中的，装备卡
    self._goodsWarehouse = {}   --仓库中的武将，装备卡，升级需要用到，将军府用的到
    self._sixAttrOfOnePos = {}
    self.generalPlus = {}
end

function EquipProxy:resetAttr()
    self._allGoods = {}
    self._goodsWarehouse = {}
    self._sixAttrOfOnePos = {}
    self.generalPlus = {}
end

function EquipProxy:registerNetEvents()
--    self:registerNetEvent(AppEvent.NET_M13, AppEvent.NET_M13_C130000, self, self.onAllEquipsResp)
    self:registerNetEvent(AppEvent.NET_M13, AppEvent.NET_M13_C130006, self, self.onSoldierMofidyResp)
    self._indexMap = {}
    self._indexMap[12] = 6
    self._indexMap[4] = 5
    self._indexMap[6] = 4
    self._indexMap[11] = 3
    self._indexMap[5] = 2
    self._indexMap[7] = 1
end

function EquipProxy:unregisterNetEvents()
--    self:unregisterNetEvent(AppEvent.NET_M13, AppEvent.NET_M13_C130000, self, self.onAllEquipsResp)
    self:unregisterNetEvent(AppEvent.NET_M13, AppEvent.NET_M13_C130006, self, self.onSoldierMofidyResp)
end

function EquipProxy:initSyncData(data)
    EquipProxy.super.initSyncData(self, data)
    self.generalinfo = {}
    self.generallist = {}
    self.generalPlus = {}
    if data.rs == 0 then
        for _,v in pairs(data.equipinfos) do
            self._allGoods[v.id] = v
        end
        local baseConfig = ConfigDataManager:getConfigData(ConfigData.GeneralsConfig)
        local soulConfig = ConfigDataManager:getConfigData(ConfigData.GeneralsSoulConfig)
        self.generalinfo = data.generalinfo
        for k,v in pairs(self.generalinfo) do
        	local id = v.generalId
        	local potential = baseConfig[id].potential
        	for key,value in pairs(v.generalSoul) do
        		self:setPlusById(id, value.id, potential*value.generallevel/100)
        	end
        end
        -- self:setPlusById()
        -- if #self.generalinfo > 0 then
        -- 	table.sort(self.generalinfo, function(a, b)
        -- 		return a.generalId < b.generalId
        -- 	end)
        -- end
    end

    for index = 1, 6 do
        self:onSetSixAttrByPos(index)
    end

       
end

function EquipProxy:afterInitSyncData()
    self:onUpdateFightByEquip()
end

function EquipProxy:onAllEquipsResp(data)
--	if data.rs == 0 then
--		for _,v in pairs(data.equipinfos) do
--			self._allGoods[v.id] = v
--		end
--	end
--
--	for index = 1, 6 do
--	   self:onSetSixAttrByPos(index)
--    end
--    self:onUpdateFightByEquip()
end

function EquipProxy:updateAllEquips(equipList)
	for _,v in pairs(equipList) do
		if v.typeid == 0 then
			self._allGoods[v.id] = nil
		else
			self._allGoods[v.id] = v
		end
	end
	self:updateRedPoint()
	self:onUpdateFightByEquip()
	self:sendNotification(AppEvent.PROXY_UPDATE_All_EQUIPS, {})
end

function EquipProxy:updateImgView(data)

end

function EquipProxy:getAllEquip()      --所有的装备
	return self._allGoods
end

local function sortList(x,y)
	if x.type == y.type then
		if x.quality == y.quality then
			return x.level > y.level
		else
			return x.quality > y.quality
		end
	else
		return x.type < y.type
	end
end

function EquipProxy:getEquipAllHome()  --仓库中的武将，装备卡
	local data = {}
	for _,v in pairs(self._allGoods) do
		if v ~= nil then
			if v.position == 0 then
				table.insert(data,v)
			end
		end
	end

	--tudo  排序没有优化
	table.sort(data,sortList)--function ( x,y) return tonumber((4 - x.type)..x.quality..x.level) > tonumber((4 - y.type)..y.quality..y.level) end)
	return data
end

function EquipProxy:getWearEquips()
	local data = {}
	for _,v in pairs(self._allGoods) do
		if v ~= nil then
			if v.position ~= 0 then
				table.insert(data,v)
			end
		end
	end
	return data
end

function EquipProxy:getSoldierByAttr(attr,cuPos)  --某一属性的所有佣兵
	local data = {}
	if cuPos == nil then
		for _,v in pairs(self._allGoods) do
			if v ~= nil then
				if v.upproperty == attr then
					table.insert(data,v)
				end
			end
		end
	else
		for _,v in pairs(self._allGoods) do
			if v ~= nil then
				if v.upproperty == attr and v.position ~= cuPos then
					local cuPos 
					if v.position == 0 then
						cuPos = 1
					else
						cuPos = 8 - v.position
					end
					--print("position cuPos  quality  level  ",v.position,cuPos,v.quality,v.level)
					v["paixu"] = cuPos*100 + v.quality*10 + v.level
					table.insert(data,v) 
				end
			end
		end
	end
	table.sort(data,function(a,b) return a.paixu > b.paixu end )
	return data
end

function EquipProxy:getSoldiersByPos(pos) --根据槽位找到对应的武将列表
	local data = {}
	for _,v in pairs(self._allGoods) do
		if v ~= nil then
			if v.position == pos then
				table.insert(data,v)
			end
		end
	end
	return data
end

function EquipProxy:getSoldierById(Id)
	return self._allGoods[Id]
end

function EquipProxy:getPosUpproperty(pos) --找到槽位中的最大属性
	local soldierList = self:getSoldiersByPos(pos)
	local function onFindAttr(attr)
		for _,v in pairs(soldierList) do
			if v.upproperty == attr then
				return tonumber(v.quality..v.level..self._indexMap[attr])
			end
		end
		return 
	end
	local maxKey = 12
	local maxValue = 0
	local attrList = 0
	for key,v in pairs(self._sixAttrOfOnePos[pos]) do
		if v > maxValue then
			maxValue = v
			maxKey = key
			attrList = onFindAttr(key)
		elseif v == maxValue then
			if onFindAttr(key) ~= nil then 
				if onFindAttr(key) > attrList then
					maxValue = v
					maxKey = key
					attrList = onFindAttr(key)
				end
			end
		end
	end
	if maxValue == 0 then
		return nil
	else
		return maxKey
	end

	-- local soldierList = self:getSoldiersByPos(pos)
	-- if #soldierList == 0 then
	-- 	return nil
	-- end
	-- print("TTTTTTTTTTTTTT  %d",pos)
	-- local cuInfo = {level = 0,quality = 0,upproperty = 12}
	
	-- for _,v in pairs(soldierList) do
 --        print("quity:"..v.quality.."level:"..v.level.."upproperty:"..v.upproperty)
	-- 	if v.quality > cuInfo.quality then
 --            cuInfo = v
 --        elseif v.quality == cuInfo.quality then
 --            if v.level > cuInfo.level then
 --                cuInfo = v
 --            elseif v.level == cuInfo.level then
 --            	if self._indexMap[v.upproperty] > self._indexMap[cuInfo.upproperty] then
 --            		cuInfo = v
 --            	end
 --            end
 --        end
	-- end
	-- if cuInfo.level == 0 and cuInfo.quality == 0 then
	-- 	return nil
	-- else
	-- 	return cuInfo.upproperty
	-- end
end

function EquipProxy:onSoldierMofidyResp(data)
	-- if data.rs == 0 then
	-- 	for _,v in pairs(data.equipinfos) do
	-- 		if v.typeid == 0 then
	-- 			self._allGoods[v.id] = nil
	-- 		else
	-- 			self._allGoods[v.id] = v
	-- 		end
	-- 	end
	-- end
	-- self:onUpdateFightByEquip()
	-- self:updateRedPoint()
end

function EquipProxy:onSetSixAttrByPos(pos)
	self._sixAttrOfOnePos[pos] = {}
	local soldierList = self:getSoldiersByPos(pos)
    local number = {12,4,6,11,5,7}

    for _ ,v in pairs(soldierList) do
        for k,va in pairs(number) do
            if va == v.upproperty then
                number[k] = nil
                local info = ConfigDataManager:getInfoFindByTwoKey("WarriorProConfig","lv",v.level,"quality",v.quality)
    			local value = info[SoliderPowerDefine.equipAttribute[v.upproperty]] / 10000
    			self._sixAttrOfOnePos[pos][va] = value
                break
            end
        end
    end

    for _ ,v in pairs(number) do
        if v ~= nil then
        	self._sixAttrOfOnePos[pos][v] = 0
        end
    end

    if #soldierList == 6 then  --套装属性加成
    	local config = ConfigDataManager:getConfigData("SuitsConfig")
    	for _,v in pairs(config) do
    		local partneed = StringUtils:jsonDecode(v["partneed"])
    		if self:onCompare(soldierList,partneed) == true then
    			local countTb = StringUtils:jsonDecode(v["property"])
    			for _,v in pairs(countTb) do
    				--local str = StringUtils:splitString(v,",")
    				local key = v[1]
    				local value = v[2]
    				self._sixAttrOfOnePos[pos][key] = self._sixAttrOfOnePos[pos][key] + value / 10000
    			end
    			break
    		end
    	end
    end
    
    -- logger:info("YYYYYYYYYYYYYYYY   %d",pos)
    -- for k,v in pairs(self._sixAttrOfOnePos[pos]) do
    -- 	logger:info("^^^^^   %d    %d",k,v)
    -- end
    -- logger:info("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
end

function EquipProxy:onCompare(soldierList,partneed)
	--partneed = StringUtils:splitString(partneed[1],",")
	local data = {}
	for _,v in pairs(soldierList) do
		for k,va in pairs(partneed) do
			if v.typeid == tonumber(va) then
				data[va] = true
				break
			end
		end

	end
	if table.size(data) == 6 then
		return true
	end
	return false
end

function EquipProxy:onGetSixAttrByPos(pos)  --一个槽位上面的6个属性
	local onePosAttr = {}
	for k,v in pairs(self._sixAttrOfOnePos[pos]) do
		onePosAttr[k] = v
	end
	local info = self:getGeneralinfoByPos(pos)
	if info then
		local curId = info.generalId
		local otherInfo = self:getPlusById(curId)
		local generalId = info.generalId
		local GeneralsConfig = ConfigDataManager:getConfigData(ConfigData.GeneralsConfig)
		item = GeneralsConfig[generalId]
		local countTb = StringUtils:jsonDecode(item["property"])
		for _,v in pairs(countTb) do
			local key = v[1]
			local value = v[2]
			if  otherInfo ~= nil  and  otherInfo[k] ~= nil then
				onePosAttr[key] = onePosAttr[key] + value / 10000 + otherInfo[k]/100
			else
				onePosAttr[key] = onePosAttr[key] + value / 10000
			end
		end
	end
	return onePosAttr
end

function EquipProxy:onUpdateFightByEquip()  --最大战力
	for index = 1, 6 do
	   self:onSetSixAttrByPos(index)
    end
    local soldierProxy = self:getProxy(GameProxys.Soldier)
    soldierProxy:soldierMaxFightChange()
--    proxy:setMapFightAddEquip()
end

------小助手接口--武将队伍第一个是否有攻击武将
function EquipProxy:isFirstAttackEmpty()
	local natureList = self:onGetSixAttrByPos(2)
	if natureList[12] == 0 then
		return true
	else
		return false
	end
end

---获取套装表
function EquipProxy:getTaozhuang(pos)
	local taozhuang = {0, 0, 0, max = 0}
	local list = self:getSoldiersByPos(pos)
	local function setTaozhuangTb(i)
		taozhuang[i] = taozhuang[i] + 1
		if taozhuang[i] > taozhuang.max then
			taozhuang.max = taozhuang[i]
		end
	end
	for _, v in pairs(list) do
		if v.typeid > 40 and v.typeid < 50 then
			setTaozhuangTb(1)
		elseif v.typeid > 50 and v.typeid < 60 then
			setTaozhuangTb(2)
		elseif v.typeid > 60 and v.typeid < 70 then
			setTaozhuangTb(3)
		end
	end
	return taozhuang
end

--小红点更新
function EquipProxy:updateRedPoint()
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:checkEquiipRedPoint() 
	self:sendNotification(AppEvent.PROXY_UPDATE_TEAM_OTHER_INFO, {})
end

function EquipProxy:getGeneralinfo()
	return self.generalinfo
end


--20007更新武将信息
function EquipProxy:updateAllGenerals(data)

	for _, newValue in pairs(data) do
		for key, value in pairs(self.generalinfo) do
			if newValue.generalId == value.generalId then
				self.generalinfo[key] = newValue
			end
		end
	end
	self:sendNotification(AppEvent.PROXY_UPDATE_ALL_HERO, {})
end

--获取仓库数据
function EquipProxy:getGeneralInfoByStoreHouse()
 	local infos = {}
	for _, info in pairs(self:getGeneralinfo()) do
		if info.position == 0 then
			-- print(info.generalId)
			table.insert(infos,info)
		end
	end
	local Generals = require("excelConfig.GeneralsConfig")
		--A武将品质
		--B武将等级
		--C武将id倒序
	table.sort(infos,function (a, b)
		--if Generals[a.generalId].color == Generals[b.generalId].color then
			if a.generalLevel == b.generalLevel then
				return a.generalId > b.generalId
			else
				return a.generalLevel > b.generalLevel
			end
		--else
		--	return Generals[a.generalId].color > Generals[b.generalId].color
		--end
	end)
	local number, index = 1, 1
	local datas = {} 
	for _, v in pairs(infos) do
		if number == 1 then
			datas[math.ceil(index/3)] = {}
		end
		datas[math.ceil(index/3)][number] = v
		index = index + 1
		number = number + 1
		if number == 4 then
			number = 1
		end
	end
	return datas
end

--获取某个位置武将信息
function EquipProxy:getGeneralinfoByPos(pos)
	for _, info in pairs(self:getGeneralinfo()) do
		if info.position == pos then
			return info
		end
	end
	return false
end


--获取5种经验丹的数量
function EquipProxy:getExpDan()
	local danNums = {}
	local itemProxy = self:getProxy(GameProxys.Item)
	for i = 1, 5 do
		danNums[i] = itemProxy:getItemNumByType(3400 + i)
	end
	return danNums
end


--新增接口获取当前选择武将ID
function EquipProxy:getCurrentPos()
	local info =  self:getGeneralinfoByPos(self.currentPos)
	return info.generalId
end

function EquipProxy:setCurrentPos(pos)
	self.currentPos = pos
end

function EquipProxy:getInfoById(id)
	local result = nil
	local data = self:getGeneralinfo()
	for k,v in pairs(data) do
		if v.generalId == id then
			return data[k]
		end
	end
end

function EquipProxy:onTriggerNet290005Req(data)
	-- self.curId = data.id
    self:syncNetReq(AppEvent.NET_M29, AppEvent.NET_M29_C290005, data)
end

function EquipProxy:onTriggerNet290004Req(data)
    self:syncNetReq(AppEvent.NET_M29, AppEvent.NET_M29_C290004, data)
end

function EquipProxy:onTriggerNet290004Resp(data)
	if data.rs == 0 then
		self:sendNotification(AppEvent.PROXY_UPDATE_IMG_VIEW, data.num)
	end
end

function EquipProxy:onTriggerNet290005Resp(data)
	if data.rs == 0 then
		self:showSysMessage("重置成功")
		local pos = self:getCurrentPos()
		local generalInfo = self:getInfoById(pos)
		local config = ConfigDataManager:getConfigById(ConfigData.GeneralsConfig, pos)
		generalInfo.potential = config.potential
		for k,v in pairs(generalInfo.generalSoul) do
			generalInfo.generalSoul[k].generallevel = 0
			generalInfo.generalSoul[k].num = 0
		end
		self:sendNotification(AppEvent.PROXY_UPDATE_EQUIP_VIEW)
	end
end

function EquipProxy:updateData(soulID, generalId, num, need)
	local result = nil
	local data = self:getGeneralinfo()
	for k,v in pairs(data) do
		if v.generalId == generalId then
			result = data[k]
		end
	end
	for k,v in pairs(result.generalSoul) do
		if v.id == soulID then
			local info = result.generalSoul[k]
			info.generallevel = info.generallevel + 1
			info.num = info.num + need
			break
		end
	end
	result.potential = num
end

function EquipProxy:setPlusById(generalId, configId, plus)
	if self.generalPlus[generalId] == nil then
		self.generalPlus[generalId] = {}
	end
	local soulInfo = ConfigDataManager:getConfigData(ConfigData.GeneralsSoulConfig)
	local soulID = soulInfo[configId].propertype
	self.generalPlus[generalId][soulID] = plus
end

function EquipProxy:getPlusById(generalId)
	return self.generalPlus[generalId]
end

function EquipProxy:getNameAndLvByPos(pos)
	local info = self:getGeneralinfoByPos(pos)
	if not info then
		return "无武将",0
	end
	local lv = info.generalLevel
	local generalId = info.generalId
	local GeneralsConfig = ConfigDataManager:getConfigData(ConfigData.GeneralsConfig)
	local name = GeneralsConfig[generalId].name
	return name,lv
end