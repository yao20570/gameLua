-- /**
--  * @Author:    fzw
--  * @DateTime:    2016-04-07 21:15:46
--  * @Description: 活动数据代理
--  */

ActivityProxy = class("ActivityProxy", BasicProxy)

local allModule = {
    [ActivityDefine.LIMIT_ACTION_LABA_ID] = ModuleName.PullBarActivityModule, --拉霸--------
    [ActivityDefine.LIMIT_ACTION_LEGIONSHARE_ID] = ModuleName.ChargeShareModule,     --有福同享-----
    [ActivityDefine.LIMIT_ACTION_GIFTGOLD_ID] = ModuleName.RedPacketModule,
    [ActivityDefine.LIMIT_ACTION_VIPBOX_ID] = ModuleName.VipBoxModule,           --vip宝箱
    [ActivityDefine.LIMIT_ACTION_ORDNANCEFORGING_ID] = ModuleName.PartsGodModule,         --军械神将-------
    [ActivityDefine.ACTIVITY_CONDITION_VIP_GO_TYPE] = ModuleName.VipRebateModule,        --vip总动员
    [ActivityDefine.LIMIT_ACTION_ERERYDAY_ZHUANPAN_ID] = ModuleName.DayTurntableModule,         --每日转盘
    [ActivityDefine.LIMIT_ACTION_EMPEROR_AWARD_ID] = ModuleName.EmperorAwardModule,         --皇帝封赏
    [ActivityDefine.LIMIT_JIANG_BING_ID] = ModuleName.GeneralAndSoldierModule,          --天降奇兵
    [ActivityDefine.LIMIT_SPRING_SQUIB_ID] = ModuleName.SpringSquibModule,          --春节活动爆竹酉礼
    [ActivityDefine.LIMIT_SMASHEGG_ID] = ModuleName.SmashEggModule,  --金鸡砸蛋
    [ActivityDefine.LIMIT_COLLECTBLESS_ID] = ModuleName.CollectBlessModule,  --迎春集福---------
    [ActivityDefine.LIMIT_ACTIVITY_SHOP_ID] = ModuleName.ActivityShopModule,  --洛阳闹市-------
    [ActivityDefine.LIMIT_MARTIALTEACH_ID] = ModuleName.MartialTeachModule,  --武学讲堂
    [ActivityDefine.LIMIT_COOKINGWINE_ID] = ModuleName.CookingWineModule,  --煮酒论英雄
    [ActivityDefine.LIMIT_DAYRECHARGE_ID] = ModuleName.DayRechargeModule,  --连续充值
    [ActivityDefine.LIMIT_BROADSEAL_ID] = ModuleName.BroadSealModule,  --国之重器
    [ActivityDefine.LIMIT_CONSORT_ID] = ModuleName.ConsortModule,  --礼贤下士
    [ActivityDefine.LIMIT_LIONTURNTABLE_ID] = ModuleName.LionTurntableModule,  --雄狮轮盘
    [ActivityDefine.LIMIT_JINGJUECITY_ID] = ModuleName.JingJueCityModule,  --精绝古城
    [ActivityDefine.LIMIT_RECHARGEREBATE_ID] = ModuleName.RechargeRebateModule,  --充值返利大放送
    [ActivityDefine.LIMIT_LEGIONRICH_ID] = ModuleName.LegionRichModule,  --同盟致富
    [ActivityDefine.LIMIT_LUCKTURNTABLE_ID] = ModuleName.LuckTurntableModule,  --幸运轮盘
    [ActivityDefine.LIMIT_CHANGELUCK_ID] = ModuleName.ChangeLuckModule,  --招财转运
    [ActivityDefine.LIMIT_RICH_POWERFUL_VILLAGE_ID] = ModuleName.RichPowerfulVillageModule,  --富贵豪庄
    [ActivityDefine.LIMIT_GETLOTOFMONEY_ID] = ModuleName.GetLotOfMoneyModule, --财源广进
    [ActivityDefine.LIMIT_CORNUCOPIA_ID] = ModuleName.CornucopiaModule,  --聚宝盆
}

function ActivityProxy:ctor()
    ActivityProxy.super.ctor(self)
    self.proxyName = GameProxys.Activity

    self._limitActivityInfo = {}
    self.allInfo = {}
    self.labaXinxi = {}
    self.rankInfo = {}
    self.moduleName = {}
    self._dayTurntableRedPoints = {}
    self.allTotal = {}
    self.pos = 1
    self.pkgKey = "legionShare"
    self._limitKey = "limitKey"
    self._actKey = "activity"
    -- self.time = {10*60, 15*60, 30*60, 60*60, 90*60}
    self.lastTime = 0
    self.firstSend = true
    self.chatName = ""
    self.allLaBaEffectid = {}
    -- self.time = {60, 90, 120, 150, 200}
    self._partsGodInfos = {} --军械神将

    self.spendTimes = 0  --金鸡砸蛋
    self.remainTimes = 0
    self.squibInfos = {} --爆竹数据
    self.martialInfos = {} --武学讲堂数据
    self.dayRechargeInfos = {} --连续充值数据
    self.cookInfos = {} --煮酒论英雄数据
    self.broadSealInfos = {} --国之重器信息
    self.lionTurntableInfos = {} --雄狮轮盘信息
    self.jingJueInfos = {} --精绝古城信息
    self.rechargeRebateInfos = {} --返利大放送信息
    self.legionRichInfos = {} --同盟致富信息
    self.legionRichGatherInfos = {} --同盟致富采集信息
    self.chargeCardOpenInfo = {} --周卡、月卡等开放信息
    self._rewardFlag = false

    self.__oldSpend = nil  --登陆时的今日累计消费。第二天后自动为0。  *不可随意修改
    self.__afterCharge = nil  --充值变化

    self.richPowerfulVillageInfo = {} --富贵豪庄信息
    self.getLotOfMoneyInfo = {} --财源广进信息
    self.cornucopiaInfos = {} --聚宝盆信息

    self._lastReqTime = os.time()
end

function ActivityProxy:resetAttr()
    self._allActivityInfo = {}
    self._activeIDTmp = {}
    self._labaActivityInfo = {}
    self.allTipsData = {}
    self._limitActivityInfo = {}
    self.redPkgInfo = {}
    self._partsGodInfos = {}
    self.labaXinxi = {}
    self.moduleName = {}
    self._dayTurntableRedPoints = {}
    self.allTotal = {}
    self._removeQueue:clear()
    self._frameQueue:clear()
    self._rewardFlag = false
end

function ActivityProxy:resetCountSyncData()

    self.__oldSpend = 0
    self.__afterCharge = 0

    --清0砸蛋次数
    self:resetEggTimes()
    
    for k,v in pairs(self.labaXinxi) do
        self.labaXinxi[k].free = 1
        local data = {}
        data.rs = 0
        data.labaInfo = self.labaXinxi[k]
        -- self:onTriggerNet230003Resp(data)

        if not self.labaXinxi then self.labaXinxi = {} end
        self.labaXinxi[data.labaInfo.id] = data.labaInfo
        self._labaActivityInfo = data.labaInfo
        self.LabaNum = data.labaInfo.free
        self:sendNotification(AppEvent.PROXY_LABA_INFO, false)
        -- self:updateLimitRedpoint()
    end
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:setPullBarRed()

    self._dayTurntableRedPoints = {}
    self:setPartsGodFree()
    self:updateTurnTable()

    for k,v in pairs(self._allActivityInfo) do
        if v.resettime == 1 then
           -- print("名字-====",v.name)
            self._allActivityInfo[k].already = 0
            local num = self:getTotalById(v.activityId)
            num = num or 200
            self._allActivityInfo[k].total = num
            if v.effectInfos then
                for key,value in pairs(self._allActivityInfo[k].effectInfos) do
                    if self._allActivityInfo[k].effectInfos[key].iscanget ~= 2 then
                        self._allActivityInfo[k].effectInfos[key].iscanget = 3
                    end
                    if value.limit then
                        self._allActivityInfo[k].effectInfos[key].limit = 0
                    end
                end
            end
            --大按钮重置的type未明
            -- if v.buttons then
            --     for key,value in pairs(self._allActivityInfo[k].buttons) do
            --         if self._allActivityInfo[k].buttons[key].type == 2 then
            --             self._allActivityInfo[k].buttons[key].type = 1
            --         end
            --     end
            -- end
        end
    end

    local eProxy = self:getProxy(GameProxys.EmperorAward)
    eProxy:resetData()

    local vProxy = self:getProxy(GameProxys.VipRebate)
    vProxy:resetData()

    local gProxy = self:getProxy(GameProxys.GeneralAndSoldier)
    gProxy:resetData()



    self:sendNotification(AppEvent.PROXY_ACTIVITY_INFO, self._allActivityInfo)
    self._proxy:setAllLimitActivity()

    --清空爆竹酉礼数据
    self:cleanClientSquibInfo()

    --充值武学讲堂免费次数
    self:resetMartialFreeTime()

    --重置煮酒英雄免费次数
    self:resetCookFreeTime()

    --重置国之重器免费次数
    self:resetBroadSealFreeTime()

    --重置雄狮轮盘免费次数
    self:resetLionTurnFreeTime()

    --重置精绝古城免费次数
    self:resetJingJueFreeTime()

    --周卡数据刷新
    self:resetWeekCard()

    --限时活动财源广进
    self:resetGetLotOfMoney()

    --连续充值数据刷新
    self:resetDayRecharge()

    --通知所有活动界面，0点刷新
    self:sendNotification( AppEvent.PROXY_UPDATE_ACTVIEW_TIMEOVER )

    --重新请求230055  更新数据 8115 同盟致富零点重置采集量时，没有将同盟成员详情列表的数据清除，需要该成员登录时才会去刷新
    local richinfos = self:getLegionRichInfos()
    if richinfos and richinfos[1] and richinfos[1].activityId then
        self:onTriggerNet230055Req({activityId = richinfos[1].activityId})
    end
    
end

function ActivityProxy:registerNetEvents()
    -- self:registerNetEvent(AppEvent.NET_M2, AppEvent.NET_M2_C20200, self, self.onUpdateTipsResp)--所有小红点缓存
    self:addEventListener(AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoRsp)
    self:addEventListener(AppEvent.PROXY_UPDATE_BUFF_NUM, self, self.updateRoleBagRsp)
end

function ActivityProxy:unregisterNetEvents()
    -- self:unregisterNetEvent(AppEvent.NET_M2, AppEvent.NET_M2_C20200, self, self.onUpdateTipsResp)--所有小红点缓存
    self:removeEventListener(AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.updateRoleInfoRsp)
    self:removeEventListener(AppEvent.PROXY_UPDATE_BUFF_NUM, self, self.updateRoleBagRsp)
end

function ActivityProxy:onTriggerNet230000Req(data) 
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230000, data) 
end

function ActivityProxy:onTriggerNet230001Req(data, id, flag, isBuy)
    self.curId = id
    self.isBig = flag
    self.isBuy = isBuy
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230001, data)
end

function ActivityProxy:onTriggerNet230002Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230002, data)
end

function ActivityProxy:onTriggerNet230003Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230003, data)
end

function ActivityProxy:onTriggerNet230005Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230005, data)
end

function ActivityProxy:onTriggerNet230006Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230006, data)
end

function ActivityProxy:onTriggerNet230008Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230008, data)
end

function ActivityProxy:onTriggerNet230009Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230009, data)
end

function ActivityProxy:onTriggerNet230010Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230010, data)
end

function ActivityProxy:onTriggerNet230011Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230011, data)
end

function ActivityProxy:onTriggerNet230015Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230015, data)
end

function ActivityProxy:onTriggerNet230016Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230016, data)
end

function ActivityProxy:onTriggerNet230018Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230018, data)
end

function ActivityProxy:onTriggerNet230022Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230022, data)
end

function ActivityProxy:onTriggerNet230030Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230030, data)
end
function ActivityProxy:onTriggerNet230031Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230031, data)
end

function ActivityProxy:onTriggerNet230036Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230036, data)
end
--连续充值================================
function ActivityProxy:onTriggerNet230037Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230037, data)
end
function ActivityProxy:onTriggerNet230038Req(data)
    -- print("onTriggerNet230038Req", data.activityId, data.getRewardId )
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230038, data)
end

-- 初始化活动数据
function ActivityProxy:initSyncData(data)
    ActivityProxy.super.initSyncData(self, data)
    self._frameQueue = FrameQueue.new(2)
    self._removeQueue = FrameQueue.new(1)
    self.allTotal = {}
    self._proxy = self:getProxy(GameProxys.RedPoint)
    self.onLineTime = data.actorInfo.totalOnlineTime
    local tempdata = {}
    tempdata.activitys = data.activitys
    tempdata.nextOpenId = data.actorInfo.nextOpenId
    tempdata.nextOpenTime = data.actorInfo.nextOpenTime
    table.sort(tempdata.activitys, function(a, b)
        return a.sort < b.sort
    end)
    tempdata.rs = 0
    self:onTriggerNet230000Resp(tempdata)
    local tempdata = {}
    tempdata.nextOpenId = data.actorInfo.nextLimtOpenId
    tempdata.nextOpenTime = data.actorInfo.nextLimtOpenTime
    tempdata.activitys = data.limitActivitys
    tempdata.rs = 0
    self._delyData = tempdata
        
    self.redPkgInfo = {}
    self.turntableInfos = {}
    self:initActivityDetailData(data)

     -- 周卡、月卡
    self:setChargeCardOpenInfo(data.chargeCardOpenInfo)
end

