local Guide240 = class("Guide240",Guide)

function Guide240: ctor (gameState)
   Guide240.super.ctor(self, gameState)

   self.ID = 240     --民心

    --self:addActionName("MoveSceneAction")  --强制跳转到主界面行为，通用
    self:addActionName("GuideAction2401")  --对白
    self:addActionName("GuideAction2402")  --点击战役
    self:addActionName("GuideAction2403")  --点击民心
    self:addActionName("GuideAction2404")  --对白
    --self:addActionName("GuideAction2405")  --对白
    --self:addActionName("GuideAction2406")  --关闭按钮
end

return Guide240
