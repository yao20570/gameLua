-- /**
--  * @Author:	  fzw
--  * @DateTime:	2015-12-26 17:11:16
--  * @Description: 游戏设置
--  */

SettingProxy = class("SettingProxy", BasicProxy)

function SettingProxy:ctor()
    SettingProxy.super.ctor(self)
    self.proxyName = GameProxys.Setting

	self._initSettingConf = self:initSettingConf()
	
	self._keySettingConf = {}
    for _, v in pairs(self._initSettingConf) do
		self._keySettingConf[v.key] = v
	end
	
	self:initGameSetting()
end

function SettingProxy:initSyncData( data )
	if data.headHas then
		self._headHas = data.headHas
	end
	if data.pendantHas then
		self._pendantHas = data.pendantHas
	end
end

function SettingProxy:resetAttr()
    -- self._keySettingConf = {}
end

--------------------------------------------------------------------------------------------------
-- 初始化
--------------------------------------------------------------------------------------------------
function SettingProxy:initSettingConf()
	-- body
	-- 初始化设置表
	
	-- type=1 游戏性设置，type=2 通知设置
	-- status=0 已关闭，status=1 已开启
	-- name：对应文字表TextWordsConfig
	-- isGloble=true 全局，isGloble=false 局部
	-- func:对应设置的函数接口
	-- key：缓存本地数据的key

	local initSettingConf = {
		{id = 1, name = 1412, type = 1, status = 1, isGloble = true, func = self.setBackGroundMusic, key = "BackGroundMusic"}, 			--背景音乐
		{id = 2, name = 1413, type = 1, status = 1, isGloble = true, func = self.setkeySoundEffect, key = "keySoundEffect"},  			--音效
		{id = 3, name = 1415, type = 1, status = 1, isGloble = true, func = self.setPayTwoConfirm, key = "PayTwoConfirm"},  			--消费二次确认
		{id = 4, name = 1437, type = 1, status = 1, isGloble = true, func = self.setResourceLostConfirm, key = "ResourceLostConfirm"}, 	--矿点战损确认
		{id = 5, name = 1438, type = 1, status = 1, isGloble = true, func = self.setLordCitySpend, key = "LordCitySpend"}, 	    		--城主战消耗元宝取消休整确认
		{id = 6, name = 1442, type = 1, status = 1, isGloble = true, func = self.setFightResTile, key = "FightResTile"}, 	    		--进攻玩家矿点失去保护状态提示确认

		--TODO 版本要求：暂时屏蔽以下部分按钮数据
		-- {id = 3, name = 1414, type = 1, status = 1, isGloble = true, func = self.setAutoAddDefence, key = "AutoAddDefence"},
		-- {id = 4, name = 1415, type = 1, status = 1, isGloble = true, func = self.setPayTwoConfirm, key = "PayTwoConfirm"},
		-- {id = 5, name = 1416, type = 1, status = 1, isGloble = true, func = self.setDisplayBuildingName, key = "DisplayBuildingName"},
		-- {id = 6, name = 1417, type = 2, status = 1, isGloble = true, func = self.setActivityOpen, key = "ActivityOpen"},
		-- {id = 7, name = 1418, type = 2, status = 1, isGloble = true, func = self.setBuildingUpgrateDone, key = "BuildingUpgrateDone"},
		-- {id = 8, name = 1419, type = 2, status = 1, isGloble = true, func = self.setProductDone, key = "ProductDone"},
		-- {id = 9, name = 1420, type = 2, status = 1, isGloble = true, func = self.setEnergyFull, key = "EnergyFull"},		
	}

	return initSettingConf		
end

--初始化游戏设置
function SettingProxy:initGameSetting()
    local conf = self._initSettingConf
    for _, v in pairs(conf) do
        v.func(self, v.key)
    end
end

--获取Key值的缓存 true false
function SettingProxy:getLocalStatusByKey(key)
    local v = self._keySettingConf[key]
    local status = self:getLocalData(v.key, v.isGloble) --读取本地数据
    return tonumber(status) == 1 or status == nil
