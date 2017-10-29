-- /**
--  * @Author:      fzw
--  * @DateTime:    2016-01-25 17:57:42
--  * @Description: 探险排行榜
--  */
LimitExpRankPanel = class("LimitExpRankPanel", BasicPanel)
LimitExpRankPanel.NAME = "LimitExpRankPanel"

function LimitExpRankPanel:ctor(view, panelName)
    LimitExpRankPanel.super.ctor(self, view, panelName, 700)
    
    self:setUseNewPanelBg(true)
end

function LimitExpRankPanel:finalize()
    LimitExpRankPanel.super.finalize(self)
end

function LimitExpRankPanel:initPanel()
	LimitExpRankPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(1900))

    local listView = self:getChildByName("indexPanel/ListView_50")
    -- NodeUtils:adaptive(listView)    
end

function LimitExpRankPanel:onShowHandler(data)
    -- body
    print("rank show handler")
    self:onShowRankList(data)
end

-- -- 界面显示
function LimitExpRankPanel:onShowRankList(data)
    local indexPanel = self:getChildByName("indexPanel")
    indexPanel:setVisible(true)
    local myIndex = indexPanel:getChildByName("myIndex")
    local myGrade = indexPanel:getChildByName("myGrade")
    local ListView_50 = indexPanel:getChildByName("ListView_50")

    if data.myIndexInfo.index <= 0 or data.myIndexInfo.index > 100 then
        -- myIndex:setString("未上榜")
        myIndex:setString(self:getTextWord(4001))
    else
        myIndex:setString(data.myIndexInfo.index)
    end
    myGrade:setString(data.myIndexInfo.grade)
    self:renderListView(ListView_50, data.allIndexInfo, self, self.registerIndexItemEvents,nil,nil,0)

end

function LimitExpRankPanel:registerIndexItemEvents(item,data)
    if item == nil or data == nil then
        return
    end
    item:setVisible(true)

    local imgTouch = item:getChildByName("imgTouch")
    if imgTouch then
        imgTouch:setVisible(false)
    end
    -- self:addTouchEventListener(item,self.itemTouchEnd,self.itemTouchBegin)

    item:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local imgTouch = sender:getChildByName("imgTouch")
            imgTouch:setVisible(false)
        elseif eventType == ccui.TouchEventType.began then
            local imgTouch = sender:getChildByName("imgTouch")
            imgTouch:setVisible(true)
        elseif eventType == ccui.TouchEventType.canceled then
            local imgTouch = sender:getChildByName("imgTouch")
            imgTouch:setVisible(false)
        end
    end)
    
    local indexImg = item:getChildByName("indexImg")
    local index = item:getChildByName("index")
    local name = item:getChildByName("name")
    local name_New = item:getChildByName("name_New")
    local fight = item:getChildByName("fight")
    local grade = item:getChildByName("grade")
    local Image_line1 = item:getChildByName("Image_line_1")
    local Image_line2 = item:getChildByName("Image_line_2")

    item.index = data.index

    if data.index % 2 == 0 then
        Image_line1:setVisible(true)
        Image_line2:setVisible(false)
    else
        Image_line1:setVisible(false)
        Image_line2:setVisible(true)
    end

    index:setString(data.index)
    fight:setString(StringUtils:formatNumberByK3(data.fight, nil))
    grade:setString(data.grade)

    name:setString("")
    name_New:setString("")

    local tag = 99
    indexImg:removeAllChildren()

    local rank = data.index
    index:setVisible(true)
    indexImg:setVisible(false)
    if rank > 3 then
        index:setString(rank)
        name:setString(data.name)
    else
        local color = ColorUtils.wordColor01
        local url = ""
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

        local img = TextureManager:createImageView(url)
        indexImg:addChild(img, 0, tag)
        index:setString("")
        indexImg:setVisible(true)
        name_New:setColor(color)
        name_New:setString(data.name)
        
        if name_New.pos == nil then
            name_New.pos = true
            name_New:setPosition(name:getPosition())
        end
    end

end




function LimitExpRankPanel:registerEvents()
    LimitExpRankPanel.super.registerEvents(self)
    
    -- local closeBtn = self:getChildByName("indexPanel/closeBtn")
    -- self:addTouchEventListener(closeBtn, self.onCloseBtnTouche)
end

function LimitExpRankPanel:onCloseBtnTouche(sender)
    self:hide()
end







function LimitExpRankPanel:itemTouchEnd(item)
end