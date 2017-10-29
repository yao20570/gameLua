local GuideAction2371 = class( "GuideAction101", DialogueAction)
function GuideAction2371:ctor()
   GuideAction2371.super.ctor(self)

    self.info = "使用战法秘籍可提升部队的属性"
  
  
  
end

function GuideAction2371:onEnter(guide)
    GuideAction2371.super.onEnter(self, guide)
end

return GuideAction2371