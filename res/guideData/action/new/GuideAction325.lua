local GuideAction325 = class("GuideAction325", DialogueAction)

function GuideAction325:ctor()
    GuideAction325.super.ctor(self)
    
    self.info = "主公简直鲁班转生，建设能力超群啊"  --
    
end

--
function GuideAction325:callback(value)
    GuideAction325.super.callback(self, value)

    self._guide:hidePanel(ModuleName.MainSceneModule, "BuildingUpPanel")
end

return GuideAction325


