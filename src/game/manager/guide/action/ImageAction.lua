-- 似乎没用，暂时屏蔽
--ImageAction = class("DialogueAction", GuideAction)

--function ImageAction:ctor()
--    self.modelId = 0
--    self.imgId = 0
--end

--function ImageAction:onEnter(guide)
--    ImageAction.super.onEnter(self, guide)

--    local function callback()
--        self:callback()
--    end

--    local view = guide:getView()
--    if view == nil then  --TODO
--        GuideManager:skipGuide()

--        if _G["onLuaException"] ~= nil then 
--            setUserInfo(game.const.GameConfig.accountName)
--            onLuaException("引导异常", debug.traceback())
--        end
--        return
--    end
--    view:updateImgInfo(self, callback)

--end

--function ImageAction:callback()
--    self:nextAction()
--end
