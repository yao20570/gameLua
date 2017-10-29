local Guide222 = class("Guide222",Guide)

function Guide222: ctor (gameState)
   Guide222.super.ctor(self, gameState)

   self.ID = 222

  
   self:addActionName("GuideAction2221")
   self:addActionName("GuideAction2222")
   --self:addActionName("GuideAction2223")
  
end

return Guide222
