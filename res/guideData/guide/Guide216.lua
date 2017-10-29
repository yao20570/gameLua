local Guide216 = class("Guide216",Guide)

function Guide216: ctor (gameState)
   Guide216.super.ctor(self, gameState)

   self.ID = 216

   self:addActionName("JumpModuleAction")
   self:addActionName("GuideAction2161")
   self:addActionName("GuideAction2162")
  
  
end

return Guide216
