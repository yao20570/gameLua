
ScienceMuseumPanel = class("ScienceMuseumPanel", BasicPanel)
ScienceMuseumPanel.NAME = "ScienceMuseumPanel"

function ScienceMuseumPanel:ctor(view, panelName)
    ScienceMuseumPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function ScienceMuseumPanel:finalize()
    ScienceMuseumPanel.super.finalize(self)
end

function ScienceMuseumPanel:initPanel()
	ScienceMuseumPanel.super.initPanel(self)
	self:setBgType(ModulePanelBgType.NONE)
    local function commentCallback()
        self:onCommentBtn()
    end
    self:setCommentHandle(commentCallback, self)
    self:addTabControl()
end

function ScienceMuseumPanel:addTabControl()
    self._tabControl = UITabControl.new(self)
    self._tabControl:addTabPanel(ScienceBuildPanel.NAME, self:getTextWord(891))
    self._tabControl:addTabPanel(ScienceResearchPanel.NAME, self:getTextWord(8104))

    self._tabControl:setTabSelectByName(ScienceBuildPanel.NAME)

    self:onSetTitle()
end

--TODO 信息Title显示处理
function ScienceMuseumPanel:onUpdateBuildingInfo()
    self:onSetTitle()
end

function ScienceMuseumPanel:onSetTitle()
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo = buildingProxy:getCurBuildingInfo()
    local lv = buildingInfo.level

    local info = buildingProxy:getCurBuildingConfigInfo()
    local title = string.format("(Lv.%d)", lv)
    self:setTitle(true, "taixueyuan", true, title)

    -- self:setTitle(true, title)
end

function ScienceMuseumPanel:onClosePanelHandler()
    self.view:dispatchEvent(ScienceMuseumEvent.HIDE_SELF_EVENT)
end

-- 类型  1-兵营 2-武将 3-太学院 4-战法 5-军师 
function ScienceMuseumPanel:onCommentBtn()
    local proxy = self:getProxy(GameProxys.Comment)
    proxy:toCommentModule(3, 0)
end

function ScienceMuseumPanel:tabChangeMainPanelEvent()
    ScienceMuseumPanel.super.tabChangeMainPanelEvent(self) -- link
    local panel = self:getPanel(ScienceResearchPanel.NAME)
    self:setCommentBtnVisible(panel:isVisible())
end
