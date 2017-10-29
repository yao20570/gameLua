---战斗自动退出Action

local BattleAutoExitAction = class("GuideAction101", AutoClickAction)

function BattleAutoExitAction:ctor()
    BattleAutoExitAction.super.ctor(self)
    
--    self.delayTimePre = 8
    
    self.moduleName = ModuleName.BattleModule
    self.panelName = "BattleResultPanel"
    self.widgetName = "exitBtn"
    
    self.isTouchCall = false 
    self.callbackArg = true
    self.directGetWidget = true
    
    self.isShowArrow = false

    self.delayFlyTime = 2000
end

function BattleAutoExitAction:onEnter(guide)
    BattleAutoExitAction.super.onEnter(self, guide)

    local nextActionData = guide:getNextActionData()
    if nextActionData ~= nil then
    	nextActionData.delayFlyTime = 2000
    end
end

return BattleAutoExitAction