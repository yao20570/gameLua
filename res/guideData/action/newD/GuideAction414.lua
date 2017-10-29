local GuideAction414 = class("GuideAction414", DialogueAction)

function GuideAction414:ctor()
    GuideAction414.super.ctor(self)
    
    self.info = "讨伐会有战损，记得用最大的战力进行讨伐"  --
    self.delayTimePre = 0.5     
end

return GuideAction414


