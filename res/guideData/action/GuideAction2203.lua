local GuideAction2203 = class( "GuideAction101", DialogueAction)
function GuideAction2203:ctor()
   GuideAction2203.super.ctor(self)

  self.info = "点击按钮攻击他们吧"
  
  
  
end

function GuideAction2203:onEnter(guide)
   GuideAction2203.super.onEnter(self, guide)
end

return GuideAction2203
