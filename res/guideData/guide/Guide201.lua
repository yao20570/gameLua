local Guide201 = class("Guide201",Guide)

function Guide201: ctor (gameState)
   Guide201.super.ctor(self, gameState)

   self.ID = 201

   self:addActionName("MoveSceneAction")
   self:addActionName("GuideAction2011")
   self:addActionName("GuideAction2012")
  
  
end

return Guide201
