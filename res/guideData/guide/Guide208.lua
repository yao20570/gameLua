local Guide208 = class("Guide208",Guide)

function Guide208: ctor (gameState)
   Guide208.super.ctor(self, gameState)

   self.ID = 208

   self:addActionName("MoveSceneAction")
   self:addActionName("GuideAction2081")
   self:addActionName("GuideAction2082")
   --self:addActionName("GuideAction2083")
   --self:addActionName("GuideAction2084")
end

return Guide208
