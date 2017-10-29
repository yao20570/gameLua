SoldierProxy = class("SoldierProxy", BasicProxy)

SoldierProxy.ArmyKind_Qi = 1
SoldierProxy.ArmyKind_Dao = 2
SoldierProxy.ArmyKind_Qiang = 3
SoldierProxy.ArmyKind_Gong = 4

--驻防状态
SoldierProxy.GARRISON_STATE_YES = 1 
SoldierProxy.GARRISON_STATE_NO = 2 

-- 行军状态
SoldierProxy.March_Atk = 1 -- 进攻
SoldierProxy.March_Ret = 2 -- 返回
SoldierProxy.March_Dig = 3 -- 挖掘
SoldierProxy.March_Go_Help = 4 -- 出发驻防
SoldierProxy.March_Help_Other = 5 -- 驻防中
SoldierProxy.March_Help_Me = 6 -- 别人的驻军
SoldierProxy.March_Legion_Fight = 7 -- 盟战准备开战
SoldierProxy.March_Imperial_Fight = 8 --皇城战准备开战

-- 军队目标类型
SoldierProxy.Target_Player = 1 -- 玩家
SoldierProxy.Target_Res = 2 -- 矿点
SoldierProxy.Target_Empty = 3 -- 空地OR容错
SoldierProxy.Target_Rebels = 4 -- 叛军
SoldierProxy.Target_Town_PVP = 5 -- 郡城pvp
SoldierProxy.Target_Town_PVE = 6 -- 郡城pve
SoldierProxy.Target_Imperial_PVP = 7 -- 皇城pvp
SoldierProxy.Target_Imperial_PVE = 8 --皇城pve

function SoldierProxy:ctor()
    SoldierProxy.super.ctor(self)
    self.proxyName = GameProxys.Soldier
    self._soldierTotalList = {}  --佣兵列表,包含了数量为0的佣兵
    self._soldierRealList = {}   --佣兵列表,不包含数量为0的佣兵
    self._soldierFightAndWeight = {} --一个佣兵的战力和载重
    self._firstInit = true           --第一次初始化计算
    self._getRoleInfo = false
    self:initData()
    self.beAttactionData = {}
    self._badSoldierList = {}
    self._taskTeamInfo = {}
    
    self._taskTeamInfoMap = {}
    self._teamInfo = {}
    self._checkProtectPos = {}

    self._maxFightModules = {ModuleName.TeamModule,ModuleName.ArenaModule,ModuleName.WarlordsModule}  --最大战力相关的模块

    self._totalFirstNum = 0 --总共的先手值 在设置最大战力的时候算一下就好了

    self._armyKindMap = nil

    self._attackOldMap = {}
end

function SoldierProxy:resetAttr()
    self._soldierTotalList = {}
    self._soldierRealList = {}
    self._soldierFightAndWeight = {}
    self._firstInit = false 
    self._firstOpen = nil
    self._getRoleInfo = false
    self._isRepaireSoldier = false
    self.beAttactionData = {}
    self._badSoldierList = {}
    self._taskTeamInfo = {}
    self._teamInfo = {}
    self._checkProtectPos = {}

    self._totalFirstNum = 0 

    self._garrisonTeamId = 0
end

function SoldierProxy:onTriggerNet40000Resp(data)
    logger:error("========服务端不要再发40000了！！=============")
end

function SoldierProxy:onTriggerNet40001Resp(data)
    self:onBadSolidersListResp(data)
end

--修复兵返回，这里需要对下次的获取兵，进行强制设置最大战力
--TODO 暂时这样子处理
function SoldierProxy:onTriggerNet40002Resp(data)
    self._isForceUpdateFight = true
end

function SoldierProxy:onTriggerNet80003Resp(data)
    self:onUpdateTaskTeamInfoResp(data)
end


function SoldierProxy:initData()
    self._soldierType = {}
    self._soldierType[SoldierProxy.ArmyKind_Qi] = 1
    self._soldierType[SoldierProxy.ArmyKind_Dao] = 2.4
    self._soldierType[SoldierProxy.ArmyKind_Qiang] = 1.7
    self._soldierType[SoldierProxy.ArmyKind_Gong] = 4.08

    self._soldierAddAttr = {}
    self._soldierAddAttr[SoldierProxy.ArmyKind_Qi] = {15,16}
    self._soldierAddAttr[SoldierProxy.ArmyKind_Dao] = {13,14}
    self._soldierAddAttr[SoldierProxy.ArmyKind_Qiang] = {17,18}
    self._soldierAddAttr[SoldierProxy.ArmyKind_Gong] = {19,20}
end

function SoldierProxy:initSyncData(data)
    SoldierProxy.super.initSyncData(self, data)

    local roleProxy = self:getProxy(GameProxys.Role)
    --这里roleproxy的20000初始化还要快
    if roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command) == 0 then
        local actorInfo = data.actorInfo
        roleProxy:setRoleAttrInfos(actorInfo.attrInfos)
    end

    self._attackTimes = data.attackTimes -- 离线状态受过攻击次数

    self._attackPlayerTimes = data.attackPlayerTimes -- 攻打世界玩家次数

    --_applyTeamInfo  套用阵型的信息
    self._applyTeamInfo = {}
    self._applyTeamInfoClone = {}

    self.curFight = nil
    self._getRoleInfo = true
    local soldierList = data.soldierList
    self:onDicData(soldierList, 1)
     
    self._taskTeamInfoMap = {}
    
    local tempData = {}
    tempData.soldiers = data.soldiers
    tempData.rs = 0
    self:onBadSolidersListResp(tempData)

    if data.list then
        local tempData = {}
        tempData.list = data.list
        tempData.rs = 0
        self:onUpdateTaskTeamInfoResp(tempData)
    end
    if data.infos then
        local tempData = {}
        tempData = data.infos
        self:onTriggerNet80007Resp(tempData)
    end
    
    -- local dungeonProxy = self:getProxy(GameProxys.Dungeon)
    -- dungeonProxy:setCheckExample()
    if data.info ~= nil then   --阵型的数据保存
        local tempData = {}
        tempData.info = data.info
        tempData.rs = 0
        self:onSetTeamResp1(tempData)
    end

    if data.teamInfo ~= nil then
        self:setTeamInfo(data.teamInfo)
    end
    self:updateDefTeamInfo()
    self:updateSetTeamInfo()
    self:updatePveTeamInfo()
end


--获取 某类型兵种的所有兵的配置
function SoldierProxy:getArmysCfgByKind(armyKind)
    local armyKindMap = self:getArmyKindMapCfg()
    return armyKindMap[armyKind]
end

--获取 以兵种类型type为一维，兵种阶级gradation为二维的 兵种配置表
function SoldierProxy:getArmyKindMapCfg()
    if self._armyKindMap == nil then
       self._armyKindMap = {}
        local armyKindCfg = ConfigDataManager:getConfigData(ConfigData.ArmKindsConfig)
        for k, v in pairs(armyKindCfg) do
            local armys = self._armyKindMap[v.type] or {}
            armys[v.gradation] = v
            self._armyKindMap[v.type] = armys
        end
    end

    return self._armyKindMap
end

function SoldierProxy:afterInitSyncData()
--    self:setMaxFighAndWeight() --建筑初始化完毕后，再设置
end

function SoldierProxy:setTeamInfo(data)
    for k,v in pairs(data) do
        self._applyTeamInfo[v.type] = v
    end
    self._applyTeamInfoClone = clone(self._applyTeamInfo)
end

--获取套用阵型的map数据
function SoldierProxy:getTeamDataMap()
    return self._applyTeamInfo
end

function SoldierProxy:onDicData(newTable, other)  --other 1:表示佣兵列表
    if newTable == nil then
        return
    end
    
    local data = nil
    if other == 1 then --佣兵列表
        for _,v in pairs(newTable) do
            self._soldierTotalList[v.typeid] = v
            
            if #v.powerInfo > 0 then
                logger:error("=====服务端不要发佣兵的powerList了==============")
            end
        end
    end



    self._soldierRealList = {}
    for _,v in pairs(self._soldierTotalList) do
        if v.num ~= 0 then
            self._soldierRealList[v.typeid] = v
        end
    end

    --进mainscene时候，还没有佣兵列表，获取佣兵列表后通知主城刷新
    self:delaySendNotification(AppEvent.PROXY_SOLIDER_MOFIDY)
   
end

function SoldierProxy:getTotalSoldierList()  --佣兵获取的接口,包含佣兵数量为0
    return self._soldierTotalList
end

function SoldierProxy:getRealSoldierList()   --佣兵获取的接口,不包含num为0
    return self._soldierRealList
end

--获取佣兵的power值
function SoldierProxy:getSoldierPowerValue(typeid, power)
    local solider = self._soldierRealList[typeid]
    local powerList = solider.powerList

    return powerList[power]
end

function SoldierProxy:getSoldier(typeid)
    return self._soldierTotalList[typeid]
end

