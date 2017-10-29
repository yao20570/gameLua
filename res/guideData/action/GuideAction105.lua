local GuideAction105 = class("GuideAction105", DialogueAction)

function GuideAction105:ctor()
    GuideAction105.super.ctor(self)

    self.info = ""
end

function GuideAction105:onEnter(guide)
    GuideAction105.super.onEnter(self, guide)

end

return GuideAction105