local GuideAction2172 = class( "GuideAction101", DialogueAction)
function GuideAction2172:ctor()
   GuideAction2172.super.ctor(self)

    self.info = "选择一个你喜欢的头像后确定"
  
  
  
end

function GuideAction2172:onEnter(guide)
   GuideAction2172.super.onEnter(self, guide)
end

return GuideAction2172