-- 初始化Power值 重算Power算
-- noPlus不为空时，不计算加成
function SoldierProxy:getPowerListValue(typeid, noPlus)

    local soldierDefine = ConfigDataManager:getConfigById(ConfigData.ArmKindsConfig, typeid)


    -- 计算阵法对兵的加成
    local heroProxy = self:getProxy(GameProxys.Hero)
    local formation = heroProxy:getAllFormation()
    local const_atk = 37
    -- 宏定义，攻击
    local const_hp = 36
    -- 宏定义，血量
    local hpPlus = 0
    local atkPlus = 0
    for k, v in pairs(formation) do
        local config = ConfigDataManager:getInfoFindByTwoKey(ConfigData.FormationLvConfig, "FormationID", k, "lv", v)
        local ArmGrada = StringUtils:jsonDecode(config.ArmGrada)
        local isSameArms = false
        local isSameType = soldierDefine.type == config.ArmKinds
        for key, value in pairs(ArmGrada) do
            if value == soldierDefine.gradation then
                isSameArms = true
                break
            end
        end
        if config ~= nil and isSameArms and isSameType then
            local plusData = StringUtils:jsonDecode(config.property)
            for _, plus in pairs(plusData) do
                if plus[1] == const_hp then
                    hpPlus = hpPlus + plus[2]
                end
                if plus[1] == const_atk then
                    atkPlus = atkPlus + plus[2]
                end
            end
        end
    end

    if noPlus ~= nil then
        atkPlus = 0
        hpPlus = 0
    end


    local hp = soldierDefine.hpmax
    local atk = soldierDefine.atk
    local hitRate = soldierDefine.hitRate
    local dodgeRate = soldierDefine.dodgeRate
    local critRate = soldierDefine.critRate
    local defRate = soldierDefine.defRate
    local wreck = soldierDefine.wreck
    local defend = soldierDefine.defend
    local load = soldierDefine.load
    local soldierType = soldierDefine.type

    local powerMap = { }

    local roleProxy = self:getProxy(GameProxys.Role)
    for i = SoldierDefine.POWER_hpMax, SoldierDefine.TOTAL_FIGHT_POWER do
        local value = roleProxy:getRoleAttrValue(i)
        powerMap[i] = value
    end
    powerMap[SoldierDefine.POWER_hpMax] = powerMap[SoldierDefine.POWER_hpMax] + hp
    powerMap[SoldierDefine.POWER_hp] = powerMap[SoldierDefine.POWER_hp] + hp
    -- + hpPlus
    powerMap[SoldierDefine.POWER_atk] = powerMap[SoldierDefine.POWER_atk] + atk
    -- + atkPlus
    powerMap[SoldierDefine.POWER_hitRate] = powerMap[SoldierDefine.POWER_hitRate] + hitRate
    powerMap[SoldierDefine.POWER_dodgeRate] = powerMap[SoldierDefine.POWER_dodgeRate] + dodgeRate
    powerMap[SoldierDefine.POWER_critRate] = powerMap[SoldierDefine.POWER_critRate] + critRate
    powerMap[SoldierDefine.POWER_defRate] = powerMap[SoldierDefine.POWER_defRate] + defRate
    powerMap[SoldierDefine.POWER_wreck] = powerMap[SoldierDefine.POWER_wreck] + wreck
    powerMap[SoldierDefine.POWER_defend] = powerMap[SoldierDefine.POWER_defend] + defend
    powerMap[SoldierDefine.POWER_load] = powerMap[SoldierDefine.POWER_load] + load
    powerMap[SoldierDefine.POWER_loadRate] = powerMap[SoldierDefine.POWER_loadRate]
    powerMap[SoldierDefine.POWER_hpMaxRate] = powerMap[SoldierDefine.POWER_hpMaxRate] + self:getHpAddPercent(soldierType)
    powerMap[SoldierDefine.POWER_atkRate] = powerMap[SoldierDefine.POWER_atkRate] + self:getAtkAddPercent(soldierType)

    powerMap[SoldierDefine.POWER_extraHp] = 0
    powerMap[SoldierDefine.POWER_extraAtk] = 0

    local partsProxy = self:getProxy(GameProxys.Parts)
    local map = partsProxy:getSoldierTypePowerMap(soldierType)

    for key, value in pairs(powerMap) do
        if map[key] ~= nil then
            powerMap[key] = powerMap[key] + map[key]
        end
    end

    -- 计算国策对某个士兵的属性加成   add by fwx 16.11.19---
    if not noPlus then
        local talentProxy = self:getProxy(GameProxys.Talent)
        local map = talentProxy:getSoldierPowerMap(typeid)

        for key, value in pairs(map) do
            powerMap[key] = (powerMap[key] or 0) + value
        end
    end

    -- 计算军工所对某个兵种的属性加成
    local buildingProxy = self:getProxy(GameProxys.Building)
    if buildingProxy:isBuildingOpen(20, 17, true) then
        local militaryProxy = self:getProxy(GameProxys.Military)
        local curAttriTable = militaryProxy:getCurAttriTable(soldierType)
        for key, value in pairs(curAttriTable) do
            powerMap[key] = (powerMap[key] or 0) + value
        end
    end
	local offset = 0 --四舍五入    
    local powerList = { }
    for i = SoldierDefine.POWER_hpMax, SoldierDefine.TOTAL_FIGHT_POWER do
        if i == SoldierDefine.POWER_hp or SoldierDefine.POWER_hpMax == i then
            local hp = powerMap[SoldierDefine.POWER_hp]
            local hpPer = powerMap[SoldierDefine.POWER_hpMaxRate]
            hp = math.floor(hp *(1 + hpPer / 10000.0) + hpPlus + offset) + powerMap[SoldierDefine.POWER_extraHp]
            table.insert(powerList, hp)
        elseif SoldierDefine.POWER_atk == i then
            local atk = powerMap[SoldierDefine.POWER_atk]
            local atkPer = powerMap[SoldierDefine.POWER_atkRate]
            atk = math.floor(atk *(1 + atkPer / 10000.0) + atkPlus + offset) + powerMap[SoldierDefine.POWER_extraAtk]
            table.insert(powerList, atk)
        elseif SoldierDefine.POWER_load == i then
            local load = powerMap[SoldierDefine.POWER_load]
            local loadPer = powerMap[SoldierDefine.POWER_loadRate]
            load = math.floor(load *(1 + loadPer / 10000.0) + offset)
            table.insert(powerList, load)
        else
            table.insert(powerList, powerMap[i])
        end
    end

    -- powerList的29之后所需的后续属性增加
    powerList[SoldierDefine.POWER_critdam]  = powerMap[SoldierDefine.POWER_critdam]  or 0 ---------爆伤*/33
    powerList[SoldierDefine.POWER_tenacity] = powerMap[SoldierDefine.POWER_tenacity] or 0 ---------韧性*/34
    powerList[SoldierDefine.POWER_damHurt]  = powerMap[SoldierDefine.POWER_damHurt]  or 0 ---------伤害*/44
    powerList[SoldierDefine.POWER_damArmor] = powerMap[SoldierDefine.POWER_damArmor] or 0 ---------护甲*/45

    return powerList
end


function SoldierProxy:getHpAddPercent(soldierType)
    local roleProxy = self:getProxy(GameProxys.Role)
    local adder = roleProxy:getRoleAttrValue(SoldierDefine.POWER_hpMaxRate)
    local addPower = 0
    if soldierType == SoldierDefine.SOLDIER_TYPE_CAVALRY then
        addPower = SoldierDefine.POWER_cavalryHpMax
    elseif soldierType == SoldierDefine.SOLDIER_TYPE_INFANTRY then
        addPower = SoldierDefine.POWER_infantryHpMax
    elseif soldierType == SoldierDefine.SOLDIER_TYPE_ARCHER then
        addPower = SoldierDefine.POWER_archerHpMax
    elseif soldierType == SoldierDefine.SOLDIER_TYPE_PIKEMAN then
        addPower = SoldierDefine.POWER_pikemanHpMax
    end

    adder = adder + roleProxy:getRoleAttrValue(addPower)
    return adder
end

function SoldierProxy:getAtkAddPercent(soldierType)
    local roleProxy = self:getProxy(GameProxys.Role)
    local adder = roleProxy:getRoleAttrValue(SoldierDefine.POWER_atkRate)
    local addPower = 0
    if soldierType == SoldierDefine.SOLDIER_TYPE_CAVALRY then
        addPower = SoldierDefine.POWER_cavalryAtk
    elseif soldierType == SoldierDefine.SOLDIER_TYPE_INFANTRY then
        addPower = SoldierDefine.POWER_infantryAtk
    elseif soldierType == SoldierDefine.SOLDIER_TYPE_ARCHER then
        addPower = SoldierDefine.POWER_archerHpatk
    elseif soldierType == SoldierDefine.SOLDIER_TYPE_PIKEMAN then
        addPower = SoldierDefine.POWER_pikemanAtk
    end

    adder = adder + roleProxy:getRoleAttrValue(addPower)
    return adder
end

function SoldierProxy:updateSoldiersList(soldiersList)
    --for _,v in pairs(soldiersList) do
        --logger:info("#########################     %d",v.num)
    --end
    
    self:onDicData(soldiersList, 1)
    self:soldierMaxFightChange()
    
    --local isShow = self:isModuleShow(ModuleName.TeamModule) 
    local isShow = self:onShowMaxFightModules()
    if isShow == true then
        self:setMaxFighAndWeight()
    end
    self:delaySendNotification(AppEvent.PROXY_SOLIDER_MOFIDY)
    self:setCheckExample()
    self:updateSetTeamInfo()
    self:updateDefTeamInfo()
    self:updatePveTeamInfo()
    
end

