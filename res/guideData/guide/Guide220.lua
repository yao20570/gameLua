local Guide220 = class("Guide220",Guide)

function Guide220: ctor (gameState)
   Guide220.super.ctor(self, gameState)

   self.ID = 220

  
   self:addActionName("GuideAction2201")
   self:addActionName("GuideAction2202")
   self:addActionName("GuideAction2203")
  
end

return Guide220
