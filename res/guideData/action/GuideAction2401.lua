local GuideAction2401 = class( "GuideAction101", DialogueAction)
function GuideAction2401:ctor()
    GuideAction2401.super.ctor(self)

    self.info = "恭喜主公解锁民心功能，每天百姓会进贡大量材料，我们赶紧前往吧"



end

function GuideAction2401:onEnter(guide)
    GuideAction2401.super.onEnter(self, guide)
end

return GuideAction2401