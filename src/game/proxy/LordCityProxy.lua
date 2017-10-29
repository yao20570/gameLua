-- /**
--  * @Author:	  fzw
--  * @DateTime:	2016-11-01 16:06:30
--  * @Description: 城主战数据代理
--  */
LordCityProxy = class("LordCityProxy", BasicProxy)

function LordCityProxy:ctor()
    LordCityProxy.super.ctor(self)
    self.proxyName = GameProxys.LordCity
    self:initData()
    self:testData()
end

function LordCityProxy:resetAttr()
	BuildingProxy.super.resetAttr(self)
    self:initData()
end

function LordCityProxy:initSyncData(data)
    LordCityProxy.super.initSyncData(self, data)
    local citySkillInfos = data.citySkillInfos
    self._skillInfos = citySkillInfos
    -- self:updateSkillInfos(citySkillInfos)
end

function LordCityProxy:initData()
	self._cityInfoMap = {}				--城池列表信息
	self._cityHostMap = {}				--城池详细信息
	-- self._defenderInfoMap = {}			--防守队伍列表
    self._playerDamageRankMap = {}      --积分排行榜(个人)
	self._memberDamageRankMap = {}		--积分排行榜(军团成员)
    self._legionDamageRankMap = {}      --积分排行榜(军团)
	self._voteLegionMap = {}		    --投票军团列表信息
    self._buffInfoMap = {}              --鼓舞等级信息
    self._defenderInfoMap = {}          --防守队伍列表
    self._attackInfoMap = {}            --进攻队伍列表
    self._singleCityReportMap = {}      --个人战报列表
    self._fullCityReportMap = {}        --全服战报列表
    self._playerTeamInfoMap = {}        --查看玩家阵型信息
    self._playerInfoMap = {}            --玩家信息
    self._cityStateMap = {}             --城池的状态 占领状态，攻防转换状态
    self._selectCityId = nil            --记录当前点击的城池id
    self._restBtnState = false          --自动修正勾选状态 默认未选中
    self._isHaveTeam = false            --玩家是否已经设置防守部队 false=未设置 true=已设置
    -- self._isGotRewardMap = {}            --归属城池的每日奖励 0=无奖励 1=未领取 2=已领取
    -- self._voteRewardState = -1           --投票奖励领取按钮状态 -1=未投票 0=未领取 >0=已领取
    self._lordCityTeamUI = false        --是否进攻方打开了布阵界面
    self._isReconnect = false           --是否断线重连
    self._powerInfos = {}               --可参战资格列表
    self._skillInfos = {}               --城主战技能列表

    -- 主城坐标索引
    self._keyMapOfLordCityPlacePos = nil -- 放置索引
    self._keyMapOfLordCityTouchPos = nil -- 点击索引
    self:setKeyMapOfCityBattleCfg()
end



function LordCityProxy:getNumKeyByPos(x, y)
    return x * 10000 + y
end

function LordCityProxy:setKeyMapOfCityBattleCfg()
    self._keyMapOfLordCityPlacePos = { }
    self._keyMapOfLordCityTouchPos = { }

    local cityBattleCfg = ConfigDataManager:getConfigData(ConfigData.CityBattleConfig)
    for k, v in pairs(cityBattleCfg) do
        local ary = StringUtils:jsonDecode(v.cityCoordinate)

        -- 放置坐标索引(第一个默认为放置坐标)
        local key = self:getNumKeyByPos(ary[1][1], ary[1][2])
        self._keyMapOfLordCityPlacePos[key] = v

        -- 点击坐标索引(点击)
        for i = 1, #ary do
            local touchKey = self:getNumKeyByPos(ary[i][1], ary[i][2])
            self._keyMapOfLordCityTouchPos[touchKey] = v
        end
        
    end
end

function LordCityProxy:isLordCityPlacePos(x, y)
    local key = self:getNumKeyByPos(x, y)
    return self._keyMapOfLordCityPlacePos[key] ~= nil
end

function LordCityProxy:getCityBattleCfgDataByTouchPos(x, y)
    local key = self:getNumKeyByPos(x, y)
    return self._keyMapOfLordCityTouchPos[key]
end

------------------------------------------------------------------------------
--城主战 协议
AppEvent.NET_M36 = 36
AppEvent.NET_M36_C360010 = 360010 --城池列表信息
AppEvent.NET_M36_C360011 = 360011 --城池详细信息
AppEvent.NET_M36_C360012 = 360012 --任命副团
AppEvent.NET_M36_C360013 = 360013 --攻城鼓舞升级
AppEvent.NET_M36_C360014 = 360014 --设置防守
AppEvent.NET_M36_C360015 = 360015 --投票
AppEvent.NET_M36_C360016 = 360016 --查看玩家阵型
AppEvent.NET_M36_C360017 = 360017 --投票列表信息
AppEvent.NET_M36_C360018 = 360018 --领取参与投票奖励
AppEvent.NET_M36_C360019 = 360019 --撤回防守
AppEvent.NET_M36_C360020 = 360020 --获得防守队伍列表
AppEvent.NET_M36_C360021 = 360021 --攻打Boss
AppEvent.NET_M36_C360022 = 360022 --攻打城墙
AppEvent.NET_M36_C360023 = 360023 --攻击防守方
AppEvent.NET_M36_C360024 = 360024 --清除休整CD时间
AppEvent.NET_M36_C360025 = 360025 --查看个人战斗列表
AppEvent.NET_M36_C360026 = 360026 --查看全服战斗列表
AppEvent.NET_M36_C360031 = 360031 --领取奖励
AppEvent.NET_M36_C360032 = 360032 --个人积分排行榜
AppEvent.NET_M36_C360033 = 360033 --军团积分排行榜
AppEvent.NET_M36_C360034 = 360034 --军团成员积分排行榜
AppEvent.NET_M36_C360041 = 360041 --鼓舞列表信息
AppEvent.NET_M36_C360042 = 360042 --玩家信息
AppEvent.NET_M36_C360043 = 360043 --推送占领状态更新
AppEvent.NET_M36_C360044 = 360044 --推送防守列表更新
AppEvent.NET_M36_C360045 = 360045 --推送血量变化更新
AppEvent.NET_M36_C360046 = 360046 --有参战资格的同盟列表信息
AppEvent.NET_M36_C360047 = 360047 --任命副团后推送副团团长确认
AppEvent.NET_M36_C360048 = 360048 --副团团长确认被任命结果
AppEvent.NET_M36_C360049 = 360049 --副团团长确认后推送发起者结果
AppEvent.NET_M36_C360050 = 360050 --技能信息更新替换
AppEvent.NET_M36_C360051 = 360051 --使用技能
AppEvent.NET_M36_C360052 = 360052 --奖励小红点
------------------------------------------------------------------------------
--城主战 通知
AppEvent.PROXY_LORDCITY_STATE = "proxy_lordcity_state"              --更新城主站占领状态
AppEvent.PROXY_LORDCITY_VOTEINFO = "proxy_lordcity_voteinfo"        --更新投票列表信息
AppEvent.PROXY_LORDCITY_BUFFUP = "proxy_lordcity_buffup"            --更新鼓舞升级信息
AppEvent.PROXY_LORDCITY_BUFFMAP = "proxy_lordcity_buffmap"          --更新鼓舞列表信息
AppEvent.PROXY_LORDCITY_UPDATE = "proxy_lordcity_update"            --更新城池列表信息
AppEvent.PROXY_LORDCITY_INFO = "proxy_lordcity_info"                --更新城池详细信息
AppEvent.PROXY_LORDCITYRANK_SINGLE = "proxy_lordcityrank_single"    --更新个人排行信息
AppEvent.PROXY_LORDCITYRANK_LEGION = "proxy_lordcityrank_legion"    --更新军团排行信息
AppEvent.PROXY_LORDCITYRECORD_SINGLE = "proxy_lordcityrecord_single"    --更新个人战报信息
AppEvent.PROXY_LORDCITYRECORD_FULL = "proxy_lordcityrecord_full"    --更新全服战报信息
AppEvent.PROXY_LORDCITY_DEFMAP = "proxy_lordcity_defmap"            --更新防守列表信息
AppEvent.PROXY_LORDCITY_VOTEREWARD = "proxy_lordcity_votereward"    --领取投票参与奖励
AppEvent.PROXY_LORDCITY_DEFTEAM = "proxy_lordcity_defteam"          --更新玩家阵型(设置防守、撤回防守)
AppEvent.PROXY_LORDCITY_PLAYERINFOMap = "proxy_lordcity_playerinfoMap"    --更新玩家信息
AppEvent.PROXY_LORDCITY_UPDATESTATE = "proxy_lordcity_updatestate"    --更新城池列表的开启状态
AppEvent.PROXY_LORDCITY_STATECHANGE = "proxy_lordcity_statechange"    --城池占领状态变更推送
AppEvent.PROXY_LORDCITY_REWARDUPDATE = "proxy_lordcity_rewardupdate"  --更新城池奖励宝箱领取状态
AppEvent.PROXY_LORDCITY_360049 = "proxy_lordcity_360049"              --服务端给归属盟主推送任命副盟的结果
AppEvent.PROXY_LORDCITY_QUALIFY = "proxy_lordcity_qualify"            --更新参战资格列表信息
AppEvent.PROXY_LORDCITY_TEAMDIE = "proxy_lordcity_teamdie"            --防守部队被击杀发出通知
AppEvent.PROXY_LORDCITY_SKILL = "proxy_lordcity_skill"                --通知更新技能列表
------------------------------------------------------------------------------
-- 城主战 配表
ConfigData.CityBattleConfig = "CityBattleConfig"    --城主战配置
ConfigData.CityBossConfig = "CityBossConfig"        --城主战boss配置
ConfigData.CityWallConfig = "CityWallConfig"        --城主战城墙配置
ConfigData.CityGuessConfig = "CityGuessConfig"      --城主战投票奖励配置
ConfigData.CityBuffConfig = "CityBuffConfig"        --城池buff配置
ConfigData.InspireConfig = "InspireConfig"          --城主战鼓舞属性配置
ConfigData.CityRewardConfig = "CityRewardConfig"    --城主战奖励相关配置
ConfigData.BuffShowConfig = "BuffShowConfig"        --城主战奖励相关配置
------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- 请求协议
------------------------------------------------------------------------------
-- 城池列表信息
function LordCityProxy:onTriggerNet360010Req(data)
	self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360010, {})
