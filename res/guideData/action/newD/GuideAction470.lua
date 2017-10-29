local GuideAction470 = class("GuideAction470", DialogueAction)

function GuideAction470:ctor()
    GuideAction470.super.ctor(self)
    
    self.info = "主公威武，完美通关，还差6个星星就可以领取宝箱了哦"  --
    self.delayTimePre = 0.5     
end

return GuideAction470


