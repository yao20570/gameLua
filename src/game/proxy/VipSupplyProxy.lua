-- /**
--  * @Author:	  
--  * @DateTime:	2016-04-07 21:15:46
--  * @Description: V
--  */

VipSupplyProxy = class("VipSupplyProxy", BasicProxy)

function VipSupplyProxy:ctor()
    VipSupplyProxy.super.ctor(self)
    self.proxyName = GameProxys.VipSupply

    self._vipSupplyInfo = {}
end

-- message VipSupplyInfo{ //vip特供活动信息
--   repeated int32 receiveTimes = 1;//初始化列表：里面包含5个初始值（0 0 0 0 0） 0 表示不可领取 1 表示未领取 2表示已领取）
-- 	optional int32 remainingTime = 2;//未成为vip的活动剩余时间
-- }

--------initData----
function VipSupplyProxy:initSyncData(data)
	  --这个是由服务端发送过来的初始化数据
    if data.vipSupplyInfo then
	    local _data = {}
	    _data.rs = 0
	    _data.info = data.vipSupplyInfo
	    self:onTriggerNet380000Resp(_data)
	end
end


function VipSupplyProxy:onTriggerNet380000Resp(data)
	if data.rs==0 then
		self._vipSupplyInfo = data.info or {}
    	local time = self._vipSupplyInfo.remainingTime or 0
    	self:pushRemainTime( GameProxys.VipSupply, time, AppEvent.NET_M38_C380000, nil, self.productRemainTimeComplete)
    end
	--增加updata事件，通知模块刷新界面
	self:sendNotification(AppEvent.PROXY_UPDATE_VIPSUPPLYVIEW, data)
	--红点推送
	self:sendNotification(AppEvent.PROXY_UPDATE_VIPSUPPLY_POINT, data)
end

----------resp-------------------
--接受到服务端返回的领取VIP特供协议
function VipSupplyProxy:onTriggerNet380001Resp(data)
	if data.rs==0 then
		local index = data.receiveDay
		self._vipSupplyInfo.receiveTimes[ index ] = 2
	end
	--增加updata事件，通知模块刷新界面
	self:sendNotification(AppEvent.PROXY_UPDATE_VIPSUPPLY_RECEIVE, data)
	--增加updata事件，通知模块刷新界面
	self:sendNotification(AppEvent.PROXY_UPDATE_VIPSUPPLYVIEW, data)
	--红点推送
	self:sendNotification(AppEvent.PROXY_UPDATE_VIPSUPPLY_POINT, data)
end

-----------req---------
--请求领取VIP特供协议
function VipSupplyProxy:onTriggerNet380000Req()
	self:syncNetReq(AppEvent.NET_M38, AppEvent.NET_M38_C380000, {})
end
-----------req---------
--请求领取VIP特供协议
function VipSupplyProxy:onTriggerNet380001Req(data)
	--请求数据
	self:syncNetReq(AppEvent.NET_M38, AppEvent.NET_M38_C380001, data)
end

---------------
--获取VIP特供信息
function VipSupplyProxy:getVipSupplyInfo()
    return self._vipSupplyInfo
end

function VipSupplyProxy:getReceiveState()
	local ret = 0
	local len = 0
	local flag = 0
	local arrTimes = self._vipSupplyInfo.receiveTimes
	if arrTimes then
		for i, state in ipairs( arrTimes ) do
			len = len + 1
			flag = flag + state
			if state==1 then
				ret = ret + 1 --有一个state为1 可领取 显示一个数字
			end
		end
	end
	if flag==0 and self:getTime()==0 or flag>=len*2 then --state 全部为2或者全部为0、关闭活动
		return -1
	end
	return ret  --否则打开活动
end

--倒计时
function VipSupplyProxy:productRemainTimeComplete()
	self:sendNotification( AppEvent.PROXY_UPDATE_VIPSUPPLY_TIMECOMPLEC )
	self:pushRemainTime( GameProxys.VipSupply, 0 )
	--红点推送
	self:sendNotification(AppEvent.PROXY_UPDATE_VIPSUPPLY_POINT, {rs=0})
end
	
function VipSupplyProxy:getTime()
	return self:getRemainTime( GameProxys.VipSupply )
end

function VipSupplyProxy:resetCountSyncData()
	self:onTriggerNet380000Req()
end