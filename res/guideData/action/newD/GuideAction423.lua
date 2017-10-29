local GuideAction423 = class("GuideAction423", DialogueAction)

function GuideAction423:ctor()
    GuideAction423.super.ctor(self)
    
    self.info = "建造时间超5分钟用加速卡，升级更快哦"  --
    self.delayTimePre = 0.5     
end

return GuideAction423


