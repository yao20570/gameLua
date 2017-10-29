local GuideAction482 = class("GuideAction482", AreaClickAction)

function GuideAction482:ctor()
    GuideAction482.super.ctor(self)
    
    self.info = "点击酒令"
    self.moduleName = ModuleName.PubModule
    self.panelName = "PubPanel"
    self.widgetName = "tabBtn3" --点击酒令
end

function GuideAction482:onEnter(guide)
    GuideAction482.super.onEnter(self, guide)
    
end

return GuideAction482