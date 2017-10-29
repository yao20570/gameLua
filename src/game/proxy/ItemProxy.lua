ItemProxy = class("ItemProxy", BasicProxy)
-- 可以批量使用的其他物品的类型枚举
ItemProxy.OTHER_CAN_BATCH = {
    [1] = 1,
    [2] = 2,
    [3] = 37
}

ItemProxy.USE_TYPE_NOT = 0      -- 不能使用 
ItemProxy.USE_TYPE_MANY = 1     -- 可批量使用 
ItemProxy.USE_TYPE_SINGLE = 2   -- 只能单独使用


function ItemProxy:ctor()
    ItemProxy.super.ctor(self)
    self.proxyName = GameProxys.Item
    self:resetAttr()
end

function ItemProxy:finalize( )
	-- body
	ItemProxy.super.ctor(self)
end

function ItemProxy:resetAttr()
    self._itemMap = {}
    self._itemInfo={}   --TODO，此数据无用
    self._maxCDMap = {}
end

------------网络数据请求与同步-------------
function ItemProxy:onTriggerNet80011Req(data)
    self:syncNetReq(AppEvent.NET_M8, AppEvent.NET_M8_C80011, data)
end
-- 道具使用
function ItemProxy:onTriggerNet90001Req(data)
    self:syncNetReq(AppEvent.NET_M9, AppEvent.NET_M9_C90001, data)
end

function ItemProxy:onTriggerNet90004Req(data)
    self:syncNetReq(AppEvent.NET_M9, AppEvent.NET_M9_C90004, data)
end

function ItemProxy:onTriggerNet90005Req(data)
    self:syncNetReq(AppEvent.NET_M9, AppEvent.NET_M9_C90005, data)
end

function ItemProxy:onTriggerNet90006Req(data)
    self:syncNetReq(AppEvent.NET_M9, AppEvent.NET_M9_C90006, data)
end

function ItemProxy:onTriggerNet90007Req(data)

    self:syncNetReq(AppEvent.NET_M9, AppEvent.NET_M9_C90007, data)

    self._legionContributionData = {}
    local newData = {}
    local itemInfo = ConfigDataManager:getConfigById(ConfigData.ItemConfig, data.typeId)
    if itemInfo == nil then
        return
    end
    local effect = StringUtils:jsonDecode(itemInfo.effect)
    newData.num = effect[1][1]*data.num
    newData.power = 407
    newData.typeid = 302 -- 同盟贡献值类型
    table.insert(self._legionContributionData, newData)
end

function ItemProxy:onTriggerNet100008Req(data)
    self:syncNetReq(AppEvent.NET_M10, AppEvent.NET_M10_C100008, data)
end

function ItemProxy:onTriggerNet90008Req(data)
    self:syncNetReq(AppEvent.NET_M9, AppEvent.NET_M9_C90008, data)
end

-- 道具CD信息
function ItemProxy:onTriggerNet90009Resp(data)
    if data.rs ~= 0 then
        return
    end
    
    for k, v in pairs(data.itemCDInfoList) do
        self:pushRemainTime(v.cdgroup, v.remainTime)
        self._maxCDMap[v.cdgroup] = v.allTime
    end 
end

-- 
function ItemProxy:getCDGroup(groupID)
    local remainTime = self:getRemainTime(groupID)
    local allTime = self._maxCDMap[groupID]
    return remainTime, allTime
end


function ItemProxy:initSyncData(data)
    ItemProxy.super.initSyncData(self, data)
    self:onRoleInfoResp(data)

    self:onTriggerNet90009Resp(data)
end

function ItemProxy:onTriggerNet80011Resp(data) --随机迁移城市
    if data.rs ~= 0 then
        return
    end
    self:sendNotification(AppEvent.PROXY_BAG_CHANGEPOINT, data)

    local soldierProxy = self:getProxy(GameProxys.Soldier)
    soldierProxy:clearAttackList()
end

function ItemProxy:onTriggerNet90001Resp(data)  --道具使用
    if data.rs ~= 0 then
        --print("错误码"..data.rs)
        --print("itembuffinfo"..data.itemBuffInfo.remainTime.." "..data.itemBuffInfo.buffType)
        return
    elseif data.rs == 0  and data.cdTime > 0 then
        local str =string.format(TextWords:getTextWord(5062),TimeUtils:getStandardFormatTimeString6(data.cdTime))
        self:showSysMessage(str)
    end
    self:onItemUseResp(data)

    -- Time:09.22  Q:2532 【优化】- 背包使用物品隐藏成功使用提示
    -- 物品使用成功之后飘文字控制
    -- self:showMsgAfterUse(data.typeId)
end

