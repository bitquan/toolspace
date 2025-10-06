# Toolspace Core

This directory contains shared components used across all micro-tools in the Toolspace platform.

## Components

### Routing & Navigation
- `routes.dart` - Central router configuration for all tools
- `services/tool_navigation.dart` - Navigation helpers for cross-tool workflows

### Services
- `services/tool_integration_service.dart` - Cross-tool data sharing singleton
- Authentication helpers
- Billing integration stubs

### UI Components
- `ui/tool_transition.dart` - Consistent page transitions
- `ui/send_to_tool_button.dart` - Reusable "Send to Tool" button
- Theme and shared widgets

## Usage

Tools should import core components to maintain consistency across the platform.
