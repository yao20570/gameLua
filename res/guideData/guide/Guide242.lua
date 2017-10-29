local Guide242 = class("Guide242",Guide)

function Guide242: ctor (gameState)
   Guide242.super.ctor(self, gameState)

   self.ID = 242

    --self:addActionName("MoveSceneAction")  --强制跳转到主界面行为，通用
    self:addActionName("GuideAction2421")  --对白
    self:addActionName("MoveSceneAction")  --移动主城
    self:addActionName("GuideAction2422")  --点击军械坊
    self:addActionName("GuideAction2423")  --点击军械仓库
    self:addActionName("GuideAction2424")  --点击军械
    self:addActionName("GuideAction2425")  --点击装备
    self:addActionName("GuideAction2426")  --对话
    --self:addActionName("GuideAction2362")
end

return Guide242
