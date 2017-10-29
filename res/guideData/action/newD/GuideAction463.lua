local GuideAction463 = class("GuideAction463", DialogueAction)

function GuideAction463:ctor()
    GuideAction463.super.ctor(self)
    
    self.info = "太棒了，这下我们就可以出战更多的士兵了"  --
    self.delayTimePre = 0.5     
end

return GuideAction463


