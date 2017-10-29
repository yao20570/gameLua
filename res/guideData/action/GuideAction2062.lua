local GuideAction2062 = class( "GuideAction101", DialogueAction)
function GuideAction2062:ctor()
    GuideAction2062.super.ctor(self)

    self.info = "这里有个登陆礼包，找一找"



end

function GuideAction2062:onEnter(guide)
    GuideAction2062.super.onEnter(self, guide)
end

return GuideAction2062

