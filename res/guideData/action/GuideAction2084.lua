local GuideAction2084 = class( "GuideAction101", DialogueAction)
function GuideAction2084:ctor()
   GuideAction2084.super.ctor(self)

    self.info = "选择吞噬的材料"
  
  
  
end

function GuideAction2084:onEnter(guide)
   GuideAction2084.super.onEnter(self, guide)
end

return GuideAction2084