-- 初始化活动的详细数据
function ActivityProxy:initActivityDetailData(data)
    -- 派送大礼包
    if #data.redBagInfo > 0 then
        logger:info("================>派送大礼包")
        self.redPkgInfo = data.redBagInfo
    end

    -- 每日转盘信息     
    if #data.turntableInfos > 0 then
        logger:info("================>每日轮盘")
        self.turntableInfos = data.turntableInfos
    end

    -- 金鸡砸蛋数据
    if #data.smashEggInfos > 0 then
        logger:info("================>金鸡砸蛋数据")
        self:onUpdateSmashEgg(data)
    end

    -- 春节活动爆竹信息
    if #data.squibInfos > 0 then
        logger:info("================>春节活动爆竹信息")
        self:setSquibInfos(data.squibInfos)
    end

    -- 武学讲坛学习信息
    if #data.martialInfos > 0 then
        logger:info("================>武学讲坛学习信息")
        self:setMartialInfos(data.martialInfos)
    end

    -- 煮酒论英雄信息
    if #data.cookInfos > 0 then
        logger:info("================>煮酒论英雄信息")
        self:setCookInfos(data.cookInfos)
    end

    -- 连续充值信息
    if #data.continuousRechargeInfo > 0 then
        logger:info("================>连续充值信息")
        self:setDayRechargeInfos(data.continuousRechargeInfo[1])
    end

    -- 国之重器信息
    if #data.broadSealInfs > 0 then
        logger:info("================>国之重器信息")
        self:setBroadSealInfos(data.broadSealInfs)
    end

    -- 雄狮轮盘信息
    if #data.leoneInfo > 0 then
        logger:info("================>雄狮轮盘信息")
        self:setLionTurntableInfos(data.leoneInfo)
    end

    -- 精绝古城信息
    if #data.tombInfos > 0 then
        logger:info("================>精绝古城信息")
        self:setJingJueInfos(data.tombInfos)
    end

    -- 返利大放送信息
    if #data.rechargeInfos > 0 then
        logger:info("================>返利大放送信息")
        self:setRechargeRebateInfos(data.rechargeInfos)
    end

    -- 同盟致富信息
    if #data.legionRichInfos > 0 then
        logger:info("================>同盟致富信息")
        self:setLegionRichInfos(data.legionRichInfos)
    end    

    -- 富贵豪庄
    if #data.richManorInfos > 0 then
        logger:info("================>富贵豪庄")
        self:setRichPowerVillageInfos(data.richManorInfos)
    end

    --财源广进
    if #data.bullionInfos > 0 then
        logger:info("================>财源广进")
        self:setGetLotOfMoneyInfos(data.bullionInfos)
    end

    --聚宝盆
    if #data.cornucopiaInfos > 0 then
        logger:info("================>聚宝盆")
        self:setCornucopiaInfos(data.cornucopiaInfos)
    end 
end

function ActivityProxy:afterInitSyncData()
    local roleProxy = self:getProxy(GameProxys.Role)
    self.vipLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel)
    self.allSpend = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_all_spend_coin)
    self.__oldSpend = self.__oldSpend or roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_all_spend_coin)  --登陆时的今日累计消费。第二天后自动为0。  *不可随意修改

    self:onTriggerNet230002Resp(self._delyData)

end

--活动是否显示(活动所有的奖励领取完后，服务端下发的活动列表不会下该活动，)
function ActivityProxy:isActivityHide(activityData)
    local isHide = true
    if activityData ~= nil then
        if activityData.effectInfos ~= nil then -- 添加判空处理
            for k, v in pairs(activityData.effectInfos) do
                if v.iscanget ~= 4 then
                    isHide = false
                    break
                end
            end
        else
            -- TODO：兑换礼包返回 false
            if activityData.activityId == 99999 then
                isHide = false
            end
        end
    end
    return isHide
end

--根据活动id返回单个活动信息,
function ActivityProxy:getDataById(id)
    if type(self._allActivityInfo) ~= "table" then
        return false
    end
    for k, v in pairs(self._allActivityInfo) do
        if v.activityId == id then
            return true, v, id
        end
    end
    return false
end

--根据活动条件，获取单个活动信息
function ActivityProxy:getDataByCondition(condition)
    if type(self._allActivityInfo)~="table" then
        return false
    end
    for k,v in pairs(self._allActivityInfo) do
        if v.conditiontype == condition then
            return true, v, v.activityId
        end
    end
    return false
end

--根据活动name返回单个活动信息,
function ActivityProxy:getDataByName(name)
    if type(self._allActivityInfo)~="table" then
        return false
    end
    for k,v in pairs(self._allActivityInfo) do
        if v.name == name then
            return  v
        end
    end
    return false
end

function ActivityProxy:getTurnTableInfo(id)
    local roleProxy = self:getProxy(GameProxys.Role)
    local allSpend = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_all_spend_coin)
    for k,v in pairs(self.turntableInfos) do
        v.spend = allSpend
        if v.id == id then
            return self.turntableInfos[k]
        end
    end
end

function ActivityProxy:getCurActivityData()
    return self.curActivityData
end

function ActivityProxy:setCurGetId(id)
    self.curId = id
end

--在线礼包倒计时
function ActivityProxy:updateOnlineTime()

    for k,v in pairs(self.time) do
        local scheduKey = "onlineTime" .. k
        for key,value in pairs(v) do
            if value - self.onLineTime > 0 then
                self:pushRemainTime(scheduKey..key, value - self.onLineTime, 230012, k..key, function(this, param)
                    self._remainTimeMap["onlineTime"..param[1]] = nil
                    self:onTriggerNet230012Req({})
                end)
            end
        end
    end

    for k,v in pairs(self.otherTime) do
        local scheduKey = "otherOnlineTime" .. k
        for _,value in pairs(v) do
            if value > 0 then
                self:pushRemainTime(scheduKey, value, 230036, k, function(this, param)
                    self._remainTimeMap["otherOnlineTime"..param[1]] = nil
                    self:onTriggerNet230036Req({activityId = param[1]})
                end)
            end
        end
    end
end

function ActivityProxy:onTriggerNet230012Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230012, data)
end

--请求修改在线礼包的领取状态。。不可领---->可领取（倒计时后请求）
function ActivityProxy:onTriggerNet230012Resp(data)
    if data.rs == 0 then
        self.onLineTime = data.totalOnlineTime
        local curTime = data.totalOnlineTime
        for _,activity in pairs(self._allActivityInfo) do
            if activity.effectInfos then
                for k,v in pairs(activity.effectInfos) do
                    if v.conditiontype == 102 and curTime >= v.condition2 and v.iscanget == 3 then
                        self._allActivityInfo[_].effectInfos[k].iscanget = 1
                    end
                end
            end
        end
        self:sendNotification(AppEvent.PROXY_ACTIVITY_INFO, self._allActivityInfo)
        self._proxy:checkActivityRedPoint()
        self._proxy:checkArmyBigRewardRedPoint()
    else
        self:updateOnlineTime()
    end
end

function ActivityProxy:getPkgInfoByEffectId(id)
    for k,v in pairs(self.redPkgInfo) do
        if v.id == id then
            return self.redPkgInfo[k]
        end
    end
end

function ActivityProxy:getTotalById(id)
    local rs = {}
    if not self.allTotal[id] then
        return nil
    end
    for k,v in pairs(self.allTotal[id]) do
        table.insert(rs, v.totalLimit)
    end
    table.sort( rs, function(a, b)
        return a < b
    end )
    return rs[1]
end

-- 活动列表
function ActivityProxy:onTriggerNet230000Resp(data)
    if data.rs == 0 then
        if self._removeQueue then
            self._removeQueue:finalize()
            self._removeQueue = nil
            self._removeQueue = FrameQueue.new(1)
        end

        self.time = {}--在线礼包的倒计时  conditiontype = 102
        self.otherTime = {}  --军团募集类型活动的倒计时  conditiontype = 129
        self._allActivityInfo = data.activitys
        local activitys = self._allActivityInfo

       


        for i=1,#activitys do
            self:checkRemove(activitys[i], self:getScheduKey(self._actKey, activitys[i].activityId), true)
            local v = activitys[i]

            local isHide = self:isActivityHide(v)
            rawset(v, "isHide", isHide)

            if v.effectInfos then
                self.allTotal[v.activityId] = v.effectInfos
                self.time[v.activityId] = self.time[v.activityId] or {}
                self.otherTime[v.activityId] = self.otherTime[v.activityId] or {}
                for k,value in pairs(v.effectInfos) do
                    if value.conditiontype == 102 then
                        table.insert(self.time[v.activityId], value.condition2)
                    elseif value.conditiontype == 129 then
                        table.insert(self.otherTime[v.activityId], value.condition2 - value.condition1)
                    end
                end
            end
        end
        self:updateOnlineTime()
        self:updateLegionGiftData()
        
        self:checkOpen(data, self._actKey, AppEvent.NET_M23_C230010)

    end
end

function ActivityProxy:onTriggerNet230018Resp(data)
    if data.rs == 0 then
        local param = {}
        param.rbrInfo = data.rbrInfo
        param.name = self.chatName
        if data.getMoney then
            local effectId = data.bagid
            local config = ConfigDataManager:getConfigById(ConfigData.RedBagConfig, effectId)
            local redBagInfo = self:getPkgInfoByEffectId(effectId)
            if redBagInfo then
                redBagInfo.num = redBagInfo.num + data.getMoney
            end
        end
        if data.getMoney == 0 then
            local roleProxy = self:getProxy(GameProxys.Role)
            local myName = roleProxy:getRoleName()
            for k,v in pairs(data.rbrInfo) do
                if v.name == myName then
                    param.showNum = v.num
                    break
                end
            end
        else
            param.showNum = data.getMoney
        end

        self:sendNotification(AppEvent.PROXY_SHOW_REDPKGVIEW, param)
    end
end

--普通活动领取奖励，通过rs，客户端自己修改type或者iscanget或者limit(限购次数+1)
--@self.isBig  是不是大按钮
--@self.curId  当前领取奖励的活动id
--@self.isBuy  是不是限购
function ActivityProxy:onTriggerNet230001Resp(data)
    if data.rs == 0 then
        local flag, info, id = self:getDataById(data.activityId)
        if not flag then
            return
        end

        if self.isBig then
            if self.curId and info.buttons then
                if info.uitype == 2 then
                    info.buttons[self.curId] = nil
                else
                    info.buttons[self.curId].type = 3
                    info.buttons[self.curId].name = "已领取"
                    
                    
                end
            end
        else
            if self.curId and info.effectInfos then
                for k,v in pairs(info.effectInfos) do
                    if v.sort == self.curId then
                        if self.isBuy then
                            v.limit = v.limit + 1
                        else
                            v.iscanget = 4
                            local isHide = self:isActivityHide(info)
                            rawset(info, "isHide", isHide)
                        end
                    end
                end
                -- if self.isBuy then
                --     info.effectInfos[self.curId].limit = info.effectInfos[self.curId].limit + 1
                -- else
                --     info.effectInfos[self.curId].iscanget = 4
                -- end
                
                info.effectInfos[self.curId].effectId = data.effectId
            end
        end
        self._proxy:checkActivityRedPoint()
        self._proxy:checkArmyBigRewardRedPoint()
        table.sort( self._allActivityInfo, function(a,b) return a.sort < b.sort end )

        -- self:sendNotification(AppEvent.PROXY_ACTIVITY_INFO, self._allActivityInfo)
        self:sendNotification(AppEvent.PROXY_UPDATE_ONE, info)
        self:setRewardFlag(true)

        -- print("活动关闭类型===", info.endjudge)
        --根据活动的关闭类型判断是否需要请求关闭
        --[[
            endjudge:0:时间到消失,1:奖励全部领取完消失,2:活动时间到并且奖励全部领取完消失
        ]]
        if info.endjudge == 1 then
            local num = 0
            if info.buttons then
                for k,v in pairs(info.buttons) do
                    if v.type == 2 or v.type == 4 then
                        num = num + 1
                    end
                end
            end
            if info.effectInfos then
                for k,v in pairs(info.effectInfos) do                    
                    if v.iscanget >= 1 and v.iscanget <= 3 then
                        num = num + 1
                    end
                end
            end
            if num == 0 then
                local sendData = {}
                sendData.checkActivityIds = {id}
                self:onTriggerNet230008Req(sendData)
            end
        end
        if info.endjudge == 2 then
            local num = 0
            if info.buttons then
                for k,v in pairs(info.buttons) do
                    if v.type == 2 then
                        num = num + 1
                    end
                end
            end
            if info.effectInfos then
                for k,v in pairs(info.effectInfos) do
                    if v.iscanget == 3 then
                        num = num + 1
                    end
                end
            end
            if num == 0 then
                self:onTriggerNet230008Req({checkActivityIds = {info.activityId}})
            end
        end
        
    end
end

function ActivityProxy:setRewardFlag(flag)
    self._rewardFlag = flag
end

function ActivityProxy:getRewardFlag()
    return self._rewardFlag
end

--检测下一个活动开启倒计时
function ActivityProxy:checkOpen(data, key, cmdId)
    --print("显示活动===",data.nextOpenId,"===",data.nextOpenTime)
    if data.nextOpenId and data.nextOpenTime and data.nextOpenId > 0 and data.nextOpenTime > 0 then
        local time = data.nextOpenTime
        -- print("还有"..time)
        local key = self:getScheduKey(key, data.nextOpenId)
        self:pushRemainTime(key, time, cmdId, { cmdid = tostring(cmdId), id = data.nextOpenId }, function(this, param)
            for k, v in pairs(param) do
                -- 移除定时器
                --self:pushRemainTime(key, 0)
                local reqFun = self["onTriggerNet" .. v.cmdid .. "Req"]
                if reqFun and type(reqFun) == "function" then
                    reqFun(self, { checkActivityIds = v.id })
                end
            end
        end )
    end
end

