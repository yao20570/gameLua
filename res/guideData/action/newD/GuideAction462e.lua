local GuideAction462e = class("GuideAction462e", AreaClickAction)


function GuideAction462e:ctor()
    GuideAction462e.super.ctor(self)
    
    self.info = "再升一级"
    self.moduleName = ModuleName.PersonInfoModule
    self.panelName = "PersonInfoDetailsPanel"
    self.widgetName = "btn3"
    self.delayTimePre= 0.8
    
    
    self.callbackArg = true
    self.isShowArrow = false
end

function GuideAction462e:onEnter(guide)
    GuideAction462e.super.onEnter(self, guide)
end

return GuideAction462e