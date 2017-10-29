BuildingProxy = class("BuildingProxy", BasicProxy)

------内部简单的宏定义----做逻辑判断的时候需要定义-------
BuildingProxy.AUTO_BUILD_ON = 1 --自动建筑开启
BuildingProxy.AUTO_BUILD_OFF = 0 --自动建筑关闭

function BuildingProxy:ctor()
    BuildingProxy.super.ctor(self)
    self.proxyName = GameProxys.Building

    self._eventCenter = MsgCenter.new()
    
    self._curBuildingType = 0  --当前查看的建筑ID
    self._curBuildingIndex = 0 --当前查看的建筑index
    
    self._curCommandLv = 0 --当前司令部等级

    self._autoBuildState = 0 --自动建筑状态 1开启，0关闭
    self._autoBuildRemainTime = 0 --自动建筑的剩余时间，关闭时用这个值
    
    self._buildingInfoMap = {}
    -- self._newBuildingMap = {}  --建造的建筑数据 缓存
    self._hideUpdateBuildList = {}  --主城未打开时更新的建筑信息
end

function BuildingProxy:resetAttr()
    BuildingProxy.super.resetAttr(self)
    
    -- 在引导过程中先不移除相关监听
    local isGuidingUnreset = GuideManager:isGuidingUnreset() 
    if isGuidingUnreset ~= true then  
        self._eventCenter:reset()
    end

    self._buildingInfoMap = {}
end

function BuildingProxy:clearEvent()
    self._eventCenter:reset()
end

---------------实例变量赋值接口---------getter,setter----------------------

--设置当前建筑位置
function BuildingProxy:setBuildingPos(buildingType, buildingIndex)
    self._curBuildingType = buildingType
    self._curBuildingIndex = buildingIndex
    logger:info("--设置当前建筑位置 %d %d",buildingType, buildingIndex)
end

--设置自动建筑状态
function BuildingProxy:setAutoBuildState(state)
    self._autoBuildState = state
end

function BuildingProxy:getAutoBuildState()
    return self._autoBuildState
end

function BuildingProxy:setAutoBuildRemainTime(remainTime)
    self._autoBuildRemainTime = remainTime
end

--#########################网络同步数据操作################################

function BuildingProxy:initSyncData(data)
    BuildingProxy.super.initSyncData(self, data)
    self.afterData = data
end

function BuildingProxy:afterInitSyncData()
    data = self.afterData
    BuildingProxy.super.afterInitSyncData(self, data)
    self:resetAttr()
    
    local buildingInfos = data.buildingInfos

    for _,buildingInfo in pairs(buildingInfos) do
        self:_updateBuildingInfo(buildingInfo, true)

        if buildingInfo.levelTime > 0 then
            self:updateLvUpRemainTime(buildingInfo.buildingType, buildingInfo.index, buildingInfo.levelTime)
        end
        
        for _, productionInfo in pairs(buildingInfo.productionInfos) do
            self:updateProductRemainTime(buildingInfo.buildingType,
                buildingInfo.index, productionInfo.order, productionInfo.remainTime )
        end 
    end
    
    -----将等级为0的建筑，空地数据-由客户端自己实例化----------------
    --主城建筑
    local buildOpenConfig = ConfigDataManager:getConfigData(ConfigData.BuildOpenConfig)
    for _, info in pairs(buildOpenConfig) do
        if info.type == 2 then
            break --铸币所跳过
        end
        local buildingInfo = self:getBuildingInfo(info.type, info.ID)
        if buildingInfo ~= nil and buildingInfo.level == 0 then
            logger:error("=========建筑等级为0的建筑，服务端不用发了！===:%d=>%d===============", info.type, info.ID)
        elseif buildingInfo == nil then --
            buildingInfo = self:_createNewBuildingInfo(info.type, info.ID)
            self:_updateBuildingInfo(buildingInfo, true)
        end
    end
    -----野外建筑
    --官邸建筑，获取野外建筑的建筑
    local buildingInfo = self:getBuildingInfo(1, 1) -- 官邸的相关等级
    local rlist = ConfigDataManager:getConfigData(ConfigData.BuildBlankConfig)
    local openList = {}
    for _, json in pairs(rlist) do
        if buildingInfo.level >= json.openlv then
            table.insert(openList, json.ID)
        end
    end
    for _, id in pairs(openList) do
        local fieldInfo = self:getFieldBuildingInfo(id)
        if fieldInfo ~= nil and fieldInfo.buildingType == 0 then
            logger:error("======空地，服务端不用发了！===:%d=====", id)
        elseif fieldInfo == nil then
            buildingInfo = self:_createNewBuildingInfo(0, id)
            self:_updateBuildingInfo(buildingInfo, true)
        end
    end
    
    local autoUpgradeInfo = data.autoUpgradeInfo
    self:setAutoBuildState(autoUpgradeInfo.type)
    if autoUpgradeInfo.type == 1 then 
        self:updateAutoBuildRemainTime(autoUpgradeInfo.autoRemainTime)
        self:_triggerAutoBuild()
    end
    self:setAutoBuildRemainTime(autoUpgradeInfo.autoRemainTime)
    self:onTriggerNet280015Req()

    local soldierProxy = self:getProxy(GameProxys.Soldier)
    soldierProxy:setMaxFighAndWeight()

end

--建筑升级、建筑请求返回
function BuildingProxy:onTriggerNet280001Resp(data)
    for _,buildingShortInfo in pairs(data.buildingShortInfos) do
        if buildingShortInfo.rs == 0 then
            local index = buildingShortInfo.index
            local buildingType = buildingShortInfo.buildingType
            --TODO 野外的建筑可能没数据，要做逻辑
            local curBuildingInfo = self:getBuildingInfo(buildingType, index)
            if curBuildingInfo == nil then --野外建造，改变建筑类型
                curBuildingInfo = self:_changeBuildingType(0, index, buildingType) --
                local upTime = self:getBuildingUpLevelTime(buildingType, curBuildingInfo.level)
                curBuildingInfo.upTime = upTime
            end
            --升级时间
            curBuildingInfo.levelTime = self:getBuildingUpLevelTime(buildingType, curBuildingInfo.level)
            self:updateLvUpRemainTime(buildingType, index, curBuildingInfo.levelTime)
            self:_updateBuildingInfo(curBuildingInfo)

        else --TODO时间校验
            self:errorCodeHandler(AppEvent.NET_M28_C280001, buildingShortInfo.rs)
        end
        
    end
    
    if #data.buildingShortInfos > 0 then
        self:sendNotification(AppEvent.PROXY_BUILDING_MULT_UPDATE, {}) --多个建筑更新
    end
end

-- -- 缓存建造的建筑数据
-- function BuildingProxy:updateNewBuildingInfo(buildingType,index,buildingInfo)
--     -- body
--     if self._newBuildingMap[buildingType] == nil then
--         self._newBuildingMap[buildingType] = {}
--     end
--     self._newBuildingMap[buildingType][index] = buildingInfo
-- end

-- -- 获取建造的建筑数据
-- function BuildingProxy:getNewBuildingMap()
--     -- body
--     local buildingMap = {}
--     for k,buildingInfoList in pairs(self._newBuildingMap) do
--         for _,buildingInfo in pairs(buildingInfoList) do
--             table.insert(buildingMap,buildingInfo)
--         end
--     end

--     return buildingMap
-- end

-- 更新主城未显示缓存的建筑数据
function BuildingProxy:setHideUpdateBuildInfo(buildingType,index,buildingInfo)
    -- body
    if self._hideUpdateBuildList[buildingType] == nil then
        self._hideUpdateBuildList[buildingType] = {}
    end
    self._hideUpdateBuildList[buildingType][index] = buildingInfo
end

-- 获取主城未显示缓存的建筑数据
function BuildingProxy:getHideUpdateBuildList()
    -- body
    local buildingMap = {}
    for k,buildingInfoList in pairs(self._hideUpdateBuildList) do
        for _,buildingInfo in pairs(buildingInfoList) do
            table.insert(buildingMap,buildingInfo)
        end
    end

    return buildingMap
end

function BuildingProxy:onTriggerNet280016Resp(data)
    for _, buildingShortInfo in pairs(data.buildingShortInfos) do
        if buildingShortInfo.rs == 0 then
            local buildingType = buildingShortInfo.buildingType
            local index = buildingShortInfo.index
            local curBuildingInfo = self:getBuildingInfo(buildingType, index)
            curBuildingInfo.level = buildingShortInfo.level
            curBuildingInfo.levelTime = buildingShortInfo.levelTime
            self:_updateBuildingInfo(curBuildingInfo)
            self:updateLvUpRemainTime(buildingType, index, curBuildingInfo.levelTime)
        end
    end
end

