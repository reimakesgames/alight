export type Type = Instance | {
	Model: Model | {
		Handle: Part | {
			AimPoint: Attachment;
			EjectionPort: Attachment;
			Muzzle: Attachment;
			PivotPoint: Attachment;
		};
	};
	Handle: Part | {
		Handle: Motor6D
	};
	Hitbox: Part;
	GUID: StringValue;
}

return {}
