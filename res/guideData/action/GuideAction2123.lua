local GuideAction2123 = class( "GuideAction101", DialogueAction)
function GuideAction2123:ctor()
   GuideAction2123.super.ctor(self)

    self.info = "点击[升级]提升一个科技"
  
  
  
end

function GuideAction2123:onEnter(guide)
   GuideAction2123.super.onEnter(self, guide)
end

return GuideAction2123
