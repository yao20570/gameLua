local Guide210 = class("Guide210",Guide)

function Guide210: ctor (gameState)
   Guide210.super.ctor(self, gameState)

   self.ID = 210

  
   self:addActionName("GuideAction2101")
   self:addActionName("GuideAction2102")
  
  
end

return Guide210
