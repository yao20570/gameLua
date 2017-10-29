--
-- Author: zlf
-- Date: 2016年8月29日15:15:14
-- 英雄数据代理

HeroProxy = class("HeroProxy", BasicProxy)
HeroProxy.ITEM_COUNT = 6 -- 英雄格子总数
function HeroProxy:ctor()
    HeroProxy.super.ctor(self)
    self.proxyName = GameProxys.Hero
    self._allHeroInfo = {}
	self._allFormationInfo = {}
	self._allHeroPiece = {}
end

function HeroProxy:initSyncData(data)
	HeroProxy.super.initSyncData(self, data)
	self._allHeroInfo = {}                 --所有英雄数据   阵法id---阵法等级的  map
	self._allFormationInfo = {}	           --阵法   唯一id---英雄数据   map
	self._allHeroPiece = {}
	self:initHeroInfo(data.heroInfo)
	self.proxy = self:getProxy(GameProxys.Role)
	self:initFormation(data.formationInfo)
	self.iconName = {6, 8, 10, 5, 9, 11}
	self:initheroPieceInfos(data.heroPieceInfos)
end

function HeroProxy:initheroPieceInfos(info)
	for k,v in pairs(info) do
		self._allHeroPiece[v.typeid] = v
	end
end

function HeroProxy:getHeroPiece()
	return self._allHeroPiece
end

function HeroProxy:getHeroPieceNumByID(typeid)
    local num = 0
    if self._allHeroPiece[typeid] then
        num = self._allHeroPiece[typeid].num
    end 
    return num

end

function HeroProxy:updateHeroPieceInfos(info)
	for k,v in pairs(info) do
		self._allHeroPiece[v.typeid] = v
	end
	self:sendNotification(AppEvent.PROXY_HEROPIECE_UPDATE_INFO)
end

function HeroProxy:initHeroInfo(info)
	for k,v in pairs(info) do
		self._allHeroInfo[v.heroDbId] = v
	end
	self:setHeroInfoWithPos()
end

function HeroProxy:initFormation(info)
	self._allFormationInfo = self._allFormationInfo or {}
	for k,v in pairs(info) do
		self._allFormationInfo[v.formationId] = v.formationLv
	end
end

function HeroProxy:registerNetEvents()
end

function HeroProxy:unregisterNetEvents()
end

function HeroProxy:resetAttr()
end

function HeroProxy:resetCountSyncData()
end

function HeroProxy:onTriggerNet300000Req(data)
	self.curSzData = data
	self:syncNetReq(AppEvent.NET_M30, AppEvent.NET_M30_C300000, data)
end

function HeroProxy:onTriggerNet300000Resp(data)
	if data.rs == 0 then
		if self.curSzData.position == 0 then
			self:showSysMessage(TextWords:getTextWord(290056))
		else
			self:showSysMessage(TextWords:getTextWord(290057))
		end
		self:sendNotification(AppEvent.PROXY_HEROSZ_UPDATE_VIEW)
	end
    
end

--小红点更新
function HeroProxy:updateRedPoint()
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:checkEquiipRedPoint() 
end

function HeroProxy:onTriggerNet300001Req(data)
	self:syncNetReq(AppEvent.NET_M30, AppEvent.NET_M30_C300001, data)
end

function HeroProxy:onTriggerNet300001Resp(data)
	if data.rs == 0 then
		self:showSysMessage("操作成功！")
	else
		self:sendNotification(AppEvent.PROXY_HERO_LVUPDATE)
	end
end

function HeroProxy:onTriggerNet300002Req(data)
	self:syncNetReq(AppEvent.NET_M30, AppEvent.NET_M30_C300002, data)
end

function HeroProxy:onTriggerNet300002Resp(data)
	if data.rs == 0 then
		self:showSysMessage(TextWords:getTextWord(290058))
		local soldierProxy = self:getProxy(GameProxys.Soldier)
		soldierProxy:soldierMaxFightChange()
		self._allFormationInfo[data.Id] = self._allFormationInfo[data.Id] + 1
		self:sendNotification(AppEvent.PROXY_HEROZF_UPDATE_VIEW)
	end
