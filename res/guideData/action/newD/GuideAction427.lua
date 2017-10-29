local GuideAction427 = class("GuideAction427", AreaClickAction)

function GuideAction427:ctor()
    GuideAction427.super.ctor(self)
    
    self.info = "使用招募贴"
    self.moduleName = ModuleName.BagModule
    self.panelName = "BagAllItemPanel"
    self.widgetName = "item4051"  --绑定类型ID
end

function GuideAction427:onEnter(guide)
    GuideAction427.super.onEnter(self, guide)
    
    --打开背包模块 弹出使用框
    ModuleJumpManager:jump(ModuleName.BagModule)
end

return GuideAction427