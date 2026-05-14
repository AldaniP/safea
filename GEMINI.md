# Safea App - Project Instructions

<!-- SPECKIT START -->
**Current Implementation Plan**: [specs/001-ai-emotional-analysis/plan.md](specs/001-ai-emotional-analysis/plan.md)
<!-- SPECKIT END -->

## Project Overview
Safea is a Flutter-based mental health application featuring AI emotional analysis, interactive therapy roadmaps, and professional consultation.

## Core Conventions
- **State Management**: Use `provider`.
- **Services**: Use Singleton pattern for core services (e.g., `SocketService`, `SecureVaultService`).
- **Privacy**: All sensitive emotional data MUST be encrypted via `SecureVaultService` before persistence.
- **Real-time**: Real-time AI interaction is handled via Socket.IO streaming to FastAPI.
