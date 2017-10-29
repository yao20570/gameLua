-- /**
--  * @Author:      fzw
--  * @DateTime:    2016-04-19 11:27:51
--  * @Description: 军团副本协议
--  */
DungeonXProxy = class("DungeonXProxy", BasicProxy)

function DungeonXProxy:ctor()
    DungeonXProxy.super.ctor(self)
    self.proxyName = GameProxys.DungeonX
    
    -- self._allMapData = {}
    -- self._alleventInfos = {}
    -- self._allData = {}
    -- self:initData()
    self:resetCountSyncData()

    self._isInit = true  -- true=未收过协议270000，false=已收过270000 ,离开军团时候要置为true哦
end

function DungeonXProxy:resetAttr()
    self.proxyName = GameProxys.DungeonX
    -- self._allMapData = {}
    -- self._alleventInfos = {}
    -- self._allData = {}
    self:resetCountSyncData()
end

function DungeonXProxy:registerNetEvents()
    self:addEventListener(AppEvent.PROXY_LEGION_EXIT_INFO, self, self.setLegionExit)
end

function DungeonXProxy:unregisterNetEvents()
    self:addEventListener(AppEvent.PROXY_LEGION_EXIT_INFO, self, self.setLegionExit)
end

-- 4点重置
function DungeonXProxy:resetCountSyncData()
    -- body
    -- logger:info("4点重置 .... 军团副本")
    self._allMapData = {}
    self._alleventInfos = {}
    self._allData = {}

    self:initData()
end

--start 初始化数据----------------------------------------------------------------------------------
function DungeonXProxy:initData()
    -- body
    -- message DungeonInfo{   //副本的章节信息
    --     required int32 id = 1;                  //副本章节id
    --     required int32 curCapterCount = 2;      //剩余未击杀据点数量
    --     required int32 maxCapterCount = 3;      //总据点数量
    --     required int32 curBoxCount = 4;         //剩余可领取宝箱数量
    --     required int32 maxBoxCount = 5;         //总可领取宝箱数量
    --     required int32 curID = 6;               //当前攻打第几关，如果没有，则为-1
    --     required int32 openFlag = 7;            //当前章节解锁标记，0=未解锁，1=已解锁
    -- }
    -- required int32 curCount = 3;                //当日剩余攻击次数，如果没有，则为-1
    -- required int32 totalCount = 4;              //当日最大攻击次数，如果没有，则为-1
