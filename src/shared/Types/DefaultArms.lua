export type Type = Model | {
	AnimationController: AnimationController | {
		Animator: Animator
	};
	["Left Arm"]: Part;
	["Right Arm"]: Part;
	HumanoidRootPart: Part;
	Camera: Part;
	WeaponModel: Model | {
		AimPoint: Attachment;
		Muzzle: Attachment;
		EjectionPort: Attachment;

		Handle: Part | {
			Muzzle: Attachment;
			EjectionPort: Attachment;
			AimPoint: Attachment;
			PivotPoint: Attachment;
		};
	};
}

return {}
