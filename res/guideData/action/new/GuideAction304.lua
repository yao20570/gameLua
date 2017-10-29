local GuideAction304 = class("GuideAction304", DialogueAction)

function GuideAction304:ctor()
    GuideAction304.super.ctor(self)
    
    self.info = "我们兵力不足，先征召士兵，再前往讨伐"  --
    
end

return GuideAction304