-- 限时活动列表
function ActivityProxy:onTriggerNet230002Resp(data)
    if data.rs == 0 then
        self.allShareReward = { }
        if self._frameQueue then
            self._frameQueue:finalize()
            self._frameQueue = nil
            self._frameQueue = FrameQueue.new(2)
        end
        if #self._limitActivityInfo > 0 then
            self._limitActivityInfo = data.activitys
        else

            -- test:测试数据
           -- local consortActivity = { uitype=127, activityId=10058, info="招财转运", endTime=1499788800, bgIcon=34, isUpdate=false, effectId=1, lestime=109484, name="招财转运1", startTime=1499443200 }
           -- table.insert(self._limitActivityInfo, consortActivity)
           -- local consortActivity = { uitype=126, activityId=10059, info="财源广进", endTime=1499789800, bgIcon=34, isUpdate=false, effectId=1, lestime=109484, name="财源广进2", startTime=1499457200 }
           -- table.insert(self._limitActivityInfo, consortActivity)
            --

            for i = 1, #data.activitys do
--                logger:info("{ uitype=%s, activityId=%s, info=%s, endTime=%s, bgIcon=%s, isUpdate=%s, effectId=%s, lestime=%s, name=%s, startTime=%s }"
--                , data.activitys[i].uitype
--                , data.activitys[i].activityId
--                , data.activitys[i].info
--                , data.activitys[i].endTime
--                , data.activitys[i].bgIcon
--                , false
--                , data.activitys[i].effectId
--                , data.activitys[i].lestime
--                , data.activitys[i].name
--                , data.activitys[i].startTime
--                )
                table.insert(self._limitActivityInfo, data.activitys[i])
            end
        end

        self:sendNotification(AppEvent.PROXY_UPDATE_LIMIT, #data.activitys > 0)
        self:sendNotification(AppEvent.PROXY_NEW_ACT)

        for i = 1, #data.activitys do
            self:checkRemove(data.activitys[i], self:getScheduKey(self._limitKey, data.activitys[i].activityId), true)
            local uitype = data.activitys[i].uitype
            if uitype == ActivityDefine.LIMIT_ACTION_LABA_ID then
                -- 拉霸唯一判定 活动ID
                self.allLaBaEffectid[data.activitys[i].effectId] = { activityId = data.activitys[i].activityId, type = 0 }

            elseif uitype == ActivityDefine.ACTIVITY_CONDITION_VIP_GO_TYPE then
                --
                local proxy = self:getProxy(GameProxys.VipRebate)
                proxy:set230002Data(data.activitys[i])

            elseif uitype == ActivityDefine.LIMIT_ACTION_VIPBOX_ID then
                -- vip特权宝箱
                local proxy = self:getProxy(GameProxys.VIPBox)
                -- proxy:set230002Data(data.activitys[i])

            elseif uitype == ActivityDefine.LIMIT_ACTION_LEGIONSHARE_ID then
                -- 有福同享
                self.closeTime = data.activitys[i].endTime
                self.pos = 1
                self.allInfo = { }
                self:onTriggerNet230005Req( { })

            elseif uitype == ActivityDefine.LIMIT_ACTION_ORDNANCEFORGING_ID then
                -- 军械神将
                self._partsGodInfos = data.activitys[i]
                local redPointProxy = self:getProxy(GameProxys.RedPoint)
                redPointProxy:setPartsGodRed()

            elseif uitype == ActivityDefine.LIMIT_ACTION_ERERYDAY_ZHUANPAN_ID then
                -- 每日轮盘
                self:getZPCount(data.activitys[i].activityId)
                -- self:updateLimitRedpoint()
                local redPointProxy = self:getProxy(GameProxys.RedPoint)
                redPointProxy:setDayTrunRed()

            elseif uitype == ActivityDefine.LIMIT_SMASHEGG_ID then
                -- 砸蛋
                self._proxy:setSmashEggRed()

            elseif uitype == ActivityDefine.LIMIT_COLLECTBLESS_ID then
                -- 迎春集福
                self._proxy:setCollectBlessRed()

            elseif uitype == ActivityDefine.LIMIT_DAYRECHARGE_ID then
                -- 连续充值
                self._proxy:setDayRechargeNumberRed()

            elseif uitype == ActivityDefine.LIMIT_BROADSEAL_ID then
                -- 国之重器
                self._proxy:setBroadSealRed()

            elseif uitype == ActivityDefine.LIMIT_LIONTURNTABLE_ID then
                -- 雄狮轮盘
                self._proxy:setLionTurnRed()

            elseif uitype == ActivityDefine.LIMIT_LUCKTURNTABLE_ID then
                -- 幸运轮盘
                local luckTurntableProxy = self:getProxy(GameProxys.LuckTurntable)
                luckTurntableProxy:setRedPoint()

            elseif uitype == ActivityDefine.LIMIT_CHANGELUCK_ID then
                -- 招财转运
                local changeLuckProxy = self:getProxy(GameProxys.ChangeLuck)
                changeLuckProxy:setRedPoint()

            elseif uitype == ActivityDefine.LIMIT_JINGJUECITY_ID then
                -- 精绝古城
                self._proxy:setJingJueRed()

            elseif uitype == ActivityDefine.LIMIT_CONSORT_ID then
                -- 礼贤下士
                local consortProxy = self:getProxy(GameProxys.Consort)
                consortProxy:setRedPoint()

            elseif uitype == ActivityDefine.LIMIT_COOKINGWINE_ID then
                -- 煮酒论英雄
                self._proxy:setCookingRed()

            elseif uitype == ActivityDefine.LIMIT_MARTIALTEACH_ID then
                -- 武学讲堂
                self._proxy:setMartialRed()

            elseif uitype == ActivityDefine.LIMIT_RECHARGEREBATE_ID then
                -- 充值返利大放送
                self._proxy:setRechargeRebateRed()

            elseif uitype == ActivityDefine.LIMIT_LEGIONRICH_ID then
                -- 同盟致富
                self._proxy:setLegionRichRed()

            elseif uitype == ActivityDefine.LIMIT_SPRING_SQUIB_ID then
                -- 爆竹有礼
                self._proxy:setSpringSquibRed()
            elseif uitype == ActivityDefine.LIMIT_RICH_POWERFUL_VILLAGE_ID then
                --富贵豪庄
            elseif uitype == ActivityDefine.LIMIT_GETLOTOFMONEY_ID then 
                --财源广进
                self._proxy:setGetLotOfMoneyRed()
            elseif uitype == ActivityDefine.LIMIT_CORNUCOPIA_ID then 
                --聚宝盆小红点
                self._proxy:setCornucopiaRed()
            end
        end
        self:checkOpen(data, self._limitKey, AppEvent.NET_M23_C230011)
        for k, v in pairs(self.allLaBaEffectid) do
            self._frameQueue:pushParams(self.onTriggerNet230003Req, self, v)
        end
    end
end

--通用活动倒计时检测删除函数
function ActivityProxy:checkRemove(data, key, isState)
    if data.lestime and data.lestime > 0 and isState then
        local time = data.lestime
        self:pushRemainTime(key, time, data.activityId, data.activityId, function(this, param)
            self:pushRemainTime(key, 0)
            local sendData = { }
            sendData.checkActivityIds = param
            self._removeQueue:pushParams(self.onTriggerNet230008Req, self, sendData)
        end )
    end
end

-- 拉霸活动信息
function ActivityProxy:onTriggerNet230003Resp(data)
    -- body
    if data.rs == 0 then
        if not self.labaXinxi then self.labaXinxi = {} end
        self.labaXinxi[data.labaInfo.id] = data.labaInfo
        self._labaActivityInfo = data.labaInfo
        self.LabaNum = data.labaInfo.free
        self:sendNotification(AppEvent.PROXY_LABA_INFO, true)
        -- self:updateLimitRedpoint()
        local redPointProxy = self:getProxy(GameProxys.RedPoint)
        redPointProxy:setPullBarRed()
    else
       self:sendNotification(AppEvent.PROXY_LABA_INFO) 
    end
end

function ActivityProxy:getScheduKey(const, param)
    return const..param
end

function ActivityProxy:onTriggerNet230015Resp(data)
    if data.rs == 0 and data.redBagInfo then
        for k,v in pairs(self.redPkgInfo) do
            if v.id == data.redBagInfo.id then
                self.redPkgInfo[k] = data.redBagInfo
                return
            end
        end
    end
end

function ActivityProxy:onTriggerNet230016Resp(data)
    if data.rs == 0 and self.curActivityData then
        local effectId = self.curActivityData.activityId
        local config = ConfigDataManager:getConfigById(ConfigData.RedBagConfig, self.curActivityData.effectId)
        local redBagInfo = self:getPkgInfoByEffectId(effectId)
        if redBagInfo then
            redBagInfo.num = redBagInfo.num - config.price*config.discount*0.01
            redBagInfo.num = redBagInfo.num > 0 and redBagInfo.num or 0
        end
        self:sendNotification(AppEvent.PROXY_UPDATE_ACTVIEW, self.curActivityData)
    end
end

--获取有福同享礼包列表，倒计时
function ActivityProxy:onTriggerNet230005Resp(data)
    if data.rs == 0 then
        for k,v in pairs(data.legionShareInfo) do
            v.pos = self.pos
            v.time = os.time()
            self:pushRemainTime(self:getScheduKey(self.pkgKey, v.pos), v.timeLeft, 230008, v.pos, function(this, param)
                self._remainTimeMap[self:getScheduKey(self.pkgKey, v.pos)] = nil
                for k,v in pairs(param) do
                    self:removeInfo(v)
                    local num = 0
                    if self.LabaNum then
                        num = #self.allInfo + self.LabaNum
                    else
                        num = #self.allInfo
                    end
                    self:sendNotification(AppEvent.PROXY_UPDATE_COUNT, num)
                    self:sendNotification(AppEvent.PROXY_PKG_INFO, self.allInfo)
                    if #self.allInfo == 0 then
                        local data = {}
                        data.checkActivityIds = {}
                        data.checkActivityIds[1] = 18
                        self:onTriggerNet230008Req(data)
                    end
                end
            end)
            table.insert(self.allInfo, v)
            self.pos = self.pos + 1
        end
        self:sendNotification(AppEvent.PROXY_PKG_INFO, self.allInfo)
        self:updateLimitRedpoint()
    end
end

function ActivityProxy:onTriggerNet230006Resp(data)
    self:sendNotification(AppEvent.PROXY_GET_REWARD, data)
    -- self:updateLimitRedpoint()
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:setChargeShareRed()
end

--检测一个普通活动是否开启
function ActivityProxy:onTriggerNet230010Resp(data)
    if data.rs == 1 then

        local useData = { }
        for k, v in pairs(self._allActivityInfo) do
            useData[v.activityId] = v
        end


        for k, v in pairs(data.activityInfo) do
            useData[v.activityId] = v
            self.allTotal[v.activityId] = v.effectInfos

            -- 移除请求230010协议的定时器
            local key = self:getScheduKey(self._actKey, v.activityId)
            self:pushRemainTime(key, 0)
        end

        self._allActivityInfo = TableUtils:map2list(useData)

        table.sort(self._allActivityInfo, function(a, b) return a.sort < b.sort end )

        self._proxy:checkActivityRedPoint()
        self._proxy:checkArmyBigRewardRedPoint()
        self:sendNotification(AppEvent.PROXY_ACTIVITY_INFO, self._allActivityInfo)
        self:checkOpen(data, self._actKey, AppEvent.NET_M23_C230010)
    end
end

--检测一个限时活动是否开启
function ActivityProxy:onTriggerNet230011Resp(data)
    if data.rs == 1 then

        local param = {}
        param.rs = 0
        param.nextOpenId = data.nextOpenId
        param.nextOpenTime = data.nextOpenTime
        param.activitys = { }
        
        -- 已开启的活动
        for k, v in pairs(self._limitActivityInfo) do
            table.insert(param.activitys, v)
        end

        -- 新开启的活动
        for k, v in pairs(data.activityInfo) do
            table.insert(param.activitys, v)   
            
            -- 移除请求230011协议的定时器
            local key = self:getScheduKey(self._limitKey, v.activityId)
            self:pushRemainTime(key, 0)
        end

        -- 初始化新增活动的数据
        self:initActivityDetailData(data)

        self:onTriggerNet230002Resp(param)
    end
end

--服务端推新的活动数据，替换数据，刷新单个活动面板
function ActivityProxy:onTriggerNet230007Resp(data)
    if self._allActivityInfo == nil then
        return
    end
    for i=1,#data.activityInfo do
        local isFind = false
        for k,v in pairs(self._allActivityInfo) do
            if data.activityInfo[i].activityId == v.activityId then
                isFind = k
                break
            end
        end
        if isFind then
            logger:error("230007刷新活动名称 %s", self._allActivityInfo[isFind].name)
            if data.activityInfo[i].buttons then
                for k,v in pairs(data.activityInfo[i].buttons) do
                    self._allActivityInfo[isFind].buttons[k].type = v.type
                    if v.type == 1 then
                        self._allActivityInfo[isFind].buttons[k].name = "立刻前往"
                    elseif v.type == 2 then
                        self._allActivityInfo[isFind].buttons[k].name = "立刻领取"
                    elseif v.type == 3 then
                        self._allActivityInfo[isFind].buttons[k].name = "已领取"
                    else
                        self._allActivityInfo[isFind].buttons[k].name = "立刻购买"
                    end
                end
            end
            if data.activityInfo[i].effectInfos then
                for k,v in pairs(data.activityInfo[i].effectInfos) do
                    self._allActivityInfo[isFind].effectInfos[v.sort].iscanget = v.iscanget
                    self._allActivityInfo[isFind].effectInfos[v.sort].rewardState = v.rewardState
                end
            end
            if data.activityInfo[i].already then
                self._allActivityInfo[isFind].already = data.activityInfo[i].already
            end
            if data.activityInfo[i].total then
                self._allActivityInfo[isFind].total = data.activityInfo[i].total
            end
        end
    end
    -- print("刷新小红点数量")
    self._proxy:checkActivityRedPoint()
    self._proxy:checkArmyBigRewardRedPoint()
    table.sort(self._allActivityInfo, function(a, b)
        return a.sort < b.sort
    end)
    --遍历到有奖励的活动直接return并刷新单个活动
    for i=1,#self._allActivityInfo do
        if self._allActivityInfo[i].effectInfos then
            for j=1,#self._allActivityInfo[i].effectInfos do 
                if self._allActivityInfo[i].effectInfos[j].iscanget == 1 then
                    self:sendNotification(AppEvent.PROXY_UPDATE_ONE, self._allActivityInfo[i])
                    self:sendNotification(AppEvent.PROXY_ACTIVITY_INFO, self._allActivityInfo)
                    return
                end
            end
        end

        if self._allActivityInfo[i].buttons then
            for j=1,#self._allActivityInfo[i].buttons do 
                if self._allActivityInfo[i].buttons[j].type == 2 then
                    self:sendNotification(AppEvent.PROXY_UPDATE_ONE, self._allActivityInfo[i])
                    self:sendNotification(AppEvent.PROXY_ACTIVITY_INFO, self._allActivityInfo)
                    return
                end
            end
        end
    end
    --没找到有奖励的活动，默认刷新第一个活动
    self:sendNotification(AppEvent.PROXY_UPDATE_ONE, self._allActivityInfo[1])
    self:sendNotification(AppEvent.PROXY_ACTIVITY_INFO, self._allActivityInfo)
end

--活动数据删除了，叫界面刷新吧 
function ActivityProxy:onTriggerNet230008Resp(data)
    for k,v in pairs(data.activityIds) do
        if v ~= 0 then
            self:removeActivity(self._allActivityInfo, v)
            self:removeActivity(self._limitActivityInfo, v)
        end
    end
    self:sendNotification(AppEvent.PROXY_REMOVE_ACT, data.activityIds)
    self:closeAllActivity()

    table.sort(self._allActivityInfo, function(a, b)
        return a.sort < b.sort
    end)
    self:sendNotification(AppEvent.PROXY_ACTIVITY_INFO, self._allActivityInfo)
    self:sendNotification(AppEvent.PROXY_NEW_ACT)
    self._proxy:checkActivityRedPoint()
    self._proxy:checkArmyBigRewardRedPoint()
    self:updateLimitRedpoint()
    local isHas, legInfo = self:getDataByCondition(ActivityDefine.LEGION_JOIN_CONDITION) -- self:getDataById(15)
    self:sendNotification(AppEvent.PROXY_LEGION_GIFT, legInfo)
end

--通用删除活动函数
function ActivityProxy:removeActivity(param, id)
    local key
    for k,v in pairs(param) do
        if v.activityId == id then
            key = k
            break
        end
    end
    table.remove(param,key)
end

function ActivityProxy:onTriggerNet240000Req(data)
    self:syncNetReq(AppEvent.NET_M24, AppEvent.NET_M24_C240000, data)
end
------------------周卡start
--购买充值卡
function ActivityProxy:onTriggerNet490000Req(data)
    self:syncNetReq(AppEvent.NET_M49, AppEvent.NET_M49_C490000, data)
end
function ActivityProxy:onTriggerNet490000Resp(data)
    if data.rs == 0 then
        self:sendNotification(AppEvent.PROXY_ACTIVITY_CANBUY_WEEKCARD, data.id)
    end
end
--领取每日奖励
function ActivityProxy:onTriggerNet490001Req(data)
    self:syncNetReq(AppEvent.NET_M49, AppEvent.NET_M49_C490001, data)
end
function ActivityProxy:onTriggerNet490001Resp(data)
    if data.rs >= 0 then
        if self.chargeCardOpenInfo.chargeCardInfo ~= nil and  #self.chargeCardOpenInfo.chargeCardInfo > 0 then
            for index,cardInfo in ipairs(self.chargeCardOpenInfo.chargeCardInfo) do
                if self.chargeCardOpenInfo.id[index] == data.id then
                    self.chargeCardOpenInfo.chargeCardInfo[index].remainTimes = data.remainTimes
                    self.chargeCardOpenInfo.chargeCardInfo[index].isGet = 1 --已领取
                    self.weekCardState = 1

                end
            end
        end
        --把剩余次数为零的数据删除
        if self.chargeCardOpenInfo.chargeCardInfo ~= nil and  #self.chargeCardOpenInfo.chargeCardInfo > 0 then
            for index=#self.chargeCardOpenInfo.chargeCardInfo,1,-1 do
                if self.chargeCardOpenInfo.chargeCardInfo[index].remainTimes == 0 then
                    table.remove(self.chargeCardOpenInfo.chargeCardInfo,index)
                end
            end
        end
        self:sendNotification(AppEvent.PROXY_ACTIVITY_WEEKCARD_UPDATE)
        self._proxy:checkActivityRedPoint()
    end


end
--推送功能开放
function ActivityProxy:onTriggerNet490002Resp(data)
    self:setChargeCardOpenInfo(data.chargeCardOpenInfo)
    self:sendNotification(AppEvent.PROXY_ACTIVITY_WEEKCARD_UPDATE)
    self._proxy:checkActivityRedPoint()
end
function ActivityProxy:setChargeCardOpenInfo(chargeCardOpenInfo)

    self.chargeCardOpenInfo = chargeCardOpenInfo
    if self.chargeCardOpenInfo.chargeCardInfo ~= nil and #self.chargeCardOpenInfo.chargeCardInfo > 0 then
        for index,info in ipairs(self.chargeCardOpenInfo.chargeCardInfo) do
            local config = ConfigDataManager:getConfigById(ConfigData.ChargeCardConfig,info.id)
            if config.cardType == 1 then
                self.weekCardState = self.chargeCardOpenInfo.chargeCardInfo[index].isGet
                break
            end
        end
    end
end
function ActivityProxy:getWeekCardState()
   return self.weekCardState or -1
end
function ActivityProxy:getChargeCardOpenInfo()
   return self.chargeCardOpenInfo or {}
end
--获取周卡领取信息
function ActivityProxy:getWeekCardInfo()
    if  self.chargeCardOpenInfo ~= nil and  self.chargeCardOpenInfo.chargeCardInfo ~= nil and #self.chargeCardOpenInfo.chargeCardInfo > 0 then
        for index,info in ipairs(self.chargeCardOpenInfo.chargeCardInfo) do
            local config = ConfigDataManager:getConfigById(ConfigData.ChargeCardConfig,info.id)
            if config.cardType == 1 then
                self.chargeCardOpenInfo.chargeCardInfo[index].dayReward = config.dayReward
                return self.chargeCardOpenInfo.chargeCardInfo[index]
            end
        end
    end
    return {id = -1 ,remainTimes = -1}
end
--获取开放的周卡ID与奖励
function ActivityProxy:getWeekCardOpenInfo()
    local openInfo = {id = -1 ,dayReward = {}}
    if self.chargeCardOpenInfo ~= nil and self.chargeCardOpenInfo.id ~= nil and #self.chargeCardOpenInfo.id > 0 then
        for index,val in ipairs(self.chargeCardOpenInfo.id) do
            local config = ConfigDataManager:getConfigById(ConfigData.ChargeCardConfig,val)
            if config.cardType == 1 then
                openInfo.dayReward = config.dayReward
                openInfo.id = val
                return openInfo
            end
        end
    end
    return openInfo
end
--零点重置
function ActivityProxy:resetWeekCard()
    if self.chargeCardOpenInfo.chargeCardInfo ~= nil and  #self.chargeCardOpenInfo.chargeCardInfo > 0 then
        for index,cardInfo in ipairs(self.chargeCardOpenInfo.chargeCardInfo) do
            self.chargeCardOpenInfo.chargeCardInfo[index].isGet = 0 --未领取
            self.weekCardState = 0
        end
    end
    self:sendNotification(AppEvent.PROXY_ACTIVITY_WEEKCARD_UPDATE)
    self._proxy:checkActivityRedPoint()
end

------------------周卡end
--间隔上次打开活动界面过去5分钟请求排行榜数据。前提是有排行榜活动
function ActivityProxy:onTriggerNet230013Req(data)
    if self._allActivityInfo == nil then
        return
    end
    local isSend = false
    for k,v in pairs(self._allActivityInfo) do
        if v.uitype == 5 then
            isSend = true
            break
        end
    end
    --TODO 第一次没有数据，会导致模块打开一半，再进行渲染
    local now = os.time()
    if isSend and now - self._lastReqTime >= 5 * 60   then --5分钟，才会去请求数据
        self._lastReqTime = now
        self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230013, data)
    else
        self:sendNotification(AppEvent.PROXY_ACTIVITY_INFO, self._allActivityInfo)
    end
    