end
-- 城池详细信息
function LordCityProxy:onTriggerNet360011Req(data)
	self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360011, data)
end
-- 任命副团
function LordCityProxy:onTriggerNet360012Req(data)
    self.data360012 = data  
	self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360012, data)
end
-- 攻城鼓舞升级
function LordCityProxy:onTriggerNet360013Req(data)
    self._inspireId = data.inspireId
    self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360013, data)
end
-- 攻城鼓舞列表信息
function LordCityProxy:onTriggerNet360041Req(data)
	self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360041, data)
end
-- 设置防守
function LordCityProxy:onTriggerNet360014Req(data)
    self.data360014 = data
	self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360014, data)
end
-- 投票
function LordCityProxy:onTriggerNet360015Req(data)
    self.data360015 = data
    self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360015, data)
end
-- 
function LordCityProxy:onTriggerNet360016Req(data)
    self.data360016 = data
    self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360016, data)
end
-- 投票列表信息
function LordCityProxy:onTriggerNet360017Req(data)
    self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360017, data)
end
-- 投票参与奖励
function LordCityProxy:onTriggerNet360018Req(data)
    self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360018, data)
end
-- 撤回防守
function LordCityProxy:onTriggerNet360019Req(data)
    self.data360019 = data
    self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360019, data)
end
-- 玩家信息
function LordCityProxy:onTriggerNet360042Req(data)
    self.data360042 = data
	self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360042, data)
end
-----------------------------
-----------------------------
-- 获得防守队伍列表
function LordCityProxy:onTriggerNet360020Req(data)
    self.data360020 = data
    self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360020, data)
end
-- 攻打Boss
function LordCityProxy:onTriggerNet360021Req(data)
    self.data360021 = data
    self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360021, data)
end
-- 攻打城墙
function LordCityProxy:onTriggerNet360022Req(data)
    self.data360022 = data
    self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360022, data)
end
-- 攻击防守方
function LordCityProxy:onTriggerNet360023Req(data)
    self.data360023 = data
    self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360023, data)
end
-- 清除休整CD时间
function LordCityProxy:onTriggerNet360024Req(data)
    self.data360024 = data
	self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360024, data)
end
-- 查看个人战斗列表
function LordCityProxy:onTriggerNet360025Req(data)
	self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360025, data)
end
-- 查看全服战斗列表
function LordCityProxy:onTriggerNet360026Req(data)
    self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360026, data)
end
-- 请求重播战斗记录
function LordCityProxy:onTriggerNet160005Req(data)
    self:syncNetReq(AppEvent.NET_M16, AppEvent.NET_M16_C160005, data)
end

-----------------------------
-----------------------------
-- 领取奖励
function LordCityProxy:onTriggerNet360031Req(data)
    self.data360031 = data
	self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360031, data)
end
-- 个人积分排行榜
function LordCityProxy:onTriggerNet360032Req(data)
	self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360032, data)
end
-- 军团积分排行榜
function LordCityProxy:onTriggerNet360033Req(data)
    self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360033, data)
end
-- 军团成员积分排行榜
function LordCityProxy:onTriggerNet360034Req(data)
    self:syncNetReq(AppEvent.NET_M36,AppEvent.NET_M36_C360034, data)
end
-- 请求可参战资格列表
function LordCityProxy:onTriggerNet360046Req(data)
    self:syncNetReq(AppEvent.NET_M36, AppEvent.NET_M36_C360046, data)
end
-- 副团团长确认是否成为附团
function LordCityProxy:onTriggerNet360048Req(data)
    if data.result == 1 then
        self:showSysMessage(TextWords:getTextWord(370099))
    elseif data.result == 2 then
        self:showSysMessage(TextWords:getTextWord(370098))
    end
    self:syncNetReq(AppEvent.NET_M36, AppEvent.NET_M36_C360048, data)
end

-- function LordCityProxy:onTriggerNet360050Req(data)
--     self:syncNetReq(AppEvent.NET_M36, AppEvent.NET_M36_C360050, data)
-- end

function LordCityProxy:onTriggerNet360051Req(data)
    self:syncNetReq(AppEvent.NET_M36, AppEvent.NET_M36_C360051, data)
end
------------------------------------------------------------------------------
-- 接收协议
------------------------------------------------------------------------------
function LordCityProxy:onTriggerNet360010Resp(data)
    if data.rs == 0 then
        local minInfo = nil
        -- local minTime = nil
    	for _,info in pairs(data.cityInfos) do
            -- print("......城池基本信息 ",info.cityId,info.legionName,info.cityState,info.rewardState)
    		self._cityInfoMap[info.cityId] = info
            
            -- 鉴于城池列表要显示状态倒计时，根据状态请求一下对应的城池详细信息,再请求下参战状态显示
            if info.cityState == 2 or info.cityState == 3 then
                local sendData = {cityId = info.cityId}
                self:onTriggerNet360011Req(sendData)
                self:onTriggerNet360046Req({})
            end

            local tmp = info.startTime - GameConfig.serverTime
            local dt = math.abs(tmp)
            if tmp < 0 then
                tmp = 0
            end
            if minInfo == nil or minInfo.dt > dt then
                minInfo = info
                minInfo.dt = dt
                minInfo.tmp = tmp
            end
            self:setNextOpenRemainTime(info.cityId,0)
        end

        if minInfo then
            self:setNextOpenRemainTime(minInfo.cityId,minInfo.tmp)
        end

        self:sendNotification(AppEvent.PROXY_LORDCITY_UPDATE,{})
    end
end

