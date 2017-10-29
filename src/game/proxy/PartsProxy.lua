-------------tudo:self._currMessage这个表的作用是  先返回13万某某协议，但是这个协议只返回rs，
-------------没有返回数据，数据现在统一返回在20007协议协议中，作用在onRunCurrFun


PartsProxy = class("PartsProxy", BasicProxy)

function PartsProxy:ctor()
    PartsProxy.super.ctor(self)
    self.proxyName = GameProxys.Parts
    self._eventCenter = MsgCenter.new()

    self._pieceInfos = {} --所有碎片信息
    --self._ordnanceEquipedInfos = {} --已装备的军械
    --self._ordnanceUnEquipInfos = {} --未装备的军械
    self._ordnanceInfos = {} --所有的军械信息
    self._sparUseInfos = {} --军械仓库晶石兑换信息

    self._currMessage = {id = nil,count = 0} --当前返回的协议号,为了适应先返回13万这些协议，再返回20007协议，导致无法刷新
end

function PartsProxy:resetAttr()
    self._eventCenter:reset()
    
    self._pieceInfos = nil --所有碎片信息
    --self._ordnanceEquipedInfos = nil --已装备的军械
    ---self._ordnanceUnEquipInfos = nil --未装备的军械
    self._ordnanceInfos = nil
    self._currMessage = {}
end
function PartsProxy:resetCountSyncData()
    self._sparUseInfos = {} --军械仓库晶石兑换信息
    self:sendNotification(AppEvent.PARTS_SPAR_CHANGE_INFO, {}) -- 晶石兑换信息变更
end

function PartsProxy:clearEvent()
    self._eventCenter:reset()
end

-- function PartsProxy:registerNetEvents()
-- end

-- function PartsProxy:unregisterNetEvents()
-- end

-- message OrdnanceInfo{    //军械信息
--     required fixed64 id = 1; //军械唯一id
--     required int32 typeid = 2; //军械碎片装备配置id
--     required int32 strgthlv=3;//强化等级
--     required int32 remoulv=4;//改造等级
--     required int32 type=5;//兵种类型
--     required int32 quality=6;//品质
--     required int32 part=7;//部位
--     required int32 position = 8; //装备的位置，0在仓库里,1槽位
--     required int32 strength=9;//强度
  
-- }

-----------------数据初始化------------------
function PartsProxy:initSyncData(data)
    PartsProxy.super.initSyncData(self, data)

    self._pieceInfos = {}
    self._ordnanceInfos = {}
    self:updateOrdnanceInfos(data.odInfos)
    self:updatePieceInfos(data.odpInfos)
    self:_updateOrdnanceInfos()
    --晶石兑换次数信息
    self:updateSparUseInfos(data.osuInfos)
end

-------
-- 军械更新函数
function PartsProxy:onCompareData(id ,mark, srcData,destData)
    for k1,v1 in pairs(destData) do
        local isExist = false
        for k2,v2 in pairs(srcData) do
            if v2[id] == v1[id] then   
                isExist = true
                if v1[mark] <= 0 then  --删除
                    table.remove(srcData,k2)
                elseif v1[mark] > 0 then --升级
                    srcData[k2] = v1     --tudo:v2 = v1，srcData的数据没发生改变
                end
                break
            end
        end
        if isExist == false and v1[id] ~= -1 then  --新增
            table.insert(srcData,v1)
            -- 走全局消息的刷新感叹号
            self:sendNotification(AppEvent.PARTS_UPDATE_BUILD_TIP,{})
            -- 军械数量增加
            self:sendNotification(AppEvent.PARTS_NUM_ADD_UPDATE, {})
        end
    end
end

--更新军械碎片的数量,20007协议也会调用
function PartsProxy:updatePieceInfos(data)
    local size = table.size(data)
    
    self:onCompareData("typeid","num",self._pieceInfos,data)
    self:onRunCurrFun(data)
    if size > GlobalConfig.pieceWarehouseMaxCount then
        logger:error("=======军械碎片的数量有问题=======:%d", size)
    end
    self:sendNotification("parts_event_update_whpiece",nil) -- 重新刷一遍 军械碎片界面
    self:sendNotification(AppEvent.PARTS_PIECE_CHANGE_INFO, {}) -- 军械数量变更
