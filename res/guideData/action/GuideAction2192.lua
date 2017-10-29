local GuideAction2192 = class( "GuideAction101", DialogueAction)
function GuideAction2192:ctor()
   GuideAction2192.super.ctor(self)

    self.info = "选择一个章节或战役"
  
  
  
end

function GuideAction2192:onEnter(guide)
   GuideAction2192.super.onEnter(self, guide)
end

return GuideAction2192
