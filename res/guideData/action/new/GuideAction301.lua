local GuideAction301 = class("GuideAction301", DialogueAction)

function GuideAction301:ctor()
    GuideAction301.super.ctor(self)
    
    self.info = "主公，百姓夹道喜迎您的回归，赶紧进城吧！"  --
    
end

--进入引导了 跳转到世界地图模块
function GuideAction301:onEnter(guide)
    GuideAction301.super.onEnter(self, guide)

    guide:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.MapModule, isPerLoad = true})
    --这里应该直接跳转的，而不是切换动画
end


return GuideAction301


