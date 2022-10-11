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