--###############建筑完成升级返回
function BuildingProxy:onTriggerNet280002Resp(data)
    for _,buildingShortInfo in pairs(data.buildingShortInfos) do
        if buildingShortInfo.rs == 0 then
            local buildingType = buildingShortInfo.buildingType
            local index = buildingShortInfo.index
    
            self:updateLvUpRemainTime(buildingType, index, 0) --删除定时器
            
            self:deleteHelpInfos(index,buildingType)

            local curBuildingInfo = self:getBuildingInfo(buildingType, index)
            -- curBuildingInfo = clone(curBuildingInfo) --这里要克隆一个新的，不然由于同个引用，下面更新数据前，算出最大等级时，有问题
            
            local lastMaxLv = nil
            if buildingType == BuildingTypeConfig.BARRACK then
                lastMaxLv = self:getBuildingMaxLvByType(BuildingTypeConfig.BARRACK)
            end

            curBuildingInfo.level = curBuildingInfo.level + 1
            curBuildingInfo.levelTime = 0
            self:_updateBuildingInfo(curBuildingInfo, nil, nil, lastMaxLv)
            self:_buildingUpgrade(buildingType, index)
            
            -- if curBuildingInfo.level == 1 then  --建造完成
            --     logger:info("建筑完成。。。。00")
            --     self:updateNewBuildingInfo(buildingType,index,curBuildingInfo)
            -- end

        elseif buildingShortInfo.rs == -3 then --TODO时间校验
            self:updateLvUpRemainTime(buildingShortInfo.buildingType, 
                buildingShortInfo.index, buildingShortInfo.levelTime)
            -- self:errorCodeHandler(AppEvent.NET_M28_C280002, buildingShortInfo.rs)
        end
    end
    
    if #data.buildingShortInfos > 0 then
        self:_triggerAutoBuild()
        self:sendNotification(AppEvent.PROXY_BUILDING_MULT_UPDATE, {})
    end
    
end

--#############取消建筑升级
function BuildingProxy:onTriggerNet280003Resp(data)
    if data.rs == 0 then
        local buildingType = data.buildingType
        local index = data.index
        self:deleteHelpInfos(index,buildingType)
        self:updateLvUpRemainTime(buildingType, index, 0) --删除定时器

        local curBuildingInfo = self:getBuildingInfo(buildingType, index)
        curBuildingInfo.levelTime = 0

        -- 取消铸币所建造，按拆除逻辑处理
        local isGoldBuilding = false
        if buildingType == 2 and index == 1 and curBuildingInfo.level == 0 then
            self:_changeBuildingType(curBuildingInfo.buildingType, curBuildingInfo.index, 0)
            --将建筑数据，还原到默认数据
            curBuildingInfo.level = 0
            curBuildingInfo.buildingType = 0   --0为空地类型
            curBuildingInfo.levelTime = 0
            isGoldBuilding = true
        end

        self:_updateBuildingInfo(curBuildingInfo)
        self:_triggerAutoBuild()
        self:sendNotification(AppEvent.PROXY_BUILDING_MULT_UPDATE, {})

        if isGoldBuilding == true then
            self:sendNotification(AppEvent.BUILDING_CANCEL_UPDATE, {})
        end

    end
end

--##########建筑加速升级
function BuildingProxy:onTriggerNet280004Resp( data )
    if data.rs == 0 then
        local buildingType = data.buildingType
        local index = data.index
        local curBuildingInfo = self:getBuildingInfo(buildingType, index)
        curBuildingInfo.levelTime = data.levelTime

        local lastMaxLv = nil
        if data.levelTime == 0 then --证明建筑升级已经完成了，直接升级
            self:deleteHelpInfos(index,buildingType)
            -- curBuildingInfo = clone(curBuildingInfo) --这里要克隆一个新的，不然由于同个引用，下面更新数据前，算出最大等级时，有问题
            
            if buildingType == BuildingTypeConfig.BARRACK then
                lastMaxLv = self:getBuildingMaxLvByType(BuildingTypeConfig.BARRACK)
            end
            curBuildingInfo.level = curBuildingInfo.level + 1
        else
            
        end

        --更新倒计时，0的话，会删除掉
        self:updateLvUpRemainTime(buildingType, index, data.levelTime)
        self:_updateBuildingInfo(curBuildingInfo, nil, nil, lastMaxLv)
        
        if data.levelTime == 0 then --升级完成，触发自动建筑
            self:_buildingUpgrade(buildingType, index)
            self:_triggerAutoBuild()
        end

        self:sendNotification(AppEvent.PROXY_BUILDING_MULT_UPDATE, {})

    end
end

---#######建筑野外拆除返回
function BuildingProxy:onTriggerNet280005Resp(data)
    if data.rs == 0 then
        local index = data.index
        local curBuildingInfo = self:getFieldBuildingInfo(index)
        self:_changeBuildingType(curBuildingInfo.buildingType, curBuildingInfo.index, 0)
        --将建筑数据，还原到默认数据
        curBuildingInfo.level = 0
        curBuildingInfo.buildingType = 0   --0为空地类型
        curBuildingInfo.levelTime = 0

        self:_updateBuildingInfo(curBuildingInfo)

        self:_triggerAutoBuild()
        self:sendNotification(AppEvent.PROXY_BUILDING_MULT_UPDATE, {})
    end
end

-----#######建筑生产请求返回
function BuildingProxy:onTriggerNet280006Resp(data)
     if data.rs == 0 then
        local buildingType = data.buildingType
        local index = data.index
        local productionInfo = data.productionInfo
        local curBuildingInfo = self:getBuildingInfo(buildingType, index)
        if #curBuildingInfo.productionInfos == 0 then
            curBuildingInfo.productionInfos = {}
        end
        table.insert(curBuildingInfo.productionInfos, productionInfo)

        if productionInfo.state == 1 then --生产中，设置定时器
            local remainTime = self:getBuildingProductionTime(buildingType, index, 
                productionInfo.typeid, productionInfo.num)
            self:updateProductRemainTime(buildingType, index, productionInfo.order, remainTime)
        end

        self:_updateBuildingInfo(curBuildingInfo)

        
        local isShow = self:isModuleShow(ModuleName.BarrackModule)
        if isShow == true then
            self:sendNotification(AppEvent.PROXY_BUILDING_PROD_UPDATE, {})
        end

     end
end

--请求生产完成返回
function BuildingProxy:onTriggerNet280007Resp(data)
    if data.rs == 0 then
        local buildingType = data.buildingType
        local index = data.index
        --self:deleteHelpInfos(index,buildingType)
        local productionInfo = self:removeBuildingProduction(buildingType, index, data.order)
        self:updateProductRemainTime(buildingType, index, data.order, 0)
        self:_buildingProductionComplete(buildingType, index, productionInfo)

        if data.nextOrder > 0 then --还有下一个可以生产的，继续生产
            local productionInfo = self:startBuildingProduction(buildingType, index, data.nextOrder)
            self:updateProductRemainTime(buildingType, index, productionInfo.order, productionInfo.remainTime)
        end

        local buildingInfo = self:getBuildingInfo(buildingType, index)
        self:_updateBuildingInfo(buildingInfo)

    elseif data.rs == -2 then --TODO 时间校验错误码时
        self:updateProductRemainTime(data.buildingType, data.index, data.order, data.remainTime)
    end
end
--在帮助队列里剔除
function BuildingProxy:deleteHelpInfos(index,buildingType)
    local legionHelpProxy = self:getProxy(GameProxys.LegionHelp)
    legionHelpProxy:deleteHelpInfos(index,buildingType)
end
    
--取消生产返回
function BuildingProxy:onTriggerNet280008Resp(data)
    if data.rs == 0 then
        local buildingType = data.buildingType
        local index = data.index
        
        self:removeBuildingProduction(buildingType, index, data.order)
        self:updateProductRemainTime(buildingType, index, data.order, 0)

        if data.nextOrder > 0 then --还有下一个可以生产的，继续生产
            local productionInfo = self:startBuildingProduction(buildingType, index, data.nextOrder)
            self:updateProductRemainTime(buildingType, index, productionInfo.order, productionInfo.remainTime)
        end

        local buildingInfo = self:getBuildingInfo(buildingType, index)
        self:_updateBuildingInfo(buildingInfo)
    end
end

--加速生产返回
function BuildingProxy:onTriggerNet280009Resp(data)
    if data.rs == 0 then
        local buildingType = data.buildingType
        local index = data.index

        if data.remainTime == 0 then
            self:updateProductRemainTime(buildingType, index, data.order, 0)
            local productionInfo = self:removeBuildingProduction(buildingType, index, data.order)
            self:_buildingProductionComplete(buildingType, index, productionInfo)
            if data.nextOrder > 0 then --还有下一个可以生产的，继续生产
                local productionInfo = self:startBuildingProduction(buildingType, index, data.nextOrder)
                self:updateProductRemainTime(buildingType, index, productionInfo.order, productionInfo.remainTime)
            end
            
            local buildingInfo = self:getBuildingInfo(buildingType, index)
            self:_updateBuildingInfo(buildingInfo)
        else
            self:updateProductRemainTime(buildingType, index, data.order, data.remainTime)
        end
    end
end

--VIP购买建筑位
function BuildingProxy:onTriggerNet280011Resp(data)
    if data.rs == 0  then
        if data.type == 1 then --开启了自动升级了
            self:updateAutoBuildRemainTime(data.autoRemainTime)
            
            self:_triggerAutoBuild()
        end

        self:setAutoBuildState(data.type)
        self:setAutoBuildRemainTime(data.autoRemainTime)

        --TODO待验证
        self:showSysMessage(TextWords:getTextWord(541))
        self._switchType = data.type  --自动升级建筑开关按钮
        local num = 1
        self:sendNotification(AppEvent.BUILDING_SUCCESS_UPDATE,num)
    end
end

