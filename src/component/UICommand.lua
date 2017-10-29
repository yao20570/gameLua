--UI控件功能：军令/讨伐令不足的弹窗
--Time:2017/02/13
--Author:LGC
UICommand = class("UICommand", BasicComponent)
UICommand.COMMAND_TYPE01 = 1 -- 军令
UICommand.COMMAND_TYPE02 = 2 -- 讨伐令

function UICommand:ctor(panel)
    local uiSkin = UISkin.new("UICommand")
    local parent = panel:getLayer(ModuleLayer.UI_TOP_LAYER) -- 弹窗层
    uiSkin:setParent(parent)
    uiSkin:setName(GlobalConfig.uitopWin.UICommand) -- "UICommand"

    self._uiSkin = uiSkin
    self._panel = panel
    self._parent = parent
    self._proxy = panel:getProxy(GameProxys.Role) -- 角色数据
    self:registerProxyEvent()

    local secLvBg = UISecLvPanelBg.new(self._uiSkin:getRootNode(), self)
    secLvBg:setBackGroundColorOpacity(120)
    secLvBg:setTitle(TextWords:getTextWord(519))
    secLvBg:setContentHeight(480)
    self._secLvBg = secLvBg

    self._uiSkin:setLocalZOrder(PanelLayer.UI_Z_ORDER_11)
    
    self:registerEvents()
end

function UICommand:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end

function UICommand:registerProxyEvent()
    -- 回调隐藏
    self._proxy:addEventListener(AppEvent.PROXY_BUYEVENT_UPDATE, self, self.hide)

end

function UICommand:finalize()
    self._proxy:addEventListener(AppEvent.PROXY_BUYEVENT_UPDATE, self, self.hide)
    self._uiSkin:finalize()
    if self._secLvBg ~= nil then
        self._secLvBg = nil
    end
    if self._panel.uiCommand ~= nil then
        self._panel.uiCommand = nil
    end
end


-- seclv的close()函数回调
function UICommand:hide()
    
    TimerManager:remove(self.updateTime, self)
    logger:info("UICommand界面隐藏")
    self._uiSkin:setVisible(false)
end
-- 外部调用  show
function UICommand:show(showType, content, callByEnergy)
    self._showType = showType -- 类型
    self._content = content -- 显示
    self.callByEnergy = callByEnergy
    self._uiSkin:setVisible(true)
    self:initPanel(self._showType, self._content)
end


-- 控件获取和添加响应
function UICommand:registerEvents()
    local mianPanel = self:getChildByName("mainPanel")

    local img01 = mianPanel:getChildByName("img01")
    local img02 = mianPanel:getChildByName("img02")
    local img03 = mianPanel:getChildByName("img03")

    self._tipTxt01 = img01:getChildByName("tipTxt")
    self._tipTxt02 = img02:getChildByName("tipTxt")
    self._tipTxt03 = img03:getChildByName("tipTxt")
    self._timeTxt  = img03:getChildByName("timeTxt")

    self._buyBtn     = img01:getChildByName("buyBtn")
    self._getFreeBtn = img02:getChildByName("getFreeBtn")
    self._checkBtn   = img03:getChildByName("checkBtn")

    ComponentUtils:addTouchEventListener(self._buyBtn, self.onBuyBtn, nil, self)
    ComponentUtils:addTouchEventListener(self._getFreeBtn, self.onGetFreeBtn, nil, self)
    ComponentUtils:addTouchEventListener(self._checkBtn, self.onCheckBtn, nil, self)

end


------
-- 显示信息设置
-- @param  showType [int] 显示类型
function UICommand:initPanel(showType, content)
    -- 文本显示
    self._tipTxt01:setString(content)
    if showType == UICommand.COMMAND_TYPE01 then
        self._tipTxt02:setString( string.format(TextWords:getTextWord(133), TextWords:getTextWord(200103) ))
        self._tipTxt03:setString( string.format(TextWords:getTextWord(134), TextWords:getTextWord(200103) ))
    elseif showType == UICommand.COMMAND_TYPE02 then
        self._tipTxt02:setString( string.format(TextWords:getTextWord(133), TextWords:getTextWord(200109) ))
        self._tipTxt03:setString( string.format(TextWords:getTextWord(134), TextWords:getTextWord(200109) ))
    end
    NodeUtils:alignNodeL2R(self._tipTxt03, self._timeTxt)
    
    -- 时间刷新
    self:updateTime()
    -- 定时器
    self:addTimerManager()
end

-- 点击购买
function UICommand:onBuyBtn()
    self.callByEnergy()
end


-- 点击前往
function UICommand:onGetFreeBtn()
    --ModuleJumpManager:jump(ModuleName.ActivityModule, "ActivityModule")
    --self._panel:dispatchEvent(MapEvent.SHOW_OTHER_EVENT, {moduleName = ModuleName.ActivityModule})

    local _data = {}
    _data.moduleName = ModuleName.GameActivityModule
    _data.extraMsg = {
    jumpToId = 39
    }
    -- 打开邮箱界面，并传递数据，
    self._proxy:sendAppEvent(AppEvent.MODULE_EVENT,AppEvent.MODULE_OPEN_EVENT, _data)

    self:hide()
end

-- 点击查看
function UICommand:onCheckBtn()
    ModuleJumpManager:jump(ModuleName.PersonInfoModule, "PersonInfoDetailsPanel")
    self:hide()
end

-- 点击获取免费
function UICommand:updateTime()
    if self._showType == UICommand.COMMAND_TYPE01 then
        local maxEnergy = 20
        local curEnergy = self._proxy:getRoleAttrValue(PlayerPowerDefine.POWER_energy) or 0

        if curEnergy < maxEnergy then
            local remainTime = self._proxy:getRemainTimeByPower(PlayerPowerDefine.POWER_energy)
            self._timeTxt:setString(TimeUtils:getStandardFormatTimeString8(remainTime))
        else
            self._timeTxt:setString(TextWords:getTextWord(135))
        end

    elseif self._showType == UICommand.COMMAND_TYPE02 then
        local maxsade = GlobalConfig.maxCrusadeEnergy
        local cursade = self._proxy:getRoleAttrValue(PlayerPowerDefine.POWER_crusadeEnergy) or 0
        if cursade < maxsade then
            local remainTime = self._proxy:getRemainTimeByPower(PlayerPowerDefine.POWER_crusadeEnergy)
            self._timeTxt:setString(TimeUtils:getStandardFormatTimeString8(remainTime))
        else
            self._timeTxt:setString(TextWords:getTextWord(135))
        end
    end
end

-- 每秒一次刷新
function UICommand:addTimerManager()
    TimerManager:add(1000, self.updateTime, self)
end







