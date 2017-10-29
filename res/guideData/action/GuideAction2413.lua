local GuideAction2413 = class( "GuideAction101", DialogueAction)
function GuideAction2413:ctor()
    GuideAction2413.super.ctor(self)

    self.info = "让我们来设置最大战力吧"



end

function GuideAction2413:onEnter(guide)
    GuideAction2413.super.onEnter(self, guide)
end

return GuideAction2413