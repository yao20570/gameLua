local GuideAction2223 = class( "GuideAction101", DialogueAction)
function GuideAction2223:ctor()
   GuideAction2223.super.ctor(self)

    self.info = "接受一个日常任务"
  
  
  
end

function GuideAction2223:onEnter(guide)
   GuideAction2223.super.onEnter(self, guide)
end

return GuideAction2223
