local GuideAction2132 = class( "GuideAction101", DialogueAction)
function GuideAction2132:ctor()
   GuideAction2132.super.ctor(self)

    self.info = "点击宝箱获取奖励"
  
  
  
end

function GuideAction2132:onEnter(guide)
   GuideAction2132.super.onEnter(self, guide)
end

return GuideAction2132
