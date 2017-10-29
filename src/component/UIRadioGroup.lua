UIRadioGroup = class("UIRadioGroup")

function UIRadioGroup:ctor(checkBoxList, initIndex)

    self._checkBoxList = checkBoxList
    self._curSelectIndex = initIndex or 0
    
    self:initGroup()
end

function UIRadioGroup:getCurSelectIndex()
    return self._curSelectIndex 
end

function UIRadioGroup:setSelectIndex(index)
    self._curSelectIndex = index
    self:resetGroupState()
end

function UIRadioGroup:initGroup()
    for index, checkBox in pairs(self._checkBoxList) do
    	checkBox.index = index
        self:registerCheckBoxEvent(checkBox)
        checkBox:setSelectedState(index == self._curSelectIndex)
    end    
end


function UIRadioGroup:registerCheckBoxEvent(checkBox)
    local function selectedEvent(sender,eventType)
        if eventType == ccui.CheckBoxEventType.selected then
            self._curSelectIndex = sender.index
            self:resetGroupState()
        elseif eventType == ccui.CheckBoxEventType.unselected then
            if self._curSelectIndex == sender.index then
                self._curSelectIndex = 0 --没有选择的了。
            end
        end
    end  
    
    checkBox:addEventListener(selectedEvent)  
end

function UIRadioGroup:resetGroupState()
    for index, checkBox in pairs(self._checkBoxList) do
        checkBox:setSelectedState(index == self._curSelectIndex)
    end 
end

