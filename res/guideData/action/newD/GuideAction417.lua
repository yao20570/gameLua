local GuideAction417 = class("GuideAction417", DialogueAction)

function GuideAction417:ctor()
    GuideAction417.super.ctor(self)
    
    self.info = "大人威武，相信贼寇们近期不敢来犯恶了。"  --

    self.moduleName = ModuleName.MapModule --
    
end

return GuideAction417


