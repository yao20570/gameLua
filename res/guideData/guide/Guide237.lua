local Guide237 = class("Guide237",Guide)

function Guide237: ctor (gameState)
   Guide237.super.ctor(self, gameState)

   self.ID = 237

    --self:addActionName("MoveSceneAction")  --强制跳转到主界面行为，通用
    self:addActionName("GuideAction2371")  --对白
    self:addActionName("GuideAction2372")  --点击头像
    self:addActionName("GuideAction2373")  --点击战法按钮
    self:addActionName("GuideAction2374")  --点击命中战法的升级按钮
    self:addActionName("GuideAction2375")  --对白
    self:addActionName("GuideAction2376")  --关闭按钮
end

return Guide237
