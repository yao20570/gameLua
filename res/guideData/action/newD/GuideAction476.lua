local GuideAction476 = class("GuideAction476", AreaClickAction)

function GuideAction476:ctor()
    GuideAction476.super.ctor(self)
    
    self.info = "领取"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonRewardPanel"
    self.widgetName = "rewardBtn"
    self.delayTime = 1.5

    self.arrowDir = -1

    self.callbackDelayTime = 2
end

function GuideAction476:onEnter(guide)
    GuideAction476.super.onEnter(self, guide)
end

function GuideAction476:callback(value)
    GuideAction476.super.callback(self, value)
    local function callback()
        local module = self._guide:getModule(ModuleName.DungeonModule)
        module.srcModule = nil --清除掉来源关系
        self._guide:hideModule(ModuleName.DungeonModule)
        self._guide:hideModule(ModuleName.RegionModule)
    end

    TimerManager:addOnce(self.callbackDelayTime * 1000, callback, self)
end


return GuideAction476