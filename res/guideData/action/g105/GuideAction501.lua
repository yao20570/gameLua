--region *.lua
--Date
--先跳转到RegionModule的关卡模块，关标指向对应的章节，描述“点击进入章节关卡”
--这个章节需要算出来 
local GuideAction501 = class("GuideAction501", AreaClickAction)

function GuideAction501:ctor()
    GuideAction501.super.ctor(self)
    
    self.info = "点击进入章节关卡"  --
    self.moduleName = ModuleName.RegionModule
    self.panelName = "CenterRegionPanel"
    self.widgetName = "panel102"
    --还需要滑动
    self.delayNextActionTime = 1
end

function GuideAction501:onEnter(guide)
    -- GuideAction501.super.onEnter(self, guide)

    local taskProxy = guide:getProxy(GameProxys.Task)
    self._taskProxy = taskProxy
    local chapter, _ = taskProxy:getGuideDungeonInfo()
    taskProxy:setGuideFlag(chapter)

    self.widgetName = "panel" .. chapter  --动态获取外部设置的章节值
    
    ModuleJumpManager:jump(ModuleName.RegionModule)

    local function delayJump()  
        GuideAction501.super.onEnter(self, guide)
    end
    --延时打开Guide 模块，避免章节Panel未处理完显示位置
    TimerManager:addOnce(500, delayJump, self)

end

--触发回调
function GuideAction501:callback(value)
	local touchCallbackValue = GuideAction501.super.callback(self, value)
	if touchCallbackValue == "close" then  --章节打不开，直接跳过引导
		self._isSkipAction = true
	end

    local guideChapter = self._taskProxy:getGuideFlag()
    if guideChapter then
        self._taskProxy:setGuideFlag(nil)
    end

end

function GuideAction501:delayNextAction()
	-- print("~~~~~~~delayNextAction()~~~~~~~~~", self._isSkipAction)
	if self._isSkipAction == true then
		self._guide:skipAction()
	else
		self:nextAction()
	end
end

return GuideAction501



--endregion
