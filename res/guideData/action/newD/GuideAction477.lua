local GuideAction477 = class("GuideAction477", DialogueAction)

function GuideAction477:ctor()
    GuideAction477.super.ctor(self)
    
    self.info = "恭喜主公获得稀有道具，赶紧使用它吧"  --
    
end

function GuideAction477:callback(value)
    GuideAction477.super.callback(self, value)

    local module = self._guide:getModule(ModuleName.DungeonModule)
    module.srcModule = nil --清除掉来源关系
    self._guide:hideModule(ModuleName.DungeonModule)
    self._guide:hideModule(ModuleName.RegionModule)
end

return GuideAction477


