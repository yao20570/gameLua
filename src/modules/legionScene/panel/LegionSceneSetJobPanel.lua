-- /**
--  * @DateTime:    2016-01-14 11:07:18
--  * @Description: 军团成员-设定职位
--  */

LegionSceneSetJobPanel = class("LegionSceneSetJobPanel", BasicPanel)
LegionSceneSetJobPanel.NAME = "LegionSceneSetJobPanel"

function LegionSceneSetJobPanel:ctor(view, panelName)
    LegionSceneSetJobPanel.super.ctor(self, view, panelName, 600)
    
    self:setUseNewPanelBg(true)
end

function LegionSceneSetJobPanel:finalize()
    LegionSceneSetJobPanel.super.finalize(self)
end

function LegionSceneSetJobPanel:initPanel()
	LegionSceneSetJobPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(3113))
	
	self._uiCheckBoxMap = {}
	local list = {}
	for index=1, 6 do

        local str = "xxx"
		local jobBox = self:getChildByName("mainPanel/jobBox" .. index)
        local checkBox = UICheckBox.new(jobBox, {{content = str}})
        table.insert(list, jobBox)
        checkBox:fixLabelMidPos()
        self._uiCheckBoxMap[index] = checkBox
	end
	
    local radioGroup = UIRadioGroup.new(list, 1)
    self._radioGroup = radioGroup

end

function LegionSceneSetJobPanel:onAfterActionHandler()
    self:onShowHandler()
end

function LegionSceneSetJobPanel:onShowHandler()
    if self:isModuleRunAction() then
        return
    end
end

function LegionSceneSetJobPanel:onShowHandlerNew(memberInfo)
    self._curMemberInfo = memberInfo

    local legionProxy = self:getProxy(GameProxys.Legion)     
    local mineInfo = legionProxy:getMineInfo()    
    local legionLevel = mineInfo.level

     for job=1, 6 do
        local jobName = legionProxy:getJobName(job)
        -- print("print...jobName = "..jobName..",len="..string.len(jobName))

        local str = jobName
        if string.len(jobName) == 0 and job <= 4 then
            str = self:getTextWord(3008)        
            if legionLevel < 3 and job == 2 then
                str = self:getTextWord(3002)
            elseif legionLevel < 6 and job == 3 then
                str = self:getTextWord(3003)
            elseif legionLevel < 9 and job == 4 then
                str = self:getTextWord(3004)
            end
        end

        local checkBox = self._uiCheckBoxMap[job]
        local mycolor="#9C724C"
        if string.sub(str,0,12)=="同盟等级" and string.sub(str,14,22)=="级开放" then
            mycolor="#555555"
        end
        local content = {{content = str,color=mycolor}}
        checkBox:updateContent(content)
        -- checkBox:fixLabelMidPos()
        -- print("content len="..string.len(str))
            local x, y = checkBox._checkBox:getPosition()
            local size = checkBox._checkBox:getContentSize()
            -- checkBox._label:setColor(ColorUtils:color16ToC3b("#9C724C"))
            checkBox._label:setPosition(x + size.width / 2 + 10, y + size.height / 2 +5)
     end
     
     self._radioGroup:setSelectIndex(memberInfo.job)
end


function LegionSceneSetJobPanel:registerEvents()
	LegionSceneSetJobPanel.super.registerEvents(self)
	
    local okBtn = self:getChildByName("mainPanel/okBtn")
    local cancelBtn = self:getChildByName("mainPanel/cancelBtn")
    -- local closeBtn = self:getChildByName("mainPanel/closeBtn")
    
    self:addTouchEventListener(okBtn, self.onOkBtnTouch)
    self:addTouchEventListener(cancelBtn, self.onCancelBtnTouch)
    -- self:addTouchEventListener(closeBtn, self.onCancelBtnTouch)
end

function LegionSceneSetJobPanel:onOkBtnTouch(sender)
   --TODO 保存职位设置
    local job = self._radioGroup:getCurSelectIndex()
    if job > 0 then
        local legionProxy = self:getProxy(GameProxys.Legion)
        local jobName = legionProxy:getJobName(job)
        if string.len(jobName) == 0 then
            -- 该职位未编辑
            self:showSysMessage(self:getTextWord(3009))
            return
        end

        local data = {}
        data.type = 1
        data.id = self._curMemberInfo.id
        data.job = job
        local legionProxy = self:getProxy(GameProxys.Legion)
        legionProxy:onTriggerNet220221Req(data)

        -- 关闭界面
        self:onCancelBtnTouch(sender)
    end
end

function LegionSceneSetJobPanel:onCancelBtnTouch(sender)
    self:hide()
end






