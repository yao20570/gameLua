townReportPanel = class("townReportPanel", BasicPanel)
townReportPanel.NAME = "townReportPanel"

function townReportPanel:ctor(panel,parent)
	self._panel = panel
	self._parent = parent

end


function townReportPanel:initPanel(reportInfo, listViewTown)
    self._reportInfo = reportInfo
    self._battleReportInfo = reportInfo.townBattleReport

    self._listViewTown = listViewTown
    self._listViewTown:setVisible(true)


    -- 3个item
    self._adapPanel = listViewTown:getItem(0)
    self._listView        = listViewTown:getItem(2)
    self._rewardPanel     = listViewTown:getItem(1)

    self._topPanel = self._adapPanel:getChildByName("topPanel")
    self._nameTxt = self._topPanel:getChildByName("nameTxt")
    self._posTxt = self._topPanel:getChildByName("posTxt")

    self._timeTxt01  = self._topPanel:getChildByName("timeTxt01")
    self._timeTxt02  = self._topPanel:getChildByName("timeTxt02")

    self._resultTxt     = self._topPanel:getChildByName("resultTxt")
    self._legionNameTxt = self._topPanel:getChildByName("legionNameTxt")
    self._tipTxt        = self._topPanel:getChildByName("tipTxt")

    --

    self._midPanel = self._adapPanel:getChildByName("midPanel")
    self._leftPanel = self._midPanel:getChildByName("leftPanel")
    self._rightPanel = self._midPanel:getChildByName("rightPanel")

    -- proxy
    self._cityWarProxy = self._parent:getProxy(GameProxys.CityWar)

    -- 设置属性    
    self:onUpdateAllReportPanel()
end


function townReportPanel:onUpdateAllReportPanel()
    local configInfo = self._cityWarProxy:getTownConfigInfoById(self._battleReportInfo.townId)
    self._nameTxt:setString(configInfo.stateName)
    
    local posX = configInfo.dataX
    local posY = configInfo.dataY
    self._posTxt:setString( string.format("(%s，%s)", posX, posY))
    

    self._timeTxt01:setString(TimeUtils:setTimestampToString6(self._battleReportInfo.endTime) )
    self._timeTxt02:setString("")
    local result = self._battleReportInfo.result

    -- //////////////////////////////////////////// 01，包括UI
    -- 战报结果
    if self._reportInfo.mailType == 1 or self._reportInfo.mailType == 2 then
        if result == 1 then
            self._resultTxt:setString(self:getTextWord(1215)) -- 进攻胜利
        else
            self._resultTxt:setString(self:getTextWord(1213)) -- "防守胜利"
        end
    end
    self._resultTxt:setColor(ColorUtils.wordGreenColor)

    local winLegionName = self._battleReportInfo.winLegionName
    -- 主语显示
    if winLegionName ~= "" then  
        self._legionNameTxt:setString(winLegionName) 
        self._tipTxt:setString(self:getTextWord(471021)) -- "获得郡城归属权"
    else
        self._legionNameTxt:setString(self:getTextWord(471037)) -- 郡城守卫军
        self._tipTxt:setString(self:getTextWord(471029)) -- "，无同盟获得本郡城的归属权
    end
    -- ////////////////////////////////////////////02 差异

    -- ////////////////////////////////////////////01
    NodeUtils:fixTwoNodePos(self._legionNameTxt, self._resultTxt)
    NodeUtils:fixTwoNodePos(self._resultTxt , self._tipTxt)
    -- ////////////////////////////////////////////02

    self:setMidPanel()

    self:setBattleListPanel()
    -- ////////////////////////////////////////////01
    self:setRewardPanel() -- 奖励层
    -- ////////////////////////////////////////////02
end

function townReportPanel:setMidPanel()

    self:setMidSidePanel(self._leftPanel, 1)
    self:setMidSidePanel(self._rightPanel, 2)
end

function townReportPanel:setMidSidePanel(sidePanel, index)

    local spareTeamBtn = sidePanel:getChildByName("spareTeamBtn")
    spareTeamBtn.index =  index
    spareTeamBtn.battleReportInfo = self._battleReportInfo
    spareTeamBtn.parent = self._parent

    ComponentUtils:addTouchEventListener(spareTeamBtn, self.onSpareTeamBtn)

    if index == 2 then
        if self._battleReportInfo.defendIsMonster == 1 then -- 0否 1是守军是否为怪物
            NodeUtils:setEnable(spareTeamBtn, false)
        else
            NodeUtils:setEnable(spareTeamBtn, true)
        end
    end
    -- 文本
    local numTxt = sidePanel:getChildByName("numTxt")
    local numTxt01 = sidePanel:getChildByName("numTxt01")
    local numTxt02 = sidePanel:getChildByName("numTxt02")

    if index == 1 then
        numTxt01:setString(self._battleReportInfo.attackTeamNum)
        numTxt02:setString("/"..self._battleReportInfo.attackTotalNum.."）")
    else
        numTxt01:setString(self._battleReportInfo.defendTeamNum)
        numTxt02:setString("/"..self._battleReportInfo.defendTotalNum.."）")
    end
    NodeUtils:fixTwoNodePos(numTxt, numTxt01)
    NodeUtils:fixTwoNodePos(numTxt01, numTxt02)
end



function townReportPanel:onSpareTeamBtn(sender)
    logger:info("点击：".. sender.index)
    local battleReportInfo = sender.battleReportInfo


    local teamList = {}

    if sender.index == 1 then
        teamList = battleReportInfo.attackIdleTeamList
    elseif sender.index == 2 then
        teamList = battleReportInfo.defendIdleTeamList
    end

    local panel = sender.parent:getPanel(MailSpareTeamPanel.NAME)
    panel:show(teamList)
