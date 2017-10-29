local GuideAction483 = class("GuideAction483", AreaClickAction)

function GuideAction483:ctor()
    GuideAction483.super.ctor(self)
    
    self.info = "点击良将令"
    self.moduleName = ModuleName.PubModule
    self.panelName = "PubShopPanel"
    self.widgetName = "item0" --点击良将令
end

function GuideAction483:onEnter(guide)
    GuideAction483.super.onEnter(self, guide)
    
end

return GuideAction483