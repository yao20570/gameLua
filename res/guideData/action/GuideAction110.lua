local GuideAction110 = class("GuideAction110", AreaClickAction)

function GuideAction110:ctor()
    GuideAction110.super.ctor(self)
    
    self.info = "升级命中战法，提升攻击命中率"
    self.moduleName = ModuleName.PersonInfoModule
    self.panelName = "PersonInfoSkillPanel"
    self.widgetName = "item1"
    self.isShowArrow = false
end

function GuideAction110:onEnter(guide)
    GuideAction110.super.onEnter(self, guide)
end

return GuideAction110