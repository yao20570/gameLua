local GuideAction419 = class("GuideAction419", DialogueAction)

function GuideAction419:ctor()
    GuideAction419.super.ctor(self)
    
    self.info = "主公，新任务是官邸达到3级哦！"  --
    self.delayTimePre = 0.5   

    self.moduleName = ModuleName.MapModule  
end

return GuideAction419