end

function HeroProxy:onTriggerNet300003Req(data)
	self:syncNetReq(AppEvent.NET_M30, AppEvent.NET_M30_C300003, data)
end

function HeroProxy:onTriggerNet300003Resp(data)
	if data.rs == 0 then
		self:showSysMessage(TextWords:getTextWord(290059))
		self:sendNotification(AppEvent.PROXY_HEROBF_UPDATE_VIEW)
	end
end

function HeroProxy:onTriggerNet300004Resp(data)
	self:initFormation(data.formationInfo)
	self:sendNotification(AppEvent.PROXY_HEROZF_UPDATE_VIEW)
end

function HeroProxy:onTriggerNet300005Req(data)
	self:syncNetReq(AppEvent.NET_M30, AppEvent.NET_M30_C300005, data)
end

function HeroProxy:onTriggerNet300005Resp(data)
	if data.rs == 0 then
		self:showSysMessage(TextWords:getTextWord(290060))
	end
	self:sendNotification(AppEvent.PROXY_HERO_POS_CHANGE, data.rs)
end

function HeroProxy:onTriggerNet300006Req(data)
	self:syncNetReq(AppEvent.NET_M30, AppEvent.NET_M30_C300006, data)
end

function HeroProxy:onTriggerNet300006Resp(data)
	if data.rs == 0 then
		--self:showSysMessage("进阶成功")
		self:sendNotification(AppEvent.PROXY_TREASURE_ADVANCE_SUCCESS,data.time)
	else
		--满阶-2进阶失败-3 材料不足-4
		self:sendNotification(AppEvent.PROXY_TREASURE_ADVANCE_FAIL,data)
	end
end

function HeroProxy:onTriggerNet300007Req()
	self:syncNetReq(AppEvent.NET_M30, AppEvent.NET_M30_C300007, {})
end

function HeroProxy:onTriggerNet300100Req(data)
	local sendData = {}
	sendData.typeId = data
	self:syncNetReq(AppEvent.NET_M30, AppEvent.NET_M30_C300100,sendData)
end

function HeroProxy:onTriggerNet300100Resp(data)
	
end

function HeroProxy:onTriggerNet300101Req(data)
	self:syncNetReq(AppEvent.NET_M30, AppEvent.NET_M30_C300101, data)
end

function HeroProxy:onTriggerNet300101Resp(data)
	if data.rs == 0 then
		self:showSysMessage(TextWords:getTextWord(290026))
		self:sendNotification(AppEvent.PROXY_HERO_POS_RESOLVE)
	end
end

function HeroProxy:onTriggerNet300102Req(data)
	self:syncNetReq(AppEvent.NET_M30, AppEvent.NET_M30_C300102, data)
end

function HeroProxy:onTriggerNet300102Resp(data)
	if data.rs == 0 then
		self:sendNotification(AppEvent.PROXY_HERO_SHOW_RESOLVE, data.cr)
	end
end


function HeroProxy:onTriggerNet300103Req(data)
	self:syncNetReq(AppEvent.NET_M30, AppEvent.NET_M30_C300103, data)
end

function HeroProxy:onTriggerNet300103Resp(data)
end



--获取所有英雄信息
function HeroProxy:getAllHeroInfo()                
	local info = TableUtils:map2list(self._allHeroInfo)
	return info
end

--获得所有英雄的map信息
function HeroProxy:getAllHeroData()
	return self._allHeroInfo
end


------
-- 根据类型获取英雄信息
-- @param  heroType [int] 英雄类型
-- @return typeHeroData 该类型的英雄数据
function HeroProxy:getHeroByType(heroType)
    local typeHeroData = {}
    for key, value in pairs(self._allHeroInfo) do
        local configType = ConfigDataManager:getConfigById(ConfigData.HeroConfig, value.heroId).type
        if configType == heroType then
            table.insert(typeHeroData, value)
        end
    end
    return typeHeroData
