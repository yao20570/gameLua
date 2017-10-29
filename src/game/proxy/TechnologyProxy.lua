--[[
--太学院，科技相关代理
--]]

TechnologyProxy = class("TechnologyProxy", BasicProxy)

function TechnologyProxy:ctor()
    TechnologyProxy.super.ctor(self)
    self.proxyName = GameProxys.Technology

    self._technologMap = {}

    -- 资源类科技
    self._resourcesTypeMap = { [1] = 1, [4] = 4, [7] = 7, [10] = 10, [14] = 14 }
end

--初始化太学院相关信息
function TechnologyProxy:initTechnology(tchnologyInfos)
    local jsonAry = ConfigDataManager:getConfigData(ConfigData.MuseumConfig)
    for _, jsonObj in pairs(jsonAry) do
        local typeid = jsonObj.scienceType
        self._technologMap[typeid] = {typeid = typeid, num = 0}
    end

    tchnologyInfos = tchnologyInfos or {}
    for _,technologyInfo in pairs(tchnologyInfos) do
    	self._technologMap[technologyInfo.typeid] = {typeid = technologyInfo.typeid, num = technologyInfo.level}
    end
end

--更新太学院科技
function TechnologyProxy:updateTechnologyInfo(typeid, level)
	self._technologMap[typeid] = {typeid = typeid, num = level}
end

--获取建筑等级
function TechnologyProxy:getTechnologyLevel(typeid)
	return self._technologMap[typeid].num
end

--获取对应的太学院建筑详细信息
function TechnologyProxy:getDetailInfos()
	return self._technologMap
end

-- 是否资源类科技
function TechnologyProxy:isResourcesType(scienceType)
    return self._resourcesTypeMap[scienceType] ~= nil
end
