
------获取道具弹框特效---
GetPropAnimation = class("GetPropAnimation", BaseAnimation)


function GetPropAnimation:finalize()

	GetPropAnimation.super.finalize(self)

end

function GetPropAnimation:play()
    local uiGetProp = self._uiGetProp
    if uiGetProp == nil then
    	uiGetProp = UIGetProp.new(self.parent, self, true)
    	self._uiGetProp = uiGetProp
    end

    uiGetProp:show(self.data)
end

