TalentProxy = class("TalentProxy", BasicProxy)

function TalentProxy:ctor()
    TalentProxy.super.ctor(self)
    self.proxyName = GameProxys.Talent


    --服务器数据  = M39.WarBookInfo
    self.talentInfo = {}

    --自定义数据 某个兵的属性加成 { [兵id] = {propertyJson, propertyJson}, ... }
    self.extraSoldierPower = {}

end

--//国策信息

-- message TalentInfo{
--   required int32 talentId = 1;//天赋id
--   required int32 talentLv = 2;//对应的天赋等级
-- }

function TalentProxy:initSyncData(data)
    TalentProxy.super.initSyncData(self, data)
     
    self:onTriggerNet390000Resp(data)
end

--===============================================================
--协议请求
--===============================================================
--国策信息
function TalentProxy:onTriggerNet390000Req()
    self:syncNetReq(AppEvent.NET_M39, AppEvent.NET_M39_C390000, {})
end
--天赋升级 { TalentInfo, talentClass }
function TalentProxy:onTriggerNet390001Req(data)
    self:syncNetReq(AppEvent.NET_M39, AppEvent.NET_M39_C390001, data)
end
--天赋重置
function TalentProxy:onTriggerNet390002Req()
    self:syncNetReq(AppEvent.NET_M39, AppEvent.NET_M39_C390002, {})
end
--天赋激活
function TalentProxy:onTriggerNet390003Req( data )
    self:syncNetReq(AppEvent.NET_M39, AppEvent.NET_M39_C390003, data )
end
--协议返回
function TalentProxy:onTriggerNet390000Resp(data)

		self.talentInfo = data.talentInfo or {} --默认值
		self:_renderTalentPower()
		self:sendNotification( AppEvent.PROXY_TALENT_UPDATE )
	
end
function TalentProxy:onTriggerNet390001Resp(data)
    if data.rs==0 then
		--手动设置升一级
		self:_setTalentLvup( data.talentId )
    	self:_renderTalentPower()
    	self:sendNotification( AppEvent.PROXY_TALENT_UPDATE_SINGLE, data.talentId )
    end
end
function TalentProxy:onTriggerNet390002Resp(data)
	if data.rs==0 then
		self.talentInfo = {}
		self:_renderTalentPower()
		self:sendNotification( AppEvent.PROXY_TALENT_UPDATE )
	end
end
function TalentProxy:onTriggerNet390003Resp(data)
	if data.rs==0 then
		self:showSysMessage( TextWords:getTextWord(577) )
		self:_setTalentState( data.talentId )
		self:sendNotification( AppEvent.PROXY_TALENT_USED )
	end
end
--设置等级
function TalentProxy:_setTalentLvup( talentId )
	local isNew = true
	for i,v in ipairs(self.talentInfo) do
		if v.talentId==talentId then
			isNew = false
			v.talentLv = v.talentLv + 1
		end
	end
	if isNew then
		local defaut = self:getDefautTalentInfoById( talentId, 1 )
		table.insert( self.talentInfo, defaut )
	end
end
--设置激活
function TalentProxy:_setTalentState( talentId )
	local conf = self:getWarBookConfById( talentId ) or {}
	local class = conf.talentClass
	for i,v in ipairs(self.talentInfo) do
		local conf = ConfigDataManager:getInfoFindByOneKey( ConfigData.WarBookTalent, "ID", v.talentId)
		if conf.talentClass==class then
			v.talentState = v.talentId==talentId and 0 or 1
		end
	end
end

function TalentProxy:getTalentPropertyKey(talentId, propertyType)
    return talentId * 100 + propertyType
end