--主城兵少了，更新防守阵型的兵
function SoldierProxy:updateDefTeamInfo()
    local defTeamInfo = self._teamInfo[2].members

    local soldierNums = {}
    for k,v in pairs(self.defSoldierInfo.members) do
        if v.typeid ~= 0 and v.post ~= 9 then
            local soldier = self:getSoldier(v.typeid)
            local haveSoldier = 0
            if soldier ~= nil then
                haveSoldier = soldier.num
            end
            if soldierNums[v.typeid] == nil then
                soldierNums[v.typeid] = haveSoldier
            end
        end
    end

    for k,v in pairs(self.defSoldierInfo.members) do
        local haveSoldier = 0
        --v.post = 9 是军师
        if v.typeid ~= 0 and v.post ~= 9 then
            --获取兵的数量
            haveSoldier = soldierNums[v.typeid]
            for key,info in pairs(defTeamInfo) do
                if info.post == v.post then
                    --这个肯定能找到的  因为self.defSoldierInfo.members是defTeamInfo克隆出来的一份数据
                    defTeamInfo[key].num = v.num > haveSoldier and haveSoldier or v.num
                    soldierNums[v.typeid] = soldierNums[v.typeid] - defTeamInfo[key].num
                    soldierNums[v.typeid] = soldierNums[v.typeid] > 0 and soldierNums[v.typeid] or 0
                    break
                end
            end
        end
    end
    self._teamInfo[2].members = defTeamInfo
    self:sendNotification(AppEvent.PROXY_DEFTEAM_UPDATE)
end

--主城兵少了，更新套用阵型的兵
function SoldierProxy:updateSetTeamInfo()
    local function updateTeamInfo(info, key)
        local teaminfo = self._applyTeamInfo[key].members
        local soliderNums = {}
        --记录最原始的阵法的兵的数量，下面要做减法
        for k,v in pairs(info) do
            if v.typeid ~= 0 and v.post ~= 9 then
                local num = 0
                local soldier = self:getSoldier(v.typeid)
                if soldier ~= nil then
                    num = soldier.num
                end
                if soliderNums[v.typeid] == nil then
                    soliderNums[v.typeid] = num
                end 
            end
        end

        --更新每个阵型的每个槽位上的兵的数量
        for k,v in pairs(info) do
            --v.post = 9 是军师
            if v.typeid ~= 0 and v.post ~= 9 then
                local haveSoldier = soliderNums[v.typeid]
                for index, item in pairs(teaminfo) do
                    if item.post == v.post then
                        teaminfo[index].num = v.num > haveSoldier and haveSoldier or v.num
                        soliderNums[v.typeid] = soliderNums[v.typeid] - teaminfo[index].num
                        soliderNums[v.typeid] = soliderNums[v.typeid] > 0 and soliderNums[v.typeid] or 0
                        break
                    end
                end
            end
            
        end
        self._applyTeamInfo[key].members = teaminfo
    end

    self._applyTeamInfoClone = self._applyTeamInfoClone or {}
    for key,value in pairs(self._applyTeamInfoClone) do
        --更新所有套用阵型的兵的数量
        updateTeamInfo(value.members, key)
    end

end

function SoldierProxy:onShowMaxFightModules()
    for _,v in pairs(self._maxFightModules) do
        if self:isModuleShow(v) == true then
            return true
        end
    end
end

-- function SoldierProxy:setMaxFighAndWeightUpdate(soldiersList)  --佣兵修改之后的重新排列
--     for _ ,father in pairs(soldiersList) do
--         if father.num == 0 then  --如果一个typeid为空
--             local index = 1
--             for _ , child in pairs(self._sortFightList) do  --最大战力列表的修改
--                 if child.typeid == father.typeid then
--                     table.remove(self._sortFightList,index)
--                 end
--                 index = index + 1
--             end

--             local index = 1
--             for _ , child in pairs(self._sortWeightList) do
--                 if child.typeid == father.typeid then
--                     table.remove(self._sortWeightList,index)
--                 end
--                 index = index + 1
--             end
--         else --属性值发生改变了
--             local index = 1
--             for _ , child in pairs(self._sortFightList) do
--             end
--         end
--     end
-- end

--同时设置一下powerList
function SoldierProxy:getFightAndWeightByItem(SoldierInfo)
    local totalFight = 0
    SoldierInfo.powerList = self:getPowerListValue(SoldierInfo.typeid)
    local powerList = SoldierInfo.powerList
    SoldierInfo.attack = powerList[SoliderPowerDefine.attack]  
    SoldierInfo.hp = powerList[SoliderPowerDefine.life]
    
    SoldierInfo._life = powerList[SoliderPowerDefine.life]                        --生命
    SoldierInfo._attack = powerList[SoliderPowerDefine.attack]                    --攻击
    SoldierInfo._target = powerList[SoliderPowerDefine.target]                    --命中
    SoldierInfo._escape = powerList[SoliderPowerDefine.escape]                    --闪避
    SoldierInfo._heavyFight = powerList[SoliderPowerDefine.heavyFight]            --暴击
    SoldierInfo._Kbao = powerList[SoliderPowerDefine.Kbao]                        --抗暴          
    local chuanCi  = powerList[SoliderPowerDefine.chuanCi]                        -- 穿刺
    local proctect = powerList[SoliderPowerDefine.proctect]                       -- 防护

    local critdam  = powerList[SoldierDefine.POWER_critdam]                       -- 爆伤33
    local tenacity = powerList[SoldierDefine.POWER_tenacity]                      -- 韧性34
    local damHurt  = powerList[SoldierDefine.POWER_damHurt]                       -- 伤害44
    local damArmor = powerList[SoldierDefine.POWER_damArmor]                      -- 护甲45

    SoldierInfo._lifePer = powerList[SoliderPowerDefine.POWER_hpMaxRate]  --生命百分比
    SoldierInfo._atkPer = powerList[SoliderPowerDefine.POWER_atkMaxRate]  --攻击百分比

    local roleProxy = self:getProxy(GameProxys.Role)
    local rate = roleProxy:getRoleAttrValue(PlayerPowerDefine.NOR_POWER_loadRate)
    local weight = math.floor( powerList[SoliderPowerDefine.weight]  ) --载重

    local info = ConfigDataManager:getInfoFindByOneKey("ArmKindsConfig","ID",SoldierInfo.typeid)
    SoldierInfo._soldierType = self._soldierType[info.type]

    SoldierInfo._lifeAdd = powerList[self._soldierAddAttr[info.type][1]]   --兵种血量加成比
    SoldierInfo._atkAdd = powerList[self._soldierAddAttr[info.type][2]]    --兵种攻击加成比

    totalFight = totalFight + chuanCi / 10--* 100 /100
    totalFight = totalFight + proctect / 10--* 100 / 100

    totalFight = totalFight + critdam  * 10--* 配置问题 *10
    totalFight = totalFight + tenacity * 10--* 配置问题 *10
    local damHurtMen  = damHurt * 0.5 * SoldierInfo._soldierType
    local damArmorMen = damArmor * 0.5 * SoldierInfo._soldierType
    totalFight = totalFight + damHurtMen 
    totalFight = totalFight + damArmorMen

    local exterLen = totalFight

    totalFight = totalFight + SoldierInfo._target / 100 --* 100 / 10000
    totalFight = totalFight + SoldierInfo._escape / 100--* 100 / 10000
    totalFight = totalFight + SoldierInfo._heavyFight / 100--* 100 /10000
    totalFight = totalFight + SoldierInfo._Kbao / 100 --* 100 / 10000
    
    local attackMen = SoldierInfo._attack * 0.5 * SoldierInfo._soldierType
    totalFight = totalFight + attackMen--SoldierInfo._attack * (1 + SoldierInfo._atkPer /10000 )* 0.5 * SoldierInfo._soldierType    -- + SoldierInfo._atkAdd /10000
    local lifeMen = SoldierInfo._life * 0.1
    totalFight = totalFight + lifeMen--SoldierInfo._life * ( 1 + SoldierInfo._lifePer /10000 ) * 0.1   -- + SoldierInfo._lifeAdd /10000

    return  totalFight,weight,exterLen
end

--佣兵的最大战力需要改变
--
function SoldierProxy:soldierMaxFightChange()
    self._isSoldierMaxFightChange = true
end

--通过建筑类型，建筑等级，获取开启的槽位
---1则还未开启
function SoldierProxy:getOpenPos(buildType, buildLv)
    local troopsStartConfig = ConfigDataManager:getConfigData(ConfigData.TroopsStartConfig)
    for _, config in pairs(troopsStartConfig) do
        local captainLv = StringUtils:jsonDecode( config.buildLv )
        if buildType == captainLv[1] and buildLv == captainLv[2] then
            return config.troopsID
        end
    end
    return -1
end

--获取开启的部队坑位列表
function SoldierProxy:getTroopsOpenPosList()
    local openPos = {}  --Open的坑位
    for pos = 1,6 do
         if self:isTroopsOpen(pos) then
             table.insert(openPos, pos)
         end
    end
    
    return openPos
end

--槽位是否开启
function SoldierProxy:isTroopsOpen(pos)
    local info = ConfigDataManager:getInfoFindByOneKey(ConfigData.TroopsStartConfig, "troopsID", pos)
    local captainLv = StringUtils:jsonDecode( info.buildLv )
    local buildType = captainLv[1]
    local level = captainLv[2]
    local buildProxy = self:getProxy(GameProxys.Building)
    local maxLv = buildProxy:getBuildingMaxLvByType(buildType)
    if maxLv >= level then
        return true
    end
    --TODO 增加notOpenInfo 
    local buildOpenConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.BuildOpenConfig, "type", buildType)
    return false, buildOpenConfig.name .. level
end

--function SoldierProxy:

