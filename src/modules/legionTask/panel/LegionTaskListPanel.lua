-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
LegionTaskListPanel = class("LegionTaskListPanel", BasicPanel)
LegionTaskListPanel.NAME = "LegionTaskListPanel"

function LegionTaskListPanel:ctor(view, panelName)
    LegionTaskListPanel.super.ctor(self, view, panelName)
end

function LegionTaskListPanel:finalize()
    LegionTaskListPanel.super.finalize(self)
end

function LegionTaskListPanel:initPanel()
	LegionTaskListPanel.super.initPanel(self)

	self._mainPanel = self:getChildByName("mainPanel")
	self.legionProxy = self:getProxy(GameProxys.Legion)
	self._roleProxy = self:getProxy(GameProxys.Role)
end

function LegionTaskListPanel:registerEvents()
	LegionTaskListPanel.super.registerEvents(self)
end

function LegionTaskListPanel:onShowHandler()
	self:updateLegionTaskInfo()
end 

function LegionTaskListPanel:doLayout()
	local taskPanel = self:getPanel(LegionTaskPanel.NAME)
	if taskPanel ~= nil then
		local taskTopPanel = taskPanel:getChildByName("panelTop")
		NodeUtils:adaptiveUpPanel(self._mainPanel,taskTopPanel,0)

		-- NodeUtils:adaptivePanel(self._mainPanel)

		local PanelDown = taskPanel:getChildByName("PanelDown")
		-- NodeUtils:adaptiveUpPanel(PanelDown,self._mainPanel,0)

		local listView = self._mainPanel:getChildByName("taskList")
		NodeUtils:adaptiveListView(listView,PanelDown,taskTopPanel,0)

		-- NodeUtils:adaptiveListView(listView, downPanel, self._panel,0)
	end 
end

local function sortFunc(a,b)
	return a.sort < b.sort
end 

function LegionTaskListPanel:updateList(data)
	local taskList = self._mainPanel:getChildByName("taskList")

	for k,v in pairs(data) do
		local taskInfo = ConfigDataManager:getConfigById(ConfigData.LegionTaskConfig,v.id)
		if taskInfo then
			v.sort = taskInfo.sort
			v.taskInfo = taskInfo
		end
	end
	table.sort(data,sortFunc)

	self:renderListView(taskList, data, self, self.renderTemplate)
	taskList:setItemsMargin(0)
end

