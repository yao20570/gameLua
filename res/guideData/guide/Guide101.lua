local Guide101 = class("Guide101",Guide)

function Guide101:ctor(gameState)
    Guide101.super.ctor(self, gameState)
    
    self.id = 101
    
    self:addActionName("GuideAction101")
    self:addActionName("GuideAction102")
    self:addActionName("BattleAutoExitAction") --一定要执行 3
    self:addActionName("GuideAction103")
    self:addActionName("BattleAutoExitAction")  --一定要执行 5
    self:addActionName("GuideAction104")
end

return Guide101