-----目前打开TeamModule时才会调用--!!!!
--加个军师的参数，在军师上下阵的时候都要调用这个函数，改变每个槽位的出兵数量
--军师上阵就传个真实id过来   要军师的唯一id，下阵就传不是num类型的过来就可以
--传nil直接去军师数据类拿最大战力的军师
function SoldierProxy:setMaxFighAndWeight(adviserId)

    --在部队主界面的相关佣兵操作，都强制设置最大战力了
    if self._isSoldierMaxFightChange == false  then
        return
    end

    self._isSoldierMaxFightChange = false

    --TODO 这里要先选一个军师出来，军师会增加玩家POWER_command属性，战斗属性
    local consuPeoxy = self:getProxy(GameProxys.Consigliere)
    local adviserData = consuPeoxy:getInfoById(adviserId)
    if adviserId == nil then
        adviserId = consuPeoxy:getMaxConsu()--选出来的
        adviserData = consuPeoxy:getInfoById(adviserId)
    end

    adviserData = adviserData or {}

    local command = self:getAdviserCommand(adviserData)
    
    local proxy = self:getProxy(GameProxys.Role)
    local num = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_command) + command --一个坑最大的出兵上线
    print("上限................",num,command)

    local level = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)  --指挥官等级,算出几个坑是open的
    local openPos = self:getTroopsOpenPosList()
    self._sortFightList = {}
    self._sortWeightList = {}
    
    local time = os.clock()
    
    local sortFightList = SortList.new(6, "totalPower")  --前6战斗力数组
    local sortWeightList = SortList.new(6, "totalPower") --前6战斗力数组
    for _,v in pairs(self._soldierRealList) do
        if v ~= nil then
            local total ,weight,exterLen = self:getFightAndWeightByItem(v) 
            
            self._soldierFightAndWeight[v.typeid] = {}
            self._soldierFightAndWeight[v.typeid].value = v
            self._soldierFightAndWeight[v.typeid].fight = total    --一个武将的战力，不包括装备属性加成
            self._soldierFightAndWeight[v.typeid].weight = weight  --一个武将的载重
            self._soldierFightAndWeight[v.typeid].exterLen = exterLen  --一个武将包括穿刺和保护的战力
            self._soldierFightAndWeight[v.typeid].num = v.num           --该武将的数量

            local item = {}
            local weItem = {}

            --logger:info("total: %d  typeid :%d  weight: %d   num:%d",total,v.typeid,weight,v.num)

            local _cuNum = v.num
            if _cuNum > num then
                local times = math.floor(_cuNum / num)
                for i =1,times do
                    item = {}
                    item.typeid = v.typeid
                    item.num = num
                    item.totalPower = total*num
                    table.insert(self._sortFightList,item)  --战力
                    sortFightList:add(item)

                    weItem = {}
                    weItem.typeid = v.typeid
                    weItem.num = num
                    weItem.totalPower = weight*num
--                    table.insert(self._sortWeightList,weItem) --载重
                    sortWeightList:add(weItem)
                end
                local exter = _cuNum % num
                if exter ~= 0 then
                    item = {}
                    item.typeid = v.typeid
                    item.num = exter
                    item.totalPower = total*exter
--                    table.insert(self._sortFightList,item)
                    sortFightList:add(item)

                    weItem = {}
                    weItem.typeid = v.typeid
                    weItem.num = exter
                    weItem.totalPower = weight*exter
--                    table.insert(self._sortWeightList,weItem) --载重
                    sortWeightList:add(weItem)
                end
            else
                item = {}
                item.typeid = v.typeid
                item.num = v.num
                item.totalPower = total*v.num
--                table.insert(self._sortFightList,item)
                sortFightList:add(item)

                weItem = {}
                weItem.typeid = v.typeid
                weItem.num = v.num
                weItem.totalPower = weight*v.num
--                table.insert(self._sortWeightList,weItem)
                sortWeightList:add(weItem)
            end
        end
    end

    self._sortFightList = sortFightList:getList()
    self._sortWeightList = sortWeightList:getList()
    
--    table.sort(self._sortFightList, function (a,b) return (a.totalPower > b.totalPower) end)
--    table.sort(self._sortWeightList, function (a,b) return (a.totalPower > b.totalPower) end)

    print("=========setMaxFighAndWeight==========", os.clock() - time)

    -- for _,item in pairs(self._sortFightList) do
    --     logger:info("fight   id: %d  num: %d  fight: %d ",item.typeid,item.num,item.totalPower)
    -- end

    -- logger:info("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")

    -- for _,item in pairs(self._sortWeightList) do
    --     logger:info("weight   id: %d  num: %d  fight: %d ",item.typeid,item.num,item.totalPower)
    -- end


    self._maxWeightMap = {}
    local index = 1
    local item
    table.sort(openPos, function (a,b) return (a < b) end)
    for _,v in pairs(openPos) do
        if self._sortFightList[index] == nil then
            break
        end
        item = {}
        item = self._sortWeightList[index]
        item["post"] = v   --先就随机放坑了
        table.insert(self._maxWeightMap,item)
        index = index + 1
    end

    self:setMapFightAddEquip(adviserData)
end

function SoldierProxy:getAdviserCommand(data)
    local command = 0 --军师加的带兵量
    if table.size(data) == 0 then
        return 0
    end

    local config = ConfigDataManager:getInfoFindByTwoKey(ConfigData.CounsellorLvupConfig, "CounsellorID", data.typeId, "lv", data.lv)
    if config == nil then
        config = ConfigDataManager:getConfigById(ConfigData.CounsellorConfig, data.typeId)
    end

    if config == nil then
        logger:error("这个军师的typeId无法读表：%d", data.typeId)
        return 0
    end
    command = config.command
    return command
end

function SoldierProxy:setMapFightAddEquip(adviserData)   --最大战力加上英雄加成之后的

    self._firstOpen = true
    local proxy = self:getProxy(GameProxys.Role)
    local level = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)  --指挥官等级,算出几个坑是open的
    local openPos = self:getTroopsOpenPosList()

    local maxLen = table.size(self._sortFightList) > #openPos and #openPos or table.size(self._sortFightList)

    local alreadySolve = {}
    self._maxFightMap = {}

    
    local allPosFight = {}
    self._totalFirstNum = 0
    for i=1,#openPos do
        local v = openPos[i]
        local fightData = {}
        fightData.fight = self:getPosFight(v, adviserData)
        fightData.pos = v
        table.insert(allPosFight, fightData)
        local firstnum = self:getPosFirstNum(v)
        self._totalFirstNum = self._totalFirstNum + firstnum
    end



    local allSoldier = clone(self._sortFightList)
    --防止没兵的情况出现报错
    if table.size(allSoldier) > 0 and #openPos > 0 then

        table.sort( allPosFight, function(a, b) 
            return a.fight > b.fight 
        end)

        table.sort( allSoldier, function(a, b) 
            return a.totalPower > b.totalPower 
        end)

        for i=1,maxLen do
            allSoldier[i].post = allPosFight[i].pos
            table.insert(self._maxFightMap, allSoldier[i])
        end
    end
end

--计算一个槽位的战力，槽位的战力英雄的加成和宝具的加成
--军师直接传一个common.proto里面的一个军师数据过来，因为需要读表id和唯一id  {}也无所谓
--因为下面拿的时候会判空
function SoldierProxy:getPosFight(pos, adviserData)
    local heroProxy = self:getProxy(GameProxys.Hero)
    local heroFight = heroProxy:getHeroFight(pos, adviserData)
        
    local heroTreasureProxy = self:getProxy(GameProxys.HeroTreasure)
    local heroTreasureFight = heroTreasureProxy:getPosTreasureFight(pos, adviserData)
    
    local adviserProxy = self:getProxy(GameProxys.Consigliere)
    adviserData = adviserData or {}
    if rawget(adviserData, "id") == nil then
        adviserData.id = ""
    end
    local adviserFight = adviserProxy:getAdviserFight(adviserData.id)
    return (heroFight + heroTreasureFight + adviserFight)*0.7
end

--穿戴宝具有变化时，调用这个接口
function SoldierProxy:heroTreasureChange()
    self._isHeroTreasureChange = true
end

--宝具有变化时要重新计算先手值
function SoldierProxy:updateTotalFirstNum()
    local openPos = self:getTroopsOpenPosList()    
    self._totalFirstNum = 0
    for i=1,#openPos do
        local v = openPos[i]
        local firstnum = self:getPosFirstNum(v)
        self._totalFirstNum = self._totalFirstNum + firstnum
    end

    return self._totalFirstNum
end

--计算一个槽位的先手值，英雄的加成和宝具的加成
function SoldierProxy:getPosFirstNum(pos)
    local heroProxy = self:getProxy(GameProxys.Hero)
    local firstnum = heroProxy:getFirstnum(pos)

    local heroTreasureProxy = self:getProxy(GameProxys.HeroTreasure)
    local treasureFirstnum = heroTreasureProxy:getPosTreasureFirstNum(pos)

    return firstnum + treasureFirstnum
end

--获取总共的先手值 目前跟佣兵的属性无关
function SoldierProxy:getTotalFirstnum()
    if self._isHeroTreasureChange == false  then
        print("......... 宝具没变化 不用重新计算先手值....")
        return self._totalFirstNum
    end
    self._isHeroTreasureChange = false
    return self:updateTotalFirstNum()

    -- return self._totalFirstNum
end

--获得这个槽位上的总战力，   槽位本身的战力+兵的战力
--军师直接传一个common.proto里面的一个军师数据过来，因为需要读表id和唯一id  {}也无所谓
--因为下面拿的时候会判空
-- @isWithoutHero 是否计算英雄战力
function SoldierProxy:getPosAllFight(soldierInfo, adviserData, isWithoutHero)
    local heroProxy = self:getProxy(GameProxys.Hero)
    local heroFight = 0
    if isWithoutHero ~= true then
        heroFight = heroProxy:getHeroFight(soldierInfo.post, adviserData)
    end

    local soldierFight = 0
    if self._soldierFightAndWeight[soldierInfo.typeid] ~= nil then
        soldierFight = self._soldierFightAndWeight[soldierInfo.typeid].fight
    end

    local heroTreasureProxy = self:getProxy(GameProxys.HeroTreasure)
    local heroTreasureFight = heroTreasureProxy:getPosTreasureFight(soldierInfo.post, adviserData)

    local adviserProxy = self:getProxy(GameProxys.Consigliere)
    local adviserFight = adviserProxy:getAdviserFight(adviserData.id)

    return (heroFight + soldierFight*soldierInfo.num + heroTreasureFight + adviserFight)*0.7
