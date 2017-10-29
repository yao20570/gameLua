local JumpModuleAction = class("JumpModuleAction", AutoClickAction)

-----跳转到某个模块
function JumpModuleAction:ctor()
    JumpModuleAction.super.ctor(self)
    self.isTouchCall = false
    self.isNotWidget = true  
    self.isShowArrow = false  
end

function JumpModuleAction:onEnter(guide)
    
    local nextActionData = guide:getNextActionData()
    self.moduleName = nextActionData.moduleName
    self.panelName = nextActionData.panelName

    local widgetName = nextActionData.widgetName
    local function moveEnd()
        self.widgetName = widgetName
    end
    
    ModuleJumpManager:jump(self.moduleName, self.panelName)

    moveEnd()
    
    JumpModuleAction.super.onEnter(self, guide)
end

return JumpModuleAction

