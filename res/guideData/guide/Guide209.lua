local Guide209 = class("Guide209",Guide)

function Guide209: ctor (gameState)
   Guide209.super.ctor(self, gameState)

   self.ID = 209

   self:addActionName("MoveSceneAction")
   self:addActionName("GuideAction2091")
   self:addActionName("GuideAction2092")
   self:addActionName("GuideAction2093")
  
end

return Guide209
