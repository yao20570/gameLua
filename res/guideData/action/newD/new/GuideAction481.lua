local GuideAction480 = class("GuideAction480", AreaClickAction)

function GuideAction480:ctor()
    GuideAction480.super.ctor(self)
    
    self.info = "点击酒馆"
    self.moduleName = ModuleName.PubModule
    self.panelName = "PubNorPanel"
    self.widgetName = "nineBtn" --点击九连抽
end

function GuideAction480:onEnter(guide)
    GuideAction480.super.onEnter(self, guide)
    
end

return GuideAction480