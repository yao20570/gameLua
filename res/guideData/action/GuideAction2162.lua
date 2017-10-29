local GuideAction2162 = class( "GuideAction101", DialogueAction)
function GuideAction2162:ctor()
   GuideAction2162.super.ctor(self)

    self.info = "点击别人的头像"
  
  
  
end

function GuideAction2162:onEnter(guide)
   GuideAction2162.super.onEnter(self, guide)
end

return GuideAction2162
