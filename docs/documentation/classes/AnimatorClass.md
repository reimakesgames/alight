# AnimatorClass

A top-level class that provides a number of useful methods for working with Animators

## Constructors
### new
```lua
AnimatorClass.new() -> AnimatorClass
```

Returns a new [AnimatorClass](#animatorclass)

---

## Destructors
### Destroy
```lua
AnimatorClass:Destroy() -> nil
```

Clears the [AnimatorClass.Tracks](#tracks) table and unreferences everything

---

## Properties
### Tracks
```lua
AnimatorClass.Tracks: { [string]: AnimationTrack }
```

A table of all the AnimationTracks in the animator loaded by [AnimatorClass:LoadAnimation](#loadanimation)

!!! note
	This property is read-only, and cannot be manually set.

---

### Animator
```lua
AnimatorClass.Animator: Animator = nil
```

The [Animator](https://developer.roblox.com/en-us/api-reference/class/Animator) instance of the animator

---

## Methods
### Load
```lua
AnimatorClass:Load(animation: Animation, trackName: string) -> nil
```

Loads an [Animation](https://developer.roblox.com/en-us/api-reference/class/Animation) into the animator
and inserts it into the [AnimatorClass.Tracks](#tracks) table

!!! error
	This method will throw an error if the [AnimatorClass.Animator](#animator) property is `nil`

!!! danger
	This method is deprecated and will be removed in the future

---
### LoadAnimation
