local GuideAction2396 = class( "GuideAction101", DialogueAction)
function GuideAction2396:ctor()
    GuideAction2396.super.ctor(self)

    self.info = "匈奴每天有5次免费挑战机会，可获得大量武将碎片哦"



end

function GuideAction2396:onEnter(guide)
    GuideAction2396.super.onEnter(self, guide)
end

return GuideAction2396