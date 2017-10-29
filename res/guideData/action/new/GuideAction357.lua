local GuideAction357 = class("GuideAction357", DialogueAction)

function GuideAction357:ctor()
    GuideAction357.super.ctor(self)
    
    self.info = "刚刚完成了好多任务，赶紧领取奖励"  --

    
end

function GuideAction357:onEnter(guide)
    GuideAction357.super.onEnter(self, guide)
    
    guide:hideModule(ModuleName.HeroModule)
end

return GuideAction357