function LegionTaskListPanel:renderTemplate(template,data,index)
	local bg_1 = template:getChildByName("templateBg_1")
	local bg_2 = template:getChildByName("templateBg_2")
	-- local icon = template:getChildByName("icon") --任务图标
	local taskDesLab = template:getChildByName("taskDesLab") --任务进度
	local scheduleValueLab = template:getChildByName("scheduleValueLab") --任务进度值

	local finishLab = template:getChildByName("finishLab") --完成次数
	local finishValue = template:getChildByName("finishValue") --完成次数值

	local gotoBtn = template:getChildByName("gotoBtn")

	--[[
		optional int32 id = 1;		// 任务ID
		optional int64 num = 2;		// 完成度
		optional int32 finish = 3;	// 已完成次数
	--]]

 	if index % 2 == 1 then
 		bg_1:setVisible(true)
        bg_2:setVisible(true)
    else
    	bg_1:setVisible(true)
        bg_2:setVisible(false)
    end

	local id = data.id
	local num = data.num
	local finish = data.finish

	local taskInfo = data.taskInfo
	if taskInfo then
		local taskType = taskInfo.type
		local function goToBtnOnTap()
			if taskInfo.jumpmodule then
				if taskInfo.jumpmodule == ModuleName.WarlordsModule then --群雄逐鹿
					local id = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_LegionId)
					if id <= 0 then
						self._roleProxy:showSysMessage(TextWords:getTextWord(280139))
						return
					end
					local battle = self:getProxy(GameProxys.BattleActivity)
					battle:onTriggerNet330000Req({activityId = 2})
					return
				elseif taskInfo.jumpmodule == ModuleName.WorldBossModule then --讨伐物资
					local battle = self:getProxy(GameProxys.BattleActivity)
	                local battleInfo = battle:getActivityInfoByUitype(ActivityDefine.SERVER_ACTION_WORLD_BOSS)
	              --   if battleInfo ~= nil then--and battleInfo.state == 1 then
	              --       self._roleProxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.WorldBossModule,extraMsg=battleInfo})
	            		-- return 
	              --   else
	             	if battleInfo == nil then 
	                	self:showSysMessage(TextWords:getTextWord(249992))
	                	return
	                end
				elseif taskInfo.jumpmodule == ModuleName.MapMilitaryModule then 
					if self._roleProxy:isFunctionUnLock(61, true) then
			            local moduleName = taskInfo.jumpmodule
			       	 	local panelName = taskInfo.reaches
			       	 	ModuleJumpManager:jump(moduleName, panelName)
			        	self:dispatchEvent(LegionTaskEvent.HIDE_SELF_EVENT, {})
			        	return 
			        end
			    elseif taskInfo.jumpmodule == ModuleName.LegionSceneModule then
			    	local legionId = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_LegionId)
			    	local moduleName,panelName
				    if legionId < 1 then
			            local isOpen = self._roleProxy:isFunctionUnLock(7)
			            if isOpen then
			                moduleName = ModuleName.LegionApplyModule
			                panelName = "LegionRecommendPanel"
			            end 
			        else
			            moduleName = ModuleName.LegionSceneModule
			            panelName = "LegionSceneHallPanel"
			        end
			        if panelName ~= nil and moduleName ~= nil then
			            ModuleJumpManager:jump(moduleName, panelName)
			            self:dispatchEvent(LegionTaskEvent.HIDE_SELF_EVENT, {})
			        end
			        return
			    elseif taskInfo.jumpmodule == ModuleName.LegionScienceTechModule then
			    	local moduleName = taskInfo.jumpmodule
			    	local panelName = "LegionScienceDonatePanel" --到捐献面板
			    	ModuleJumpManager:jump(moduleName, panelName)
			    	-- if taskInfo.reaches == "LegionScienceHallPanel" then  --等级捐献
			    	-- local function call()
			    	self.legionProxy:sendNotification(AppEvent.PROXY_LEGION_TASKINFO_JUMPTO,taskInfo.reaches)
			    	-- elseif taskInfo.reaches == "LegionScienceTechPanel" then --科技捐献
			    	-- end 
			    	-- 	TimerManager:addOnce(60,call,self)
			    	-- end
			    	return
				end

				local moduleName = taskInfo.jumpmodule
	       	 	local panelName = taskInfo.reaches    
	        	ModuleJumpManager:jump(moduleName, panelName)

	        	self:dispatchEvent(LegionTaskEvent.HIDE_SELF_EVENT, {})
			else 
			end 
		end
		--taskInfo.Icon 任务图标

		local iconInfo = {}
	    iconInfo.power = GamePowerConfig.Other
	    iconInfo.typeid = taskInfo.Icon
	    iconInfo.num = 0

	    local icon = template.icon
	    if icon == nil then
	        local iconImg = template:getChildByName("icon")
	        icon = UIIcon.new(iconImg,iconInfo,false)        
	        template.icon = icon
	    else
	        icon:updateData(iconInfo)
	    end
	    icon:setTouchEnabled(false)

		taskDesLab:setString(taskInfo.describe)
		scheduleValueLab:setString(num .. "/" .. taskInfo.finishcond2)
		finishValue:setString(finish .. "/" .. taskInfo.limit)

		self:addTouchEventListener(gotoBtn,goToBtnOnTap)
	end
end


function LegionTaskListPanel:updatePanelInfo(data)
	self:updateList(data.taskList)
end

--同盟数据刷新
function LegionTaskListPanel:updateLegionTaskInfo()
	local taskInfo = self.legionProxy:getLegionTaskInfo()
	if taskInfo then
		self:updatePanelInfo(taskInfo)
	end 
end 