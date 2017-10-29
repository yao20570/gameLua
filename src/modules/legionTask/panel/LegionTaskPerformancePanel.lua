-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
LegionTaskPerformancePanel = class("LegionTaskPerformancePanel", BasicPanel)
LegionTaskPerformancePanel.NAME = "LegionTaskPerformancePanel"

function LegionTaskPerformancePanel:ctor(view, panelName)
    LegionTaskPerformancePanel.super.ctor(self, view, panelName)

end

function LegionTaskPerformancePanel:finalize()
    LegionTaskPerformancePanel.super.finalize(self)
end

function LegionTaskPerformancePanel:initPanel()
	LegionTaskPerformancePanel.super.initPanel(self)

	self._mainPanel = self:getChildByName("mainPanel")
	self.legionProxy = self:getProxy(GameProxys.Legion)
end

function LegionTaskPerformancePanel:registerEvents()
	LegionTaskPerformancePanel.super.registerEvents(self)
end

function LegionTaskPerformancePanel:doLayout()
	local taskPanel = self:getPanel(LegionTaskPanel.NAME)
	if taskPanel ~= nil then
		local taskTopPanel = taskPanel:getChildByName("panelTop")
		NodeUtils:adaptiveUpPanel(self._mainPanel,taskTopPanel,0)
		local topPanel = self._mainPanel:getChildByName("Image_22")
		-- NodeUtils:adaptivePanel(self._mainPanel)
		local PanelDown = taskPanel:getChildByName("PanelDown")
		-- NodeUtils:adaptiveUpPanel(PanelDown,self._mainPanel,0)
		local listView = self._mainPanel:getChildByName("taskList")
		NodeUtils:adaptiveListView(listView,PanelDown,topPanel,18)
	end 
end 

function LegionTaskPerformancePanel:onShowHandler()
	self:updateLegionTaskInfo()
end

function LegionTaskPerformancePanel:updateList(data)
	local taskList = self._mainPanel:getChildByName("taskList")
	self:renderListView(taskList, data, self, self.renderTemplate)
	taskList:setItemsMargin(0)
end

function LegionTaskPerformancePanel:renderTemplate(template,data,index)
	local nomalBg = template:getChildByName("nomalBg")
	local touchBg = template:getChildByName("touchBg")
	local isSelfBg = template:getChildByName("isSelfBg")
	local rankImg = template:getChildByName("rankImg")
	local rankLab = template:getChildByName("rankLab")
	local nameLab = template:getChildByName("nameLab")
	local levelLab = template:getChildByName("levelLab")
	local powerLab = template:getChildByName("powerLab")
	local performanceLab = template:getChildByName("performanceLab")

	if index % 2 == 1 then
 		nomalBg:setVisible(true)
        touchBg:setVisible(true)
    else
    	nomalBg:setVisible(true)
        touchBg:setVisible(false)
    end


    -- if self._mineID == memberInfo.id then
    --     mineBg:setVisible(true)
    --     print("is mine")
    --     mineBg:setOpacity(255)
    -- else
    --     mineBg:setVisible(false)
    --     print("is not mine")
    -- end

	local rank = data.rank
	local name = data.name
	local level = data.level
	local capacity = data.capacity
	local performance = data.performance
	rankImg:setVisible(false)

	--[[
		optional int32 rank = 1;		// 排名
		optional string name = 2;		// 名字
		optional int32 level = 3;		// 等级
		optional int64 capacity = 4;	// 国力
		optional int32 performance = 5;	// 绩效
	--]]

	if rank > 3 then
		rankLab:setString(rank)
		nameLab:setString(name)
	else  --榜单前三名
		local url = ""
		local color = ColorUtils.wordColor01
		if rank == 1 then
			url = "images/newGui2/IconNum_1.png"
			color = ColorUtils.wordAddColor
		elseif rank == 2 then
			url = "images/newGui2/IconNum_2.png"
			color = ColorUtils.wordPurpleColor
		elseif rank == 3 then
			url = "images/newGui2/IconNum_3.png"
			color = ColorUtils.wordBlueColor
		end
		-- print("rank img url",url)
		TextureManager:updateImageView(rankImg, url)
        rankImg:setVisible(true)

        rankLab:setString("")
		nameLab:setColor(color)
		nameLab:setString(name)
	end

	levelLab:setString(level)
	powerLab:setString(StringUtils:formatNumberByK(capacity, 0))--(capacity)
	performanceLab:setString(performance)
end

function LegionTaskPerformancePanel:updatePanelInfo(data)
	self:updateList(data.rankInfo)
end

--同盟数据刷新
function LegionTaskPerformancePanel:updateLegionTaskInfo()
	local taskInfo = self.legionProxy:getLegionTaskInfo()
	if taskInfo then
		self:updatePanelInfo(taskInfo)
	end 
end 