end

--更新军械晶石兑换信息
function PartsProxy:updateSparUseInfos(osuInfos)
    self._sparUseInfos = osuInfos
end
--根据配置表ID获取已经兑换次数
function PartsProxy:getSparExchangeTimeByID( typeId )
    for _,val in pairs(self._sparUseInfos) do
        if val.typeId == typeId then
            return val.exchangeTime
        end
    end
    return 0
end
--typeId对应已经兑换次数加一
function PartsProxy:addOneSparExchangeTimeByID( typeId )
    local num = 0
    for _,val in pairs(self._sparUseInfos) do
        if val.typeId == typeId then
            val.exchangeTime = 1 + val.exchangeTime
            num = val.exchangeTime
            break
        end
    end
    if num == 0 then
        local newItem = {}
        newItem.typeId = typeId
        newItem.exchangeTime = 1
        table.insert(self._sparUseInfos, newItem)
    end
    self:sendNotification(AppEvent.PARTS_SPAR_CHANGE_INFO, {}) -- 晶石兑换信息变更
end

-- 更新军械的数量,20007协议也会调用
function PartsProxy:updateOrdnanceInfos(data)
    local size = table.size(data)
    self:onCompareData("id","typeid",self._ordnanceInfos,data)
    

    self:onRunCurrFun(data)
    if size > GlobalConfig.partWarehouseMaxCount then
        logger:error("=======军械的数量有问题=======:%d", size)
    end
end

function PartsProxy:onRunCurrFun(data)
    if self._currMessage.id ~= nil then
        if self._currMessage.count == 0 then
            self._currMessage.count = 1
            self._currMessage.serverData = data
            self[self._currMessage.id](self)
        end
    end
end


--------------接受到协议数据-------------------

--M130102:军械碎片合成/ 合成的时候，先因为装备数量上的换更，而走了一遍，导致数量出错，
function PartsProxy:onTriggerNet130102Resp(data)
    if data ~= nil then
        self._currMessage = {id = "onTriggerNet130102Resp",count = 0,data = data}
        return
    end

    if self._currMessage.data.rs == 0 then
        if self._currMessage.id == "onTriggerNet130102Resp" and self._currMessage.count == 1 then
            self:showSysMessage(TextWords:getTextWord(8221))

            self:_updateOrdnanceInfos() 
            -- 合成等同于增加新军械，所以不需要_updateOrdnanceInfos2
            --self:sendNotification("parts_event_update_whpiece",nil)
            self:sendNotification("parts_event_update_whnum",nil)
            self:sendNotification("parts_event_update_partsenable",nil)
            -- 走全局消息的刷新感叹号
            self:sendNotification(AppEvent.PARTS_UPDATE_BUILD_TIP,{})
            self._currMessage = {}
        end
    end 
end

--M130103:军械碎片分解
function PartsProxy:onTriggerNet130103Resp(data)
    if data ~= nil then
        self._currMessage = {id = "onTriggerNet130103Resp",count = 0,data = data}
        return
    end

    if self._currMessage.data.rs == 0 then
        if self._currMessage.id == "onTriggerNet130103Resp" and self._currMessage.count == 1 then
            self:showSysMessage(TextWords:getTextWord(8222))
            --减少碎片
            

            self._currMessage = {}
        end
    end 
end

--M130104:军械装备
function PartsProxy:onTriggerNet130104Resp(data)
    if data ~= nil then
        self._currMessage = {id = "onTriggerNet130104Resp",count = 0,data = data}
        return
    end

    if self._currMessage.data.rs == 0 then
        if self._currMessage.id == "onTriggerNet130104Resp" and self._currMessage.count == 1 then


            self:showSysMessage(TextWords:getTextWord(8223))
            -- 不同的穿戴刷新
            if self._doPanelName == "PartsMainPanel" then
                self:_updateOrdnanceInfos2()
            else
                self:sendNotification(AppEvent.PARTS_EQUIP_IN_HOUSE, {}) -- 在仓库穿戴
            end
            self:sendNotification("parts_event_update_whnum",nil)
            self:sendNotification("parts_event_update_partsenable",nil)
            self:sendNotification("parts_event_update_whparts",nil)
            self:updateRedPoint()
            self._currMessage = {}
            -- 走全局消息的刷新感叹号
            self:sendNotification(AppEvent.PARTS_UPDATE_BUILD_TIP,{})
        end
    end 
