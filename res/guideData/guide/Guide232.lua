local Guide232 = class("Guide232",Guide)

function Guide232: ctor (gameState)
   Guide232.super.ctor(self, gameState)

   self.ID = 232

    self:addActionName("MoveSceneAction")
    self:addActionName("GuideAction2321")
    --self:addActionName("GuideAction2322")
end

return Guide232
