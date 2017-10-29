DungeonProxy = class("DungeonProxy", BasicProxy)

function DungeonProxy:ctor()
    DungeonProxy.super.ctor(self)
    self.proxyName = GameProxys.Dungeon
    -- self._teamInfo = {}
    -- self._checkProtectPos = {}
    self._alldungeoInfos = {}
    self._subtype = nil
    --self._initInfos = true
end

function DungeonProxy:resetAttr()
    self._initInfos = true
    self.proxyName = GameProxys.Dungeon
    -- self._teamInfo = {}
    -- self._checkProtectPos = {}
    self._alldungeoInfos = {}
    self._subtype = nil
end

function DungeonProxy:registerNetEvents()
    --self:registerNetEvent(AppEvent.NET_M7, AppEvent.NET_M7_C70000, self, self.onSetTeamResp1)
    --self:registerNetEvent(AppEvent.NET_M7, AppEvent.NET_M7_C70001, self, self.onSetTeamResp)

    --self:addEventListener(AppEvent.PROXY_SOLIDER_MOFIDY,self,self.setCheckExample)

    --self:registerNetEvent(AppEvent.NET_M6, AppEvent.NET_M6_C60000, self, self.setDungeonListInfos)
    --self:registerNetEvent(AppEvent.NET_M6, AppEvent.NET_M6_C60006, self, self.updateDungeonListInfos)
    --self:addEventListener(AppEvent.PROXY_GET_ROLE_INFO, self, self.updateRoleInfoRsp)
    --self:addEventListener(AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoRsp)
end

function DungeonProxy:unregisterNetEvents()
    --self:unregisterNetEvent(AppEvent.NET_M7, AppEvent.NET_M7_C70000, self, self.onSetTeamResp1)
    --self:unregisterNetEvent(AppEvent.NET_M7, AppEvent.NET_M7_C70001, self, self.onSetTeamResp)

    --self:removeEventListener(AppEvent.PROXY_SOLIDER_MOFIDY,self,self.setCheckExample)

    --self:unregisterNetEvent(AppEvent.NET_M6, AppEvent.NET_M6_C60000, self, self.setDungeonListInfos)
    --self:unregisterNetEvent(AppEvent.NET_M6, AppEvent.NET_M6_C60006, self, self.updateDungeonListInfos)
    --self:removeEventListener(AppEvent.PROXY_GET_ROLE_INFO, self, self.updateRoleInfoRsp)
    --self:removeEventListener(AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoRsp)
end

--副本初始化数据
function DungeonProxy:initSyncData( data )
    DungeonProxy.super.initSyncData(self, data)
    self:resetAttr()
    self:setDungeonListInfos(data.dungeonInfos)

    
    if self._currDungeonId ~= nil then
        -- 断线重连时
        self:onTriggerNet60001Req({id = self._currDungeonId})
    end

    -- if data.info ~= nil then
    --     local tempData = {}
    --     tempData.info = data.info
    --     tempData.rs = 0
    --     self:onSetTeamResp1(tempData)
    -- end
end

-- function DungeonProxy:onTriggerNet70000Resp(data)
--     self:onSetTeamResp1(data)
-- end

-- function DungeonProxy:onTriggerNet70001Resp(data)
--     self:onSetTeamResp(data)
-- end

-- function DungeonProxy:onTriggerNet70001Req(data)
--     self:syncNetReq(AppEvent.NET_M7, AppEvent.NET_M7_C70001, data)
-- end

-- function DungeonProxy:updateRoleInfoRsp(data)
--     local roleProxy = self:getProxy(GameProxys.Role)
--     local currentLv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
--     if currentLv > 2  and self._initInfos then
--         --self:sendServerMessage(AppEvent.NET_M6, AppEvent.NET_M6_C60000, {})
--         self._initInfos = false
--     end
-- end

function DungeonProxy:onTriggerNet60006Resp(data)
    self:updateDungeonListInfos(data)
    self:updateRedPoint()
    self:onUpdateDungeonInfos(data)
end

function DungeonProxy:setCurrType(id,type)  --id:探险的4个副本类型, type：1：征战 2：探险
    self._currDungeonId = id
    self._type = type
end

function DungeonProxy:getCurrType()
    return self._type,self._currDungeonId  --_currDungeonId:探险的4个副本类型, _type：1：征战 2：探险
end

function DungeonProxy:setCurrCityType(id)  --id:副本里面的id
    self._currCityId = id
end

function DungeonProxy:getCurrCityType()
    return self._currCityId
end

