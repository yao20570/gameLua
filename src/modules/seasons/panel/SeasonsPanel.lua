-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 四季系统
--  */
SeasonsPanel = class("SeasonsPanel", BasicPanel)
SeasonsPanel.NAME = "SeasonsPanel"

function SeasonsPanel:ctor(view, panelName)
    SeasonsPanel.super.ctor(self, view, panelName, 600)

    self:setTanChuangBgSize(true,0,0)
    --self:setUseNewPanelBg(true)
end

function SeasonsPanel:finalize()
    SeasonsPanel.super.finalize(self)
end

function SeasonsPanel:doLayout()  
	
end

function SeasonsPanel:initPanel()
	SeasonsPanel.super.initPanel(self)

    
    self:setTitle(true, "世界", false)

	self._pnlMain = self:getChildByName("pnlMain")
	self._pnlTab = self._pnlMain:getChildByName("pnlTab")


end

function SeasonsPanel:registerEvents()
	SeasonsPanel.super.registerEvents(self)
end


function SeasonsPanel:onShowHandler()

	if not self._UITabForTanChuang then
	    self._UITabForTanChuang = UITabForTanChuang.new({
	        adaptivePanel = self._pnlTab, --[node]:适配panle,页签会根据这个panle的size来设置scrollView的size
	    	basicPanel = self,
	    })

	    self._UITabForTanChuang:addTabPanel(SeasonsFourSeasonPanel.NAME,self:getTextWord(500001))
	    self._UITabForTanChuang:addTabPanel(SeasonsWorldLevel.NAME,self:getTextWord(500002))
	    self._UITabForTanChuang:setSelectTabIdx(1)
	    -- self._UITabForTanChuang:setOpenConditionCallback(self,self.openConditionCallback)
	    
	end

    local seasonsFourSeasonPanel = self:getPanel(SeasonsFourSeasonPanel.NAME)
    seasonsFourSeasonPanel:showAction();
end

function SeasonsPanel:onHideHandler()
	if self._UITabForTanChuang then
		self._UITabForTanChuang:finalize()
		self._UITabForTanChuang = nil
	end
	self:dispatchEvent(SeasonsEvent.HIDE_SELF_EVENT)   
end

-- function SeasonsPanel:openConditionCallback(data,idx)
--     local proxy = self:getProxy(GameProxys.Seasons)
-- 	if data.skinName ==  SeasonsWorldLevel.NAME then --世界等级
-- 		if proxy:isWorldLevelOpen() then
-- 			return true
-- 		else
--         	self:showSysMessage(TextWords:getTextWord(500004))
-- 			return false
-- 		end
-- 	end
-- 	return true
-- end
