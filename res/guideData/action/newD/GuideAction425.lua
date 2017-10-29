local GuideAction425 = class("GuideAction425", DialogueAction)

function GuideAction425:ctor()
    GuideAction425.super.ctor(self)
    
    self.info = "主公简直鲁班转生，建设能力超群啊"  --
    self.delayTimePre = 0.5     
end

--
function GuideAction425:callback(value)
    GuideAction425.super.callback(self, value)

    self._guide:hidePanel(ModuleName.MainSceneModule, "BuildingUpPanel")
end

return GuideAction425


