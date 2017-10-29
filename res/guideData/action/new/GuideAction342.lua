local GuideAction342 = class("GuideAction342", DialogueAction)

function GuideAction342:ctor()
    GuideAction342.super.ctor(self)
    
    self.info = "2名武将待命中，赶紧回城升级兵营解锁上阵位哦！"  --
    
end

function GuideAction342:onEnter(guide)
    GuideAction342.super.onEnter(self, guide)
end

function GuideAction342:callback(value)
    GuideAction342.super.callback(self, value)

    local module = self._guide:getModule(ModuleName.DungeonModule)
    module.srcModule = nil --清除掉来源关系
    self._guide:hideModule(ModuleName.DungeonModule)
    self._guide:hideModule(ModuleName.RegionModule)
end

return GuideAction342


