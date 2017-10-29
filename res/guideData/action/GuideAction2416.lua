local GuideAction2416 = class( "GuideAction101", DialogueAction)
function GuideAction2416:ctor()
    GuideAction2416.super.ctor(self)

    self.info = "主公，您可以选择挑战对手了，建议选择比您战力低的人哦"



end

function GuideAction2416:onEnter(guide)
    GuideAction2416.super.onEnter(self, guide)
end

return GuideAction2416