function LordCityProxy:onTriggerNet360011Resp(data)
    if data.rs == 0 then
        -- print("............. 城池详细信息  ",data.host.cityId, data.host.timeLeft, data.host.prepareTime, data.host.cityState)

        local cityId = data.host.cityId
        local prepareTime = data.host.prepareTime
        local timeLeft = data.host.timeLeft
        local hostLegion = data.host.hostLegion
        local cityState = data.host.cityState
        self._cityHostMap[cityId] = data.host
        self:isSameLegion(cityId)

        if self._cityInfoMap[cityId] then
            self._cityInfoMap[cityId].legionName = hostLegion  --更新城池列表的军团名字
            if cityState == 0 then
                self._cityInfoMap[cityId].cityState = cityState
            elseif prepareTime > 0 then
                self._cityInfoMap[cityId].cityState = 2
            elseif timeLeft > 0 then
                self._cityInfoMap[cityId].cityState = 3
            end
            self:sendNotification(AppEvent.PROXY_LORDCITY_UPDATESTATE,self._cityInfoMap[cityId])  --更新主界面城池的开启状态显示
        end

        self:setBattleReadyRemainTime(cityId, prepareTime)
        self:setBattleRemainTime(cityId, timeLeft)
        self:sendNotification(AppEvent.PROXY_LORDCITY_INFO,{})
    end
end

function LordCityProxy:onTriggerNet360012Resp(data)  --任命附团
    if data.rs == 0 then
        self:showSysMessage(TextWords:getTextWord(370097))  --已发出邀请
    end
end
function LordCityProxy:onTriggerNet360013Resp(data)  --鼓舞升级
    if data.rs == 0 then
        for k,v in pairs(self._buffInfoMap) do
            if v.id == self._inspireId then
                self._buffInfoMap[k].level = v.level + 1  --对应的鼓舞等级+1
                self:sendNotification(AppEvent.PROXY_LORDCITY_BUFFUP,{})
                return
            end
        end
    end
end
function LordCityProxy:onTriggerNet360041Resp(data) --鼓舞列表信息
    if data.rs == 0 then
        self._buffInfoMap = data.infos
        self:sendNotification(AppEvent.PROXY_LORDCITY_BUFFMAP,{})
    end
end
function LordCityProxy:onTriggerNet360014Resp(data)  --设置防守
    if data.rs == 0 then
        self._isHaveTeam = true
        self:showSysMessage(TextWords:getTextWord(370046))
        self._defenderModel = rawget(data,"model")
        self:sendNotification(AppEvent.PROXY_LORDCITY_DEFTEAM,{})
        -- self:onTriggerNet360020Req({cityId = self.data360014.cityId}) --设置成功，请求刷新防守列表，其实服务端直接推送就可以了
        self:onTriggerNet360042Req({cityId = self.data360014.cityId}) --设置成功，请求刷新休整CD，其实服务端直接推送就可以了
    end
end
function LordCityProxy:onTriggerNet360015Resp(data) --投票
    if data.rs == 0 then
        local legionId = self.data360015.legionId
        self._voteLegionId = legionId
        self._voteRewardState = 0

        for k,v in pairs(self._voteLegionMap) do
            if v.legionId == legionId then
                self._voteLegionMap[k].votes = self._voteLegionMap[k].votes + 1  --本地票数+1
            end
        end
        self:sendNotification(AppEvent.PROXY_LORDCITY_VOTEINFO,{})                

    end
end
function LordCityProxy:onTriggerNet360016Resp(data)  --查看玩家阵型
    if data.rs == 0 then
        self._playerTeamInfoMap[self.data360016.playerId] = data.formations
    end
end
function LordCityProxy:onTriggerNet360017Resp(data) --查看投票结果
    if data.rs == 0 then
        self._voteLegionMap = data.voteInfos
        self._voteLegionId = data.voteLegionId
        self._voteRewardState = data.drawVoteTime
        self:sendNotification(AppEvent.PROXY_LORDCITY_VOTEINFO,{})
    end
end
function LordCityProxy:onTriggerNet360018Resp(data)
    if data.rs == 0 then
        self._voteRewardState = 1  --大于0表示已领取
       self:sendNotification(AppEvent.PROXY_LORDCITY_VOTEREWARD,{})
    end
end
function LordCityProxy:onTriggerNet360019Resp(data)  --撤防
    if data.rs == 0 then
        self._teamBackCoolTime = rawget(data,"cd")
        logger:info("..............--撤防成功 ",self._teamBackCoolTime,self.data360019.cityId)
        if self._teamBackCoolTime then
            if self._teamBackCoolTime > 0 then
                self:setRestDefRemainTime(self.data360019.cityId, self._teamBackCoolTime)  --更新防守休整时间
            else
                self:setRestDefRemainTime(self.data360019.cityId, 0)  --更新防守休整时间
            end
        end

        self._isHaveTeam = false
        self:sendNotification(AppEvent.PROXY_LORDCITY_DEFTEAM,{})
        self:removeMyTeam()
        self:sendNotification(AppEvent.PROXY_LORDCITY_DEFMAP,{})

        self:onTriggerNet360042Req({cityId = self.data360019.cityId}) --撤防成功，请求刷新休整CD，其实服务端直接推送就可以了
    end
end
-----------------------------
-----------------------------
function LordCityProxy:onTriggerNet360020Resp(data)  --获取进攻/防守列表
    if data.rs == 0 then
        local roleProxy = self:getProxy(GameProxys.Role)
        local myName = roleProxy:getRoleName()
        local isHaveSelf = false
        local isHaveDie = false
        for k,info in pairs(data.defenderInfoes) do
            if info.name ~= "" and info.name == myName then
                isHaveSelf = true
            end

        end
        self._isHaveTeam = isHaveSelf

        --有防守部队被击杀时，播放全屏特效
        local actionType = rawget(data,"actionType")
        if actionType == 0 then
            self:sendNotification(AppEvent.PROXY_LORDCITY_TEAMDIE,{})
        end

        self._defenderInfoMap = data.defenderInfoes
        self:sendNotification(AppEvent.PROXY_LORDCITY_DEFMAP,{})

    end
end

function LordCityProxy:onTriggerNet360021Resp(data)
    if data.rs == 0 then
        if rawget(data,"cd") then
            -- logger:info("360021 CD 时间 %d ",data.cd)
            self:setRestAttRemainTime(self.data360021.cityId, data.cd)
        end
        if rawget(data,"hpNow") then
            self._cityHostMap[self._selectCityId].bossNowHp = data.hpNow
            self:sendNotification(AppEvent.PROXY_LORDCITY_INFO,{})
        end
    end
end
function LordCityProxy:onTriggerNet360022Resp(data)
    if data.rs == 0 then
        if rawget(data,"cd") then
            -- logger:info("360022 CD 时间 %d ",data.cd)
            self:setRestAttRemainTime(self.data360022.cityId, data.cd)
        end
        if rawget(data,"hpNow") then
            self._cityHostMap[self._selectCityId].wallNowHp = data.hpNow
            self:sendNotification(AppEvent.PROXY_LORDCITY_INFO,{})
        end
    end
end
function LordCityProxy:onTriggerNet360023Resp(data)
    if data.rs == 0 then
        if rawget(data,"cd") then
            -- logger:info("360023 CD 时间 %d ",data.cd)
            self:setRestAttRemainTime(self.data360023.cityId, data.cd)
        end
    end
end
function LordCityProxy:onTriggerNet360024Resp(data) --清除休整CD时间
    if data.rs == 0 then
        local cityId = self.data360024.cityId
        local type = self.data360024.type
        if type == 0 then
            self:setRestAttRemainTime(cityId,0)
        elseif type == 1 then
            self:setRestDefRemainTime(cityId,0)
        end
        self:showSysMessage(TextWords:getTextWord(370057))
    end
end

function LordCityProxy:onTriggerNet360025Resp(data)
    if data.rs == 0 then
        self._singleCityReportMap = data.reports
        self:sendNotification(AppEvent.PROXY_LORDCITYRECORD_SINGLE,{})
    end
end

function LordCityProxy:onTriggerNet360026Resp(data)
    if data.rs == 0 then
        self._fullCityReportMap = data.reports
        self:sendNotification(AppEvent.PROXY_LORDCITYRECORD_FULL,{})
    end
