local Guide235 = class("Guide235",Guide)

function Guide235: ctor (gameState)
   Guide235.super.ctor(self, gameState)

   self.ID = 235

    self:addActionName("MoveSceneAction")
    self:addActionName("GuideAction2351")
    --self:addActionName("GuideAction2352")
end

return Guide235
