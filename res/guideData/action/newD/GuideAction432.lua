local GuideAction432 = class("GuideAction432", DialogueAction)

function GuideAction432:ctor()
    GuideAction432.super.ctor(self)
    
    self.info = "战力飙升得多快。征兵、招将是涨战力最稳妥的方式"  --
    self.delayTime = 1 
    
end

function GuideAction432:onEnter(guide)
    GuideAction432.super.onEnter(self, guide)
    
    guide:hideModule(ModuleName.HeroModule)
end

return GuideAction432