end

function ActivityProxy:onTriggerNet230013Resp(data)
    if data.rs == 0 then
        local activityRankInfo = data.activityRankInfo
        for i=1,#activityRankInfo do
            local flag, info = self:getDataById(activityRankInfo[i].activityid)
            if flag then
                -- print("现在的排名===",activityRankInfo[i].rank)
                if activityRankInfo[i].rank ~= -1 then 
                    info.already = activityRankInfo[i].rank
                end
            end
        end
        self:sendNotification(AppEvent.PROXY_ACTIVITY_INFO, self._allActivityInfo)
    end
end

--新增1个限时活动
function ActivityProxy:onTriggerNet230009Resp(data)
    local id = data.activityInfo.activityId
    local isNew = false
    for k,v in pairs(self._limitActivityInfo) do
        if v.activityId == id then
            isNew = k
            break
        end
    end
    if isNew then
        self._limitActivityInfo[isNew] = data.activityInfo
    else
        table.insert(self._limitActivityInfo, data.activityInfo)
    end
    
    self:sendNotification(AppEvent.PROXY_UPDATE_LIMIT, true)
    self:sendNotification(AppEvent.PROXY_NEW_ACT)
end

function ActivityProxy:updateLegionGiftData()
    local flag, info, activeID = self:getDataByCondition(ActivityDefine.LEGION_JOIN_CONDITION) --self:getDataById(15)
    self:setLegionGiftIDTmp(activeID)
    self:sendNotification(AppEvent.PROXY_LEGION_GIFT, info)
end

-- 设置军团好礼活动id
function ActivityProxy:setLegionGiftID(data)
    -- body
    self._activeID = data
end

-- 设置军团好礼活动按钮状态
function ActivityProxy:setLegionGiftBtn(data)
    -- body
    self._LGiftBtn = data
end

-- 设置军团好礼活动id Tmp
function ActivityProxy:setLegionGiftIDTmp(data)
    -- body
    self._activeIDTmp = data
end

function ActivityProxy:closeAllActivity()
    local num = 0
    for k,v in pairs(self._limitActivityInfo) do
        num = num + 1
    end
    if num == 0 then
        self:sendNotification(AppEvent.PROXY_UPDATE_LIMIT, false)
    end
end

function ActivityProxy:onUpdateTipsResp(data)
    self.allTipsData = data
end


-----------------------------------------------------------
-- get function 外部调用接口

-- 获取活动列表
function ActivityProxy:getActivityInfo()
    -- body
    return self._allActivityInfo -- function GameActivityPanel:onShowHandler(extraMsg)中会加入兑换礼包
end

-- 获取军团好礼活动id
function ActivityProxy:getLegionGiftID()
    -- body
    return self._activeID
end

-- 获取军团好礼活动id Tmp
function ActivityProxy:getLegionGiftIDTmp()
    -- body
    return self._activeIDTmp
end

-- 获取军团好礼活动按钮状态
function ActivityProxy:getLegionGiftBtn()
    -- body
    return self._LGiftBtn
end

-- 主城按钮点击：设置军团好礼活动id Tmp to 
function ActivityProxy:setTmpToLegionGiftID(isTrue)
    -- body
    self._activeID = self._activeIDTmp
    self._LGiftBtn = isTrue --是否点击了按钮标记
end


-- 获取限时活动列表
function ActivityProxy:getLimitActivityInfo()
    return self._limitActivityInfo or {}
end
-- 获取限时活动信息，通过uitype
function ActivityProxy:getLimitActivityDataByUitype( uitype )
    for k,v in pairs(self._limitActivityInfo) do
        if v.uitype == uitype then
            return v
        end
    end
    return nil
end
--获取限时活动信息，通过moudleName
function ActivityProxy:getLimitActivityDataByModuleName( moduleName )
    local activityData = nil
    for uitype, moduleN in pairs( allModule ) do
        if moduleName==moduleN then
            activityData = self:getLimitActivityDataByUitype( uitype )
        end
    end
    return activityData
end
-- 获取限时活动信息，通过id
function ActivityProxy:getLimitActivityInfoById(id)
    for k,v in pairs(self._limitActivityInfo) do
        if v.activityId == id then
            return v
        end
    end
end
-- 获得显示活动模块名,通过uitype
function ActivityProxy:getLimitActivityModuleNameByUiType(uiType)
    if uiType then
        return allModule[uiType]
    end
end


--*仅chatModule可用
function ActivityProxy:getLimitInfoByUitype(uitype)
    for k,v in pairs(self._limitActivityInfo) do
        if v.uitype == uitype then
            self.curActivityData = v
            return v
        end
    end
end

function ActivityProxy:removeLimitActivityInfo(id)
    for k,v in pairs(self._limitActivityInfo) do
        if v.activityId == id then
            table.remove(self._limitActivityInfo, k)
            break
        end
    end
end

-- 获取拉霸活动列表
function ActivityProxy:getLaBaActivityInfo()
    -- body
    return self._labaActivityInfo or {}
end

function ActivityProxy:returnInfo()
    return self.allInfo
