local Guide204 = class("Guide204",Guide)

function Guide204: ctor (gameState)
   Guide204.super.ctor(self, gameState)

   self.ID = 204

   self:addActionName("MoveSceneAction")
   self:addActionName("GuideAction2041")
   self:addActionName("GuideAction2042")
  
  
end

return Guide204
