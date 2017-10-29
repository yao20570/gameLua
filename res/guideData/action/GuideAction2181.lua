local GuideAction2181 = class( "GuideAction101", DialogueAction)
function GuideAction2181:ctor()
   GuideAction2181.super.ctor(self)

  self.info = "好多厉害的人，你看看"
  self.moduleName = ModuleName.RankModule
  self.panelName = "RankPanel"
  
end

function GuideAction2181:onEnter(guide)
   GuideAction2181.super.onEnter(self, guide)
end

return GuideAction2181
