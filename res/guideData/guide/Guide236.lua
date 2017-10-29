local Guide236 = class("Guide236",Guide)

function Guide236: ctor (gameState)
   Guide236.super.ctor(self, gameState)

   self.ID = 236

    self:addActionName("MoveSceneAction")
    self:addActionName("GuideAction2361")
    --self:addActionName("GuideAction2362")
end

return Guide236
