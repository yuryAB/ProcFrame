# Action Plan: Keyframe Timeline

## Current State (Action Timeline Panel)
- `ActionTimelineViewModel` holds `timelineDuration`, `currentTime`, and a timer that increments time during playback.
- `ActionMark` is a simple range `{ nodeID, startTime, duration }` stored in `ProcFrameViewModel`.
- `TimelineTrackView` renders one row per node and a "+" button that creates an `ActionMark` at a fixed time.
- `ActionTrackView` renders a block with draggable edges to edit start/duration.
- There is **no data model** for keyframes yet, and **playback does not drive** node transforms.

## Proposed Keyframe Data Model (Domain)
Focus on position + rotation now, with room to extend later:

- `TransformKeyframe`: `{ id, nodeID, time, position, rotation, interpolation }`
- `NodeAnimationTrack`: `{ nodeID, keyframes: [TransformKeyframe] }`
- `AnimationTimeline`: `{ duration, tracks: [NodeAnimationTrack] }`
- `KeyframeInterpolation`: `linear | easeInOut | stepped` (extendable)

Notes:
- Keyframes are stored in time order.
- Sampling returns the closest keyframe or interpolates between two.
- We can extend `TransformKeyframe` later to include scale/opacity/anchor.
- `interpolation` is stored on the **starting keyframe** and defines the curve used **until the next keyframe**.
- The same curve applies to both position and rotation for that segment.
- A visible animation segment exists only **between two keyframes** (no motion with a single keyframe).
- When the user creates the first keyframe, the system auto-creates a **start keyframe at time 0** with the current transform.
- The user can **drag the segment start** (i.e., move that first keyframe in time) to change the initial time position.
- When the user changes a node transform while `currentTime` is set, a keyframe is auto-recorded at that time.

## Plan of Action

### Phase 1 - Domain + Store
- Add keyframe entities in `ProcFrame/Domain/Entities/`.
- Add use cases:
  - `AddKeyframe`, `RemoveKeyframe`, `MoveKeyframe`
  - `SampleTransformAtTime` (linear interpolation first)
  - `ApplyTimelineAtTime` (mutate nodes with sampled transforms)
- Add `timeline` storage to `ProcFrameViewModel`.
- Keep `ActionMark` for now, but plan to replace it in UI.
- Business rule: parented nodes **do not require** their own keyframes if they only follow the parent transform. A keyframe is created only when the user animates the child explicitly.
- When a node is deleted, its animation track is removed automatically.

### Phase 2 - Timeline UI (Keyframe Editing)
- Replace `ActionMark` blocks with keyframe markers per node track.
- "Add keyframe" should capture the selected node's position/rotation at `currentTime`.
- Show keyframes aligned to the timeline ruler; allow drag to change time.
- Update selection behavior: selecting a keyframe shows its values in the edition panel.

### Phase 3 - Playback + Scrubbing
- During playback, sample each node's track at `currentTime` and apply transforms to the node store.
- Scrubbing `currentTime` should also update nodes (non-destructive preview).
- Decide how to handle user edits while playing (pause playback or create new keyframe).
- Ensure SpriteKit scene stays in sync when timeline updates node transforms.
 - When duration changes, keyframes after the new end should be clamped to the timeline duration.
- Optional later: generate SKAction sequences from keyframes, using the same interpolation curve as `timingMode` / `timingFunction`.

### Phase 4 - UX Polishing
- Snapping to ruler ticks (optional).
- Interpolation selector per keyframe or per track.
- Visual feedback for active keyframe and current time.
- Context menu actions to edit interpolation and remove keyframes.
- Track handle behavior: left handle moves the whole segment (start + end); right handle adjusts duration (end).

### Phase 5 - Persistence (Later)
- Use JSON persistence in Application Support (`timeline.json`).
- Load timeline on app start and auto-save on timeline changes.

## Decisions Needed
- Replace `ActionMark` entirely or reuse it as a "clip" between keyframes.
- Time unit: seconds (current UI) vs frames/fps (future).
- Should keyframes be per-property or unified `TransformKeyframe` (recommended initially).
- Confirm interpolation choices per keyframe (linear, easeIn, easeOut, easeInOut, stepped, or custom Bezier).
