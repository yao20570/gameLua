local GuideAction472 = class("GuideAction472", DialogueAction)

function GuideAction472:ctor()
    GuideAction472.super.ctor(self)
    
    self.info = "主公，敌方出动大量刀兵部队，先回城训练骑兵来克制他们"  --
    self.delayTimePre = 0.5     
end


function GuideAction472:callback(value)
    GuideAction472.super.callback(self, value)

    local module = self._guide:getModule(ModuleName.DungeonModule)
    module.srcModule = nil --清除掉来源关系
    self._guide:hideModule(ModuleName.DungeonModule)
    self._guide:hideModule(ModuleName.RegionModule)
end

return GuideAction472


