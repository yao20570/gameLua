local GuideAction323 = class("GuideAction323", DialogueAction)

function GuideAction323:ctor()
    GuideAction323.super.ctor(self)
    
    self.info = "建造时间超5分钟用加速卡，升级更快哦"  --
    
end

return GuideAction323


