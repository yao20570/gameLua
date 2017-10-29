-- /**
--  * @Author:	  lizhuojian
--  * @DateTime:	2017-4-11
--  * @Description: 酒馆数据代理
--  */

PubProxy = class("PubProxy", BasicProxy)

function PubProxy:ctor()
    PubProxy.super.ctor(self)
    self.proxyName = GameProxys.Pub
    --小宴数据结构
    self.banquetInfo = {}
    --盛宴数据结构
    self.feastInfo = {}
    --免费次数结构
    self.pubFreeData = {}
    --小宴跑马灯数据（历史记录）
    self.banquetHistoryInfos = {}
    --盛宴跑马灯数据（历史记录）
    self.feastHistoryInfos = {}
    --女儿红typeId
    self.norItemTypeId = nil
    --竹叶青typeId
    self.speItemTypeId = nil
    --酒令兑换剩余次数信息
    self.drinkOrderTimeInfos = {}
end
-- 初始化活动数据 M20000
function PubProxy:initSyncData(data) 
    local pubDrawConfig = ConfigDataManager:getConfigById(ConfigData.PubDrawConfig, 1)
    local consume = StringUtils:jsonDecode(pubDrawConfig.consume)
    self.norItemTypeId    = consume[1][2]       --女儿红(奇宝币)typeId 4014
    pubDrawConfig = ConfigDataManager:getConfigById(ConfigData.PubDrawConfig, 2)
    local consume = StringUtils:jsonDecode(pubDrawConfig.consume)
    self.speItemTypeId    = consume[1][2]       --竹叶青(神兵币)typeId 4042
end

function PubProxy:afterInitSyncData()

end

function PubProxy:resetAttr()
    -- local redPointProxy = self:getProxy(GameProxys.RedPoint)
    -- redPointProxy:checkFreeFindBoxRedPoint()
    -- self:sendNotification(AppEvent.PROXY_PUB_ALL_UPDATE)
end
function PubProxy:resetCountSyncData()

    local pubDrawConfig = ConfigDataManager:getConfigById(ConfigData.PubDrawConfig, 1)
    local norFreemax = pubDrawConfig.freemax
    pubDrawConfig = ConfigDataManager:getConfigById(ConfigData.PubDrawConfig, 2)
    local speFreemax = pubDrawConfig.freemax
    self:setPubFreeData(norFreemax,speFreemax)
    self:sendNotification(AppEvent.PROXY_PUB_ALL_UPDATE)
    
end

--获取酒馆小宴信息
function PubProxy:onTriggerNet450000Req(data)
	self:syncNetReq(AppEvent.NET_M45, AppEvent.NET_M45_C450000, {})
end
--获取酒馆盛宴信息
function PubProxy:onTriggerNet450001Req(data)
    self:syncNetReq(AppEvent.NET_M45, AppEvent.NET_M45_C450001, {})
end
--小宴购买女儿红
function PubProxy:onTriggerNet450002Req(data)
    self:syncNetReq(AppEvent.NET_M45, AppEvent.NET_M45_C450002, {})
end
--盛宴购买竹叶青
function PubProxy:onTriggerNet450003Req(data)
    self:syncNetReq(AppEvent.NET_M45, AppEvent.NET_M45_C450003, {})
end
--小宴单抽
function PubProxy:onTriggerNet450004Req(data)
    self:syncNetReq(AppEvent.NET_M45, AppEvent.NET_M45_C450004, {})
end
--小宴九抽
function PubProxy:onTriggerNet450005Req(data)
    self:syncNetReq(AppEvent.NET_M45, AppEvent.NET_M45_C450005, {})
end
--盛宴单抽
function PubProxy:onTriggerNet450006Req(data)
    self:syncNetReq(AppEvent.NET_M45, AppEvent.NET_M45_C450006, {})
end
--盛宴九抽
function PubProxy:onTriggerNet450007Req(data)
    self:syncNetReq(AppEvent.NET_M45, AppEvent.NET_M45_C450007, {})
