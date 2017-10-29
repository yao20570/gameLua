local GuideAction358 = class("GuideAction358", DialogueAction)

function GuideAction358:ctor()
    GuideAction358.super.ctor(self)
    
    self.info = "主公，我要回军师府休息一下了，请笑纳一份厚礼，赶紧跟着任务节奏，成为一代帝王"  --
    self.deleyTime = 1
    
end

return GuideAction358