end

--M130105:军械卸下
function PartsProxy:onTriggerNet130105Resp(data)
    if data.rs == 0 then
            for _,v in pairs(self._ordnanceInfos) do
                if v.id == self._sendDownId then
                    self._sendDownId = nil
                    v.position = 0
                    break
                end
            end
            self:showSysMessage(TextWords:getTextWord(8224))

            self:_updateOrdnanceInfos2()
            self:sendNotification("parts_event_update_whnum",nil)
            self:sendNotification("parts_event_update_partsenable",nil)
            self:sendNotification(AppEvent.PARTS_UPDATE_BUILD_TIP,{})
        --end
    end 
end

--M130106:军械分解
function PartsProxy:onTriggerNet130106Resp(data)
    if data ~= nil then
        self._currMessage = {id = "onTriggerNet130106Resp",count = 0,data = data}
        return
    end

    if self._currMessage.data.rs == 0 or self._currMessage.data.rs == -1 then
        if self._currMessage.id == "onTriggerNet130106Resp" and self._currMessage.count == 1 then
            self:showSysMessage(TextWords:getTextWord(8225))
            self:_minusOrdnanceInfos()
            -- 军械数量分解减少回调onInitAllPage()
            self:sendNotification(AppEvent.PARTS_NUM_ADD_UPDATE, {})

            self:sendNotification("parts_event_update_whparts",nil)
            self:sendNotification("parts_event_update_whnum",nil)
            self:sendNotification("parts_event_update_partsenable",nil)
            -- 走全局消息的刷新感叹号
            self:sendNotification(AppEvent.PARTS_UPDATE_BUILD_TIP,{})
            self._currMessage = {}
        end
    end
end

--M130107:军械强化
function PartsProxy:onTriggerNet130107Resp(data)
    if data ~= nil then -- 强化失败等其他的操作
        self._currMessage = {id = "onTriggerNet130107Resp",count = 0,data = data}
        self:sendNotification(AppEvent.PROXY_PARTS_STRENG, data.rs)
        return
    end

    if self._currMessage.id == "onTriggerNet130107Resp" and self._currMessage.count == 1 then
        if self._currMessage.data.rs == 0 then
            self:showSysMessage(TextWords:getTextWord(8226))

            self:_updateOrdnanceInfos2(self._currMessage.serverData[1])
            self:sendNotification("parts_event_update_whparts",nil)
        else
            self:sendNotification("parts_event_stren_failed",nil)
        end
        self._currMessage = {}
    end  
end

--M130108:军械改造
function PartsProxy:onTriggerNet130108Resp(data)
    if data ~= nil then
        self._currMessage = {id = "onTriggerNet130108Resp",count = 0,data = data}
        if data.rs == 0 then
            self:sendNotification(AppEvent.PROXY_PARTS_CHANGE)
        end
        return
    end

    if  self._currMessage.data.rs == 0 then
        if self._currMessage.id == "onTriggerNet130108Resp" and self._currMessage.count == 1 then
            self:showSysMessage(TextWords:getTextWord(8227))

            self:_updateOrdnanceInfos2(self._currMessage.serverData[1])
            self:sendNotification("parts_event_update_whparts",nil)
            self._currMessage = {}
        end
    end  
end

--M130109:军械进阶
function PartsProxy:onTriggerNet130109Resp(data)
    if data ~= nil then
        self._currMessage = {id = "onTriggerNet130109Resp",count = 0,data = data}
        return
    end
    
    if self._currMessage.data.rs == 0 then
        if self._currMessage.id == "onTriggerNet130109Resp" and self._currMessage.count == 1 then
            self:showSysMessage(TextWords:getTextWord(8228))
            -- 接收数据特殊处理:拿到的是-1  说明这个id是旧的装备，需要删掉
            
            -- 刷新军械仓库
            self:sendNotification("parts_event_update_whparts",nil)
            -- 刷新军械主界面
            -- 进阶传的数据不一样
            self:_updateOrdnanceInfos2(self._currMessage.serverData[2])
            -- 走全局消息的刷新感叹号
            self:sendNotification(AppEvent.PARTS_UPDATE_BUILD_TIP,{})

            self:updateRedPoint() 
            local soldierProxy = self:getProxy(GameProxys.Soldier)
            soldierProxy:soldierMaxFightChange()
            -- 刷新
            self._currMessage = {}
        end
    end  