function DungeonProxy:setExploreIndex(index)  --探险界面的三个关卡,装备和军械可以购买次数
    self._exploreIndex = index 
end

function DungeonProxy:getExploreIndex()
    return self._exploreIndex
end

-- function DungeonProxy:setTeamType(city)  --有值：关卡模块跳到部队模块
--     self._teamType = city
-- end

-- function DungeonProxy:getTeamType()
--     return self._teamType
-- end

-- function DungeonProxy:setCurrDunId()
-- end

-- function DungeonProxy:onSetTeamResp1(data)  --type 1:模板套用阵型 2：部队防守阵形 3：竞技场阵型
--     if data.rs == 0 then
--         for _,v in pairs(data.info) do
--             self:onJudgePowerCommond(v.members)
--             self._teamInfo[v.type] = v
--         end
--     end
--     self:setCheckExample()
-- end

-- function DungeonProxy:onSetTeamResp(data)  --type 1:模板套用阵型 2：部队防守阵形 3：竞技场阵型
--     if data.rs == 0 then
-- 		for _,v in pairs(data.info) do
--             self:onJudgePowerCommond(v.members)
-- 		    self._teamInfo[v.type] = v
-- 		end
--         self:showSysMessage("保存阵型成功!")
-- 	end
--     self:setCheckExample()
-- end

-- function DungeonProxy:onJudgePowerCommond(data)
--     local roleProxy = self:getProxy(GameProxys.Role)
--     local maxSoldierCount = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)
--     for _,v in pairs(data) do
--         if v.num > maxSoldierCount then
--             v.num = maxSoldierCount
--         end
--     end
-- end

-- function DungeonProxy:onGetTeamInfo()
-- 	return self._teamInfo
-- end

-- function DungeonProxy:setCheckExample(outMembers)  --检查套用阵型的正确性
--     local members
--     if outMembers == nil then
--         if self._teamInfo[1] == nil then
--             return
--         end
--         members = self._teamInfo[1].members
--     else
--         members = outMembers
--     end
--     local soldierProxy = self:getProxy(GameProxys.Soldier)
--     local soldierList = soldierProxy:getRealSoldierList()

--     -- print("=======getRealSoldierList====")
--     -- for _,v in pairs(soldierList) do
--     --     print("real soldier :  post  num  typeid-----  ",v.num,v.typeid)
--     -- end
--     -- print("=============================")

--     table.sort(members, function (a,b) return (a.post < b.post) end)
--     local exterList = {}
--     local checkData = {}
--     for _,v in pairs(members) do
--         if v.num > 0 and v.typeid > 0 then
--             if exterList[v.typeid] == nil then
--                 exterList[v.typeid] = {}
--                 exterList[v.typeid].totalNum = 0
--                 exterList[v.typeid].items = {}
--             end
--             exterList[v.typeid].totalNum = exterList[v.typeid].totalNum + v.num
--             table.insert(exterList[v.typeid].items,{post = v.post,num = v.num})
--         else
--             table.insert(checkData,v)
--         end
--     end

--     for key,v in pairs(exterList) do
--         if soldierList[key] == nil then
--             for _,child in pairs(v.items) do
--                 child.num = 0
--             end
--         else
--             if v.totalNum > soldierList[key].num then
--                 v.totalNum = soldierList[key].num
--                 for _,child in pairs(v.items) do
--                     if v.totalNum >= child.num then
--                         v.totalNum = v.totalNum - child.num
--                     else
--                         child.num = v.totalNum
--                         v.totalNum = 0
--                     end
--                 end
--             end
--         end
--     end

--     for fkey,fv in pairs(exterList) do
--         for ckey,cv in pairs(fv.items) do
--             local item = {}
--             item.typeid = fkey
--             item.post = cv.post
--             item.num = cv.num
--             if cv.num < 0 then
--                 item.num = 0
--             end
--             table.insert(checkData,item)
--         end
--     end
--     ---------tudo: 繁荣度下降后，带兵量上限要及时修改-----------
--     self:onJudgePowerCommond(checkData)

--     if outMembers == nil then
--         self._checkProtectPos = checkData
--     end
--     return checkData
-- end

-- function DungeonProxy:getCheckData()
--     return self._checkProtectPos
-- end

function DungeonProxy:onExterInstanceSender(index)  --1，装备 2.配件 3.极限  0普通的最高关卡
    self._isExterInstance = index
    --self:sendServerMessage(AppEvent.NET_M6, AppEvent.NET_M6_C60000, {})
    self:onGetExterInsatance()
    --print("----------------------60000Req------------------------------------------")