end
-----------------------------
-----------------------------
--归属城池的每日奖励 0=无奖励 1=未领取 2=已领取
function LordCityProxy:onTriggerNet360031Resp(data)  --领取归属城池的每日奖励
    if data.rs == 0 then
        local cityId = self.data360031.cityId
        if self._cityInfoMap[cityId] then
            self._cityInfoMap[cityId].rewardState = 2
            self:sendNotification(AppEvent.PROXY_LORDCITY_REWARDUPDATE,{cityId = cityId, rewardState = 2})
            
        end
        
        -- 领取完奖励更新小红点
        local redPointProxy = self:getProxy(GameProxys.RedPoint)
        local curNum = redPointProxy:getCityBattleRedNum()
        if curNum > 0 then
            curNum = curNum - 1
        end
        redPointProxy:updateCityBattleRedNum(curNum)
    end
end

function LordCityProxy:onTriggerNet360032Resp(data)
    if data.rs == 0 then
    	for _,info in pairs(data.ranks) do
            -- print("......... 个人排名 ",info.rank,info.score,info.times)
            if info.rank <= 0 then
                logger:error("....出现 个人排名 rank = 0")
            else
                self._playerDamageRankMap[info.rank] = info
            end
        end
        self:sendNotification(AppEvent.PROXY_LORDCITYRANK_SINGLE,{})
    end
end

function LordCityProxy:onTriggerNet360033Resp(data)
    if data.rs == 0 then
        for _,info in pairs(data.ranks) do
            -- print("......... 军团排名 ",info.rank,info.score,info.times)
            if info.rank <= 0 then
                logger:error("....出现 军团排名 rank = 0")
            else
                self._legionDamageRankMap[info.rank] = info
            end
        end
        self:sendNotification(AppEvent.PROXY_LORDCITYRANK_LEGION,{})
    end
end

function LordCityProxy:onTriggerNet360034Resp(data)
    if data.rs == 0 then
        for _,info in pairs(data.ranks) do
            -- print("......... 军团成员排名 ",info.rank,info.score,info.times)
            if info.rank <= 0 then
                logger:error("....出现 军团成员排名 rank = 0")
            else
                self._memberDamageRankMap[info.rank] = info
            end
        end
        self:sendNotification(AppEvent.PROXY_LORDCITYRANK_SINGLE,{})
    end
end

function LordCityProxy:onTriggerNet360042Resp(data)  --玩家信息
    if data.rs == 0 then
        if rawget(data,"infos") then
            local cityId = self.data360042.cityId
            local infos = data.infos
            self._playerInfoMap[cityId] = infos
            
            -- print("......玩家信息  ",infos.attackTime,infos.defendTime,infos.rechangeTime,infos.participate)

            local attackTime = infos.attackTime
            if attackTime < 0 then
                attackTime = 0
            end
            local defendTime = infos.defendTime
            if defendTime < 0 then
                defendTime = 0
            end
            local rechangeTime = infos.rechangeTime
            if rechangeTime < 0 then
                rechangeTime = 0
            end
            self:setRestAttRemainTime(cityId, attackTime)
            self:setRestDefRemainTime(cityId, defendTime)
            self:setChangeRemainTime(cityId, rechangeTime)

            local isHaveTeam = rawget(infos,"isSetTeam")
            if isHaveTeam ~= nil then
                self._isHaveTeam = isHaveTeam == 1
            end

            self:sendNotification(AppEvent.PROXY_LORDCITY_PLAYERINFOMap,{})
        end
    end
end

function LordCityProxy:onTriggerNet360043Resp(data)  --城池占领状态变更推送更新
    if data.rs == 0 then
        local rechangeTime = data.rechangeTime
        local cityHost = data.host
        local cityId = cityHost.cityId

        self:isSameLegion(cityId)

        -- print("........360043 攻防切换倒计时",rechangeTime)
        self:setChangeRemainTime(cityId,rechangeTime)
        
        self:onTriggerNet360011Resp(data)
        self:sendNotification(AppEvent.PROXY_LORDCITY_STATECHANGE,{})
    end
end

function LordCityProxy:onTriggerNet360044Resp(data)  --防守列表推送更新
    if data.rs == 0 then
        self:onTriggerNet360020Resp(data)
    end
end

function LordCityProxy:onTriggerNet360045Resp(data)  --城墙血量变化/boss血量变化 推送更新
    if data.rs == 0 then
        local cityId = data.cityId
        -- print("...360045 --城墙血量变化/boss血量变化 推送更新 ",cityId)
        local bossNowHp = data.bossNowHp
        local wallNowHp = data.wallNowHp
        if self._cityHostMap[cityId] then
            self._cityHostMap[cityId].bossNowHp = bossNowHp
            self._cityHostMap[cityId].wallNowHp = wallNowHp
            self:sendNotification(AppEvent.PROXY_LORDCITY_INFO,{})
            self:sendNotification(AppEvent.PROXY_LORDCITY_DEFMAP,{})
        end
    end
end

-- 可参战资格列表信息
function LordCityProxy:onTriggerNet360046Resp(data)
    if data.rs == 0 then
        self._myQualify = data.myQualify
        self._powerInfos = data.infos
        logger:info("360046 資格列表长度 %d",table.size(data.infos))
        self:sendNotification(AppEvent.PROXY_LORDCITY_QUALIFY,{})
    end
end

-- 是否同意成为副盟的弹窗通知
function LordCityProxy:onTriggerNet360047Resp(data)
    local function sendMsg(cityId,result)
        local sendData = {}
        sendData.cityId = cityId
        sendData.result = result
        self:onTriggerNet360048Req(sendData)
    end
    -- 接受
    local function yesCallback()
        sendMsg(data.cityId,1)
    end
    -- 拒绝
    local function noCallback()
        sendMsg(data.cityId,2)
    end

    local content = TextWords:getTextWord(392)
    content = string.format(content,data.legionName)
    local yesTxt = TextWords:getTextWord(395)
    local noTxt = TextWords:getTextWord(396)
    self:showMessageBox(content,yesCallback,noCallback,yesTxt,noTxt)
end

-- 副盟操作弹窗的返回结果
function LordCityProxy:onTriggerNet360048Resp(data)
end

-- 主盟收到副盟操作结果的推送
function LordCityProxy:onTriggerNet360049Resp(data)
    local content = nil
    if data.result == 1 then  --副盟同意了
        self:sendNotification(AppEvent.PROXY_LORDCITY_360049,data)  --通知军团列表更新显示
        content = string.format(TextWords:getTextWord(393),data.legionName)
    elseif data.result == 2 then  --副盟拒接了
        content = string.format(TextWords:getTextWord(394),data.legionName)
    else
        return
    end
    self:showSysMessage(content)
end

function LordCityProxy:onTriggerNet360050Resp(data)
    if data.rs == 0 then
        self._skillInfos = data.skillInfos
        self:sendNotification(AppEvent.PROXY_LORDCITY_SKILL,data)  --通知技能列表更新显示
    end
end

function LordCityProxy:onTriggerNet360051Resp(data)
    if data.rs == 0 then
        for k,v in pairs(self._skillInfos) do
            if v.typeId == data.typeId then
                self._skillInfos[k].leesNum = self._skillInfos[k].leesNum - 1
                break
            end
        end
        -- print("使用技能成功 ",data.typeId,self._skillInfos[data.typeId].leesNum)
        self:sendNotification(AppEvent.PROXY_LORDCITY_SKILL,data)  --通知技能列表更新显示        
    end
end

function LordCityProxy:onTriggerNet360052Resp(data)
    if data.rewardNum then
        logger:info("360052 城主战 小红点！~~~%d",data.rewardNum)
        local redPointProxy = self:getProxy(GameProxys.RedPoint)
        redPointProxy:updateCityBattleRedNum(data.rewardNum)
    end
end

------------------------------------------------------------------------------
--[[
stateType:
    1>>  xx占领XX
    2>>  xx占领XX 倒计时 xx
    3>>  xx被抢夺，即将切换到进攻方 倒计时 xx
    4>>  恭喜XX获得XX归属权
    5>>  xx未被占领
    6>>  提示设置防守阵型
    7>>  占领成功，提示设置防守阵型 倒计时 xx
]]
--[[
stateType:
    0>>  有boss (初始)
    1>>  他占领 (初始)
    2>>  我占领 (初始)
    3>>  占领成功  转换1>3>2
    4>>  被抢夺    转换2>4>1
    5>>  获得归属  转换2>5
    6>>  无人占领  转换6>0
    7>>  
]]
function LordCityProxy:setCityState(cityId,stateType)  --缓存城池争夺状态
    -- self._cityStateMap[cityId] = stateType
