local GuideAction2152 = class( "GuideAction101", DialogueAction)
function GuideAction2152:ctor()
   GuideAction2152.super.ctor(self)

    self.info = "点击下面的聊天框输入"
  
  
  
end

function GuideAction2152:onEnter(guide)
   GuideAction2152.super.onEnter(self, guide)
end

return GuideAction2152
