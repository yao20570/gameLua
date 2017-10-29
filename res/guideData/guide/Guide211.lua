local Guide211 = class("Guide211",Guide)

function Guide211: ctor (gameState)
   Guide211.super.ctor(self, gameState)

   self.ID = 211

  
   self:addActionName("GuideAction2111")
   self:addActionName("GuideAction2112")
   self:addActionName("GuideAction2113")
  
end

return Guide211