end

-- 获取设置数据列表
-- type 设置的类型
function SettingProxy:getSettingDataByType(type)
	-- body
	local conf = self._initSettingConf

	local tabData = {}
	for k,v in pairs(conf) do
		if v.type == type then
			local status = self:getLocalData(v.key, v.isGloble) or 1	--读取本地数据
			v.status = tonumber(status)
			table.insert(tabData, v)
		end
	end

	return tabData
end

function SettingProxy:onSwitchSettingByKey(key)
	-- body
	local conf = self._initSettingConf

	for k,v in pairs(conf) do
		if v.key == key then
            v.func(self, key)
		end
	end

end

--------------------------------------------------------------------------------------------------
-- 实例变量
--------------------------------------------------------------------------------------------------
function SettingProxy:setBackGroundMusic(key)
	-- body
	local status = self:getLocalStatusByKey(key)
    AudioManager:musicEnable(status)
end
function SettingProxy:setkeySoundEffect(key)
	-- body
	logger:info("setkeySoundEffect")
    local status = self:getLocalStatusByKey(key)
    AudioManager:effectEnable(status)
end
function SettingProxy:setAutoAddDefence(key)
	-- body
	logger:info("setAutoAddDefence")
end
function SettingProxy:setPayTwoConfirm(key)
	-- body
	logger:info("setPayTwoConfirm")
end
function SettingProxy:setResourceLostConfirm(key)
	-- body
	logger:info("setResourceLostConfirm")
end
function SettingProxy:setLordCitySpend(key)
	-- body
	logger:info("setLordCitySpend")
end
function SettingProxy:setFightResTile(key)
	-- body
	logger:info("setFightResTile")
end
function SettingProxy:setDisplayBuildingName(key)
	-- body
	logger:info("setDisplayBuildingName")
end

-- 通知1
function SettingProxy:setActivityOpen(key)
	-- body
	logger:info("setActivityOpen")
end

-- 通知2
function SettingProxy:setBuildingUpgrateDone(key)
	-- body
	logger:info("setBuildingUpgrateDone")
end

-- 通知3
function SettingProxy:setProductDone(key)
	-- body
	logger:info("setProductDone")
end

-- 通知4
function SettingProxy:setEnergyFull(key)
	-- body
	logger:info("setEnergyFull")
end

--------------------------------------------------------------------------------------------------
-- 请求协议
--------------------------------------------------------------------------------------------------
function SettingProxy:onTriggerNet20300Req(data)
    -- body
    if data >= 1 and data <= 4 then
    	self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20300, {remainlist = {data}})
    else
		logger:info("onTriggerNet20300Req data error !!~~~")
    end
end

--------------------------------------------------------------------------------------------------
-- 接收协议
--------------------------------------------------------------------------------------------------
function SettingProxy:onTriggerNet20300Resp(data)
	-- body
	if data.rs == 0 then
	end
end

--更新获得头像
function SettingProxy:onTriggerNet20803Resp(data)
	if data.rs==0 then
		self:showSysMessage( TextWords[1435] ) -- "你获得了活动头像，快去设置里看看吧！"
		self._headHas = data.headHas
	end
end
--更新获得挂件
function SettingProxy:onTriggerNet20804Resp(data)
	if data.rs==0 then
		self:showSysMessage( TextWords[1436] ) -- 你获得了活动挂件，快去设置里看看吧！
		self._pendantHas = data.pendantHas
	end
end
function SettingProxy:isHasHead( headid )
	local ret = false
	for i, id in ipairs( self._headHas or {} ) do
		if not ret and id==headid then
			ret = true
		end
	end
	return ret
end
function SettingProxy:isHasPendant( pendantid )
	local ret = false
	for i, id in ipairs( self._pendantHas or {} ) do
		if not ret and id==pendantid then
			ret = true
		end
	end
	return ret
end