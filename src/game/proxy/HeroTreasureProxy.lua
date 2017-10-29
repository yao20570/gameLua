-- /**
--  * @Author:	  lizhuojian
--  * @DateTime:	2016-10-12
--  * @Description: 宝具数据代理
--  */

HeroTreasureProxy = class("HeroTreasureProxy", BasicProxy)

function HeroTreasureProxy:ctor()
    HeroTreasureProxy.super.ctor(self)
    self.proxyName = GameProxys.HeroTreasure
    --所有宝具信息 M20000 M20007
    self._allTreasureInfos = {}
    --所有宝具碎片信息 M20000 M20007
    self._allTreasurePieceInfos = {}  
    --6个槽位上宝具槽位的信息（宝具槽位现在挂在出战部队槽位上）
    self._allPostInfos = {}  
end
-- 初始化活动数据 M20000
function HeroTreasureProxy:initSyncData(data)
    HeroTreasureProxy.super.initSyncData(self, data)
    --data = self.M20000
    local treasureInfos = data.treasureInfos
    local treasurePieceInfos = data.treasurePieceInfos
    local bastPostInfos = data.bastPostInfos
    if bastPostInfos and #bastPostInfos > 0 then
        self:updatePostInfos(bastPostInfos)
    end
    if treasureInfos and #treasureInfos > 0 then
        self:updateTreasureInfo(treasureInfos)
    end
    if treasurePieceInfos and #treasurePieceInfos > 0 then
        self:updateTreasurePieceInfo(treasurePieceInfos)
    end

    self.heroProxy = self:getProxy(GameProxys.Hero)

 
end

function HeroTreasureProxy:afterInitSyncData()

end
--20007更新宝具信息
function HeroTreasureProxy:updateTreasureInfo(data)
    if data then
        for k,v in pairs(data) do
            --删除数据某一条数据
            if v.typeid == -1 then
                self._allTreasureInfos[v.id] = nil
            else
            --添加或者刷新数据
                local config = ConfigDataManager:getConfigById(ConfigData.TreasureBaseConfig, v.typeid)
                v.part = config.part
                v.color = config.color
                self._allTreasureInfos[v.id] = v
            end 

        end
        self.heroProxy = self:getProxy(GameProxys.Hero)
        self:sendNotification(AppEvent.PROXY_TREASURE_UPDATE_INFO)    
        self:isChangeFirstNum()
    end

end
--20007更新宝具碎片信息
function HeroTreasureProxy:updateTreasurePieceInfo(data)
    for k,v in pairs(data) do
        if v.num == -1 then
           self._allTreasurePieceInfos[v.typeid] = nil
        else
           self._allTreasurePieceInfos[v.typeid] = v
        end	
	end
    self:sendNotification(AppEvent.PROXY_TREASURE_PIECE_UPDATE_INFO) 
end
--更新槽位信息
function HeroTreasureProxy:updatePostInfos(data)
        
    for k,v in pairs(data) do
        self._allPostInfos[v.postId] = v
    end
    self:sendNotification(AppEvent.PROXY_TREASURE_POSTINFOS_UPDATE) 
end



function HeroTreasureProxy:resetAttr()
    self._treasureInfos = {}
    self._treasurePieceInfos = {}   
end
function HeroTreasureProxy:resetCountSyncData()

    for k,v in pairs(self._allPostInfos) do
        for key,val in pairs(self._allPostInfos[k].treasurePostWishInfo) do
            self._allPostInfos[k].treasurePostWishInfo[key].wish = 0
        end
    end
    self:sendNotification(AppEvent.PROXY_TREASURE_POSTINFOS_UPDATE) 

end

function HeroTreasureProxy:registerNetEvents()

end

function HeroTreasureProxy:unregisterNetEvents()

end
--宝具穿戴（穿上，卸下，更换）
function HeroTreasureProxy:onTriggerNet350000Req(data)
    self.curPostId = data.postId
	self:syncNetReq(AppEvent.NET_M35, AppEvent.NET_M35_C350000, data)
