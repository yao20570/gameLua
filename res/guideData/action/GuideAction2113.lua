local GuideAction2113 = class( "GuideAction101", DialogueAction)
function GuideAction2113:ctor()
   GuideAction2113.super.ctor(self)

    self.info = "点击[升级]提升全军战法"
  
  
  
end

function GuideAction2113:onEnter(guide)
   GuideAction2113.super.onEnter(self, guide)
end

return GuideAction2113