end


--获得未上阵英雄的数量
function HeroProxy:getAllHeroNum()
	local heroNum = 0
	for k , v in pairs(self._allHeroInfo) do 
        if v.heroPosition == 0 then 
        	heroNum = heroNum + 1
        end
    end
	return heroNum
end

------
-- 获得未上阵的数据
function HeroProxy:getUnAddHero()
    local unAdd = {}
    for key, value in pairs(self._allHeroInfo) do
        if value.heroPosition == 0 and self:isExpCar(value) == false then
            table.insert(unAdd, value)
        end
    end
    return unAdd
end

------
-- 获得可上阵的坑位数
function HeroProxy:getCanAddCount()
    local count = 0 
    local posData = self:getUnlockPos()
    for pos = 1, HeroProxy.ITEM_COUNT do
        if posData[pos] then -- 如果开启
            -- 查看有无上阵英雄
            if self:getHeroInfoWithPos(pos) == nil then
                count = count + 1
            end
        end
    end
    return count
end

------
-- 获取解锁表
function HeroProxy:getUnlockPos()
    local posData = {}
    local soldierProxy = self:getProxy(GameProxys.Soldier)
    for i=1, HeroProxy.ITEM_COUNT do
		local state = soldierProxy:isTroopsOpen(i)
        posData[i] = state
    end
    return posData
end

--通过唯一id获取单个英雄信息
function HeroProxy:getInfoById(id)                 
	return self._allHeroInfo[id]
end

-- 计算一个card/hero的eat经验
-- #data, info
function HeroProxy:getEachEatenExp(data)
    local expNum = 0
    
    local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)
    
    if config.type == 1 then
        expNum = config.eatedExp
    elseif config.type == 0 then
        local expKey = {"wexpoffer", "gexpoffer", "bexpoffer", "pexpoffer", "oexpoffer"}
		local levelConfig = ConfigDataManager:getConfigById(ConfigData.HeroLevelConfig, data.heroLv)
		local key = expKey[config.color]
		expNum = levelConfig[key]
    end
    return expNum
end



--20007更新英雄信息
function HeroProxy:updateHeroInfo(data)            
	for k,v in pairs(data) do
		if v.heroId <= 0 then
			self._allHeroInfo[v.heroDbId] = nil
		else
			self._allHeroInfo[v.heroDbId] = v
		end
	end
	local soldier = self:getProxy(GameProxys.Soldier)
	soldier:soldierMaxFightChange()
--	soldier:setMaxFighAndWeight()  --只标记需要重新算最大战力就行，触发到对应的界面，才去算，不用实时去算
	self:sendNotification(AppEvent.PROXY_HERO_UPDATE_INFO, self._allHeroInfo)
    self:updateRedPoint() -- 更新阵容小红点
end

--更新位置各个位置上的英雄的信息
function HeroProxy:setHeroInfoWithPos(data)
	-- self._posHeroInfo = {}
	-- for k,v in pairs(self._allHeroInfo) do
	-- 	if v.heroPosition ~= 0 and v.heroPosition ~= nil then
	-- 		self._posHeroInfo[v.heroPosition] = v
	-- 	end
	-- end
end

--通过上阵位置获取英雄信息
function HeroProxy:getHeroInfoWithPos(pos)
	for k,v in pairs(self._allHeroInfo) do
		if v.heroPosition == pos then
			return v
		end
	end

end

--设置当前可以选材料的个数
function HeroProxy:setChooseMaxNum(num)
	self.maxNum = num
end

function HeroProxy:getChooseMaxNum()
	return self.maxNum or 5
end 

function HeroProxy:getFormationById(ID)
	return self._allFormationInfo[ID]
end

function HeroProxy:getAllFormation()
	return self._allFormationInfo
end

