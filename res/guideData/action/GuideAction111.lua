local GuideAction111 = class("GuideAction111", AreaClickAction)

function GuideAction111:ctor()
    GuideAction111.super.ctor(self)
    
    self.info = "主公战力更强，我们检验一番"
    self.moduleName = ModuleName.ToolbarModule
    self.panelName = "ToolbarPanel"
    self.widgetName = "btnItem1"
    
    self.callbackArg = true
    self.isShowArrow = false
end

function GuideAction111:onEnter(guide)
    GuideAction111.super.onEnter(self, guide)
    
    guide:hideModule(ModuleName.PersonInfoModule)
end

return GuideAction111