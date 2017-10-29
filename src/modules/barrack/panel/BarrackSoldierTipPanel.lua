-- /**
--  * @Author:
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description:
--  */
BarrackSoldierTipPanel = class("BarrackSoldierTipPanel", BasicPanel)
BarrackSoldierTipPanel.NAME = "BarrackSoldierTipPanel"


function BarrackSoldierTipPanel:ctor(view, panelName)
    BarrackSoldierTipPanel.super.ctor(self, view, panelName, 400)
    

end

function BarrackSoldierTipPanel:finalize()
    BarrackSoldierTipPanel.super.finalize(self)
end

function BarrackSoldierTipPanel:initPanel()
    BarrackSoldierTipPanel.super.initPanel(self)

    -- 代理
    self._proxy = self:getProxy(GameProxys.Soldier)

    -- 标题
    self:setTitle(true, self:getTextWord(8006))


    self._panelContainer = self:getChildByName("panelContainer")    
    self._txtSkillinfo = self._panelContainer:getChildByName("txtSkillinfo")    
    self._txtRestrain1 = self._panelContainer:getChildByName("txtRestrain1")    
    self._txtRestrain2 = self._panelContainer:getChildByName("txtRestrain2")    
    self._txtAuar1 = self._panelContainer:getChildByName("txtAuar1")    
    self._txtAuar2 = self._panelContainer:getChildByName("txtAuar2")
    
end

function BarrackSoldierTipPanel:registerEvents()
    BarrackSoldierTipPanel.super.registerEvents(self)
end


function BarrackSoldierTipPanel:onShowHandler(data)
    self._soldierId = data
    local soldierCfgData = ConfigDataManager:getConfigById(ConfigData.ArmKindsConfig, self._soldierId)
    self._txtSkillinfo:setString(soldierCfgData.skillinfo)
    self._txtRestrain1:setString(soldierCfgData.restrain1) 
    self._txtRestrain2:setString(soldierCfgData.restrain2) 
    self._txtAuar1:setString(soldierCfgData.auar1)
    self._txtAuar2:setString(soldierCfgData.auar2)
end 


-----------------------------------------------按钮事件----------------------------------------------
