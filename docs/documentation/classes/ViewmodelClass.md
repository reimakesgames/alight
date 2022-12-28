# ViewmodelClass

A top-level class that provides a number of useful methods for working with Viewmodels

Written by [Synthranger](https://github.com/Synthranger)
and modified by [reimakesgames](https://github.com/reimakesgames)

## Constructors
### new
```lua
ViewmodelClass.new(model: Model) -> ViewmodelClass
```

Returns a new [ViewmodelClass](#viewmodelclass)

---

## Destructors
### CleanUp
```lua
ViewmodelClass:CleanUp() -> nil
```

Destroys the Model, Decoration, clears the Springs table, and unreferences everything.

!!! danger
	This method will be replaced with a `Destroy` method in the future for consistency.

---

### Destroy

---

## Properties
### Model
```lua
ViewmodelClass.Model: Model | DefaultArms
```

The model of the viewmodel, which is a [DefaultArms](DefaultArms.md).

!!! note
	This property is read-only, and cannot be manually set.

	You can only set this property by passing the model into the constructor.

!!! note
	The name of the class is `DefaultArms` despite it being the Arms and Viewmodel all together.

	It will be renamed to `DefaultViewmodel` in the future.

---

### Decoration

```lua
ViewmodelClass.Decoration: Model
```
!!! note
	This property is read-only, and cannot be manually set.

	Use [`Decorate()`](#decorate) to change the decoration of the viewmodel.

!!! warning
	This property is misnamed and will be renamed to `Arms` in the future.

---

### Culled
```lua
ViewmodelClass.Culled: boolean = true
```

Whether or not the viewmodel is culled.

If `true`, the viewmodel will be culled, and forcefully set the Model's `CFrame` to `CFrame.new(0, -128, 0)`

!!! note
	This property is read-only, and cannot be manually set.

	Use [`Cull()`](#cull) to change the culling state of the viewmodel.

---

### Animator
```lua
ViewmodelClass.Animator: AnimatorClass
```

The [AnimatorClass](AnimatorClass.md) of the viewmodel.

This property is set to the Model's AnimationController's Animator at the time of construction.

!!! note
	This property is read-only, and cannot be manually set.


---

### Springs
```lua
ViewmodelClass.Springs: { [string]: SpringClass }
```

A table of [SpringClass](SpringClass.md) objects that are used to animate the viewmodel.

!!! warning
	These springs are highly wasteful of memory, and should be used sparingly.

!!! Danger
	This property is deprecated, and will be removed in the future.

---

## Methods
### Decorate
```lua
ViewmodelClass:Decorate(decoration: Model | DefaultArms) -> nil
```

Decorates the viewmodel with the given model.
Welding the "Left Arm" and "Right Arm" of the decoration to the viewmodel.

---

### Cull
```lua
ViewmodelClass:Cull(enabled: boolean) -> nil
```

Culls the viewmodel, and forcefully set the Model's `CFrame` to `CFrame.new(0, -128, 0)`

!!! error
	Calling this function with any boolean state will still put the viewmodel at `CFrame.new(0, -128, 0)`

---

### SetCFrame
```lua
ViewmodelClass:SetCFrame(cframe: CFrame) -> nil
```

Sets the CFrame of the viewmodel.
If the viewmodel is culled, this will do nothing.
Otherwise, it will set the CFrame of the viewmodel's `Model` property.