-- message EventInfo{   //副本的关卡信息
--     required int32 id = 1;                  //关卡id
--     required int32 chapter = 2;             //所属章节id
--     optional MonsterInfo monsterInfos = 3;  //关卡怪物信息
--     optional int32 force = 4;               //怪物战力
--     required int32 curProgress = 5;         //当前关卡攻打进度百分比
--     optional int32 haveBox = 6;             //是否有可领取宝箱，1=有，0=没有
-- }
-- message MonsterInfo{   //关卡信息
--     required int32 id = 1;//关卡id
--     required int32 post = 2;//位置
--     required int32 num = 3;//怪物数量
-- }
    -- 军团副本的战斗类型应该定为type=6
    -- 军团副本的战斗类型应该定为type=6
    -- 军团副本的战斗类型应该定为type=6
    self._maxPassId = 0
    
    local tabData = {
                        {id = 1, curCapterCount = 5, maxCapterCount = 5, curBoxCount = 0, maxBoxCount = 0, openFlag = 1},
                        {id = 2, curCapterCount = 5, maxCapterCount = 5, curBoxCount = 0, maxBoxCount = 0, openFlag = 0},
                        {id = 3, curCapterCount = 5, maxCapterCount = 5, curBoxCount = 0, maxBoxCount = 0, openFlag = 0},
                        {id = 4, curCapterCount = 5, maxCapterCount = 5, curBoxCount = 0, maxBoxCount = 0, openFlag = 0},
                        {id = 5, curCapterCount = 5, maxCapterCount = 5, curBoxCount = 0, maxBoxCount = 0, openFlag = 0},
                    }
    local allData = {}
    allData.curCount = 5
    allData.totalCount = 5
    allData.dungeonInfos = tabData
    self._allData = allData


    local monsterData = {
                        {id = 1001, post = 1, num = 23},
                        {id = 1002, post = 2, num = 33},
                        {id = 1003, post = 3, num = 43},
                        {id = 1004, post = 4, num = 53},
                        }

    local eventData1 = {
                        {id = 01, chapter = 1, force = 0, curProgress = 10000.00, haveBox = 0, monsterInfos = monsterData},
                        {id = 02, chapter = 1, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        {id = 03, chapter = 1, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        {id = 04, chapter = 1, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        {id = 05, chapter = 1, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        }
    local eventData2 = {
                        {id = 06, chapter = 2, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        {id = 07, chapter = 2, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        {id = 08, chapter = 2, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        {id = 09, chapter = 2, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        {id = 10, chapter = 2, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        }
    local eventData3 = {
                        {id = 11, chapter = 3, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        {id = 12, chapter = 3, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        {id = 13, chapter = 3, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        {id = 14, chapter = 3, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        {id = 15, chapter = 3, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        }
    local eventData4 = {
                        {id = 16, chapter = 4, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        {id = 17, chapter = 4, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        {id = 18, chapter = 4, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        {id = 19, chapter = 4, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        {id = 20, chapter = 4, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        }
    local eventData5 = {
                        {id = 21, chapter = 5, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        {id = 22, chapter = 5, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        {id = 23, chapter = 5, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        {id = 24, chapter = 5, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        {id = 25, chapter = 5, force = 0, curProgress = -01.00, haveBox = 0, monsterInfos = monsterData},
                        }

    local allMapData = {}

    self._alleventInfos = {}
    self._alleventInfos[1] = eventData1
    self._alleventInfos[2] = eventData2
    self._alleventInfos[3] = eventData3
    self._alleventInfos[4] = eventData4
    self._alleventInfos[5] = eventData5
    self._allMapData = allMapData

    self._conf = ConfigDataManager:getConfigData(ConfigData.LegionEventConfig)
end
--end 初始化数据----------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------
-- 初始化数据
--------------------------------------------------------------------------------------------------
function DungeonXProxy:initSyncData(data)
    -- body
    DungeonXProxy.super.initSyncData(self, data)
    -- logger:info("初始化数据···DungeonXProxy:initSyncData(data)")
    -- 副本箱子初始化
    for key, value in pairs(data) do
        if key == "legionDungeonInfos" then
            for k,v in pairs(data.legionDungeonInfos) do
                v.openFlag = 1
                self._allData.dungeonInfos[v.id] = v
            end
            break
        end
    end

    -- 军团剩余可挑战次数初始化
    self._allData.curCount = data.legDunCurCount -- 军团副本攻击剩余次数

end

--------------------------------------------------------------------------------------------------
-- 请求协议
--------------------------------------------------------------------------------------------------
-- 请求章节信息
function DungeonXProxy:onTriggerNet270000Req(data)
    -- body
    -- print("请求章节信息onTriggerNet270000Req...",data)
    self:syncNetReq(AppEvent.NET_M27, AppEvent.NET_M27_C270000, data)
end

-- 挑战询问
function DungeonXProxy:onTriggerNet270002Req(data)
    -- body 
    if rawget(data, 'infos') then
        self._hasAskFlag = true
    else
        self._hasAskFlag = false
    end
    -- print("onTriggerNet270002Req...",data)
    self:syncNetReq(AppEvent.NET_M27, AppEvent.NET_M27_C270002, data)
end

-- 领取宝箱奖励
function DungeonXProxy:onTriggerNet270003Req(data)
    -- body 
    -- print("onGetBoxReq...",data)
    self:syncNetReq(AppEvent.NET_M27, AppEvent.NET_M27_C270003, data)
end

-- 请求据点信息
function DungeonXProxy:onTriggerNet270004Req(data)
    -- body
    -- print("请求据点信息onTriggerNet270004Req...",data)
    self:syncNetReq(AppEvent.NET_M27, AppEvent.NET_M27_C270004, data)
end

--------------------------------------------------------------------------------------------------
-- 接收协议
--------------------------------------------------------------------------------------------------
function DungeonXProxy:onTriggerNet270000Resp(data)
    -- body 副本章节列表信息
    if data.rs == 0 then
        -- logger:info("接收协议···DungeonXProxy:onTriggerNet270000Resp(data)")
        -- 章节信息
        if data.dungeonInfos ~= nil then

            for k,v in pairs(data.dungeonInfos) do
                -- logger:info("章节信息（270000）···id, curCapterCount, curBoxCount maxPassId = %d %d %d %d", v.id, v.curCapterCount, v.curBoxCount, data.maxPassId)
                v.openFlag = 1

                self._allData.dungeonInfos[v.id] = v

                if v.curCapterCount == 0 and v.id > data.maxPassId then
                    -- 解锁下一个章节
                    -- logger:info("（270004）...解锁下一个章节")
                    self._allData.dungeonInfos[v.id+1].openFlag = 1
                    self._alleventInfos[v.id+1][1].curProgress = 10000
                end

            end


        end

        -- 关卡信息
        if data.eventInfos ~= nil then
            -- 据点信息更新
            -- print("据点表长度···#eventInfos", #data.eventInfos)
            for k,v in pairs(data.eventInfos) do
                print("关卡信息（270000）···id,chapter,curProgress,haveBox",v.id,v.chapter,v.curProgress,v.haveBox)
                for i,j in pairs(v.monsterInfos) do
                    print(i,j.id,j.post,j.num)
                end
                print("... force",v.id,v.chapter,v.force)

                local sort = self._conf[v.id].sort
                self._alleventInfos[v.chapter][sort] = v
            end

            -- -- 发送据点更新通知
            -- self:sendNotification(AppEvent.PROXY_DUNGEONX_EVENT_UPDATE, {})
        end
        
        self._allData.curCount = data.curCount
        -- self._allData.totalCount = data.totalCount
        self._maxPassId = data.maxPassId

        self:updateIsInit(false)


        -- 发送章节列表更新通知
        self:sendNotification(AppEvent.PROXY_DUNGEONX_CHAPTER_UPDATE, {})
        local isShow = self:isModuleShow(ModuleName.DungeonXModule)
        if isShow then
            -- -- 发送据点更新通知
            self:sendNotification(AppEvent.PROXY_DUNGEONX_EVENT_UPDATE, {})
        end
        -- 关卡宝箱感叹号更新
        self:sendNotification(AppEvent.PROXY_DUNGEONX_TIP_UPDATE, {})
    end
end

function DungeonXProxy:onTriggerNet270001Resp(data)
    -- body 关卡挑战
    -- if data.rs == 0 then
    --     logger:info("···DungeonXProxy:onTriggerNet270001Resp(data)")
    -- end
end


function DungeonXProxy:onTriggerNet270002Resp(data)
    -- body 挑战关卡询问
    if data.rs == 0 then
        -- 发送章节列表更新通知
        if self._hasAskFlag ~= true then
            self._hasAskFlag = true
            -- logger:info("270002  发通知")
            self:sendNotification(AppEvent.PROXY_DUNGEONX_EVENT_ANSWER, data)
        end
    end
end
-- body 关卡宝箱领取
function DungeonXProxy:onTriggerNet270003Resp(data)
    -- body 关卡宝箱领取
    -- logger:info("···DungeonXProxy:onTriggerNet270003Resp(data) data.rs=%d", data.rs)
    if data.rs == 0 then
        -- logger:info("···DungeonXProxy:onTriggerNet270003Resp(data)  00  curID %d", self._curChapterID)
        
        
        for k,v in pairs(self._alleventInfos[self._curChapterID]) do
            if v.id == data.id then
                -- logger:info("···DungeonXProxy:onTriggerNet270003Resp(data)  11 ")

                v.haveBox = 0
                local sort = self._conf[v.id].sort
                self._alleventInfos[self._curChapterID][sort] = v

                self:showSysMessage(TextWords:getTextWord(3702))
                self:sendNotification(AppEvent.PROXY_DUNGEONX_BOX_UPDATE, v)
                -- 关卡宝箱感叹号更新
                self:sendNotification(AppEvent.PROXY_DUNGEONX_TIP_UPDATE, {})
                -- 章节信息更新可领取宝箱数量
                if self._allData ~= nil and self._allData.dungeonInfos ~= nil then
                    local num = self._allData.dungeonInfos[self._curChapterID].curBoxCount
                    if num > 0 then
                        self._allData.dungeonInfos[self._curChapterID].curBoxCount = num - 1
                        self:sendNotification(AppEvent.PROXY_DUNGEONX_CHAPTER_UPDATE, {})
                    end
                    -- 关卡宝箱感叹号更新
                    self:sendNotification(AppEvent.PROXY_DUNGEONX_TIP_UPDATE, {})
                end
                return
            end
        end
        
    end
end

function DungeonXProxy:onTriggerNet270004Resp(data)
    -- body 获取某章节的关卡详细信息
    if data.rs == 0 then
        -- print("关卡详细信息更新···DungeonXProxy:onTriggerNet270004Resp(data) data.curCount",data.curCount)
        self._allData.curCount = data.curCount
        
        -- 关卡宝箱感叹号更新
        self:sendNotification(AppEvent.PROXY_DUNGEONX_TIP_UPDATE, {})

        if data.maxPassId ~= nil then
            -- logger:info("270004 self._maxPassId, data.maxPassId = %d %d", data.maxPassId, self._maxPassId)
            if self._maxPassId < data.maxPassId then
                self._maxPassId = data.maxPassId
            end
        end
        
        self:updateDungeonEventListInfos(data.eventInfos)
    end
end

-- 更新关卡据点信息
function DungeonXProxy:updateDungeonEventListInfos(eventInfos)
    -- body
    if eventInfos ~= nil then
        -- 据点信息更新
        for k,v in pairs(eventInfos) do

            logger:info("关卡信息（270004）···id,chapter,curProgress,haveBox = %d %d %d %d",v.id,v.chapter,v.curProgress,v.haveBox)
            for i,j in pairs(v.monsterInfos) do
                print(i,j.id,j.post,j.num)
            end
            print("... force",v.id,v.chapter,v.force)
            
            -- 更新当前据点信息
            local sort = self._conf[v.id].sort
            self._alleventInfos[v.chapter][sort] = nil
            self._alleventInfos[v.chapter][sort] = v  --更新据点数据


            -- 当前据点已通关
            if v.curProgress == 0 then
                -- if v.id <= self._maxPassId then
                if v.id < self._maxPassId then
                    -- 不用判定是否要解锁

                else
                    -- 要判定是否要解锁
                    if sort < 5 then
                        -- 解锁下一个据点
                        -- logger:info("（270004）···解锁下一个据点")
                        self._alleventInfos[v.chapter][sort+1].curProgress = 10000 --UI里自行除于100


                    elseif sort == 5 and v.chapter < 5 then
                        -- 解锁下一个章节
                        -- logger:info("（270004）...解锁下一个章节")
                        self._allData.dungeonInfos[v.chapter+1].openFlag = 1
                        self._alleventInfos[v.chapter+1][1].curProgress = 10000
                    end

                end

                -- logger:info("（270004）...更新章节数量Count")
                -- 更新章节信息
                self._allData.dungeonInfos[v.chapter].curCapterCount = self._allData.dungeonInfos[v.chapter].curCapterCount - 1
                
                -- 更新宝箱信息
                if v.haveBox == 1 then
                    self._allData.dungeonInfos[v.chapter].curBoxCount = self._allData.dungeonInfos[v.chapter].curBoxCount + 1
                end
                self._allData.dungeonInfos[v.chapter].maxBoxCount = self._allData.dungeonInfos[v.chapter].maxBoxCount + 1
            end
        end

        -- 发送章节更新通知
        self:sendNotification(AppEvent.PROXY_DUNGEONX_CHAPTER_UPDATE, {})
        -- 关卡宝箱感叹号更新
        self:sendNotification(AppEvent.PROXY_DUNGEONX_TIP_UPDATE, {})
        local isShow = self:isModuleShow(ModuleName.DungeonXModule)
        if isShow then
            -- 发送据点更新通知
            self:sendNotification(AppEvent.PROXY_DUNGEONX_EVENT_UPDATE, {})            
        end

    end
    
end



--------------------------------------------------------------------------------------------------
-- 公共接口
--------------------------------------------------------------------------------------------------
function DungeonXProxy:setCurChapterID(id)
    -- body
    self._curChapterID = id
end

function DungeonXProxy:getCurChapterID()
    -- body
    return self._curChapterID
end

function DungeonXProxy:getOneChapterEventsInfoByID(id) --章节id
    -- body 获取某一章节的全部关卡信息
    -- print("getOneChapterEventsInfoByID...···cur id=",id)
    if self._alleventInfos ~= nil and id ~= nil then
        return self._alleventInfos[id]
    else
        return nil
    end
end

function DungeonXProxy:getOneEventInfoByID(chapter, id) --章节id，关卡id
    -- body 获取某一章节的某个关卡信息
    -- print("getOneEventInfoByID···chapter,id",chapter,id)
    if self._alleventInfos ~= nil and chapter ~= nil and id ~= nil then
        return self._alleventInfos[chapter][id]
    else
        return nil
    end
end

function DungeonXProxy:getMaxPassedID()
    -- body 获取最高通关的关卡ID
    -- logger:info("getMaxPassedID %d", self._maxPassId)
    return self._maxPassId
end

function DungeonXProxy:getAllDungeonData()
    -- body
    return self._allData
end

function DungeonXProxy:getAllDungeonMapData()
    -- body
    return self._allMapData
end

function DungeonXProxy:getAllDungeonEventInfos()
    -- body
    return self._alleventInfos
end

function DungeonXProxy:updateIsInit(data)
    -- body
    self._isInit = data
end

function DungeonXProxy:isInit()
    -- body
    return self._isInit
end

-- 从代理拿配表数据，避免panel二次解析
function DungeonXProxy:getConfigData()
    -- body
    return self._conf
end

-- 退出军团/被踢出军团/转让军团
function DungeonXProxy:setLegionExit()
    -- body
    self._isInit = true
    self:initData()
end

function DungeonXProxy:updateAskFlag(flag)
    self._hasAskFlag = flag
end



------
-- 计算可领取箱子总数量
function DungeonXProxy:canGetAllCurBoxCount()
    local allCurBoxCount = 0
    if self._allData ~= nil then -- 有数据用原数据
        for key, value in pairs(self._allData.dungeonInfos) do
            allCurBoxCount = value.curBoxCount + allCurBoxCount
        end
    end
    
    return allCurBoxCount
end


------
-- 获取剩余攻打次数
function DungeonXProxy:canFightCurCount()
    return self._allData.curCount
end

------
-- 是否有可领取的宝箱, 不为0返回true
function DungeonXProxy:checkRewardBoxState()
    local count = self:canGetAllCurBoxCount()
    local state = count ~= 0
    return state
end

------
-- 是否有剩余次数, 不为0/-1 则返回true
function DungeonXProxy:checkFightCurState()
    local count = self:canFightCurCount()
    local state = count ~= 0 
    if count == -1 then
        state = false
    end 
    return state
end