--购买自动升级建筑
function BuildingProxy:onTriggerNet280012Resp(data)
    if data.rs == 0 then
        -- TODO：服务端逻辑设计有问题，在背包中使用也会下发280012的消息号
        if self:isModuleShow(ModuleName.BagModule) == false then 
            self:showSysMessage(TextWords:getTextWord(555)) -- 购买成功，获得4H自动
        end
        if data.type == 1 then --开启了自动升级了
            self:updateAutoBuildRemainTime(data.autoRemainTime)
            self:_triggerAutoBuild()
        else
            self:updateAutoBuildRemainTime(0) --关闭倒计时
            
        end
        
        self:setAutoBuildRemainTime(data.autoRemainTime)
        self:setAutoBuildState(data.type)

        --TODO待验证
        self._switchType = data.type  --自动升级建筑开关按钮
        local num = 1
        self:sendNotification(AppEvent.BUILDING_AUTO_UPGRATE,num)
    end
end

--自动升级建筑开关
--弹出购买自动升级对话框  客户端自己计算
function BuildingProxy:onTriggerNet280013Resp(data)
    local num = 2
    if data.rs == 0 then
        if data.type == 0 then --关闭了自动升级建筑
            self:updateAutoBuildRemainTime(0)
        else --开启
            self:updateAutoBuildRemainTime(data.autoRemainTime)
            self:_triggerAutoBuild()
        end

        self:setAutoBuildRemainTime(data.autoRemainTime)
        self:setAutoBuildState(data.type)
        --TODO待验证
        self._switchType = data.type  --自动升级建筑开关按钮
        self:showSysMessage(TextWords:getTextWord(543)) --操作成功
        num = 2 --操作成功

        self:sendNotification(AppEvent.BUILDING_AUTO_UPGRATE,num)
    else
        -- num = 3 --弹出购买自动升级对话框 
    end
end

--结束自动升级建筑了
function BuildingProxy:onTriggerNet280014Resp(data)
    local autoKey = self:getAutoBuildRemainKey()
    if data.rs == 0 then
        self:pushRemainTime(autoKey, 0)
    else --校验时间
        self:updateAutoBuildRemainTime(data.autoRemainTime)
    end
end
----------------req--UI层，直接调用协议请求--请求之前，客户端可能会再做一层判断
------------或者弹窗------------------
--建筑升级请求  UI逻辑里面的，不是自动升级触发的
function BuildingProxy:onTriggerNet280001Req(data)
    local index = data.index
    local type = data.type
    local buildingType = data.buildingType

    local isBuildingCanUpgrade = self:isBuildingCanUpgrade(buildingType, index, type)
    if isBuildingCanUpgrade == 0 then --客户端判断可以升级了，请求服务端升级
        local sendData = {}
        local buildingShortInfos = {}
        table.insert(buildingShortInfos, {buildingType = buildingType, index = index})
        sendData.buildingShortInfos = buildingShortInfos
        sendData.type = type
        self:syncNetReq(AppEvent.NET_M28, AppEvent.NET_M28_C280001, sendData)
    elseif isBuildingCanUpgrade == ErrorCodeDefine.M100001_6 then --建筑位不够，判断是否可以购买
        self:buyVipBuilding()
    else
        self:errorCodeHandler(AppEvent.NET_M28_C280001, isBuildingCanUpgrade)
    end
end

--取消建筑升级请求
function BuildingProxy:onTriggerNet280003Req(data)
    --TODO，这个客户端可以先行逻辑
    self:syncNetReq(AppEvent.NET_M28, AppEvent.NET_M28_C280003, data)
end

--建筑加速升级请求
function BuildingProxy:onTriggerNet280004Req(data)
    self:syncNetReq(AppEvent.NET_M28, AppEvent.NET_M28_C280004, data)
end

--野外建筑拆除请求
function BuildingProxy:onTriggerNet280005Req(data)
    self:syncNetReq(AppEvent.NET_M28, AppEvent.NET_M28_C280005, data)
end

--建筑生产 包括 兵营，校场，工匠坊，科技请求
function BuildingProxy:onTriggerNet280006Req(data)
    local isBuildingCanProduction = rawget(data,"isBuildingCanProduction")
    if isBuildingCanProduction == nil then
        isBuildingCanProduction = self:isBuildingCanProduction(data.buildingType, data.index)
    end
    data.isBuildingCanProduction = nil

    if isBuildingCanProduction == 0 then
        self:syncNetReq(AppEvent.NET_M28, AppEvent.NET_M28_C280006, data)
    else --TODO 弹错误码
        --太学院进这里，兵营、工匠坊、校场都提前return不进这里
        if data.buildingType == BuildingTypeConfig.SCIENCE then
            self:showSysMessage(TextWords:getTextWord(359))
        end
        -- self:errorCodeHandler(AppEvent.NET_M28_C280006, isBuildingCanProduction)
    end
end

--取消生产 请求
function BuildingProxy:onTriggerNet280008Req(data)
    self:syncNetReq(AppEvent.NET_M28, AppEvent.NET_M28_C280008, data)
end

--加速生产 请求
function BuildingProxy:onTriggerNet280009Req(data)
    self:syncNetReq(AppEvent.NET_M28, AppEvent.NET_M28_C280009, data)
end

--客户端自己判断是否可以购买VIP购买建筑位，且计算出价格
function BuildingProxy:onTriggerNet280011Req(data)
    --TODO
    self:syncNetReq(AppEvent.NET_M28, AppEvent.NET_M28_C280011, data)
end

--购买自动升级建筑
function BuildingProxy:onTriggerNet280012Req(data)
    self:syncNetReq(AppEvent.NET_M28, AppEvent.NET_M28_C280012, data)
end

--自动升级建筑开关
function BuildingProxy:onTriggerNet280013Req(data)
    self:syncNetReq(AppEvent.NET_M28, AppEvent.NET_M28_C280013, data)
end

---------------------------倒计时处理--------------------------------

--更新建筑升级的倒计时
function BuildingProxy:updateLvUpRemainTime(buildingType, index, remainTime)
    local key = self:getLvUpRemainKey(buildingType, index)
    local buildingShortInfo = {}
    buildingShortInfo.index = index
    buildingShortInfo.buildingType = buildingType
    self:pushRemainTime(key, remainTime, AppEvent.NET_M28_C280002, buildingShortInfo, 
        self.lvUpRemainTimeComplete)
end

--倒计时结束
function BuildingProxy:lvUpRemainTimeComplete(buildingShortInfos)
    print("===========倒计时结束==请求升级完成===============")
    local sendData = {}
    sendData.buildingShortInfos = buildingShortInfos
    self:syncNetReq(AppEvent.NET_M28, AppEvent.NET_M28_C280002, sendData)
end

--更新生产倒计时
function BuildingProxy:updateProductRemainTime(buildingType, index, order, remainTime)
    local sendData = {}
    sendData.buildingType = buildingType
    sendData.index = index
    sendData.order = order
    local key = self:getProductRemainKey(index, order)
    
    self:pushRemainTime(key, remainTime, AppEvent.NET_M28_C280007, sendData,
        self.productRemainTimeComplete)
end

--生产倒计时结束
function BuildingProxy:productRemainTimeComplete(sendDataList)
    for _,sendData in pairs(sendDataList) do
        self:syncNetReq(AppEvent.NET_M28, AppEvent.NET_M28_C280007, sendData)
    end
end

--更新自动建筑定时器
function BuildingProxy:updateAutoBuildRemainTime(remainTime)
    local key = self:getAutoBuildRemainKey()
    local sendData = {}
    self:pushRemainTime(key, remainTime,
        AppEvent.NET_M28_C280014, sendData, self.autoBuldRemainTimeComplete)
end

--自动建筑升级倒计时结束
function BuildingProxy:autoBuldRemainTimeComplete()
    self:syncNetReq(AppEvent.NET_M28, AppEvent.NET_M28_C280014, {})
end

--获取当前流水线的剩余时间
function BuildingProxy:getCurBuildingProLineReTime(order)
    local time = self:getBuildingProLineReTime(self._curBuildingIndex, order) 
    return time
end

function BuildingProxy:getBuildingProLineReTime(index, order)
    local key = self:getProductRemainKey(index, order)
    local remainTime = self:getRemainTime(key)
    return remainTime
end

--建筑升级剩余时间
function BuildingProxy:getBuildingUpReTime(buildingType, index)
    local key = self:getLvUpRemainKey(buildingType, index)
    local remainTime = self:getRemainTime(key)
    return remainTime
end

--当前建筑升级剩余时间
function BuildingProxy:getCurBuildingUpReTime()
    local time = self:getBuildingUpReTime(self._curBuildingType, self._curBuildingIndex)
    return time
end

--获取当前自动建筑的剩余时间
--收到自动建筑状态的影响
function BuildingProxy:getAutoBuildReTime()
    local remainTime = 0
    if self._autoBuildState == BuildingProxy.AUTO_BUILD_OFF then --自动建筑升级关闭
        remainTime = self._autoBuildRemainTime
    else
        local key = self:getAutoBuildRemainKey()
        remainTime = self:getRemainTime(key)
    end

    return remainTime
end

--获取建筑升级的倒计时key
function BuildingProxy:getLvUpRemainKey(buildingType, index)
    return "LvUp" .. buildingType .. "_" .. index
end

--获取建筑生产的倒计时key
function BuildingProxy:getProductRemainKey(index, order)
    return "Pro" .. index .. "_" .. order
end

--自动建筑的剩余时间key
function BuildingProxy:getAutoBuildRemainKey()
   return "AutoBuild"
end

