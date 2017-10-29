local Guide215 = class("Guide215",Guide)

function Guide215: ctor (gameState)
   Guide215.super.ctor(self, gameState)

   self.ID = 215

   self:addActionName("JumpModuleAction")
   self:addActionName("GuideAction2151")
   self:addActionName("GuideAction2152")
  
  
end

return Guide215
