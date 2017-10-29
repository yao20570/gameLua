-- /**
--  * @Author:guocheng
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
TopFramePanel = class("TopFramePanel", BasicPanel)
TopFramePanel.NAME = "TopFramePanel"

FOREVERTIME = 31536000

function TopFramePanel:ctor(view, panelName)
    TopFramePanel.super.ctor(self, view, panelName)

end

function TopFramePanel:finalize()
    TopFramePanel.super.finalize(self)
end

function TopFramePanel:initPanel()
	TopFramePanel.super.initPanel(self)
    self._frameProxy = self:getProxy(GameProxys.Frame)

end

function TopFramePanel:registerEvents()
	TopFramePanel.super.registerEvents(self)
    self._frameListView = self:getChildByName("frameListView")

end

-- 自适应
function TopFramePanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._frameListView, GlobalConfig.downHeight, tabsPanel)
end

-- 显示初始化
function TopFramePanel:onShowHandler()
    
    if self._frameListView then
        self._frameListView:jumpToTop()
    end

    self:updateFrameListView()
end 

function TopFramePanel:updateFrameListView()
    self._frameData = self._frameProxy:getFrameInfos()

    local mergeData = {}
    -- copy
    table.merge( mergeData, self._frameData)
    table.sort(mergeData, 
    function(item1, item2)
        -- 已使用＞可使用＞未获得 //0未使用，1使用
        local showLevel01 = self:getShowLevel(item1)
        local showLevel02 = self:getShowLevel(item2)
        if showLevel01 == showLevel02 then
            return item1.ID < item2.ID
        else
            return showLevel01 > showLevel02
        end
    end)

    self._updateItemMap = {}
    self:renderListView(self._frameListView, mergeData, self, self.onSetItem)
end

function TopFramePanel:onSetItem(item, data, index)
    if item == nil then
        return 
    end

    local frameNameTxt = item:getChildByName("frameNameTxt")
    local frameMemoTxt = item:getChildByName("frameMemoTxt")

    local timeTxt      = item:getChildByName("timeTxt")

    local icon         = item:getChildByName("icon")
    local downBtn      = item:getChildByName("downBtn")
    local upBtn        = item:getChildByName("upBtn")
    local noGotBtn     = item:getChildByName("noGotBtn")
    
    -- 按钮显示
    noGotBtn:setVisible(false)
    downBtn:setVisible(false)
    upBtn:setVisible(false)
    
    --//null
    noGotBtn:setTitleFontSize(20)
    downBtn:setTitleFontSize(20)
    upBtn:setTitleFontSize(20)
    -- 文本显示
    frameNameTxt:setString(data.title)
    frameMemoTxt:setString(data.titleInfo)

    downBtn.frameId = data.ID
    upBtn.frameId = data.ID

    -- 显示状态
    self:addTouchEventListener(downBtn,self.onChangeFrame)
    self:addTouchEventListener(upBtn,self.onChangeFrame)


    -- 设置头像
    icon.data = data
    self:setFrameShow(icon)

    -- 网络数据
    local time = data.time
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
    end
    NodeUtils:setEnable(noGotBtn, false)

    -- 时间
    local remainTime = self:getRemainTime(data.ID)
    timeTxt:setString( string.format("(%s)", TimeUtils:getStandardFormatTimeString8(remainTime) ) )
    --超过1年的当永久处理
    if remainTime == 0 or remainTime > FOREVERTIME then
        timeTxt:setString("")
    end
    timeTxt:setPositionX(frameNameTxt:getContentSize().width + frameNameTxt:getPositionX() + 3)
    -- 刷新单元赋值
    if remainTime ~= 0 then
        self._updateItemMap[index + 1] = {item = item, data = data}
    end

end

function TopFramePanel:update()
    for index, info in pairs(self._updateItemMap) do
        local item = info.item
        local data = info.data
        local remainTime = self:getRemainTime(info.data.ID)
        local timeTxt = item:getChildByName("timeTxt")
        local frameNameTxt = item:getChildByName("frameNameTxt")
        --超过1年的当永久处理
        if remainTime == 0 or remainTime > FOREVERTIME then
            timeTxt:setString("")
        else
            timeTxt:setString( string.format("(%s)", TimeUtils:getStandardFormatTimeString8(remainTime)) )
        end
    end
end




-- 按钮
function TopFramePanel:onChangeFrame(sender)
    local data = {}
    data.frameId = sender.frameId
--    if sender.state == 0 then
--        data.frameId = 0
--    end
    self._frameProxy:onTriggerNet20805Req(data)
end

------
-- 设置头像框显示
function TopFramePanel:setFrameShow(icon)
    local frameId = icon.data.ID
    local headInfo = {}
	headInfo.icon = 9999 -- 无人头像
	headInfo.preName1 = "headIcon"
	headInfo.preName2 = nil
    headInfo.frameId = frameId
    local head = icon.head
    if head == nil then
        head = UIHeadImg.new(icon, headInfo,self)
        icon.head = head
        head:setScale(0.8)
        head:setPosition(0,10)
    else
        head:updateData(headInfo)
    end 

end



-- 获取优先级
function TopFramePanel:getShowLevel(item)
    local showLevel = 0 
    local use  = item.use
    local time = self:getRemainTime(item.ID )
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


function TopFramePanel:getRemainTime(id)
    return self._frameProxy:getRemainTime( self._frameProxy:getKey(id) )
end