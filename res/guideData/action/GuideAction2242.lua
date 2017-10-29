local GuideAction2242 = class( "GuideAction101", DialogueAction)
function GuideAction2242:ctor()
   GuideAction2242.super.ctor(self)

    self.info = "查看资源的情况，点[获取]看看"
  
  
  
end

function GuideAction2242:onEnter(guide)
   GuideAction2242.super.onEnter(self, guide)
end

return GuideAction2242
