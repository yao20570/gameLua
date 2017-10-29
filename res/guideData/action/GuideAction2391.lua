local GuideAction2391 = class( "GuideAction101", DialogueAction)
function GuideAction2391:ctor()
    GuideAction2391.super.ctor(self)

    self.info = "主公，远征副本已经解锁了，我们赶紧前往看看"



end

function GuideAction2391:onEnter(guide)
    GuideAction2391.super.onEnter(self, guide)
end

return GuideAction2391