end

function HeroTreasureProxy:onTriggerNet350000Resp(data)
	if data.rs == 0 then
    	if self.curPostId == 0 then
			self:showSysMessage(TextWords:getTextWord(3817))
		else
			self:showSysMessage(TextWords:getTextWord(3818))
		end
        self:sendNotification(AppEvent.PROXY_TREASURE_PUT)
	end
end
--宝具洗练
function HeroTreasureProxy:onTriggerNet350001Req(data)
	self:syncNetReq(AppEvent.NET_M35, AppEvent.NET_M35_C350001, data)
end

function HeroTreasureProxy:onTriggerNet350001Resp(data)
	if data.rs == 0 then
		--self:showSysMessage("洗炼成功！")
        self:sendNotification(AppEvent.PROXY_TREASURE_PURIFY_SUCCESS)
	end

end
--宝具洗练属性恢复
function HeroTreasureProxy:onTriggerNet350002Req(data)
	self:syncNetReq(AppEvent.NET_M35, AppEvent.NET_M35_C350002, data)
end

function HeroTreasureProxy:onTriggerNet350002Resp(data)
	if data.rs == 0 then
		self:showSysMessage(TextWords:getTextWord(3819))
	end
end
--宝具分解
function HeroTreasureProxy:onTriggerNet350003Req(data)
	self:syncNetReq(AppEvent.NET_M35, AppEvent.NET_M35_C350003, data)
end

function HeroTreasureProxy:onTriggerNet350003Resp(data)
	if data.rs == 0 then
		self:showSysMessage(TextWords:getTextWord(3820))
	end
end
--宝具碎片分解
function HeroTreasureProxy:onTriggerNet350004Req(data)
	self:syncNetReq(AppEvent.NET_M35, AppEvent.NET_M35_C350004, data)
end

function HeroTreasureProxy:onTriggerNet350004Resp(data)
	if data.rs == 0 then
		self:showSysMessage(TextWords:getTextWord(3820))
	end
end
--宝具碎片合成宝具
function HeroTreasureProxy:onTriggerNet350005Req(data)
	self:syncNetReq(AppEvent.NET_M35, AppEvent.NET_M35_C350005, data)
end

function HeroTreasureProxy:onTriggerNet350005Resp(data)
	if data.rs == 0 then
		self:showSysMessage(TextWords:getTextWord(3821))
	end
end


------------------------------------------------------------- get function 外部调用接口
--根据出战部队槽位Id获取宝具身上table
function HeroTreasureProxy:getTreasureInfoByHeroPostId(postId)

    local treasureTable = {}
    for key, var in pairs(self._allTreasureInfos) do
        if postId ==  var["postId"] then
          treasureTable[tostring(var.part)] = var
        end
    end
    return treasureTable

end

function HeroTreasureProxy:getAllTreasureInfosList()                
	local info = TableUtils:map2list(self._allTreasureInfos)
    table.sort(info,sortTreasure)
	return info
end
--全部的武器（左边）
function HeroTreasureProxy:getWTreasureInfosList()   
    local wInfos = {}             
    local info = self:getAllTreasureInfosList()
    for i,v in ipairs(info) do
        if v.part == 0 then
            table.insert(wInfos, v)
        end
    end
    return wInfos
end
--全部的马（右边）
function HeroTreasureProxy:getHTreasureInfosList()   
    local hInfos = {}             
    local info = self:getAllTreasureInfosList()
    for i,v in ipairs(info) do
        if v.part == 1 then
            table.insert(hInfos, v)
        end
    end
    return hInfos
end
--判断是否有可穿戴的宝具
function HeroTreasureProxy:isCanPutOn( pos )
    local allData = {}
    if pos == 0 then
        allData = self:getWTreasureInfosList()
    elseif pos == 1 then
        allData = self:getHTreasureInfosList()
    end
    for _,v in pairs(allData) do
        if v.postId == 0 then
            return true
        end
    end
    return false
