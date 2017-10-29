UISkillIcon = class("UISkillIcon")

--仅用于 军师

--data.power data.typeid data.num
function UISkillIcon:ctor(parent, panel, skillid )-- data)  --必须要有node，num，颜色,图片id(typeid)
    self._parent = parent

    self._panel = panel

    self.conf = ConfigDataManager:getConfigData(ConfigData.CounsellorSkillConfig)
    
    self:updateData( skillid )

end

function UISkillIcon:updateData( skillid )
    --self._parent:removeAllChildren()
    -- self.data = data

    local ITEM_SIZE = 0.45

    self.skillInfo = self.conf[skillid]

    -- local color = 1
    -- if self.skillInfo then
    --     color = self.skillInfo.skillLevel + 1
    -- end
    local bgname = "___bg"
    local bg = self._parent:getChildByName( bgname )
    local colorUrl = "images/newGui2/Frame_prop_1.png"
    if not bg then
        bg = TextureManager:createImageView( colorUrl )
        bg:setScale( ITEM_SIZE )
        bg:setName( bgname )
        -- bg:setLocalZOrder(1)
        self._parent:addChild(bg)
    else
        TextureManager:updateImageView( bg, colorUrl )
    end

    -- local bg = TextureManager:createImageView(
    -- bg:setName("Icon")
    -- self._parent:addChild(bg)

    -- self._iconBg = bg
    -- local layout = ccui.Layout:create()
    -- layout:setContentSize(cc.size(93,93))
    -- layout:setPosition(-46,-46)
    -- layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
    -- self._iconBg:addChild(layout)
    -- layout:setLocalZOrder(100)
    -- ComponentUtils:addTouchEventListener(layout,self.onIconTouch, nil, self)

    -- -- local url = "images/gui/Frame_prop_" ..data.color..".png"
    -- local url = "images/newGui2/Frame_prop_1.png"
    -- local bgImg = TextureManager:createImageView(url)
    -- bgImg:setLocalZOrder(1)
    -- self._parent:addChild(bgImg)

    -- local color = 1
    -- if self.skillInfo then
    --     color = self.skillInfo.skillLevel
    -- end
    -- local urlTure = "images/gui/Frame_prop_aperture_"..color..".png"
    -- local qualityTure = TextureManager:createImageView(urlTure)
    -- qualityTure:setLocalZOrder(3)
    -- self._parent:addChild(qualityTure)

    skillid = 999 --------------临时
    local iconUrl = string.format("images/littleIcon/%d.png", skillid)
    local iconname = "___iconImg"
    local iconImg = self._parent:getChildByName( iconname )
    if not iconImg then
        iconImg = TextureManager:createImageView(iconUrl)
        iconImg:setName( iconname )
        -- iconImg:setLocalZOrder(4)
        ComponentUtils:addTouchEventListener(iconImg, self.onIconTouch, nil, self)
        self._parent:addChild(iconImg)
    else
        TextureManager:updateImageView( iconImg, iconUrl )
    end

    local t = TextureManager:getUITexture( iconUrl )
    iconImg:setScale( t and 1 or ITEM_SIZE )


    -- self._iconBg = iconImg
    -- if data.num and data.num > 0 then
    --     self:updateIconNum(data.num, color)
    -- end                       
end

-- function UISkillIcon:updateIconNum(num,color)

--     local text = ccui.Text:create()
--     text:setFontName(GlobalConfig.fontName)
--     text:setLocalZOrder(100)
--     text:setAnchorPoint(cc.p(1, 0.5))
--     text:setPosition(35,-25)
--     self._parent:addChild(text)
--     text:setLocalZOrder(100)
--     text:setFontSize(16)
--     text:setString(num)
--     local url = "images/newGui2/Frame_prop_box_"..color..".png"
--     local rect_table = cc.rect(11,10,2,1)   --小背景框的9宫格参数
--     local textBg = TextureManager:createScale9Sprite(url,rect_table)
--     textBg:setLocalZOrder(80)
--     textBg:setAnchorPoint(cc.p(1, 0.5))
--     textBg:setPosition(41,-31) ---这是小背景框的位置
--     local width = 0
--     local numSize = text:getContentSize() --文字根据字的多少获得的长度
--     if numSize.width <= 23 then
--         width = 23
--         local txtWidth = 41 - (width/2 - numSize.width/2) -- x描点的中心坐标
--         text:setPosition(txtWidth,-30) --这是文字的描点Y坐标位置(除了1之外的位置）
--     else
--         width = numSize.width + 6
--         text:setPosition(37,-30)  ----这是文字的位置
--     end
--     textBg:setContentSize(width, numSize.height+5) ----背景框的尺寸
--     self._parent:addChild(textBg)
-- end

function UISkillIcon:onIconTouch()
    if not self._panel or not self.skillInfo then
        return
    end

    local proxy = self._panel:getProxy(GameProxys.Role)

    local parent = proxy:getCurGameLayer(GameLayer.popLayer)
    local uiTip = UITip.new(parent,120)
    local line = {}
    local lines = {}
    line[1] = {{content = self.skillInfo.name, foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    line[2] = {{content = self.skillInfo.info, foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    table.insert(lines, line[1])
    table.insert(lines, line[2])
    uiTip:setAllTipLine(lines)
end
