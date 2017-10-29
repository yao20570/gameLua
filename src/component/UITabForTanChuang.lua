--[[
    属于弹窗的Tab 页签切换控件
]]

UITabForTanChuang = class("UITabForTanChuang")


--[[外部接口说明:

    --设置条件打开回调 如果需要
        *function UITabForTanChuang:setOpenConditionCallback(openConditionCallback)
            *openConditionCallback(data,index)
                *data = {
                    skinName
                }
    --设置选择的页签
        function UITabForTanChuang:setSelectTabByName(name)
    --设置选择的页签
        function UITabForTanChuang:setSelectTabByContent(content)
    --设置选择的页签 从1开始
        function UITabForTanChuang:setSelectTabIdx(idx)

]]

--[[参数说明:
    conf = {
        adaptivePanel = self._pnlTab, --[node]:适配panle,页签会根据这个panle的size来设置scrollView的size
        basicPanel = basicPanel,--[basicPanel]:继承与basicPanel的类对象
        callback  --(可选参数)  为了切换前做各种自己想做的处理   在外部实现标签页切换   注意：返回的是标签页所对应的panelName
    }

]]

function UITabForTanChuang:ctor(conf)

    if type(conf) ~= type({}) then
        logger:error("UITabForTanChuang:没有传递配置")
        logger.error(debug.track())
        return
    end

    --记录页签 跟切换页签要打开的panle名字
    self._data = {}
    self._openIndex = nil


    --------------------------------------------
    self._conf = conf

    local parent = conf.adaptivePanel
    self._parent = parent
    self._basicPanel = conf.basicPanel

    self.callback = conf.callback

    local uiSkin = UISkin.new("UITabForTanChuang")
    uiSkin:setParent(parent)
    self._uiSkin = uiSkin

    self:resetParentPanel(parent)

    self:initSkin()
end


function UITabForTanChuang:finalize()
    if self._curPanelName then
        local panel = self._basicPanel:getPanel(self._curPanelName)
        if panel:isVisible() then
            panel:hide()
        end
    end

    self._data = {}
    self._openIndex = nil
end

function UITabForTanChuang:resetParentPanel(panel)
    --设置无颜色,无点击事件
    panel:setBackGroundColorType(0)
end

function UITabForTanChuang:initSkin()
    self._svTab = self._uiSkin:getChildByName("svTab")

    local size = self._parent:getContentSize()

    self._svTab:setContentSize(size)
    self._svTab:setInnerContainerSize(size)
end



--加入一个页签
function UITabForTanChuang:addTabPanel(showPanelName,content,redNum)
    table.insert(self._data,{showPanelName,content,redNum or 0})
end

--获取标签数据
function UITabForTanChuang:getTabPanel()
    return self._data
end 

--设置选择的页签
function UITabForTanChuang:setSelectTabByName(name)
    for key, val in pairs(self._data) do
        local panelName = val[1]
        if panelName == name then
            self:setSelectTabIdx(key)
            break
        end
    end
end

--设置选择的页签
function UITabForTanChuang:setSelectTabByContent(content)
    for key, val in pairs(self._data) do
        local _content = val[2]
        if _content == content then
            self:setSelectTabIdx(key)
            break
        end
    end
end

--设置选择的页签 从1开始
function UITabForTanChuang:setSelectTabIdx(idx)
    if self._openIndex == idx then
        logger:info("相同页签,我不切换")
        return
    end

    self._openIndex = idx
    self._oldPanelName = self._curPanelName
    self._curPanelName = self._data[idx][1]

    if self._oldPanelName then
        local panel = self._basicPanel:getPanel(self._oldPanelName)
        if panel:isVisible() == true then
            -- panel:hideVisibleCallBack()
            -- panel:hideCallBack()
            panel:hide()
        end
    end

    if self._curPanelName then
        local panel = self._basicPanel:getPanel(self._curPanelName)
        if not panel:isVisible() then
            panel:show()
            panel:setLocalZOrder(2)
        end
    end

    --渲染页签
    self._basicPanel:renderScrollView(self._svTab, "item", self._data, 
                                            self, self.renderTab, nil, 1)

end

--更新小红点
function UITabForTanChuang:reRender()
     --渲染页签
    self._basicPanel:renderScrollView(self._svTab, "item", self._data, 
                                            self, self.renderTab, nil, 1)
end 


UITabForTanChuang.UnselectBtnUrl = "images/newGui9Scale/SpTab1.png"
UITabForTanChuang.SelectBtnUrl = "images/newGui9Scale/SpTab2.png"
function UITabForTanChuang:renderTab(item,data,idx)

    local btnTab = item:getChildByName("btnTab")
    btnTab:setTitleText(data[2])
    btnTab.idx = idx
    btnTab.panelName = data[1]
    btnTab.redNum = data[3]

    local redDot = item:getChildByName("redDot")
    local num = redDot:getChildByName("num")
    if btnTab.redNum > 0 then
        redDot:setVisible(true)
        num:setString(btnTab.redNum)
    else
        redDot:setVisible(false)
        num:setString(0)
    end 
    btnTab:addTouchEventListener(handler(self,self.onBtnTab))

    if self._openIndex == idx then
        TextureManager:updateButtonNormal(btnTab, 
                UITabForTanChuang.SelectBtnUrl, UITabForTanChuang.SelectBtnUrl)
        btnTab:setTitleColor(ColorUtils.commonColor.c3bWhite)
    else
        TextureManager:updateButtonNormal(btnTab, 
                UITabForTanChuang.UnselectBtnUrl, UITabForTanChuang.UnselectBtnUrl)
        btnTab:setTitleColor(ColorUtils.commonColor.c3bMiaoShu)
    end


end

function UITabForTanChuang:onBtnTab(item,eventType)
    if eventType == ccui.TouchEventType.ended then
        if self._openConditionCallback and not self._openConditionCallback({
                skinName = self._data[item.idx][1]
            }, item.idx) then
            return
        end
        if item.idx then
            if self.callback then
                self.callback(item.panelName)
                return
            end 
            self:setSelectTabIdx(item.idx)
        end
    end
end

--设置条件打开回调 如果需要
function UITabForTanChuang:setOpenConditionCallback(obj,openConditionCallback)
    self._openConditionCallback = handler(obj,openConditionCallback)
end



