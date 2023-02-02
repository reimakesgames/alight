local ActiveHumanoid = require(script.Parent:WaitForChild("ActiveHumanoid"))

export type Type = Model | {
	HumanoidRootPart: Part | {
		Climbing: Sound;
		Died: Sound;
		FreeFalling: Sound;
		GettingUp: Sound;
		Jumping: Sound;
		Landing: Sound;
		Running: Sound;
		Splash: Sound;
		Swimming: Sound;

		RootAttachment: Attachment;
		RootJoint: Motor6D
	};
	Torso: BasePart | {
		roblox: Decal;

		NeckAttachment: Attachment;
		BodyFrontAttachment: Attachment;
		BodyBackAttachment: Attachment;
		LeftCollarAttachment: Attachment;
		RightCollarAttachment: Attachment;
		WaistFrontAttachment: Attachment;
		WaistCenterAttachment: Attachment;
		WaistBackAttachment: Attachment;

		Neck: Motor6D;
		["Right Shoulder"]: Motor6D;
		["Left Shoulder"]: Motor6D;
		["Right Hip"]: Motor6D;
		["Left Hip"]: Motor6D;
	};
	Head: BasePart | {
		Mesh: SpecialMesh;
		HairAttachment: Attachment;
		HatAttachment: Attachment;
		FaceFrontAttachment: Attachment;
		FaceCenterAttachment: Attachment;
		face: Decal;
	};
	["Left Arm"]: BasePart | {
		LeftShoulderAttachment: Attachment;
		LeftGripAttachment: Attachment;
	};
	["Right Arm"]: BasePart | {
		RightShoulderAttachment: Attachment;
		RightGripAttachment: Attachment;
	};
	["Left Leg"]: BasePart | {
		LeftFootAttachment: Attachment;
	};
	["Right Leg"]: BasePart | {
		RightFootAttachment: Attachment;
	};

	Humanoid: ActiveHumanoid.Type | Humanoid;
	Animate: LocalScript;
	Health: Script;

	BodyColors: BodyColors;
	Shirt: Shirt;
	Pants: Pants;
}

return {}