function HeroProxy:isExpCar(data)
	local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)
	if config == nil then
		logger:error("无法读表的数据，id===%d",data.heroId)
	end
	return config.type == 1
end

function HeroProxy:heroIsMaxLv(ID)
	local data = self._allHeroInfo[ID]
	local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)
	return data.heroLv >= config.lvmax
end

--获得所有属性(基础属性+升星带来的属性提升)，在infopanel里面显示
--isNoPlus不要带兵量的加成（计算坑位加成的时候不需要带兵量的加成）
function HeroProxy:getHeroAllAttr(data, isNoPlus)
	local attrInfo = {}
	local comNum = self.proxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)
	local baseKeys = {"hpMax", "hitRate", "criRate", "atk", "dodgeRate", "defRate"}
	local addKeys = {"hpMaxgrow", "hitRategrow", "criRategrow", "atkgrow", "dodRategrow", "defRategrow"}
	local textInfo = {"血量", "命中", "暴击", "攻击", "闪避", "抗暴"}
	local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)
	local starConfig = ConfigDataManager:getInfoFindByTwoKey(ConfigData.HeroStarConfig, "heroID", data.heroId, "star", data.heroStar)
	for k,v in pairs(baseKeys) do
		attrInfo[k] = {}
		if starConfig ~= nil then
			attrInfo[k].base = config[v] + config[addKeys[k]] * data.heroLv + starConfig[v]
		else
			attrInfo[k].base = config[v] + config[addKeys[k]] * data.heroLv
		end
		if k == 1 or k == 4 then
			if not isNoPlus then
				attrInfo[k].base = attrInfo[k].base * comNum / 100
			end
		end
		attrInfo[k].text = textInfo[k]
	end
	return attrInfo
end

--获得英雄本级属性和下一级属性加成  isMaxLv  满级不算下一级加成
function HeroProxy:getHeroLvUpAttr(data, isMaxLv, exp)
	local baseData = self:getHeroAllAttr(data)
	if isMaxLv or exp == 0 then
		for k,v in pairs(baseData) do
			v.add = 0
		end
		return baseData, 0
	end

	local comNum = self.proxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)

	local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)
	local levelConfig = ConfigDataManager:getConfigData(ConfigData.HeroLevelConfig)
	local needKeys = {"wexpneed", "gexpneed", "bexpneed", "pexpneed", "oexpneed"}
	local expKey = needKeys[config.color]
	exp = exp + data.heroExp
	local nextLv = data.heroLv
	local nextExp = levelConfig[nextLv][expKey]
	local canUpLevel = 0
	while nextExp <= exp do
		canUpLevel = canUpLevel + 1
		nextLv = nextLv + 1
		if nextLv >= config.lvmax then
			break
		end
		nextExp = nextExp + levelConfig[nextLv][expKey]
	end
	local addKeys = {"hpMaxgrow", "hitRategrow", "criRategrow", "atkgrow", "dodRategrow", "defRategrow"}

	for k,v in pairs(baseData) do
		if k == 1 or k == 4 then
			v.add = config[addKeys[k]] * canUpLevel * comNum / 100
		else
			v.add = config[addKeys[k]] * canUpLevel
		end
	end
	return baseData, canUpLevel
end

--获得英雄本级属性和下一星级属性加成  nextData下一星级的数据表，空表示满级
function HeroProxy:getHeroStarUpAttr(data, nextData, curData)
	local baseData = self:getHeroAllAttr(data)
	local addKeys = {"hpMax", "hitRate", "criRate", "atk", "dodgeRate", "defRate"}
	local comNum = self.proxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)
	for k,v in pairs(baseData) do
		if nextData ~= nil then
            local curDataAdd = 0
            if curData ~= nil then
                curDataAdd = curData[addKeys[k]] 
            end
             
			v.add = nextData[addKeys[k]] - curDataAdd
		else
			v.add = 0
		end
		if k == 1 or k == 4 then -- 血量和攻击的特殊处理
			v.add = v.add*comNum/100
		end
	end
	return baseData
