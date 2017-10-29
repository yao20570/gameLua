local GuideAction2381 = class( "GuideAction101", DialogueAction)
function GuideAction2381:ctor()
    GuideAction2381.super.ctor(self)

    self.info = "每天我们有1次免费抽取的机会，主公赶紧试下您的手气吧"



end

function GuideAction2381:onEnter(guide)
    GuideAction2381.super.onEnter(self, guide)
end

return GuideAction2381