function ItemProxy:onTriggerNet90004Resp(data)  --道具使用发红包改名卡
    self:onItemUseResp(data)
    self:sendNotification(AppEvent.PROXY_BAG_ESPECIALUSE, data)

    if rawget(data,"name") ~= nil then  --使用改名道具，顺便更新下角色属性
        if data.typeId == 3331 then -- 角色改名卡才修改角色名字
            local roleProxy = self:getProxy(GameProxys.Role)
            roleProxy:updateRoleName(data)
        end
    end
end

function ItemProxy:onTriggerNet90005Resp(data)
    self:sendNotification(AppEvent.PROXY_BAG_SURFACEGOODSUSE, data)
end

function ItemProxy:onTriggerNet90008Resp(data)
    
end

function ItemProxy:onTriggerNet90007Resp(data)  --增加军团贡献度
    if data.rs ~= 0 then
        return 
    end
    if #self._legionContributionData > 0 then
        self:useItemAddResFly(self._legionContributionData)
    end
    self._legionContributionData = {}

    self:sendNotification(AppEvent.PROXY_BAG_LEGIONCONTRIBUTE, data)
end

function ItemProxy:onTriggerNet100008Resp(data)  --购买商品回调
    self:sendNotification(AppEvent.PROXY_BUYGOODS_UPDATE, data)
end

function ItemProxy:onTriggerNet30104Resp(data) --仓库满了提示
    self:showSysMessage(TextWords:getTextWord(563))
end


--初始化背包ItemMap
function ItemProxy:onRoleInfoResp(data)
    self._itemMap = {}
    self._itemInfo={}
    local itemList = data.itemList
    self:updateItemInfos(itemList)
end

--面板更新
function ItemProxy:onItemUseResp(data)
    local iteminfos = data.iteminfos
    self:updateItemInfos(iteminfos)
end
--外部的proxy会调用
function ItemProxy:updateItemInfos(itemList)

    local addItemIdList = {}
    local updateItemIdList = {}
    local removeItemIdList = {}
    
    for _, itemInfo in pairs(itemList) do
        if itemInfo.num == 0 then --0表示物品被删除了
            table.insert(removeItemIdList, itemInfo.typeid)
            self._itemMap[itemInfo.typeid] = nil
        else
            if self._itemMap[itemInfo.typeid] == nil then
                table.insert(addItemIdList, itemInfo.typeid)
            else
                table.insert(updateItemIdList, itemInfo.typeid)
            end
            self._itemMap[itemInfo.typeid] = itemInfo
        end
        -- 更新物品数量改变后响应的红点刷新
        self:updateCountChangeRedPoint(itemInfo) 
    end
    
    local data = {}
    data.addItemIdList = addItemIdList
    data.updateItemIdList = updateItemIdList
    data.removeItemIdList = removeItemIdList

    self:sendNotification(AppEvent.PROXY_ITEMINFO_UPDATE, data)
    self:updateRedPoint() --背包的小红点更新
end

--TODO
--通过类型ID，拿到道具数量
function ItemProxy:getItemNumByType(typeid)
    local itemNumber = self:getItemNum()
    for k, v in pairs(itemNumber) do
    	if k == typeid then
    	    return itemNumber[k] 
    	end
    end
    return 0 --没有数量
end

--TreasureModule调用
function ItemProxy:setItemNumByType(typeid,num)
    if typeid == typeid then
        if num > 0 then
            if self._itemMap[typeid] then
                self._itemMap[typeid].num = num
            else
                self._itemMap[typeid] = {}
                self._itemMap[typeid].num = num 
                self._itemMap[typeid].typeid = typeid
            end
        else
            self._itemMap[typeid] = nil
        end
    end 
end


function ItemProxy:getItemByType(typeid)
    return self._itemMap[typeid]
end

--匹配num数据排列
function ItemProxy:getItemNum()
    local  itemNum = {}
    for _,v in pairs(self._itemMap) do
        if v.num == 0 then --0表示物品被删除了
            itemNum[v.typeid] = nil
        else
            itemNum[v.typeid] = v.num
        end
    end
    return itemNum
end
--获取所有的物品数据s
function ItemProxy:getAllItemList()
    local list = {}      
    for _, item in pairs(self._itemMap) do   
        local info = ConfigDataManager:getConfigById(ConfigData.ItemConfig, item.typeid)
        if info.ShowType ~= 4 and info.bagType == ItemBagTypeConfig.COMMON_BAG then
            item["sequence"] = info.sequence
            table.insert(list, item)
        end
    end
    table.sort( list, function (a,b) return a.sequence > b.sequence end )
    return list
