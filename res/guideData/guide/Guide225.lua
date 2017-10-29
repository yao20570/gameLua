local Guide225 = class("Guide225",Guide)

function Guide225: ctor (gameState)
   Guide225.super.ctor(self, gameState)

   self.ID = 225

   self:addActionName("MoveSceneAction")
   self:addActionName("GuideAction2251")
 
  
end

return Guide225
