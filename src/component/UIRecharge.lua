--UI控件功能：元宝不足的弹窗
--Time:2016/03/22
--Author:FZW
--How to use ? 参考 DailyTaskPanel:onMessageBox()

UIRecharge = class("UIRecharge")

function UIRecharge:ctor(parent, panel)
    local uiSkin = UISkin.new("UIReCharge")
    local parent = panel:getLayer(ModuleLayer.UI_TOP_LAYER)
    uiSkin:setParent(parent)
    uiSkin:setName(GlobalConfig.uitopWin.UIRecharge)
    self._uiSkin = uiSkin

    self._panel = panel
    self._parent = parent
    
    local secLvBg = UISecLvPanelBg.new(self._uiSkin:getRootNode(), self)
    secLvBg:setBackGroundColorOpacity(120)
    secLvBg:setTitle(TextWords:getTextWord(337))
    self._secLvBg = secLvBg

    self._uiSkin:setLocalZOrder(PanelLayer.UI_Z_ORDER_12)
--    self._uiSkin:setLocalZOrder(PanelLayer.UI_Z_ORDER_11)
    self:initPanel()
    self:registerEvent()
end

function UIRecharge:finalize()
    self._uiSkin:finalize()
    self._secLvBg = nil
end

function UIRecharge:hide()
    self._uiSkin:setVisible(false)
    --print("------UIRecharge:hide()------")
end

function UIRecharge:show()
    --print("------UIRecharge:show()------")
    self._uiSkin:setVisible(true)
    self:initPanel()
end


function UIRecharge:initPanel()

    local panel = self:getChildByName("mainPanel")
    local panel2 = self:getChildByName("mainPanel2")
    panel:setVisible(false)
    panel2:setVisible(false)
    
    local isFirst = self:isFirstCharge()
    if isFirst == true then
        -- 首冲
        self._secLvBg:setContentHeight(500)
        panel:setVisible(true)
        self:initReardPanel(panel)
    else
        -- 非首冲
        self._secLvBg:setContentHeight(320)
        panel2:setVisible(true)
    
        local roleProxy = self._panel:getProxy(GameProxys.Role)
        local viplv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel) or 0
        local vipexp = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipExp) or 0
        self:initReardPanel2(panel2, viplv, vipexp)

    end

end

function UIRecharge:isFirstCharge()
    -- -- 1.首冲活动是否还在    
    local activityProxy = self._panel:getProxy(GameProxys.Activity)
    local isFirst = activityProxy:isFirstCharge()
    return isFirst
end

-- 首冲弹窗界面---------------------------------------------------------
function UIRecharge:initReardPanel(panel)
    -- 首冲礼包数据
    local rewardList = GlobalConfig.FirstRechargeReward    

    for index=1, 4 do
        local iconContainer = self:getChildByName("mainPanel/rewardPanel/iconContainer" .. index)
        local iconPanel = self:getChildByName("mainPanel/rewardPanel/panel" .. index)
--        local iconName = iconContainer:getChildByName("iconName")

        local icon = iconPanel.icon
        if icon == nil then
            -- icon = UIIcon.new(iconContainer, rewardList[index], rewardList[index].isShowNum, self._panel)
            icon = UIIcon.new(iconContainer, rewardList[index], rewardList[index].isShowNum)
            iconPanel.icon = icon
            icon:setShowName(true)
        else
            icon:updateData(rewardList[index])
        end

--        local quality = icon:getQuality()
--        local color = ColorUtils:getColorByQuality(quality)
--        iconName:setColor(color)        

--        if rewardList[index].typeid == 206 then
--            -- 双倍元宝
--            iconName:setString(TextWords:getTextWord(1513))
--        else
--            iconName:setString(icon:getName())
--        end

    end
end

function UIRecharge:registerEvent()
    local rewardBtn = self:getChildByName("mainPanel/rewardBtn")
    ComponentUtils:addTouchEventListener(rewardBtn, self.onRewardBtnTouch, nil, self)
end

function UIRecharge:onRewardBtnTouch(sender)
    --TODO 打开充值界面
    ModuleJumpManager:jump(ModuleName.RechargeModule, "RechargePanel")
    self:hide()
end

function UIRecharge:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end

-- 非首冲界面---------------------------------------------------------
function UIRecharge:initReardPanel2(panel, viplv, vipexp)

    -- local rewardBtn = self:getChildByName("mainPanel2/rewardBtn")
    local conf = ConfigDataManager:getConfigDataBySortId(ConfigData.VipDataConfig) 
    self:renderData(panel, viplv, vipexp, conf)
 
    local rewardBtn = panel:getChildByName("rewardBtn")
    ComponentUtils:addTouchEventListener(rewardBtn, self.onRewardBtnTouch, nil, self)

end

function UIRecharge:renderData(panel, viplv, vipexp, conf)
    -- body
    -- local Panel_top = self:getChildByName("mainPanel2")
    local Panel_top = panel

    local Image_vip = Panel_top:getChildByName("Image_vip")
    local svip1 = Panel_top:getChildByName("svip1")
    local svip2 = Panel_top:getChildByName("svip2")
    local svip3 = Panel_top:getChildByName("svip3")
    local Label_7 = Panel_top:getChildByName("Label_7")
    local Label_9 = Panel_top:getChildByName("Label_9")
    local Label_11 = Panel_top:getChildByName("Label_11")
    local Label_13 = Panel_top:getChildByName("Label_13")

    local vipTxt = Image_vip:getChildByName("vipTxt")
    local vipTxt1 = svip1:getChildByName("vipTxt1")
    local vipTxt2 = svip2:getChildByName("vipTxt2")
    local vipTxt3 = svip3:getChildByName("vipTxt3")


    vipTxt:setString(viplv)

    local nextVipLv = viplv + 1
    local maxVipLv = conf[#conf].level

    if viplv >= maxVipLv then
        -- vip 满级
        Label_7:setString(TextWords:getTextWord(1507))
        Label_9:setVisible(false)
        Label_11:setVisible(false)
        Label_13:setVisible(false)
        svip1:setVisible(false)
        svip2:setVisible(false)
        svip3:setVisible(false)
    else
        -- vip 未满级
        local tmpLV = nextVipLv + 1
        local value = conf[tmpLV].value
        local v = StringUtils:jsonDecode(value)
        local maxExp = v[2]
        
        local money = maxExp - vipexp
        Label_7:setString(string.format(TextWords:getTextWord(1501),money))
    
        Label_9:setString(TextWords:getTextWord(1502))
        Label_11:setString(TextWords:getTextWord(1503))
        Label_13:setString(TextWords:getTextWord(1504))

        vipTxt1:setString(nextVipLv)
        vipTxt2:setString(1)
        vipTxt3:setString(nextVipLv)

        Label_9:setVisible(true)
        Label_11:setVisible(true)
        Label_13:setVisible(true)
        svip1:setVisible(true)
        svip2:setVisible(true)
        svip3:setVisible(true)


        -- 文本自适应对齐
        local size = Label_7:getContentSize()
        local x = Label_7:getPositionX()
        x = x + size.width + 40
        svip1:setPositionX(x)

        size = svip3:getContentSize()
        local size2 = vipTxt3:getContentSize()
        local x = svip3:getPositionX()
        x = x + size2.width
        Label_13:setPositionX(x)

    end

end