end

function HeroProxy:getIconPath(index)
	return string.format("images/littleIcon/%d.png", self.iconName[index])
end

--isMe剔除本身
function HeroProxy:getHeroNumByType(type, star, isMe)
	local data = clone(self._allHeroInfo)
	if isMe then
		data[isMe.heroDbId] = nil
	end
	local num = 0
	for k,v in pairs(data) do
		if v.heroStar == star and v.heroId == type then
			num = num + 1
		end
	end
	return num
end

--获得一个英雄的总带兵量
function HeroProxy:getHeroCommandNumWithData(data)
	local command = 0
	if data == nil then
		return 0
	end
	local baseConfig = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)
	command = command + baseConfig.command
	if data.heroStar == 0 or data.heroStar == nil then
		return command
	end
	for i=1,data.heroStar do
		local starConfig = ConfigDataManager:getInfoFindByTwoKey(ConfigData.HeroStarConfig, "heroID", data.heroId, "star", i)
		command = command + starConfig.command
	end
	return command
end

--跳转到heroinfopanel的时候有时候没带数据，来这里拿 已经废弃
function HeroProxy:setCurInfoPanelData(data)
	self.curHeroData = data
end

--废弃
function HeroProxy:getCurInfoPanelData()
	return self.curHeroData
end

--获得一个英雄的战力
--TODO  写死了一些系数，修改时候需要注意
--0.1  血量系数
--0.5  攻击系数
--4.08 弓兵系数
function HeroProxy:getHeroFight(pos, adviserInfo)
	local data = self:getHeroInfoWithPos(pos)
	if data == nil then
		return 0
	end
	-- local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)
	
	-- local hp = (config.hpMax + config.hpMaxgrow * data.heroLv)-- * 0.1
	-- local attack = (config.atk + config.atkgrow * data.heroLv)-- * 0.5 * 4.08
	-- local hit = config.hitRate + config.hitRategrow * data.heroLv
	-- local dodge = config.dodgeRate + config.dodRategrow * data.heroLv
	-- local defrate = config.defRate + config.defRategrow * data.heroLv
	-- local crit = config.criRate + config.criRategrow * data.heroLv

	-- local starConfig = ConfigDataManager:getInfoFindByTwoKey(ConfigData.HeroStarConfig, "heroID", data.heroId, "star", data.heroStar)
	-- if starConfig ~= nil then
	-- 	hp = hp + starConfig.hpMax
	-- 	attack = attack + starConfig.atk
	-- 	hit = hit + starConfig.hitRate
	-- 	dodge = dodge + starConfig.dodgeRate
	-- 	defrate = defrate + starConfig.defRate
	-- 	crit = crit + starConfig.criRate
	-- end
    
	-- hp = hp / 100
	-- attack = attack / 100

	-- hp = math.floor(hp)
	-- attack = math.floor(attack)

	-- hp = hp * 0.1
	-- attack = attack * 0.5 * 4.08

 --    -- 兵法战力加成
 --    local strategicsInfo = data.strategicsInfo
 --    local strategicsFightValue = 0
 --    if #strategicsInfo ~= 0 then
 --        for key, info in pairs(strategicsInfo) do
 --            local strategicsLvInfo = ConfigDataManager:getInfoFindByTwoKey(ConfigData.StrategicsLvConfig, "StrategicsID", info.strategicsId, "lv", info.strategicsLv)
 --            strategicsFightValue = strategicsLvInfo.fightValue + strategicsFightValue
 --        end
 --    end

	-- local soldierProxy = self:getProxy(GameProxys.Soldier)
	-- local proxy = self:getProxy(GameProxys.Role)
	-- local adviserCommand = soldierProxy:getAdviserCommand(adviserInfo)
 --    local command = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_command) + adviserCommand
    
 --    logger:error("获得一个英雄的战力====%d", ((hit + dodge + defrate + crit) / 100 + hp + attack + strategicsFightValue) * command )
	-- return ((hit + dodge + defrate + crit) / 100 + hp + attack + strategicsFightValue) * command
	return self:calculateHeroFight(data,adviserInfo)
