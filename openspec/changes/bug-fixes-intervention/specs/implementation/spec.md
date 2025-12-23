## ADDED Requirements

### Requirement: B42 API Compatibility Layer
The system SHALL implement manual API compatibility fixes for Build 42 to resolve undocumented API changes and type validation failures.

#### Scenario: API Method Migration
- **WHEN** EmmyLua type validation reveals deprecated method signatures
- **THEN** system migrates from `luautils.walkToAdjacentTile()` to `luautils.walkAdj()`
- **AND** adds required `require('utl')` import for B42 compatibility
- **AND** updates parameter order to match B42 signatures

#### Scenario: Event Registration Simplification
- **WHEN** B42 event system becomes more reliable
- **THEN** system removes redundant safety checks for event registration
- **AND** uses direct `Events.OnFillWorldObjectContextMenu.Add()` calls
- **AND** eliminates verbose error logging for missing event handlers

### Requirement: Inventory Synchronization Safety
The system SHALL implement Java container-safe inventory operations to prevent multiplayer synchronization errors.

#### Scenario: Container Operation Sequence
- **WHEN** performing inventory modifications in timed actions
- **THEN** system avoids storing `getInventory()` in variables across operations
- **AND** uses direct method calls for each inventory operation
- **AND** sequences `AddItem()` before `Remove()` to prevent container state conflicts

#### Scenario: Java Container Error Prevention
- **WHEN** Java container operations fail during inventory sync
- **THEN** system provides proper error boundaries around inventory modifications
- **AND** maintains client-server state consistency
- **AND** uses B42-compatible inventory synchronization patterns

### Requirement: Performance Optimization Patterns
The system SHALL implement performance optimizations for bulk operations while maintaining functionality.

#### Scenario: Bulk Operation Early Returns
- **WHEN** processing multiple items in `dryAll()` functions
- **THEN** system validates player proximity once with `luautils.walkAdj(player, rack:getSquare(), true)`
- **AND** returns early if distance validation fails
- **AND** eliminates redundant distance checks in processing loops

#### Scenario: Redundant Operation Elimination
- **WHEN** context menu actions are queued
- **THEN** system removes duplicate `walkToAdjacentTile()` calls in loops
- **AND** fixes context menu option parameter order
- **AND** optimizes inventory scanning patterns

### Requirement: Type Safety Enforcement
The system SHALL utilize EmmyLua type validation to catch API issues during development rather than runtime.

#### Scenario: Type-Driven Development
- **WHEN** `emmyrc-check` command reveals type mismatches
- **THEN** system adds proper type annotations for all function parameters
- **AND** documents undefined type resolution strategies for B42 APIs
- **AND** creates type-safe interfaces for game object interactions

#### Scenario: Global Variable Handling
- **WHEN** EmmyLua reports undefined global variables
- **THEN** system documents which globals are provided by the game engine
- **AND** adds proper type annotations for global objects
- **AND** creates explicit import statements where required

### Requirement: Error Handling Enhancement
The system SHALL provide enhanced error handling and user feedback for B42 multiplayer environments.

#### Scenario: Improved User Feedback
- **WHEN** drying operations complete successfully
- **THEN** system uses `HaloTextHelper.addGoodText()` instead of generic colored text
- **AND** provides contextual success messages for different operation types
- **AND** maintains consistent feedback patterns across all drying operations

#### Scenario: Distance Validation Improvements
- **WHEN** player attempts actions from invalid distances
- **THEN** system provides clear distance requirement feedback
- **AND** validates distances before queuing timed actions
- **AND** uses B42-compatible distance calculation methods

## MODIFIED Requirements

### Requirement: Context Menu Implementation
The system SHALL provide context menu options with B42-compatible event registration, proper type annotations, and enhanced parameter handling for multiplayer synchronization.

#### Scenario: Enhanced Context Menu Registration
- **WHEN** registering context menu event handlers
- **THEN** system uses direct event registration without safety checks
- **AND** provides proper type annotations for all callback parameters
- **AND** implements B42-specific parameter order requirements

### Requirement: Timed Action Processing
The system SHALL process drying actions through timed actions with Java container-safe inventory operations and B42-compatible synchronization patterns.

#### Scenario: Container-Safe Processing
- **WHEN** executing timed actions that modify inventory
- **THEN** system uses direct inventory method calls without variable caching
- **AND** sequences operations to prevent Java container conflicts
- **AND** provides proper multiplayer synchronization

### Requirement: Development Workflow Integration
The system SHALL follow B42-specific modding patterns with EmmyLua type validation integration and API compatibility documentation.

#### Scenario: Type-Driven Development Workflow
- **WHEN** implementing new mod components
- **THEN** system validates types using `emmyrc-check` before testing
- **AND** documents all manual API compatibility fixes
- **AND** maintains B42 API pattern documentation for future reference