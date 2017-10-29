local GuideAction404 = class("GuideAction404", DialogueAction)

function GuideAction404:ctor()
    GuideAction404.super.ctor(self)
    
    self.info = "我们兵力不足，先征召士兵，再前往讨伐"  --
    self.delayTimePre = 0.5     
end

return GuideAction404