end
--TODO 通过分类拿到对应的物品数据
--1资源 2增益 3其他 4背包不显示道具
--bagType 背包类型 1正常背包 2宝具  3军械
function ItemProxy:getItemByClassify(classifyid, bagType)
    --分类   
    bagType = bagType or ItemBagTypeConfig.COMMON_BAG
    local itemList = {}
    for _, item in pairs(self._itemMap) do
        local typeid = item.typeid
        local info = ConfigDataManager:getConfigById(ConfigData.ItemConfig, typeid)
        if info.ShowType == classifyid and info.bagType == bagType then
            local data = {}
            data["serverData"] = item
            data["excelInfo"] = info
            data["sequence"] = info.sequence
            table.insert(itemList, data)
        end
    end
    table.sort( itemList, function (a,b) return a.sequence > b.sequence end )
    return itemList
end

--是否能够在背包中直接使用
function ItemProxy:isCanUse(typeid)
    local info = ConfigDataManager:getConfigById(ConfigData.ItemConfig, typeid)    
    flag = info.use > ItemProxy.USE_TYPE_NOT --直接配置表
    return flag
end

------
-- 其他道具类是否可以批量使用
-- @param  itemType [int] 道具类型
-- @return state [bool]
function ItemProxy:isOthenCanBatch(itemType)
    local state = false
    for key, value in pairs(ItemProxy.OTHER_CAN_BATCH) do
        if value == itemType then
            state = true
            break
        end
    end
    return state
end


--背包的小红点更新
function ItemProxy:updateRedPoint()
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:checkBagRedPoint()
    redPointProxy:setGetLotOfMoneyRed()--限时活动财源广进小红点
end

-- 更新物品数量改变后响应的红点刷新
function ItemProxy:updateCountChangeRedPoint(itemInfo)
    -- 点兵（奇兵/神兵）硬币变更、只解决外部红点刷新问题
    if itemInfo.typeid == 4014 or itemInfo.typeid == 4042 then
        local redPointProxy = self:getProxy(GameProxys.RedPoint)
        redPointProxy:checkFreeFindBoxRedPoint()
        self:sendNotification(AppEvent.PROXY_ITEM_COIN_COUNT_UPDATE, itemInfo)
    end
end

-- 90001道具使用成功飘字.
function ItemProxy:showMsgAfterUse(typeId)
    -- body
    local info = ConfigDataManager:getConfigById(ConfigData.ItemConfig, typeId)
    local str = string.format(TextWords:getTextWord(5050), info.name)
    self:showSysMessage(str)
end

-- 缓存当前道具在列表中的位置
function ItemProxy:setCurIndex(index)
    -- body
    if index == nil then
        index = 0
    end
    self._curIndex = index
end

-- 获取当前道具在列表中的位置
function ItemProxy:getCurIndex()
    -- body
    if self._curIndex == nil then
        return 0
    else
        return self._curIndex
    end
end

function ItemProxy:sortList(itemList)
	local data = TableUtils:splitData(itemList, 2)
	return data
end 

-------
-- 没有走20007增加资源的，且要求进行飘窗：例 使用军团贡献道具
-- @格式：data.typeId , data.num, data.power// tempData.rewards = data
function ItemProxy:useItemAddResFly(data)
    local tempData = {}
    tempData.rewards = data
    AnimationFactory:playAnimationByName("BagFreshFly", tempData)
end


-- 是否为合成道具
function ItemProxy:isSpeItem(type)
    if type == 41 then
        return true
    end
    return false
end

-- 获取合成道具表数据
function ItemProxy:getSynthetizeData(id)
    local config = ConfigDataManager:getConfigById(ConfigData.SynthetizeConfig,id)
    return config
end

-- 读取合成道具id
function ItemProxy:getComposeID(typeId)
    local itemInfo = ConfigDataManager:getConfigById(ConfigData.ItemConfig, typeId)
    local effect = StringUtils:jsonDecode(itemInfo.effect)
    local composeID = effect[1][1]
    return composeID
end


-- 请求合成道具的提示语
function ItemProxy:composeMsg(typeId,curNum)
    local id = self:getComposeID(typeId)
    local config = self:getSynthetizeData(id)
    local cost = StringUtils:jsonDecode(config.costID)
    local needNum = cost[1][3]
    
    if curNum < needNum then
        self:showSysMessage(TextWords[5055])  --数量不足，无法合成
        return nil
    end

    local needInfo = ConfigDataManager:getConfigById(ConfigData.ItemConfig, cost[1][2])
    local needName = needInfo.name

    local target = StringUtils:jsonDecode(config.targetID)
    local targetNum = target[1][3]
    local targetInfo = ConfigDataManager:getConfigById(ConfigData.ItemConfig, target[1][2])
    local targetName = targetInfo.name

    local info = string.format(TextWords[5061],needNum,needName,targetNum,targetName)
    return info
end

-- 请求合成道具
function ItemProxy:compose(typeId)
    local composeID = self:getComposeID(typeId)
    local data = {}
    data.typeId = composeID
    self:onTriggerNet90008Req(data)
end


