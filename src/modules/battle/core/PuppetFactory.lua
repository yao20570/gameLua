module("battleCore", package.seeall)

PuppetFactory = class("PuppetFactory")  --佣兵

local instance = nil

function PuppetFactory:getInstance()
    if instance == nil then
        instance = PuppetFactory.new()
    end
    return instance
end

function PuppetFactory:finalize()
    for _, ent in pairs(self._entMap) do
        ent:finalize()
    end
    self._entMap = {}
end

function PuppetFactory:ctor()
    self._entMap = {}
end

function PuppetFactory:create(attr, rootNode)
    local ent = Puppet.new(attr, rootNode)
    
    local index = attr.index
    self._entMap[index] = ent
    return ent
    
end

function PuppetFactory:getEntitysByCamp(camp)
    local list = {}
    for _, ent in pairs(self._entMap) do
    	if ent.camp == camp then
            table.insert(list, ent)
    	end
    end
    
    return list
end

function PuppetFactory:getEntitys()
    return self._entMap
end

function PuppetFactory:getEntity(index)
    return self._entMap[index]
end



