local Guide241 = class("Guide241",Guide)

function Guide241: ctor (gameState)
   Guide241.super.ctor(self, gameState)

    self.ID = 241  --解锁演武场

    --self:addActionName("MoveSceneAction")  --强制跳转到主界面行为，通用
    self:addActionName("GuideAction2411")  --对白：恭喜主公解锁演武场，挑战其他人得更好排名，可获得排行榜奖励哦
    self:addActionName("MoveSceneAction")  --移动主城
    self:addActionName("GuideAction2412")  --点击演武场
    self:addActionName("GuideAction2413")  --对白：让我们来设置最大战力吧
    self:addActionName("GuideAction2414")  --最大战力
    self:addActionName("GuideAction2415")  --保存阵型
    self:addActionName("GuideAction2416")  --对白

end

return Guide241
