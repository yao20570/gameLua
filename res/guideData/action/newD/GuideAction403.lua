local GuideAction403 = class("GuideAction403", DialogueAction)

function GuideAction403:ctor()
    GuideAction403.super.ctor(self)
    
    self.info = "黄巾贼经常来掠夺庄稼，请大人为我们做主！"  --
    self.delayTimePre = 0.5     
end

return GuideAction403


