ConditionAction = class("ConditionAction", GuideAction)

function ConditionAction:ctor()
    self.level = 1
    
    self.isTrigger = false --是否已经触发过了
end

function ConditionAction:onEnter(guide)
    ConditionAction.super.onEnter(self, guide)
    guide._step = 1
    
    local key = guide:getKey()
    local bool =  LocalDBManager:getValueForKey(key)
    
    if bool ~= nil then --已经引导过了
        guide:endAction(true)
        return
    else
        logger:error("引导开始缓存本地数据")
        LocalDBManager:setValueForKey(key, "true")
    end
    
    self:nextAction()
    
    return true
end