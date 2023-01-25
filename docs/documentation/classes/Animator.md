# Animator

A top-level class that provides a number of useful methods for working with Animators

---

## Constructors
### new
```lua
Animator.new() -> Animator
```

Returns a new [Animator](#animator)

---

## Destructors
### Destroy
```lua
Animator:Destroy() -> ()
```

Clears the [Animator.Tracks](#tracks) table and clears itself

---

## Properties
### Tracks
```lua
Animator.Tracks: { [string]: AnimationTrack }
```

A table of all the AnimationTracks in the animator loaded by [Animator:LoadAnimation](#loadanimation)

!!! note
	This property is read-only, and cannot be manually set.

### _PauseList
```lua
Animator._PauseList = { [string]: number }
```

A table that's used by [Animator:PauseAnimation](#pauseanimation) to be able to resume animations with the same speed

!!! warning
	This property is a private member!

### Animator
```lua
Animator.Animator: Animator = nil
```

The [Animator](https://developer.roblox.com/en-us/api-reference/class/Animator) instance of the animator

---

## Methods

### IsA
```lua
Animator:IsA(className: string) -> boolean
```
{!documentation\classes\isAFunction.md!}

### SetAnimator
```lua
Animator:SetAnimator(animator: Animator) -> ()
```
Sets the Animator of the Object.

!!! warning
	This must be called before calling other methods as the reference is nil and cause everything to break!

### LoadAnimation
```lua
Animator:LoadAnimation(trackName: string, animation: Animation, properties: { animationPriority: Enum.AnimationPriority?, looped: boolean? }) -> ()
```

Loads an [Animation](https://developer.roblox.com/en-us/api-reference/class/Animation) into the animator
and inserts it into the [Animator.Tracks](#tracks) table

The properties parameter contains:
* **animationPriority** which is an Enum.AnimationPriority and is optional
* **looped** which is a boolean and is optional

!!! error
	This method will throw an error if the [Animator.Animator](#animator) property is `nil`

### PlayAnimation
```lua
Animator:PlayAnimation(trackName: string, properties: { playSpeed: number?, playReversed: boolean?, weight: number?, weightFade: number? }? ) -> ()
```

Plays the animation provided the track name

The optional `properties` parameter contains:

| Parameter | Description |
| --- | --- |
| `playSpeed: number? = 1` |  |
| `playReversed: boolean? = false` | |
| `weight: number? = 1` | |
| `weightFade: number? = 0.1` | |



### PauseAnimation
```lua
Animator:PauseAnimation(trackName: string) -> ()
```

Pauses the selected animation which keeps its original properties,
But can be resumed by [ResumeAnimation](#resumeanimation)

### ResumeAnimation
```lua
Animator:ResumeAnimation(trackName: string, newSpeed: number?) -> ()
```

Resumes the paused track if it is paused and is inside [_PauseList](#_pauselist) with an optional parameter `newSpeed` to replace its speed

### StopAnimation
```lua
Animator:StopAnimation(trackName: string, properties: { weightFade: number?, forceStop: boolean? }?) -> ()
```

Method that stops the selected track, with an optional `properties` parameter that contains:
* **weightFade** which is a number
* **forceStop** which is a boolean

these two properties cannot exist together as they are mutually exclusive.
forceStop will be ignored if they both exist.

### AdjustWeight
```lua
Animator:AdjustWeight(trackName: string, weight: number) -> ()
```

!!! note
	Works like AnimationTrack:AdjustWeight()

### AdjustSpeed
```lua
Animator:AdjustSpeed(trackName: string, speed: number) -> ()
```

!!! note
	Works like AnimationTrack:AdjustSpeed()

### AdjustTimePosition
```lua
Animator:AdjustTimePosition(trackName: string, timePosition: number) -> ()
```

!!! note
	Works like AnimationTrack.TimePosition but as a function instead
