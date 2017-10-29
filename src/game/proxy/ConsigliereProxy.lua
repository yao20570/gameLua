
ConsigliereProxy = class("ConsigliereProxy", BasicProxy)

function ConsigliereProxy:ctor()
    ConsigliereProxy.super.ctor(self)
    self.proxyName = GameProxys.Consigliere
    self._maxConsuId = nil

    self.consiglierInfo = ConfigDataManager:getConfigData(ConfigData.CounsellorConfig)

    self.allInfo = {}
end

function ConsigliereProxy:resetAttr()

end

function ConsigliereProxy:resetCountSyncData()
    local priceInfo = {}
    for i=1,2 do
        priceInfo[i] = priceInfo[i] or {}
        local priceType = i == 1 and 206 or 201
        local priceConfig = ConfigDataManager:getInfoFindByTwoKey(ConfigData.CounsellorPriceConfig, "timemax", 1, "pricetype", priceType)
        priceInfo[i]["onceprice"] = priceConfig.price
        local allPrice = 0
        for j=1,5 do
            priceConfig = ConfigDataManager:getInfoFindByTwoKey(ConfigData.CounsellorPriceConfig, "timemax", j, "pricetype", priceType)
            allPrice = allPrice + priceConfig.price
        end
        priceInfo[i]["fiveprice"] = allPrice
    end
    local tempData = {}
    tempData.costInfos = priceInfo
    tempData.rs = 0
    self:onTriggerNet260004Resp(tempData)
end

function ConsigliereProxy:initSyncData(data)
    ConsigliereProxy.super.initSyncData(self, data)
    if data.adviserinfos ~= nil then
        local tempData = {}
        tempData.adviserinfos = data.adviserinfos
        tempData.rs = 0
        self:onTriggerNet260000Resp(tempData)
    end
    if data.costInfos ~= nil then
        local tempData = {}
        tempData.costInfos = data.costInfos
        tempData.rs = 0
        self:onTriggerNet260004Resp(tempData) -- 随20000消息号下发
    end
    --内政数据
    if data.foreignInfos ~= nil then
        local tempData = {}
        tempData.info = data.foreignInfos
        tempData.rs = 0
        self:onTriggerNet260007Resp(tempData)
    end
end

function ConsigliereProxy:registerNetEvents()
end

function ConsigliereProxy:unregisterNetEvents()
end

--分解
function ConsigliereProxy:onTriggerNet260003Resp(data)
    self:sendNotification(AppEvent.PROXY_RESOLVE, data)
end

--升级
function ConsigliereProxy:onTriggerNet260002Resp(data)
    self:sendNotification(AppEvent.PROXY_UPGRADE, data)
end

--一键进阶
function ConsigliereProxy:onTriggerNet260006Resp(data)
    self:sendNotification(AppEvent.PROXY_ONEKEY, data)
end

--任命
function ConsigliereProxy:onTriggerNet260007Resp(data)
    self:sendNotification(AppEvent.PROXY_CONSIGRE_FOREIGN, data)
end

--卸任
function ConsigliereProxy:onTriggerNet260008Resp(data)
    self:sendNotification(AppEvent.PROXY_CONSIGRE_FOREIGN_RELIEV, data)
end


function ConsigliereProxy:onTriggerNet260000Resp(data)
    if data.rs == 0 then
        -- self.allNum = 0
        self.allInfo = {}
        for _, data in pairs( data.adviserinfos ) do
            local k = data.id
            self.allInfo[k] = data
        end
        self:sendNotification(AppEvent.PROXY_GET_CONINFO)
    end
end

--进阶
function ConsigliereProxy:onTriggerNet260001Resp(data)
    self:sendNotification(AppEvent.PROXY_ADVANCED, data)
end

--抽奖信息
function ConsigliereProxy:onTriggerNet260004Resp(data)
    if data.rs == 0 then
        self.recruitData = data.costInfos
    end
    self:sendNotification(AppEvent.PROXY_UPDATE_BUY_VIEW)
end

--抽奖
function ConsigliereProxy:onTriggerNet260005Resp(data)
    if data.rs == 0 then
        self.recruitData = data.costInfos
    end
    self:sendNotification(AppEvent.PROXY_CONSIGRECRUIT, data)
end

function ConsigliereProxy:onTriggerNet260005Req(data)
    self:syncNetReq(AppEvent.NET_M26, AppEvent.NET_M26_C260005, data)
end

function ConsigliereProxy:onTriggerNet260002Req(data)
    self:syncNetReq(AppEvent.NET_M26, AppEvent.NET_M26_C260002, data)
end

