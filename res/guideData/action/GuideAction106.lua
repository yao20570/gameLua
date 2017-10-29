local GuideAction106 = class("GuideAction106", DialogueAction)

function GuideAction106:ctor()
    GuideAction106.super.ctor(self)
    
    self.info = "恭喜主公，凯旋归营！这次战利品真丰厚。"  --
end

function GuideAction106:onEnter(guide)
    GuideAction106.super.onEnter(self, guide)
    AudioManager:playEffect("guide03")
end

return GuideAction106