local Guide233 = class("Guide233",Guide)

function Guide233: ctor (gameState)
   Guide233.super.ctor(self, gameState)

   self.ID = 233

    self:addActionName("MoveSceneAction")
    self:addActionName("GuideAction2331")
    --self:addActionName("GuideAction2332")
end

return Guide233
