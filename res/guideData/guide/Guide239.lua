local Guide239 = class("Guide239",Guide)

function Guide239: ctor (gameState)
   Guide239.super.ctor(self, gameState)

   self.ID = 239    --匈奴远征

    --self:addActionName("MoveSceneAction")  --强制跳转到主界面行为，通用
    self:addActionName("GuideAction2391")  --对白
    self:addActionName("GuideAction2392")  --点击战役
    self:addActionName("GuideAction2393")  --点击远征
    self:addActionName("GuideAction2394")  --点击匈奴
    self:addActionName("GuideAction2395")  --点击延吉
    self:addActionName("GuideAction2396")  --对白
end

return Guide239
