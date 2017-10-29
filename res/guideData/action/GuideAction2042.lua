local GuideAction2042 = class( "GuideAction101", DialogueAction)
function GuideAction2042:ctor()
   GuideAction2042.super.ctor(self)

    self.info = "升级太学院，研究高级科技"
  
  
  
end

function GuideAction2042:onEnter(guide)
   GuideAction2042.super.onEnter(self, guide)
end

return GuideAction2042
