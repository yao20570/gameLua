local Guide238 = class("Guide238",Guide)

function Guide238: ctor (gameState)
   Guide238.super.ctor(self, gameState)

   self.ID = 238    --探宝

    --self:addActionName("MoveSceneAction")  --强制跳转到主界面行为，通用
    self:addActionName("GuideAction2381")  --对白
    self:addActionName("GuideAction2382")  --点击探宝按钮
    self:addActionName("GuideAction2383")  --对白
    --self:addActionName("GuideAction2384")  --点击命中战法的升级按钮
    --self:addActionName("GuideAction2385")  --对白
   -- self:addActionName("GuideAction2386")  --关闭按钮
end

return Guide238
