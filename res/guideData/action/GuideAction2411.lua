local GuideAction2411 = class( "GuideAction101", DialogueAction)
function GuideAction2411:ctor()
    GuideAction2411.super.ctor(self)

    self.info = "恭喜主公解锁演武场，挑战其他人得更好排名，可获得排行榜奖励哦"



end

function GuideAction2411:onEnter(guide)
    GuideAction2411.super.onEnter(self, guide)
end

return GuideAction2411