end


-- //////////////////////////////////////////// 差异
------
-- 战斗列表
function townReportPanel:setBattleListPanel()
    self._attackTeamList = table.reverseList(clone(self._battleReportInfo.attackTeamList) )
    self._defendTeamList = table.reverseList(clone(self._battleReportInfo.defendTeamList) )

    local listData
    if #self._attackTeamList <= #self._defendTeamList then
        listData = self._defendTeamList
    else
        listData = self._attackTeamList
    end

    local itemPanel = self._listViewTown:getItem(2)
    itemPanel:setVisible(false)
    
    local items = self._listViewTown:getItems()
    -- 差别个数
    local diff = 1 
    if #listData > 0 then
        diff = #listData 
    end
    -- 删除多余
    for i = 1, #items do
        if #self._listViewTown:getItems() > 2 + diff then
            self._listViewTown:removeLastItem()
        else
            break
        end
    end

    
    local pushCloneData = {} -- 定时加载数据
    for i = 1, #listData do
        listData[i].iNum = i -- 添加标志字段
        
        if i == 1 then
            self:renderItem(itemPanel, listData[i], i - 1)
            itemPanel:setVisible(true)
        else
            if self._listViewTown:getItems()[2 + i] ~= nil then
                self:renderItem(self._listViewTown:getItems()[2 + i], listData[i], i - 1)
                self._listViewTown:getItems()[2 + i]:setVisible(true)
            else

                table.insert(pushCloneData, listData[i])
            end
        end
    end

    self:pushCloneItemPanel(pushCloneData)
end
-- //////////////////////////////////////////// 差异

-- 定时器缓慢加载处理
function townReportPanel:pushCloneItemPanel(pushCloneData)
    local itemPanel = self._listViewTown:getItem(2)
    local index = 1
    -- 定时器缓慢加载处理
    local function pushClone()
        local cloneItemPanel = itemPanel:clone()
        self:renderItem(cloneItemPanel, pushCloneData[index], pushCloneData[index].iNum - 1)
        self._listViewTown:pushBackCustomItem(cloneItemPanel)
        cloneItemPanel:setVisible(true)

        -- logger:info("加载："..pushCloneData[index].iNum)
        index = index + 1
        if index <= #pushCloneData then
            TimerManager:addOnce(30, pushClone, self)
        end
    end 

    if #pushCloneData ~= 0 then
        pushClone()
    end
end



-- 渲染itemPanel
function townReportPanel:renderItem(itemPanel, data, index)
    if itemPanel == nil then
        return 
    end
    
    index = index + 1

    local img01 = itemPanel:getChildByName("img01")
    local img02 = itemPanel:getChildByName("img02")
    img01:setVisible(true)
    img02:setVisible(true)


    local attackTeamInfo = self._attackTeamList[index]
    local defendTeamInfo = self._defendTeamList[index]
    
    if index%2 == 1 then
        TextureManager:updateImageView(img01, "images/newGui9Scale/S9ReportRedd01.png")  
        TextureManager:updateImageView(img02, "images/newGui9Scale/S9ReportBlue01.png")  
    elseif index%2 == 0 then
        TextureManager:updateImageView(img01, "images/newGui9Scale/S9ReportRedd02.png")  
        TextureManager:updateImageView(img02, "images/newGui9Scale/S9ReportBlue02.png")  
    end

    if attackTeamInfo == nil then
        img01:setVisible(false)
    else
        self:setTeamInfo(img01, attackTeamInfo)
    end

    if defendTeamInfo == nil then
        img02:setVisible(false)
    else
        self:setTeamInfo(img02, defendTeamInfo)
    end
end

-- 设置信息
function townReportPanel:setTeamInfo(img, info)
    local playerName = info.playerName 
    local legionName = info.legionName 
    local percent	 = info.percent		

    local nameTxt01  = img:getChildByName("nameTxt01")
    local nameTxt02  = img:getChildByName("nameTxt02")
    local loadBar    = img:getChildByName("loadBar")
    local percentTxt = loadBar:getChildByName("percentTxt")
    nameTxt01:setString(playerName)
    nameTxt02:setString(legionName)
    loadBar:setPercent(percent)
    percentTxt:setString(percent.."%")
    NodeUtils:fixTwoNodePos(nameTxt01, nameTxt02, 3)
end

function townReportPanel:setRewardPanel()
    local selfData = self._reportInfo.reward

    self._rewardPanel:setVisible(true)
	self:onUpdateItemPanel(self._rewardPanel, selfData)
end

function townReportPanel:onUpdateItemPanel(panel, data)
	local index = 1
--    t = {}
--    t.power  = data[1].power
--    t.typeid = data[1].typeid
--    t.num    = data[1].num
--    table.insert(data, t)
	for _,v in pairs(data) do
		local item = panel:getChildByName("item"..index)
		item:setVisible(true)
		local person = item:getChildByName("person")
		local config = ConfigDataManager:getConfigByPowerAndID(v.power,v.typeid)

		local tmp = {}
        tmp.power = v.power
        tmp.typeid = v.typeid
        tmp.num = v.num
		local icon = person.icon
        if icon == nil then
            icon = UIIcon.new(person, tmp, true, self._parent, nil)
            icon:setScale(0.9)
            person.icon = icon
        else
        	icon:updateData(tmp)
        end
		index = index + 1
	end
    ------
    --
	for i = index,6 do
		local item = panel:getChildByName("item"..i)
		item:setVisible(false)
	end 
end