----------外部调用方法-------------
--玩家属性更新后，触发的建筑相关逻辑
--会触发自动升级建筑等逻辑
function BuildingProxy:updateRoleInfo(updatePowerList)
    local powerlist = {}
    table.insert(powerlist, PlayerPowerDefine.POWER_tael)
    table.insert(powerlist, PlayerPowerDefine.POWER_wood)
    table.insert(powerlist, PlayerPowerDefine.POWER_iron)
    table.insert(powerlist, PlayerPowerDefine.POWER_stones)
    table.insert(powerlist, PlayerPowerDefine.POWER_food)

    local isIntersect = table.isIntersect(powerlist, updatePowerList)
    if isIntersect == true then
        self:_triggerAutoBuild()  --资源变化了，触发一下自动建筑；在不够资源时，会少于可建筑的位置
    end
end

--请求购买VIP建筑位弹窗
function BuildingProxy:buyVipBuilding()
    self:sendNotification(AppEvent.PROXY_BUILDING_BUY_FIELD, {})
end

--注册对应建筑改变事件
function BuildingProxy:registerBuilingInfoChangeEvent(buildingType, index, object, fun)
    self._eventCenter:addEventListener(buildingType, index, object, fun)
end
-- 注册监听事件
function BuildingProxy:registerCurBuilingInfoChangeEvent(object, fun)
    self:clearEvent()
    self._eventCenter:addEventListener(self._curBuildingType, self._curBuildingIndex, object, fun)
end

function BuildingProxy:getBuildingInfo(buildingType, index)
    if self._buildingInfoMap[buildingType] == nil then
        return nil
    end
    return self._buildingInfoMap[buildingType][index]
end

function BuildingProxy:getBuildingLevel(buildingType, index)
    if self._buildingInfoMap[buildingType] == nil then
        return 0
    end
    return self._buildingInfoMap[buildingType][index].level
end

--获取野外建筑信息
function BuildingProxy:getFieldBuildingInfo(index)
    local buildingInfo = nil
    for buildingType, buildingList in pairs(self._buildingInfoMap) do
        if self:isFieldBuilding(buildingType) then
            for i, building in pairs(buildingList) do
                if building.index == index then
                    buildingInfo = building
                    break
                end
            end
        end
        if buildingInfo ~= nil then
            break
        end
    end
    if buildingInfo == nil then
--        print("=====获取的建筑位数据是空的===========", index)
--        print_r(self._buildingInfoMap)
    end
    return buildingInfo
end

--获取建筑的升级时间
function BuildingProxy:getBuildingUpLevelTime(buildingType, level)
    local roleProxy = self:getProxy(GameProxys.Role)
    local info = self:getBuildingConfigInfo(buildingType, level)
    if info == nil then
        return 0
    end
    local time = info.time
    local buildspeedrate = roleProxy:getRoleAttrValue(PlayerPowerDefine.NOR_POWER_buildspeedrate)
    time = math.ceil(time / (1 + buildspeedrate / 100.0))
    return time
end

-- 获取某一类型的所有建筑信息
function BuildingProxy:getOneTypeBuildingInfo(buildingType)
    if self._buildingInfoMap[buildingType] == nil then
        return nil
    end
    
    if  table.size ( self._buildingInfoMap[buildingType] ) == 0 then
        return nil
    end
    
    return self._buildingInfoMap[buildingType]
end


function BuildingProxy:getCurBuildingInfo()
    local buildingType = self._curBuildingType  -- 9
    local index = self._curBuildingIndex        -- 2
    return self:getBuildingInfo(buildingType, index)
end

--获取当前建筑的配置属性
function BuildingProxy:getCurBuildingConfigInfo()
    local buildingInfo = self:getCurBuildingInfo()
    local buildingType = buildingInfo.buildingType
    local level = buildingInfo.level
    
    local info = self:getBuildingConfigInfo(buildingType, level)
    
    return info
    
end

function BuildingProxy:getBuildingConfigInfo(buildingType, level)
    local buildConfigName = ConfigData.BuildResourceConfig
    if self:isFieldBuilding(buildingType) == true then --资源建筑
        --资源建筑
        buildConfigName = ConfigData.BuildResourceConfig
    elseif buildingType == BuildingTypeConfig.COMMAND 
      or buildingType == BuildingTypeConfig.WAREHOUSE then --官邸、仓库也属于资源
        buildConfigName = ConfigData.BuildResourceConfig
    else --功能建筑
        buildConfigName = ConfigData.BuildFunctionConfig
    end

    local info = ConfigDataManager:getInfoFindByTwoKey(
        buildConfigName,"type",buildingType,"lv",level)

    -- if info == nil then
    --     info = ConfigDataManager:getInfoFindByTwoKey(
    --         ConfigData.BuildResourceConfig,"type",buildingType,"lv",level)
    -- end
    
    return info
end

--该建筑是否最高等级了
function BuildingProxy:isBuildingMaxLevel(buildingType, index)
    local buildingInfo = self:getBuildingInfo(buildingType, index)
    local info = self:getBuildingConfigInfo(buildingType, buildingInfo.level + 1)
    if info == nil then
        return true
    end
    return false
end

function BuildingProxy:getCurBuildingDetailInfo(typeid)
    local curBuildingInfo = self:getCurBuildingInfo()
    if curBuildingInfo == nil then
        return {num = 0, typeid = typeid}
    end
    
    local result = nil
    local buildingDetailInfos = curBuildingInfo.buildingDetailInfos
    for _, buildingDetailInfo in pairs(buildingDetailInfos) do
    	if buildingDetailInfo.typeid == typeid then
            result = buildingDetailInfo
            break
    	end
    end
    
    return result
end

--获取建筑生产所对应的配置表
function BuildingProxy:getBuildingProConfigName(buildingType)
    local configName = ""

    local info = ConfigDataManager:getInfoFindByOneKey(
        ConfigData.BuildSheetConfig, "type", buildingType)
    
    if info.prosheet == nil then
        return nil
    end

    return info.prosheet .. "Config"
end

--获取当前建筑生产所对应的配置表
function BuildingProxy:getCurBuildingProConfigName()
    return self:getBuildingProConfigName(self._curBuildingType)
end

function BuildingProxy:getBuildingMaxLvByType(buildingType)
    local maxLv = 0
    local index = 0
    local infos = self._buildingInfoMap[buildingType] or {}
    for _, info in pairs(infos) do
    	if maxLv < info.level then
            maxLv = info.level
            index = info.index
    	end
    end
    return maxLv, index
end

--获取野外所有的建筑ID
function BuildingProxy:getAllOutdoorBuilding()
    local buildingList = {}
    for buildingType, buildingInfoList in pairs(self._buildingInfoMap) do
        if self:isFieldBuilding(buildingType) == true then
            for _, buildingInfo in pairs(buildingInfoList) do
                table.insert(buildingList,buildingInfo)
            end
        end
    end
    
    return buildingList
    
end

-- 通过建筑类型，判断是否为野外建筑
function BuildingProxy:isFieldBuilding(buildingType)
    local flag = false
    if buildingType == 0 
            or (buildingType >= 2 and buildingType <= 6) then
        flag = true
        
    end
    
    return flag
end

function BuildingProxy:getCommandLv()
    return self._curCommandLv
end

--建筑升级中的总建筑数
function BuildingProxy:buildingLvNum()
    local num = 0
    local minLevelTime = 140000000
    local buildingType = -1
    local index = -1
    for _, map in pairs(self._buildingInfoMap) do
        for _, buildingInfo in pairs(map) do
            local levelTime = buildingInfo.levelTime
            if levelTime > 0 then  --buildingInfo.levelTime
                num = num + 1
                if minLevelTime > levelTime then --buildingInfo.levelTime
                    minLevelTime = levelTime --buildingInfo.levelTime
                    buildingType = buildingInfo.buildingType
                    index = buildingInfo.index
                end
    		end
    	end
    end
    return num, buildingType, index
end

--通过类型获取可以生产的ID队列
function BuildingProxy:getCanProductIdList(buildingType)
    local proConfigName = self:getBuildingProConfigName(buildingType)
    local _, index = self:getBuildingMaxLvByType(buildingType)
    local infos = ConfigDataManager:getConfigData(proConfigName)
    local idList = {}
    for _, info in pairs(infos) do
        local isCanPro = self:getProductConditionResult(buildingType, index, info)
        if isCanPro == true then
            table.insert(idList, info.ID)
        end
    end
    
    return idList
end

--获取当前建筑的生产条件
--这条生产消息是否能够生产
function BuildingProxy:getProductConditionResult(buildingType, buildingIndex, info)
    if info == nil then
        return false, ""
    end
    local roleProxy = self:getProxy(GameProxys.Role)

    local roleLv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)

    local lvneed = StringUtils:jsonDecode(info.Lvneed)
    local needBuildingType = lvneed[1]
    local level = lvneed[2]

    local buildingInfo = self:getBuildingInfo(buildingType, buildingIndex)
    local buildingMaxLv = buildingInfo.level

    if buildingInfo.buildingType == BuildingTypeConfig.REFORM then --校场
        buildingMaxLv = self:getBuildingMaxLvByType(needBuildingType)
    end

    local commanderLv = info.commanderLv

    local flag = false
    if buildingMaxLv >= level and roleLv >= commanderLv then
        flag = true
    end

    
    local dec = ""
    if flag == false then
        local key = tonumber(string.format("800%d", needBuildingType))
        dec = string.format(TextWords:getTextWord(key), level )
        if commanderLv > 0 then
            key = tonumber(string.format("8000%d", needBuildingType))
            dec = string.format(TextWords:getTextWord(key), level )
            dec = dec .. "," .. string.format(TextWords:getTextWord(805), commanderLv )
        end
    end

    return flag, dec