end

function DungeonProxy:updateDungeonListInfos(data)
    if  data.rs == 0 then
        local dataTemp = clone(self._allDungeonListInfos)
        dataTemp.isPassAll = data.isPassAll
        local dungeoInfos = data.dungeoInfos
        local num1  = 0 
        if data.type == 1 then
            for k, v in pairs(dataTemp.dungeoInfos) do
                if v.id == dungeoInfos.id then
                    dataTemp.dungeoInfos[k] = dungeoInfos
                    num1 = num1 + 1
                end
            end
            if num1 == 0 then
                dataTemp.dungeoInfos[#dataTemp.dungeoInfos + 1] = dungeoInfos
            end 
            self:setDungeonListInfos(dataTemp)
        else
            local dungeoExplore = data.dungeoExplore
            local num = 0
                for k, v in pairs(dataTemp.dungeoExplore) do
                    if v.id == dungeoExplore.id then
                        dataTemp.dungeoExplore[k] = dungeoExplore
                        num = num + 1
                    end
                end
            if num == 0 then
                dataTemp.dungeoExplore[#dataTemp.dungeoExplore + 1] = dungeoExplore
            end
            self:setDungeonListInfos(dataTemp)
        end
    end
end

function DungeonProxy:resetCountSyncData()
    print("4点重置数据")
    self:onTriggerNet60106Req({})
    -- if (not self._alldungeoInfos) or (not self._allDungeonListInfos) then
    --     return
    -- end
    -- for k,v in pairs(self._alldungeoInfos) do
    --     if type(v) == "table" then
    --         for ka,va in pairs(v) do
    --             if ka == "times" then
    --                 self._alldungeoInfos[k][ka] = 5
    --                 self:sendNotification(AppEvent.PROXY_DUNGEON_RESET_DATA, 5)
    --             end
    --         end
    --     else
    --         if k == "times" then
    --             self._alldungeoInfos[k] = 5
    --             self:sendNotification(AppEvent.PROXY_DUNGEON_RESET_DATA, 5)
    --         end
    --     end
    -- end
    -- local function resetData(data)
    --     for k,v in pairs(data) do
    --         if v.count ~= -1 then
    --             data[k].count = 5
    --         end
    --     end
    -- end
    -- resetData(self._allDungeonListInfos.dungeoInfos)
    -- resetData(self._allDungeonListInfos.dungeoExplore)
    -- --刷新外面的数据
    -- self:sendNotification(AppEvent.PROXY_DUNGEON_LIST_INFO_UPDATE, {})
    -- self:updateRedPoint()
end

function DungeonProxy:setDungeonListInfos(data)
    if #data.dungeoInfos > 1 then
        table.sort(data.dungeoInfos, function (a,b) return (a.id > b.id) end)
    end
    self._allDungeonListInfos = data
    self:onGetExterInsatance()
end

function DungeonProxy:getDungeonListInfo()
    return self._allDungeonListInfos
end

--获取普通副本开启的关卡数
function DungeonProxy:getDungeonOpenNum(dungeonId)
    local dungeoInfos = self._allDungeonListInfos.dungeoInfos
    for _,v in pairs(dungeoInfos) do
        if v.id == dungeonId then
            return v.len
        end
    end
    return 1
end

--获取普通副本是否已经开启
function DungeonProxy:isDungeonOpen(dungeonId)
    local dungeoInfos = self._allDungeonListInfos.dungeoInfos
    for _,v in pairs(dungeoInfos) do
        if v.id == dungeonId then
            return true
        end
    end
    return false
end

function DungeonProxy:onGetExterInsatance()
    local data = self:getDungeonListInfo()
    if self._isExterInstance ~= nil then
        self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.DungeonModule})
        local infos 
        if self._isExterInstance ~= 0 then
            infos = data.dungeoExplore[self._isExterInstance]
            self:setCurrType(infos.id,2)
        else
            local function getMaxValue(tb,key)
                local maxkey = 0
                local maxValue = nil
                for _,value in pairs(tb) do
                    if value[key] > maxkey then
                        maxkey = value[key]
                        maxValue = value
                    end
                end
                return maxValue
            end
            infos = getMaxValue(data.dungeoInfos,"id")
            self:setCurrType(infos.id,1)
        end

        print("打开副本啦阿里啦la..................")
        local data = {}
        data.moduleName = ModuleName.DungeonModule
        data.extraMsg = true
        -- data["isPerLoad"] = true
        data.isPerLoad = true
        self:sendAppEvent(AppEvent.MODULE_EVENT,AppEvent.MODULE_OPEN_EVENT,data)
        self._isExterInstance = nil
    end
    self:sendNotification(AppEvent.PROXY_DUNGEON_LIST_INFO_UPDATE, {})
