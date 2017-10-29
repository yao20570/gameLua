local Guide212 = class("Guide212",Guide)

function Guide212: ctor (gameState)
   Guide212.super.ctor(self, gameState)

   self.ID = 212

   self:addActionName("MoveSceneAction")
   self:addActionName("GuideAction2121")
   self:addActionName("GuideAction2122")
   self:addActionName("GuideAction2123")
  
end

return Guide212
