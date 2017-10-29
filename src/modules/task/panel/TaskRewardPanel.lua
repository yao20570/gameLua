-- 任务tip
TaskRewardPanel = class("TaskRewardPanel", BasicPanel)
TaskRewardPanel.NAME = "TaskRewardPanel"

function TaskRewardPanel:ctor(view, panelName)
    --TaskRewardPanel.super.ctor(self, view, panelName, 400, nil, true)
    TaskRewardPanel.super.ctor(self, view, panelName, 500)
    
    self:setUseNewPanelBg(true)
end

function TaskRewardPanel:finalize()
    TaskRewardPanel.super.finalize(self)
end

function TaskRewardPanel:initPanel()
	TaskRewardPanel.super.initPanel(self)
    
    self:setTitle(true, self:getTextWord(1343))
end

function TaskRewardPanel:onShowHandler(taskInfo)
    -- body
    if self._root == nil then
        local root = ccui.Layout:create()
        root:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
        root:setContentSize(cc.size(640,960))
        root:setLocalZOrder(2)
        self:addChild(root)
        self:addTouchEventListener(root, self.onClosePanelHandler)
        self._root = root
        self:setCloseBtnStatus(false)
    end


    local conf = taskInfo.conf

    local Image_2 = self:getChildByName("Panel_1/Image_2")
    local info = Image_2:getChildByName("info")
    local iconImg = Image_2:getChildByName("iconImg")
    local progress = Image_2:getChildByName("progress")
    local progressR = Image_2:getChildByName("progressR")

    local iconInfo = {}
    iconInfo.power = GamePowerConfig.Other
    iconInfo.typeid = conf.icon
    iconInfo.num = 0
    
    local icon = iconImg.icon
    if icon == nil then
        icon = UIIcon.new(iconImg,iconInfo,false)
        iconImg.icon = icon
    else
        icon:updateData(iconInfo)
    end 


    info:setString(conf.name)

    local curNum = tonumber(taskInfo.num)
    local maxNum = conf.finishcond2
    local color = nil
    if curNum >= maxNum then
        curNum = maxNum
        color = ColorUtils.wordColorDark03
    else
        color = ColorUtils.wordColorDark04
    end
    progress:setColor(color)

    local stype = conf.stype
    if stype == 10 or stype == 46 or stype == 47 or stype == 38 or stype == 5 or stype == 41 then  --任务小类 显示格式 进度：未完成/已完成
        -- 任务小类：战胜xxx，显示格式（进度：已完成/未完成）
        local str = ""
        if curNum < maxNum then
            str = self:getTextWord(1329)
        else
            str = self:getTextWord(1330)
        end
        progress:setString(str)
        progressR:setVisible(false)
    else
        if stype == 5 then  -- 任务小类：战胜xxx，显示格式（进度：0/1）
            maxNum = 1
            if curNum > maxNum then
                curNum = maxNum
            end
        end
        progressR:setVisible(true)
        progress:setString(curNum)
        progressR:setString("/"..maxNum)

        local size = progress:getContentSize()
        progressR:setPositionX(progress:getPositionX() + size.width)
    end





    local Panel_6 = Image_2:getChildByName("Panel_6")
    -- local Label_28 = Panel_6:getChildByName("Label_28")
    -- Label_28:setString(self:getTextWord(1324))


    local rewardID = StringUtils:jsonDecode(conf.fixreward)
    local iconTab = {1,2,3,4}
    local rewardTab = {}

    local TASKTYPE = taskInfo.TASKTYPE  -- 1:日常任务 tip增加显示经验
    if TASKTYPE ~= nil and TASKTYPE == 1 then
        local roleProxy = self:getProxy(GameProxys.Role)
        local playerLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level) or 0
        local taskStar = taskInfo.star or 0
        local expNumber = math.floor((500 + playerLevel * 25) * (1 + 0.2 * taskStar))
        local contentID = PlayerPowerDefine.POWER_exp
        local finalConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.ResourceConfig,"ID",contentID)
        
        local data = {}
        data.name = finalConfig.name
        data.picId = finalConfig.icon
        data.num = expNumber
        data.id = contentID
        data.type = GamePowerConfig.Resource
        data.color = nil

        table.insert( rewardTab, data )
    end

    for i=1,#rewardID do
        local rewardData = ConfigDataManager:getRewardConfigById(rewardID[i])
        table.insert( rewardTab, rewardData )
    end


    for i=1,#rewardTab do
        local rewardData = rewardTab[i]

        local iconImg = Panel_6:getChildByName("icon"..i)
        local iconName = iconImg:getChildByName("iconName")
        local iconValue = iconImg:getChildByName("iconValue")
        iconImg:setVisible(true)


        local num = rewardData.num
        local color = ColorUtils:getColorByQuality(rewardData.color)
        iconName:setColor(color)
        iconName:setString(rewardData.name)
        iconValue:setString("+"..num)
         
        if self:getProxy(GameProxys.RealName):isShowDebuff() then
            if rewardData.power == 407 and rewardData.typeid == 101 then
                local debuff = self:getProxy(GameProxys.RealName):getDebuff()
                num = math.floor(num* (1 - debuff))
                iconValue:setString("+"..num)
                logger:error("任务奖励未实名惩罚生效")
            end
        end

        local iconInfo = {}
        iconInfo.power = rewardData.power
        iconInfo.typeid = rewardData.typeid
        iconInfo.num = num
        
        local icon = iconImg.icon
        if icon == nil then
            icon = UIIcon.new(iconImg,iconInfo,false,self)
            iconImg.icon = icon
        else
            icon:updateData(iconInfo)
        end             

        table.remove(iconTab,1)
    end

    for i=1,#iconTab do
        local iconImg = Panel_6:getChildByName("icon"..iconTab[i])
        iconImg:setVisible(false)
    end

end

-- -- 点击icon
-- function TaskRewardPanel:onIconBtn(sender)
--     -- body
--     self:showSysMessage("onIconBtn")
-- end

function TaskRewardPanel:onClosePanelHandler()
    self:hide()
end
---------------------------------------------------------------------
