-- /**
--  * @Author:
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: ¾ü¹¤Íæ·¨
--  */
MapMilitaryPanel = class("MapMilitaryPanel", BasicPanel)
MapMilitaryPanel.NAME = "MapMilitaryPanel"

function MapMilitaryPanel:ctor(view, panelName)
    MapMilitaryPanel.super.ctor(self, view, panelName, 700)

    self:setTanChuangBgSize(true, 0, 0)
    -- self:setUseNewPanelBg(true)
end

function MapMilitaryPanel:finalize()
    if self._UITabForTanChuang then
        self._UITabForTanChuang:finalize()
        self._UITabForTanChuang = nil
    end
    MapMilitaryPanel.super.finalize(self)
end

function MapMilitaryPanel:doLayout()

end

function MapMilitaryPanel:initPanel()
    MapMilitaryPanel.super.initPanel(self)


    self:setTitle(true, self:getTextWord(540101), false)

    self._panelMain = self:getChildByName("panelMain")
    self._panelTab = self._panelMain:getChildByName("panelTab")

    self:setHtmlStr("html/help_military.html")
    self:setIsShowAndHideAction(false)
end

function MapMilitaryPanel:registerEvents()
    MapMilitaryPanel.super.registerEvents(self)
end


function MapMilitaryPanel:onShowHandler()
    if not self._UITabForTanChuang then
        local function callbackFunc(panelName)
            --self:updateRedPoint()
            if panelName == MapMilitaryTaskPanel.NAME then --军工
                if self:getProxy(GameProxys.Role):isFunctionUnLock(60, true) then
                    self._UITabForTanChuang:setSelectTabIdx(2)
                end 
            elseif panelName == MapMilitaryCentralTargetPanel.NAME then --中原目标
                 self._UITabForTanChuang:setSelectTabIdx(1)
            end 
        end 

        self._UITabForTanChuang = UITabForTanChuang.new( {
            adaptivePanel = self._panelTab,
            -- [node]:ÊÊÅäpanle,Ò³Ç©»á¸ù¾ÝÕâ¸öpanleµÄsizeÀ´ÉèÖÃscrollViewµÄsize
            basicPanel = self,
            callback = callbackFunc,
        } )
        self._UITabForTanChuang:addTabPanel(MapMilitaryCentralTargetPanel.NAME, self:getTextWord(540100))
        self._UITabForTanChuang:addTabPanel(MapMilitaryTaskPanel.NAME, self:getTextWord(540000))
        self._UITabForTanChuang:setSelectTabIdx(1)
    else
    self._UITabForTanChuang:setSelectTabIdx(1)
    end

    local militaryPanel = self:getPanel(MapMilitaryCentralTargetPanel.NAME)
    militaryPanel:showAction()


    militaryPanel:plainschapterUpdate()
    
    self:updateRedPoint()
end

function MapMilitaryPanel:onHideHandler()
    self:dispatchEvent(MapMilitaryEvent.HIDE_SELF_EVENT)
end

--角色信息更新(动态添加标签)
function MapMilitaryPanel:onGetRoleInfo()
    -- if self:getProxy(GameProxys.Role):isFunctionUnLock(60, true) then
    --     if not self._UITabForTanChuang:judgeIsHaveTabByName(MapMilitaryTaskPanel.NAME) then
    --         self._UITabForTanChuang:addTabPanel(MapMilitaryTaskPanel.NAME, self:getTextWord(540000))
    --     end 
    -- elseif self._UITabForTanChuang:judgeIsHaveTabByName(MapMilitaryTaskPanel.NAME) then 

    -- end 
end

--更新小红点
function MapMilitaryPanel:updateRedPoint()
    if self._UITabForTanChuang then
        local data = self._UITabForTanChuang:getTabPanel()
        for key,value in pairs(data) do
            if value[1] == MapMilitaryCentralTargetPanel.NAME then
                value[3] = self:getProxy(GameProxys.MapMilitary):getPlainsChapterRewardNum()
            elseif value[1] == MapMilitaryTaskPanel.NAME then
                value[3] = self:getProxy(GameProxys.MapMilitary):getRewardNum()
            end 
        end 
        self._UITabForTanChuang:reRender()
    end 
end 
