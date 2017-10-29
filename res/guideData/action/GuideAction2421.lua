local GuideAction2421 = class( "GuideAction101", DialogueAction)
function GuideAction2421:ctor()
    GuideAction2421.super.ctor(self)

    self.info = "主公，军械坊已经解锁，我们赶紧去装备零件"



end

function GuideAction2421:onEnter(guide)
    GuideAction2421.super.onEnter(self, guide)
end

return GuideAction2421