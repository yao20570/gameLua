local GuideAction2033 = class( "GuideAction101", DialogueAction)
function GuideAction2033:ctor()
   GuideAction2033.super.ctor(self)

  self.info = "升级或建造一个资源点，等级越高资源产量越多！"
  
  
  
end

function GuideAction2033:onEnter(guide)
   GuideAction2033.super.onEnter(self, guide)
end

return GuideAction2033