end

-- 所属的建筑模块是否开启
function BuildingProxy:isBuildingModuelOpen(moduleName)
    local isOpen = true
    local info = self:getBuildConfigByModuleName(moduleName)
    if info ~= nil then
        isOpen = self:isBuildingOpen(info.type, info.ID)
    end
    return isOpen
end

function BuildingProxy:getBuildConfigByModuleName(moduleName)
    local buildingType = nil
    local buildingIndex = nil
    local index = string.find(moduleName, "Module")
    local sub = string.sub(moduleName , index + 6)
    if sub ~= "" then
        local subAry = StringUtils:splitString(sub, "_")
        buildingType = tonumber(subAry[1])
        buildingIndex = tonumber(subAry[2])
        moduleName = string.sub(moduleName,1,index + 5)
    end
    
    local infoList = nil
    if buildingType ~= nil then
        infoList = {}
        if buildingIndex ~= nil then
            local info = {}
            info.type = buildingType
            info.ID = buildingIndex
            table.insert(infoList, info)
        else
            local buildingInfoList = self:getOneTypeBuildingInfo(buildingType)
            if buildingInfoList == nil then return end
            for _, buildingInfo in pairs(buildingInfoList) do
                local info = {}
                info.type = buildingInfo.buildingType
                info.ID = buildingInfo.index
                table.insert(infoList, info)
            end
        end
    else
        infoList = ConfigDataManager:getInfosFilterByTwoKey(ConfigData.BuildOpenConfig
        ,"moduleName",moduleName,"type", buildingType)
    end
    
    local resultInfo = nil
    local maxLevel = -1
    for _, info in pairs(infoList) do
    	local buildingInfo = self:getBuildingInfo(info.type, info.ID)
        -- 加入判空
        if buildingInfo == nil then
            return nil
        end
    	if buildingInfo.level > maxLevel then
            maxLevel = buildingInfo.level
            resultInfo = info
    	end
    end
    
    return resultInfo, moduleName
end

--建筑是否开启
function BuildingProxy:isBuildingOpen(buildingType, buildingIndex, noShowMsg)
    
    local isOpen = true
    local info = ConfigDataManager:getInfoFindByTwoKey(ConfigData.BuildOpenConfig,
        "ID",buildingIndex,"type",buildingType)
    if info == nil then
        logger:error("---------isBuildingOpen---nil---------", tostring(buildingType), tostring(buildingIndex))
        return false
    end
        
    local roleProxy = self:getProxy(GameProxys.Role)
    local condition = info.condition
    --修改成读表，而不是写死
    local opentype = info.opentype
    if opentype == 1 then --指挥官等级
         local level = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
         if level < condition then --条件不通过
            isOpen = false
             if noShowMsg ~= true then
                local txtNO = 831
                if info.type == 17 then --军团大厅
                    txtNO = 832  
                end
                local content = string.format(TextWords:getTextWord(txtNO), condition, info.name)
                self:showSysMessage(content)
             end
        end
    elseif opentype == 3 then --官邸等级
        local buildingInfo = self:getBuildingInfo(1, 1)
        if buildingInfo == nil then
            return false
        end
        local level = buildingInfo.level
        if level < condition then --条件不通过
            isOpen = false
            if noShowMsg ~= true then
                local content = string.format(TextWords:getTextWord(830), condition)
                self:showSysMessage(content)
            end
        end
    elseif opentype == 2 then -- 先不做处理
        isOpen = false
    end
    
    return isOpen
end

--获取个人信息建筑面板的详细信息
--1.只显示已建造出的建筑
--2.等级低的排在上面
--3.同等级的 根据升级时间排序  时间少的  排上面
--4.处于升级状态的  优先排上面    
--5.都处于升级状态的  按照升级所需时间从小到大排序
--
function BuildingProxy:getPersonBuildingDetailInfos()
    local buildingList = {}

    for buildingType, buildings in pairs(self._buildingInfoMap) do
        if buildingType > 0 then
            for _, buildingInfo in pairs(buildings) do
                if buildingInfo.level > 0 and 
                    table.indexOf(BuildingDefine.BUILD_GROWTH_LIST, buildingInfo.buildingType ) >= 0 
                    and self:isBuildingMaxLevel(buildingType, buildingInfo.index) ~= true then
                    table.insert(buildingList, buildingInfo)
                end
            end
        end
    end

    local function comps(a, b) -- 排序函数
        if (a.levelTime == 0 and b.levelTime == 0) or a.levelTime == b.levelTime then --
            if a.level == b.level then
                return a.upTime < b.upTime
            else
                return a.level < b.level
            end
        elseif a.levelTime > 0 and b.levelTime > 0 then
            return a.levelTime < b.levelTime
        elseif a.levelTime > 0 and b.levelTime == 0 then
            return true
        else
            return false
        end
        return true
    end 

    table.sort(buildingList, comps)

    return buildingList
end

--获取正在升级的建筑列表信息
function BuildingProxy:getBuildingUpGradeList()
    local list = {}
    for buildingType, buildings in pairs(self._buildingInfoMap) do
        if buildingType > 0 then
            for _, buildingInfo in pairs(buildings) do
                if buildingInfo.level > 0 and buildingInfo.levelTime > 0 then
                    local data = {}
                    data.buildingIndex = buildingInfo.index
                    data.buildingType = buildingInfo.buildingType
                    table.insert(list, data)
                end
            end
        end
    end
    
    return list
end

--删除某个建筑的生产队列信息，完成或者取消
function BuildingProxy:removeBuildingProduction(buildingType, index, order)
    local buildingInfo = self:getBuildingInfo(buildingType, index)
    local productionInfos = buildingInfo.productionInfos

    local removeIndex, removeProductionInfo
    for index, productionInfo in pairs(productionInfos) do
        if productionInfo.order == order then
            removeIndex = index
            removeProductionInfo = productionInfo
            break
        end
    end

    if removeIndex ~= nil then
        table.remove(buildingInfo.productionInfos, removeIndex)
    else
        logger:error("!!!!!竟然没有建筑生产可以删除!!!!!")
    end

    return removeProductionInfo
end

--开始建筑生产
function BuildingProxy:startBuildingProduction(buildingType, index, order)
    local buildingInfo = self:getBuildingInfo(buildingType, index)
    local productionInfos = buildingInfo.productionInfos
    local updateIndex
    for index, productionInfo in pairs(productionInfos) do
        if productionInfo.order == order then
            updateIndex = index 
            break
        end
    end

    local productionInfo
    if updateIndex ~= nil then
        productionInfo = buildingInfo.productionInfos[updateIndex]
        productionInfo.state = 1 --设置成生产中状态
        --TODO 算出当前所需要的总共所需时间
        local remainTime = self:getBuildingProductionTime(buildingType, index, 
            productionInfo.typeid, productionInfo.num)
        productionInfo.remainTime = remainTime
    else
        logger:error("=========没有可以开始生产的队列=================")
    end

    return productionInfo
end

--建筑能否生产
function BuildingProxy:isBuildingCanProduction(buildingType, index)
    local vipProxy = self:getProxy(GameProxys.Vip)

    local hadWaitQueue =  self:getBuildingProductionQueue()
    local curProductionNum = self:getBuildingProductionNum(buildingType, index)
    if curProductionNum >= hadWaitQueue then --可生产的队列已经满了
        return ErrorCodeDefine.M100006_4
    end

    --其他状态，UI逻辑会屏蔽掉

    return 0
    -- local configName
    -- if buildingType == BuildingTypeConfig.SCIENCE  then
    -- else
    --     if buildingType == BuildingTypeConfig.BARRACK then --兵营
    --         configName = ConfigData.ArmProductConfig
    --     elseif buildingType == BuildingTypeConfig.REFORM then --校场
    --         configName = ConfigData.ArmRemouldConfig
    --     elseif buildingType == BuildingTypeConfig.MAKE then --工匠坊
    --         configName = ConfigData.ItemMadeConfig
    --     end
    --     local jsonObject = ConfigDataManager:getConfigById(configName, typeid)


    -- end

end

