module("battleCore", package.seeall)

Skill = class("Skill")

function Skill:ctor(battle)
    self._owner = nil
    self._id = nil
    self._targets = nil
    self._config = nil
    self._round = nil
    self._skillEndCallback = nil
    self._battle = battle
    
    self._rootNode = {action = nil, nextNode = nil}
end


function Skill:init(owner, targets, config, round, callback)
    self._owner = owner
    self._targets = targets
    self._config = config
    self._round = round
    self._skillEndCallback = callback
    
    --TODO 不同兵种会不同Action  ,"Move" , "MoveBack"
    -- local skillActionKeys = {"Ready", "PreAttack", "Attack", "Battle", "Recover"}
    local skillActionKeys = {"Ready", "PreAttack", "Attack", "Recover"}
    for _, key in pairs(skillActionKeys) do
        local action = self:getActonByKey(key)
        self:addAction(action)
    end
end

function Skill:use()
    self:onEnter()
end

function Skill:onEnter()
    self._curNode = self._rootNode
    self:onEnterAction(self._curNode.action)
end

function Skill:nextAction()
    self._curNode = self._curNode.nextNode
    if self._curNode ~= nil then
        self:onEnterAction(self._curNode.action)
    else
        ----end event回合结束
        if self._skillEndCallback ~= nil then
            self._skillEndCallback()
        end
    end
end

function Skill:onEnterAction(action)
    action:onEnter(self)
end


function Skill:addAction(action) 
    if self._rootNode.action == nil then
        self._rootNode.action = action
    else
        local newNode = {action = action, nextNode = nil}
        local curNode = self._rootNode
        while curNode.nextNode ~= nil do
            curNode = curNode.nextNode
        end
        curNode.nextNode = newNode
    end
end

function Skill:getActonByKey(key)
    local ActionClass = battleCore[key .. "Action"]
    local action = ActionClass.new()
    return action
end

function Skill:getOwner()
    return self._owner
end

function Skill:getTargets()
    return self._targets
end

function Skill:getConfig()
    return self._config
end

function Skill:getRound()
    return self._round
end

function Skill:getBattle()
    return self._battle
end

function Skill:addTimerOnce(delay, func, obj, ...)
    self._battle:addTimerOnce(delay, func, obj, ...)
end











