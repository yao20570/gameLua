local GuideAction101 = class("GuideAction101", DialogueAction)

function GuideAction101:ctor()
    GuideAction101.super.ctor(self)
    
    self.info = "恭喜，新手引导就要结束了，要记得多升级建筑，多招士兵哦"  --
    
end

function GuideAction101:onEnter(guide)
    GuideAction101.super.onEnter(self, guide)
end

return GuideAction101