end

function LordCityProxy:getCityState(cityId)  --获取城池争夺状态
    -- return self._cityStateMap[cityId]
end

function LordCityProxy:updateCityState(data)  --更新城池的占领状态/攻防转换状态等
    -- local state = self:getCityState(cityId)
    -- self:setCityState(cityId,stateType)
end

------------------------------------------------------------------------------
-- 实例变量
------------------------------------------------------------------------------
-- 撤回防守 本地删除自己的防守信息
function LordCityProxy:removeMyTeam()
    local roleProxy = self:getProxy(GameProxys.Role)
    local myName = roleProxy:getRoleName()
    for k,team in pairs(self._defenderInfoMap) do
        if team.name == myName then
            self._defenderInfoMap[k] = nil
            return
        end
    end
end

function LordCityProxy:getIsCanSetChildLegion(cityId)  --是否有权限设置附团 true=有权限，false=没有权限
    local isCanSet = false
    local roleProxy = self:getProxy(GameProxys.Role)
    local myRoleName = roleProxy:getRoleName()
    local cityHost = self:getCityHostById(cityId)
    if cityHost.hostCommander ~= "" and cityHost.hostCommander == myRoleName then
        isCanSet = true
    end

    return isCanSet
end

-- 同个军团占领城池多了，带兵量会有削弱效果
function LordCityProxy:updateCommand(teamInfo)    
    local curPercent = self:getCommandPercentAfterSub()
    if curPercent == nil or curPercent == 100 or curPercent < 0 then
        -- logger:info(" 没有削弱效果 直接返回！！ ")
        return teamInfo
    end

    teamInfo = clone(teamInfo)
    for k,v in pairs(teamInfo) do
        if v.typeid ~= 0 and v.post ~= 9 then
            -- logger:info("削弱效果before : %d %d %d %d",v.post, v.typeid, v.num, curPercent)
            v.num = math.floor(v.num * curPercent / 100)
            -- logger:info("削弱效果after : %d %d %d %d",v.post, v.typeid, v.num, curPercent)
        end
    end

    return teamInfo
end

-- 计算是否会削弱，以及已占领城池数量
function LordCityProxy:isNeedSubCommand(curLV)
    local isNeedSub = nil  --是否需要削弱
    local maxLV = 0  --已占领城池最高等级
    local sameCount = 0  --同个军团已占领城池数量
    local roleProxy = self:getProxy(GameProxys.Role)
    local myLegionName = roleProxy:getLegionName()

    for k,v in pairs(self._cityInfoMap) do
        if v.legionName == myLegionName then
            sameCount = sameCount + 1
            local cityConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.CityBattleConfig, "ID", v.cityId)
            if maxLV < cityConfig.level then
                maxLV = cityConfig.level
            end
        end
    end

    -- 攻打城池等級大于已占领城池最高等级，不用削弱
    -- 已占领城池数量为0，不用削弱
    if curLV > maxLV or sameCount == 0 then
        isNeedSub = false
    else
        isNeedSub = true
    end
    return isNeedSub, sameCount
end

-- 同个军团占领城池多了，削弱之后每个坑位剩余百分比带兵量
function LordCityProxy:getCommandPercentAfterSub()
    local curPercent = 100
    local cityId = self:getSelectCityId()
    local cityConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.CityBattleConfig,"ID",cityId)
    local isNeedSub,sameCount = self:isNeedSubCommand(cityConfig.level)

    if isNeedSub ~= true then
        return curPercent  --不需要削弱，返回100%
    end
    
    if sameCount == 1 then
        curPercent = curPercent - cityConfig.firstDebuff
    elseif sameCount == 2 then
        curPercent = curPercent - cityConfig.secondDebuff
    elseif sameCount == 3 then
        curPercent = curPercent - cityConfig.thirdDebuff
    end

    return curPercent
end

-- 标记城主战进攻方打开了布阵界面
function LordCityProxy:setLordCityTeamUI(state)
    self._lordCityTeamUI = state
end

-- 获取是否打开了城主战的布阵界面（默认false），是的话要校验是否削弱带兵量
function LordCityProxy:isLordCityTeamUI()
    return self._lordCityTeamUI
end

-- 判定攻防状态  返回值stateType：1=显示进攻方，2=显示防守方
function LordCityProxy:getCityState()
    local roleProxy = self:getProxy(GameProxys.Role)
    local selfLegionName = roleProxy:getLegionName()
    local cityId = self:getSelectCityId()
    local cityHost = self:getCityHostById(cityId)
    
    local stateType
    if selfLegionName == cityHost.hostLegion then
        stateType = 2  --城池属于己方军团，提示防守
    else
        stateType = 1  --城池不属于己方军团，提示进攻
    end
    return stateType
end
------------------------------------------------------------------------------
-- 公共接口
------------------------------------------------------------------------------
-- 获取城池列表 --下标是cityId
function LordCityProxy:getCityInfoMap()
    return self._cityInfoMap
end
-- 根据城池id获取城池信息
function LordCityProxy:getCityInfoById(cityId)
    return self._cityInfoMap[cityId]
end
 
-- 获取全部城池详细信息
function LordCityProxy:getCityHostMap()
    return self._cityHostMap
end
 
-- 获取城池详细信息
function LordCityProxy:getCityHostById(cityId)
    return self._cityHostMap[cityId]
end

-- 获得防守队伍列表 --下标是id
function LordCityProxy:getDefenderInfoMap()
    return self._defenderInfoMap
end

-- 根据id获取防守队伍信息
function LordCityProxy:getDefenderInfoById(id)
    return self._defenderInfoMap[id]
end

-- 获得进攻队伍列表 --下标是id
function LordCityProxy:getAttackInfoMap()
    return self._attackInfoMap
end

-- 根据id获取进攻队伍信息
function LordCityProxy:getDefenderInfoById(id)
    return self._attackInfoMap[id]
end


-- 积分排行榜(个人)  --下标是排名
function LordCityProxy:getPlayerDamageRankMap()
    return self._playerDamageRankMap
end

-- 积分排行榜(军团成员)  --下标是排名
function LordCityProxy:getMemberDamageRankMap()
    return self._memberDamageRankMap
end

-- 积分排行榜(军团) --下标是排名
function LordCityProxy:getLegionDamageRankMap()
    return self._legionDamageRankMap
end

-- 个人战报
function LordCityProxy:getSingleCityReportMap()
    return self._singleCityReportMap
end

-- 全服战报
function LordCityProxy:getFullCityReportMap()
    return self._fullCityReportMap
end

-- 缓存当前点击的城池的id
function LordCityProxy:setSelectCityId(cityId)
    self._selectCityId = cityId
end

-- 获取当前点击的城池的id
function LordCityProxy:getSelectCityId()
    return self._selectCityId
end

-- 获取已投票的军团id 
function LordCityProxy:getVoteLegionId()
    return self._voteLegionId
end

-- 获取投票军团列表 --下标是legionId
function LordCityProxy:getVoteLegionMap()
    return self._voteLegionMap
end

-- 根据军团id获取投票军团信息
function LordCityProxy:getVoteLegionById(legionId)
    return self._voteLegionMap[legionId]
end

-- 获取鼓舞信息
function LordCityProxy:getBuffInfoMap()
    return self._buffInfoMap
end

-- 获取鼓舞信息
function LordCityProxy:getBuffInfoById(id)
    for _,v in pairs(self._buffInfoMap) do
        if v.id == id then
            return v
        end
    end
    return nil
end


-- -- 获取城池缩放比例
-- function LordCityProxy:getCityScaleById(cityId)
--     return self._cityScaleMap[cityId] or 1
-- end

-- 获取投票奖励领取状态 0=可领取 >0 已领取
function LordCityProxy:getVoteRewardState()
    return self._voteRewardState
end

function LordCityProxy:getPlayerTeamInfoMap()  --获取全部玩家的阵型信息
    return self._playerTeamInfoMap
end