-- 设置兵法Power加成
function TalentProxy:_renderTalentPower()
    
    local soldierProxy = self:getProxy(GameProxys.Soldier)

    local map = { }
    for _, talent in ipairs(self.talentInfo) do
        if talent.talentLv and talent.talentLv > 0 then
            local conf = self:getWarBookUpgradeByIdLv(talent.talentId, talent.talentLv) or { }
            local propertyArr = StringUtils:jsonDecode(conf.armProperty or "[]")

            for _, v in pairs(propertyArr) do
                local type = v[1]
                local id = v[2]
                local property = {
                    talentId = v.talentId,
                    key = v[3],
                    value = v[4]
                }

                if type == 1 then
                    -- 对id兵加成                    
                    map[id] = map[id] or { }    
                    table.insert(map[id], property)

                elseif type == 2 then
                    -- 对id类型的兵加成
                    local armyKind = soldierProxy:getArmysCfgByKind(id)
                    for k, army in pairs(armyKind) do
                        local armyId = army.ID
                        map[armyId] = map[armyId] or { }
                        table.insert(map[armyId], property)
                    end

                elseif type == 3 then
                    -- 对id阶兵加成
                    local armyKindMapCfg = soldierProxy:getArmyKindMapCfg()
                    for type, armys in pairs(armyKindMapCfg) do
                        local armyId = armys[id].ID
                        map[armyId] = map[armyId] or { }
                        table.insert(map[armyId], property)
                    end

                elseif type == 4 then
                    -- 对id阶以上的兵加成
                    local armyKindMapCfg = soldierProxy:getArmyKindMapCfg()
                    for type, armys in pairs(armyKindMapCfg) do
                        for gradation, army in pairs(armys) do
                            if gradation >= id then
                                local armyId = army.ID
                                map[armyId] = map[armyId] or { }
                                table.insert(map[armyId], property)
                            end
                        end
                    end
                elseif type == 6 then
                    -- 对id兵以及同类型在id兵以上阶的兵
                    local armyCfgData = ConfigDataManager:getConfigById(ConfigData.ArmKindsConfig, id)
                    local tempGradation = armyCfgData.gradation
                    local armys = soldierProxy:getArmysCfgByKind(armyCfgData.type)
                    for gradation, army in pairs(armys) do
                        if gradation >= tempGradation then
                            local armyId = army.ID
                            map[armyId] = map[armyId] or { }
                            table.insert(map[armyId], property)
                        end
                    end

                end
            end
        end
    end
    self.extraSoldierPower = map
end

-- 获取国策的出手类型
function TalentProxy:getCurSequenceIcon()
    for i, v in ipairs(self.talentInfo) do
        if v.talentState == 1 then
            local talentCfgData = ConfigDataManager:getConfigById(ConfigData.WarBookTalent, v.talentId)
            if talentCfgData.talentActivate == 1 then
                local upgradeCfgData = ConfigDataManager:getInfoFindByOneKey(ConfigData.WarBookUpgrade, "talentID", v.talentId)
                if upgradeCfgData then
                    local sequenceCfgData = ConfigDataManager:getConfigById(ConfigData.WarBookSequence, upgradeCfgData.orderID)
                    if sequenceCfgData then
                        return sequenceCfgData.firstIcon
                    end
                end
            end
        end
    end

    -- 默认前排出手
    return 1
end

--============================================
--获取服务器数据
--============================================
--获得某个天赋信息  M39.TalentInfo
function TalentProxy:getTalentInfoById( talentId )
	for i,v in ipairs(self.talentInfo) do
		if v.talentId==talentId then
			return v
		end
	end
	return nil
end
--获得兵力国策属性加成
function TalentProxy:getSoldierPowerMap(soldierId)
    
    local map = { }
    local propertyDatas = self.extraSoldierPower[soldierId] or { }

    for i, property in ipairs(propertyDatas) do

        local key = property.key
        map[key] = map[key] or 0
        map[key] = map[key] + property.value

    end

    return map
end
--客户端手动生成一个默认天赋数据
function TalentProxy:getDefautTalentInfoById( id, lv )
	local conf = self:getWarBookConfById( id ) or {}
	local ret = {
		talentId=id,
		talentLv=lv,
		talentState= conf.talentActivate
	}
	return ret
end








--===============================================================
--以下 配置表
--===============================================================

function TalentProxy:getWarBookConf()
	local conf = ConfigDataManager:getConfigData( ConfigData.WarBookTalent )
	return conf
end
function TalentProxy:getWarBookConfById( id )
	local ret = ConfigDataManager:getInfoFindByOneKey( ConfigData.WarBookTalent, "ID", id)
	return ret
end
--阶级上限
function TalentProxy:getUnlockNumByClass( class )
	local ret = ConfigDataManager:getInfoFindByOneKey( ConfigData.WarBookClass, "talentClass", class) or {}
	return ret.unlockNum
end
--升级表
function TalentProxy:getWarBookUpgradeByIdLv( id, lv )
	local ret = nil
	if lv>0 then
		ret = ConfigDataManager:getInfoFindByTwoKey( ConfigData.WarBookUpgrade, "talentID", id, "level", lv )
	else
		ret = self:getWarBookConfById( id )
	end
	return ret
end
--重设价格
function TalentProxy:getWarBookParameter()
	local conf = ConfigDataManager:getInfoFindByOneKey( ConfigData.WarBookParameter, "ID", 1)
	return conf.resetPrice
end
--============================================
--将表数据按 talentClass 分组
function TalentProxy:getWarBookConfigRowList()
	local conf = self:getWarBookConf()
	local ret = {}
	for i,v in pairs( conf ) do
		local key = v.talentClass
		ret[key] = ret[key] or {}
		table.insert(ret[key], v)
	end

    return ret
end
