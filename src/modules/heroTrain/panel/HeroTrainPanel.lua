--
-- Author: zlf
-- Date: 2016年8月30日15:58:06
-- 英雄培养标签页


HeroTrainPanel = class("HeroTrainPanel", BasicPanel)
HeroTrainPanel.NAME = "HeroTrainPanel"

function HeroTrainPanel:ctor(view, panelName)
    HeroTrainPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function HeroTrainPanel:finalize()
    HeroTrainPanel.super.finalize(self)
    
end

function HeroTrainPanel:initPanel()
	HeroTrainPanel.super.initPanel(self)

	self:setBgType(ModulePanelBgType.NONE)

    local tabControl = UITabControl.new(self, self.openMethod)
    tabControl:addTabPanel(HeroLvUpPanel.NAME, self:getTextWord(810))
    tabControl:addTabPanel(HeroStarUpPanel.NAME, self:getTextWord(290000))
    tabControl:addTabPanel(HeroStrategicsPanel.NAME, self:getTextWord(290002))
    tabControl:setTabSelectByName(HeroLvUpPanel.NAME)

    self.allPanel = {HeroLvUpPanel.NAME, HeroStarUpPanel.NAME, HeroStrategicsPanel.NAME}

    self._tabControl = tabControl

    self:setTitle(true,"hero",true)

    self:setCloseMultiBtn(true)
end

function HeroTrainPanel:registerEvents()
	HeroTrainPanel.super.registerEvents(self)
end

function HeroTrainPanel:onClosePanelHandler()
    --关掉通用面板
    local name = self._tabControl:getCurPanelName()
    if name == HeroLvUpPanel.NAME then
        local panel = self:getPanel(name)
        local uiPanel = panel:getOtherPanel()
        if uiPanel ~= nil then
            local node = uiPanel:getRootNode()
            if node:isVisible() then
                node:setVisible(false)
                self:setTitle(true,"hero",true)
                panel:closeCallBack()
                return
            end
        end
    end
    self:dispatchEvent(HeroTrainEvent.HIDE_SELF_EVENT)
end

function HeroTrainPanel:openMethod(panelName)
    if panelName == HeroStarUpPanel.NAME then
        local heroData = self.view:readCurData()
        local proxy = self:getProxy(GameProxys.Hero)
        heroData = proxy:getInfoById(heroData.heroDbId)
        if heroData.heroLv < 20 then
            self:showSysMessage("当前武将达到20级后解锁")
        end
        return heroData.heroLv >= 20
    else
        return true
    end
end

function HeroTrainPanel:checkHeroLv()
    local heroData = self.view:readCurData()
    local proxy = self:getProxy(GameProxys.Hero)
    heroData = proxy:getInfoById(heroData.heroDbId)
    self._tabControl:setTabVisibleByIndex(3, heroData.heroLv >= 20)

    local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, heroData.heroId)
    --可升级提示
    local isHaveExpCard, count = proxy:isHaveExpCard()
    local isShow = isHaveExpCard and (config.lvmax > heroData.heroLv)
    self._tabControl:setItemCount(1, isShow, count)

    --可升星提示
    local enough = proxy:isCanStarUp(heroData)
    local num = enough and 1 or 0
    self._tabControl:setItemCount(2, enough, num)

    if heroData.heroLv < 20 then
        self._tabControl:setItemCount(2, false, 0)
    end
end