end
--M130110:晶石兑换物品
function PartsProxy:onTriggerNet130110Resp(data)
    if data.rs == 0 then
        --兑换成功，客户端手动修改兑换信息
        self:addOneSparExchangeTimeByID(data.typeId)
    end
end



------------协议请求------------------------

--请求军械碎片信息
-- function PartsProxy:pieceInfosReq(data)
--     self:sendServerMessage(AppEvent.NET_M13, AppEvent.NET_M13_C130100, data)
-- end
-- --请求军械信息
-- function PartsProxy:ordnanceInfosReq(data)
--     self:sendServerMessage(AppEvent.NET_M13, AppEvent.NET_M13_C130101, data)
-- end

--碎片合成
function PartsProxy:pieceCompoundReq(data)
    self:sendServerMessage(AppEvent.NET_M13, AppEvent.NET_M13_C130102, data)
end

--碎片分解
function PartsProxy:pieceResolveReq(data)
    self:sendServerMessage(AppEvent.NET_M13, AppEvent.NET_M13_C130103, data)
end

--军械穿戴
function PartsProxy:ordnanceEquipedReq(data, doPanelName)
    self._doPanelName = doPanelName -- 区分在什么页面执行穿戴。执行不同的回调
    self._sendUpId = data.id
    self:sendServerMessage(AppEvent.NET_M13, AppEvent.NET_M13_C130104, data)
end

--军械卸下
function PartsProxy:ordnanceUnwieldReq(data)
    self._sendDownId = data.id
    self:sendServerMessage(AppEvent.NET_M13, AppEvent.NET_M13_C130105, data)
end

--军械分解
function PartsProxy:ordnanceResolveReq(data)
    self:sendServerMessage(AppEvent.NET_M13, AppEvent.NET_M13_C130106, data)
end

--军械强化
function PartsProxy:ordnanceStrengthenReq(data)
    self:sendServerMessage(AppEvent.NET_M13, AppEvent.NET_M13_C130107, data)
end

--军械改造
function PartsProxy:ordnanceRemouldReq(data)
    self:sendServerMessage(AppEvent.NET_M13, AppEvent.NET_M13_C130108, data)
end

--军械进阶
function PartsProxy:ordnanceEvolveReq(data)
    self:sendServerMessage(AppEvent.NET_M13, AppEvent.NET_M13_C130109, data)
end

--晶石兑换物品
function PartsProxy:onTriggerNet130110Req(data)
    self:sendServerMessage(AppEvent.NET_M13, AppEvent.NET_M13_C130110, data)
end

----------外部调用方法-------------
--获取碎片信息
function PartsProxy:getPieceInfos()
    --先排序
    if self._pieceInfos then
        table.sort(self._pieceInfos,sortPiece)
    end 
    return self._pieceInfos
end

--获取已装备的军械
function PartsProxy:getOrdnanceEquipedInfos()
    local t = nil
    if self._ordnanceInfos == nil then return t end 
    t = {}
    -- local count = 0
    for _,v in pairs(self._ordnanceInfos) do
        if v.position == 1 then --军械装备中
            table.insert(t,v)

            -- count = count + 1
            -- print("初始化 ··· id, typeid, type, part, position", v.id, v.typeid, v.type, v.part, v.position)
        end 
    end

    -- print("获取已装备 ··· count", count)

    return t
end

--获取未装备的军械
function PartsProxy:getOrdnanceUnEquipInfos()
    local t = nil
    if self._ordnanceInfos == nil or table.size(self._ordnanceInfos) == 0 then 
        return t 
    end 
    t = {}
    for _,v in pairs(self._ordnanceInfos) do
        if v.position == 0 then --在仓库
            table.insert(t,v)
        end 
    end 
    table.sort(t,sortParts)
    return t
