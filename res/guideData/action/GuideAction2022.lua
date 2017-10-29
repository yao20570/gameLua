local GuideAction2022 = class( "GuideAction101", DialogueAction)
function GuideAction2022:ctor()
   GuideAction2022.super.ctor(self)

  self.info = "升级你的兵营吧"
  
  
  
end

function GuideAction2022:onEnter(guide)
   GuideAction2022.super.onEnter(self, guide)
end

return GuideAction2022
