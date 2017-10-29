------------阵型详细信息

WarlordsTeamInfoPanel = class("WarlordsTeamInfoPanel", BasicPanel)
WarlordsTeamInfoPanel.NAME = "WarlordsTeamInfoPanel"

function WarlordsTeamInfoPanel:ctor(view, panelName)
    WarlordsTeamInfoPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function WarlordsTeamInfoPanel:finalize()
	if self._uITeamMiPanel then
	    self._uITeamMiPanel:finalize()
	end
    WarlordsTeamInfoPanel.super.finalize(self)
end

function WarlordsTeamInfoPanel:initPanel()
	WarlordsTeamInfoPanel.super.initPanel(self)
	self:setTitle(true,"teamInfo",true)
	self:setBgType(ModulePanelBgType.TEAM)
	self._battleActivityProxy = self:getProxy(GameProxys.BattleActivity)
	self._typeMap = {self:getTextWord(7050),self:getTextWord(7051),self:getTextWord(7052),self:getTextWord(7050),self:getTextWord(7053)}
end

function WarlordsTeamInfoPanel:onClosePanelHandler()
    self:hide()
end

function WarlordsTeamInfoPanel:onClose()
	self:onClosePanelHandler()
end

function WarlordsTeamInfoPanel:onShowHandler()
	local data = self._battleActivityProxy:onGetFightInfos()
	self:onUpdateData(data)
end

function WarlordsTeamInfoPanel:onUpdateData(data)
	if self._uITeamMiPanel == nil then
        local topPanel = self:topAdaptivePanel()
        topPanel.topOffset = GlobalConfig.topAdaptive
		self._uITeamMiPanel = UITeamMiPanel.new(self,nil,6,nil,topPanel,true)
		self._uITeamMiPanel:setSrcType(1)
	end

	self._uITeamMiPanel:setSoliderList(nil)
	-- self._uITeamMiPanel:onCheckConsuData(data)
	self._uITeamMiPanel:setSoliderList(data)
	self._uITeamMiPanel:onShowConsuSuoImg(false)

	local saveData = self._battleActivityProxy:onGetSaveData()
	if saveData then
		-- 战力显示
		self._uITeamMiPanel:setCurrFight(saveData.fight)
		self._uITeamMiPanel:setQXZLSolderCount(saveData.count,saveData.total)
		self._uITeamMiPanel:setSrcType(0)
	-- else
	-- 	self._uITeamMiPanel:setfightPosMap(1)
	end

	
	-- for k,v in pairs(data) do
	-- 	print(v.post)
	-- end

	local posData = {}
	for k,v in pairs(data) do
		posData[k] = v.num > 0
	end

	local adviserId, adviserLv
	for k,v in pairs(data) do
		if v.post == 9 then
			adviserId = v.typeid
			adviserLv = v.adviserLv
		end
	end
	if adviserId ~= nil then
		self._uITeamMiPanel:setAdviserData(adviserLv, adviserId)
	else
		self._uITeamMiPanel:setAdviserData(0, -100)
	end
	self._uITeamMiPanel:updatePosOpenStatus(posData)
    self._uITeamMiPanel:onShowBtnAndLabel()
end
