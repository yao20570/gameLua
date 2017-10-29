local Guide202 = class("Guide202",Guide)

function Guide202: ctor (gameState)
   Guide202.super.ctor(self, gameState)

   self.ID = 202

   self:addActionName("MoveSceneAction")
   self:addActionName("GuideAction2021")
   self:addActionName("GuideAction2022")
  
  
end

return Guide202
