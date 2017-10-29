UIRetPacket = class("UIRetPacket", BasicComponent)

function UIRetPacket:ctor(parent, panel)
    UIRetPacket.super.ctor(self)
    local uiSkin = UISkin.new("UIRetPacket")
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(640, 960))
    layout:setAnchorPoint(cc.p(0.5,0.5))
    local winSize = cc.Director:getInstance():getWinSize()
    layout:setPosition(winSize.width/2, winSize.height/2)
    layout:setTouchEnabled(true)
    parent:addChild(layout)
    uiSkin:setParent(layout)
    self._parent = layout
    self._uiSkin = uiSkin
    self._panel = panel

    local label = self:getChildByName("mainPanel/lab_target")
    label:setString("")
    self.pos = cc.p(label:getPosition())

    local root = self:getChildByName("touchPanel")
    ComponentUtils:addTouchEventListener(root, self.hide, nil,self)

    -- self.first = true
    require "modules.chat.rich.RichTextMgr"
end

--TODO 外部还未调用finalize 
function UIRetPacket:finalize()
    if self.richText ~= nil then
        self.richText:dispose()
        self.richText = nil
    end
    self._uiSkin:finalize()
    self._uiSkin = nil
    UIRetPacket.super.finalize(self)
end

function UIRetPacket:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end

function UIRetPacket:show(data, name, num)
	self._parent:setVisible(true)
    self:initView(data, name, num)
end

function UIRetPacket:hide()
    self._parent:stopAllActions()
	self._parent:setVisible(false)
end

function UIRetPacket:render(item, data)
	local lab_name = item:getChildByName("lab_name")
	local lab_info = item:getChildByName("lab_info")
    local bgImg = item:getChildByName("bgImg")
    TextureManager:updateImageView(bgImg, "images/chat/notGet.png")
	lab_name:setString(data.name)
	lab_info:setString(data.num..TextWords:getTextWord(250013))
end

function UIRetPacket:initView(data, name, num)
    local lab_tips = self:getChildByName("mainPanel/lab_tips")
    local bgImg = self:getChildByName("mainPanel/bgImg")
    local successImg = self:getChildByName("mainPanel/infoImg")
    local label = self:getChildByName("mainPanel")

    TextureManager:updateImageView(bgImg, "images/chat/bgImg.png") --红包底

    lab_tips:setVisible(num ~= nil)
    local url = "images/chat/tipText.png"
    if num ~= nil then
        url = "images/chat/get.png"
        lab_tips:setString(string.format(TextWords:getTextWord(250012), num))
    end
    TextureManager:updateImageView(successImg, url)
    local listView = self:getChildByName("mainPanel/listview_info")
    local item = listView:getItem(0)
    listView:setItemModel(item)
    item:setVisible(false)

    if name ~= self.oldName then
        self.oldName = name
        local args = {}
        args[1] = {txt = name, isUnderLine = 1, color = "30c7ff", fontSize = 22}
        args[2] = {txt = TextWords:getTextWord(250014), color = "54422a", fontSize = 22}
        if self.richText then
            self.richText:setData(args, 270)
        else
            self.richText = RichTextMgr:getInstance():getRich(args, 270)
            label:addChild(self.richText)
        end
        self.richText:setLocalZOrder(10)
        self.richText:setAnchorPoint(0, 1)
        self.richText:setPosition(self.pos)
    end
    self:renderListView(listView, data, self, self.render)
end

function UIRetPacket:removeFromParent()
    self:finalize()
    -- if self.richText ~= nil then
    --     self.richText:dispose()
    --     self.richText = nil
    -- end
    -- self._parent:removeChild(self._uiSkin, true)
    -- self._parent:removeFromParent()
end