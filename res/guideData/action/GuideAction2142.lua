local GuideAction2142 = class( "GuideAction101", DialogueAction)
function GuideAction2142:ctor()
   GuideAction2142.super.ctor(self)

    self.info = "选择一个武将培养"
  
  
  
end
  

function GuideAction2142:onEnter(guide)
   GuideAction2142.super.onEnter(self, guide)
end

return GuideAction2142
