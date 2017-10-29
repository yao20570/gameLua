UICheckBox = class("UICheckBox")

--一个CheckBox 右边再对应一个富文本 {content =, foneSize =, color =}
function UICheckBox:ctor(checkBox, contentLine)
    self:initCheckBox(checkBox, contentLine)
end

function UICheckBox:initCheckBox(checkBox, contentLine)

    local label = ComponentUtils:createRichLabel("", nil, nil, nil)
    label:setString({contentLine})

    -- local html = StringUtils:getHtmlByLines({contentLine})
    -- local label = ComponentUtils:createRichNodeWithString(
    --     html,cc.size(200,0))


    -- label:setAnchorPoint(cc.p(0, 0.5))
    
    local x, y = checkBox:getPosition()
    local size = checkBox:getContentSize()
    
    checkBox:getParent():addChild(label)
    label:setPosition(x + size.width / 2 + 10, y + size.height / 2 - 5)
    
    self._label = label
    self._checkBox = checkBox
end

function UICheckBox:updateContent(contentLine)
    -- local html = StringUtils:getHtmlByLines({contentLine})
    self._label:setString({contentLine})
end

-- 文本坐标修正
function  UICheckBox:fixLabelMidPos()
    local x, y = self._checkBox:getPosition()
    local size = self._checkBox:getContentSize()
    self._label:setPosition(x + size.width / 2 + 10, y + size.height / 2 - 20)
end

