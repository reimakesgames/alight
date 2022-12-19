# SpringClass

A top-level class that provides a number of useful methods for working with Springs

## Constructors
### new
```lua
SpringClass.new(mass: number, force: number, damping: number, speed: number) -> SpringClass
```

Returns a new [SpringClass](#springclass)

---

## Destructors
### Destroy

---

## Properties
### Target
```lua
SpringClass.Target: Vector3 = Vector3.new(0, 0, 0)
```

The target position of the spring

---

### Position
```lua
SpringClass.Position: Vector3 = Vector3.new(0, 0, 0)
```

The current position of the spring

---

### Velocity
```lua
SpringClass.Velocity: Vector3 = Vector3.new(0, 0, 0)
```

The current velocity of the spring

---

### Mass
```lua
SpringClass.Mass: number = 4
```

The mass of the spring

---

### Force
```lua
SpringClass.Force: number = 50
```

The force of the spring

---

### Damping
```lua
SpringClass.Damping: number = 4
```

The damping of the spring

---

### Speed
```lua
SpringClass.Speed: number = 4
```

The speed of the spring

---

## Methods
### Step
```lua
SpringClass:Step(deltaTime: number) -> nil
```

Steps the spring by the given delta time

This should be called every frame with a `RunService.Heartbeat`/`RenderStepped`/`Stepped` event
!!! warning
	This isn't a lazy function, so you should call this every frame

```lua title="Example" linenums="1"
local RunService = game:GetService("RunService")

local spring = Spring.new()

RunService.Heartbeat:Connect(function(deltaTime)
	spring:Step(deltaTime)
end)
```

---

### ApplyForce
```lua
SpringClass:ApplyForce(force: Vector3) -> nil
```

Applies a force to the spring

```lua title="Example" linenums="1"
local spring = Spring.new()

spring:ApplyForce(Vector3.new(0, 50, 0))
```
