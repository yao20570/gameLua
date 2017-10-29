local GuideAction2375 = class( "GuideAction101", DialogueAction)
function GuideAction2375:ctor()
   GuideAction2375.super.ctor(self)

    self.info = "获得更多战法秘籍提升部队更多属性吧"
  
  
  
end

function GuideAction2375:onEnter(guide)
    GuideAction2375.super.onEnter(self, guide)
end

return GuideAction2375
