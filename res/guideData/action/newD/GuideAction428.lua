local GuideAction428 = class("GuideAction428", DialogueAction)

function GuideAction428:ctor()
    GuideAction428.super.ctor(self)
    
    self.info = "恭喜主公，我们赶紧派遣于禁到部队上"  --
    
end

function GuideAction428:onEnter(guide)
    GuideAction428.super.onEnter(self, guide)

    guide:hideModule(ModuleName.BagModule)
end

return GuideAction428