end
function HeroTreasureProxy:getAllTreasureInfos()

    return  self._allTreasureInfos
end
function HeroTreasureProxy:getTreasureInfoByDbId(DbId)

    return  self._allTreasureInfos[DbId]
end
function HeroTreasureProxy:getAllTreasurePieceInfos()

    return  self._allTreasurePieceInfos
end
function HeroTreasureProxy:getPieceNumByID(typeid)
    local num = 0
    if self._allTreasurePieceInfos[typeid] then
        num = self._allTreasurePieceInfos[typeid].num
    end 
    return num

end
function HeroTreasureProxy:getAllTreasurePieceInfosList()
    local info = TableUtils:map2list(self._allTreasurePieceInfos)
    return info
end
function HeroTreasureProxy:getHeroProxy()
    if self.heroProxy then
        return  self.heroProxy
        else 
        self.heroProxy = self:getProxy(GameProxys.Hero)
        return self.heroProxy
    end

end
--获取未装备的宝具
function HeroTreasureProxy:getUnEquipInfosList()
    local t = nil
    if self._allTreasureInfos == nil or table.size(self._allTreasureInfos) == 0 then 
        return t 
    end 
    local listInfo = self:getAllTreasureInfosList()
    t = {}
    for _,v in pairs(listInfo) do
        if v.postId ==  0 then --英雄ID为0未上装
            table.insert(t,v)
        end 
    end 
    return t
end
--根据宝具DbID获取基础属性（固定的属性加槽位升阶后加成的属性）
function HeroTreasureProxy:getBasalAttInfoByTreasureDbID(treasureDbID)
    if self._allTreasureInfos[treasureDbID] == nil then
        print("HeroTreasureProxy:getBasalAttInfoByTreasureDbID error,no this treasureDbID")
        return
    end
    local config = ConfigDataManager:getConfigById(ConfigData.TreasureBaseConfig, self._allTreasureInfos[treasureDbID].typeid)
    local baseTable = StringUtils:jsonDecode(config.property)
    if self._allTreasureInfos[treasureDbID].postId ==  0 then
        --无槽位升阶属性
        return baseTable 
    else
        --有槽位升阶属性加成
        local aTable = clone(baseTable)
        local addTable = StringUtils:jsonDecode(config.rate)
        local postInfo =  self:getPostInfoByTreasureDbID(treasureDbID)
        local level = postInfo.treasurePostLevelInfo.level
        for key, var in pairs(baseTable) do
            aTable[key][2] = aTable[key][2] + addTable[key][2]*level
        end
        return aTable
    end   
end
--根据槽位Id获得阶级信息
function HeroTreasureProxy:getPostLevelInfosByPos(postId)
    local aTable = {}
    local postLevelInfos = self._allPostInfos[postId].treasurePostLevelInfo
    for k,v in pairs(postLevelInfos) do
        aTable[v.postId] = v.level
    end
    return aTable
end
--根据某一个洗炼属性服务器info获取洗炼属性的对应加成（多少级的属性）baseInfo{typeid,level}
function HeroTreasureProxy:getHighAttInfoByBaseInfo(baseInfo)
    if baseInfo == nil and baseInfo.typeid == nil and baseInfo.level == nil then
        print("HeroTreasureProxy:getHighAttInfoByBaseInfo,baseInfo is nil")
        return
    end
    local config = ConfigDataManager:getConfigById(ConfigData.TreasureEnchantConfig, baseInfo.typeid)
    --local baseTable = --StringUtils:jsonDecode(config.property)

    local addTable = StringUtils:jsonDecode(config.propertyrate)
    
    local aTable = clone(addTable)

    aTable[2] = addTable[2]*baseInfo.level

    return aTable
    
    
