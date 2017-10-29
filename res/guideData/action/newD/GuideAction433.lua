local GuideAction433 = class("GuideAction433", DialogueAction)

function GuideAction433:ctor()
    GuideAction433.super.ctor(self)
    
    self.info = "终于可以打战役，通关战役招降更多武将哦！"  --
    self.delayTimePre = 0.5     
end

return GuideAction433