function ConsigliereProxy:onTriggerNet260006Req(data)
    self:syncNetReq(AppEvent.NET_M26, AppEvent.NET_M26_C260006, data)
end

function ConsigliereProxy:onTriggerNet260001Req(data)
    self:syncNetReq(AppEvent.NET_M26, AppEvent.NET_M26_C260001, data)
end

function ConsigliereProxy:onTriggerNet260004Req(data)
    self:syncNetReq(AppEvent.NET_M26, AppEvent.NET_M26_C260004, data)
end

function ConsigliereProxy:onTriggerNet260003Req(data)
    self:syncNetReq(AppEvent.NET_M26, AppEvent.NET_M26_C260003, data)
end

function ConsigliereProxy:onTriggerNet260007Req(data)
    self:syncNetReq(AppEvent.NET_M26, AppEvent.NET_M26_C260007, data)
end

function ConsigliereProxy:onTriggerNet260008Req(data)
    print("卸任", data.pos)
    self:syncNetReq(AppEvent.NET_M26, AppEvent.NET_M26_C260008, data)
end


function ConsigliereProxy:setConsidliereImg(adviserinfo) --军师鉴图啊
end

function ConsigliereProxy:getDataById( typeId )
	return self.consiglierInfo[ typeId ]
end

function ConsigliereProxy:getConfById( id )
    local data = self:getInfoById( id )
    if data then
        return self.consiglierInfo[ data.typeId ]
    else
        return nil
    end
end

function ConsigliereProxy:getSkillData(id)
	local conf = ConfigDataManager:getConfigData(ConfigData.CounsellorSkillConfig)
	return conf[id]
end

function ConsigliereProxy:getLvData( typeId, lv )  --lv=星级
    local conf = nil
    if lv and lv>0 then
        conf = ConfigDataManager:getInfoFindByTwoKey(ConfigData.CounsellorLvupConfig, "lv", lv, "CounsellorID", typeId )
    else
        conf = self:getDataById( typeId )
    end
    return conf
end

function ConsigliereProxy:getConfLvById( id )
    local data = self:getInfoById( id )
    return self:getLvData( data.typeId, data.lv )
end

-- 军师身体图片
function ConsigliereProxy:getIconByTypeid( typeId )
    local conf = self:getDataById( typeId ) or {}
    return conf.icon
end


--获得指定品质。且闲置状态的英雄
-- quality --品质
-- isIdle --是否判断闲置  默认否 不判断闲置状态
function ConsigliereProxy:getQuiltyById( quality, isIdle )
    local arr = {}
    for k,data in pairs(self.allInfo) do
        local flag = not isIdle or (isIdle and data.pos==0)  --
        local conf = self:getDataById( data.typeId )
        if conf and conf.quality==quality and flag  then
            table.insert( arr, data )
        end
    end
    return arr
end

--是否是闲置军师
function ConsigliereProxy:isFreeAdviser( id )
    local data = self:getInfoById(id)
    local ret = false
    if data and data.pos==0 then
        ret = true
    end
    return ret
end

function ConsigliereProxy:onNewInfoResp(data)
    if not self.allInfo then
        self.allInfo = {}
    end
    --插入与删除数据
    local newDataList = {}  --新获得
    local roleProxy = self:getProxy(GameProxys.Role)

    for i,v in ipairs(data) do
        if v.typeId==0 then  --协议定义typeId为0，是删除的意思，

            --军师跟战力和带兵量的关系，一个军师消失了，需要判断是否为套用阵型或者其他阵型里面引用到的
            --需要重算槽位兵量和更新阵型里面的军师id
            local adviser = self.allInfo[v.id]
            local count = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)
            local function adjustData(teamInfo)
                local isNeedChange = false
                for k,info in pairs(teamInfo) do
                    for key,value in pairs(info.members) do
                        
                        if value.post == 9 then
                            if v.id == value.adviserId then
                                --强制设置为fixed64 0的数据
                                
                                teamInfo[k].members[key].adviserId = StringUtils:int32ToFixed64(0)
                                print("这个军师给分解了",v.id, "====新的唯一id",teamInfo[k].members[key].adviserId)
                                local adviserConfig = self:getDataById(adviser.typeId)
                                local command = adviserConfig.command
                                isNeedChange = command > 0
                            end
                        end
                    end
                end

                --带兵量变了。
                if isNeedChange then
                    for k,info in pairs(teamInfo) do
                        for key,value in pairs(info.members) do
                            teamInfo[k].members[key].num = teamInfo[k].members[key].num > count and count or teamInfo[k].members[key].num
                        end
                    end
                end
            end
            local soldier = self:getProxy(GameProxys.Soldier)
            local allSetTeamInfo = soldier:onGetTeamInfo()
            adjustData(allSetTeamInfo)

            allSetTeamInfo = soldier:getTeamDataMap()
            adjustData(allSetTeamInfo)



            self.allInfo[v.id] = nil
        else
            if not self.allInfo[ v.id ] then
                table.insert( newDataList, v )
            end
            self.allInfo[ v.id ] = v
        end
    end

    local oldMaxId = self._maxConsuId

    self:getMaxConsuId()

    if oldMaxId ~= self._maxConsuId then
        local proxy = self:getProxy(GameProxys.Soldier)
        proxy:soldierMaxFightChange()
        proxy:setMaxFighAndWeight()
    end

    --额外分类引用
    -- self.allNum = 0
    --重设 图鉴数据
    -- self:setConsidliereImg(self.allInfo)
    --通知进阶界面刷新
    self:sendNotification(AppEvent.PROXY_GET_CONINFO, newDataList )--, self.allInfo)
