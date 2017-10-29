-- /**
--  * @Author:	  fzw
--  * @DateTime:	2016-04-25 11:16:17
--  * @Description: 排行榜
--  */
RankProxy = class("RankProxy", BasicProxy)

function RankProxy:ctor()
    RankProxy.super.ctor(self)
    self.proxyName = GameProxys.Rank
    self._rankList = {}
    self._playerData = {}
    self._lastRefreshTime = 0
end

function RankProxy:resetAttr()
    self._rankList = {}
    self._playerData = {}
    self._lastRefreshTime = 0
end

---------------------------------------------------------------------
-- 协议请求
---------------------------------------------------------------------
--请求榜单数据
function RankProxy:onTriggerNet210000Req()
    local now = os.time()
	if now - self._lastRefreshTime > 300 then   -- 5分钟刷新一次
		self:syncNetReq(AppEvent.NET_M21,AppEvent.NET_M21_C210000, {})
	end
end

function RankProxy:initSyncData(data)
    RankProxy.super.initSyncData(self, data)
	local tempData = {}
    tempData.rankListInfo = data.rankinfos
    self:onTriggerNet210000Resp(tempData)

    self:onTriggerNet210001Resp(data)
end

---------------------------------------------------------------------
-- 协议接收
---------------------------------------------------------------------
function RankProxy:onTriggerNet210000Resp(data)
	local dataRanks = data.rankListInfo
	local typeId = dataRanks.typeId
	for _, v in pairs(dataRanks) do
		local typeId = v.typeId
		self:setRankList(typeId, v.powerRankInfo)
		self:setPlayerData(typeId, v.myRank)
	end
	self._lastRefreshTime = os.time()
--[[typeId difine	1.战力 2.暂时屏蔽 3.关卡 4.战绩 5.攻击强化 
					6.暴击强化 7.闪避强化 8.演武场 9.暂时屏蔽
	]]
	-- if typeId == 1 then
	-- 	self:sendNotification(AppEvent.PROXY_RANK_INFO_UPDATE, {})
	-- 	local data = {typeId = 3}
	-- 	self:syncNetReq(AppEvent.NET_M21,AppEvent.NET_M21_C210000, data)
	-- 	self._lastRefreshTime = os.time()
	-- elseif typeId == 3 then
	-- 	local data = {typeId = 4}
	-- 	self:syncNetReq(AppEvent.NET_M21,AppEvent.NET_M21_C210000, data)
	-- elseif typeId == 4 then
	-- 	local data = {typeId = 5}
	-- 	self:syncNetReq(AppEvent.NET_M21,AppEvent.NET_M21_C210000, data)		
	-- elseif typeId == 5 then
	-- 	local data = {typeId = 6}
	-- 	self:syncNetReq(AppEvent.NET_M21,AppEvent.NET_M21_C210000, data)
	-- elseif typeId == 6 then
	-- 	local data = {typeId = 7}
	-- 	self:syncNetReq(AppEvent.NET_M21,AppEvent.NET_M21_C210000, data)
	-- elseif typeId == 7 then
	-- 	local data = {typeId = 8}
	-- 	self:syncNetReq(AppEvent.NET_M21,AppEvent.NET_M21_C210000, data)
	-- end
end

function RankProxy:onTriggerNet210001Req(data)
	self:syncNetReq(AppEvent.NET_M21,AppEvent.NET_M21_C210001, data)
end

function RankProxy:onTriggerNet210001Resp(info)
	local data = info.worldResRankInfos
	--木材type是3，石料是4
	local max = {1,2,4,3,5}
	local rank = {}
	self._resRankInfos = {}
	for i=1,#data do
		local v = data[i]
		rank[v.type] = rank[v.type] or {}
		if #v.rankPlayerInfos > 0 then
			table.insert(rank[v.type], v)
		end
	end

	for k=1,#max do
		local i = max[k] 
		if rank[i] ~= nil and #rank[i] ~= 0 then
			table.sort( rank[i], function(a, b)
                return a.lv > b.lv
			end )
			for j=1,#rank[i] do
				local v = rank[i][j]
				local config = ConfigDataManager:getInfoFindByTwoKey(ConfigData.ResourcePointConfig, "type", v.type, "level", v.lv)
				table.insert(self._resRankInfos, v)
			end
		end
	end
	self:sendNotification(AppEvent.PROXY_RESRANK_INFO_UPDATE)
end

---------------------------------------------------------------------
-- 实例变量
---------------------------------------------------------------------
function RankProxy:setRankList(typeId, data)
	data = data or {}
	self._rankList[typeId] = data
end

function RankProxy:setPlayerData(typeId, data)
	self._playerData[typeId] = data
end

---------------------------------------------------------------------
-- 公共接口
---------------------------------------------------------------------
function RankProxy:getRankList(typeId)
	return self._rankList[typeId]

end

function RankProxy:getPlayerData(typeId)
	return self._playerData[typeId]
end

--获得征矿榜的数据
function RankProxy:getResRankInfo()
	return self._resRankInfos
end
