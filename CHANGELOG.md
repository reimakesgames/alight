# [0.5.1] - 2023-02-08
### Added
- Scene Player
- Main Menu UI (WIP)
- Main Menu Scene (WIP)
- TestEZ Companion Extension
- Unit Tests for Symbol, isRealNumber, tableOperations
- TestEZ Definition File

### Changed
- Unit Testing is now more robust and better Developer Experience (DX)
- Initialization of scripts is now ran by a script in the main menu script handler

### Fixed
- Symbol returning nothing despite being a valid symbol
- MovementHandler being blocked because of the new temporary initialization process

# [0.5.0] - 2023-02-02
### Changed
- Core Functionality utilizes a better programming style
- Link for BridgeNet

### Added
- KeybindHandler with Save/Load
- Basic Map Ping
- MovementHandler
- Basic Implementation of Crosshair but OOPized
- Webhook Class
- Discord Webhook
- Player Joins/Leaves Webhook
- GitHub Community Files
- GitHub Issue Templates
- GitHub Pull Request Template
- GitHub Code of Conduct
- GitHub Contributing Guidelines
- GitHub Security Policy
- Basic Documentation

### Deprecated
- Nearly all of the old code

# [0.4.1] - 2022-11-25
### Changed
- Viewmodel Sway to use camera delta instead of mouse delta
- Viewmodel Rendering performance improvements
- Link and Prisma Version

### Fixed
- Raycasts starting from the player's camera position instead of the player's position
- SFXHandler not disposing spatial audio sources
- SFXHandler not disposing finished audio sources

# [0.4.0] - 2022-11-19
### Added
- Weapon equipping animations
- Debug gui (FPS, Ping, Version)
- Build metadata folder
- Merge PR commenter

### Changed
- Some accesses are now sanitized
- Unit Testing is now simplified

### Removed
- Some print statements
- Workflow scripts

# [0.3.1.1] - 2022-11-17
### Changed
- Management workflow

# [0.3.1] - 2022-11-17
### Added
- New Pull Requests get a comment now
- New Issues get a label automatically

### Changed
- CI Workflows

# [0.3.0] - 2022-11-16
### Added
- Crosshair Class
- Character Ragdolling
- Tool Dropping on Death
- Tool Dropping (Key G)
- Tool Pickup (Key F)
- Tool Select Gui
- Tool GUID

### Changed
- View model table references
- Ejection smoke and bullet is instantaneous now
- CI manager from Foreman to Aftman
- Inspect key is now Y

### Fixed
- Tool Pickup checks
- Inspect and Reload priority conflict
- QuickInstance return type (DX)
- Internal types (DX)
- Class properties in methods not appearing (DX)

# [0.2.3] - 2022-10-18
### Changed
- Viewmodel/Worldmodel now hides itself properly
- Separated Modifier and Viewmodel calls
- Fix wrong key for inspect from G to F



# [0.2.0] - 2022-10-17
### Added
- Weapon Inspect
- Variable Initialize function



### The following entries does not follow the Proper
### Semantic Versioning Guidelines



# [v0.1.4] - 2022-10-16
### Changed
- Update version of link from v0.2.1 to v0.2.4
- Update version of prisma from v0.2.0 to v0.2.1
- Fix tool oriented viewmodel bug when dead and respawned
- Fix API changes with link
- Enabled Leg Rotation

# [v0.1.3] - 2022-10-13
### Added
- Ammunition Reserve
- Reserve Display

### Changed
- Reloading / Firing Ammo Logic
- WeaponClient variable changes

# [v0.1.2] - 2022-10-11
### Added
- Animation Blending
- Equipped Modifier
- Cancellable Reload
- Tool oriented Viewmodels
- Animator Class

# [v0.1.1] - 2022-10-08
### Added
- Basic crouching

# [v0.1.0] - 2022-10-07
### Changed
- API members now have proper naming structure
- Removed some redundant parameters
- Fix server exit bullets rendering
- Made Viewmodel constructor automatically cull ViewmodelClass.Model

# [v0.0.10.e] - 2022-10-05
### Added
- Basic replication of cast
- Predictable Randomness on both client and server

# [v0.0.9] - 2022-10-05
### Changed
- bullets will now wall bang to a max of 4 times
- wall bang loop breaks if bullets get a negative penetration value
- Fix wall bang behavior with incorrect results

# [v0.0.8.p1] - 2022-10-05
### Changed
- Made Changelog follow the KeepAChangelog style
- Changed Header2 in Changelogs client to Header3
- Renamed CHANGELOGS.md to CHANGELOG.md because i am dumb
- Changed file pointer in Changelogs server reflecting this change

# [v0.0.8] - 2022-10-04
### Added
- New Custom Pivot for Viewmodel
- WallBanging
- BulletExit method for ParticleEffects
### Changed
- Made FindThickness return RayCastResult instead of Vector3
- Fix ParticleEmit using Enabled instead of Emit
- Fix Reloading modifier being broken for viewmodel sway
- Fix WalkCycle not being seamless when sprinting and walking

# [v0.0.7.p1]
### Added
- Loading indicator in changelogs
### Changed
- Replaced individual TextLabels for changelog into a single TextLabel
- Fix request changelogs having no rate limit
- Fix changelogs requests would make duplicate frames

# [v0.0.7]
### Added
- Changelog List UI
- Github File Fetcher



### Everything past here is not properly documented



# [v0.0.6]
### Changed
- Replaced BulletHole Parts to use Attachments instead
- Tweaked spring values to reflect on states
- Fix LinearInterpolate to be framerate independent

# [v0.0.5]
### Added
- Bullet Shells
- LinearInterpolate module
### Changed
- Better checks to the Reload function
- Renamed Instance references in scripts
- Tweaked spring values to reflect on states
- Fix bullet hole to weld onto part instead of anchored
- Fix caster not ignoring camera children
- Fix broken sprinting offsets
- Fix weapon states
### Removed
- Individual LinearInterpolate functions

# [v0.0.4]
### Added
- Aiming
- Basic reloading animation
- Reloading camera shake
- SoundEffects module
- EmitParticles method
- Viewmodel decorations
- WalkCycles, Recoil, Sprinting states and springs
### Fixes
- Fix smoke trail going past the hit position

# [v0.0.3]
### Added
- Viewmodel module
- Spring utility
- Smoke Trail
### Fixes
- Minor fixes

# [v0.0.2]
### Added
- VisualEffects module
### Changed
- Optimized the RayCast System
- Optimized the VisualEffects module
- Renamed the VisualEffects module to ParticleEffects

# [v0.0.1]
### Added
- RayCast System
- PartThickness Method
### Fixes
- Fix Filesystem errors