end
--根据(已经上装)宝具DbID获取它所在英雄的槽位信息（部位阶级信息，部位祝福值信息）
function HeroTreasureProxy:getPostInfoByTreasureDbID(treasureDbID)
    if self._allTreasureInfos[treasureDbID] == nil then
        print("HeroTreasureProxy:getPostInfoByTreasureDbID error,no this treasureDbID")
        return
    end
    if self._allTreasureInfos[treasureDbID].postId ==  0 then
        print("HeroTreasureProxy:getPostInfoByTreasureDbID error,treasureDbID is not in hero")
        return
    end
    local postId = self._allTreasureInfos[treasureDbID].postId
    local typeid = self._allTreasureInfos[treasureDbID].typeid
    local config = ConfigDataManager:getConfigById(ConfigData.TreasureBaseConfig, typeid)
    local part = config.part

    local tempTable = {}
    for key, var in pairs(self._allPostInfos[postId].treasurePostLevelInfo) do
        
        if var.postId ==  part then
            tempTable.treasurePostLevelInfo = var
        end
    end

    
    for key, var in pairs(self._allPostInfos[postId].treasurePostWishInfo) do
        if var.postId ==  part then
            tempTable.treasurePostWishInfo = var
        end
    end
    return  tempTable
end
--用typeId获取宝具基础
function HeroTreasureProxy:getDataFromTreasureBaseConfig(typeid)
       local config = ConfigDataManager:getConfigById(ConfigData.TreasureBaseConfig, typeid)
       return config
end
--用typeId获取宝具碎片基础
function HeroTreasureProxy:getDataFromTreasurePieceConfig(typeid)
       local config = ConfigDataManager:getConfigById(ConfigData.TreasurePieceConfig, typeid)
       return config
end
--用typeId获取宝具部位
function HeroTreasureProxy:getPartByTypeid(typeid)
       local config = ConfigDataManager:getConfigById(ConfigData.TreasureBaseConfig, typeid)
       return config.part
end
--获取本次洗炼消耗(这里的普通消耗数量为基数数量，未乘以本天洗炼次数)
function HeroTreasureProxy:getOnePurifyPrice()
       local config = ConfigDataManager:getConfigData(ConfigData.TreasureSophisticationConfig)
       local aTable = {}
       aTable.payprice = config[1].payprice
       aTable.freePrice = tonumber(StringUtils:jsonDecode(config[1].freePrice)[1][3])
       return aTable
end


--计算一个出战槽位上的宝具加成战力
function HeroTreasureProxy:getPosTreasureFight(pos, adviserInfo)

    local treasureFight = 0
    local treasureAddTable = self:getOnePostAddTreasureAttTable(pos)
    local hp = 0             --1血量
    local attack = 0         --3攻击
    local hitRate = 0        --4命中
    local dodgeRate = 0      --5闪避
    local critRate = 0       --6暴击
    local defRate = 0        --7抗暴
    local hpRate = 0         --11血量百分比
    local attackRate = 0     --12攻击百分比
    local blastRate = 0      --33爆伤
    local toughnessRate = 0  --34韧性
    if treasureAddTable ~= nil and treasureAddTable ~= {} then
    hp = hp + treasureAddTable.hp
    attack = attack + treasureAddTable.attack
    hitRate = hitRate + treasureAddTable.hitRate
    dodgeRate = dodgeRate + treasureAddTable.dodgeRate
    critRate = critRate + treasureAddTable.critRate
    defRate = defRate + treasureAddTable.defRate
    hpRate = hpRate + treasureAddTable.hpRate
    attackRate = attackRate + treasureAddTable.attackRate
    blastRate = blastRate + treasureAddTable.blastRate
    toughnessRate = toughnessRate + treasureAddTable.toughnessRate
	end
    
    local soldierProxy = self:getProxy(GameProxys.Soldier)
    local adviserCommand = soldierProxy:getAdviserCommand(adviserInfo)
	local rProxy = self:getProxy(GameProxys.Role)
    local command = rProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command) + adviserCommand
    
    hp = math.floor(hp)
    attack = math.floor(attack)

    hp = hp * 0.1
    attack = attack * 0.5 * 4.08
    --宝具战力公式 血量*0.1 + 攻击*0.5*4.08 + (命中+闪避+暴击+抗暴+爆伤+韧性)/100.0 + (血量百分比+攻击百分比)*800.0/10000.0
    treasureFight = (hp + attack + (hitRate + dodgeRate + critRate + defRate + blastRate + toughnessRate) / 100.0 + (hpRate + attackRate)*800.0/10000.0) * command
	return treasureFight