end

--获取佣兵类型的装备上的军械
function PartsProxy:getOrdnanceInEquipByType(type)
    local list = {}
    for _, ordnanceInfo in pairs(self._ordnanceInfos) do
    	if ordnanceInfo.type == type and ordnanceInfo.position ~= 0 then
    	    table.insert(list, ordnanceInfo)
    	end
    end
    return list
end

--获取军械碎片数量
function PartsProxy:getPieceNumByID(typeid)
    local num = 0
    if self._pieceInfos then
        for _,v in pairs(self._pieceInfos) do
            if v.typeid == typeid then
                num = v.num
                break
            end 
        end
    end 
--    print("num===",num)
    return num
end

--获取军械配置表数据
function PartsProxy:getDataFromOrdnanceConfig(parts)
    local part = parts.part
    local quality = parts.quality
    local sLv = parts.strgthlv
    local tLv = parts.remoulv
    local type = parts.type

    --提升、（初始生命，强化加成，改造加成）、（初始攻击，强化加成，改造加成）、（初始防护，强化加成，改造加成）、（初始穿刺，强化加成，改造加成）
    local data = {}
    data.life = 0.00
    data.attack = 0.00
    data.protection = 0.00
    data.puncture = 0.00
    data.name = ""
    data.isadvance = 0
    local t = ConfigDataManager:getConfigData(ConfigData.OrdnanceConfig)
    for _,v in pairs(t) do
        if v.part == part and v.quality == quality and v.type == type then 
            data.name = v.name
            data.isadvance = v.isadvance
            data.advanceitem = v.advanceitem
            local base1 = 100
            local base2 = 100
            local temp = {}
            if      part == 1 then --生命
                data.life = (v.hpRateIni+v.hpRateStr*sLv+v.hpRateRem*tLv)/base1
            elseif part == 2 then --攻击
                data.attack = (v.atkRateIni+v.atkRateStr*sLv+v.atkRateRem*tLv)/base1
            elseif part == 3 then --防御
                data.protection = (v.defIni+v.defStr*sLv+v.defRem*tLv)/base2
            elseif part == 4 then --穿刺
                data.puncture = (v.wreckIni+v.wreckStr*sLv+v.wreckRem*tLv)/base2
            elseif part == 5 then --生命、防御         
                data.life = (v.hpRateIni+v.hpRateStr*sLv+v.hpRateRem*tLv)/base1
                data.protection = (v.defIni+v.defStr*sLv+v.defRem*tLv)/base2
            elseif part == 6 then --攻击、穿刺
                data.attack = (v.atkRateIni+v.atkRateStr*sLv+v.atkRateRem*tLv)/base1
                data.puncture = (v.wreckIni+v.wreckStr*sLv+v.wreckRem*tLv)/base2
            elseif part == 7 then --攻击、生命  
                data.attack = (v.atkRateIni+v.atkRateStr*sLv+v.atkRateRem*tLv)/base1
                data.life = (v.hpRateIni+v.hpRateStr*sLv+v.hpRateRem*tLv)/base2
            elseif part == 8 then --防御、穿刺  
                data.protection = (v.defIni+v.defStr*sLv+v.defRem*tLv)/base1
                data.puncture = (v.wreckIni+v.wreckStr*sLv+v.wreckRem*tLv)/base2
            end 
            return data
        end 
    end 
end 

