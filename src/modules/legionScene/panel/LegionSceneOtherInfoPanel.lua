-- /**
--  * @DateTime:    2016-01-14 11:07:18
--  * @Description: 军团信息-查看其他军团信息
--  */

LegionSceneOtherInfoPanel = class("LegionSceneOtherInfoPanel", BasicPanel)
LegionSceneOtherInfoPanel.NAME = "LegionSceneOtherInfoPanel"

function LegionSceneOtherInfoPanel:ctor(view, panelName)
    LegionSceneOtherInfoPanel.super.ctor(self, view, panelName, 560)
    
    self:setUseNewPanelBg(true)
end

function LegionSceneOtherInfoPanel:finalize()
    LegionSceneOtherInfoPanel.super.finalize(self)
end

function LegionSceneOtherInfoPanel:initPanel()
	LegionSceneOtherInfoPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(3021))
    self._infoPanel = self:getChildByName("mainPanel/infoPanel")

    local Image_bg = self:getChildByName("mainPanel/Image_bg")
    TextureManager:updateImageView(Image_bg, "images/guiScale9/Frame_item_bg.png")

    local Image_bg_0 = self:getChildByName("mainPanel/Image_bg_0")
    TextureManager:updateImageView(Image_bg_0, "images/guiScale9/Frame_item_bg.png")

    --local numTxtxxx =self:getChildByName("mainPanel/infoPanel/mainPanel/infoPanel")
    --numTxtxxx:setTitle(TextWords:getTextWord(3159))
    --local Label_10_1 = self:getChildByName("mainPanel/infoPanel/mainPanel/Label_10_1")
    --Label_10_1:setTitle(TextWords:getTextWord(3160))
end

function LegionSceneOtherInfoPanel:registerEvents()
	LegionSceneOtherInfoPanel.super.registerEvents(self)
end

function LegionSceneOtherInfoPanel:onAfterActionHandler()
    self:onShowHandler()
end

function LegionSceneOtherInfoPanel:onShowHandler()
    if self:isModuleRunAction() then
        return
    end
end

function LegionSceneOtherInfoPanel:onShowHandlerNew(info)
    self._info = info
    self._legionId = self._info.id
    self:updateBaseInfo(self._info)

    local legionProxy = self:getProxy(GameProxys.Legion)
    legionProxy:onTriggerNet220101Req({id = self._info.id})
end

function LegionSceneOtherInfoPanel:updateBaseInfo(legionInfo)
    local infoPanel = self._infoPanel
    local nameTxt = infoPanel:getChildByName("nameTxt")
    local rankTxt = infoPanel:getChildByName("rankTxt")
    local levelTxt = infoPanel:getChildByName("levelTxt")
    local numTxt = infoPanel:getChildByName("numTxt")

    local name   = legionInfo.name
    local rank   = legionInfo.rank
    local level  = legionInfo.level
    local curNum = legionInfo.curNum
    local maxNum = legionInfo.maxNum
    
    nameTxt:setString(name) --军团名
    rankTxt:setString(rank) --排名
    -- levelTxt:setString(level)--等级
    levelTxt:setString(string.format(self:getTextWord(3200), level))--等级
    numTxt:setString(string.format("%d/%d", curNum,maxNum ))--人数
    -- rankTxt:setColor(ColorUtils.wordGreenColor)

    local size = levelTxt:getContentSize()
    nameTxt:setPositionX(levelTxt:getPositionX() + size.width + 12)

end

function LegionSceneOtherInfoPanel:updateDetailInfoPanel(info)
	logger:info("legion id = "..info.id..",self._legionId = "..self._legionId)

	local infoPanel = self._infoPanel
    local leaderTxt = infoPanel:getChildByName("leaderTxt")			--军团长
    local joinTxt = infoPanel:getChildByName("joinTxt")  			--加入方式
    local conditionTxt = infoPanel:getChildByName("conditionTxt") 	--加入条件
    local noticeTxt = infoPanel:getChildByName("noticeTxt")         --军团宣言
    local Image_head = infoPanel:getChildByName("Image_head") 		--头像


    leaderTxt:setString(info.leaderName)
    joinTxt:setString(self:getTextWord(3110 + info.joinType))
    

    -- 头像和挂件
    -- print("iconId="..info.iconId..",,pendantId="..info.pendantId)
    
    local headInfo = {}
    headInfo.icon = info.iconId
    headInfo.pendant = info.pendantId
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = "headPendant"
    headInfo.isCreatPendant = true
    --headInfo.isCreatButton = false
    headInfo.playerId = rawget(info, "id")

    local head = infoPanel.head
    if head == nil then
        head = UIHeadImg.new(Image_head,headInfo,self)
        
        infoPanel.head = head
    else
        head:updateData(headInfo)
    end



    local str1 = info.joinCond1
    local str2 = info.joinCond2

    local str = nil
    if str1 == nil or str2 == nil then
        str = self:getTextWord(3108)
    elseif str1 == 0 and str2 == 0 then
        str = self:getTextWord(3108)
    elseif str1 ~= 0 and str2 ~= 0 then
        str = string.format(self:getTextWord(3109), info.joinCond1).." "..string.format(self:getTextWord(3110), StringUtils:formatNumberByK3(info.joinCond2, nil))
    elseif str1 ~= 0 and str2 == 0 then
        str = string.format(self:getTextWord(3109), info.joinCond1)
    elseif str1 == 0 and str2 ~= 0 then
        str = string.format(self:getTextWord(3110), StringUtils:formatNumberByK3(info.joinCond2, nil))
    end
    conditionTxt:setString(str)


    if string.len(info.notice) == 0 then
        noticeTxt:setString(self:getTextWord(3007))
    else
        noticeTxt:setString(info.notice)
    end 

end

function LegionSceneOtherInfoPanel:registerEvents()
    LegionSceneOtherInfoPanel.super.registerEvents(self)

    self._applyBtn = self:getChildByName("mainPanel/applyBtn")
    self:addTouchEventListener(self._applyBtn, self.onApplyBtnTouch)
    --NodeUtils:setEnable(self._applyBtn, false)
end

function LegionSceneOtherInfoPanel:onCloseBtnTouch(sender)
    -- body
    self:hide()
end

function LegionSceneOtherInfoPanel:onApplyBtnTouch(sender)
    local roleProxy = self:getProxy(GameProxys.Role)
    local legionName = roleProxy:getLegionName()
    local str = string.format(self:getTextWord(3157), legionName)
    self:showSysMessage(str)
end
