local GuideAction357e = class("GuideAction357e", AreaClickAction)

function GuideAction357e:ctor()
    GuideAction357e.super.ctor(self)
    
    self.info = "点击使用招募令"
    self.moduleName = ModuleName.BagModule
    self.panelName = "BagSelectGoods"
    self.widgetName = "useBtn"  --绑定类型ID
end

function GuideAction357e:onEnter(guide)
    GuideAction357e.super.onEnter(self, guide)
end

return GuideAction357e