---
--移动到对应建筑模块
--下一个GuideAction需要点击对应的建筑！！

local MoveSceneAction = class("MoveSceneAction", AutoClickAction)

function MoveSceneAction:ctor()
    MoveSceneAction.super.ctor(self)
    self.isTouchCall = false
    self.delayTime = 0.1
end

function MoveSceneAction:onEnter(guide)
    MoveSceneAction.super.onEnter(self, guide)
    
    local nextActionData = guide:getNextActionData()
    self.moduleName = nextActionData.moduleName
    self.panelName = nextActionData.panelName
    self.widgetName = "notExit"
    
    local guidePanel = guide:getPanel(ModuleName.GuideModule, GuidePanel.NAME)
    local widgetName = nextActionData.widgetName
    local function moveEnd()
        self.widgetName = widgetName
        if guidePanel ~= nil then
            guidePanel:moveEnd()
        end
    end
    
    local panel = guide:getPanel(self.moduleName, self.panelName)
    local widget = guide:getWidget(self.moduleName, self.panelName, widgetName)
    
    panel:moveToBuildingPanel(widget, moveEnd)

    
    if guidePanel then
        guidePanel:moveAreaClick()
    end
end

function MoveSceneAction:callback(value)
    TimerManager:remove(self.delaycallback, self)
    if self._widget ~= nil and self._widget.touchCallback ~= nil and self.isTouchCall == true then
        self._widget.touchCallback(self._widget, ccui.TouchEventType.ended) --模拟触摸
    end
    if self._iscallback == true then
        return
    end

    self._iscallback = true

    self.delayNextActionTime = self.delayNextActionTime or 0.01
    TimerManager:addOnce(self.delayNextActionTime * 1000, self.delayNextAction, self)
end

return MoveSceneAction