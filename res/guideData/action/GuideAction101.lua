local GuideAction101 = class("GuideAction101", DialogueAction)

function GuideAction101:ctor()
    GuideAction101.super.ctor(self)
    
    self.info = "主公！您终于来了！赶紧击溃黄巾军吧！"  --
    
end

function GuideAction101:onEnter(guide)
    GuideAction101.super.onEnter(self, guide)
    
    local dungeonProxy = guide:getProxy(GameProxys.Dungeon)
    dungeonProxy:onExterInstanceSender(0)
    
--    AudioManager:playEffect("guide01")
end

return GuideAction101