end

-----------------一个坑位的属性------------
----------------pos具体的坑位
-------------adviserId军师ID，军师会加成到所有的坑位
function SoldierProxy:getPosAttr(item, pos, adviserId)
    local proxy = self:getProxy(GameProxys.Equip)
    local heroProxy = self:getProxy(GameProxys.Hero)

    --heroData不为nil 坑位上有英雄，否则不算英雄加成
    local heroData = heroProxy:getHeroInfoWithPos(pos)
    local heroAttrInfo = nil
    if heroData ~= nil then
        heroAttrInfo = heroProxy:getHeroAllAttr(heroData, true)
    end

    -- local attrEquipMap = proxy:onGetSixAttrByPos(pos)

    local typeid = item.typeid
    local oneSolider = self._soldierFightAndWeight[typeid]

    if oneSolider == nil then
        return 0
    end

    --这里要算出军的加成比

    local adviserPowerMap = {}
    adviserPowerMap[SoldierDefine.POWER_atkRate] = 0 --12
    adviserPowerMap[SoldierDefine.POWER_dodgeRate] = 0 --5
    adviserPowerMap[SoldierDefine.POWER_hpMaxRate] = 0 --11
    adviserPowerMap[SoldierDefine.POWER_hitRate] = 0  --4
    adviserPowerMap[SoldierDefine.POWER_critRate] = 0  --6
    adviserPowerMap[SoldierDefine.POWER_defRate] = 0  --7

    --{"血量", "命中", "暴击", "攻击", "闪避", "抗暴"}
    local heroPowerMap = {0,0,0,0,0,0}

    --军师对坑位的加成
    if adviserId ~= nil then
        local config = ConfigDataManager:getConfigById(ConfigData.CounsellorConfig, adviserId)
        if config ~= nil then
            local property = config.property
            local proList = StringUtils:jsonDecode(property)
            for _, proValue in pairs(proList) do
                adviserPowerMap[proValue[1]] = adviserPowerMap[proValue[1]] + proValue[2]
            end
        end
    end
    

    --英雄对坑位的加成
    if heroAttrInfo ~= nil then
        for k,v in pairs(heroAttrInfo) do
            heroPowerMap[k] = v.base
        end
    end

    local value = oneSolider.value
    local exterLen = oneSolider.exterLen
    local totalPower = 0

    totalPower =  totalPower + (value._target / 10000.0 + heroPowerMap[2] / 10000.0 + adviserPowerMap[SoldierDefine.POWER_hitRate] / 10000.0) * 100  --命中率
    totalPower =  totalPower + (value._escape / 10000.0 + heroPowerMap[5] / 10000.0 + adviserPowerMap[SoldierDefine.POWER_dodgeRate] / 10000.0) * 100  --闪避率
    totalPower =  totalPower + (value._heavyFight / 10000.0 + heroPowerMap[3] / 10000.0 + adviserPowerMap[SoldierDefine.POWER_critRate] / 10000.0 ) * 100 --暴击率
    totalPower =  totalPower + (value._Kbao /10000.0 + heroPowerMap[6] / 10000.0 + adviserPowerMap[SoldierDefine.POWER_defRate] / 10000.0) * 100  --抗暴率
    totalPower = totalPower + (value._attack + heroPowerMap[4]/100.0 + value._attack / (1 + value._atkPer /10000.0 ) * (adviserPowerMap[SoldierDefine.POWER_atkRate] / 10000.0))* 0.5 * value._soldierType  --+ value._atkAdd /10000.0
    totalPower = totalPower + (value._life + heroPowerMap[1]/100.0 + value._life / ( 1 + value._lifePer /10000.0 ) * ( adviserPowerMap[SoldierDefine.POWER_hpMaxRate] / 10000.0)) * 0.1    --+ value._lifeAdd /10000.0 (由于服务端已经加上了兵种判定，不需要再加）
    totalPower = totalPower + exterLen
    return totalPower
end

function SoldierProxy:getMaxFight()
    return self._maxFightMap
end

function SoldierProxy:getMaxWeight()
    return self._maxWeightMap
end

function SoldierProxy:getOneSoldierFightById(Id)  --根据佣兵的id得出一个佣兵的战力
    if self._soldierFightAndWeight[Id] == nil then
        return 0 
    end
    return self._soldierFightAndWeight[Id].fight
end

function SoldierProxy:getOneSoldierWeightById(Id) --根据佣兵的id得出一个佣兵的载重
    if self._soldierFightAndWeight[Id] == nil then
        return 0 
    end
    return self._soldierFightAndWeight[Id].weight
end

function SoldierProxy:getSoldierCountById(Id)  --根据佣兵的id，得到佣兵的数量
    if self._soldierTotalList[Id] == nil then
        return 0 
    end
    return self._soldierTotalList[Id].num
end

--获取模型ID
function SoldierProxy:getModelId(typeid)
    local info = ConfigDataManager:getInfoFindByOneKey(ConfigData.ArmKindsConfig,
        "ID", typeid)
    local realModelId = ConfigDataManager:getInfoFindByOneKey(
        ConfigData.ModelGroConfig,"ID",info.model).modelID
        
    return realModelId
end

function SoldierProxy:onBadSolidersListResp(data)
    self._badSoldierList = {}
    if data.rs == 0 then
        for _,v in pairs(data.soldiers) do
            self._badSoldierList[v.typeid] = v
        end
        self:updateRedPoint()
        self:sendNotification(AppEvent.BAD_SOLDIER_LIST_UPDATE, {})
    end
end

function SoldierProxy:getBadSoldiersList()
    return self._badSoldierList
end

function SoldierProxy:getSortCanProList(type)
    local proxy = self:getProxy(GameProxys.Building)
    local fightSort = {}
    local dataList = proxy:getCanProductIdList(type)
    if #dataList == 0 then
        return 
    end
    for _,v in pairs(dataList) do
        local fight = self:getOneSoldierFightById(v)
        local num = self:getSoldierCountById(v)
        table.insert(fightSort,{typeid = v,fight = fight,num = num})
    end
    table.sort(fightSort, function (a,b) return (a.fight > b.fight) end)
    return fightSort
end

function SoldierProxy:onShowEveryPosCount(list)
    local serverListData = self:getRealSoldierList()
    if table.size(serverListData) <= 0 then
        self:showSysMessage(TextWords[710])
        return
    end
    local listData = self:copyTab(serverListData)
    local exterList = {}
    for _ , v in pairs(list) do
        if v.num > 0 and v.typeid > 0 then
            if exterList[v.typeid] == nil then
                exterList[v.typeid] = v.num 
            else
                exterList[v.typeid] = exterList[v.typeid] + v.num
            end
        end
    end

    local config = ConfigDataManager:getConfigData("ArmKindsConfig")
    local realData = {}
    if table.size(exterList) > 0 then
        for key,v in pairs(exterList) do
            if listData[key] ~= nil then
                listData[key].num  = listData[key].num - v
            end
        end
        
        for _,v in pairs(listData) do
            if v.num > 0 then
                v["sort"] = config[v.typeid].sort
                table.insert(realData,v)
            end
        end
    else
        for _,v in pairs(listData) do
            v["sort"] = config[v.typeid].sort
        end
        realData = TableUtils:map2list(listData)
        --realData = listData
    end
    
    if table.size(realData) <= 0 then
        self:showSysMessage(TextWords[710])
        return
    end
    table.sort( realData, function(a,b) return a.sort < b.sort end)
    return realData
end

function SoldierProxy:copyTab(st)  --lua的深拷贝
    local tab = {}
    for k, v in pairs(st or {}) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = self:copyTab(v)
        end
    end
    return tab
end


--------------------------
function SoldierProxy:showSoldierInfo(panel, typeid)
    local soldier = self:getSoldier(typeid)

    if self._uiSoldierInfo == nil then
        local parent = panel:getLayer(ModuleLayer.UI_TOP_LAYER)
        self._uiSoldierInfo = UISoldierInfo.new(parent, self)
    end
    self._uiSoldierInfo:updateSoldierInfo(typeid, soldier)
end
--UIIcon的tips专用的显示兵种信息（纯读表）
function SoldierProxy:showSoldierInfoFromConfigData(panel, typeid)
    if self._uiSoldierInfo == nil then
        local parent = panel:getLayer(GameLayer.topLayer)
        self._uiSoldierInfo = UISoldierInfo.new(parent, self)
    end
    self._uiSoldierInfo:updateSoldierInfoFromConfigData(typeid)
end

function SoldierProxy:onUpdateTaskTeamInfoResp(data)
    if #data.list == 0 then
        self:setTaskTeamInfo()
        return
    end
    for _, teamInfo in pairs(data.list) do
        self._taskTeamInfoMap[teamInfo.id] = teamInfo
        self:setTaskTeamInfo(teamInfo)
    end
end

function SoldierProxy:setTaskTeamInfo(taskTeamInfo)
--    local currentData = self:getTaskTeamInfo()
--    for _, data in pairs(currentData) do
    if taskTeamInfo ~= nil then
        local key = "teamTask"..taskTeamInfo.id
        local remainTime = taskTeamInfo.totalTime - taskTeamInfo.alreadyTime
        if taskTeamInfo.type == 3 then
            -- local plusData = self:getPlusDataIdAndPost(taskTeamInfo.id, taskTeamInfo.post)
            remainTime = remainTime / taskTeamInfo.product-- / (1 + plusData.allPlus*0.01)
        end
        self:pushRemainTime(key, remainTime)
    end
--    end
    
    -- 请求驻防队伍
    self:onTriggerNet80019Req()


    self:sendNotification(AppEvent.TASK_TEAM_INFO_UPDATE, {})
    self:updateRedPoint()
end

-- 设置驻防队伍
function SoldierProxy:setTeamGarrisonState(teamId)    
    self._garrisonTeamId = teamId
    for k, v in pairs(self._taskTeamInfoMap) do
        if v.id == self._garrisonTeamId then
            v.state = SoldierProxy.GARRISON_STATE_YES
        else
            v.state = SoldierProxy.GARRISON_STATE_NO
        end
    end
    self:sendNotification(AppEvent.TASK_TEAM_INFO_UPDATE, {})
end

function SoldierProxy:getTaskTeamInfo()
    local data = TableUtils:map2list( self._taskTeamInfoMap ) --clone(self._taskTeamInfo)
    return data
end

function SoldierProxy:getSelfTaskTeamInfo()
    local list = {}
    for _, teamInfo in pairs(self._taskTeamInfoMap) do
        if teamInfo.type ~= 6 then
            table.insert(list, teamInfo)
        end
    end
    
    return list
end

------
-- 获取驻军的相关信息
function SoldierProxy:getBeStationInfo()
    local list = {}
    for _, teamInfo in pairs(self._taskTeamInfoMap) do
        if teamInfo.type == 6 then -- 类型6
            table.insert(list, teamInfo)
        end
    end
    return list
end


function SoldierProxy:onTriggerNet80004Req(data)
    self:syncNetReq(AppEvent.NET_M8, AppEvent.NET_M8_C80004, data)
end

function SoldierProxy:onTriggerNet80004Resp(data)
--    self:onTriggerNet80103Resp(data)
end

function SoldierProxy:onTriggerNet80103Req(data)
    self:syncNetReq(AppEvent.NET_M8, AppEvent.NET_M8_C80103, data)
end

function SoldierProxy:onTriggerNet80103Resp(data)
    if data.rs == 0 then
        self._taskTeamInfoMap[data.id] = nil
        local key = "teamTask"..data.id
        self:pushRemainTime(key, 0)
        self:setTaskTeamInfo()
    end
end

function SoldierProxy:onTriggerNet80104Req(data)
    self:syncNetReq(AppEvent.NET_M8, AppEvent.NET_M8_C80104, data)
end

function SoldierProxy:onTriggerNet80104Resp(data)
    if data.rs == 0 then
        self._taskTeamInfoMap[data.taskTeamInfo.id] = data.taskTeamInfo
        self:setTaskTeamInfo(data.taskTeamInfo)
    end
end

function SoldierProxy:onTriggerNet80007Req(data)
    self:syncNetReq(AppEvent.NET_M8, AppEvent.NET_M8_C80007, data)
end

function SoldierProxy:onTriggerNet80007Resp(data) -- 废弃的消息号，服务端不下发了
    self.beAttactionData = {}
    for _, info in pairs(data) do
        self.beAttactionData[info.key] = info
    end
    self:setTeamBeStation()
end

------
-- 获取敌袭数据
function SoldierProxy:getAttactionData()
    local data = self.beAttactionData or {}
    local list = TableUtils:map2list(data)
    return list
end

------
-- 是否有敌人来袭
function SoldierProxy:hadBeingAttacked()
    local count = 0

    local data = self.beAttactionData or {} 
    for key, value in pairs(data) do
        if self._attackOldMap[key] == nil then
            self._attackOldMap[key] = value
            count = count + 1
        end
    end

    if #self:getAttactionData() == 0 then
        self._attackOldMap = {}
    end

    return count ~= 0
end

------
-- 获取离线状态受过的攻击次数
function SoldierProxy:getQuitAttackTimes()
    return self._attackTimes
end

function SoldierProxy:setQuitAttackTimes(times)
    self._attackTimes = times
end


function SoldierProxy:onTriggerNet80107Req(data)
    self:syncNetReq(AppEvent.NET_M8, AppEvent.NET_M8_C80107, data)
end

function SoldierProxy:onTriggerNet80107Resp(data)
    if data.rs == 0 then
        self.beAttactionData[data.key] = nil
        local key = "teamBeAttactionTask"..data.key
        self:pushRemainTime(key, 0)
    elseif data.rs == 1 then
        self.beAttactionData = {}
    end
    self:setTeamBeStation()
end

function SoldierProxy:onTriggerNet80108Req(data)
    self:syncNetReq(AppEvent.NET_M8, AppEvent.NET_M8_C80108, data)
end

function SoldierProxy:onTriggerNet80108Resp(data)
    for _, info in pairs(data.infos) do
        self.beAttactionData[info.key] = info
    end
    self:setTeamBeStation()
end

------
-- 请求撤军80017
function SoldierProxy:onTriggerNet80017Req(data)
    self:syncNetReq(AppEvent.NET_M8, AppEvent.NET_M8_C80017, data)
end

------
-- 请求撤军返回
function SoldierProxy:onTriggerNet80017Resp(data)
    if data.rs ~= 0 then
        return 
    end

    local id = data.id
    if self._taskTeamInfoMap[id] ~= nil then
        self._taskTeamInfoMap[id].type = 2  -- //1.进攻,2返回，3挖掘,4 出发驻防 
    end

    self:setTaskTeamInfo()
end

------
-- 首次攻打世界玩家成功推送
function SoldierProxy:onTriggerNet80018Resp(data)
    if data.rs ~= 0 then
        return 
    end
    self._attackPlayerTimes = data.times
    self:sendNotification(AppEvent.ATTACK_TIMES_UPDATE, {})
end

------
-- 请求驻防队伍
function SoldierProxy:onTriggerNet80019Req(data)
    self:syncNetReq(AppEvent.NET_M8, AppEvent.NET_M8_C80019, {})
end
function SoldierProxy:onTriggerNet80019Resp(data)
    if data.rs ~= 0 then
        return 
    end
    self:setTeamGarrisonState(data.id)
end

-- 获得攻打世界玩家次数
function SoldierProxy:getAttackPlayerTimes()
    return self._attackPlayerTimes
end


function SoldierProxy:setTeamBeStation()
    for _, data in pairs(self.beAttactionData) do
        local key = "teamBeAttactionTask"..data.key
        local remainTime = data.time
        local oldTime = self:getRemainTime(key)
        if oldTime > 0 then
            if remainTime > oldTime then
                remainTime = oldTime
            end
        end
        self:pushRemainTime(key, remainTime)
    end
    self:sendNotification(AppEvent.PROXY_TEAM_BEATTACTION, data)
end

--小红点更新
function SoldierProxy:updateRedPoint()
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:checkTeamRedPoint() 
end

function SoldierProxy:clearAllList() --清除所有任务队列
    local currentList = self:getTaskTeamInfo()
    for _, data in pairs(currentList) do
        local key = "teamTask"..data.id
        self:pushRemainTime(key, 0)
    end
    for _, data in pairs(self.beAttactionData) do
        local key = "teamBeAttactionTask"..data.key
        self:pushRemainTime(key, 0)
    end
    self._taskTeamInfoMap = {}
    self.beAttactionData = {}
    self:sendNotification(AppEvent.PROXY_TEAM_BEATTACTION, data)
    self:sendNotification(AppEvent.TASK_TEAM_INFO_UPDATE, {})
    self:updateRedPoint()
end



---------------防守 套用 演武场的阵型计算-----------------------------
function SoldierProxy:onSetTeamResp1(data)  --type 1:模板套用阵型 2：部队防守阵形 3：竞技场阵型 6 pve攻击阵形
    if data.rs == 0 then
        for _,v in pairs(data.info) do
            self:onJudgePowerCommond(v.members)
            self._teamInfo[v.type] = v
            --复制一份防守阵型的数据
            if v.type == 2 then
                self.defSoldierInfo = clone(v)
            end
            if v.type == 6 then
                self.pveSoldierInfo = clone(v)
            end
        end
        local teamData = {}
        for i=1,6 do
            teamData[i] = {}
            teamData[i].typeid = 0
            teamData[i].post = i
            teamData[i].num = 0
        end
        self._teamInfo[2] = self._teamInfo[2] or {type = 2, members = teamData}
        self._teamInfo[3] = self._teamInfo[3] or {type = 3, members = teamData}
        self._teamInfo[6] = self._teamInfo[6] or {type = 6, members = teamData}

    end
    self:setCheckExample()
end

-------------------------------------------------------------------------------pve start
--主城兵少了，更新PVE阵型的兵  -- 6 pve攻击阵形
function SoldierProxy:updatePveTeamInfo()
    -- logger:info("--主城兵少了，更新PVE阵型的兵 ")
    if self.pveSoldierInfo == nil or self.pveSoldierInfo.members == nil then
        local teamData = {}
        for i=1,6 do
            teamData[i] = {}
            teamData[i].typeid = 0
            teamData[i].post = i
            teamData[i].num = 0
        end
        self._teamInfo[6] = {type = 6, members = teamData}
        self.pveSoldierInfo = clone(self._teamInfo[6])  --单独一份，更新数量时候用到
        logger:error("--主城兵少了，根本就没有PVE阵型的兵 ")
        return
    end
    
    local pveTeamInfo = self._teamInfo[6].members

    local soldierNums = {}
    for k,v in pairs(self.pveSoldierInfo.members) do
        if v.typeid ~= 0 and v.post ~= 9 then
            local soldier = self:getSoldier(v.typeid)
            local haveSoldier = 0
            if soldier ~= nil then
                haveSoldier = soldier.num
            end
            if soldierNums[v.typeid] == nil then
                soldierNums[v.typeid] = haveSoldier
            end
        end
    end

    for k,v in pairs(self.pveSoldierInfo.members) do
        local haveSoldier = 0
        --v.post = 9 是军师
        if v.typeid ~= 0 and v.post ~= 9 then
            --获取兵的数量
            haveSoldier = soldierNums[v.typeid]
            for key,info in pairs(pveTeamInfo) do
                if info.post == v.post then
                    --这个肯定能找到的  因为self.pveSoldierInfo.members是pveTeamInfo克隆出来的一份数据
                    pveTeamInfo[key].num = v.num > haveSoldier and haveSoldier or v.num
                    soldierNums[v.typeid] = soldierNums[v.typeid] - pveTeamInfo[key].num
                    soldierNums[v.typeid] = soldierNums[v.typeid] > 0 and soldierNums[v.typeid] or 0
                    break
                end
            end
        end
    end

    self._teamInfo[6].members = pveTeamInfo
end

-- 校验阵型的军师是否可上阵
-- @ origionTeam = 输入拷贝的阵型数据，避免修改到原数据
-- @ targetTeam = 输入当前阵型数据
-- @ adviserT = 返回军师数据
-- @ isCopyTeam = 是否是套用阵型
function SoldierProxy:checkTeamAdviser(origionTeam, targetTeam, isCopyTeam)
    if origionTeam == nil or targetTeam == nil then
        logger:info("--校验阵型的军师是否可上阵 数据有误！")
        return
    end

    local proxy = self:getProxy(GameProxys.Consigliere)
    
    local adviserT = nil
    local adviserP = nil

    for k,v in pairs(targetTeam) do
        if v.post == 9 then
            adviserT = v
            break
        end
    end
    for k,v in pairs(origionTeam) do
        if v.typeid ~= 0 and v.post == 9 then
            adviserP = v
            break
        end
    end

    if adviserP ~= nil then
        local conf = proxy:getDataById( adviserP.typeid )
        if conf == nil then --已遣散军师 要排除
            logger:info("--已遣散军师 要排除")
            adviserT.typeid = 0
            adviserT.num = 0
            adviserT.adviserId= StringUtils:int32ToFixed64(0)
        else
            local infos = proxy:getInfosByTypeId(adviserP.typeid)
            if infos == nil then  --已遣散军师 要排除
                logger:info("--已遣散军师 要排除")
                adviserT.typeid = 0
                adviserT.num = 0
                adviserT.adviserId= StringUtils:int32ToFixed64(0)
            else

                local function check(infolist)
                    for k,v in pairs(infolist) do
                        logger:info("== 同类型军师 %d %d %d==",v.pos,v.lv,adviserP.adviserLv)
                        if v.pos == 0 and v.lv == adviserP.adviserLv then
                            return v.id
                        end
                    end
                    return nil
                end

                adviserP.adviserLv = adviserP.adviserLv or 0
                -- local newAdviserId = check(infos)

                local newAdviserId = nil
                if isCopyTeam ~= nil then
                    local adviserInfo = proxy:getInfoById(adviserP.adviserId)
                    if adviserInfo ~= nil and adviserInfo.pos == 0 then
                        logger:info("=== 套用阵型，还原军师id ===")
                        newAdviserId = adviserP.adviserId
                    end
                else
                    newAdviserId = check(infos)                    
                end


                if newAdviserId == nil then  --内政军师/已出战军师 要排除
                    logger:info("--内政军师/已出战军师 要排除")
                    adviserT.typeid = 0
                    adviserT.num = 0
                    adviserT.adviserId= StringUtils:int32ToFixed64(0)
                else
                    logger:info("--还原军师 000000000000 ")
                    adviserT.typeid = adviserP.typeid
                    adviserT.num = adviserP.num
                    adviserT.adviserId = newAdviserId
                end
            end
        end
        -- targetData[9] = adviserT
    end
    return adviserT
end


--出战重置pve攻击阵形
function SoldierProxy:setPveTeamInfo(data)
    self._teamInfo[6].members = data
    self.pveSoldierInfo.members = clone(data)
end

-- 获取pve阵型信息
function SoldierProxy:getPveTeamInfo()
    local adviser = self:checkTeamAdviser(clone(self.pveSoldierInfo.members), self._teamInfo[6].members)
    if adviser ~= nil then
        self._teamInfo[6].members[9] = adviser
    end
    self._teamInfo[6].members = self:setSolderCount(self._teamInfo[6].members)
    return self._teamInfo[6]
end

--校验下当前上阵的带兵数量，确保不超过每个坑位的带兵量上限
function SoldierProxy:setSolderCount(members)  
    local roleProxy = self:getProxy(GameProxys.Role)
    local consiProxy = self:getProxy(GameProxys.Consigliere)

    local count = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)  --每个坑位的带兵量(已包含武将)
    local consuId = nil
    for k,v in pairs(members) do
        if v.post == 9 and v.num > 0 then
            consuId = rawget(v,"adviserId")
            local adviserData = consiProxy:getInfoById(consuId)
            if adviserData ~= nil then
                local adviserCommand = self:getAdviserCommand(adviserData)
                count = adviserCommand + count
            end
            break
        end
    end

    for k,v in pairs(members) do
        if v.post ~= 9 and v.num > count then
            members[k].num = count
        end
    end
    return members
