local GuideAction461 = class("GuideAction461", AreaClickAction)

function GuideAction461:ctor()
    GuideAction461.super.ctor(self)
    
    self.info = "打关卡掉落战法秘籍、统率令、经验"
    self.moduleName = ModuleName.RoleInfoModule
    self.panelName = "RoleInfoPanel"
    self.widgetName = "headBtn"
    self.isShowArrow = false
end

function GuideAction461:onEnter(guide)
    GuideAction461.super.onEnter(self, guide)
end

return GuideAction461