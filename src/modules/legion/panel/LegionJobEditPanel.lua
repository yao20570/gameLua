-- /**
--  * @DateTime:    2016-01-14 11:07:18
--  * @Description: 军团信息-职位编辑
--  */

LegionJobEditPanel = class("LegionJobEditPanel", BasicPanel)
LegionJobEditPanel.NAME = "LegionJobEditPanel"

function LegionJobEditPanel:ctor(view, panelName)
    LegionJobEditPanel.super.ctor(self, view, panelName, 600)
    
    self:setUseNewPanelBg(true)
end

function LegionJobEditPanel:finalize()
    LegionJobEditPanel.super.finalize(self)
end

function LegionJobEditPanel:initPanel()
	LegionJobEditPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(3019))

    local legionLevel = 1  --军团等级
	
	self._jobEditBoxMap = {}
	local infoPanel = self:getChildByName("mainPanel/infoPanel")
	for index=1, 4 do
		local jobLinePanel = infoPanel:getChildByName("jobLinePanel" .. index)
		local inputPanel = jobLinePanel:getChildByName("inputPanel")

        local str = 3105
        local isTrue = true
        if legionLevel < 3 and index == 2 then
            str = 3002
            isTrue = false
        elseif legionLevel < 6 and index == 3 then
            str = 3003
            isTrue = false
        elseif legionLevel < 9 and index == 4 then
            str = 3004
            isTrue = false
        end

        -- local editBox = ComponentUtils:addEditeBox(inputPanel, 4, self:getTextWord(str))
		local editBox = ComponentUtils:addEditeBox(inputPanel, 4, self:getTextWord(str), nil, true)
		inputPanel:setTouchEnabled(isTrue)
        jobLinePanel.editBox = editBox
		self._jobEditBoxMap[index] = editBox
	end
end

function LegionJobEditPanel:onAfterActionHandler()
    self:onShowHandler()
end

function LegionJobEditPanel:onShowHandler()
    if self:isModuleRunAction() then
        return
    end
    local infoPanel = self:getChildByName("mainPanel/infoPanel")
    -- print("job edit panel onShowHandler``````````````")
    local legionProxy = self:getProxy(GameProxys.Legion)
    local customJobInfos = legionProxy:getCustomJobInfos()
    self._mineInfo = legionProxy:getMineInfo()    
    self:rendeInfoPanel(infoPanel,customJobInfos)
    
end

function LegionJobEditPanel:rendeInfoPanel(infoPanel, customJobInfos)
    local index = 1
    for _, customJobInfo in pairs(customJobInfos) do
        local jobLinePanel = infoPanel:getChildByName("jobLinePanel" .. index)
        self:renderJobLinePanel(jobLinePanel, customJobInfo, index)
    	index = index + 1
    end
end

function LegionJobEditPanel:renderJobLinePanel(jobLinePanel, customJobInfo, index)
    local curNumTxt = jobLinePanel:getChildByName("curNumTxt")
    local editBox = jobLinePanel.editBox
    
    curNumTxt:setString(customJobInfo.curNum)
    editBox:setText(customJobInfo.name)

    local inputPanel = jobLinePanel:getChildByName("inputPanel")
    local str = customJobInfo.name
    local isTrue = true
    local legionLevel = self._mineInfo.level
    if index == 2 then
        if legionLevel >= 3 then
            str = self:getTextWord(3105)
            editBox:setPlaceHolder(str)
        else
            isTrue = false
        end
    elseif index == 3 then
        if legionLevel >= 6 then
            str = self:getTextWord(3105)
            editBox:setPlaceHolder(str)
        else
            isTrue = false
        end
    elseif index == 4 then
        if legionLevel >= 9 then
            str = self:getTextWord(3105)
            editBox:setPlaceHolder(str)
        else
            isTrue = false
        end

    end
    inputPanel:setTouchEnabled(isTrue)
    
    -- print("str = "..str)
    -- print("legionLevel = "..legionLevel)
end

function LegionJobEditPanel:registerEvents()
	LegionJobEditPanel.super.registerEvents(self)
	
	local okBtn = self:getChildByName("mainPanel/okBtn")
	local cancelBtn = self:getChildByName("mainPanel/cancelBtn")
	-- local closeBtn = self:getChildByName("mainPanel/closeBtn")
	
    self:addTouchEventListener(okBtn, self.onOkBtnTouch)	
    self:addTouchEventListener(cancelBtn, self.onCancelBtnTouch) 
    -- self:addTouchEventListener(closeBtn, self.onCancelBtnTouch)   
end

function LegionJobEditPanel:onOkBtnTouch(sender)
    --TODO 保存

    local legionProxy = self:getProxy(GameProxys.Legion)
    local customJobInfos = legionProxy:getCustomJobInfos()
    local data = {}
    local infos = {}
    for i=1,4 do
        local editBox = self._jobEditBoxMap[i]
        local txt = editBox:getText()
        if txt ~= customJobInfos[i].name then
            local info = {}
            info.index = i
            info.name = editBox:getText()
            table.insert(infos, info)

            logger:info("job name = "..info.name..",job len = "..string.len(info.name))
        end            
    end
    data.infos = infos


    -- local data = {}
    -- local infos = {}
    -- for index, editBox in pairs(self._jobEditBoxMap) do
    --     local info = {}
    --     info.index = index
    --     info.name = editBox:getText()
    --     table.insert(infos, info)
    -- end
    -- data.infos = infos
    
    local legionProxy = self:getProxy(GameProxys.Legion)
    legionProxy:onTriggerNet220220Req(data)
    
    -- self:hide()
end

function LegionJobEditPanel:onCancelBtnTouch(sender)
    self:hide()
end

function LegionJobEditPanel:onClosePanelHandler()
    self:hide()
end