--获取 佣兵类型对应的军械加成属性值
function PartsProxy:getSoldierTypePowerMap(soldierType)
    local list = self:getOrdnanceInEquipByType(soldierType)
    
    local powerMap = {}
    powerMap[SoldierDefine.POWER_wreck] = 0
    powerMap[SoldierDefine.POWER_defend] = 0
    powerMap[SoldierDefine.POWER_hpMaxRate] = 0
    powerMap[SoldierDefine.POWER_atkRate] = 0
    for _, ordnance in pairs(list) do
        local ordConfig = ConfigDataManager:getConfigById(ConfigData.OrdnanceConfig,ordnance.typeid)
        --穿刺
        local wreck = ordConfig.wreckIni + 
            ordConfig.wreckStr * ordnance.strgthlv + ordConfig.wreckRem * ordnance.remoulv
        --防护
        local defend = ordConfig.defIni + 
            ordConfig.defStr * ordnance.strgthlv + ordConfig.defRem * ordnance.remoulv
        --攻击
        local atk = ordConfig.atkRateIni + 
            ordConfig.atkRateStr * ordnance.strgthlv + ordConfig.atkRateRem * ordnance.remoulv
        --生命
        local hp = ordConfig.hpRateIni + 
            ordConfig.hpRateStr * ordnance.strgthlv + ordConfig.hpRateRem * ordnance.remoulv
    
        powerMap[SoldierDefine.POWER_wreck] = powerMap[SoldierDefine.POWER_wreck] + wreck
        powerMap[SoldierDefine.POWER_defend] = powerMap[SoldierDefine.POWER_defend] + defend
        powerMap[SoldierDefine.POWER_hpMaxRate] = powerMap[SoldierDefine.POWER_hpMaxRate] + hp
        powerMap[SoldierDefine.POWER_atkRate] = powerMap[SoldierDefine.POWER_atkRate] + atk
    end
    
    return powerMap
end


--更新军械数据
function PartsProxy:_updateOrdnanceInfos(data)

    self:updateRedPoint() 

    local soldierProxy = self:getProxy(GameProxys.Soldier)
    soldierProxy:soldierMaxFightChange()
end 

--更新指定军械的数据
function PartsProxy:_updateOrdnanceInfos2(data)
    
    self:sendNotification("parts_event_equip_parts",data)
    self:updateRedPoint() 

    local soldierProxy = self:getProxy(GameProxys.Soldier)
    soldierProxy:soldierMaxFightChange()
end



--减少军械
function PartsProxy:_minusOrdnanceInfos(id)
    self:updateRedPoint()

    local soldierProxy = self:getProxy(GameProxys.Soldier)
    soldierProxy:soldierMaxFightChange()
end 

------table排序---
function sortParts(a,b)
    --1品质->2兵种->3部位->4强度
    if a.quality > b.quality then --品质
        return true
    elseif a.quality == b.quality then
        if a.type < b.type then --兵种
            return true
        elseif a.type == b.type then
            if a.part < b.part then --部位
                return true
            elseif a.part == b.part then
                if a.strength > b.strength then --强度
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

function sortPiece(a,b)
    local aPieceData = ConfigDataManager:getConfigById(ConfigData.OrdnancePieceConfig, a.typeid)  
    local bPieceData = ConfigDataManager:getConfigById(ConfigData.OrdnancePieceConfig, b.typeid)
    local aBigType = aPieceData.type
    local bBigType = bPieceData.type
    if aBigType > bBigType then --碎片类型
        return true
    elseif aBigType == 2 and bBigType == 2 then
        return aPieceData.ID < bPieceData.ID         
    elseif aBigType == 1 and bBigType == 1 then
        local aPartsData = ConfigDataManager:getConfigById(ConfigData.OrdnanceConfig, aPieceData.compound)  
        local bPartsData = ConfigDataManager:getConfigById(ConfigData.OrdnanceConfig, bPieceData.compound)
        --print("sortPiece(a,b)===",aPieceData.compound,bPieceData.compound,aPartsData,bPartsData)
        local aQuality = aPieceData.quality
        local aType = aPartsData.type
        local aPart = aPartsData.part
        local bQuality = bPieceData.quality
        local bType = bPartsData.type
        local bPart = bPartsData.part
        if aQuality > bQuality then --品质
            return true
        elseif aQuality == bQuality then
            if aType < bType then --兵种类型
                return true
            elseif aType == bType then
                return aPart < bPart --部位 
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


function PartsProxy:updateRedPoint()
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:checkOrdmamceRedPoint()
    --通知部队那边有军械数据改变
    self:sendNotification(AppEvent.PROXY_UPDATE_TEAM_OTHER_INFO, {})
end

function PartsProxy:getAllData()
    return self._ordnanceInfos
end

