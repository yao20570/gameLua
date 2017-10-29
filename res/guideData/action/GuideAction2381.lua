local GuideAction2381 = class( "GuideAction101", DialogueAction)
function GuideAction2381:ctor()
    GuideAction2381.super.ctor(self)

    self.info = "主公，酒馆功能解锁了，看看我们的运气如何，哈"



end

function GuideAction2381:onEnter(guide)
    GuideAction2381.super.onEnter(self, guide)
end

return GuideAction2381