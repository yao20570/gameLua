local GuideAction2302 = class( "GuideAction101", DialogueAction)
function GuideAction2302:ctor()
   GuideAction2302.super.ctor(self)

    self.info = "选择武将上阵"
  
  
  
end

function GuideAction2302:onEnter(guide)
   GuideAction2302.super.onEnter(self, guide)
   local panel = guide:getPanel(ModuleName.EquipModule,"EquipMainPanelNewPanel")
   panel:show(2)
end

return GuideAction2302
