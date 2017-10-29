local GuideAction2151 = class( "GuideAction101", DialogueAction)
function GuideAction2151:ctor()
   GuideAction2151.super.ctor(self)

  self.info = "没事就到世界聊天"
  self.moduleName = ModuleName.ChatModule
  self.panelName = "ChatPanel"
  
end

function GuideAction2151:onEnter(guide)
   GuideAction2151.super.onEnter(self, guide)
end

return GuideAction2151
