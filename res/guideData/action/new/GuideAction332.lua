local GuideAction332 = class("GuideAction332", DialogueAction)

function GuideAction332:ctor()
    GuideAction332.super.ctor(self)
    
    self.info = "战力飙升得多快。征兵、招将是涨战力最稳妥的方式"  --
    self.delayTime = 1 
    
end

function GuideAction332:onEnter(guide)
    GuideAction332.super.onEnter(self, guide)
    
    guide:hideModule(ModuleName.HeroModule)
end

return GuideAction332


