local GuideAction2161 = class( "GuideAction101", DialogueAction)
function GuideAction2161:ctor()
   GuideAction2161.super.ctor(self)

  self.info = "添加一些志同道合的人"
  self.moduleName = ModuleName.ChatModule
  self.panelName = "ChatPanel"
  
end

function GuideAction2161:onEnter(guide)
   GuideAction2161.super.onEnter(self, guide)
end

return GuideAction2161
