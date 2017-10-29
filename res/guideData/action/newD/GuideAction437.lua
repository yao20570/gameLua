local GuideAction437 = class("GuideAction437", DialogueAction)

function GuideAction437:ctor()
    GuideAction437.super.ctor(self)
    
    self.info = "战役挑战部队零战损，请尽情的征服中原。"  --
    self.delayTimePre = 0.5     
end

return GuideAction437


