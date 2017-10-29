-- /**
--  * @Author:	  fzw
--  * @DateTime:	2016-05-05 16:09:11
--  * @Description: 西域远征
--  */
LimitExpProxy = class("LimitExpProxy", BasicProxy)

function LimitExpProxy:ctor()
    LimitExpProxy.super.ctor(self)
    self.proxyName = GameProxys.LimitExp

    self._allExpInfos = nil
end

--初始化同步数据 接收剩余扫荡时间 触发扫荡奖励邮件下发
function LimitExpProxy:initSyncData(data)
	LimitExpProxy.super.initSyncData(self, data)
	local time = rawget(data, 'mopptime')
	if time ~= nil then
		logger:info("== --初始化同步数据  剩余扫荡时间 %d ==",time)
		self:updateRemainTime(time)
	end
end

function LimitExpProxy:resetAttr()
    -- self.proxyName = GameProxys.LimitExp
    self._allExpInfos = nil
end

function LimitExpProxy:registerNetEvents()
    -- self:addEventListener(AppEvent.PROXY_SOLIDER_MOFIDY,self,self.setCheckExample)
end

function LimitExpProxy:unregisterNetEvents()
    -- self:removeEventListener(AppEvent.PROXY_SOLIDER_MOFIDY,self,self.setCheckExample)
end


-- --副本初始化数据
-- function LimitExpProxy:initSyncData( data )
--     -- self:resetAttr()
--     self:setExpListInfos(data.dungeoExplore)
-- end

-- function LimitExpProxy:setExpListInfos(data)
-- 	-- body

-- end


---------------------------------------------------------------------
-- 请求协议
---------------------------------------------------------------------
-- 极限探险的信息
function LimitExpProxy:onTriggerNet60100Req(data)
	-- body
	-- print("...onTriggerNet60100Req")
	self:syncNetReq(AppEvent.NET_M6, AppEvent.NET_M6_C60100, {})
end

-- 极限重置
function LimitExpProxy:onTriggerNet60101Req(data)
	-- body
	-- print("...onTriggerNet60101Req")
	self:syncNetReq(AppEvent.NET_M6, AppEvent.NET_M6_C60101, data)
end

-- 开始极限扫荡
function LimitExpProxy:onTriggerNet60102Req(data)
	-- body
	-- print("...onTriggerNet60102Req")
	self:syncNetReq(AppEvent.NET_M6, AppEvent.NET_M6_C60102, data)
end

-- 停止极限扫荡
function LimitExpProxy:onTriggerNet60103Req(data)
	-- body
	-- print("...onTriggerNet60103Req")
	self:syncNetReq(AppEvent.NET_M6, AppEvent.NET_M6_C60103, data)
end

-- 极限扫荡的倒计时
function LimitExpProxy:onTriggerNet60105Req(data)
	-- body
	-- print("...onTriggerNet60105Req")
	self:syncNetReq(AppEvent.NET_M6, AppEvent.NET_M6_C60105, data)
end

-- 请求重播
function LimitExpProxy:onTriggerNet160005Req(data)
    self:syncNetReq(AppEvent.NET_M16, AppEvent.NET_M16_C160005, data)
end


---------------------------------------------------------------------
-- 接收协议
---------------------------------------------------------------------
function LimitExpProxy:onTriggerNet60100Resp(data)
	-- body 极限探险的信息
	-- print("···onTriggerNet60100Resp",data.rs)
	if data.rs == 0 then
		if data.ismop == 1 then  --正在扫荡
			self:updateRemainTime(data.moptime)
		end

		if data.moptime == 0 then
			data.ismop = 0
		end
		self._allExpInfos = data

		--顺便刷新20000里面的西域远征的次数信息
		local roleProxy = self:getProxy(GameProxys.Role)
		roleProxy:setLimitExpData(data.fightCount, data.backCount)

		self:updateRedPoint()
		self:sendNotification(AppEvent.PROXY_LIMIT_INFO_UPDATE, {})
	end
end

function LimitExpProxy:onTriggerNet60101Resp(data)
	-- body 极限重置
	-- print("···onTriggerNet60101Resp")
	if data.rs == 0 then
	end
end

function LimitExpProxy:onTriggerNet60102Resp(data)
	-- body 开始极限扫荡
	-- print("···onTriggerNet60102Resp")
	if data.rs == 0 then
	end
end

function LimitExpProxy:onTriggerNet60103Resp(data)
	-- body 停止极限扫荡
	-- print("···onTriggerNet60103Resp")
	if data.rs == 0 then
	end
end

function LimitExpProxy:onTriggerNet60105Resp(data)
	-- body 极限扫荡的倒计时
	-- print("···onTriggerNet60105Resp")
	if data.rs == 0 then
		local remainTime = data.moptime
		if remainTime == -1 then
			-- print("···校验成功")
			remainTime = 0
		else
			-- print("···校验失败 remainTime", remainTime)
			self:onTriggerNet60100Req()  --扫荡结束，刷新一遍
		end
		self:updateRemainTime(remainTime)

	end
end



---------------------------------------------------------------------
-- 实例变量
---------------------------------------------------------------------

---------------------------------------------------------------------
-- 公共接口
---------------------------------------------------------------------
--获取最新的60100的数据
function LimitExpProxy:getExinfos()
	return self._allExpInfos
end

function LimitExpProxy:getMopRemainTime()
	local key = self:getTimeKey()
	local remainTime = self:getRemainTime(key)
	return remainTime
end
---------------------------------------------------------------------
-- 定时器
---------------------------------------------------------------------
-- 自定义唯一key
function LimitExpProxy:getTimeKey()
	-- body
	return "key_limit_exp"
end

-- 更新定时器
function LimitExpProxy:updateRemainTime(remainTime)
	-- body
	local key = self:getTimeKey()
	local sendData = {}

	-- print("更新定时器...key, remainTime", key, remainTime)

	self:pushRemainTime(key, remainTime, AppEvent.NET_M6_C60105, sendData, self.completeCallFunc)
end

-- 回调
function LimitExpProxy:completeCallFunc(sendDataList)
	-- body
	for _,sendData in pairs(sendDataList) do
		-- print("completeCallFunc...sendData...")
		-- self:onTriggerNet60100Req(sendData)
		self:onTriggerNet60105Req(sendData)
	end
end

--小红点更新
function LimitExpProxy:updateRedPoint()
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:checkDungeonRedPoint() 
end

