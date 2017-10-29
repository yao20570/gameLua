UIOtherIcon = class("UIOtherIcon")

--data.power data.typeid data.num
function UIOtherIcon:ctor(parent, data)  --必须要有node，num，颜色,图片id(typeid)
    self._parent = parent
    
    self:updateData(data)
end

function UIOtherIcon:updateData(data)
    self._parent:removeAllChildren()
    -- local url = "images/gui/Frame_prop_" ..data.color..".png"
    --local url = "images/newGui2/Frame_prop_1.png"
    --local bgImg = TextureManager:createImageView(url)
    --bgImg:setLocalZOrder(1)
    --self._parent:addChild(bgImg)
    local urlTure = "images/newGui1/IconPinZhi"..data.color..".png"
    local qualityTure = TextureManager:createImageView(urlTure)
    qualityTure:setLocalZOrder(3)
    self._parent:addChild(qualityTure)

    local iconUrl = string.format("images/pullBarActivity/0%d.png",data.typeid)
    local iconImg = TextureManager:createImageView(iconUrl)
    iconImg:setLocalZOrder(4)
    self._parent:addChild(iconImg)
    self._iconBg = iconImg
    self._qualityTure = qualityTure
    --self._bgImg = bgImg
    if data.num and data.num > 0 then
        self:updateIconNum(data.num,data.color)
    end                       
end

function UIOtherIcon:updateIconNum(num,color)

    local text = ccui.Text:create()
    text:setFontName(GlobalConfig.fontName)
    text:setLocalZOrder(100)
    text:setAnchorPoint(cc.p(1, 0.5))
    text:setPosition(35,-25)
    self._parent:addChild(text)
    text:setLocalZOrder(100)
    text:setFontSize(16)
    text:setString(num)
    local url = "images/newGui2/Frame_prop_box_"..color..".png"
    local rect_table = cc.rect(11,10,2,1)   --小背景框的9宫格参数
    local textBg = TextureManager:createScale9Sprite(url,rect_table)
    textBg:setLocalZOrder(80)
    textBg:setAnchorPoint(cc.p(1, 0.5))
    textBg:setPosition(41,-31) ---这是小背景框的位置
    local width = 0
    local numSize = text:getContentSize() --文字根据字的多少获得的长度
    if numSize.width <= 23 then
        width = 23
        local txtWidth = 41 - (width/2 - numSize.width/2) -- x描点的中心坐标
        text:setPosition(txtWidth,-30) --这是文字的描点Y坐标位置(除了1之外的位置）
    else
        width = numSize.width + 6
        text:setPosition(37,-30)  ----这是文字的位置
    end
    textBg:setContentSize(width, numSize.height+5) ----背景框的尺寸
    self._parent:addChild(textBg)
end

function UIOtherIcon:setIconPosition(posX, posY)
    --self._bgImg:setPosition(cc.p(posX, posY))
    self._qualityTure:setPosition(cc.p(posX, posY))
    self._iconBg:setPosition(cc.p(posX, posY))                     
end