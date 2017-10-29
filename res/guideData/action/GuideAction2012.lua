local GuideAction2012 = class( "GuideAction101", DialogueAction)
function GuideAction2012:ctor()
   GuideAction2012.super.ctor(self)

    self.info = "升级官邸建造高级建筑"
  
  
  
end

function GuideAction2012:onEnter(guide)
   GuideAction2012.super.onEnter(self, guide)
end

return GuideAction2012