function LordCityProxy:getPlayerTeamInfo(playerId)  --获取玩家的阵型信息
    return self._playerTeamInfoMap[playerId]
end

function LordCityProxy:getIsHaveTeam()  --获取玩家是否设置了防守阵型 true=已设置 false=未设置
    return self._isHaveTeam
end

function LordCityProxy:getPlayerInfoMap()  --获取玩家信息
    return self._playerInfoMap
end
function LordCityProxy:getPlayerInfo(cityId)  --获取玩家信息
    return self._playerInfoMap[cityId]
end

function LordCityProxy:setChildLegion(cityId)  --任命附团的信息
    self._isSetChildLegion = true  --任命标记
    self._setChildCityId = cityId  --城池id
    self:isSameLegion(cityId)
end

function LordCityProxy:clearChildLegion()
    self._isSetChildLegion = false  --任命标记清除
end

-- 城主占领军团判定： --false=不是自己的军团占领,true=是自己的军团占领
function LordCityProxy:isSameLegion(cityId)
    local cityHost = self:getCityHostById(cityId)
    self._hostLegion = cityHost.hostLegion
end

function LordCityProxy:isSetChildLegion()  --任命附团
    return self._isSetChildLegion,self._setChildCityId,self._hostLegion
end

function LordCityProxy:getPowerInfos()  --获取参战资格数据
    return self._powerInfos
end

function LordCityProxy:getMyQualify()  --获取我的参战资格，0=不可参战，1=可参战
    return self._myQualify
end

function LordCityProxy:getSkillInfos()  --获取技能列表
    -- return TableUtils:map2list(self._skillInfos)
    return self._skillInfos
end

-- 判定玩家自身是否被施放了技能
function LordCityProxy:isHaveCitySkillBuff()
    local itemBuffProxy = self:getProxy(GameProxys.ItemBuff)
    local bufferInfos  = itemBuffProxy:getItemBuffInfos()
    local bufferIds = itemBuffProxy:getBufferShowIds()

    local config = ConfigDataManager:getConfigData(ConfigData.CityBattleSkillConfig)

    for _,v in pairs(bufferInfos) do
        if v.buffType == 1 then --技能是全服Buff
            for _, i in pairs(config) do
                local buff = StringUtils:jsonDecode(i.buff)
                for _,id in pairs(buff) do
                    if v.itemId == id and v.remainTime > 0 then
                        return true
                    end
                end
            end
        end
    end

    return false
end


------------------------------------------------------------------------------
-- 世界地图城池显示用，获取城池状态和倒计时
function LordCityProxy:getCityStateAndTime(cityId)
    local state = 2  --准备中
    local remainTime = 0 --默认值
    remainTime = self:getBattleReadyRemainTime(cityId)

    local configInfo = ConfigDataManager:getConfigById(ConfigData.CityBattleConfig, cityId)
    if remainTime > configInfo.beginTime then
        state = 0  --未开启
    else
        if remainTime <= 0 then  --非准备阶段
            state = 3  --争夺中
            remainTime = self:getBattleRemainTime(cityId)
        end
        if remainTime <= 0 then  --非争夺阶段阶段
            state = 0  --未开启
        end
    end

    return state,remainTime
end

------------------------------------------------------------------------------
function LordCityProxy:setIsReconnect(state)
    self._isReconnect = state
end

function LordCityProxy:getIsReconnect()
    return self._isReconnect
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- 定时器数据接口
------------------------------------------------------------------------------
--[[
LORDCITYKEY:
    0 >> 争夺剩余时间
    1 >> 休整倒计时进攻方
    2 >> 休整倒计时防守方
    3 >> 切换到进攻方倒计时
    4 >> 切换到防守方倒计时
    5 >> 争夺准备时间
    6 >> 攻防切换时间
    7 >> 下次开启时间
]]
LORDCITYKEY = {}
LORDCITYKEY.TYPE0 = 0
LORDCITYKEY.TYPE1 = 1
LORDCITYKEY.TYPE2 = 2
LORDCITYKEY.TYPE3 = 3
LORDCITYKEY.TYPE4 = 4
LORDCITYKEY.TYPE5 = 5
LORDCITYKEY.TYPE6 = 6
LORDCITYKEY.TYPE7 = 7

-- 更新某个定时器
function LordCityProxy:updateRemainTime(keyType, cityId, remainTime)
    local key = self:getTimeKey(keyType, cityId)
    -- print("更新定时器 ···key,power,cmd", key, cityId) --TODO 调试信息

    local sendData = {}
    sendData.keyType = keyType
    sendData.key = key
    sendData.cityId = cityId

    self:pushRemainTime(key, remainTime, AppEvent.NET_M36_C360011, sendData, self.completeCallFunc)
    -- self:pushRemainTime(key, remainTime)
end

-- 定时器为零时回调
function LordCityProxy:completeCallFunc(sendDataList)
    for _,sendData in pairs(sendDataList) do
        local keyType = sendData.keyType
        local key = sendData.key
        local cityId = sendData.cityId
        if keyType == LORDCITYKEY.TYPE0         --争夺剩余时间到0
        or keyType == LORDCITYKEY.TYPE5         --争夺准备时间到0
        or keyType == LORDCITYKEY.TYPE7 then    --下次开启时间到0
            logger:info("-- 定时器为零时回调 %s",key)
            self:onTriggerNet360011Req({cityId = cityId})
        end
        if keyType == LORDCITYKEY.TYPE7 then    --下次开启时间到0,刷新参战资格状态
           self:onTriggerNet360046Req({})
        end
        self:pushRemainTime(key,0)

        if keyType == LORDCITYKEY.TYPE0 then         --争夺剩余时间到0
            -- 切换到进攻方倒计时
            -- 切换到防守方倒计时
            logger:info("-- 定时器为零时回调 清除攻防CD  %s %d",key,cityId)
            self:setChangeRemainTime(cityId, 0)

            -- 活动结束，清除上次阵型
            local soldierProxy = self:getProxy(GameProxys.Soldier)
            if soldierProxy:isNeedResetAttackTeam() == true then
                soldierProxy:resetLordCityAttackTeam()
            end
        end
    end
end

function LordCityProxy:getTimeKey(keyType,cityId)
    return "LORDCITY_KEY_"..keyType.."_"..cityId
end

-- 获取倒计时
function LordCityProxy:getRemainTimeByKeyAndId(keyType, cityId)
    local key = self:getTimeKey(keyType, cityId)
    local remainTime = self:getRemainTime(key)
    return remainTime
end
---------------------------------------获取时间
-- 争夺剩余时间
function LordCityProxy:getBattleRemainTime(cityId)
    local remainTime = self:getRemainTimeByKeyAndId(LORDCITYKEY.TYPE0, cityId)
    return remainTime
end
-- 休整倒计时进攻方
function LordCityProxy:getRestAttRemainTime(cityId)
    local remainTime = self:getRemainTimeByKeyAndId(LORDCITYKEY.TYPE1, cityId)
    return remainTime
end
-- 休整倒计时防守方
function LordCityProxy:getRestDefRemainTime(cityId)
    local remainTime = self:getRemainTimeByKeyAndId(LORDCITYKEY.TYPE2, cityId)
    return remainTime
end
-- 切换到进攻方倒计时
function LordCityProxy:getChangeAttRemainTime(cityId)
    local remainTime = self:getRemainTimeByKeyAndId(LORDCITYKEY.TYPE3, cityId)
    return remainTime
end
-- 切换到防守方倒计时
function LordCityProxy:getChangeDefRemainTime(cityId)
    local remainTime = self:getRemainTimeByKeyAndId(LORDCITYKEY.TYPE4, cityId)
    return remainTime
end
-- 争夺准备时间
function LordCityProxy:getBattleReadyRemainTime(cityId)
    local remainTime = self:getRemainTimeByKeyAndId(LORDCITYKEY.TYPE5, cityId)
    return remainTime
end
-- 攻防切换时间
function LordCityProxy:getChangeRemainTime(cityId)
    local remainTime = self:getRemainTimeByKeyAndId(LORDCITYKEY.TYPE6, cityId)
    return remainTime
