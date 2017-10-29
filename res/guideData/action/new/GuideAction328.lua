local GuideAction328 = class("GuideAction328", DialogueAction)

function GuideAction328:ctor()
    GuideAction328.super.ctor(self)
    
    self.info = "恭喜主公，我们赶紧派遣于禁到部队上"  --
    
end

function GuideAction328:onEnter(guide)
    GuideAction328.super.onEnter(self, guide)

    guide:hideModule(ModuleName.BagModule)
end

return GuideAction328