end
--酒令兑换（购买）
function PubProxy:onTriggerNet450008Req(data)
    self:syncNetReq(AppEvent.NET_M45, AppEvent.NET_M45_C450008, data)
end
--小宴界面公告
function PubProxy:onTriggerNet450009Req(data)
    self:syncNetReq(AppEvent.NET_M45, AppEvent.NET_M45_C450009, {})
end
--盛宴界面公告
function PubProxy:onTriggerNet450010Req(data)
    self:syncNetReq(AppEvent.NET_M45, AppEvent.NET_M45_C450010, {})
end
--获取酒令兑换信息
function PubProxy:onTriggerNet450011Req(data)
    self:syncNetReq(AppEvent.NET_M45, AppEvent.NET_M45_C450011, {})
end
--------------------------------协议返回---------------------------------------------
--获取酒馆小宴信息
function PubProxy:onTriggerNet450000Resp(data)
    if data.rs >= 0 then
        --免费次数
        self:setNorPubFreeData(data.banquetInfo.banquetFreeTime)
        self:setBanquetInfo(data.banquetInfo)
        self:sendNotification(AppEvent.PROXY_PUB_NORINFO_UPDATE)
    end
end
--获取酒馆盛宴信息
function PubProxy:onTriggerNet450001Resp(data)
    if data.rs >= 0 then
        --免费次数
        self:setSpePubFreeData(data.feastInfo.feastFreeTime)
        self:setFeastInfo(data.feastInfo)
        self:sendNotification(AppEvent.PROXY_PUB_SPEINFO_UPDATE)
    end
end
--小宴购买女儿红
function PubProxy:onTriggerNet450002Resp(data)
    self:sendNotification(AppEvent.PROXY_PUB_NOR_BUYITEM_450002,data.rs)
    if data.rs >= 0 then
        --购买成功通知界面去掉屏蔽层
        self:sendNotification(AppEvent.PROXY_PUB_BUY_NORITEM)
    end
end
--盛宴购买竹叶青
function PubProxy:onTriggerNet450003Resp(data)
    self:sendNotification(AppEvent.PROXY_PUB_SPE_BUYITEM_450003,data.rs)
    if data.rs >= 0 then
        --购买成功通知界面去掉屏蔽层
        self:sendNotification(AppEvent.PROXY_PUB_BUY_SPEITEM)
    end
end
--小宴单抽
function PubProxy:onTriggerNet450004Resp(data)
    if data.rs >= 0 then
        self:setNorPubFreeData(data.banquetInfo.banquetFreeTime)
        self:setBanquetInfo(data.banquetInfo)
        --单抽显示单个奖励
        self:sendNotification(AppEvent.PROXY_PUB_NOR_ONE_OPEN,data.reward)
    end
end
--小宴九抽
function PubProxy:onTriggerNet450005Resp(data)
    self:sendNotification(AppEvent.PROXY_PUB_NOR_NINE_450005,data.rs)
    if data.rs >= 0 then
        self:setNorPubFreeData(data.banquetInfo.banquetFreeTime)
        self:setBanquetInfo(data.banquetInfo)
        --九抽显示九个奖励
        self:sendNotification(AppEvent.PROXY_PUB_NOR_NINE_OPEN,data.reward)
    end
end
--盛宴单抽
function PubProxy:onTriggerNet450006Resp(data)
    if data.rs >= 0 then
        self:setSpePubFreeData(data.feastInfo.feastFreeTime)
        self:setFeastInfo(data.feastInfo)
        --单抽显示单个奖励
        self:sendNotification(AppEvent.PROXY_PUB_SPE_ONE_OPEN,data.reward)
    end