end
-- 下次开启时间
function LordCityProxy:getNextOpenRemainTime(cityId)
    local remainTime = self:getRemainTimeByKeyAndId(LORDCITYKEY.TYPE7, cityId)
    return remainTime
end
---------------------------------------更新时间
-- 争夺剩余时间
function LordCityProxy:setBattleRemainTime(cityId, remainTime)
    self:updateRemainTime(LORDCITYKEY.TYPE0, cityId, remainTime)
end
-- 休整倒计时进攻方
function LordCityProxy:setRestAttRemainTime(cityId, remainTime)
    self:updateRemainTime(LORDCITYKEY.TYPE1, cityId, remainTime)
end
-- 休整倒计时防守方
function LordCityProxy:setRestDefRemainTime(cityId, remainTime)
    self:updateRemainTime(LORDCITYKEY.TYPE2, cityId, remainTime)
end
-- 切换到进攻方倒计时
function LordCityProxy:setChangeAttRemainTime(cityId, remainTime)
    self:updateRemainTime(LORDCITYKEY.TYPE3, cityId, remainTime)
end
-- 切换到防守方倒计时
function LordCityProxy:setChangeDefRemainTime(cityId, remainTime)
    self:updateRemainTime(LORDCITYKEY.TYPE4, cityId, remainTime)
end
-- 争夺准备时间
function LordCityProxy:setBattleReadyRemainTime(cityId, remainTime)
    self:updateRemainTime(LORDCITYKEY.TYPE5, cityId, remainTime)
end
-- 攻防切换倒计时
function LordCityProxy:setChangeRemainTime(cityId, remainTime)
    self:updateRemainTime(LORDCITYKEY.TYPE6, cityId, remainTime)
end
-- 下次开启时间
function LordCityProxy:setNextOpenRemainTime(cityId, remainTime)
    self:updateRemainTime(LORDCITYKEY.TYPE7, cityId, remainTime)
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- 自测数据
function LordCityProxy:testData()

    -- self._cityScaleMap = {0.8,0.6,0.8,0.6}  --城池缩放比例  因为城池大小不统一

    -- //城池信息
    -- message CityInfo{
    --     required int32  cityId=1;       //主城Id
    --     required string cityName=2;     //主城名字
    --     required string legionName=3;   //占据该主城的军团名字
    --     required int32  cityState=4;    //主城状态 0：未攻占 1：已攻占
    --     required int32  startTime=5;    //下次争夺时间
    -- }

    self._cityInfoMap = {}
    -- self._cityInfoMap[1] = {cityId = 1,cityName = "城池1",legionName = "",cityState = 0, startTime = 1200}
    -- self._cityInfoMap[2] = {cityId = 2,cityName = "城池2",legionName = "",cityState = 0, startTime = 1200}
    -- self._cityInfoMap[3] = {cityId = 3,cityName = "城池3",legionName = "",cityState = 0, startTime = 1200}
    -- self._cityInfoMap[4] = {cityId = 4,cityName = "城池4",legionName = "",cityState = 0, startTime = 1200}


    -- //城主信息
    -- message CityHost{
    --     required int32  cityId=1;           //主城Id
    --     required string hostLegion=2;       //军团名字
    --     required string hostCommander=3;    //军团长名字
    --     required string viceLegion=4;       //附属军团名字
    --     required string viceCommander=5;    //附属军团长名字
    --     required int32  additionBuff=6;     //占领该城池后获得的加成
    --     required int32  prepareTime=7;      //下次争夺准备时间
    --     required int32  startTime=8;        //下次争夺开始时间
    --     required int64 bossMaxHp=9;         //BOSS最大血量
    --     required int64 bossNowHp=10;        //BOSS当前血量（0：BOSS死亡）
    --     required int64 wallMaxHp=11;        //城墙原始血量
    --     required int64 wallNowHp=12;        //城墙当前血量（0：城墙推倒）
    -- }

    self._cityHostMap = {}
    -- self._cityHostMap[1] = {
    --     cityId = 1, 
    --     hostLegion = "军团A", 
    --     hostCommander = "团长A", 
    --     viceLegion = "附团a", 
    --     viceCommander = "附团长a", 
    --     additionBuff = 50,
    --     prepareTime = 123,
    --     startTime = 456,
    --     bossMaxHp = 200000,
    --     bossNowHp = 200000,
    --     wallMaxHp = 100000,
    --     wallNowHp = 100000,
    --     cityState = 0
    -- }


    -- //投票结果列表
    -- message VoteInfo{
    --     required string legionName=1;   //军团名称
    --     required int64 capacity=2;      //战力
    --     required int32 votes=3;         //票数
    --     required int32 voted=4;         //是否已投票，0：已投票，1：已投票;
    -- }

    -- 投票
    self._voteLegionId = 2
    self._voteLegionMap = {}
    -- self._voteLegionMap[1] = {legionId = 1, legionName = "军团00001", votes = 1001, capacity = 1203456}
    -- self._voteLegionMap[2] = {legionId = 2, legionName = "军团00002", votes = 1002, capacity = 1203456}
    -- self._voteLegionMap[3] = {legionId = 3, legionName = "军团00003", votes = 1003, capacity = 1203456}
    -- self._voteLegionMap[4] = {legionId = 4, legionName = "军团00004", votes = 1004, capacity = 1203456}
    -- self._voteLegionMap[5] = {legionId = 5, legionName = "军团00005", votes = 1005, capacity = 1203456}
    -- self._voteLegionMap[6] = {legionId = 6, legionName = "军团00006", votes = 1006, capacity = 1203456}
    -- self._voteLegionMap[7] = {legionId = 7, legionName = "军团00007", votes = 1007, capacity = 1203456}


    -- 鼓舞等级信息 暂缺协议
    self._buffInfoMap = {}
    -- self._buffInfoMap[1] = {id = 1, level = 0}
    -- self._buffInfoMap[2] = {id = 2, level = 0}
    -- self._buffInfoMap[3] = {id = 3, level = 0}

    -- //防守队伍
    -- message DefenderInfo{
    --     required int32 type=1;      //防守类型 1:BOSS，2：敌军  3：城墙
    --     required int64 id=2;        //ID
    --     required string name=3;     //名称（BOSS名称，敌方军团名称，城墙）
    --     required int32 level=4;     //等级
    --     required int32 icon=5;      //图标
    --     required int64 capacity=6;  //战斗力
    --     required int64 hp=7;        //血量 (城墙)
    --     required int64 hpMax=8;     //血量上限(城墙)
    -- }

    -- 防守队伍列表信息
    self._defenderInfoMap = {}
    -- self._defenderInfoMap[1] = {type = 1, id = 1, name = "我是防守者01", level = 1, icon = 2, capacity = 343423, hp = 23232, hpMax = 55555}
    -- self._defenderInfoMap[2] = {type = 1, id = 2, name = "我是防守者02", level = 2, icon = 2, capacity = 343423, hp = 23232, hpMax = 55555}
    -- self._defenderInfoMap[3] = {type = 1, id = 3, name = "我是防守者03", level = 3, icon = 3, capacity = 343423, hp = 23232, hpMax = 55555}
    -- self._defenderInfoMap[4] = {type = 1, id = 4, name = "我是防守者04", level = 4, icon = 4, capacity = 343423, hp = 23232, hpMax = 55555}
    -- self._defenderInfoMap[5] = {type = 1, id = 5, name = "我是防守者05", level = 5, icon = 5, capacity = 343423, hp = 23232, hpMax = 55555}

    -- 进攻队伍列表信息
    self._attackInfoMap = {}
    -- self._attackInfoMap[1] = {type = 1, id = 1, name = "我是进攻者01", level = 10, icon = 2, capacity = 3423, hp = 2032, hpMax = 6555}
    -- self._attackInfoMap[2] = {type = 1, id = 2, name = "我是进攻者02", level = 20, icon = 2, capacity = 3423, hp = 2032, hpMax = 6555}
    -- self._attackInfoMap[3] = {type = 1, id = 3, name = "我是进攻者03", level = 30, icon = 3, capacity = 3423, hp = 2032, hpMax = 6555}
    -- self._attackInfoMap[4] = {type = 1, id = 4, name = "我是进攻者04", level = 40, icon = 4, capacity = 3423, hp = 2032, hpMax = 6555}
    -- self._attackInfoMap[5] = {type = 1, id = 5, name = "我是进攻者05", level = 50, icon = 5, capacity = 3423, hp = 2032, hpMax = 6555}


