# Security Policy

## Supported Versions

| Version | Supported |
| --- | --- |
| Latest release | Yes |
| Previous minor | Security fixes only |
| Older | No |

## Data Handling

EngLearn stores all data locally on the user's device using SwiftData. The application:

- Makes **zero network requests**
- Collects **zero telemetry or analytics**
- Has **zero third-party dependencies**
- Stores data only in the app's sandboxed container
- Requires microphone access only for the Speaking module (user-initiated)

## Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly:

1. **Do not** open a public issue
2. Email: aderamdani@proton.me (replace with your actual security contact)
3. Include a description of the vulnerability and steps to reproduce
4. Allow reasonable time for a fix before public disclosure

## App Sandbox

EngLearn runs in Apple's App Sandbox with the following entitlements:
- `com.apple.security.app-sandbox`: Enabled
- `com.apple.security.files.user-selected.read-write`: For export features
- `com.apple.security.device.audio-input`: For speech recognition
- `com.apple.security.device.microphone`: For pronunciation practice
