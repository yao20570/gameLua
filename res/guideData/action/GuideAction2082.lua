local GuideAction2082 = class( "GuideAction101", DialogueAction)
function GuideAction2082:ctor()
   GuideAction2082.super.ctor(self)

	self.info = "选择武将进行培养"
end

function GuideAction2082:onEnter(guide)
	GuideAction2082.super.onEnter(self, guide)
end

return GuideAction2082
