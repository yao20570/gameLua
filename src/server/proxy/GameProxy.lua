module("server", package.seeall)

GameProxy = class("GameProxy")

function GameProxy:ctor(m20000, m30000)
    self._proxyMap = {}

    self:initProxys(m20000, m30000)
end


function GameProxy:initProxys(m20000, m30000)
    local playerProxy = PlayerProxy.new(m20000.actorInfo)
    playerProxy:setGameProxy(self)
    self:addProxy(ActorDefine.PLAYER_PROXY_NAME, playerProxy)

    local buildingProxy = ResFunBuildProxy.new(m20000.buildingInfos)
    buildingProxy:setGameProxy(self)
    self:addProxy(ActorDefine.RESFUNBUILD_PROXY_NAME, buildingProxy)

    local timerdbProxy = TimerdbProxy.new(m30000)
    timerdbProxy:setGameProxy(self)
    self:addProxy(ActorDefine.TIMERDB_PROXY_NAME, timerdbProxy)
    
    local systemProxy = SystemProxy.new()
    systemProxy:setGameProxy(self)
    self:addProxy(ActorDefine.SYSTEM_PROXY_NAME, systemProxy)

    local vipProxy = VipProxy.new()
    vipProxy:setGameProxy(self)
    self:addProxy(ActorDefine.VIP_PROXY_NAME, vipProxy) 

    local talentProxy = TalentProxy.new()
    talentProxy:setGameProxy(self)
    self:addProxy(ActorDefine.VIP_PROXY_NAME, talentProxy) 

    local itemProxy = ItemProxy.new(m20000.itemList)
    itemProxy:setGameProxy(self)
    self:addProxy(ActorDefine.ITEM_PROXY_NAME, itemProxy) 

    local rewardProxy = RewardProxy.new()
    rewardProxy:setGameProxy(self)
    self:addProxy(ActorDefine.REWARD_PROXY_NAME, rewardProxy) 
    
    local soldierProxy = SoldierProxy.new(m20000.soldierList)
    soldierProxy:setGameProxy(self)
    self:addProxy(ActorDefine.SOLDIER_PROXY_NAME, soldierProxy) 

    local technologyProxy = TechnologyProxy.new(m20000.buildingInfos)
    technologyProxy:setGameProxy(self)
    self:addProxy(ActorDefine.TECHNOLOGY_PROXY_NAME, technologyProxy) 
    
    technologyProxy:initTechnology(m20000.buildingInfos)
    buildingProxy:initBuildings(m20000.buildingInfos)
end

function GameProxy:addProxy(name, proxy)
    self._proxyMap[name] = proxy
end

function GameProxy:getProxy(name)
    return self._proxyMap[name]
end