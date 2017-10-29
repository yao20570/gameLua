local GuideAction484 = class("GuideAction484", DialogueAction)

function GuideAction484:ctor()
    GuideAction484.super.ctor(self)
    
    self.info = "我要换成剧情对白"  --
    
end

function GuideAction484:onEnter(guide)
    GuideAction484.super.onEnter(self, guide)
    
    guide:hideModule(ModuleName.PubModule)
end

return GuideAction484