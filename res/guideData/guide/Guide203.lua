local Guide203 = class("Guide203",Guide)

function Guide203: ctor (gameState)
   Guide203.super.ctor(self, gameState)

   self.ID = 203

   self:addActionName("MoveSceneAction")
   self:addActionName("GuideAction2031")
   self:addActionName("GuideAction2032")
   self:addActionName("GuideAction2033")
  
end

return Guide203
