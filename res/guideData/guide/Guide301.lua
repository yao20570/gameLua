local Guide301 = class("Guide301",Guide)

function Guide301: ctor (gameState)
   Guide301.super.ctor(self, gameState)

   self.ID = 301

    
    self:addActionName("DialogAction3001")  --对白    
end

return Guide301