end
--盛宴九抽
function PubProxy:onTriggerNet450007Resp(data)
    self:sendNotification(AppEvent.PROXY_PUB_SPE_NINE_450007,data.rs)
    if data.rs >= 0 then
        self:setSpePubFreeData(data.feastInfo.feastFreeTime)
        self:setFeastInfo(data.feastInfo)
        --九抽显示九个奖励
        self:sendNotification(AppEvent.PROXY_PUB_SPE_NINE_OPEN,data.reward)
    end
end
--酒令兑换（购买）
function PubProxy:onTriggerNet450008Resp(data)
    if data.rs >= 0 then
        self.drinkOrderTimeInfos = data.drinkOrderTimeInfo
        self:sendNotification(AppEvent.PROXY_PUB_SHOP_UPDATE)
    end
end
--小宴界面公告(跑马灯历史数据)
function PubProxy:onTriggerNet450009Resp(data)
    if data.rs >= 0 then
        self.banquetHistoryInfos = data.banquetNotice
        self:sendNotification(AppEvent.PROXY_PUB_NOR_HISTORY_UPDATE)
    end
end
--盛宴界面公告(跑马灯历史数据)
function PubProxy:onTriggerNet450010Resp(data)
    if data.rs >= 0 then
        self.feastHistoryInfos = data.feastNotice
        self:sendNotification(AppEvent.PROXY_PUB_SPE_HISTORY_UPDATE)
    end
end
--获取酒令兑换信息
function PubProxy:onTriggerNet450011Resp(data)
    if data.rs >= 0 then
        self.drinkOrderTimeInfos = data.drinkOrderTimeInfo
        self:sendNotification(AppEvent.PROXY_PUB_SHOP_UPDATE)
    end
end
------------------------数据----------------------------------
--小宴数据
function PubProxy:setBanquetInfo(banquetInfo)
    self.banquetInfo = banquetInfo
end
--盛宴数据
function PubProxy:setFeastInfo(feastInfo)
    self.feastInfo = feastInfo
end
-- 拥有的女儿红(奇兵币)数量
function PubProxy:getNorItemCount()
    local itemProxy = self:getProxy(GameProxys.Item)
    local count = itemProxy:getItemNumByType(self.norItemTypeId)
    return count
end
-- 拥有的竹叶青(神兵币)数量
function PubProxy:getSpeItemCount()
    local itemProxy = self:getProxy(GameProxys.Item)
    local count = itemProxy:getItemNumByType(self.speItemTypeId)
    return count
end
-- 奇兵币和神兵币的总数
function PubProxy:getNorSpeItemCount()
    local count = self:getNorItemCount() + self:getSpeItemCount()
    return count
end
--设置酒馆免费次数norTimes（小宴）,spcTimes（盛宴）
function PubProxy:setPubFreeData(norTimes,speTimes)
    local freeData = {}
    freeData[1] = {times = norTimes, type = 1}
    freeData[2] = {times = speTimes, type = 2}
    self.pubFreeData = freeData
    self:updateRedPoint()
end
--修改小宴免费次数
function PubProxy:setNorPubFreeData(norTimes)
    if self.pubFreeData[1] then
        self.pubFreeData[1].times = norTimes
    end
    self:updateRedPoint()
end
--修改盛宴免费次数
function PubProxy:setSpePubFreeData(speTimes)
    if self.pubFreeData[2] then
        self.pubFreeData[2].times = speTimes
    end
    self:updateRedPoint()
end
-- 获取普通与高级探宝免费次数的数据表
function PubProxy:getPubFreeData(type)
    if type ~= nil  then
        return self.pubFreeData[type].times
    end
    return self.pubFreeData
end
--获取小宴界面公告(跑马灯历史数据)
function PubProxy:getNorHistoryInfos()
    return self.banquetHistoryInfos or {}
end
--获取盛宴界面公告(跑马灯历史数据)
function PubProxy:getSpeHistoryInfos()
    return self.feastHistoryInfos or {}

end
--------------------------------------------------------
--小宴数据
function PubProxy:getBanquetInfo(banquetInfo)
    return self.banquetInfo or {}
