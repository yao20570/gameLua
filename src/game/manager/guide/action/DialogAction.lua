DialogAction = class("DialogAction", DialogueAction)

function DialogAction:ctor()
    DialogAction.super.ctor(self)
end

function DialogAction:finalize()
    DialogAction.super.finalize(self)
end

function DialogAction:onEnter(guide)
    DialogAction.super.onEnter(self, guide)    
end

--渲染引导
function DialogAction:renderView(view, callback)
    self._infoIndex = self._infoIndex or 1
    local info = self._infos[self._infoIndex]

    view:updateDialogueInfo(info, callback) -- 调用guideView里的显示函数

    self._infoIndex = self._infoIndex + 1
end


function DialogAction:callback(value)    
    
    AudioManager:playEffect("Button")
            
    if self._infoIndex <= #self._infos then
        local view = self._guide:getView()
        self:renderView(view, function() 
            self:callback(self.callbackArg) 
        end)
        return
    end

    DialogAction.super.callback(self, value)
end
