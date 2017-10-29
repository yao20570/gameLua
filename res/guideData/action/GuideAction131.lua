local GuideAction101 = class("GuideAction101", DialogueAction)

function GuideAction101:ctor()
    GuideAction101.super.ctor(self)
    
    self.info = "主公，资源是升建筑和发展的保证。"  --
    
end

function GuideAction101:onEnter(guide)
    GuideAction101.super.onEnter(self, guide)

    guide:hideModule(ModuleName.DungeonModule)
    guide:hideModule(ModuleName.InstanceModule)
end


return GuideAction101