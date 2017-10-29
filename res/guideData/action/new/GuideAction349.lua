local GuideAction349 = class("GuideAction349", AreaClickAction)

function GuideAction349:ctor()
    GuideAction349.super.ctor(self)
    
    self.info = "点击骑兵"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackRecruitPanel"
    self.widgetName = "itemPanel2"
    self.callbackArg = true
end

function GuideAction349:onEnter(guide)
    GuideAction349.super.onEnter(self, guide)
    
end

return GuideAction349