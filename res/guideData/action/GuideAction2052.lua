local GuideAction2052 = class( "GuideAction101", DialogueAction)
function GuideAction2052:ctor()
   GuideAction2052.super.ctor(self)

    self.info = "这里有个等级礼包，找一找"
  
  
  
end

function GuideAction2052:onEnter(guide)
   GuideAction2052.super.onEnter(self, guide)
end

return GuideAction2052