end

--重新排序，返回新的队列数组
function ConsigliereProxy:tableSort(param)
    local retTable = {}
    for k,v in pairs(param) do
        table.insert( retTable, v )
    end
    -- if type(param) ~= "table" then
    --     return param
    -- end
    table.sort( retTable, function(a, b)
        local aa = a.pos==0 and 1000 or a.pos  --将闲置0，排到末尾
        local bb = b.pos==0 and 1000 or b.pos
        if aa<bb then 
            return true
        elseif aa==bb then
            local baseDataA = self:getDataById(a.typeId)
            local baseDataB = self:getDataById(b.typeId)
            return baseDataA.sort<baseDataB.sort
        else
            return false
        end
    end )
    return retTable
end

function ConsigliereProxy:setPrice(price)
    self.price = price
end

function ConsigliereProxy:getPrice()
    return self.price
end

-- function ConsigliereProxy:removeInfo(data)
--     self:removeHelp(self.allInfo, data)
-- end

function ConsigliereProxy:setMaxChooseNum(num)
    self.maxNum = num
end

-- function ConsigliereProxy:removeHelp( removeId )
--     -- for k,v in pairs(removeData) do
--         for k, data in pairs(self.allInfo) do
--             if data.id == removeId then
--                 table.remove(self.allInfo, k )
--                 break
--             end
--         end
--     -- end
-- end

-- function ConsigliereProxy:getAllNum()
--     return self.allNum
-- end

--返回一个排好序的数组
function ConsigliereProxy:getAllInfo()
    local ret = self:tableSort( self.allInfo )
	return ret
end

function ConsigliereProxy:getInfoById( id )
    return self.allInfo[id]
end

function ConsigliereProxy:getInfoByTypeId( typeId )
    for _,v in pairs( self.allInfo ) do
        if v.typeId==typeId then
            return v
        end
    end
    return nil
end

-- 获取内政选择列表
function ConsigliereProxy:getForeignSelectList()    
    local listData = { }
    for key, v in pairs(self.allInfo) do
        -- 内政 排除5星 排除上阵
        local conf = self:getDataById(v.typeId)
        if conf.quality <= 4 and v.pos == 0 then
            table.insert(listData, v)
        end
    end

    local ret = self:tableSort( listData )
    return ret
end

-- 获取相同typeid的全部军师，因为同款军师可以存在多个
function ConsigliereProxy:getInfosByTypeId( typeId )
    local infos = {}
    for _,v in pairs( self.allInfo ) do
        if v.typeId==typeId then
            -- return v
            table.insert(infos,v)
        end
    end
    -- return nil
    return infos
end

function ConsigliereProxy:getAllPosInfo()
    local allPosArr = {}
    for k, info in pairs( self.allInfo ) do
        if info.pos and info.pos>0 then
            table.insert( allPosArr, info )
        end
    end
    return allPosArr
end

function ConsigliereProxy:getPosInfoByPos( pos )
    for k, info in pairs( self.allInfo ) do
        if info.pos==pos then
            return info
        end
    end
    return nil
end


-- function ConsigliereProxy:getConsigType(type) --获得军师类型，0表示全部
--     local needData = {}
--     if type == 0 then
--         needData = self.allImgInfo
--     else
--         needData = self["info"..type]
--     end
--     table.sort(needData, function (a,b) return (a.sort < b.sort) end)
--     return self:infoToThree(needData)
-- end

