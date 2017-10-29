local GuideAction448 = class("GuideAction448", AreaClickAction)

function GuideAction448:ctor()
    GuideAction448.super.ctor(self)
    
    self.info = "征召骑兵"
    self.moduleName = ModuleName.BarrackModule
    self.panelName = "BarrackPanel"
    self.widgetName = "tabBtn2"  --中间标签
    
    self.callbackArg = 40
end

function GuideAction448:onEnter(guide)
    GuideAction448.super.onEnter(self, guide)
    
end

return GuideAction448