------
-- 获得属性字符表
function PartsProxy:initAttrData(configData)
    local tempNames = {}
    local sid = 8210
    for i=1,4,1 do
        local id = sid + i
        tempNames[i] = TextWords:getTextWord(id)
    end 
    local attrNames = {}
    local attrNums = {}

    if configData.life > 0 then
        table.insert(attrNames,tempNames[1])
        local numStr = configData.life .."%"
        table.insert(attrNums,numStr) 
    end 
    if configData.attack > 0 then
        table.insert(attrNames,tempNames[2])
        local numStr = configData.attack .."%"
        table.insert(attrNums,numStr) 
    end 
    if configData.protection > 0 then
        table.insert(attrNames,tempNames[3])
        table.insert(attrNums,configData.protection)   
    end 
    if configData.puncture > 0 then
        table.insert(attrNames,tempNames[4])
        table.insert(attrNums,configData.puncture)
    end 
    return attrNames, attrNums
end

------
-- 检查是否有可穿戴的装备
function PartsProxy:checkPartsBuildTip()
    -- 判断建筑是否开启
    local buildingProxy = self:getProxy(GameProxys.Building)
    local isOpen = buildingProxy:getBuildOpenByModuleName(ModuleName.PartsModule)
    if isOpen == false then
        return false
    end

    local state = false
    local count = 0 
    for pageIndex = 1 , 4 do
        count = self:getPageRedCount(pageIndex) + count
    end
    if count ~= 0 then
        state = true
    end


    return state
end


------
-- 获取每页应显示的红点，排除拥有但未解锁的槽位
-- pageIndex 页码，从1开始
function PartsProxy:getPageRedCount(pageIndex)
    -- 注意，有个坑，配置表顺序为骑步枪弓，显示要求却是步骑枪弓
    -- 数据修正
    if pageIndex == 1 then
        pageIndex = 2
    elseif pageIndex == 2 then
        pageIndex = 1
    end

    local count = 0 -- 红点个数
    -- 解锁等级限制表
    local tPartLimitLv = self:getOrdnancePartConfig()
    -- 获取角色等级
    local roleProxy = self:getProxy(GameProxys.Role)
    local playerLv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    local allPartHaveInfo = self:getAllPartHaveInfo()
    for i = 1 , 8 do -- 此处的8为槽位个数
        if allPartHaveInfo[pageIndex][i] == 2 then -- 未装备
            if playerLv >= tPartLimitLv[i] then
                count = count + 1 
            end
        end
    end

    return count
end


------
-- 返回所有穿戴状态
function PartsProxy:getAllPartHaveInfo()
    local allPartHaveInfo = {}
    local soldierBaseConfig = self:getSoldierBaseInfo()
    for _,v in ipairs(soldierBaseConfig) do
        --0无装备，1有装备，2可装备
        allPartHaveInfo[v.type] = {0,0,0,0,0,0,0,0}
    end 

    local unEquipInfos = self:getOrdnanceUnEquipInfos() -- 获取未装备的军械
    local equipedInfos = self:getOrdnanceEquipedInfos() -- 获取已装备的军械

    --检查部位是否有装备
    if equipedInfos ~= nil  then
        for _,v in pairs(equipedInfos) do
            allPartHaveInfo[v.type][v.part] = 1 -- 有设为1
        end 
    end 
    --检查是否有可装备的配件
    if unEquipInfos ~= nil then
        for _,v in pairs(unEquipInfos) do
            local tag = allPartHaveInfo[v.type][v.part]
            if tag == 0 then
                allPartHaveInfo[v.type][v.part] = 2 -- 可设为2
            end 
        end 
    end

    return allPartHaveInfo
end

-- 获取武将配置数据
function PartsProxy:getSoldierBaseInfo()
    local temp = {}
    local configData = ConfigDataManager:getConfigData("OrdnancePageConfig")
    for _,v in pairs(configData) do 
        local t = {}
        t.type = v.tankType
        t.name = v.tankName
        t.model= v.tankModel
        t.page = v.page
        temp[v.page] = t
    end 
    table.sort(temp,function(a,b) return a.page<b.page end)
    return temp
end 

--获取配件等级限制配置表
function PartsProxy:getOrdnancePartConfig()
    local temp = {}
    local t = ConfigDataManager:getConfigData(ConfigData.OrdnancePartConfig)
    for _,v in pairs(t) do
        temp[v.part] = v.openlv
    end 
    return temp
end