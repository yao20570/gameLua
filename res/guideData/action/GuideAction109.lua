local GuideAction109 = class("GuideAction109", AreaClickAction)

function GuideAction109:ctor()
    GuideAction109.super.ctor(self)
    
    self.info = "干得漂亮，是时候提升战法了"
    self.moduleName = ModuleName.PersonInfoModule
    self.panelName = "PersonInfoPanel"
    self.widgetName = "tabBtn2"
    self.isShowArrow = false
    
end

function GuideAction109:onEnter(guide)
    GuideAction109.super.onEnter(self, guide)
end

return GuideAction109