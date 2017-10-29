-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2016-12-08
--  * @Description: 春节活动-爆竹酉礼
--  */
SpringSquibPanel = class("SpringSquibPanel", BasicPanel)
SpringSquibPanel.NAME = "SpringSquibPanel"

function SpringSquibPanel:ctor(view, panelName)
    SpringSquibPanel.super.ctor(self, view, panelName,true)
end

function SpringSquibPanel:finalize()
    SpringSquibPanel.super.finalize(self)
end

function SpringSquibPanel:initPanel()
	SpringSquibPanel.super.initPanel(self)
	self:addTabControl()
end


function SpringSquibPanel:addTabControl()
    self._tabControl = UITabControlOld.new(self)
    self._tabControl:addTabPanel(SpringSquibMainPanel.NAME, self:getTextWord(390000))
    self._tabControl:addTabPanel(SpringSquibRewardPanel.NAME, self:getTextWord(390001))
    self._tabControl:setTabSelectByName(SpringSquibMainPanel.NAME)
    self:setTitle(true, "baozhuyouli", true)
    self._tabControl:setTabTexturesByIndex(1,"images/springActivityIcon/x_off.png","images/springActivityIcon/x_on.png")
    self._tabControl:setTabTexturesByIndex(2,"images/springActivityIcon/x_off.png","images/springActivityIcon/x_on.png")
   
end

function SpringSquibPanel:registerEvents()
	SpringSquibPanel.super.registerEvents(self)
end

function SpringSquibPanel:onClosePanelHandler()
    self.view:dispatchEvent(SpringSquibEvent.HIDE_SELF_EVENT)
end