end

--计算英雄战力
function HeroProxy:calculateHeroFight(data,adviserInfo)

	if data == nil or data.heroId == nil then
		return 0
	end

	local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)
	
	local hp = (config.hpMax + config.hpMaxgrow * data.heroLv)-- * 0.1
	local attack = (config.atk + config.atkgrow * data.heroLv)-- * 0.5 * 4.08
	local hit = config.hitRate + config.hitRategrow * data.heroLv
	local dodge = config.dodgeRate + config.dodRategrow * data.heroLv
	local defrate = config.defRate + config.defRategrow * data.heroLv
	local crit = config.criRate + config.criRategrow * data.heroLv

	local starConfig = ConfigDataManager:getInfoFindByTwoKey(ConfigData.HeroStarConfig, "heroID", data.heroId, "star", data.heroStar)
	if starConfig ~= nil then
		hp = hp + starConfig.hpMax
		attack = attack + starConfig.atk
		hit = hit + starConfig.hitRate
		dodge = dodge + starConfig.dodgeRate
		defrate = defrate + starConfig.defRate
		crit = crit + starConfig.criRate
	end
    
	hp = hp / 100
	attack = attack / 100

	hp = math.floor(hp)
	attack = math.floor(attack)

	hp = hp * 0.1
	attack = attack * 0.5 * 4.08

    -- 兵法战力加成
    local strategicsInfo = data.strategicsInfo
    local strategicsFightValue = 0
    if #strategicsInfo ~= 0 then
        for key, info in pairs(strategicsInfo) do
            local strategicsLvInfo = ConfigDataManager:getInfoFindByTwoKey(ConfigData.StrategicsLvConfig, "StrategicsID", info.strategicsId, "lv", info.strategicsLv)
            strategicsFightValue = strategicsLvInfo.fightValue + strategicsFightValue
        end
    end

	local soldierProxy = self:getProxy(GameProxys.Soldier)
	local proxy = self:getProxy(GameProxys.Role)
	local adviserCommand = soldierProxy:getAdviserCommand(adviserInfo)
    local command = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_command) + adviserCommand
    
    logger:error("获得一个英雄的战力====%d", ((hit + dodge + defrate + crit) / 100 + hp + attack + strategicsFightValue) * command )
	return ((hit + dodge + defrate + crit) / 100 + hp + attack + strategicsFightValue) * command
end

--获取一个槽位英雄先手值
function HeroProxy:getFirstnum(pos)
	local data = self:getHeroInfoWithPos(pos)
	if data == nil then
		return 0
	end

    return self:getFirstnumFromData(data)
	--local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)
	--local talentList = StringUtils:jsonDecode(config.talent)
	--local firstnum = 0
	--for _,talentId in pairs(talentList) do
	--	local info = ConfigDataManager:getConfigById(ConfigData.HeroGiftConfig, talentId)
	--	firstnum = firstnum + info.firstnum
	--end

 --   -- 星级的先手值加成
 --   local starFirstNum = 0
 --   local heroStarData = ConfigDataManager:getInfoFindByTwoKey(ConfigData.HeroStarConfig, "heroID", data.heroId, "star", data.heroStar)
 --   if heroStarData ~= nil then
 --       starFirstNum = heroStarData.firstValueShow
 --       logger:info("槽位星级先手值："..starFirstNum)
 --   end
 --   return firstnum + starFirstNum
end