end

--计算一个槽位上的宝具加成先手值
function HeroTreasureProxy:getPosTreasureFirstNum(pos)
    local treasureAddFirstNum = self:getFirstNumInPost(pos) or 0
    return treasureAddFirstNum
end
--宝具信息刷新后计算先手值是否发生改变
function HeroTreasureProxy:isChangeFirstNum()
    local first = 0
    for i=1,6 do
        first =  self:getPosTreasureFirstNum(i) + first
    end 
    if self.oldFirst == nil then
        self.oldFirst = first
    end
    if self.oldFirst ~= first then
        local soldierProxy = self:getProxy(GameProxys.Soldier)
        soldierProxy:heroTreasureChange()
    end
    self.oldFirst = first

end


--获取单个出战槽上宝具所有的属性table
function HeroTreasureProxy:getOnePostAddTreasureAttTable(pos)
    local treasureAddTable = {}
    treasureAddTable.hp = 0             --1血量
    treasureAddTable.attack = 0         --3攻击
    treasureAddTable.hitRate = 0        --4命中
    treasureAddTable.dodgeRate = 0      --5闪避
    treasureAddTable.critRate = 0       --6暴击
    treasureAddTable.defRate = 0        --7抗暴
    treasureAddTable.hpRate = 0         --11血量百分比
    treasureAddTable.attackRate = 0     --12攻击百分比
    treasureAddTable.blastRate = 0      --33爆伤
    treasureAddTable.toughnessRate = 0  --34韧性
    
    local treasureTable = self:getTreasureInfoByHeroPostId(pos)
    
    local function addToTable( singleInfo )
        if singleInfo[1] == 1 or singleInfo[1] == 2 then
            treasureAddTable.hp = treasureAddTable.hp + singleInfo[2]
        elseif singleInfo[1] == 3 then
            treasureAddTable.attack = treasureAddTable.attack + singleInfo[2]
        elseif singleInfo[1] == 4 then
            treasureAddTable.hitRate = treasureAddTable.hitRate + singleInfo[2]
        elseif singleInfo[1] == 5 then
            treasureAddTable.dodgeRate = treasureAddTable.dodgeRate + singleInfo[2]
        elseif singleInfo[1] == 6 then
            treasureAddTable.critRate = treasureAddTable.critRate + singleInfo[2]
        elseif singleInfo[1] == 7 then
            treasureAddTable.defRate = treasureAddTable.defRate + singleInfo[2]
        elseif singleInfo[1] == 11 then
            treasureAddTable.hpRate = treasureAddTable.hpRate + singleInfo[2]
        elseif singleInfo[1] == 12 then
            treasureAddTable.attackRate = treasureAddTable.attackRate + singleInfo[2]
        elseif singleInfo[1] == 33 then
            treasureAddTable.blastRate = treasureAddTable.blastRate + singleInfo[2]
        elseif singleInfo[1] == 34 then
            treasureAddTable.toughnessRate = treasureAddTable.toughnessRate + singleInfo[2]
        end
    end
    if treasureTable["0"] then
        --基础属性（固定+进阶）
        local addBasalInfo = self:getBasalAttInfoByTreasureDbID(treasureTable["0"].id)
        for _, var in pairs(addBasalInfo or {}) do
            addToTable(var)
        end


        --洗炼属性
        for _, var in pairs(treasureTable["0"].baseInfo or {}) do
            local addHighInfo = self:getHighAttInfoByBaseInfo(var)
            addToTable(addHighInfo)
        end
        
        
    end
    if treasureTable["1"] then
        --基础属性（固定+进阶）
        local addBasalInfo = self:getBasalAttInfoByTreasureDbID(treasureTable["1"].id)
        for _, var in pairs(addBasalInfo or {}) do
            addToTable(var)
        end
        --洗炼属性
        for _, var in pairs(treasureTable["1"].baseInfo or {}) do
            local addHighInfo = self:getHighAttInfoByBaseInfo(var)
            addToTable(addHighInfo)
        end
    end
    

    return treasureAddTable
