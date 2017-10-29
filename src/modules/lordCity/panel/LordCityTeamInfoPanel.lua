-- 查看对方阵型信息
---------------------------------------------------------------------------------------
LordCityTeamInfoPanel = class("LordCityTeamInfoPanel", BasicPanel)
LordCityTeamInfoPanel.NAME = "LordCityTeamInfoPanel"

function LordCityTeamInfoPanel:ctor(view, panelName)
    LordCityTeamInfoPanel.super.ctor(self, view, panelName, true)
end

function LordCityTeamInfoPanel:finalize()
	if self._uITeamMiPanel then
	    self._uITeamMiPanel:finalize()
	end
    LordCityTeamInfoPanel.super.finalize(self)
end

function LordCityTeamInfoPanel:initPanel()
	LordCityTeamInfoPanel.super.initPanel(self)
	self:setTitle(true,"teamInfo",true)
	self:setBgType(ModulePanelBgType.NONE)
	self:setLocalZOrder(1000)
	self._typeMap = {self:getTextWord(7050),self:getTextWord(7051),self:getTextWord(7052),self:getTextWord(7050),self:getTextWord(7053)}
end

function LordCityTeamInfoPanel:onClosePanelHandler()
    self:hide()
end

function LordCityTeamInfoPanel:show(data)
	LordCityTeamInfoPanel.super.show(self)
	self:onUpdateData(data)
end

function LordCityTeamInfoPanel:onUpdateData(data)
	if self:isVisible() ~= true then
		return
	end

	if self._uITeamMiPanel == nil then
		self._uITeamMiPanel = UITeamMiPanel.new(self,nil,6,nil,nil,true)
	end
	self._uITeamMiPanel:setSoliderList(nil)
	self._uITeamMiPanel:onCheckConsuData(data.fightInfos)
	self._uITeamMiPanel:setSoliderList(data.fightInfos)
	self._uITeamMiPanel:onShowConsuSuoImg(false)

	local adviserId
	for k,v in pairs(data.fightInfos) do
		if v.post == 9 then
			adviserId = v.adviserId
		end
	end


	local soleierProxy = self:getProxy(GameProxys.Soldier)
	local key = "teamTask"..data.id
	local remainTime = soleierProxy:getRemainTime(key)

	local fightCap = data.capacity
	local target = data.name
	local weight = data.load
	local curNum = data.soldierNum
	local maxNum = data.maxSoldierNum
	local time,statusStr

	if data.type == 1 or data.type == 2 then
		statusStr = self._typeMap[data.type]
        time = remainTime
	elseif data.type == 3 then
        local count = math.ceil(remainTime)
        time = count
		statusStr = remainTime <= 0 and self:getTextWord(7054) or self:getTextWord(7052)
	end

	self._uITeamMiPanel:setTargetCity(target)
	self._uITeamMiPanel:setFirstNumber()
	self._uITeamMiPanel:setCurrWeight(weight)
	self._uITeamMiPanel:setSolidertime(time)
	self._uITeamMiPanel:setCurrStatus(statusStr)

	self._uITeamMiPanel:setCurrFight(fightCap)
	self._uITeamMiPanel:setSolderCount(curNum,maxNum)
	self._uITeamMiPanel:showLostInfo(true,0)
	self._uITeamMiPanel:setConsuPosEnable(false)
	self._uITeamMiPanel:onShowConsuImgById(adviserId)

end