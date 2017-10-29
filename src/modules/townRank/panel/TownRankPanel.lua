-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
TownRankPanel = class("TownRankPanel", BasicPanel)
TownRankPanel.NAME = "TownRankPanel"

function TownRankPanel:ctor(view, panelName)
    TownRankPanel.super.ctor(self, view, panelName, true)
    self:setUseNewPanelBg(true)
end

function TownRankPanel:finalize()
    TownRankPanel.super.finalize(self)
end

function TownRankPanel:initPanel()
	TownRankPanel.super.initPanel(self)
    self:setBgType(ModulePanelBgType.NONE)
    self:setTitle(true,"town_krank",true)
    
    self._cityWarProxy = self:getProxy(GameProxys.CityWar)
end

function TownRankPanel:registerEvents()
	TownRankPanel.super.registerEvents(self)
    self._topPanel = self:getChildByName("topPanel")
    self._masterImg = self._topPanel:getChildByName("masterImg")
    
    self._masterHeadImg = self._topPanel:getChildByName("masterHeadImg")
    
    self._listView = self:getChildByName("listView")
end

function TownRankPanel:doLayout()
    
    NodeUtils:adaptiveTopPanelAndListView( self._topPanel, self._listView, GlobalConfig.downHeight, GlobalConfig.topHeight, 0)
end

function TownRankPanel:onShowHandler()
    self:onUpdateTownRankPanel()

end


function TownRankPanel:onUpdateTownRankPanel()
    self._rankInfoList = self._cityWarProxy:getTownRankInfoList()

    local firstInfo = self._rankInfoList[1]

    self:setMaster(firstInfo)

    self:setVice(firstInfo)

    if #self._rankInfoList >= 1 then
        table.remove(self._rankInfoList, 1)
    else
        self._rankInfoList = {}
    end
    


    self:renderListView(self._listView, self._rankInfoList, self, self.renderItem, nil, nil, 0)
end

-- 渲染itemPanel
function TownRankPanel:renderItem(itemPanel, data, index)
    index = index + 1

    local masterNameTxt = itemPanel:getChildByName("masterNameTxt")
    local leigonNameTxt = itemPanel:getChildByName("leigonNameTxt")
    local viceNameTxt01 = itemPanel:getChildByName("viceNameTxt01")
    local viceNameTxt02 = itemPanel:getChildByName("viceNameTxt02")
    local areaTxt       = itemPanel:getChildByName("areaTxt")

    local rank			    = data.rank			
    local legionName		= data.legionName		
    local townKingInfo	    = data.townKingInfo	
    local viceKingInfoList  = data.viceKingInfoList
    local totalArea	        = data.totalArea		
    

    masterNameTxt:setString(townKingInfo.name)
    leigonNameTxt:setString(legionName)

    viceNameTxt01:setString("")
    viceNameTxt02:setString("")
    viceNameTxt01:setColor(ColorUtils.wordNameColor)
    viceNameTxt02:setColor(ColorUtils.wordNameColor)

    if viceKingInfoList[1] ~= nil then
        viceNameTxt01:setString(viceKingInfoList[1].name)
    else
        viceNameTxt01:setString(self:getTextWord(360010))
        viceNameTxt01:setColor(ColorUtils.wordBadColor)
    end

    if viceKingInfoList[2] ~= nil then
        viceNameTxt02:setString(viceKingInfoList[2].name)
    else
        viceNameTxt02:setString(self:getTextWord(360010))
        viceNameTxt02:setColor(ColorUtils.wordBadColor)
    end

    areaTxt:setString(totalArea)

    -- 颜色
    local bgUrl = "images/newGui9Scale/S9Gray.png"
    if index %2 == 0 then
        bgUrl = "images/newGui9Scale/S9Bg.png"
    end

    TextureManager:updateImageView(itemPanel, bgUrl)

 end	


-- 第三个参数为空则显示暂无
function TownRankPanel:setTitleValue(fontBg, value, isShowNil)
    local valueTxt = fontBg:getChildByName("valueTxt")
    
    if value == "" and isShowNil == nil then
        value = self:getTextWord(360010) -- "暂无"
        valueTxt:setColor(ColorUtils.wordBadColor)
    else
        valueTxt:setColor(ColorUtils.wordWhiteColor)
    end

    valueTxt:setString(value)
end 


function TownRankPanel:setHeadIcon(node, headIcon, frameId, playerId)
    local headInfo = {}
    headInfo.icon = headIcon 
    headInfo.preName1 = "headIcon"
	headInfo.preName2 = nil
    headInfo.frameId = frameId
    headInfo.playerId = playerId
    local head = node.head
    if head == nil then
        head = UIHeadImg.new(node, headInfo, self)
        node.head = head
        head:setScale(0.8)
        head:setPosition(0, -3)
    else
        head:updateData(headInfo)
    end
end


function TownRankPanel:onClosePanelHandler()
    self:dispatchEvent(TownRankEvent.HIDE_SELF_EVENT)
end

-- 设置第一郡王
function TownRankPanel:setMaster(firstInfo)
    -- 文本
    for i = 1, 3 do
        local fontbg =  self._masterImg:getChildByName("fontBg0".. i)
        local value = ""
        if firstInfo ~= nil then
            if i == 1 then
                value = firstInfo.townKingInfo.name
            elseif i == 2 then
                value = firstInfo.legionName
            elseif i == 3 then
                value = firstInfo.totalArea
            end
            self:setTitleValue(fontbg, value)
        else
            if i == 1 then
                self:setTitleValue(fontbg, value)
            elseif i == 2 then
                self:setTitleValue(fontbg, value, false)
            elseif i == 3 then
                self:setTitleValue(fontbg, value, false)
            end
        end
    end



    -- 城主的头像
    if firstInfo ~= nil then 
        self._masterHeadImg:setVisible(true)
        self:setHeadIcon(self._masterHeadImg, firstInfo.townKingInfo.headIcon, 1, firstInfo.townKingInfo.playerId)
    else
        self._masterHeadImg:setVisible(true)
        self:setHeadIcon(self._masterHeadImg, 9999, 1)
    end


end

-- 设置vice
function TownRankPanel:setVice(firstInfo)
    -- 副盟的文本和头像
    if firstInfo ~= nil then
        for i = 1, 2 do
            local viceKingInfoList = firstInfo.viceKingInfoList

            local viceImg = self._topPanel:getChildByName("viceImg0"..i)
            local fontBg = self._topPanel:getChildByName("fontBg0"..i)
        
            local viceInfo =  viceKingInfoList[i]
            local name = nil 
            local headIcon = nil
            local playerId = nil
            if viceInfo == nil then
                self:setTitleValue(fontBg, "")
                viceImg:setVisible(false)
            else
                name = viceInfo.name
                headIcon = viceInfo.headIcon
                playerId = viceInfo.playerId
                self:setTitleValue(fontBg, name)
                viceImg:setVisible(true)
                self:setHeadIcon(viceImg, headIcon, nil, playerId)
            end
        end
    elseif firstInfo == nil then
        for i = 1, 2 do
            local viceImg = self._topPanel:getChildByName("viceImg0"..i)
            local fontBg = self._topPanel:getChildByName("fontBg0"..i)
            self:setTitleValue(fontBg, "")
            viceImg:setVisible(false)
        end
    end
end