end


--是否为pve攻击阵形
function SoldierProxy:isPve(fightType)
    -- --战斗类型
    -- GameConfig.battleType = {}
    -- GameConfig.battleType.level = 1 --战役
    -- GameConfig.battleType.explore = 2 --探险
    -- GameConfig.battleType.world = 4 --世界战斗(前端布阵界面显示类型是0)
    -- GameConfig.battleType.world_def = 5 --世界战斗防守
    -- GameConfig.battleType.legion = 6 --军团试炼场
    -- GameConfig.battleType.world_boss = 7 --世界Boss
    -- GameConfig.battleType.qunxiong = 8 --群雄逐鹿
    -- GameConfig.battleType.kill = 9 --剿匪
    -- GameConfig.battleType.west = 10 --西域远征  
    -- GameConfig.battleType.rebels = 14 --消灭叛军

    -- 布阵界面类型
    local uiType = {}
    uiType.world = 0 --世界战斗(玩家、矿)

    -- logger:info(" 战斗类型 %d",fightType)
    if fightType ~= nil then
        if fightType == GameConfig.battleType.level
            or fightType == GameConfig.battleType.explore
            or fightType == GameConfig.battleType.kill
            or fightType == GameConfig.battleType.west
            or fightType == GameConfig.battleType.rebels
            or fightType == GameConfig.battleType.emperor_city
            or fightType == uiType.world then
            return true
        end
    end

    return false
