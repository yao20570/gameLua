local Guide230 = class("Guide230",Guide)

function Guide230: ctor (gameState)
   Guide230.super.ctor(self, gameState)

   self.ID = 230

   self:addActionName("MoveSceneAction")
   self:addActionName("GuideAction2301")
   self:addActionName("GuideAction2302")
end

return Guide230
