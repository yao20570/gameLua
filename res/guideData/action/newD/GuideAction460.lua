local GuideAction460 = class("GuideAction460", DialogueAction)

function GuideAction460:ctor()
    GuideAction460.super.ctor(self)
    
    self.info = "主公，我们带兵的数量不足，先提升下统率等级吧"  --
    self.delayTimePre = 0.5     
end

return GuideAction460


