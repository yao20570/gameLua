local GuideAction2404 = class( "GuideAction101", DialogueAction)
function GuideAction2404:ctor()
    GuideAction2404.super.ctor(self)

    self.info = "主公，您赶紧选择想要的材料，如果都不想要，记得点击刷新按钮哦"



end

function GuideAction2404:onEnter(guide)
    GuideAction2404.super.onEnter(self, guide)
end

return GuideAction2404