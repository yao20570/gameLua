local GuideAction409 = class("GuideAction409", AreaClickAction)

function GuideAction409:ctor()
    GuideAction409.super.ctor(self)
    
    self.info = "加速征召，立即获得"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "RecruitingPanel"
    self.widgetName = "quickBtn1"
    
    self.callbackArg = true
    self.isShowArrow = false
end

function GuideAction409:onEnter(guide)
    GuideAction409.super.onEnter(self, guide)
    -- local widget = guide:getWidget(self.moduleName, self.panelName, self.widgetName)
    -- if widget == nil then
    -- 	self:nextAction() --招兵已完成，直接进入下一步
    -- end
end

return GuideAction409