function ConsigliereProxy:infoToThree(info)
    local tempInfo = {}
    local index = 1
    -- for i=1,10 do
        print("#info==",#info)
    -- end
    for i=1,#info do
        local v = info[i]
        if index%3 == 1 then
            tempInfo[(index+2)/3] = {}
            tempInfo[(index+2)/3][1] = v
        elseif index%3 == 2 then
            tempInfo[(index+1)/3][2] = v
        else
            tempInfo[index/3][3] = v
        end
        index = index + 1
    end

    return tempInfo
end

function ConsigliereProxy:getAllConsig() --获得表的军师
    return self.consiglierInfo or {}
end
function ConsigliereProxy:getAllSortConsig()
    local _data = self:getAllConsig()
    local arrList = {}
    for k,v in pairs(_data) do
        table.insert( arrList, v )
    end 
    table.sort( arrList, function(a, b)
        return a.sort<b.sort
    end )
    return arrList
end

function ConsigliereProxy:getRecruitInfo()
    return self.recruitData
end

function ConsigliereProxy:coinIsEnough(needCoin)
    local roleProxy = self:getProxy(GameProxys.Role)
    local coin = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold)
    return coin >= needCoin
end

function ConsigliereProxy:getMaxConsu()  --tudo：找出最大的军师  quality > level > ID
    local roleProxy = self:getProxy(GameProxys.Role)
    local level = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)   --tudo:24级开启军师
    if level < 24 or table.size(self.allInfo) <= 0 then
        return
    end
    self._maxConsuId = nil

    local retId

    local maxFight = 0

    for k,v in pairs(self.allInfo) do
        if v.pos == 0 then
            local config = ConfigDataManager:getInfoFindByTwoKey(ConfigData.CounsellorLvupConfig, "CounsellorID", v.typeId, "lv", v.lv)
            if config == nil then
                config = ConfigDataManager:getConfigById(ConfigData.CounsellorConfig, v.typeId)
            end

            if config == nil then
                logger:error("这个军师的typeId无法读表：%d", v.typeId)
                return
            end
            if maxFight < config.fightrank then
                maxFight = config.fightrank
                retId = v.id
                self._maxConsuId = v.id
            end
        end
    end

    -- local quality = 0

    -- for i=0,5 do
    --     self["quality"..i] = {}
    -- end

    -- --同品质
    -- for _,v in pairs(self.allInfo) do
    --     if v.pos == 0 then
    --         local config = self:getDataById(v.typeId)
    --         if config.quality > quality then
    --             quality = config.quality
    --         end
    --         table.insert(self["quality".. config.quality], v)
    --     end
    -- end

    -- local star = 0

    -- for i=0,5 do
    --     self["_star"..i] = {}
    -- end

    -- --同星级
    -- for k,v in pairs(self["quality".. quality]) do
    --     if v.lv > star then
    --         star = v.lv
    --     end
    --     table.insert(self["_star"..v.lv], v)
    -- end

    -- local maxFight = 0
    -- --最后选个表里战力最大的军师
    -- for k,v in pairs(self["_star"..star]) do
    --     local config = self:getDataById(v.typeId)
    --     if config.fightrank > maxFight then
    --         maxFight = config.fightrank
    --         retId = v.id
    --         self._maxConsuId = v.id
    --     end
    -- end
    return retId
end

function ConsigliereProxy:getMaxConsuId()  --tudo:得到战力最大的军师ID
    return self:getMaxConsu()
end

function ConsigliereProxy:getConsuById(id)
    for _,v in pairs(self.allInfo) do
        if v.typeId == id then
            return v
        end
    end
end

-- function ConsigliereProxy:onTriggerNet260002Resp(data)
--     self:sendNotification(AppEvent.PROXY_UPGRADE, data)
-- end

--TODO  写死了一些系数，修改时候需要注意
--通过唯一id去算一个军师的战力~~
--加成到所有槽位，就是算每一个槽位战力的时候都要来这里拿一下军师的战力
--0.1  血量系数
--0.5  攻击系数
--4.08 弓兵系数