end
--获取一个出战槽的先手值（宝具加成的先手值）
function HeroTreasureProxy:getFirstNumInPost(pos)
    local firstNum = 0
    
    local treasureTable = self:getTreasureInfoByHeroPostId(pos)
    
    local function addToTable( singleInfo )
        if singleInfo[1] == 10 then
            firstNum = firstNum + singleInfo[2]
        end
    end
    if treasureTable["0"] then
        --基础属性（固定+进阶）
        local addBasalInfo = self:getBasalAttInfoByTreasureDbID(treasureTable["0"].id)
        for _, var in pairs(addBasalInfo or {}) do
            addToTable(var)
        end


        --洗炼属性
        for _, var in pairs(treasureTable["0"].baseInfo or {}) do
            local addHighInfo = self:getHighAttInfoByBaseInfo(var)
            addToTable(addHighInfo)
        end
        
        
    end
    if treasureTable["1"] then
        --基础属性（固定+进阶）
        local addBasalInfo = self:getBasalAttInfoByTreasureDbID(treasureTable["1"].id)
        for _, var in pairs(addBasalInfo or {}) do
            addToTable(var)
        end
        --洗炼属性
        for _, var in pairs(treasureTable["1"].baseInfo or {}) do
            local addHighInfo = self:getHighAttInfoByBaseInfo(var)
            addToTable(addHighInfo)
        end
    end
 

    return firstNum
end
--英雄页面显示宝具加成到英雄身上的属性（其实是假的，只有前端加了）
function HeroTreasureProxy:getTreasureAttAddToHero(pos)
    local attrInfo = {}
    local baseKeys = {"hp", "hitRate", "critRate", "attack", "dodgeRate", "defRate"}
    local textInfo = {"血量", "命中", "暴击", "攻击", "闪避", "抗暴"}

    local treasureAddTable = self:getOnePostAddTreasureAttTable(pos)

    for k,v in pairs(baseKeys) do
        attrInfo[k] = {}
        attrInfo[k].base = treasureAddTable[v]
        attrInfo[k].text = textInfo[k]
    end

    return attrInfo

end
--英雄页面显示宝具加成到英雄身上的属性血量百分比攻击百分比（特殊处理）（其实是假的，只有前端加了）
function HeroTreasureProxy:getTreasureAttAddToHeroPlus(pos)
    local attrInfo = {}
    local baseKeys = {"hpRate", "attackRate"}
    local textInfo = {"血量百分比","攻击百分比"}

    local treasureAddTable = self:getOnePostAddTreasureAttTable(pos)

    for k,v in pairs(baseKeys) do
        attrInfo[v] = treasureAddTable[v]
    end

    return attrInfo
end



--处理最优洗炼属性信息
function HeroTreasureProxy:packBestInfos(bestInfos)
    local aTable = bestInfos
    for _, var in pairs(aTable) do
        local config = ConfigDataManager:getConfigById(ConfigData.TreasureEnchantConfig, var.typeid)
        var.name = config.name
        local addTable = StringUtils:jsonDecode(config.propertyrate)
        local addAtt = addTable[2]
        addAtt = addAtt*10*4
        var.property =  self:handleBasalAttNum({addTable[1],addAtt})
        local resConfig = ConfigDataManager:getConfigById(ConfigData.ResourceConfig ,addTable[1])
        var.propertyName = resConfig.name
    end
    table.sort(aTable,function(a, b) return a.number > b.number end)  
    return aTable
end

function HeroTreasureProxy:isHasTreasure(info)
    return self._allTreasureInfos[info.id] ~= nil