end


function ActivityProxy:removeInfo(pos)
    -- print("remove pos===",pos)
    -- self.allInfo[pos] = 0
    for k,v in pairs(self.allInfo) do
        if v.pos == pos then
            table.remove(self.allInfo, k)
        end
    end
end

function ActivityProxy:getAllTipsData()
    return self.allTipsData
end

function ActivityProxy:getPartsGodInfos()  --得到军械神将的数据
    return self._partsGodInfos
end

-----------------------------------------------------------

function ActivityProxy:updateLimitRedpoint()
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:setAllLimitActivity()
end


function ActivityProxy:onTriggerNet230017Resp(data)
    --print("data.rs",data.rs)
    if data.rs == 0 then
        self:sendNotification(AppEvent.PROXY_ACTIVITY_PARTSGOD_GETREWARD , data)
        if data.type == 0 then
            self._partsGodInfos.ordnanceTime = self._partsGodInfos.ordnanceTime + 1
        end
        local redPointProxy = self:getProxy(GameProxys.RedPoint)
        redPointProxy:setPartsGodRed()
    end
end
--军械神将获取免费次数
function ActivityProxy:getPartsGodFreeTime()
    if self._partsGodInfos == nil or next(self._partsGodInfos) == nil then
        return 0
    end
    if GameConfig.serverTime >= self._partsGodInfos.endTime then
        return 0
    end
    local effectgroup = self._partsGodInfos.effectId
    local config = ConfigDataManager:getInfoFindByOneKey("OrdnanceForgingConfig", "effectgroup", effectgroup)
    local sumFreeTime = config.freetime
    local curUseTime = self._partsGodInfos.ordnanceTime
    return sumFreeTime - curUseTime
end

function ActivityProxy:onTriggerNet230017Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230017, data)
end

function ActivityProxy:onTriggerNet230019Req(data)
    self.reqActId = data.activityid
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230019, data)
end

function ActivityProxy:isUpdate()
    return self.reqActId == self.curActivityData.activityId
end

function ActivityProxy:onTriggerNet230019Resp(data)   --活动排行榜信息
    -- print("----------------------------onTriggerNet230019Resp")
    if table.size(data.activityRankInfos) == 0 then
        self.rankInfo[self.reqActId] = {}
        self.rankInfo[self.reqActId].activityRankInfos = {}
        self.rankInfo[self.reqActId].myRankInfo = data.myRankInfo
    else
        self.rankInfo[self.reqActId] = data
    end
    self:sendNotification(AppEvent.PROXY_ACTIVITY_PARTSGOD_UPDATERANKDATA)
    self:sendNotification(AppEvent.PROXY_UPDATE_ACTIVITY_RANK, data)
end

function ActivityProxy:getRankInfoById(id)
    id = id or self.curActivityData.activityId
    return self.rankInfo[id] or {activityRankInfos = {}}
end

function ActivityProxy:onTriggerNet140001Req(data)  --获取个人信息
    self:syncNetReq(AppEvent.NET_M14, AppEvent.NET_M14_C140001, data)
end

function ActivityProxy:setPartsGodFree() --重置军械神将免费
    if self._partsGodInfos ~= nil and  next(self._partsGodInfos) ~= nil then
        self._partsGodInfos.ordnanceTime = 0
        self:sendNotification(AppEvent.PROXY_ACTIVITY_PARTSGOD_SETFREE)
    end
end

function ActivityProxy:onTriggerNet230022Resp(data)
    local curId = self.curActivityData.activityId

    if data.rs == 0 then
        local info = self:getTurnTableInfo(curId)
        if info then
            info.free = info.free + #data.rewards
            --已经用掉的免费次数，限制为2次
            info.free = info.free > 2 and 2 or info.free
            --已经抽了多少次，简单粗暴加上抽的次数，这个值固定为抽的所有次数
            info.times = info.times + #data.rewards
        end
        local param = {}
        param.id = curId
        param.reward = data.rewards
        self:sendNotification(AppEvent.PROXY_UPDATE_ZPVIEW, data.rewards)
        self.allJifen = data.jifen
    else
        self:sendNotification(AppEvent.PROXY_UPDATE_ZPVIEW, {})
    end
    --更新转盘小红点，而不是更新全部活动的小红点
    self:getZPCount(curId)
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:setDayTrunRed()
    -- self:updateLimitRedpoint()

end


--=============================================================================
--金鸡砸蛋  更新初始化数据
function ActivityProxy:onUpdateSmashEgg( data )
    local eggData = data.smashEggInfos[1] or {}
    self.spendTimes = eggData.spendTimes or 0
    self.remainTimes = eggData.remainTimes or 0
end
function ActivityProxy:onTriggerNet230030Resp( data )
    if data.rs==0 then
        self.spendTimes = self.spendTimes + ( self.nNumberSmash or 1 )
        self.remainTimes = self.remainTimes - ( self.nNumberSmash or 1 )
        self._proxy:setSmashEggRed()
        self:sendNotification(AppEvent.PROXY_UPDATE_ACTVIEW_SMASHEGG, data.rewardList)
    end
end
function ActivityProxy:setNumberSmash( state )
    self.nNumberSmash = state
end
--金鸡砸蛋  获得今日可用的砸蛋点数、剩下砸蛋点数上限
function ActivityProxy:getSmashEggNumber()
    local conf = ConfigDataManager:getConfigData( ConfigData.SmashEggConfig ) or {}
    conf = conf[1] or {}
    local roleProxy = self:getProxy(GameProxys.Role)
    local nowSpend = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_all_spend_coin)
    local newNum = math.floor( (nowSpend - (self.__oldSpend or 0)) / (conf.expendMoney or 1) )
    local num2 = conf.numberMax - self.spendTimes  --99/99
    local num1 = math.min(num2, self.remainTimes + newNum)  --今日可用的点数
    return num1, num2
end
--金鸡砸蛋  刷新金鸡次数  0点后，直接设置为最大
function ActivityProxy:resetEggTimes()
    self.spendTimes = 0
    self.remainTimes = 0
end


--=============================================================================
--迎春集福 集福回来
function ActivityProxy:onTriggerNet230031Resp( data )
    if data.rs==0 then
        self:showSysMessage( "集福成功" )
        self._proxy:setCollectBlessRed()
    end
end
--迎春集福 可集福数量
function ActivityProxy:getCollectBlessFullNumber()
    local conf = ConfigDataManager:getConfigData( ConfigData.CollectBlessConfig )
    local fullNumber = 0
    local numberArr = {}
    for i,v in ipairs(conf) do
        local arr = StringUtils:jsonDecode( v.collectID or "[]") or {}
        local addnumber = 99999
        for j, icondata in ipairs( arr ) do
            local id = icondata[2]
            local num = icondata[3]
            local itemProxy = self:getProxy(GameProxys.Item)
            local numberAtBag = numberArr[id] or itemProxy:getItemNumByType( id )
            if addnumber~=nil then
                addnumber = math.min( addnumber, math.floor(numberAtBag/num) )
                numberArr[id] = (numberArr[id] or 0) - num
                if numberAtBag<num then
                    addnumber = nil
                end
            end
        end
        if addnumber==99999 or addnumber==nil then
            addnumber = 0
        end
        fullNumber = fullNumber + addnumber
    end
    return fullNumber
end


--=================================================================
--爆竹酉礼领取
function ActivityProxy:onTriggerNet230026Req(data)
    --记录点击的位置
    self.squibSendPos = data.pos
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230026, data)
end

--爆竹酉礼领取
function ActivityProxy:onTriggerNet230026Resp(data)
    if data.rs == 0 then
        self:changeClientSquibInfo(data.activityId,self.squibSendPos)
        --self:sendNotification(AppEvent.PROXY_UPDATE_SQUIBINFO)
        --领取后点燃
        self:sendNotification(AppEvent.PROXY_SQUIB_AFTER_KINDLE,self.squibSendPos)
        local redPointProxy = self:getProxy(GameProxys.RedPoint)
        redPointProxy:setSpringSquibRed()
    end
end
--=================================================================
--武学讲坛学习
function ActivityProxy:onTriggerNet230032Req(data)
    --记录是否在用为免费次数
    self.learnTime = data.times
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230032, data)
end

--武学讲坛学习
function ActivityProxy:onTriggerNet230032Resp(data)
    if data.rs == 0 then
        self:martialInfoAddOneById(data.activityId,data.learnTimes)
        self:sendNotification(AppEvent.PROXY_AFTER_MARTIALLEARN,data.rewardList)

        local redPointProxy = self:getProxy(GameProxys.RedPoint)
        redPointProxy:setMartialRed()
    end
end
--=================================================================
--更换煮酒英雄
function ActivityProxy:onTriggerNet230033Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230033, data)
end

--更换煮酒英雄
function ActivityProxy:onTriggerNet230033Resp(data)
    if data.rs == 0 then
        self:updateCookingPosInfo(data)
        self:sendNotification(AppEvent.PROXY_UPDATE_COOKINFO)
        self:sendNotification(AppEvent.PROXY_CLOSE_COOKSELECTPANEL)
    end
end
--敬酒
function ActivityProxy:onTriggerNet230034Req(data)
    --记录是否在用为免费次数
    self.cookingToastTime = data.times
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230034, data)
end

--敬酒
function ActivityProxy:onTriggerNet230034Resp(data)
    if data.rs == 0 then
        --处理次数
        self:cookingInfoTimeAddOne(data)
        self:setCookingPosInfo(data)
        --更新积分
        self:setCookingWineInfoIntegral(data)
        local effectData = {}

        if self.cookingToastTime == 0 then
            logger:info("==>self.cookingToastTime", self.cookingToastTime)
            logger:info("data.rewardList[1]:%s", data.rewardList[1].typeid)
            if #data.rewardList == 1 and next(data.rewardList[1]) == nil then
               logger:info("==============>next(data.rewardList[1])") 
               logger:info("==============>next(data.rewardList[1])") 
            end
        end
        effectData.time = self.cookingToastTime
        effectData.rewardList = data.rewardList
        self:sendNotification(AppEvent.PROXY_AFTER_TOAST,effectData)

        local redPointProxy = self:getProxy(GameProxys.RedPoint)
        redPointProxy:setCookingRed()

    end
end
--230034后刷新积分
function ActivityProxy:setCookingWineInfoIntegral(data)
    for k,v in pairs(self.cookInfos) do
        if v.activityId == data.activityId then
            self.cookInfos[k].integral  = data.integral
        end
    end
end
--230033更换武将后手动初始化PosInfo
function ActivityProxy:updateCookingPosInfo(data)
    local cookInfo = self:getCookInfoyId(data.activityId)
    if cookInfo then
        if next(cookInfo.info) then
            local haveData = false
            for k,v in pairs(cookInfo.info) do
                if v.pos == data.pos  then
                    haveData = true
                    v.typeId = data.typeId
                    v.fidelity = 0
                end
            end
            if haveData == false then
                local aTable = {}
                aTable.pos = data.pos
                aTable.typeId = data.typeId
                aTable.fidelity = 0
                table.insert(cookInfo.info, aTable)
            end
        else
            --cookInfo.info为空表
            local aTable = {}
            aTable.pos = data.pos
            aTable.typeId = data.typeId
            aTable.fidelity = 0
            table.insert(cookInfo.info, aTable)
        end
    end
end
--230034敬酒后直接覆盖最新的PosInfo
function ActivityProxy:setCookingPosInfo(data)
    local cookInfo = self:getCookInfoyId(data.activityId)
    cookInfo.info = data.info
end
function ActivityProxy:setCookInfos(cookInfos)
    self.cookInfos = cookInfos
end
--根据活动id获取煮酒英雄信息
function ActivityProxy:getCookInfoyId(activityId)
    for k,v in pairs(self:getCookInfos()) do
        if v.activityId == activityId then
            return self.cookInfos[k]
        end
    end
end
function ActivityProxy:getCookInfos()
    return self.cookInfos or {}
end
function ActivityProxy:cookingInfoTimeAddOne(data)
    for k,v in pairs(self.cookInfos) do
        if v.activityId == data.activityId then
            if self.cookingToastTime == 0 then
                self.cookInfos[k].free  = self.cookInfos[k].free + 1
            end
        end
    end
end

--
--重置煮酒英雄免费次数
function ActivityProxy:resetCookFreeTime()
    for _,v in pairs(self:getCookInfos()) do
        v.free = 0
    end
    self:sendNotification(AppEvent.PROXY_UPDATE_COOKINFO)
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:setCookingRed()
end

--根据活动id获取煮酒英雄信息免费次数
function ActivityProxy:getCookFreeTime(activityId)
    --活动已经过期，未下架，直接返回无次数
    local limitActivityInfo = self:getLimitActivityInfoById(activityId)
    if limitActivityInfo == nil then
        return 0
    end
    if GameConfig.serverTime >= limitActivityInfo.endTime then
        return 0
    end
    for _,v in pairs(self:getCookInfos()) do
        if v.activityId == activityId then
            
            local roleProxy = self:getProxy(GameProxys.Role)
            local curVipNum = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel) or 0--vip
            local cookingWineConfig = ConfigDataManager:getConfigById(ConfigData.CookingWineConfig, limitActivityInfo.effectId)
            local allfreeNum
            if curVipNum > 0 then
                allfreeNum = cookingWineConfig.vFreeTimes
            else
                allfreeNum = cookingWineConfig.freeTimes
            end
            return allfreeNum - v.free
        end
    end
    return 0
end


--=================================================================

--================国之重器start=======================
--国之重器收集
function ActivityProxy:onTriggerNet230042Req(data)
    self.broadSealCollectState = true
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230042, data)
end
function ActivityProxy:onTriggerNet230042Resp(data)
    self.broadSealCollectState = false
    if data.rs == 0 then
        self:broadSealInfoAddOne(data)
        self:updateBroadPostInfos(data)
    end
