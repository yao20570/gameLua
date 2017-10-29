-- /**
--  * @Author:	  fzw
--  * @DateTime:	2016-08-24 17:37:30
--  * @Description: 副本部队详情
--  */

TeamDetailProxy = class("TeamDetailProxy", BasicProxy)

function TeamDetailProxy:ctor()
    TeamDetailProxy.super.ctor(self)
    self.proxyName = GameProxys.TeamDetail

    -- self._sendServerData = {}

end

function TeamDetailProxy:resetAttr()
    -- self._sendServerData = {}
end

----------------------------

-----------------------------------------------------------
-- 请求协议
-----------------------------------------------------------
function TeamDetailProxy:onTriggerNet270001Req(data)
	-- body 军团副本-出战
	self:syncNetReq(AppEvent.NET_M27,AppEvent.NET_M27_C270001, data)
end

function TeamDetailProxy:onTriggerNet60002Req(data)
	-- body 出战前询问
	self:syncNetReq(AppEvent.NET_M6,AppEvent.NET_M6_C60002, data)
end

function TeamDetailProxy:onTriggerNet60005Req(data)
	-- body 请求挂机
	self:syncNetReq(AppEvent.NET_M6, AppEvent.NET_M6_C60005, data)
end

function TeamDetailProxy:onTriggerNet60004Req(data)
	-- body 请求购买挑战次数
	self:syncNetReq(AppEvent.NET_M6, AppEvent.NET_M6_C60004, data)
end

-- 购买挑战次数
function TeamDetailProxy:buyChallengeTimes(type)
	local dungeonProxy = self:getProxy(GameProxys.Dungeon)
    local _,dungeoId = dungeonProxy:getCurrType()
    local data = {}
    data.type = type
    data.dungeoId = dungeoId
    self:onTriggerNet60004Req(data)
end

-----------------------------------------------------------
-- 接收协议
-----------------------------------------------------------
function TeamDetailProxy:onTriggerNet270001Resp(data)  --军团副本挑战询问
	-- body
    if data.rs == 0 then
        self:onGoFightReq()
    end
end

-- 
function TeamDetailProxy:onTriggerNet60002Resp(data)
	-- body
	-- 询问完，请求出战
	if data.rs == 0 then
		self:onGoFightReq()
	end
end

-- 挂机
function TeamDetailProxy:onTriggerNet60005Resp(data)
    if data.rs == 0 then
        local proxy = self:getProxy(GameProxys.Soldier)  --及时刷新佣兵信息
        proxy:updateSoldiersList(data.soldierInfo)
        local forxy = self:getProxy(GameProxys.Dungeon)
    	local type,id = forxy:getCurrType()
    	local _roleProxy = self:getProxy(GameProxys.Role)
        local energy = _roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_energy)
    	if type ~= 1 then
    		energy = forxy:getTimesById(id)
    	end
    	self:sendNotification(AppEvent.PROXY_TILI_UPDATE, energy)
    else
    	data = nil
    end


    -- if self._sleepPanel == nil then
    -- 	print("60005返回，new一个UI。。。")
    --     self._sleepPanel = UITeamSleepPanel.new(self._curPanel, data)
    -- else
    --     self._sleepPanel:updateData(data)
    -- end
    self._sleepPanel:updateData(data)

end

-- 购买次数返回
function TeamDetailProxy:onTriggerNet60004Resp(data)
	-- body
	if data.rs == 0 then
		-- self:sendNotification(AppEvent.PROXY_BUY_TIMES_UPDATE,data)
	end
end


function TeamDetailProxy:onGoFightReq()
	-- body
	local function onGoFight()
	    -- body
	    local battleProxy = self:getProxy(GameProxys.Battle)
	    battleProxy:startBattleReq(self:getSendData())
	end
	
	local isShow = self._curPanel:isVisible()
	if isShow then

        if self._curPanel.onFightCallback ~= nil then
            self._curPanel:onFightCallback(onGoFight)
        else
            onGoFight()
        end

       -- 关闭布阵panel
		if self._curPanel.onCloseCallback ~= nil then
			self._curPanel:onCloseCallback()
		else
			self._curPanel:onClosePanelHandler()  --关闭布阵panel
		end

	end
end

-----------------------------------------------------------
-- 实例变量
-----------------------------------------------------------
-- 初始化
function TeamDetailProxy:setSendData(data)
	-- body
	self._sendServerData = data	
end

function TeamDetailProxy:setCurPanel(panel)
	-- body
	self._curPanel = panel	
end

function TeamDetailProxy:setSleepPanel(panel)
	-- body
	self._sleepPanel = panel	
end

-----------------------------------------------------------
-- 公共接口
-----------------------------------------------------------
-- 获取技能列表数据
function TeamDetailProxy:getSendData()
	-- body
	return self._sendServerData
end

function TeamDetailProxy:isModuleShowCustom(moduleName)
	return self:isModuleShow(moduleName)
end

-- 保存进入状态：1=挑战，2=挂机
function TeamDetailProxy:setEnterTeamDetailType(type)
	self._enterType = type
end

-- 获取进入状态：挂机OR挑战
function TeamDetailProxy:getEnterTeamDetailType()
	return self._enterType
end