end

function DungeonProxy:setExploreStatus(type)
    self._exploreStatus = type
end

function DungeonProxy:getExploreStatus()
    return self._exploreStatus
end


-------副本的信息的缓存----------------
function DungeonProxy:setAlldungeoInfos(dungeoInfos)
    for _,v in pairs(dungeoInfos) do
        self._alldungeoInfos[v.dungeoId] = v
    end
end

function DungeonProxy:updateOnedungeonInfoById(id,info)
    info["dungeoId"] = id
    self._alldungeoInfos[id] = info
end

function DungeonProxy:getDungeonById(id)
    return self._alldungeoInfos[id]
end

function DungeonProxy:setCurrentTimes(num)
    self.currentTimes = num
end

function DungeonProxy:getCurrentTimes()
    return self.currentTimes or 0
end

---60001协议与60006协议的 武将切磋  和  军械争夺  刷新剩余次数 和星星数目
function DungeonProxy:onUpdateDungeonInfos(data)
    if rawget(data,"dungeoExplore") then
        local dungeoExplore = rawget(data,"dungeoExplore")
        for key,v in pairs(self._alldungeoInfos) do
            if key == dungeoExplore.id then
                self._alldungeoInfos[key].times = dungeoExplore.count
                self._alldungeoInfos[key].timesTotal = dungeoExplore.totalCount
                self._alldungeoInfos[key].star = dungeoExplore.star
                self._alldungeoInfos[key].totalStar = dungeoExplore.totalStar
                self:sendNotification(AppEvent.PROXY_DUNGEON_GET_INFOS, self._alldungeoInfos[key])
            end
        end
    end
end

function DungeonProxy:getWhichPosByType(type,id)  --得到副本的次数
    local infos
    local data  = self:getDungeonListInfo()
    if type == 1 then  --战役
        infos = data.dungeoInfos
    elseif type == 2 then --探险
        infos = data.dungeoExplore
    end
    for index = 1,#infos do
        if infos[index].id == id then
            return #infos - index + 1
        end
    end
    return ""
end

--------------通过id获得武将切磋(1)或军械争夺(2)的剩余次数--------------
function DungeonProxy:getTimesById(id)
    local config = ConfigDataManager:getConfigById(ConfigData.AdventureConfig, id)
    if config ~= nil then
        local proxy = self:getProxy(GameProxys.Role)
        local level = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
        if level < config.level then
            return 0
        end
    end     
    local data =  self:getDungeonListInfo()
    for _,v in pairs(data.dungeoExplore) do
        if v.id == id then
            return v.count
        end
    end
end


-------------------------------------------------------------------------
function DungeonProxy:onTriggerNet60001Req(data)
    self:syncNetReq(AppEvent.NET_M6, AppEvent.NET_M6_C60001, data)
end

function DungeonProxy:onTriggerNet60003Req(data)
    self:syncNetReq(AppEvent.NET_M6, AppEvent.NET_M6_C60003, data)
end

function DungeonProxy:onTriggerNet60004Req(data)
    self:syncNetReq(AppEvent.NET_M6, AppEvent.NET_M6_C60004, data)
end

function DungeonProxy:onTriggerNet60106Req(data)
    self:syncNetReq(AppEvent.NET_M6, AppEvent.NET_M6_C60106, data)
end



------------------------------------------------------------------------
function DungeonProxy:onTriggerNet60001Resp(data)
    if data.rs == 0 then
        self:updateOnedungeonInfoById(data.dungeoId,data)
        self:sendNotification(AppEvent.PROXY_DUNGEON_GET_INFOS, data)
    end
end

function DungeonProxy:onTriggerNet50001Resp(data)
    self:sendNotification(AppEvent.PROXY_DUNGEON_FIGHT_OVER, data)
end

function DungeonProxy:onTriggerNet60003Resp(data)
    self:sendNotification(AppEvent.PROXY_DUNGEON_GET_BOXREWARD, data)
    -- local roleProxy = self:getProxy(GameProxys.Role)
    -- if data.rs == 0 then
    --     if #data.rewards > 0 then
    --         for k,v in pairs(data.rewards) do
    --             self:runRewardAction(v)
    --         end
    --     end
    -- end
end

