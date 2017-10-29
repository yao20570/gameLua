local Guide234 = class("Guide234",Guide)

function Guide234: ctor (gameState)
   Guide234.super.ctor(self, gameState)

   self.ID = 234

    self:addActionName("MoveSceneAction")
    self:addActionName("GuideAction2341")
    --self:addActionName("GuideAction2342")
end

return Guide234
