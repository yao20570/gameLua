-- /**

--  * @Author: 林国成   

--  * @DateTime:    2016-12-12 00:00:00

--  * @Description: 

--  */

TitleSettingPanel = class("TitleSettingPanel", BasicPanel)

TitleSettingPanel.NAME = "TitleSettingPanel"



function TitleSettingPanel:ctor(view, panelName)

    TitleSettingPanel.super.ctor(self, view, panelName)



end



function TitleSettingPanel:finalize()

    TitleSettingPanel.super.finalize(self)

end



function TitleSettingPanel:initPanel()

	TitleSettingPanel.super.initPanel(self)

    self._titleListView = self:getChildByName("titleListView")



    self._titleProxy = self:getProxy(GameProxys.Title)



    





end



function TitleSettingPanel:registerEvents()

	TitleSettingPanel.super.registerEvents(self)

end



-- 自适应

function TitleSettingPanel:doLayout()

    local tabsPanel = self:getTabsPanel()

    NodeUtils:adaptiveListView(self._titleListView, GlobalConfig.downHeight,tabsPanel)

end



-- ------

-- -- 显示开始

function TitleSettingPanel:onShowHandler()

    TitleSettingPanel.super.onShowHandler(self)

    

    if self._titleListView then

        self._titleListView:jumpToTop()

    end



    self:updateTitleListView()

end



------

-- 更新listView

function TitleSettingPanel:updateTitleListView()

    self._titleData = self._titleProxy:getTitleInfos()

    local mergeData = {}

    -- copy

    table.merge( mergeData, self._titleData)

    -- 排序

    table.sort(mergeData, 

    function(item1, item2)

        -- 已使用＞可使用＞未获得 //0未使用，1使用

        local showLevel01 = self:getShowLevel(item1)

        local showLevel02 = self:getShowLevel(item2)

        local sortId01 = ConfigDataManager:getInfoFindByOneKey(ConfigData.TitleConfig, "type", item1.id) --注：这里的id  实际上是type
        local sortId02 = ConfigDataManager:getInfoFindByOneKey(ConfigData.TitleConfig, "type", item2.id) --注：这里的id  实际上是type


        if showLevel01 == showLevel02 then

            return sortId01.ID < sortId02.ID

        else

            return showLevel01 > showLevel02

        end

    end)

    self._updateItemMap = {}

    self:renderListView(self._titleListView, mergeData, self, self.onSetItem)

end



-- 设置信息

function TitleSettingPanel:onSetItem(item, data, index)

    if item == nil then

        return 

    end

    local titleNameTxt = item:getChildByName("titleNameTxt")

    local timeTxt      = item:getChildByName("timeTxt")

    local titleMemoTxt = item:getChildByName("titleMemoTxt")

    local downBtn      = item:getChildByName("downBtn")

    local upBtn        = item:getChildByName("upBtn")

    local noGotBtn     = item:getChildByName("noGotBtn")

    noGotBtn:setVisible(false)

    upBtn:setVisible(false)

    downBtn:setVisible(false)

    -- 数据

    local time = data.time

    local id   = data.id

    local use  = data.use

    -- 显示状态

    if time ~= 0 then

        if use == 1 then

            downBtn:setVisible(true)

        else

            upBtn:setVisible(true)

        end

    else

        noGotBtn:setVisible(true)

        NodeUtils:setEnable(noGotBtn, false)

    end



    -- 设置信息

    local configItem = ConfigDataManager:getInfoFindByOneKey(

        ConfigData.TitleConfig, "type", id) --这里的id实际代表的是type信息

    local name = configItem.title -- 称号名字

    titleNameTxt:setString(name)

    local memo = configItem.titleInfo-- 称号描述

    titleMemoTxt:setString(memo)

    local titleLv = configItem.titleLv -- 称号品质

    titleNameTxt:setColor( ColorUtils:getColorByQuality(titleLv))





    -- 时间

    local remainTime = self._titleProxy:getRemainTime(self._titleProxy:getKey(id))

    

    timeTxt:setString( string.format("(%s)", TimeUtils:getStandardFormatTimeString8(remainTime) ) )

    if remainTime == 0 then

        timeTxt:setString("")

    end

    --NodeUtils.fixTwoNodePos(titleNameTxt, timeTxt)

    timeTxt:setPositionX(titleNameTxt:getContentSize().width + titleNameTxt:getPositionX() + 3)

    

    -- 刷新单元赋值

    if remainTime ~= 0 then

        self._updateItemMap[index + 1] = {item = item, data = data}

    end



    -- 回调响应

    item.id = id

    downBtn.id = id

    upBtn.id   = id 

    downBtn.name = name

    upBtn.name   = name

    self:addTouchEventListener(downBtn,self.onChangeTitle)

    self:addTouchEventListener(upBtn,self.onChangeTitle)

end



-- 按钮

function TitleSettingPanel:onChangeTitle(sender)

    -- print("点击换称号"..sender.name )

    local id = sender.id

    self._titleProxy:onTriggerNet20802Req(id)

end



-- 时间到了之后的回调





-- 时间跳动刷新

function TitleSettingPanel:update()

    for index, info in pairs(self._updateItemMap) do

        local item = info.item

        local data = info.data

        local id = data.id

        local remainTime = self._titleProxy:getRemainTime(self._titleProxy:getKey(id))

        local timeTxt = item:getChildByName("timeTxt")

        local titleNameTxt = item:getChildByName("titleNameTxt")

        if remainTime == 0 then

            timeTxt:setString("")

        else

            timeTxt:setString( string.format("(%s)", TimeUtils:getStandardFormatTimeString8(remainTime)) )

        end

        

    end

end



-- 获取优先级

function TitleSettingPanel:getShowLevel(item)

    local showLevel = 0 

    local use  = item.use

    local id   = item.id 

    local time = self._titleProxy:getRemainTime( self._titleProxy:getKey(id) )

    if use == 1 and time ~= 0 then

        -- 已穿

        showLevel = 3

    elseif use == 0 and time ~= 0 then 

        -- 未穿

        showLevel = 2

    elseif time == 0 then

        -- 未获得

        showLevel = 1

    end

    return showLevel

end