end
function HeroTreasureProxy:isHasTreasureFragment(info)
    return self._allTreasurePieceInfos[info.typeid] ~= nil
end
-----------------------------------------------------------
--一些资源
function HeroTreasureProxy:getBasalAttImgUrl(ID)
--{4-命中>>8.png ,5-闪避>>9.png ,10-先手值>>14.png ,11-血量>>6.png ,12-攻击>>5.png ,33-爆伤>>10.png ,34-韧性>>11.png}
--兼容1血量>>6.png ,3攻击>>5.png ,6暴击>>11.png ,7抗暴>>10.png
       local iconNameTable = {["4"] = 8,["5"] = 9,["10"] = 14,["11"] = 6,["12"] = 5,["33"] = 10,["34"] = 11,["1"] = 6,["3"] = 5,["7"] = 11,["6"] = 10}
       local num = iconNameTable[tostring(ID)] or 1
       return string.format("images/littleIcon/%d.png", num)
end
--处理基础属性加成是原值还是万分比,返回字符串，除了先手值其他都是万分比{10,500}
function HeroTreasureProxy:handleBasalAttNum(aTable)
       if aTable[1] == 10 or aTable[1] == 1 or aTable[1] == 3 then
           return  tostring(aTable[2])
       end
       local num =  math.floor(aTable[2]/100)
       return num .. "%"
end
--处理基础属性加成是原值还是万分比的基础上再乘以百分比值,返回String，除了先手值其他都是万分比{10,500}
function HeroTreasureProxy:handleBasalAttNumWithPercent(aTable,percent)
       if aTable[1] == 10 or aTable[1] == 1 or aTable[1] == 3 then
           return   tostring(aTable[2]*percent*0.01)
       end
       local num =  math.floor(aTable[2]/100)
       return num*percent*0.01 .. "%"
end

function HeroTreasureProxy:getHighAttImgUrl(typeid)
       return string.format("images/heroTreasureIcon/high_%d.png", typeid)
end

--用typeId获取宝具名称图url
function HeroTreasureProxy:getTreasureNameImgUrl(typeid)
    local info = ConfigDataManager:getConfigById(ConfigData.TreasureBaseConfig, typeid)
    local url = "images/heroTreasureIcon/name_" .. info.icon .. ".png"
    return url
end
--用typeId获取宝具颜色图url
function HeroTreasureProxy:getTreasureColorImgUrl(typeid)
    local info = ConfigDataManager:getConfigById(ConfigData.TreasureBaseConfig, typeid)
    local url = "images/heroTreasureIcon/color_" .. info.color .. ".png"
    return url
end
--用treasureDbID获取宝具阶级图url
function HeroTreasureProxy:getTreasureStageNumImgUrl(treasureDbID)
    local postInfo =  self:getPostInfoByTreasureDbID(treasureDbID)
    local level = postInfo.treasurePostLevelInfo.level
    local url = "images/heroTreasureIcon/stage_" .. level .. ".png"
    return url
end
--获取宝具大图url
function HeroTreasureProxy:getTreasureImgUrl(typeid)
    local con = self:getDataFromTreasureBaseConfig(typeid)
    if con == nil then
        return "images/newGui1/none.png"
    end
    local url
    if con.icon >  9 then
        url = "images/heroTreasureBigIconTwo/" .. con.icon .. ".png"
    else
        url = "images/heroTreasureBigIcon/" .. con.icon .. ".png"
    end

    return url
end
--------------------------------------------------------
------table排序---
function sortTreasure(a,b)
    --1已穿戴->2颜色->3部位->4id
    if a.postId ~=  0 and b.postId ==  0 then --穿戴
        return true
    elseif a.postId ==  b.postId  then
        if a.color > b.color then --颜色
            return true
        elseif a.color == b.color then
            if a.part < b.part then --部位
                return true
            elseif a.part == b.part then
                if a.typeid > b.typeid then --id
                    return true
                else
                    return false
                end 
            else
                return false
            end 
        else
            return false
        end 
    else
        return false
    end 
    
end