end
--盛宴数据
function PubProxy:getFeastInfo(feastInfo)
    return self.feastInfo or {}
end
function PubProxy:setOpenData()

end


function PubProxy:getOpenData()
    return self.openData
end
function PubProxy:getPubShopTimesInfos()
    return self.drinkOrderTimeInfos or {}
end
function PubProxy:getPubShopTimesByID( typeId )
    for _,val in pairs(self.drinkOrderTimeInfos) do
        if val.typeId == typeId then
            return val.changeTime
        end
    end
    return 0
end

-- 判定酒馆盛宴是否已开放，未开放则飘字提示
function PubProxy:isUnlockSpePub(isShowMsg)
    return self:isUnlockPubByID(9,isShowMsg)
end


-- 判定战将探宝是否已开放，未开放则飘字提示
function PubProxy:isUnlockPubByID(id,isShowMsg)
    if id == nil then
        return false
    end

    local info = ConfigDataManager:getConfigById("NewFunctionOpenConfig", id)

    if info.type == 1 then  --type = 1 判定主公等级
        local unLockLevel = info.need
        local roleProxy = self:getProxy(GameProxys.Role)
        local currentLv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)

        if currentLv < unLockLevel then
            if isShowMsg then
                self:showSysMessage(string.format(TextWords:getTextWord(340000),info.need,info.name))
            end
            return false
        end
        return true
    else
        return false
    end

end
--小红点更新
function PubProxy:updateRedPoint()
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:checkFreeFindBoxRedPoint() 
end

