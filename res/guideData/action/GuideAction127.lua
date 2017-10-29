local GuideAction127 = class("GuideAction127", AreaClickAction)

function GuideAction127:ctor()
    GuideAction127.super.ctor(self)
    
    self.info = "关闭兵营，检验新的步兵部队吧"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackPanel"
    self.widgetName = "closeBtn"
    self.isShowArrow = false
end

function GuideAction127:onEnter(guide)
    GuideAction127.super.onEnter(self, guide)
end

return GuideAction127