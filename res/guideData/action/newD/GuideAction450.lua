local GuideAction450 = class("GuideAction450", AreaClickAction)

function GuideAction450:ctor()
    GuideAction450.super.ctor(self)
    
    self.info = "开始征召"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackRecruitPanel"
    self.widgetName = "_btnRecruit"

end

function GuideAction450:onEnter(guide)
    GuideAction450.super.onEnter(self, guide)
    
end

return GuideAction450