------------------------------------------------------------------------------
-- 战斗记录
------------------------------------------------------------------------------
    -- //城主战报
    -- message CityReport{
    --     required int32 cityId=1;                //主城Id
    --     required int32 type=2;                  //战报类型1：BOSS 2：守军 3:城墙
    --     required int32 time=3;                  //时间(秒）
    --     required string attackerName=4;         //进攻击Id
    --     required string attackerLegionName=5;   //进攻击军团
    --     required string defenderName=6;         //防守者Id（BOSS，守军 城墙）
    --     required string defenderLegionName=7;   //防守者军团
    --     required int32 result=8;                //攻击方战斗结果（0：进攻方失败 1:进攻方胜利）
    --     required int64 battleId=9;              //战斗数据Id
    -- }
    -- 个人战报
    self._singleCityReportMap = {}
    -- self._singleCityReportMap[1] = {cityId = 1, type = 1, time = 2001, attackerName = "进攻方名字A1", attackerLegionName = "军团名字A1", defenderName = "防守方01", defenderLegionName = "军团名字11", result = 0, battleId = 1}
    -- self._singleCityReportMap[2] = {cityId = 1, type = 1, time = 2002, attackerName = "进攻方名字A2", attackerLegionName = "军团名字A2", defenderName = "防守方02", defenderLegionName = "军团名字12", result = 1, battleId = 1}
    -- self._singleCityReportMap[3] = {cityId = 1, type = 1, time = 2003, attackerName = "进攻方名字A3", attackerLegionName = "军团名字A3", defenderName = "防守方03", defenderLegionName = "军团名字13", result = 1, battleId = 1}
    -- self._singleCityReportMap[4] = {cityId = 1, type = 1, time = 2004, attackerName = "进攻方名字A4", attackerLegionName = "军团名字A4", defenderName = "防守方04", defenderLegionName = "军团名字14", result = 0, battleId = 1}
    -- self._singleCityReportMap[5] = {cityId = 1, type = 1, time = 2005, attackerName = "进攻方名字A5", attackerLegionName = "军团名字A5", defenderName = "防守方05", defenderLegionName = "军团名字15", result = 0, battleId = 1}

    -- 全服战报
    self._fullCityReportMap = {}
    -- self._fullCityReportMap[1] = {cityId = 1, type = 1, time = 2001, attackerName = "进攻方名字B1", attackerLegionName = "军团名字B1", defenderName = "防守方01", defenderLegionName = "军团名字11", result = 0, battleId = 1}
    -- self._fullCityReportMap[2] = {cityId = 1, type = 1, time = 2002, attackerName = "进攻方名字B2", attackerLegionName = "军团名字B2", defenderName = "防守方02", defenderLegionName = "军团名字12", result = 1, battleId = 1}
    -- self._fullCityReportMap[3] = {cityId = 1, type = 1, time = 2003, attackerName = "进攻方名字B3", attackerLegionName = "军团名字B3", defenderName = "防守方03", defenderLegionName = "军团名字13", result = 1, battleId = 1}
    -- self._fullCityReportMap[4] = {cityId = 1, type = 1, time = 2004, attackerName = "进攻方名字B4", attackerLegionName = "军团名字B4", defenderName = "防守方04", defenderLegionName = "军团名字14", result = 0, battleId = 1}
    -- self._fullCityReportMap[5] = {cityId = 1, type = 1, time = 2005, attackerName = "进攻方名字B5", attackerLegionName = "军团名字B5", defenderName = "防守方05", defenderLegionName = "军团名字15", result = 0, battleId = 1}


------------------------------------------------------------------------------
-- 攻城排行
------------------------------------------------------------------------------
    -- //积分排行榜(个人)
    -- message PlayerDamageRank{ 
    --     required int32      rank=1;     //排名
    --     required fixed64    playerId=2; //玩家Id
    --     required string     name=3;     //角色名
    --     optional int32      level=4;    //玩家等级
    --     required int64      score=5;    //积分值（伤害损兵计算） 
    -- }
    -- //积分排行榜(个人)
    self._playerDamageRankMap = {}
    -- self._playerDamageRankMap[1] = {rank = 1, playerId = 1, name = "角色名字1", level = 1, score = 1001}
    -- self._playerDamageRankMap[2] = {rank = 2, playerId = 2, name = "角色名字2", level = 2, score = 1002}
    -- self._playerDamageRankMap[3] = {rank = 3, playerId = 3, name = "角色名字3", level = 3, score = 1003}
    -- self._playerDamageRankMap[4] = {rank = 4, playerId = 4, name = "角色名字4", level = 4, score = 1004}
    -- self._playerDamageRankMap[5] = {rank = 5, playerId = 5, name = "角色名字5", level = 5, score = 1005}
    -- self._playerDamageRankMap[6] = {rank = 6, playerId = 6, name = "角色名字6", level = 6, score = 1006}
    -- self._playerDamageRankMap[7] = {rank = 7, playerId = 7, name = "角色名字7", level = 7, score = 1007}
    -- self._playerDamageRankMap[8] = {rank = 8, playerId = 8, name = "角色名字8", level = 8, score = 1008}

    -- //积分排行榜(军团)
    -- message LegionDamageRank{ 
    --     required int32      rank=1;     //排名
    --     required fixed64    legionId=2; //军团Id
    --     required string     name=3;     //军团名
    --     optional int32      level=4;    //军团等级
    --     required int64      score=5;    //积分值（伤害损兵计算）
    -- }
    -- //积分排行榜(军团)
    self._legionDamageRankMap = {}
    -- self._legionDamageRankMap[1] = {rank = 1, legionId = 1, name = "军团名字1", level = 1, score = 1001}
    -- self._legionDamageRankMap[2] = {rank = 2, legionId = 2, name = "军团名字2", level = 2, score = 1002}
    -- self._legionDamageRankMap[3] = {rank = 3, legionId = 3, name = "军团名字3", level = 3, score = 1003}
    -- self._legionDamageRankMap[4] = {rank = 4, legionId = 4, name = "军团名字4", level = 4, score = 1004}
    -- self._legionDamageRankMap[5] = {rank = 5, legionId = 5, name = "军团名字5", level = 5, score = 1005}
    -- self._legionDamageRankMap[6] = {rank = 6, legionId = 6, name = "军团名字6", level = 6, score = 1006}
    -- self._legionDamageRankMap[7] = {rank = 7, legionId = 7, name = "军团名字7", level = 7, score = 1007}
    -- self._legionDamageRankMap[8] = {rank = 8, legionId = 8, name = "军团名字8", level = 8, score = 1008}

    self._myQualify = 0
    self._powerInfos = {}
    self._skillInfos = {}
    -- self._powerInfos[1] = {legionName = "同盟名字1", force = 12344, curNumber = 1, maxNumber = 3, rank = 2}
    -- self._powerInfos[2] = {legionName = "同盟名字11", force = 12345, curNumber = 11, maxNumber = 3, rank = 12}
    -- self._powerInfos[3] = {legionName = "同盟名字12", force = 12346, curNumber = 21, maxNumber = 33, rank = 22}
    -- self._powerInfos[4] = {legionName = "同盟名字13", force = 12347, curNumber = 31, maxNumber = 43, rank = 32}
    -- self._powerInfos[5] = {legionName = "同盟名字14", force = 1234, curNumber = 41, maxNumber = 53, rank = 1}
    -- self._powerInfos[6] = {legionName = "同盟名字14", force = 1234, curNumber = 48, maxNumber = 53, rank = 1}
    -- self._powerInfos[7] = {legionName = "同盟名字14", force = 1234, curNumber = 48, maxNumber = 53, rank = 1}
    -- self._powerInfos[8] = {legionName = "同盟名字14", force = 1234, curNumber = 48, maxNumber = 53, rank = 1}
    -- self._powerInfos[9] = {legionName = "同盟名字14", force = 1234, curNumber = 48, maxNumber = 53, rank = 1}
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------