--获取一个槽位英雄先手值
function HeroProxy:getFirstnumFromData(data)
    if not data then
        return 0
    end

	local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)
	local talentList = StringUtils:jsonDecode(config.talent)
	local firstnum = 0
	for _,talentId in pairs(talentList) do
		local info = ConfigDataManager:getConfigById(ConfigData.HeroGiftConfig, talentId)
		firstnum = firstnum + info.firstnum
	end

    -- 星级的先手值加成
    local starFirstNum = 0
    local heroStarData = ConfigDataManager:getInfoFindByTwoKey(ConfigData.HeroStarConfig, "heroID", data.heroId, "star", data.heroStar)
    if heroStarData ~= nil then
        starFirstNum = heroStarData.firstValueShow
        logger:info("槽位星级先手值："..starFirstNum)
    end
    return firstnum + starFirstNum
end

-- 获取指定坑位的武将名字和名字颜色
function HeroProxy:getHeroNameByPos(pos)
	local curHero = self:getHeroInfoWithPos(pos)
	local name,color
	if curHero == nil then
	    name = TextWords:getTextWord(127)
	    color = ColorUtils.wordWhiteColor
	else
	    local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, curHero.heroId)
	    name = config.name
		color = ColorUtils:getColorByQuality(config.color) or ColorUtils.wordWhiteColor
	end
	return name,color
end

-- 
function HeroProxy:getHeroConfigInfo(typeId)
    local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, typeId)
    return config
end

--兵法升级、战法升级、升星道具不足公用元宝补足方法
--[[
		local name = ""
        local price = 0
        for k,v in pairs(otherData) do
            local config = ConfigDataManager:getInfoFindByOneKey(ConfigData.ShopConfig, "itemID", k)
            local itemData = ConfigDataManager:getConfigById(ConfigData.ItemConfig, k)
            if config ~= nil and itemData ~= nil then
                price = price + config.goldprice*v
                name = name .. itemData.name
            end
        end

        self:showMessageBox(string.format(context, name, price, name), buy)
]]
function HeroProxy:CommonLvUpEnough(data, panel, callback, context)
	local name = ""
	local price = 0
	--商城不卖
	local isNoShop = false
	for k,v in pairs(data) do
		local config = ConfigDataManager:getInfoFindByOneKey(ConfigData.ShopConfig, "itemID", k)
		local itemData = ConfigDataManager:getConfigById(ConfigData.ItemConfig, k)
		if config == nil then
            -- 忽略将魂的不足
            local heroCofigInfo = ConfigDataManager:getInfoFindByOneKey(ConfigData.HeroPieceConfig, "ID", k)
            if heroCofigInfo == nil then
			    isNoShop = true
			    break
            end
		end
		if config ~= nil and itemData ~= nil then
			price = price + config.goldprice*v
            name = name .. itemData.name .. ","
        end
	end

	if isNoShop then
		self:showSysMessage(TextWords:getTextWord(290068))
		return
	end

	if price <= 0 then
		callback()
		return 
	end

	if name ~= "" then
		name = string.reverse(name)
	    name = string.gsub(name, ",", "", 1)
	    name = string.reverse(name)
	end

	local function okFunc()
		local role = self:getProxy(GameProxys.Role)
		local haveCoin = role:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0
		if haveCoin < price then
			if panel.uiRechargePanel == nil then
				panel.uiRechargePanel = UIRecharge.new(panel, panel)
			else
				panel.uiRechargePanel:show()
			end
		else
			callback()
		end
	end

	panel:showMessageBox(string.format(context, name, price, name), okFunc)
end

function HeroProxy:findHeroWithTypeId(heroId)
	for k,v in pairs(self._allHeroInfo) do
		if v.heroId == heroId then
			return true
		end
	end
	return false
end

--根据typeid获取最高星级武将的data
function HeroProxy:getHeroDataWithTypeId(heroId)
	if self:findHeroWithTypeId(heroId) == true then
		local heroDataAry = {}
		for k,v in pairs(self._allHeroInfo) do
			if v.heroId == heroId then
				table.insert(heroDataAry,v) 
			end
		end
		table.sort( heroDataAry, function ( one,two )
			return one.heroStar > two.heroStar
		end )
		return heroDataAry[1]
	else
		return nil
	end
