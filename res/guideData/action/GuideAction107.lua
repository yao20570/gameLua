local GuideAction107 = class("GuideAction101", AreaClickAction)

function GuideAction107:ctor()
    GuideAction107.super.ctor(self)
    
    self.info = "打关卡掉落战法秘籍、统率令、经验"
    self.moduleName = ModuleName.RoleInfoModule
    self.panelName = "RoleInfoPanel"
    self.widgetName = "headBtn"
    self.isShowArrow = false
end

function GuideAction107:onEnter(guide)
    GuideAction107.super.onEnter(self, guide)
end

return GuideAction107