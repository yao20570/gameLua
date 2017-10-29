local GuideAction2426 = class( "GuideAction101", DialogueAction)
function GuideAction2426:ctor()
    GuideAction2426.super.ctor(self)

    self.info = "主公，获得更多军械，就挑战战役-鲜卑远征吧！"



end

function GuideAction2426:onEnter(guide)
    GuideAction2426.super.onEnter(self, guide)

    guide:hideModule(ModuleName.PartsWarehouseModule)
end

return GuideAction2426