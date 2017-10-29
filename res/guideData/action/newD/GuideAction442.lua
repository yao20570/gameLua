local GuideAction442 = class("GuideAction442", DialogueAction)

function GuideAction442:ctor()
    GuideAction442.super.ctor(self)
    
    self.info = "我们先回城商讨下对策，再来取得3星完美战绩"  --
    self.delayTimePre = 0.5     
end

function GuideAction442:onEnter(guide)
    GuideAction442.super.onEnter(self, guide)
end

function GuideAction442:callback(value)
    GuideAction442.super.callback(self, value)

    local module = self._guide:getModule(ModuleName.DungeonModule)
    module.srcModule = nil --清除掉来源关系
    self._guide:hideModule(ModuleName.DungeonModule)
    self._guide:hideModule(ModuleName.RegionModule)
end

return GuideAction442