end
function ActivityProxy:getBroadSealCollectState()
    return self.broadSealCollectState or false
end
--国之重器指定槽位购买
function ActivityProxy:onTriggerNet230043Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230043, data)
end
function ActivityProxy:onTriggerNet230043Resp(data)
    if data.rs == 0 then
        self:updateBroadPostInfosWithPos(data)
    end
end
--国之重器组装
function ActivityProxy:onTriggerNet230044Req(data)
    self.broadSealComposeState = true
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230044, data)
end
function ActivityProxy:onTriggerNet230044Resp(data)
    self.broadSealComposeState = false
    if data.rs == 0 then
        --客户端手动减去数量
        local broadSealInfo = self:getBroadSealInfobyId(data.activityId)
        local effectID = self:getLimitActivityInfoById(data.activityId).effectId
        local broadSealConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.BroadSealConfig, "effectID", effectID)
        local costNum = broadSealConfig.costTime
        local times = data.times   --总的收集次数
        for k,v in pairs(broadSealInfo.broadPostInfos) do
            broadSealInfo.broadPostInfos[k].num = broadSealInfo.broadPostInfos[k].num - costNum * times
        end
        self:sendNotification(AppEvent.PROXY_BROADSEAL_COMPOSE,data.rewardList)

    end
end
function ActivityProxy:getBroadSealComposeState()
    return self.broadSealComposeState or false
end
--230043后跟新posInfos
function ActivityProxy:updateBroadPostInfosWithPos(data)
    local broadSealInfo = self:getBroadSealInfobyId(data.activityId)
    for _,val in pairs(broadSealInfo.broadPostInfos) do
        if val.pos == data.pos then
            val.num = val.num + 5
        end
    end
    self:sendNotification(AppEvent.PROXY_UPDATE_BROADSEALINFO)
end
--230042后跟新posInfos
function ActivityProxy:updateBroadPostInfos(data)
    local broadSealInfo = self:getBroadSealInfobyId(data.activityId)
    local tagTable = {}
    for _,v in pairs(data.posInfos) do
        tagTable[v.pos] = v.num
    end
    local changePosInfos = {}
    for _,val in pairs(broadSealInfo.broadPostInfos) do
        if tagTable[val.pos] ~= nil then
            if val.num ~= tagTable[val.pos] then
                table.insert(changePosInfos, val.pos)
            end
            val.num = tagTable[val.pos]
        end
    end
    local infoTable = {}
    infoTable.time = data.time
    infoTable.changePosInfos = changePosInfos
    self:sendNotification(AppEvent.PROXY_BROADSEAL_COLLECT,infoTable)
end
function ActivityProxy:setBroadSealInfos(broadSealInfos)
    self.broadSealInfos = broadSealInfos
    --初始化一个槽位信息
    for _,v in pairs(self.broadSealInfos) do
        if v.broadPostInfos == nil or next(v.broadPostInfos) == nil then
            v.broadPostInfos = {}
            for i=1,9 do
                table.insert(v.broadPostInfos,i,{pos = i,num = 0})
            end
        else
            local tagTable = {}
            for _,v in pairs(v.broadPostInfos) do
                tagTable[v.pos] = v.num        
            end
            for i=1,9 do
                if tagTable[i] == nil then
                    table.insert(v.broadPostInfos,{pos = i,num = 0})
                end
            end
        end
    end
    -- local redPointProxy = self:getProxy(GameProxys.RedPoint)
    -- redPointProxy:setBroadSealRed()
end
--根据活动id获取国之重器信息
function ActivityProxy:getBroadSealInfobyId(activityId)
    for k,v in pairs(self:getBroadSealInfos()) do
        if v.activityId == activityId then
            return self.broadSealInfos[k]
        end
    end
end
function ActivityProxy:getBroadSealInfos()
    return self.broadSealInfos or {}
end
function ActivityProxy:broadSealInfoAddOne(data)
    if data.time ~= 0 then
        return
    end
    for k,v in pairs(self.broadSealInfos) do
        if v.activityId == data.activityId then
            -- if self.broadSealIsUseFreeTime == true then
                self.broadSealInfos[k].freeTime  = self.broadSealInfos[k].freeTime + 1
            -- end
        end
    end
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:setBroadSealRed()
end
function ActivityProxy:setBroadSealIsUseFreeTime(bl)
    self.broadSealIsUseFreeTime = bl
end
--重置国之重器免费次数
function ActivityProxy:resetBroadSealFreeTime()
    for _,v in pairs(self:getBroadSealInfos()) do
        v.freeTime = 0
    end
    self:sendNotification(AppEvent.PROXY_UPDATE_BROADSEALINFO)
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:setBroadSealRed()
end

--根据活动id获取国之重器免费次数
function ActivityProxy:getBroadSealFreeTime(activityId)
    for _,v in pairs(self:getBroadSealInfos()) do
        if v.activityId == activityId then
            local info = self:getLimitActivityInfoById(activityId)
            if info then
                local effectID = info.effectId
                 local broadSealConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.BroadSealConfig, "effectID", effectID)
                local freeTime = broadSealConfig.freeTime
                return freeTime - v.freeTime        
            end

        end
    end
    return 0
end
--根据活动id获取国之重器当前是否满足组装条件
function ActivityProxy:getBroadSealIsCanCompose(activityId)
    local broadSealInfo = self:getBroadSealInfobyId(activityId)
    if broadSealInfo == nil then
        return false
    end
    local info = self:getLimitActivityInfoById(activityId)
    if info == nil then
        return false
    end
    local effectID = info.effectId
    local broadSealConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.BroadSealConfig, "effectID", effectID)
    local costTime = broadSealConfig.costTime   

    local num = 0
    for _,val in pairs(broadSealInfo.broadPostInfos) do
        if val.num >= costTime then
            num = num + 1
        end
    end


    return num == 9
end
--在已知当前满足组装条件情况下，获取当前总共可以组装的个数
function ActivityProxy:getBroadSealIsCanComposeNum(activityId)
    local broadSealInfo = self:getBroadSealInfobyId(activityId)
    if broadSealInfo == nil then
        return 0
    end
    local info = self:getLimitActivityInfoById(activityId)
    if info == nil then
        return 0
    end
    local effectID = info.effectId
    local broadSealConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.BroadSealConfig, "effectID", effectID)
    local costTime = broadSealConfig.costTime   

    local tempTable = clone(broadSealInfo.broadPostInfos)
    table.sort(tempTable,function(one,two)
        return one.num < two.num
    end)
    local num = tempTable[1].num / costTime

    return math.floor(num)
end


--================国之重器end=========================
function ActivityProxy:onTriggerNet230036Resp(data)
    if data.rs == 0 then
        local flag, info = self:getDataById(data.activityId)
        if info ~= nil and info.effectInfos ~= nil then
            for k,v in pairs(info.effectInfos) do
                if v.conditiontype == 129 then
                    info.effectInfos[k].condition1 = data.time
                    if data.time >= v.condition2 and v.iscanget == 3 then
                        info.effectInfos[k].iscanget = 1
                    end
                end
            end

            self:sendNotification(AppEvent.PROXY_ACTIVITY_INFO, self._allActivityInfo)
            self._proxy:checkActivityRedPoint()
            self._proxy:checkArmyBigRewardRedPoint()
        end
    else
        self:updateOnlineTime()
    end
end

--根据activityId找武学讲坛信息然后对应学习次数加一
function ActivityProxy:martialInfoAddOneById(activityId,learnTimes)
    for k,v in pairs(self.martialInfos) do
        if v.activityId == activityId then
            
            if self.learnTime == 0 then
                self.martialInfos[k].free  = self.martialInfos[k].free + 1
                self.learnTime =  self.learnTime + 1
            end
             self.martialInfos[k].learnTimes = learnTimes
        end
    end
    
end
function ActivityProxy:setMartialInfos(martialInfos)
    self.martialInfos = martialInfos
end
function ActivityProxy:getMartialInfos()
    return self.martialInfos or {}
end
--重置武学讲堂免费次数
function ActivityProxy:resetMartialFreeTime()
    for _,v in pairs(self:getMartialInfos()) do
        v.free = 0
    end
    --print("resetMartialFreeTime111111111111111112222223````````")
    self:sendNotification(AppEvent.PROXY_UPDATE_MARTIALINFO)
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:setMartialRed()
end

--根据活动id获取武学讲坛免费次数
function ActivityProxy:getMartialFreeTime(activityId)
    --活动过期未下架直接返回0
    local limitActivityInfo = self:getLimitActivityInfoById(activityId)
    if limitActivityInfo == nil then
        return 0
    end
    if GameConfig.serverTime >= limitActivityInfo.endTime then
        return 0
    end
    for _,v in pairs(self:getMartialInfos()) do
        if v.activityId == activityId then
            return 1 - v.free
        end
    end
    -- print("There is not data in MartialInfos by this activityId")
    return 0
end
--根据活动id获取武学讲坛信息
function ActivityProxy:getMartialInfoById(activityId)
    if self.martialInfos then
        for k,v in pairs(self:getMartialInfos()) do
            if v.activityId == activityId then
                return self.martialInfos[k]
            end
        end
    else
        -- print("martialInfos is nil")
        return {}
    end
    -- print("no martialInfo by this activityId")
    -- print(activityId)
    return {}
end
--=================================================================


--fwx==============================================================
--连续充值  连续充值补签
function ActivityProxy:onTriggerNet230037Resp(data)
    if data.rs==0 then
        self:showSysMessage( TextWords:getTextWord(230381) )
        local dayLen = math.max( 0, self.dayRechargeInfos.nowDay-1 )
        for i=1,dayLen do
            self.dayRechargeInfos.day[i] = i
        end
        self:sendNotification(AppEvent.PROXY_UPDATE_ACTVIEW_DAYRECHARGE)
        self._proxy:setDayRechargeNumberRed()
    end
end
--连续充值  连续充值领取奖励
function ActivityProxy:onTriggerNet230038Resp(data)
    if data.rs==0 then
        self:showSysMessage( TextWords:getTextWord(1118) )
        for _,id in ipairs( data.getRewardId or {} ) do
            table.insert( self.dayRechargeInfos.hasgetId, id )
        end
        self:sendNotification(AppEvent.PROXY_UPDATE_ACTVIEW_DAYRECHARGE)
        self._proxy:setDayRechargeNumberRed()
    end
end
--连续充值  登陆连续充值信息
function ActivityProxy:setDayRechargeInfos(data)
    self.dayRechargeInfos = data or {}
end
function ActivityProxy:getDayRechargeInfos()
    return self.dayRechargeInfos
end
--刷新当天是否已经充够值的day数据
function ActivityProxy:updateCurDayRecharge()
    local roleProxy  = self:getProxy(GameProxys.Role)
    local haveCoin = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_today_charge) or 0
    local infoConfig = ConfigDataManager:getConfigData( ConfigData.DayRechargeConfig )
    infoConfig = infoConfig[1]
    local needCoin = infoConfig.rechargeLimit or 0
    local isRecharge = haveCoin>=needCoin
    local data = self.dayRechargeInfos or {}
    for _, day in ipairs( data.day or {} ) do
        if day==data.nowDay then
            isRecharge = false
        end
    end
    if isRecharge and data.day then
        table.insert( self.dayRechargeInfos.day, data.nowDay )
    end
end
--可领取数量
function ActivityProxy:getDayRechargeNumber()
    if not self.dayRechargeInfos.nowDay then return end
    self:updateCurDayRecharge()
    local dayLen = #self.dayRechargeInfos.day
    local rewardConf = ConfigDataManager:getConfigData( ConfigData.DayRewardConfig )
    local hasgetId = {}
    for _,id in ipairs(self.dayRechargeInfos.hasgetId) do
        hasgetId[id] = true
    end
    local numberGet = 0
	local activityProxy = self:getProxy(GameProxys.Activity)
	local activityData = activityProxy:getLimitActivityDataByUitype( ActivityDefine.LIMIT_DAYRECHARGE_ID )
	local effectId = activityData.effectId
    for i, conf in ipairs(rewardConf) do
        if not hasgetId[i] and conf.day<=dayLen then
            if conf.rewardGroup == effectId then
                numberGet = numberGet + 1
            end
        end
    end
    return numberGet
end
--过点刷新
function ActivityProxy:resetDayRecharge()
    if not self.dayRechargeInfos.nowDay then return end

    self.dayRechargeInfos.nowDay = self.dayRechargeInfos.nowDay + 1
    self.dayRechargeInfos.nowDay = math.min( 7, self.dayRechargeInfos.nowDay )

    self:sendNotification(AppEvent.PROXY_UPDATE_ACTVIEW_DAYRECHARGE)
    self._proxy:setDayRechargeNumberRed()
end
--fwx==============================================================


function ActivityProxy:updateTurnTable()
    local roleProxy = self:getProxy(GameProxys.Role)
    local allSpend = roleProxy:setRoleAttrValue(PlayerPowerDefine.POWER_all_spend_coin, 0)
    self.turntableInfos = self.turntableInfos or {}
    for k,v in pairs(self.turntableInfos) do
        self.turntableInfos[k].times = 0
        self.turntableInfos[k].free = 1
        self:getZPCount(v.id)
    end
    -- self:updateLimitRedpoint()
    --重置的时候
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:setDayTrunRed()
    self:sendNotification(AppEvent.PROXY_RESET_TTDATA)
end

function ActivityProxy:setModuleNameData(id, name)
    if not self.moduleName then
        self.moduleName = {}
    end
    self.moduleName[id] = name
end

function ActivityProxy:getModuleData(id)
    return self.moduleName[id]
end

