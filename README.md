# ProcFrame

ProcFrame is a macOS application for **composing animations** with image-based **nodes**. The goal is to build motion by arranging nodes and their transforms (position, rotation, etc.) and then animating them through a timeline. The project is **under active development** and not yet at an MVP stage.

## Current Features
- **Image Importing** - Supports PNG, JPG, and TIFF.
- **Node Manipulation** - Select, move, rotate, scale, and adjust anchor/opacity.
- **Highlight System** - Selected nodes display a visual highlight.
- **Layer Ordering** - Adjust node `zPosition` via keyboard shortcuts.
- **Zoom & Pan** - Navigate the scene with mouse and trackpad controls.
- **Keyframe Timeline (position + rotation)** - Per-node tracks with draggable segments, ruler scrubbing, snapping to ticks, and playback that updates node transforms using interpolation.
- **Interpolation Modes** - Per-segment interpolation (linear/ease/stepped) via context menu.
- **Timeline Persistence** - Keyframes are saved to Application Support and reloaded on startup.

## Proposed Keyframe Data Model (Draft)
This is a lightweight model focused on position + rotation (and ready for future expansion):

- `TransformKeyframe`: `{ id, nodeID, time, position, rotation, interpolation }`
- `NodeAnimationTrack`: `{ nodeID, keyframes: [TransformKeyframe] }`
- `AnimationTimeline`: `{ duration, tracks: [NodeAnimationTrack] }`
- `KeyframeInterpolation`: `linear | easeInOut | stepped` (extendable)

The Action Timeline Panel will evolve from action blocks into a true keyframe editor that reads/writes this model.
