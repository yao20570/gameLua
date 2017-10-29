local GuideAction462 = class("GuideAction462", AreaClickAction)

function GuideAction462:ctor()
    GuideAction462.super.ctor(self)
    
    self.info = "提升统率等级"
    self.moduleName = ModuleName.PersonInfoModule
    self.panelName = "PersonInfoDetailsPanel"
    self.widgetName = "btn3"
    
    
    self.callbackArg = true
    self.isShowArrow = false

    self.delayTime = 1
end

function GuideAction462:onEnter(guide)
    GuideAction462.super.onEnter(self, guide)
end

return GuideAction462