--获取建筑的加速比
function BuildingProxy:getProductionSpeedRate(buildingType, index, typeid)
    local buildingInfo = self:getBuildingInfo(buildingType, index)

    local lessTime = 0
    local speedRate = 0
    local powertype = self:getBuildingPower(buildingType)
    if powertype ~= 0 then
        local roleProxy = self:getProxy(GameProxys.Role)
        speedRate = roleProxy:getRoleAttrValue(powertype) --实时拿，实时算
    end
    local tmpInfo = self:getBuildingConfigInfo(buildingType, buildingInfo.level)
    if tmpInfo ~= nil and tmpInfo.producteffect ~= nil then
        speedRate = speedRate + tmpInfo.producteffect
    end

    if typeid == nil then
        return speedRate,0
    end

    if buildingType == BuildingTypeConfig.BARRACK then --兵营
        local jsonObject = ConfigDataManager:getConfigById(ConfigData.ArmProductConfig, typeid)
        lessTime = jsonObject.timeneed
    elseif buildingType == BuildingTypeConfig.SCIENCE then --太学院
        local technologyProxy = self:getProxy(GameProxys.Technology)
        local technologyLv = technologyProxy:getTechnologyLevel(typeid)
        local jsonObject = ConfigDataManager:getInfoFindByTwoKey(ConfigData.ScienceLvConfig,
        "level", technologyLv, "scienceType", typeid)
        lessTime = jsonObject.time
        local playerProxy = self:getProxy(GameProxys.Role)
        local rate2 = playerProxy:getRoleAttrValue(PlayerPowerDefine.NOR_POWER_technologyResSpeedAdd)
        local tb = {1,4,7,10,14}--  /*资源类科技研发速度提升x%*/只有这些类型才加
        -- speedRate = buildingInfo.speedRate
        for k, v in pairs(tb) do
            if v == typeid then
                speedRate = speedRate + rate2
            end
        end
    elseif buildingType == BuildingTypeConfig.MAKE  then --制造车间
        local jsonObject = ConfigDataManager:getConfigById(ConfigData.ItemMadeConfig, typeid)
        lessTime = jsonObject.timeneed
    elseif buildingType == BuildingTypeConfig.REFORM then --校场
        local jsonObject = ConfigDataManager:getConfigById(ConfigData.ArmRemouldConfig, typeid)
        lessTime = jsonObject.timeneed
        -- speedRate = buildingInfo.speedRate
    end

    -- -- 根据加速百分比计算剩余时间
    if speedRate ~= 0 then
        lessTime = TimeUtils:getTimeBySpeedRate(lessTime, speedRate)
    end

    return speedRate, lessTime
end

--获取建筑生产时间
function BuildingProxy:getBuildingProductionTime(buildingType, index, typeid, num)

    if buildingType == BuildingTypeConfig.SCIENCE then --太学院
        num = 1 --太学院升级的，只会1剩
    end

    local speedRate, lessTime = self:getProductionSpeedRate(buildingType, index, typeid) 

    lessTime = lessTime * num

    return lessTime
end

--获取建筑可生产的最大队列数
function BuildingProxy:getBuildingProductionQueue()
    local vipProxy = self:getProxy(GameProxys.Vip)
    local hadWaitQueue =  vipProxy:getVipNum(VipDefine.VIP_WAITQUEUE) + BuildingDefine.MIN_WAITQUEUE
    return hadWaitQueue
end

--获取建筑正在生产的队列数
function BuildingProxy:getBuildingProductionNum(buildingType, index)
    local buildingInfo = self:getBuildingInfo(buildingType, index)
    local productionInfos = buildingInfo.productionInfos
    return #productionInfos
end

--该建筑能否升级, 给自动建筑用的，默认判断为金币升级
--type升级类型 1普通升级 2金币升级
function BuildingProxy:isBuildingCanUpgrade(buildingType, index, type)
    local roleProxy = self:getProxy(GameProxys.Role)
    local hadbuildSize = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_buildsize)
    local curUpgradingNum = self:getBuildingUpgradingNum()
    if curUpgradingNum >= hadbuildSize then --超过可建筑数了--判断VIP，是否提示要购买建筑位
        return ErrorCodeDefine.M100001_6
    end
    
    local buildingInfo = self:getBuildingInfo(buildingType, index)
    if buildingInfo == nil then  --空地升建筑
        return 0
    end
    if buildingInfo.levelTime > 0 then --正在升级的建筑，不能升级
        return ErrorCodeDefine.M100001_2
    end

    local upinfo = self:getBuildingConfigInfo(buildingType, buildingInfo.level + 1)
    if upinfo == nil then --建筑已经最高等级了
        return ErrorCodeDefine.M100001_3
    end

    local buildingInfo = self:getBuildingInfo(buildingType, index)
    local info = self:getBuildingConfigInfo(buildingType, buildingInfo.level)
    
    -- if self:getBuildingLevel(BuildingTypeConfig.COMMAND, 1) < info.commandlv then
    --     return ErrorCodeDefine.M100001_5  --建筑需要的官邸等级 大于当前官邸等级
    -- end

    -- 建筑升级前置条件判断
    local result = self:isCanUpgrade(info.commandlv)
    if result ~= 0 then
        return result
    end


    local roleProxy = self:getProxy(GameProxys.Role)
    local needAry = StringUtils:jsonDecode(info.need)
    local coin = info.gold
    if type == 1 then --普通升级
        for _, need in pairs(needAry) do
            local typeid = need[1]
            local num = need[2]
            num = self:getNeedNumberByDiscount(num)
            if roleProxy:getRoleAttrValue(typeid) < num then  --所要升级需求资源不足
                return ErrorCodeDefine.M100001_4
            end
        end
    else
        if roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) < coin then
            return ErrorCodeDefine.M100001_8
        end
    end

    return 0
end

-- 升级建筑资源减少消耗百分比,计算减少后的资源需求
function BuildingProxy:getNeedNumberByDiscount(needNumber)
    -- 升级建筑资源减少消耗百分比
    local roleProxy = self:getProxy(GameProxys.Role)
    local discount = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_buildLevelUpDiscount) or 0

    -- 升级建筑资源减少消耗百分比
    if discount > 0 then
        logger:info("-- 升级建筑资源减少消耗百分比 %d", discount)
        needNumber = math.ceil(needNumber * discount / 100.0)
    end
    return needNumber
end

-- 建筑升级前置条件判断
function BuildingProxy:isCanUpgrade(commandlvList)
    local result = 0  --可以升级
    local commandlv = StringUtils:jsonDecode(commandlvList)
    for k,v in pairs(commandlv) do
        local level = self:getBuildingMaxLvByType(v[1])
        if level < v[2] then
            result = ErrorCodeDefine.M100001_5  --TODO 提示要根据不同建筑定义
            break
        end
    end

    return result
end

--获取正在升级的建筑数
function BuildingProxy:getBuildingUpgradingNum()
    local curUpgradingNum = 0 --当前正在升级的建筑数量
    for buildingType, buildingInfoList in pairs(self._buildingInfoMap) do
        if buildingType > 0 then
            for _, buildingInfo in pairs(buildingInfoList) do
                if buildingInfo.levelTime > 0 then
                    curUpgradingNum = curUpgradingNum + 1
                end
            end
        end
    end
    return curUpgradingNum
end

--请求购买建筑位
--判断当前还能不能购买建筑位
function BuildingProxy:askBuyBuildSize()
    local vipProxy = self:getProxy(GameProxys.Vip)
    local roleProxy = self:getProxy(GameProxys.Role)
    local canBuy = vipProxy:getVipNum(VipDefine.VIP_BULIDQUEUE) - BuildingDefine.MIN_BUILD_SIZE
    local hadBuildSize = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_buildsize)
    local hadGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold)
    local needGold = ((hadBuildSize - BuildingDefine.MIN_BUILD_SIZE) + 1) * BuildingDefine.MIN_BUY_BUILD_GOlD
    local vipInfo = ConfigDataManager:getInfoFindByOneKey(ConfigData.VipDataConfig, 
        "level", vipProxy:getMaxVIPLv())
    local vipMaxHadNum = vipInfo[VipDefine.VIP_BULIDQUEUE]
    local vipHadNum = vipProxy:getVipNum(VipDefine.VIP_BULIDQUEUE)
    if canBuy <= 0 then --没有建筑位可以购买了
        return 2
    elseif hadBuildSize >= vipMaxHadNum then --已经超过VIP最大上限了
        return 1
    elseif hadBuildSize >= vipHadNum and vipHadNum < vipMaxHadNum then --当前VIP可购买的建筑位已满
        return 2
    elseif hadGold < needGold then --元宝不足
        return needGold
    end
    return needGold
end

--获取建筑对应Power值，算加速比
function BuildingProxy:getBuildingPower(buildingType)
    local info = ConfigDataManager:getInfoFindByOneKey(ConfigData.BuildSheetConfig, 'type', buildingType)
    if info == nil then
        return 0
    end
    local power = StringUtils:jsonDecode(info.power) --TODO power字段需要导表
    if #power > 0 then
        return power[1]
    end

    return 0
end

---------私有方法-外部不能调用-----------------------
--触发自动升级
--这里可能会出现有挂的情况
function BuildingProxy:_triggerAutoBuild()
    local key = self:getAutoBuildRemainKey()
    local remainTime = self:getRemainTime(key)
    if remainTime == 0 then --自动建筑剩余时间没有在建筑，也不触发自动建筑了
        return
    end

    --TODO算出要开始升级的建筑
    local roleProxy = self:getProxy(GameProxys.Role)
    local hadbuildSize = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_buildsize) --先获取可以建筑的数量

    local curUpgradingNum = 0 --当前正在升级的建筑数量
    local readyUpgradeList = {} --准备升级的列表
    for buildingType, buildingInfoList in pairs(self._buildingInfoMap) do
        if buildingType > 0 then
            for _, buildingInfo in pairs(buildingInfoList) do
                if buildingInfo.levelTime > 0 then
                    curUpgradingNum = curUpgradingNum + 1
                end
                if buildingInfo.level > 0 then --TODO 还得增加判断该建筑能不能升级
                    if self:isBuildingCanUpgrade(buildingInfo.buildingType, buildingInfo.index, 1) == 0 then
                        table.insert(readyUpgradeList, buildingInfo) --可以升级的建筑
                    end
                end
            end
        end
    end

    local canUpgradeNum = hadbuildSize - curUpgradingNum
    if canUpgradeNum > 0 then
        local function comps(a, b)
            if a.level == b.level then
                return a.upTime < b.upTime
            else
                return a.upTime < b.upTime
            end
        end

        table.sort(readyUpgradeList, comps)

        local sendData = {}
        sendData.type = 1
        local buildingShortInfos = {}
        --批量升级
        for i=1, canUpgradeNum do --最多会同时请求多条
            local buildingInfo = readyUpgradeList[i]
            if buildingInfo == nil then  --准备升级的列表，可能会比可以升级的数量少
                break
            end
            table.insert(buildingShortInfos, {buildingType = buildingInfo.buildingType, 
                index = buildingInfo.index})
        end

        sendData.buildingShortInfos = buildingShortInfos

        self:syncNetReq(AppEvent.NET_M28, AppEvent.NET_M28_C280001, sendData)
    end