function ActivityProxy:setDayTurntableRedPointCount(id, count)
    self._dayTurntableRedPoints[id] = count
    local redPoint = self:getProxy(GameProxys.RedPoint)
    redPoint:setRedPoint(id, count)
end

function ActivityProxy:getDayTurntableRedPoints()
    return self._dayTurntableRedPoints
end

function ActivityProxy:getZPCount(id, info)
    if type(id) ~= "number" then
        return
    end
    local function getLimitInfoById(id)
        for k,v in pairs(self._limitActivityInfo) do
            if v.activityId == id then
                return v
            end
        end
    end
    if not info then
        info = getLimitInfoById(id)
    end
    local turnInfo = self:getTurnTableInfo(id)
    if info and turnInfo then
        local roleProxy = self:getProxy(GameProxys.Role)
        local config = ConfigDataManager:getConfigById(ConfigData.CoronaConfig, info.effectId)
        local vipLv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel)
        local vipCount = vipLv > 0 and 1 + config.condition or 1
        local hasCount = math.floor(turnInfo.spend/config.limit) - turnInfo.times + vipCount
        hasCount = hasCount < 0 and 0 or hasCount
        self:setDayTurntableRedPointCount(id, hasCount)

    end
end

--监测属性变化，更新小红点
function ActivityProxy:updateRoleInfoRsp(data)
    local roleProxy = self:getProxy(GameProxys.Role)
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    --今日消费变化 
    local nowLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel)
    local nowSpend = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_all_spend_coin)
    local nowCharge = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_today_charge)

    if (self.vipLevel == 0 and nowLevel ~= 0) or (self.allSpend ~= nowSpend) then
        -- print("需要刷新")
        for k,v in pairs(self._limitActivityInfo) do
            self:getZPCount(v.activityId)
        end
        -- self:updateLimitRedpoint()
        redPointProxy:setDayTrunRed()
        redPointProxy:setSmashEggRed()
    end
    self.vipLevel = nowLevel
    self.allSpend = nowSpend

    --今日充值变化
    if self.__afterCharge ~= nowCharge then
        redPointProxy:setDayRechargeNumberRed()
        self.__afterCharge = nowCharge
    end
end
--监听背包
function ActivityProxy:updateRoleBagRsp(data)
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    if #data.itemList>0 then
        redPointProxy:setCollectBlessRed()
    end
end

function ActivityProxy:getRankReqData(id)
    local data = {}
    local info = self.allTotal[id]
    for k,v in pairs(info) do
        if v.rewardState == 1 then
            data.effectId = v.effectId
            data.sort = v.sort
            break
        end
    end
    return data
end
function ActivityProxy:setSquibInfos(squibInfos)
    self.squibInfos = squibInfos
end
function ActivityProxy:getSquibInfos()
    return self.squibInfos or {}
end
--根据activityId获取爆竹酉礼点燃位置的信息
function ActivityProxy:getSquibPosInfos(activityId)
    for k,v in pairs(self.squibInfos) do
        if v.activityId == activityId then
            return self.squibInfos[k].pos
        end
    end
    return {}
end

--获取当前活动数据
function ActivityProxy:getCurActivityData()
    return self.curActivityData
end
--主动修改爆竹酉礼爆竹位置信息
function ActivityProxy:changeClientSquibInfo(activityId,squibSendPos)
    for k,v in pairs(self.squibInfos) do
        if v.activityId == activityId then
            table.insert(self.squibInfos[k].pos,squibSendPos) 
        end
    end
    
end
--清空爆竹位置信息
function ActivityProxy:cleanClientSquibInfo()
    for k,v in pairs(self.squibInfos) do
        self.squibInfos[k].pos = {}
    end

    self:sendNotification(AppEvent.PROXY_UPDATE_SQUIBINFO)
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:setSpringSquibRed()
end
--根据activityId获取爆竹酉礼还能点击多少次
function ActivityProxy:getSquibCanTouchTime(activityId)

    --计算当前充值金额前面有段
    local n = 0
    local config = ConfigDataManager:getConfigData(ConfigData.FirecrackerConfig)
    local roleProxy = self:getProxy(GameProxys.Role)
    local chargeValue = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_today_charge)
    table.sort(config,function ( a,b )
        return a.ID < b.ID
    end)

    if chargeValue >= config[#config].recharge then
        n = 6
    elseif chargeValue <= 0 then
        n = 0
    else
        for k,v in pairs(config) do
            if chargeValue > config[k]["recharge"] and chargeValue < config[k + 1]["recharge"] then
                n = k
                break
            end
        end
    end
    --已经点了几个
    local posArray = self:getSquibPosInfos(activityId)
    local hasTouch = #posArray

    local time = n - hasTouch
    time = time < 0 and 0 or time
    time = time > 6 and 6 or time

    return time
end
--====================雄狮轮盘================start
--雄狮征召
function ActivityProxy:onTriggerNet230045Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230045, data)
end
function ActivityProxy:onTriggerNet230045Resp(data)

    if data.rs == 0 then
        self:setOneLionTurnInfo(data.info)
        local tempMap = {}
        --基础数
        tempMap.soldierNum = data.info.soldierNum
        --兵种typeId
        tempMap.lastSoldierType = data.info.lastSoldierType
        --本次征召的次数（1或者10）
        tempMap.draftType = data.draftType
        self:sendNotification(AppEvent.PROXY_LIONTURN_CONSCRIPT, tempMap)
    end

end


function ActivityProxy:setLionTurntableInfos(lionTurntableInfos)
    self.lionTurntableInfos = lionTurntableInfos
end
--根据活动id获取雄狮轮盘信息
function ActivityProxy:getLionTurnInfoById(activityId)
    for k,v in pairs(self.lionTurntableInfos) do
        if v.activityId == activityId then
            return self.lionTurntableInfos[k]
        end
    end
end
function ActivityProxy:setOneLionTurnInfo(info)
    for k,v in pairs(self.lionTurntableInfos) do
        if v.activityId == info.activityId then
            self.lionTurntableInfos[k] = info
        end
    end
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:setLionTurnRed()
end
function ActivityProxy:getLionTurnInfos()
    return self.lionTurntableInfos or {}
end
--根据活动id获取雄狮轮盘免费次数
function ActivityProxy:getLionTurnFreeTime(activityId)
    for _,v in pairs(self:getLionTurnInfos()) do
        if v.activityId == activityId then
            local info = self:getLimitActivityInfoById(activityId)
            if info then
                local effectID = info.effectId
                 local lionCoronaConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.LionCoronaConfig, "effectID", effectID)
                local freeTime = lionCoronaConfig.freeTime
                return freeTime - v.freeTime        
            end

        end
    end
    return 0
end
function ActivityProxy:resetLionTurnFreeTime()
    for _,v in pairs(self:getLionTurnInfos()) do
        v.freeTime = 0
    end
    self:sendNotification(AppEvent.PROXY_UPDATE_LIONTURNINFO)
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:setLionTurnRed()
end
--====================雄狮轮盘================end


--====================精绝古城================start

function ActivityProxy:setJingJueInfos(jingJueInfos)
    self.jingJueInfos = jingJueInfos
end
function ActivityProxy:getJingJueInfos()
    return self.jingJueInfos or {}
end
function ActivityProxy:getJingJueInfoById(activityId)
    for k,val in pairs(self:getJingJueInfos()) do
        if val.activityId == activityId then
            return val
        end
    end
end
--通过活动id获取已经开启的门数量
function ActivityProxy:getJingJueCurOpenNum( activityId )
    local openNum = 0
    local indo = self:getJingJueInfoById(activityId)
    for _,val in pairs(indo.itemList) do
        if val.pos > 0 then
            openNum = openNum + 1
        end
    end
    return openNum
end
--改变客户端购买状态
function ActivityProxy:changeJingJueBuyStatus( activityId,buyTag )
    local jingJueInfo = self:getJingJueInfoById(activityId)
    jingJueInfo.buy = buyTag
    local freeTime = self:getJingJueFreeTime(activityId)
    if freeTime > 0 then
        jingJueInfo.freeTimes = jingJueInfo.freeTimes + 1
        local redPointProxy = self:getProxy(GameProxys.RedPoint)
        redPointProxy:setJingJueRed()
    end
end
--单抽与全抽协议返回数据处理
function ActivityProxy:setJingJueInfoByVo( dataVo )
    local jingJueInfo = self:getJingJueInfoById(dataVo.activityId)
    jingJueInfo.freeTimes = dataVo.freeTimes
    jingJueInfo.itemList = dataVo.itemList
    jingJueInfo.num = dataVo.num
    jingJueInfo.buy = dataVo.buy
    jingJueInfo.integral = dataVo.integral
end
--兑换协议返回数据处理
function ActivityProxy:setMergeListInJingJueInfo( dataVo )
    local jingJueInfo = self:getJingJueInfoById(dataVo.activityId)
    jingJueInfo.mergeList = dataVo.mergeList
    jingJueInfo.num = dataVo.num
end
--通过TombMarketConfig里面的ID获取对应已经合成过的次数
function ActivityProxy:getJingJueMergeByActIdAndID( activityId,ID )
    local jingJueInfo = self:getJingJueInfoById(activityId)
    if jingJueInfo.mergeList then
        for _,val in pairs(jingJueInfo.mergeList) do
            if val.typeId == ID then
                return val.times
            end
        end
    end
    return 0
end
--手动重置
function ActivityProxy:resetJingJueItemList(activityId)
    local jingJueInfo = self:getJingJueInfoById(activityId)
    jingJueInfo.itemList = {}
end
--根据活动id获取精绝古城免费次数
function ActivityProxy:getJingJueFreeTime(activityId)
    local limitActivityInfo = self:getLimitActivityInfoById(activityId)
    if limitActivityInfo == nil then
        return 0
    end
    if GameConfig.serverTime >= limitActivityInfo.endTime then
        return 0
    end
    for _,v in pairs(self:getJingJueInfos()) do
        if v.activityId == activityId then
            local info = self:getLimitActivityInfoById(activityId)
            if info then
                local effectID = info.effectId
                 local tombCityConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.TombCityConfig, "effectID", effectID)
                local freeTime = tombCityConfig.freeTime
                return freeTime - v.freeTimes        
            end

        end
    end
    return 0
end
function ActivityProxy:resetJingJueFreeTime()
    for _,v in pairs(self:getJingJueInfos()) do
        v.freeTimes = 0
    end
    self:sendNotification(AppEvent.PROXY_JINGJUECITY_UPDATE)
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:setJingJueRed()
end
--精绝古城购买（去蒙板）
function ActivityProxy:onTriggerNet230046Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230046, data)
end
function ActivityProxy:onTriggerNet230046Resp(data)
    if data.rs == 0 then
        --改变购买状态
        self:changeJingJueBuyStatus(data.activityId,1)
        self:sendNotification(AppEvent.PROXY_JINGJUECITY_UPDATE)
    end
end
--精绝古城抽奖
function ActivityProxy:onTriggerNet230047Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230047, data)
end
function ActivityProxy:onTriggerNet230047Resp(data)
    if data.rs == 0 then
        self:setJingJueInfoByVo(data)
        self:sendNotification(AppEvent.PROXY_JINGJUECITY_OPEN, data.itemList)
    else
        self:sendNotification(AppEvent.PROXY_JINGJUECITY_OPEN_ALL)
    end
    

end
--精绝古城手动重置
function ActivityProxy:onTriggerNet230048Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230048, data)
end
function ActivityProxy:onTriggerNet230048Resp(data)
    if data.rs == 0 then
        self:resetJingJueItemList(data.activityId)
        self:sendNotification(AppEvent.PROXY_JINGJUECITY_UPDATE)
    end
end
--精绝古城兑换
function ActivityProxy:onTriggerNet230049Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230049, data)
end
function ActivityProxy:onTriggerNet230049Resp(data)
    if data.rs == 0 then
        self:setMergeListInJingJueInfo(data)
        self:sendNotification(AppEvent.PROXY_JINGJUECITY_UPDATE)
    end
end
--====================精绝古城================end
--====================返利大放送================start
function ActivityProxy:setRechargeRebateInfos(rechargeRebateInfos)
    self.rechargeRebateInfos = rechargeRebateInfos
end
function ActivityProxy:getRechargeRebateInfos()
    return self.rechargeRebateInfos or {}
end
function ActivityProxy:getRechargeRebateInfoById(activityId)
    for k,val in pairs(self.rechargeRebateInfos) do
        if val.activityId == activityId then
            return self.rechargeRebateInfos[k]
        end
    end
end
--充值返利转盘
function ActivityProxy:onTriggerNet230050Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230050, data)
end
function ActivityProxy:onTriggerNet230051Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230051, data)
end
--充值返利转盘
function ActivityProxy:onTriggerNet230050Resp(data)
    if data.rs == 0 then
        for k,val in pairs(self.rechargeRebateInfos) do
            if val.activityId == data.activityId then
                self.rechargeRebateInfos[k] = data.info
            end
        end
        self:sendNotification(AppEvent.PROXY_RECHARGEREBATE_AFTER_TURN,data.info)
        local redPointProxy = self:getProxy(GameProxys.RedPoint)
        redPointProxy:setRechargeRebateRed()
    end
    self:sendNotification(AppEvent.PROXY_RECHARGEREBATE_230050,data.rs)
end
--充值返利领取返利
function ActivityProxy:onTriggerNet230051Resp(data)
    if data.rs == 0 then
    for k,val in pairs(self.rechargeRebateInfos) do
            if val.activityId == data.activityId then
                self.rechargeRebateInfos[k].currentGold = 0
                self.rechargeRebateInfos[k].condition = 0
                self.rechargeRebateInfos[k].rebate = 0
            end
        end
        self:sendNotification(AppEvent.PROXY_RECHARGEREBATE_INFO_UPDATE,{})
    end
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:setRechargeRebateRed()

