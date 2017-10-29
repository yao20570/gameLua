local GuideAction104 = class("GuideAction104", DialogueAction)

function GuideAction104:ctor()
    GuideAction104.super.ctor(self)
    
    self.info = "主公注定名垂青史！请留下名号！"  --

    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "city3"
    self.delayTimePre = 0.4
end

function GuideAction104:onEnter(guide)
    GuideAction104.super.onEnter(self, guide)
    AudioManager:playEffect("guide02")
end

function GuideAction104:callback()
    GuideAction104.super.callback(self)

    TimerManager:addOnce(30,self.delayhideModule, self)
end

function GuideAction104:delayhideModule()
    self._guide:hideModule(ModuleName.DungeonModule)
    ModuleJumpManager:jump(ModuleName.CreateRoleModule, "CreateRolePanel", true)
end

return GuideAction104