end

--


--生产队列完成，主要设置科技的逻辑
function BuildingProxy:_buildingProductionComplete(buildingType, index, productionInfo)
    if buildingType == BuildingTypeConfig.SCIENCE then
        local typeid = productionInfo.typeid
        local num = productionInfo.num
        local  technologyProxy = self:getProxy(GameProxys.Technology)
        technologyProxy:updateTechnologyInfo(typeid, num + 1)
    end
end

--对应的建筑升级了
function BuildingProxy:_buildingUpgrade(buildingType, index)
    if buildingType == BuildingTypeConfig.COMMAND then --官邸升级了，检测空地的开启
        local buildingInfo = self:getBuildingInfo(buildingType, index)
        local rlist = ConfigDataManager:getConfigData(ConfigData.BuildBlankConfig)
        local openList = {}
        for _, json in pairs(rlist) do
            if buildingInfo.level == json.openlv then
                table.insert(openList, json.ID)
            end
        end
        for _, id in pairs(openList) do
            local newBuildingInfo = self:_createNewBuildingInfo(0, id)
            self:_updateBuildingInfo(newBuildingInfo)
        end
    elseif buildingType == BuildingTypeConfig.BARRACK then
        local buildingInfos = self:getOneTypeBuildingInfo(BuildingTypeConfig.REFORM)
        for _, buildingInfo in pairs(buildingInfos) do
            self:_updateBuildingInfo(buildingInfo)
        end
    end
end

--创建一个新的BuildingInfo
function BuildingProxy:_createNewBuildingInfo(buildingType, index)
    local newBuildingInfo = {}
    newBuildingInfo.index = index
    newBuildingInfo.buildingType = buildingType
    newBuildingInfo.level = 0
    newBuildingInfo.levelTime = 0
    newBuildingInfo.productionInfos = {}
    newBuildingInfo.tchnologyInfos = {}
    
    return newBuildingInfo
end

--改变建筑类型
function BuildingProxy:_changeBuildingType(oldBuildingType, index, newBuildingType)
    
    local buildingInfo = self:getBuildingInfo(oldBuildingType, index)
    local buildList = self._buildingInfoMap[oldBuildingType] or {}
    for index, info in pairs(buildList) do
        if info.index == buildingInfo.index then  --这个建筑改变了 删除缓存
            self._buildingInfoMap[oldBuildingType][info.index] = nil
        end
    end
    
    buildingInfo.buildingType = newBuildingType
    if self._buildingInfoMap[newBuildingType] == nil then
        self._buildingInfoMap[newBuildingType] = {}
    end
    self._buildingInfoMap[newBuildingType][index] = buildingInfo
    
    return buildingInfo
end

--更新某个建筑的信息
--lastMaxLv这个建筑升级前的最大等级 buildingInfo是同个引用，里面的判断则会有问题
function BuildingProxy:_updateBuildingInfo(buildingInfo, isInit, forceUpdate, lastMaxLv)
    if buildingInfo == nil then
        return
    end
    local buildingType = buildingInfo.buildingType
    local index = buildingInfo.index

    -- logger:info("~~~~~~~~~BuildingProxy:_updateBuildingInfo~~~:%d~~~:%d~~:%d~~~~%s", buildingType, 
    --     index, buildingInfo.level, debug.traceback() )
    
    -- logger:info("=======BuildingProxy:_updateBuildingInfo===================== %d %d", buildingType, index)
    local isLevelUp = false
    local oldBuildingInfo = self:getBuildingInfo(buildingType, index)
    if oldBuildingInfo ~= nil then
        if oldBuildingInfo.lastLevel == 0 and buildingInfo.level == 1 then --建筑提示
            local info = self:getBuildingConfigInfo(buildingType, buildingInfo.level)
            local content = string.format(TextWords:getTextWord(814), info.name)
            self:showSysMessage(content)
            -- 创建完成的时候也播放升级动画，0J到1J
            self:sendNotification(AppEvent.BUILDING_LEVEL_UP, buildingInfo)
        elseif oldBuildingInfo.lastLevel ~= buildingInfo.level then --升级提示
            local info = self:getBuildingConfigInfo(buildingType, buildingInfo.level)
            if info ~= nil then
                local content = string.format(TextWords:getTextWord(815), info.name, buildingInfo.level)
                self:showSysMessage(content)
            end
            isLevelUp = true            
        end
        -- if oldBuildingInfo.level ~= buildingInfo.level or 
            -- oldBuildingInfo.lastLevel ~= buildingInfo.level then
            local upTime = self:getBuildingUpLevelTime(buildingType, buildingInfo.level)
            buildingInfo.upTime = upTime
        -- end
        
--        if forceUpdate ~= true and self:isSameBuildingInfo(oldBuildingInfo, buildingInfo) then
--            logger:error("=====更新的建筑数据跟本地的一样,我不更新！===buildingType:%d===index:%d====", 
--                buildingType, index)
--            return
--        end
    else
        local upTime = self:getBuildingUpLevelTime(buildingType, buildingInfo.level)
        buildingInfo.upTime = upTime
    end
    
    buildingInfo.lastLevel = buildingInfo.level

    if isLevelUp then
        local openType = nil
        if buildingType == BuildingTypeConfig.COMMAND then
            openType = 2
        elseif buildingType == BuildingTypeConfig.BARRACK and lastMaxLv ~= nil then
            --！！数据已经是最新的了，没办法做如下判断。
            -- local maxLv, maxIndex = self:getBuildingMaxLvByType(BuildingTypeConfig.BARRACK)
            if buildingInfo.level > lastMaxLv then --拿上一次的最大等级来判断
                openType = 3
            end
        end
        if openType ~= nil then
            local list = ConfigDataManager:getInfosFilterByTwoKey(
                      ConfigData.NewFunctionOpenConfig, "need", buildingInfo.level, "type", openType)

            if #list > 0 then
                local function delayShowModule(data)
                    self:showModule({moduleName = ModuleName.UnlockModule, extraMsg = data})
                end
                EffectQueueManager:addEffect(EffectQueueType.UNLOCK, delayShowModule, {openType = openType, openLevel = buildingInfo.level})
            end
        end
    end


    if self._buildingInfoMap[buildingType] == nil then
        self._buildingInfoMap[buildingType] = {}
    end
    self._buildingInfoMap[buildingType][index] = buildingInfo
    
    --只有在当前建筑才会派发事件
    if isInit ~= true and self._curBuildingType == buildingType
        and  self._curBuildingIndex == index then
        self._eventCenter:sendNotification(buildingType, index, buildingInfo)
    end
    
    if buildingType == 1 then --司令部的类型 写死
        self._curCommandLv = buildingInfo.level
    end

    if isInit == true then
        if buildingType == BuildingTypeConfig.SCIENCE then --初始化科技
            local technologyProxy = self:getProxy(GameProxys.Technology)
            technologyProxy:initTechnology(buildingInfo.technologyInfos)
        end
    end
    
    self:_updateBuildingDetailInfo(buildingType, index)

    --print_r(buildingInfo)
    --全局建筑信息改变
--    if isInit ~= true then --TODO 这个事件不能在这里，如果多个更新时，会触发多个更新
        -- self:sendNotification(AppEvent.PROXY_BUILDING_UPDATE, buildingInfo)
--    end

    
    -- 判断是否打开了主城模块
    -- 当主城未打开，缓存更新的建筑信息
    if self:isModuleShow(ModuleName.MainSceneModule) ~= true then
        -- if self._hideUpdateBuildList[buildingType] == nil then
        --     self._hideUpdateBuildList[buildingType] = {}
        -- end
        -- self._hideUpdateBuildList[buildingType][index] = buildingInfo
        self:setHideUpdateBuildInfo(buildingType,index,buildingInfo)
    end

    self:sendNotification(AppEvent.PROXY_BUILDING_UPDATE, buildingInfo)
    -- 触发
    ---------------------------
--    function MainSceneModule:buildingUpdateHandler(data)
--        self._view:updateBuildingInfo(data)
--    end

    if isLevelUp then
    --验证是否有槽位解锁了，重新计算最大战斗力
        local soldierProxy = self:getProxy(GameProxys.Soldier)
        if soldierProxy:getOpenPos(buildingType, buildingInfo.level) > 0 then
            soldierProxy:soldierMaxFightChange()
            soldierProxy:setMaxFighAndWeight() 
        end
    end

    -- 升级动画播放判断
    -- 如果建筑被拆迁，不播放升级动画
    if buildingInfo.level == 0 then
        isLevelUp = false
    end
    if isLevelUp then
        -- 播放升级动画
        self:sendNotification(AppEvent.BUILDING_LEVEL_UP, buildingInfo)
    end