end
--服务器主动推送 充值后返利信息
function ActivityProxy:onTriggerNet230052Resp(data)
    local isExist = false
    for k,val in pairs(self.rechargeRebateInfos) do
        if val.activityId == data.info.activityId then
            self.rechargeRebateInfos[k] = data.info
            isExist = true
        end
    end
    if isExist == false then
        table.insert(self.rechargeRebateInfos, data.info)
    end
    self:sendNotification(AppEvent.PROXY_RECHARGEREBATE_INFO_UPDATE,{})
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:setRechargeRebateRed()
end
--根据活动id获取返利大放送是否可以领取
function ActivityProxy:getRechargeRebateRewardNum(activityId)
    local num = 0
    for k,val in pairs(self.rechargeRebateInfos) do
        if val.activityId == activityId then
            if val.currentGold >= val.condition and val.condition ~= 0 then
                num = 1
            end
        end
    end
    return num
end
--====================返利大放送================end
--====================同盟致富==============start
function ActivityProxy:setLegionRichInfos(legionRichInfos)
    self.legionRichInfos = legionRichInfos
    if next(legionRichInfos) == nil then
        local redPointProxy = self:getProxy(GameProxys.RedPoint)
        redPointProxy:setLegionRichRed()
    end
end
function ActivityProxy:getLegionRichInfos()
    return self.legionRichInfos or {}
end
function ActivityProxy:getLegionRichInfoById(activityId)
    if self.legionRichInfos == nil or next(self.legionRichInfos) == nil then
        return
    end
    for k,val in pairs(self.legionRichInfos or {}) do
        if val.activityId == activityId then
            return self.legionRichInfos[k]
        end
    end
end
function ActivityProxy:getLegionRichMemberInfoById(id)
    for k,val in pairs(self.legionRichGatherInfos) do
        if val.id == id then
            return self.legionRichGatherInfos[k]
        end
    end
end
--计算领取奖励小红点总数
function ActivityProxy:getLegionRichRedNumById(activityId)
    local legionRichInfo = self:getLegionRichInfoById(activityId)
    if legionRichInfo == nil or legionRichInfo.missionInfos == nil then
        return 0
    end
    local num = 0
    for k,v in pairs(legionRichInfo.missionInfos) do
        num = num + v.remainTimes
    end
    return num
end

--领取同盟致富任务奖励
function ActivityProxy:onTriggerNet230053Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230053, data)
end
--查看同盟成员采集信息
function ActivityProxy:onTriggerNet230054Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230054, data)
end
--打开同盟致富活动界面
function ActivityProxy:onTriggerNet230056Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230056, data)
end
--领取同盟致富任务奖励
function ActivityProxy:onTriggerNet230053Resp(data)
    if data.rs == 0 then
        local isExist = false
        for k,val in pairs(self.legionRichInfos) do
            if val.activityId == data.activityId then
                self.legionRichInfos[k] = data.info
                isExist = true
            end
        end
        if isExist == false then
            table.insert(self.legionRichInfos, data.info)
        end
        self:sendNotification(AppEvent.PROXY_LEGIONRICH_UPDATE_VIEW,{})
        local redPointProxy = self:getProxy(GameProxys.RedPoint)
        redPointProxy:setLegionRichRed()
    end
end
--查看同盟成员采集信息
function ActivityProxy:onTriggerNet230054Resp(data)
    if data.rs == 0 then
        local newData = {}
        newData.id = data.id
        newData.myRank = data.myRank
        newData.myGather = data.myGather
        newData.gatherInfos = data.gatherInfos

        -- print("#gatherInfos = ",#data.gatherInfos)
        -- print("data.myGather = ",data.myGather)

        local isExist = false
        for k,val in pairs(self.legionRichGatherInfos) do
            if val.id == data.id then
                self.legionRichGatherInfos[k] = newData
                isExist = true
            end
        end
        if isExist == false then
            table.insert(self.legionRichGatherInfos, newData)
        end
        self:sendNotification(AppEvent.PROXY_LEGIONRICH_UPDATE_MEMBERVIEW,{})
    end

end


--客户端主动请求
function ActivityProxy:onTriggerNet230055Req(data)
    self:syncNetReq(AppEvent.NET_M23, AppEvent.NET_M23_C230055, data)
end

--服务器主动推送 任务完成
function ActivityProxy:onTriggerNet230055Resp(data)
    -- local a
    -- a = data.activityId
    -- a = data.info.activityId
    -- a = data.info.missionInfos
    -- for k,v in pairs(a) do
    --     local b
    --     b = v.id
    --     b = v.gather
    --     b = v.remainTimes
    -- end
    -- print("activityId = ",data.activityId)
    -- print("LegionRichInfo = ",data.info)
    -- print("LegionRichInfo.activityId = ",data.info.activityId)
    -- print("LegionRichInfo.missionInfos = ",data.info.missionInfos)
    local isExist = false
    for k,val in pairs(self.legionRichInfos) do
        if val.activityId == data.activityId then
            self.legionRichInfos[k] = data.info
            isExist = true
        end
    end
    if isExist == false then
        table.insert(self.legionRichInfos, data.info)
    end
    self:sendNotification(AppEvent.PROXY_LEGIONRICH_UPDATE_VIEW,{})
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:setLegionRichRed()

end
--打开同盟致富活动界面
function ActivityProxy:onTriggerNet230056Resp(data)
    if data.rs == 0 then
        local isExist = false
        for k,val in pairs(self.legionRichInfos) do
            if val.activityId == data.activityId then
                self.legionRichInfos[k] = data.legionRichInfo
                isExist = true
            end
        end
        if isExist == false then
            table.insert(self.legionRichInfos, data.legionRichInfo)
        end
        self:sendNotification(AppEvent.PROXY_LEGIONRICH_UPDATE_VIEW,{})
        local redPointProxy = self:getProxy(GameProxys.RedPoint)
        redPointProxy:setLegionRichRed()
    end
end
function ActivityProxy:goToWorldAndClose()
    self:sendNotification(AppEvent.PROXY_LEGIONRICH_GOTOWORLD,{})
end
function ActivityProxy:closeLegionRichModule()
    self:sendNotification(AppEvent.PROXY_LEGIONRICH_CLOSE_MODULE,{})
end
--===================同盟致富================end



--打开活动界面，通过activityData
--_jumpPanelName 可选
function ActivityProxy:onOpenActivityModule( activityData, _jumpPanelName )
    local moduleName = allModule[ activityData.uitype ]

    self.curActivityData = activityData
    self:setModuleNameData( activityData.activityId, moduleName )

    local openData = {}
    openData.extraMsg = {activityId = activityData.activityId, panelName=_jumpPanelName}
    openData.moduleName = moduleName
    self:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, openData)
end
--关掉所有活动界面
function ActivityProxy:closeAllActivityModule()
    for _, moduleName in pairs( allModule ) do
        self:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = moduleName} )
    end
end


-- 根据powerId取effectInfo， 效果值
function ActivityProxy:getEffectInfo(effectType)
    local activityProxy = self:getProxy(GameProxys.Activity)
    local activityData  = activityProxy:getActivityInfo()
    for key, info in pairs(activityData) do
        if info.effectInfos ~= nil then
            for k, v in pairs(info.effectInfos) do
                if v.effecttype == effectType then
                    return v
                end
            end
        end
    end
    return nil
end

-- 
function ActivityProxy:getEffectValue(effectType)
    local effect = nil
    local effectInfo = self:getEffectInfo(effectType)
    if effectInfo then
        effect = effectInfo.effect
    end
    return effect
end



function ActivityProxy:isFirstCharge()
    -- 1.首冲活动还在
    local allData = self:getActivityInfo()
    for k,v in pairs(allData) do
        if v.uitype == GameActivityModule.UI_TYPE_SHOU_CHONG and v.conditiontype == 101 then
            if v.buttons[1].type == 1 then
                logger:info("-- 1.首冲活动还在 %d",v.buttons[1].type)
                return true 
            end
        end
    end

    -- -- 2.VIP数据还是0
    -- local roleProxy = self:getProxy(GameProxys.Role)
 --    local viplv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel) or 0
 --    local vipexp = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipExp) or 0
    -- if viplv == 0 and vipexp == 0 then
    --  logger:info("-- 2.VIP数据还是0")
    --  return true
    -- end


    logger:info("-- 3.没首冲了")
    return false
end


---[[
--富贵豪庄start

function ActivityProxy:setRichPowerVillageInfos(params)
    for k,v in pairs(params) do
        self.richPowerfulVillageInfo[v.activityId] = v
    end 
end

function ActivityProxy:setRichPowerVillageInfo(info)
    if self.richPowerfulVillageInfo[info.activityId] then
        self.richPowerfulVillageInfo[info.activityId] = info
    end 
end 

function ActivityProxy:getRichPowerVillageInfoById(activityId)
    return self.richPowerfulVillageInfo[activityId]
end

--整理对应富贵豪庄活动的兑换数据
function ActivityProxy:getItemExchangeInfoBy(activityId)
    local info = {}
    local richPowerInfo = self:getRichPowerVillageInfoById(activityId)
    if richPowerInfo then
        local itemExchangeInfo = richPowerInfo.itemInfo
        for k,v in pairs(itemExchangeInfo) do
            info[v.id] = v
        end 
    end 
    return info
end 

--开局或改命
function ActivityProxy:onTriggerNet570000Req(data)
    self.curReqActivityId = data.activityId
    self:syncNetReq(AppEvent.NET_M57, AppEvent.NET_M57_C570000, data)
end

function ActivityProxy:onTriggerNet570000Resp(data)
    --print("onTriggerNet570000Resp",data.rs)
    if data.rs == 0 then
        --更新数据
        self:setRichPowerVillageInfo(data.info)
        self:sendNotification(AppEvent.PROXY_RICH_POWERFUL_START_CHANGE_RESP,data.info)
    end 
end

--确定按钮
function ActivityProxy:onTriggerNet570001Req(data)
    self:syncNetReq(AppEvent.NET_M57, AppEvent.NET_M57_C570001, data)
end

function ActivityProxy:onTriggerNet570001Resp(data)
    --print("onTriggerNet570001Resp",data.rs)
    if data.rs == 0 then 
        self:setRichPowerVillageInfo(data.info)
        self:sendNotification(AppEvent.PROXY_RICH_POWERFUL_COMFIRM_RESP,data.info)
    end 
end

--兑换按钮
function ActivityProxy:onTriggerNet570002Req(data)
    self:syncNetReq(AppEvent.NET_M57, AppEvent.NET_M57_C570002, data)
end

function ActivityProxy:onTriggerNet570002Resp(data)
    --print("onTriggerNet570002Resp",data.rs)
    if data.rs == 0 then 
        self:setRichPowerVillageInfo(data.info)
        self:sendNotification(AppEvent.PROXY_RICH_POWERFUL_EXCAHNGE_RESP,data.info)
    end 
end
--富贵豪庄end
--]]

---[[
--财源广进start
--初始化数据
function ActivityProxy:setGetLotOfMoneyInfos(data)
    for k,v in pairs(data) do
        self.getLotOfMoneyInfo[v.activityId] = v
    end 
end

--零点重置
function ActivityProxy:resetGetLotOfMoney()
    for k,v in pairs(self.getLotOfMoneyInfo) do
        for _,value in pairs(v.lotteryInfo) do
            value.times = 0
        end 
        for _,value in pairs(v.exchangeInfo) do
            value.times = 0
        end 
    end 
end 

function ActivityProxy:getGetLotOfMoneyInfos()
    return self.getLotOfMoneyInfo or {}
end 

--更新数据
function ActivityProxy:updateGetLotOfMoneyInfo(info)
    self.getLotOfMoneyInfo[info.activityId] = info
    self:sendNotification(AppEvent.PROXY_GETLOTOFMONEY_UPDATE,{})
end 

--获取数据
function ActivityProxy:getGetLotOfMoneyInfo(activityId)
    return self.getLotOfMoneyInfo[activityId]
end

--博彩
function ActivityProxy:onTriggerNet600000Req(param)
    --activityId    lotteryId

    self:syncNetReq(AppEvent.NET_M60, AppEvent.NET_M60_C600000, param)
end
function ActivityProxy:onTriggerNet600000Resp(data)
    if data.rs == 0 then
        self:updateGetLotOfMoneyInfo(data.info)
    end
end

--兑换
function ActivityProxy:onTriggerNet600001Req(param)
    --activityId    exchangeId
    self:syncNetReq(AppEvent.NET_M60, AppEvent.NET_M60_C600001, param)
end
function ActivityProxy:onTriggerNet600001Resp(data)
    if data.rs == 0 then
        self:updateGetLotOfMoneyInfo(data.info)
    end 
end
--财源广进end
--]]

---[[
--聚宝盆start
--抽奖
function ActivityProxy:setCornucopiaInfos(data)
    for k,v in pairs(data) do
        self.cornucopiaInfos[v.activityId] = v
    end 
end

function ActivityProxy:getCornucopiaInfos()
    return self.cornucopiaInfos
end 

function ActivityProxy:getCornucopiaInfoById(activityId)
    return self.cornucopiaInfos[activityId]
end

function ActivityProxy:updateCornucopiaInfoById(info)
    self.cornucopiaInfos[info.activityId] = info
    self:sendNotification(AppEvent.PROXY_CORNUCOPIA_UPDATE,{})
    
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:setCornucopiaRed()
end 

--抽奖请求
function ActivityProxy:onTriggerNet610000Req(param)
    self:syncNetReq(AppEvent.NET_M61, AppEvent.NET_M61_C610000, param)
end

--抽奖接口下推
function ActivityProxy:onTriggerNet610000Resp(data)
    if data.rs == 0 then
        self:updateCornucopiaInfoById(data.info)
    end 
end
--聚宝盆end
--]]
