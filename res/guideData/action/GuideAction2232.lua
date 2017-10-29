local GuideAction2232 = class( "GuideAction101", DialogueAction)
function GuideAction2232:ctor()
   GuideAction2232.super.ctor(self)

    self.info = "寻找志同道合的人，一起战斗吧"
  
  
  
end

function GuideAction2232:onEnter(guide)
   GuideAction2232.super.onEnter(self, guide)
end

return GuideAction2232