--[[
    1 血量
    3 攻击
    4 命中
    5 闪避
    6 暴击
    7 抗暴
    11 血量百分比
    12 攻击百分比
    33 爆伤？？
    34 韧性？？

    公式：  血量*0.1（血量系数） + 攻击*0.5（攻击系数）*4.08（弓兵系数） + （命中+闪避+暴击+抗暴+爆伤+韧性）/100
             + （血量百分比 + 攻击百分比）*800/10000
]]
function ConsigliereProxy:getAdviserFight(adviserId)
    local adviserinfo = self:getInfoById(adviserId)
    if adviserinfo == nil then
        return 0
    end
    local config = ConfigDataManager:getInfoFindByTwoKey(ConfigData.CounsellorLvupConfig, "CounsellorID", adviserinfo.typeId, "lv", adviserinfo.lv)
    if config == nil then
        config = ConfigDataManager:getConfigById(ConfigData.CounsellorConfig, adviserinfo.typeId)
    end

    if config == nil then
        logger:error("这个军师的typeId无法读表：%d", adviserinfo.typeId)
        return 0
    end

    local buffCoefficient = {}
    buffCoefficient[1] = 0.1
    buffCoefficient[3] = 0.5*4.08
    for i=4,7 do
        buffCoefficient[i] = 0.01
    end
    buffCoefficient[12] = 0.08
    buffCoefficient[11] = 0.08
    buffCoefficient[33] = 0.01
    buffCoefficient[34] = 0.01

    local buff = StringUtils:jsonDecode(config.property)

    local fight = 0

    for k,v in pairs(buff) do
        local coefficient = buffCoefficient[v[1]] or 1
        fight = fight + v[2] * coefficient
    end

    local soldierProxy = self:getProxy(GameProxys.Soldier)
    local proxy = self:getProxy(GameProxys.Role)
    local adviserCommand = soldierProxy:getAdviserCommand(adviserinfo)
    local command = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_command) + adviserCommand

    print("获得一个军师的战力",fight , command, fight * command)
    fight = fight * command

    
    return fight
end

--计算军师 内政加成值，返回一个str
--军师品质
--加成效果jos
--是否显示百分比
function ConsigliereProxy:analyzeForeignAddVul( quality, effectshow, isPercent )
    quality = quality or 1
    effectshow = effectshow or "[]"
    local nAddVul = 0
    local tEff = StringUtils:jsonDecode( effectshow )
    for i,v in ipairs(tEff) do
        if v[1]==quality then
            nAddVul = v[2]
        end
    end
    local retStr = ""
    if isPercent then
        retStr = nAddVul.."%"
    else
        retStr = nAddVul
    end
    return retStr
end
--军师内政更换列表 军师属性：通过quality, pos  获得 内政加成值 返回str
function ConsigliereProxy:getForeignAddVul( quality, pos )
    local interiorConf = ConfigDataManager:getConfigData( ConfigData.InteriorConfig ) or {}
    local InterData = interiorConf[ pos ] or {}
    local str = self:analyzeForeignAddVul( quality, InterData.effectshow, pos~=1 ) or ""
    local title = InterData.info or ""
    return title.." +"..str
end

------
-- 判断是否有免费的求贤次数
function ConsigliereProxy:getFreeState()
    -- 判断建筑是否开启
    local buildingProxy = self:getProxy(GameProxys.Building)
    local isOpen = buildingProxy:getBuildOpenByModuleName(ModuleName.ConsigliereModule)
    if isOpen == false then
        return false
    end

    -- TODO 等级开放的时候，刷新动画

    local freeState = nil
    local buyData = self:getRecruitInfo()
    local key_1 = "onceprice"
    local key_5 = "fiveprice"
    local needCoin_1 = buyData[1][key_1]
    local needGold_1 = buyData[2][key_1]
    local needCoin_5 = buyData[1][key_5]
    local needGold_5 = buyData[2][key_5]
    if needCoin_1 == 0 or needGold_1 == 0 then -- 先判断1次状态
        freeState = true
    else -- 判断5次状态
        if needCoin_5 == 0 or needGold_5 == 0 then
            freeState = true
        else
            freeState = false
        end 
    end
    return freeState
end

------
-- 获取当前招募优惠活动的折扣(银币)
function ConsigliereProxy:getSilverDiscount()
    local disCount = 1
    local activityProxy = self:getProxy(GameProxys.Activity)
    
    local effect = activityProxy:getEffectValue(515)
    if effect then
        disCount = effect/100
    end

    --disCount = 0.8 -- 
    return disCount
end

------
-- 获取当前招募优惠活动的折扣(元宝)
function ConsigliereProxy:getGoldDiscount()
    local disCount = 1
    local activityProxy = self:getProxy(GameProxys.Activity)
    
    local effect = activityProxy:getEffectValue(514)
    if effect then
        disCount = effect/100
    end

    --disCount = 0.8 -- 
    return disCount
end

------
-- 获取最大带兵的军师
function ConsigliereProxy:getMaxCommandAdvicer()
    local maxCount = 0
    local soldierProxy = self:getProxy(GameProxys.Soldier)
    for key, data in pairs (self.allInfo) do
        local thisCommand = soldierProxy:getAdviserCommand(data)
        if maxCount < thisCommand then
            maxCount = thisCommand
        end
    end
    return maxCount
end



