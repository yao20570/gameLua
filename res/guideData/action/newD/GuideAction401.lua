local GuideAction401 = class("GuideAction401", DialogueAction)

function GuideAction401:ctor()
    GuideAction401.super.ctor(self)
    
    self.info = "主公，百姓夹道喜迎您的回归，赶紧进城吧！"  --
    self.delayTimePre = 0.5 
    
end

--进入引导了 跳转到世界地图模块
function GuideAction401:onEnter(guide)
    GuideAction401.super.onEnter(self, guide)

    guide:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.MapModule, isPerLoad = true})
    --这里应该直接跳转的，而不是切换动画

    local forxy = guide:getProxy(GameProxys.Dungeon)
    forxy:onTriggerNet60001Req({id = 101})   --TODO 这里要请求第一个

end


return GuideAction401