--[[
-- /**
--  * @Description: 酒馆 (探宝，点兵)数据代理
--  */
LotteryProxy = class("LotteryProxy", BasicProxy)

function LotteryProxy:ctor()
    LotteryProxy.super.ctor(self)
    self.proxyName = GameProxys.Lottery
    self._lotteryInfos = {}
    self._initInfos = true
    self._lastRefreshTime = 0
    self._heroGoldCount = 0     --战将幸运币
    self._HeroLotteryInfo = {}  --战将信息
    self._heroRewards = {}      --战将抽奖获得物品信息
    self._histories = {}        --战将最近20名信息
    self._historiesMap = {}     --包含奇兵/神兵的最近20名信息

    self.HERO_KEY = "HeroLottery"  --定时器的key

end

function LotteryProxy:resetAttr()
    self._lotteryInfos = {}
    self._lastRefreshTime = 0
    self._initInfos = true
    -- self._HeroLotteryInfo = {}   --战将信息
    self._heroRewards = {}          --战将抽奖获得物品信息
    self._histories = {}            --最近20名信息
    self._historiesMap = {}         --最近20名信息
end

function LotteryProxy:resetCountSyncData()
    self:setTanbaoFreeData(1,0)
end

function LotteryProxy:registerNetEvents()
    --self:registerNetEvent(AppEvent.NET_M2, AppEvent.NET_M2_C20000, self, self.onRoleInfoResp)
    -- self:registerNetEvent(AppEvent.NET_M15, AppEvent.NET_M15_C150000, self, self.onGetLotteryInfosResp)
    -- self:registerNetEvent(AppEvent.NET_M15, AppEvent.NET_M15_C150001, self, self.onBuyLotteryResp)
    -- self:addEventListener(AppEvent.PROXY_GET_ROLE_INFO, self, self.updateRoleInfoRsp)
    -- self:addEventListener(AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoRsp)
end

function LotteryProxy:unregisterNetEvents()
    -- self:unregisterNetEvent(AppEvent.NET_M15, AppEvent.NET_M15_C150000, self, self.onGetLotteryInfosResp)
    -- self:unregisterNetEvent(AppEvent.NET_M15, AppEvent.NET_M15_C150001, self, self.onBuyLotteryResp)
    -- self:removeEventListener(AppEvent.PROXY_GET_ROLE_INFO, self, self.updateRoleInfoRsp)
    -- self:removeEventListener(AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoRsp)
end

-- function LotteryProxy:updateRoleInfoRsp(data)
--     local roleProxy = self:getProxy(GameProxys.Role)
--     local currentLv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
--     if currentLv >= 8  and self._initInfos then --TODO改成都配置表
--         self:onTriggerNet150000Req({})
--         self:onTriggerNet150001Req({})
--         self._initInfos = false
--     end
-- end

---------------------------------------------------------------------
-- 协议请求
---------------------------------------------------------------------
--请求抽奖数据刷新
function LotteryProxy:onTriggerNet150000Req(data)
    --print("奇兵 150000 req")
    self:syncNetReq(AppEvent.NET_M15,AppEvent.NET_M15_C150000, {})
end

--请求抽奖
function LotteryProxy:onTriggerNet150001Req(data)
    --print("神兵 150001 req")
    self:syncNetReq(AppEvent.NET_M15,AppEvent.NET_M15_C150001, {})
end
--购买探宝币（普通、高级、免费）
function LotteryProxy:onTriggerNet150003Req(data)
    self:syncNetReq(AppEvent.NET_M15,AppEvent.NET_M15_C150003, data)
end
--请求战将信息
function LotteryProxy:onTriggerNet150004Req(data)
    --print("150004 req")
    self:syncNetReq(AppEvent.NET_M15,AppEvent.NET_M15_C150004, {})
end

--请求战将开宝箱
function LotteryProxy:onTriggerNet150005Req(data)
    --print("150005 req")
    self:syncNetReq(AppEvent.NET_M15,AppEvent.NET_M15_C150005, {})
end

--请求战将探宝刷新奖励
function LotteryProxy:onTriggerNet150006Req(data)
    print("150006 req")
    self:syncNetReq(AppEvent.NET_M15,AppEvent.NET_M15_C150006, {})
end

--请求战将探宝抽取奖励
function LotteryProxy:onTriggerNet150007Req(data)
    print("150007 req")
    self:setLastIndex(data.index)
    self:syncNetReq(AppEvent.NET_M15,AppEvent.NET_M15_C150007, data)
end

--请求战将探关闭探宝
function LotteryProxy:onTriggerNet150008Req(data)
    print("150008 req")
    self:syncNetReq(AppEvent.NET_M15,AppEvent.NET_M15_C150008, {})
end


---------------------------------------------------------------------
-- 协议返回
---------------------------------------------------------------------
--     message  S2C{
--        required int32 rs=1;
--        optional int32 itemCount=2;//剩余探宝币数量
--        repeated LotteryHistrory histories=3;//奖励历史记录20条
--     }
function LotteryProxy:onTriggerNet150000Resp(data)
    if data.rs == 0 then
        print("协议 150000 返回")
        -- self:sendNotification(AppEvent.PROXY_LOTTERY_INFOS_CHANGE,data)
        self:updateItemNum( data,4014 )
        self._historiesMap[1] = data.histories
        self:sendNotification(AppEvent.PROXY_HEROLOTTERY_UPDATE,{})
    end
end

function LotteryProxy:onTriggerNet150001Resp(data)
    if data.rs == 0 then
        print("协议 150001 返回")
        self:updateItemNum( data,4042 )
        self._historiesMap[2] = data.histories
        self:sendNotification(AppEvent.PROXY_HEROLOTTERY_UPDATE,{})
    end
end

--战将信息
function LotteryProxy:onTriggerNet150004Resp(data)
    print("150004 resp")
    if data.rs == 0 then
        self._lastIndex = 0
        self._heroGoldCount = rawget(data,"itemCount") or 0
        self._histories = rawget(data,"histories") or {}
        self:updateItemNum(data)
        self:updateHeroLotteryInfo( data )
        self:updateHeroRewardInfo( data )
        self:sendNotification(AppEvent.PROXY_HEROLOTTERY_UPDATE,{})
    end
end

--战将开宝箱
function LotteryProxy:onTriggerNet150005Resp(data)
    print("150005 resp")
    if data.rs == 0 then
        self._heroRewards = {}
        self._heroGoldCount = rawget(data,"itemCount") or 0
        self:updateItemNum(data)
        self:updateHeroLotteryInfo( data )
        self:sendNotification(AppEvent.PROXY_HEROLOTTERY_UPDATE,{})
    end
end

--战将探宝刷新奖励
function LotteryProxy:onTriggerNet150006Resp(data)
    print("150006 resp")
    if data.rs == 0 then
        self._heroGoldCount = rawget(data,"itemCount") or 0
        self:updateItemNum(data)
        self:updateHeroLotteryInfo( data )
        self:sendNotification(AppEvent.PROXY_HEROLOTTERY_UPDATE,{})
    end
end


--战将探宝抽取奖励
function LotteryProxy:onTriggerNet150007Resp(data)
    print("150007 resp")
    if data.rs == 0 then
        self._heroGoldCount = rawget(data,"itemCount") or 0
        self:updateItemNum(data)
        self:updateHeroLotteryInfo( data )
        self:updateHeroRewardInfo( data )
        self:sendNotification(AppEvent.PROXY_HEROLOTTERY_UPDATE,{})
    end
end

--战将探关闭探宝
function LotteryProxy:onTriggerNet150008Resp(data)
    print("150008 resp",data.rs)
    if data.rs == 0 then
        print("战将探关闭探宝 lasttime,status=",data.info.lasttime,data.info.status)
        self:updateHeroLotteryInfo( data )
        self:sendNotification(AppEvent.PROXY_HEROLOTTERY_UPDATE,{})
    end
end

---------------------------------------------------------------------
-- 数据处理
---------------------------------------------------------------------
-- 更新战将信息
function LotteryProxy:updateHeroLotteryInfo( data )
    -- body
    local infos = rawget(data,"info")
    if infos ~= nil then
        print("更新战将信息.... lasttime,opentimes,status = ",infos.lasttime,infos.opentimes,infos.status)

        if infos.status == 0 then
            -- 宝箱关闭状态
            infos.lasttime = 0
            infos.lotterytimes = 0
            infos.refreshtimes = 0
        end

        -- self._candidates = self:randomPreviewRewards( infos.candidates )

        self._HeroLotteryInfo = infos
        self:setHeroRemainTime(infos.lasttime)

    end

end

-- 更新已抽取奖励
function LotteryProxy:updateHeroRewardInfo( data )
    for k,index in pairs(self._HeroLotteryInfo.indexes) do
        index = index + 1
        self._heroRewards[index] = self._HeroLotteryInfo.rewards[k]
    end

    for index,reward in pairs(self._heroRewards) do
        self._HeroLotteryInfo.candidates[index] = reward
            print("已抽到 index,power,typeid = ", index,reward.power,reward.typeid)
    end

    -- print("抽到奖励更新 _lastIndex",self._lastIndex)
end

function LotteryProxy:updateItemNum( data,itemID )
    -- body
    itemID = itemID or 4043 --战宝币4043,神宝币4042,奇宝币4014
    local number = rawget(data,"itemCount")
    if number == type(0) then
        local proxy = self:getProxy(GameProxys.Item)
        proxy:setItemNumByType(itemID, number)  
    end
end

function LotteryProxy:setLastIndex(index)
    -- body 最近一次抽奖的下标
    self._lastIndex = index
end

function LotteryProxy:getLastIndex()
    -- body 最近一次抽奖的下标
    return self._lastIndex
end


function LotteryProxy:setLotteryInfos(equipLotterInfos)
    self._lastRefreshTime = os.time()
    self._lotteryInfos = equipLotterInfos

    for key,v in pairs(equipLotterInfos) do
        if v.freeTimes <= 0 then
            self:pushRemainTime("Lottery_infos"..v.type,v.time)
        else
            self:pushRemainTime("Lottery_infos"..v.type,0)
        end
    end
    self:updateRedPoint()
end

--小红点更新
function LotteryProxy:updateRedPoint()
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:checkFreeFindBoxRedPoint() 
    redPointProxy:lotteryEquipRedPoint()
end


-- 预览奖励做随机排序
function LotteryProxy:randomPreviewRewards( rewards )
    -- body
    local randomRewards = {}
    local size = table.size(rewards)
    if size > 0 then
        math.randomseed(os.time())

        for k,v in pairs(rewards) do
            v.isDone = false
        end

        while table.size(randomRewards) < size do
            local randomIndex = math.random(size)
            -- print("随机下标 randomIndex=",randomIndex)
            local reward = rewards[randomIndex]
            if reward.isDone == false then
                reward.isDone = true
                table.insert(randomRewards,reward)
            end
        end
    end

    return randomRewards
end

---------------------------------------------------------------------
-- 对外接口
---------------------------------------------------------------------
function LotteryProxy:setHeroRemainTime( remainTime )
    print("战将探宝剩余时间 LotteryProxy:setHeroRemainTime( remainTime )", remainTime)
    -- body 战将探宝剩余时间
    -- self:pushRemainTime(self.HERO_KEY, remainTime, AppEvent.NET_M15_C150004, nil, self.onTriggerNet150004Req)
    self:setHeroRemainTimeCopy(remainTime)
    self:pushRemainTime(self.HERO_KEY, remainTime, AppEvent.NET_M15_C150004, nil, self.onRemainTimeCallBack)
end

function LotteryProxy:onRemainTimeCallBack(data)
    self:setHeroRemainTimeCopy(0)
    self:onTriggerNet150004Req(data)
end


function LotteryProxy:getHeroRemainTime()
    local remainTime = self:getRemainTime(self.HERO_KEY)
    return remainTime
end

function LotteryProxy:setHeroRemainTimeCopy(time)
    self._remainTimeCopy = time
end

function LotteryProxy:getHeroRemainTimeCopy()
    return self._remainTimeCopy
end

function LotteryProxy:getHeroLotteryInfo(  )
    -- body 战将信息
    return self._HeroLotteryInfo
end

function LotteryProxy:getRandomCandidates(  )
    -- body 随机后的奖励信息
    return self._candidates
end

function LotteryProxy:getHeroRewards(  )
    -- body 战将探宝的奖励信息
    return self._heroRewards
end

function LotteryProxy:getHeroGoldCount(  )
    -- body 战将探宝币数量
    return self._heroGoldCount
end

function LotteryProxy:getHistories(  )
    -- body 最近20条玩家探宝信息
    return self._histories
end

function LotteryProxy:getHistoriesMap(index)
    -- body 奇兵index=1/神兵index=2,最近20条玩家探宝信息
    return self._historiesMap[index]
end


-- 获取普通与高级探宝免费次数的数据表
function LotteryProxy:getTanbaoFreeData()
    return self._tanbaoFreeData
end

--获得抽奖数据
function LotteryProxy:getNetInfos()
    return self._lotteryInfos
end

-- 拥有的奇兵币
function LotteryProxy:getNorCoinCount()
    local itemProxy = self:getProxy(GameProxys.Item)
    local haveCount01 = itemProxy:getItemNumByType(4014)
    return haveCount01
end
-- 拥有的神兵币
function LotteryProxy:getSpeCoinCount()
    local itemProxy = self:getProxy(GameProxys.Item)
    local haveCount02 = itemProxy:getItemNumByType(4042)
    return haveCount02
end
-- 奇兵币和神兵币的总数
function LotteryProxy:getNorSpeCoinCount()
    local count = self:getNorCoinCount() + self:getSpeCoinCount()
    return count
end
--设置探宝免费次数norTimes（普通）,spcTimes（高级）
function LotteryProxy:setTanbaoFreeData(norTimes,spcTimes)
    local freeData = {}
    freeData[1] = {times = norTimes, type = 1}
    freeData[2] = {times = spcTimes, type = 2}
    self._tanbaoFreeData = freeData
    self:updateRedPoint()
end

function LotteryProxy:getIsFree()
    local freeTaobao = self:getTanbaoFreeData()
    for k,v in pairs(freeTaobao) do
        if v.times > 0 then
            return true
        end
    end
    return false
end

function LotteryProxy:onGetUpdateTimeInfos(index)
    local temp = clone(self._lotteryInfos)

    local function call( type)
        for _,v in pairs(temp) do
            if type == v.type then
                return v
            end
        end
    end

    for i = 1,3 do
        local remainTime = self:getRemainTime("Lottery_infos"..i)
        local info = call(i)
        info.time = remainTime
    end
    if index == nil then
        return temp
    else
        return call(index)
    end
    self:updateRedPoint()
end

-- 判定战将探宝是否已开放，未开放则飘字提示
function LotteryProxy:isUnlockLotteryByID(id,isShowMsg)
    if id == nil then
        return false
    end

    local info = ConfigDataManager:getConfigById("NewFunctionOpenConfig", id)

    if info.type == 1 then  --type = 1 判定主公等级
        local unLockLevel = info.need
        local roleProxy = self:getProxy(GameProxys.Role)
        local currentLv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)

        if currentLv < unLockLevel then
            if isShowMsg then
                self:showSysMessage(string.format(TextWords:getTextWord(340000),info.need,info.name))
            end
            return false
        end
        return true
    else
        return false
    end

end

-- 判定奇兵探宝是否已开放，未开放则飘字提示
function LotteryProxy:isUnlockNorLottery(isShowMsg)
    return self:isUnlockLotteryByID(5,isShowMsg)
end

-- 判定神兵探宝是否已开放，未开放则飘字提示
function LotteryProxy:isUnlockSpeLottery(isShowMsg)
    return self:isUnlockLotteryByID(9,isShowMsg)
end

-- 判定战将探宝是否已开放，未开放则飘字提示
function LotteryProxy:isUnlockHeroLottery(isShowMsg)
    return self:isUnlockLotteryByID(11,isShowMsg)
end
--购买探宝币
function LotteryProxy:onTriggerNet150003Resp(data)
    if data.rs >= 0 then
        self.openData = data
        self:updateItemNumByType(data.type,data.tanbaoNum)
        self:sendNotification(AppEvent.PROXY_LOTTERY_BUY_UPDATE,data)
    end
end
--探宝
function LotteryProxy:onTriggerNet150002Resp(data)
    if data.rs >= 0 then
        --self.openData = data
        self:updateItemNumByType(data.type,data.tanbaoNum)
        --单抽
        if #data.getid == 1 then
            data.getid = data.getid[1]
            self._view:onRewardRespHandle(data)
        end
        --全抽
        if #data.getid == 9 then
            self._view:onTenRewardRespHandle(data)
        end
    end
end
--更新探宝币数量
function LotteryProxy:updateItemNumByType(dataType,dataTanbaoNum)
    local itemID
    if dataType == 1 then --普通
        itemID = 4014  --奇宝币
    elseif dataType == 2 then --高级
        itemID = 4042  ----神宝币
    end
    if itemID then
        local proxy = self:getProxy(GameProxys.Item)
        proxy:setItemNumByType(itemID, dataTanbaoNum)
    end
end
--打开探宝模块时候调用
function LotteryProxy:setOpenData()
    local data = {}
    data.rs = 0
    data.type = 3
    local itemProxy = self:getProxy(GameProxys.Item)
    data.tanbaoNum = itemProxy:getItemNumByType(4014)
    data.taobaos = self:getTanbaoFreeData()
    self.openData = data
end
function LotteryProxy:getOpenData()
    return self.openData
end


]]