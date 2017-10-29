local GuideAction2213 = class( "GuideAction101", DialogueAction)
function GuideAction2213:ctor()
   GuideAction2213.super.ctor(self)

    self.info = "占领据点，采集资源"
  
  
  
end

function GuideAction2213:onEnter(guide)
   GuideAction2213.super.onEnter(self, guide)
end

return GuideAction2213
