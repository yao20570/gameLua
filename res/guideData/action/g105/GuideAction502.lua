--region *.lua
--Date
-- 进入章节关卡内部，光标指向对应的副本，描述“这是您要挑战的关卡”
--这个关卡需要算出来 
local GuideAction502 = class("GuideAction502", AreaClickAction)

function GuideAction502:ctor()
    GuideAction502.super.ctor(self)
    
    self.info = "这是您要挑战的关卡"  --
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "city10"
    --还需要滑动
    self.delayTime = 1
end

function GuideAction502:onEnter(guide)
    GuideAction502.super.onEnter(self, guide)

    --获取需要引导的id，以及此时最大的关卡ID
   
    local taskProxy = guide:getProxy(GameProxys.Task)
    local chapter, dungeonId = taskProxy:getGuideDungeonInfo()

   --获取设置的章节
    local dungeonProxy = guide:getProxy(GameProxys.Dungeon)
    local maxId = dungeonProxy:getDungeonOpenNum(chapter)

    if dungeonId > maxId then
    	dungeonId = maxId
    	self.info = "先通过前面这些关卡"
    else
    	self.info = "这是您要挑战的关卡"
    end
    self.widgetName = "city" .. dungeonId

    --TODO，这里可能会有问题，模块还未打开
    local function jumpToPercentHorizontal()
    	local dungeonMapPanel = guide:getPanel(ModuleName.DungeonModule, "DungeonMapPanel")
        if dungeonMapPanel ~= nil then
        	dungeonMapPanel:jumpToPercentHorizontal(dungeonId)
        end
    end
    jumpToPercentHorizontal() --调整下副本地图显示区域
    
end

return GuideAction502
 



--endregion