end

-- 出战更新pve阵型
function SoldierProxy:onFightUpdatePveTeam(data)
    if self:isPve(data.type) == true then
        self:setPveTeamInfo(data.infos)
    end
end
-------------------------------------------------------------------------------pve end

-- 讨伐物资 上次阵型 设置
function SoldierProxy:setWorldBossTeam(data)
    self._teamInfo[4] = {}
    self._teamInfo[4].members = data
end

-- 讨伐物资 上次阵型 重置
function SoldierProxy:resetWorldBossTeam()
    self._teamInfo[4].members = self._teamInfo[4].members or {}
    for k,v in pairs(self._teamInfo[4].members) do
        self._teamInfo[4].members[k].num = 0
        rawset(self._teamInfo[4].members[k], "adviserId", nil)
    end
end
  
-- 城主战 上次阵型 读取
function SoldierProxy:getLordCityAttackTeam()
    local team = LocalDBManager:getValueForKey("lordcity_attack_team", false, nil)    
    team = StringUtils:unserialize(team)
    return team
end

-- 城主战 上次阵型 设置
function SoldierProxy:setLordCityAttackTeam(data)
    -- self._teamInfo[5] = {}
    -- self._teamInfo[5].members = data

    data = StringUtils:serialize(data)
    LocalDBManager:setValueForKey("lordcity_attack_team", data, false)
end

-- 城主战 上次阵型 重置
function SoldierProxy:resetLordCityAttackTeam()
    -- self._teamInfo[5].members = self._teamInfo[5].members or {}
    -- for k,v in pairs(self._teamInfo[5].members) do
    --     self._teamInfo[5].members[k].num = 0
    --     rawset(self._teamInfo[5].members[k], "adviserId", nil)
    -- end
    LocalDBManager:setValueForKey("lordcity_attack_team", nil, false)
end

-- 是否要清除城主战的上次阵型
function SoldierProxy:isNeedResetAttackTeam()
    local team = self:getLordCityAttackTeam()
    if team then
        return true
    end
    return false
end

function SoldierProxy:onSetTeamResp(data)  --type 1:模板套用阵型 2：部队防守阵形 3：竞技场阵型 6 pve攻击阵形
    if data.rs == 0 then
        for _,v in pairs(data.info) do
            self:onJudgePowerCommond(v.members)
            self._teamInfo[v.type] = v
            if v.type == 2 then
                self.defSoldierInfo = clone(v)
            end
            -- if v.type == 6 then
            --     self.pveSoldierInfo = clone(v)
            -- end

            -- local teamData = {}
            -- for i=1,6 do
            --     teamData[i] = {}
            --     teamData[i].typeid = 0
            --     teamData[i].post = i
            --     teamData[i].num = 0
            -- end
            -- self._teamInfo[6] = self._teamInfo[6] or {type = 6, members = teamData}

        end
        self:showSysMessage(TextWords:getTextWord(785))
    end
    self:setCheckExample()
