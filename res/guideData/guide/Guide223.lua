local Guide223 = class("Guide223",Guide)

function Guide223: ctor (gameState)
   Guide223.super.ctor(self, gameState)

   self.ID = 223

   self:addActionName("MoveSceneAction")
   self:addActionName("GuideAction2231")
   self:addActionName("GuideAction2232")
  
  
end

return Guide223