end

function HeroProxy:isHaveExpCard()
	local rs = false
	local count = 0
	for k,v in pairs(self._allHeroInfo) do
		if self:isExpCar(v) then
			rs = true
			count = count + v.num -- 总数量
		end
	end
	return rs, count
end

function HeroProxy:setResolveId(id)
	self._curResolveId = id
end

function HeroProxy:getResolveId()
	return self._curResolveId
end

function HeroProxy:haveSameName(data)
	for k,v in pairs(self._allHeroInfo) do
		if data.heroId == v.heroId then
			return true
		end
	end
	return false
end

--返回一个英雄是否自动分解，是就存进table
function HeroProxy:isResolve(data)
	local isExpCar = self:isExpCar(data)
	if isExpCar then
		return false
	end
	local isChangPos = self._allHeroInfo[data.heroDbId] ~= nil
	if isChangPos then
		return false
	end
	self._resolveHeros = self._resolveHeros or {}
	local rs = self:haveSameName(data)
	if rs then
		self._resolveHeros[data.heroDbId] = data
	end
	return rs
end

--一个存放自动分解的table
function HeroProxy:resetResolveData()
	self._resolveHeros = {}
end

--检查一个英雄是否自动分解
function HeroProxy:isResolveHero(dbId)
	self._resolveHeros = self._resolveHeros or {}
	return self._resolveHeros[dbId] ~= nil
end

function HeroProxy:isCanStarUp(heroData)
	if heroData == nil then
		return false
	end
	local roleProxy = self:getProxy(GameProxys.Role)
	local star = heroData.heroStar or 0
    local nextStarData = ConfigDataManager:getInfoFindByTwoKey(ConfigData.HeroStarConfig, "heroID", heroData.heroId, "star", star + 1) 
    --满星不可升星
    if nextStarData == nil then
    	return false
    end
    local needData = StringUtils:jsonDecode(nextStarData.itemneed)
    local enough = true
    for k,v in pairs(needData) do
        local num = roleProxy:getRolePowerValue(v[1], v[2])
       	if num < v[3] then
            enough = false
            break
        end
    end
    return enough
end



-- 是否可以遣散
function HeroProxy:isCanWorkOut(data)
    local state = false
    if not self:isExpCar(data) then
        if self:haveTwoMoreSame(data) then
            state = true
        end
    end
    return state
end

-- 是否有多个英雄(2个/以上)
function HeroProxy:haveTwoMoreSame(data)
    local state = false
    local count = 0
    for k,v in pairs(self._allHeroInfo) do
		if data.heroId == v.heroId then
			count = count + 1
            if count == 2 then
                break
            end
		end
	end

    if count >= 2 then
        state = true
    end

    return state
end

-- 根据typeId获取数量
function HeroProxy:getHeroNumById(typeId)
    local heroNum = 0
	for k , v in pairs(self._allHeroInfo) do 
        if v.heroId == typeId then 
        	heroNum = heroNum + v.num -- 避免可能有两个武将
        end
    end
	return heroNum
end

------
-- 获取武将带兵量加成
function HeroProxy:getHerosCommand()
    local command = 0
    for i=1, 6 do
        local heroData = self:getHeroInfoWithPos(i)
        local thisHeroCommand = self:getHeroCommandNumWithData(heroData)
        command = thisHeroCommand + command
    end
    return command
end

------
-- 获取武将可升级的最大等级
function HeroProxy:getHeroCanImproveLevel()
    local level = nil 
    local roleProxy = self:getProxy(GameProxys.Role)
    local roleLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    
    local configData = ConfigDataManager:getConfigData(ConfigData.IntervalTempConfig)
    for i, info in pairs(configData) do
        local minValue = info.minValue
        local maxValue = info.maxValue
        if roleLevel >= minValue and roleLevel <= maxValue then
            level = info.effectValue
            break
        end
    end
    return level
end
