
BarrackPanel = class("BarrackPanel", BasicPanel)
BarrackPanel.NAME = "BarrackPanel"

function BarrackPanel:ctor(view, panelName)
    BarrackPanel.super.ctor(self, view, panelName,true)

    self:setUseNewPanelBg(true)
end

function BarrackPanel:finalize()
    BarrackPanel.super.finalize(self)
end

function BarrackPanel:initPanel()
	BarrackPanel.super.initPanel(self)
	
	self:addTabControl()
	
	local closeBtn = self:getCloseBtn()
    self["closeBtn"] = closeBtn
--	self:setBgType(ModulePanelBgType.WHITE)
    self:setBgType(ModulePanelBgType.NONE)
end

function BarrackPanel:addTabControl()
    self._tabControl = UITabControl.new(self)
    self._tabControl:addTabPanel(BarrackBuildPanel.NAME, self:getTextWord(801))
    self._tabControl:addTabPanel(BarrackRecruitPanel.NAME, self:getTextWord(802))
    self._tabControl:addTabPanel(RecruitingPanel.NAME, self:getTextWord(803))

    self._tabControl:setTabSelectByName(BarrackBuildPanel.NAME)

    self:onSetTitle()
end

--TODO 信息Title显示处理
function BarrackPanel:onUpdateBuildingInfo()
    self:onSetTitle()
end

function BarrackPanel:onSetTitle()
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    local lv = buildingInfo.level
    
    local info = buildingProxy:getCurBuildingConfigInfo()
    local title = string.format("(Lv.%d)", lv) -- info.name .. 
    
    -- self:setTitle(true,"barrack",true)
--    self:setTitle(true, title)
    if info.type == BuildingTypeConfig.MAKE then --工匠坊
        self:setTitle(true, "gongjiangfang", true, title)
    elseif info.type == BuildingTypeConfig.BARRACK then --兵营
        self:setTitle(true, "bingying", true, title)
    elseif info.type == BuildingTypeConfig.REFORM then --校场
        self:setTitle(true, "jiaochang", true, title) 
        
    end
    
    self:checkOnlyBuild(info.lv, info.type) -- 0级校场只显示训练标签页

    self._tabControl:updateTabName(BarrackBuildPanel.NAME, 
        self:getTextWord(tonumber(string.format("8%d1", buildingInfo.buildingType))))
    self._tabControl:updateTabName(BarrackRecruitPanel.NAME, 
        self:getTextWord(tonumber(string.format("8%d2", buildingInfo.buildingType))))
    self._tabControl:updateTabName(RecruitingPanel.NAME, 
        self:getTextWord(tonumber(string.format("8%d3", buildingInfo.buildingType))))
end

function BarrackPanel:onClosePanelHandler()
    self.view:dispatchEvent(BarrackEvent.HIDE_SELF_EVENT)
end


------
-- 判断是否显示训练标签页
-- @param  args [obj] 参数
-- @return nil
function BarrackPanel:checkOnlyBuild(lv, buildType)
    local count = self._tabControl:getPanelCount()
    if count >= 2 then
        if lv == 0 and buildType == BuildingTypeConfig.REFORM then -- 0级校场
            for i = 2, count do
                self._tabControl:setTabVisibleByIndex(i, false)
            end
        else
            for i = 2, count do
                self._tabControl:setTabVisibleByIndex(i, true)
            end
        end
    end
end



