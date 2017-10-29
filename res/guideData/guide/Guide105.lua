--region *.lua
--Date
--关卡任务跳转 特有引导

local Guide105 = class("Guide105",Guide)

function Guide105:ctor(gameState)
    Guide105.super.ctor(self, gameState)
    
    self.id = 105
    
    self:addActionName("g105.GuideAction501")
    self:addActionName("g105.GuideAction502")
end

return Guide105


--endregion