end

--最大带兵量，要算上军师的带兵量
function SoldierProxy:onJudgePowerCommond(data)   --为了防止玩家的繁荣度下降之后，带兵量减少
    
    local consuId = nil
    for k,v in pairs(data) do
        if v.post == 9 then
            consuId = rawget(v, "adviserId")
            break
        end
    end
    local command = 0
    if consuId ~= nil then
        local adviserProxy = self:getProxy(GameProxys.Consigliere)
        local adviserData = adviserProxy:getInfoById(consuId)
        command = self:getAdviserCommand(adviserData or {})
    end
    local roleProxy = self:getProxy(GameProxys.Role)
    local maxSoldierCount = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command) + command
    for _,v in pairs(data) do
        if v.num > maxSoldierCount then
            v.num = maxSoldierCount
        end
    end
end

function SoldierProxy:onGetTeamInfo()
    return self._teamInfo
end

function SoldierProxy:setCheckExample(outMembers)  --检查阵型的正确性
    local members
    if outMembers == nil then  
        if self._teamInfo[1] == nil then
            return
        end
        members = self._teamInfo[1].members --套用阵型的数据
    else
        members = outMembers  --挂机的时候
    end
    local soldierList = self:getRealSoldierList()  --得到玩家全部佣兵，不包含数量为0

    local consuData  --军师
    for _,v in pairs(members) do
        if v.post == 9 or v.post == 19 then
            consuData = v
            break
        end
    end

    table.sort(members, function (a,b) return (a.post < b.post) end)  --6个槽位全部从1,2,3,4,5,6排序
    local exterList = {}
    local checkData = {}
    for _,v in pairs(members) do  --校验阵型数据，找出6个槽位上面如果是相同typeid的槽位，数量相加,放到一起
        if v.num > 0 and v.typeid > 0 then
            if exterList[v.typeid] == nil then
                exterList[v.typeid] = {}
                exterList[v.typeid].totalNum = 0
                exterList[v.typeid].items = {}
            end
            exterList[v.typeid].totalNum = exterList[v.typeid].totalNum + v.num
            table.insert(exterList[v.typeid].items,{post = v.post,num = v.num})
        else
            table.insert(checkData,v)
        end
    end

    for key,v in pairs(exterList) do  --将6个槽位上面的typeid的数据和玩家拥有的佣兵进行比较
        if soldierList[key] == nil then
            for _,child in pairs(v.items) do
                child.num = 0
            end
        else
            if v.totalNum > soldierList[key].num then  --如果某一个typeid的数量大于真实数据
                v.totalNum = soldierList[key].num
                for _,child in pairs(v.items) do   --将typeid真实数量依次分到typeid相同的槽位上去
                    if v.totalNum >= child.num then
                        v.totalNum = v.totalNum - child.num
                    else
                        child.num = v.totalNum
                        v.totalNum = 0
                    end
                end
            end
        end
    end

    for fkey,fv in pairs(exterList) do  --将集合中的各个槽位的数量再次校验一下
        for ckey,cv in pairs(fv.items) do
            local item = {}
            item.typeid = fkey
            item.post = cv.post
            item.num = cv.num
            if cv.num < 0 then
                item.num = 0
            end
            table.insert(checkData,item)
        end
    end
    ---------tudo: 繁荣度下降后，带兵量上限要及时修改-----------
    self:onJudgePowerCommond(checkData)

    ------tudo:军师数据检查------------
    for index,v in pairs(checkData) do
        if v.post == 9 or v.post == 19 then
            table.remove(checkData,index)
            break
        end
    end
    
    if consuData then
        local proxy = self:getProxy(GameProxys.Consigliere)
        local data = proxy:getInfoById(consuData.adviserId)
        if data then
            table.insert(checkData,consuData)
        end
    end

    if outMembers == nil then
        self._checkProtectPos = checkData
    end

    return checkData
end

function SoldierProxy:getCheckData()
    return self._checkProtectPos
end

function SoldierProxy:onTriggerNet70001Resp(data)
    self:onSetTeamResp(data)
end

function SoldierProxy:onTriggerNet70001Req(data)
    if data.info.type == nil then
        logger:error("请求保存阵型数据有误：type字段不能为nil。\n %s",debug.traceback())
        return
    end
    
    if data.info.type == 3 then
        self.curFight = data.formationCapacity
    end
    self:syncNetReq(AppEvent.NET_M7, AppEvent.NET_M7_C70001, data)
end

function SoldierProxy:getArenaTeamFight()
    return self.curFight
end

function SoldierProxy:onTriggerNet70002Resp(data)
    if data.rs == 0 then
        self:showSysMessage(TextWords:getTextWord(785))
        if data.info ~= nil then
            self._applyTeamInfo[data.info.type] = data.info
        end
        self._applyTeamInfoClone = clone(self._applyTeamInfo)
        self:sendNotification(AppEvent.PROXY_SETTEAM_UPDATE)
    end
end

function SoldierProxy:onTriggerNet70003Resp(data)
    if data.rs == 0 then
        self:showSysMessage(TextWords:getTextWord(783))
        if self._data70003 ~= nil then
            self._applyTeamInfo[self._data70003.type].name = self._data70003.name
        end
        self._applyTeamInfoClone = clone(self._applyTeamInfo)
        -- self:sendNotification(AppEvent.PROXY_SETTEAM_UPDATE)
    end
end

function SoldierProxy:onTriggerNet70002Req(data)
    self:syncNetReq(AppEvent.NET_M7, AppEvent.NET_M7_C70002, data)
end

function SoldierProxy:onTriggerNet70003Req(data)
    self._data70003 = data
    self:syncNetReq(AppEvent.NET_M7, AppEvent.NET_M7_C70003, data)
    -- self:onTriggerNet70003Resp({rs = 0})  --测试
end

------
-- 获取队列表信息的总个数
function SoldierProxy:getQueueWorkCount()
    local marchData = self:getSelfTaskTeamInfo()
    local helpData = self:getBeStationInfo()
    local enemyAttackData = self:getAttactionData()
    local workCount = #marchData + #helpData + #enemyAttackData
    return workCount or 0
end

------
-- 获得当前vip等级下的出战队伍上限
function SoldierProxy:getTroopCount()
    local roleProxy = self:getProxy(GameProxys.Role)
    local vipLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel) or 0
    local keyID = vipLevel +1
    local nowVipdData = ConfigDataManager:getConfigById(ConfigData.VipDataConfig, keyID)
    local troopCount = nowVipdData.troopCount
    return troopCount
end

------
-- 获得当前出战队伍数量
function SoldierProxy:getMarchCount()
    local marchData = self:getSelfTaskTeamInfo()
    return #marchData
end

------
-- 设置世界出战数据
-- @传入：function TeamModule:onOpenModule(extraMsg)
function SoldierProxy:setWorldAttackData(worldAttackData)
    self._worldAttackData = worldAttackData
end

------
-- 判断出战地点是否为同盟占据点
function SoldierProxy:isTeammateRes()
    local state = false
    if self._worldAttackData ~= nil then
        local targetLegionName = self._worldAttackData.legionName
        local myLegionName     = self:getProxy(GameProxys.Role):getLegionName()
        if targetLegionName == myLegionName and myLegionName ~= "" then
            -- 判断出战地点是否为自己的队列
            --local isMineRes = self:isMineRes(self._worldAttackData.tileX, self._worldAttackData.tileY)
       
            --if isMineRes == false then
                state = true
            --end
            
        end
    end
    return state
end

------
-- 判断出战地点是否为自己的队列
function SoldierProxy:isMineRes(tX, tY)
    local state = false
    local marchData = self:getSelfTaskTeamInfo()
    for k, v in pairs(marchData) do
        if v.x == tX and v.y == tY then
            state = true
        end
    end
    return state
end

------
-- 判断世界出战是否满队列
function SoldierProxy:isFightButMaxMarchCount()
    local state = false
    if self._worldAttackData ~= nil then
        if self:getTroopCount() == self:getMarchCount() then
            state = true
        end
    end
    return state
end

--主城废墟之后随机迁移主城
function SoldierProxy:onTriggerNet80020Resp(data)
    self:showSysMessage(TextWords:getTextWord(370))
    self:onChangeHomeAddress(data)

    -- 刷新来袭队列
    self:clearAttackList()
end

function SoldierProxy:onChangeHomeAddress(recData)
    local data = {}
    data.moduleName = ModuleName.MapModule
    data.extraMsg = {}
    data.extraMsg.tileX = recData.x
    data.extraMsg.tileY = recData.y
    
    --世界可见，则直接搬家刷新坐标显示
    local isShow = self:isModuleShow(ModuleName.MapModule)
    if isShow == true then
        self._newHomeAddress = nil
        self:gotoNewHome(data)
        return
    end

    -- 世界不可见，则根据实际跳转到世界的情况来决定是否搬家刷新
    self._newHomeAddress = data
end

-- 获取新家的地址
function SoldierProxy:getNewHomeAddress()
    return self._newHomeAddress
end

-- 搬到新家
function SoldierProxy:gotoNewHome(data)
    local itemProxy = self:getProxy(GameProxys.Item)
    itemProxy:sendNotification(AppEvent.PROXY_BAG_OPENMAP, data)
end


-- 随机搬家之后清空来袭列表
function SoldierProxy:clearAttackList()
    for _, data in pairs(self.beAttactionData) do
        local key = "teamBeAttactionTask"..data.key
        self:pushRemainTime(key, 0)
    end


    self.beAttactionData = {}

    -- 刷新来袭列表
    self:sendNotification(AppEvent.PROXY_TEAM_BEATTACTION, {})
end     