-- function DungeonProxy:runRewardAction(data)
--     local node = cc.Node:create()
--     if data.num > 0 then
--         local str = string.format("+%d", data.num)
--         local text = ccui.Text:create()
--         text:setFontName(GlobalConfig.fontName)
--         text:setString(str)
--         text:setFontSize(RewardActionConfig.FONT_SIZE)
--         text:setColor(ColorUtils.wordGreenColor)
--         text:setAnchorPoint(cc.p(0, 0.5))
--         text:setPosition(RewardActionConfig.DISTANCE, 0)
--         node:addChild(text)
--     end
--     data.num = 1
--     local rewardIcon = UIIcon.new(node, data , true)
--     rewardIcon:setTouchEnabled(false)
--     rewardIcon:setScale(RewardActionConfig.ICON_SCALE)
--     local layer = self:getCurGameLayer(GameLayer.popLayer)
--     local winSize = cc.Director:getInstance():getWinSize()
--     node:setPosition(winSize.width*0.5, winSize.height*0.5)
--     layer:addChild(node)
--     local moveBy = cc.MoveBy:create(RewardActionConfig.INTERVAL_TIME, cc.p(0, 30))
--     local callback = cc.CallFunc:create(function()
--         node:removeFromParent()
--     end)
--     node:runAction(cc.Sequence:create(moveBy, callback))
-- end

function DungeonProxy:onTriggerNet60004Resp(data)
    self:sendNotification(AppEvent.PROXY_DUNGEON_BUY_TIMES, data)
end

function DungeonProxy:onTriggerNet60104Resp(data)
    self:sendNotification(AppEvent.PROXY_DUNGEON_FIRST_PASS, data)
end

function DungeonProxy:onTriggerNet20301Resp(data)
    self:sendNotification(AppEvent.PROXY_DUNGEON_GET_NEWGIFT, data)
end

function DungeonProxy:onTriggerNet60106Resp(data)
    -- self:sendNotification(AppEvent.PROXY_DUNGEON_GET_NEWGIFT, data)
    if data.rs == 0 then
        if (not self._alldungeoInfos) or (not self._allDungeonListInfos) then
            return
        end
        local function resetData(param, id, num)
            for k,v in pairs(param) do
                if v.count ~= -1 and v.id == id then
                    param[k].count = num
                end
            end
        end
        for i=1,#data.info do
            for k,v in pairs(self._alldungeoInfos) do
                if k == data.info[i].id then
                    v.times = data.info[i].times
                    self:sendNotification(AppEvent.PROXY_DUNGEON_RESET_DATA, data.info[i].times)
                end
            end
            resetData(self._allDungeonListInfos.dungeoExplore, data.info[i].id, data.info[i].times)
        end
    -- for k,v in pairs(self._alldungeoInfos) do
    --     if type(v) == "table" then
    --         for ka,va in pairs(v) do
    --             if ka == "times" then
    --                 self._alldungeoInfos[k][ka] = 5
    --                 self:sendNotification(AppEvent.PROXY_DUNGEON_RESET_DATA, 5)
    --             end
    --         end
    --     else
    --         if k == "times" then
    --             self._alldungeoInfos[k] = 5
    --             self:sendNotification(AppEvent.PROXY_DUNGEON_RESET_DATA, 5)
    --         end
    --     end
    -- end
    
    -- --刷新外面的数据
        self:sendNotification(AppEvent.PROXY_DUNGEON_LIST_INFO_UPDATE, {})
        self:updateRedPoint()
    end
end

--小红点更新
function DungeonProxy:updateRedPoint()
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:checkDungeonRedPoint() 
end


-- function DungeonProxy:getBoxes()
--     local boxes = {}
--     for k,v in pairs(self._allDungeonListInfos.dungeoExplore) do
--         if v.id == 1 then
--             --匈奴远征
--            boxes[1] = v.haveBox
--         end
--         if v.id == 2 then
--             --鲜卑远征
--            boxes[2] = v.haveBox
--         end
--     end
--     return boxes
-- end

-- 根据远征副本id获取远征副本数据
function DungeonProxy:getExploreInfoByID(id)
    if self._allDungeonListInfos.dungeoExplore then
        return self._allDungeonListInfos.dungeoExplore[id]
    end
    return nil
end

-- 获取全部远征数据
function DungeonProxy:getAllExploreInfos()
    if self._allDungeonListInfos.dungeoExplore then
        return self._allDungeonListInfos.dungeoExplore
    end
    return nil
end

-- 子战斗类型
function DungeonProxy:getSubBattleType()
    return self._subtype
end

-- 子战斗类型
function DungeonProxy:setSubBattleType(type)
    self._subtype = type
end
