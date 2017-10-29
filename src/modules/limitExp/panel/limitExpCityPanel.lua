-- -------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------
-- 西域远征：布阵界面
-- -------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------
limitExpCityPanel = class("limitExpCityPanel", BasicPanel)
limitExpCityPanel.NAME = "limitExpCityPanel"

function limitExpCityPanel:ctor(view, panelName)
    limitExpCityPanel.super.ctor(self, view, panelName,true)
    
    self:setUseNewPanelBg(true)
end

function limitExpCityPanel:finalize()
    if self.UITeamDetailPanel then
       self.UITeamDetailPanel:finalize() 
    end

    limitExpCityPanel.super.finalize(self)
end

function limitExpCityPanel:initPanel()
    limitExpCityPanel.super.initPanel(self)
    self:setTitle(true,"budui",true)
    self:setBgType(ModulePanelBgType.TEAM)

    -- local panel = self:getChildByName("mainPanel")
    -- if panel then
    --     panel:setVisible(false)
    -- end
end

function limitExpCityPanel:registerEvents()
    limitExpCityPanel.super.registerEvents(self)
end

function limitExpCityPanel:onClosePanelHandler()
    local panel = self:getPanel(LimitExpPanel.NAME)
    panel:setVisible(true)
    self:hide()
end

function limitExpCityPanel:onCloseCallback()
    self:onClosePanelHandler()
    local panel = self:getPanel(LimitExpPanel.NAME)
    if panel:isVisible() == true then

        -- 加遮罩 解决布阵点击出战按钮后点击到主界面挑战按钮问题
        local layout = panel:getChildByName("mask")
        if layout == nil then
            layout = ccui.Layout:create()
            local winSize = cc.Director:getInstance():getWinSize()
            layout:setContentSize(winSize)
            layout:setPosition(cc.p(0, 0))
            layout:setAnchorPoint(0, 0)
            layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
            layout:setLocalZOrder(9999)
            layout:setTouchEnabled(true)
            layout:setName("mask")
            panel:addChild(layout)
        end
        layout:setVisible(true)
        -- print("==屏蔽 panel:setMask(true)==")
    else
        -- print("==取消 panel:setMask(false)==")
        local layout = panel:getChildByName("mask")
        if layout ~= nil then
            layout:setVisible(false)
        end

    end
end

function limitExpCityPanel:onShowHandler(data)
    local uiType = 2

    data.extra = {
        isShowStar = false,   --星星
        isShowLost = false,   --战损
        isShowSleep = false,  --挂机
        -- targetName = "皇军贼",     --行军目标
    }    

    local teamDetail = self:getProxy(GameProxys.TeamDetail)
    teamDetail:setEnterTeamDetailType(1)

    if self.UITeamDetailPanel then
        self.UITeamDetailPanel:onUpdateData(data,uiType)
    else
        self.UITeamDetailPanel = UITeamDetailPanel.new(self,data,uiType)
    end

    if not self:isRunShowPanelAction() then
        self:showPanelAction()
    end
end

function limitExpCityPanel:panelActionCallback()
    local panel = self:getPanel(LimitExpPanel.NAME)
    panel:setVisible(false)
end