end

-----更新建筑详细信息
--TODO 还可以优化
function BuildingProxy:_updateBuildingDetailInfo(buildingType, index)
    local buildingInfo = self:getBuildingInfo(buildingType, index)
    local list = {}
    if buildingType == BuildingTypeConfig.BARRACK then --兵营
        local roleProxy = self:getProxy(GameProxys.Role)
        local jsonArrayList = ConfigDataManager:getConfigData(ConfigData.ArmProductConfig)
        for _, info in pairs(jsonArrayList) do
            local lvneed = StringUtils:jsonDecode(info.Lvneed)
            local commanderLv = info.commanderLv
            local typeid = info.ID
            if roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level) >= commanderLv and 
                self:getBuildingLevel(buildingType, index) >= lvneed[2] then
                local detailInfo = {}
                detailInfo.num = 0
                detailInfo.typeid = typeid
                table.insert(list, detailInfo)
            end
        end
    elseif buildingType == BuildingTypeConfig.SCIENCE then  --科技馆
        --TechnologyProxy TODO
        local technologyProxy = self:getProxy(GameProxys.Technology)
        list = technologyProxy:getDetailInfos()
    elseif buildingType == BuildingTypeConfig.MAKE then --工匠坊
        local jsonArrayList = ConfigDataManager:getConfigData(ConfigData.ItemMadeConfig)
        for _, info in pairs(jsonArrayList) do
            local typeid = info.ID
            local detailInfo = {}
            detailInfo.num = 0
            detailInfo.typeid = typeid
            table.insert(list, detailInfo)
        end
    elseif buildingType == BuildingTypeConfig.REFORM then --校场
        local roleProxy = self:getProxy(GameProxys.Role)
        local jsonArrayList = ConfigDataManager:getConfigData(ConfigData.ArmRemouldConfig)
        for _, info in pairs(jsonArrayList) do
            local lvneed = StringUtils:jsonDecode(info.Lvneed)
            local commanderLv = info.commanderLv
            local typeid = info.ID
            if roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level) >= commanderLv and 
                self:getBuildingMaxLvByType(lvneed[1]) >= lvneed[2] then
                local detailInfo = {}
                detailInfo.num = 0
                detailInfo.typeid = typeid
                table.insert(list, detailInfo)
            end
        end
    end

    buildingInfo.buildingDetailInfos = list

    --TODO VIP、对应Power值更新，需要更新
    local roleProxy = self:getProxy(GameProxys.Role)
    buildingInfo.productNum = self:getBuildingProductionQueue()
    buildingInfo.speedRate = 0 
    local powertype = self:getBuildingPower(buildingType)
    if powertype ~= 0 then
        buildingInfo.speedRate = roleProxy:getRoleAttrValue(powertype)
    end
    

    -- 功能建筑读取配表的加速百分比  add by fzw 
    if buildingType == BuildingTypeConfig.SCIENCE 
        or buildingType == BuildingTypeConfig.BARRACK 
        or buildingType == BuildingTypeConfig.REFORM then
        --start 增加配表百分比-------------------------------------------------
        -- print("00----------speedRate--------", buildingInfo.speedRate, powertype, buildingType, index)
        local tmpInfo = self:getBuildingConfigInfo(buildingType, buildingInfo.level)
        if tmpInfo.producteffect ~= nil then
            buildingInfo.speedRate = buildingInfo.speedRate + tmpInfo.producteffect
        end
        -- print("11----------speedRate--------", buildingInfo.speedRate, powertype, buildingType, index)
        --end 增加配表百分比-------------------------------------------------
    end

end

--判断建筑信息是否一致。。。一致的话，就不更新了。。。
function BuildingProxy:isSameBuildingInfo(oldBuildingInfo, newBuildingInfo)
--    print("==========oldBuildingInfo====================")
--    print_r(oldBuildingInfo)
--    print("==========newBuildingInfo====================")
--    print_r(newBuildingInfo)
--    print("########################################")
    local list = {"index", "buildingType", "level", "levelTime", "speedRate", "productNum"}
    for _, key in pairs(list) do
    	if oldBuildingInfo[key] ~= newBuildingInfo[key] then
    	    return false
    	end
    end
    
    if #oldBuildingInfo.productionInfos ~= #newBuildingInfo.productionInfos then
        return false
    end
    
    local pkList = {"typeid", "num", "state", "remainTime", "order"}
    for index=1, #oldBuildingInfo.productionInfos do
        local oldPinfo = oldBuildingInfo.productionInfos[index]
        local newPinfo = newBuildingInfo.productionInfos[index]
        for _, key in pairs(pkList) do
            if oldPinfo[key] ~= newPinfo[key] then
                return false
            end
        end
    end
    
    if #oldBuildingInfo.buildingDetailInfos ~= #newBuildingInfo.buildingDetailInfos then
        return false
    end
    
    local dList = {"typeid", "num"}
    for index=1, #oldBuildingInfo.buildingDetailInfos do
        local oldDinfo = oldBuildingInfo.buildingDetailInfos[index]
        local newDinfo = newBuildingInfo.buildingDetailInfos[index]
        for _, key in pairs(dList) do
            if oldDinfo[key] ~= newDinfo[key] then
                return false
            end
        end
    end
    
    return true
end

function BuildingProxy:buyResourceReq(data)
    local sendData = {}
    if data.type == 0 then
        sendData.typeId = data.itemID
        sendData.num = data.num
        self:sendServerMessage(AppEvent.NET_M9, AppEvent.NET_M9_C90001, sendData)--item use
    elseif data.type == 1 then
        sendData.id = data.id
        self:sendServerMessage(AppEvent.NET_M10, AppEvent.NET_M10_C100007, sendData)--item buy
    end
end

function BuildingProxy:onTriggerNet280015Resp(data)
    if data.rs == 0 then
        -- self:pushRemainTime("BuildingProxy_60Sec_Pro", 60, AppEvent.NET_M28_C280015, nil, self.onTriggerNet280015Req)
        local roleProxy = self:getProxy(GameProxys.Role)
        roleProxy:onTriggerNet20002Resp(data,true)

        --------服务端有时也会直接推送280015过来，会覆盖掉定时器，导致延后请求，而被处理成没有心跳
        if self._startReq280015 ~= false then
            TimerManager:addOnce(60 * 1000, self.onTriggerNet280015Req, self) --改成定时请求
            self._startReq280015 = false
        end
    end
    
    --通过280015来做心跳判断
    GameConfig.lastHeartbeatTime = os.time()
    GameConfig.serverTime = data.serverTime

    logger:info("~~~~~~~~~服务器时间~~~~~:%d~~~~~~~~", GameConfig.serverTime)
end

function BuildingProxy:onTriggerNet280015Req()
    self._startReq280015 = true
    self:syncNetReq(AppEvent.NET_M28, AppEvent.NET_M28_C280015, {})
end

function BuildingProxy:onTriggerNet280017Req(buildingType, index)
    local data = {}
    data.index = index
    data.buildingType = buildingType
    self:syncNetReq(AppEvent.NET_M28, AppEvent.NET_M28_C280017, data)
end

function BuildingProxy:onTriggerNet280017Resp(data)
    if data.rs == 0 then
        local legionHelpProxy = self:getProxy(GameProxys.LegionHelp)
        legionHelpProxy:addHelpInfos(data.index ,data.buildingType)
    end
end

------
-- 建筑显示感叹号表格配置
function BuildingProxy:getMarkData()
    local table = {
    [14] = "PartsModule", -- 军械坊
    [15] = "ConsigliereModule", -- 军师府
    [16] = "ArenaModule", -- 演武场
    [17] = "LegionSceneModule", -- 军团
    }
    return table
end

------
-- 判断是否在表里
-- buildingType 建筑的type，作为key
function BuildingProxy:getMarkTipsData(buildingType)
    local table = self:getMarkData() -- 建筑显示感叹号表格配置
    for key, moduleName in pairs(table) do
        if buildingType == key then
            return moduleName
        end
    end
    return false
end


------
-- 根据模块名判断建筑是否开启， 不显示提示信息版
-- @param  moduleName [str] 模块名字
-- @return nil
function BuildingProxy:getBuildOpenByModuleName(moduleName)
    local info = self:getBuildConfigByModuleName(moduleName)
    local isOpen = self:isBuildingOpen(info.type, info.ID, true)
    return isOpen
end


------
-- 获取空地列表 
-- @param  args [obj] 参数
-- @return nil
function BuildingProxy:getBlankInfo()
    local buildingInfo = self:getBuildingInfo(1, 1) -- 官邸的数据
    
    local blankList = {} -- 空白地

    local openList = {}
    local rlist = ConfigDataManager:getConfigData(ConfigData.BuildBlankConfig)
    for _, json in pairs(rlist) do
        if buildingInfo.level >= json.openlv then
            table.insert(openList, json.ID)
        end
    end
    for _, id in pairs(openList) do
        local fieldInfo = self:getFieldBuildingInfo(id)
        if fieldInfo ~= nil and fieldInfo.buildingType == 0 then
            table.insert(blankList, fieldInfo)
            -- logger:error("加入空白地列表+++++++++")
        end
    end

    return blankList
end


--function BuildingProxy:sendShowCreatePanel(data)
--    self:sendNotification(AppEvent.PROXY_CREATE_NEW_BUILD_PANEL, data)
--end