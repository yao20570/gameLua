local GuideAction327 = class("GuideAction327", AreaClickAction)

function GuideAction327:ctor()
    GuideAction327.super.ctor(self)
    
    self.info = "使用招将书"
    self.moduleName = ModuleName.BagModule
    self.panelName = "BagAllItemPanel"
    self.widgetName = "item4051"  --绑定类型ID
end

function GuideAction327:onEnter(guide)
    GuideAction327.super.onEnter(self, guide)
    
    --打开背包模块 弹出使用框
    ModuleJumpManager:jump(ModuleName.BagModule)
end

return GuideAction327