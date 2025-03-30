# Contributing to mestiNow

Thank you for your interest in contributing to our project! We welcome contributions from everyone and are grateful for even the smallest of fixes!

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Process](#development-process)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Community](#community)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to felipe@migrandama.com.

## Getting Started

1. **Prerequisites**
   - Install [Flutter SDK](https://flutter.dev/docs/get-started/install)
   - Install [Android Studio](https://developer.android.com/studio) and/or [Xcode](https://developer.apple.com/xcode/)
   - Set up your preferred IDE (VS Code or Android Studio) with Flutter plugins
   - Run `flutter doctor` to verify your setup


2. **Fork the Repository**
   ```bash
   # Clone your fork
   git clone https://github.com/dojosgithub/mestinow.git
   cd repository-name

   # Add upstream remote
   git remote add upstream https://github.com/dojosgithub/mestinow.git
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the App**
   ```bash
   # Check available devices
   flutter devices

   # Run the app
   flutter run
   ```

## Development Process

  <!-- This project uses the GitLab Flow branching strategy.
  - `main` is the default branch and it should always be in a deployable state.
  - All development is done in feature branches off of `main`.
  - When a feature is complete, it is merged into `main`.
  - When a release is ready to be deployed, it is tagged with a version number, pushed to `main` and, after testing, it is merged into `production`.
  - `production` is always in deployable state and represents the current production version of the app.
  For more information regarding the GitLab Flow branching strategy, please refer to the [GitLab Flow Best Practices](https://about.gitlab.com/topics/version-control/what-are-gitlab-flow-best-practices/). -->

1. **Create a Branch**
  Use clear and descriptive branch names and mention the GitHub issue number.
   ```bash
   # From main
   git checkout -b feature/123-your-feature-name
   # or
   git checkout -b fix/24-your-bug-fix
   ```

2. **Make Your Changes**
   - Write meaningful commit messages
   - Keep commits atomic and focused
   - Add tests for new features
   - Update documentation as needed
   - Follow Flutter's style guide

3. **Test Your Changes**
   ```bash
   # Run tests
   flutter test

   # Run static analysis
   flutter analyze

   # Format code
   dart format .
   ```

## Pull Request Process

1. **Update Your Fork**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```
2. **Commit Your Changes**
   Make sure your commit messages are clear and descriptive and that they have a reference to the issue number
   ```bash
   git commit -m "Fixes #123: Description of the fix"
   ```

2. **Push Your Changes**
   ```bash
   git push origin feature/your-feature-name
   ```

3. **Submit a Pull Request**
   - Fill out the PR template completely
   - Link any relevant issues
   - Include screenshots for UI changes
   - Ensure all tests pass
   - Request review from maintainers

4. **PR Review Process**
   - Maintainers will review your code
   - Address any requested changes
   - Once approved, your PR will be merged

## Coding Standards

- Follow [Flutter's style guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo)
- Use meaningful variable and function names
- Comment complex logic
- Write self-documenting code
- Follow Dart best practices
- Use Flutter's widget composition patterns
- Maintain widget tree efficiency

## Testing Guidelines

- Write widget tests for new UI components
- Include unit tests for business logic
- Write integration tests for critical flows
- Ensure existing tests pass
- Test on multiple screen sizes
- Test on both Android and iOS when possible

## Documentation

- Update README.md if needed
- Document new features
- Update API documentation
- Update widget documentation
- Add comments for complex widgets

## State Management

- Follow the project's chosen state management solution
- Keep state management logic separate from UI
- Document state changes
- Consider widget rebuilding efficiency

## Performance Considerations

- Use const constructors where possible
- Implement `shouldRebuild` for custom widgets
- Keep widget tree depth reasonable
- Use appropriate image formats and sizes
- Profile performance with Flutter DevTools

## Community

- Participate in discussions
- Help review pull requests
- Share ideas and feedback
- Be respectful and constructive

## Reporting Bugs

- Use the GitHub issue tracker
- Check existing issues first
- Include detailed steps to reproduce
- Provide system/environment details
  - Flutter version (`flutter --version`)
  - Device/emulator details
  - OS version
- Include screenshots or videos if applicable

## Feature Requests

- Use GitHub issues for feature requests
- Explain the use case
- Be specific about requirements
- Discuss with the community
- Be open to feedback

## Questions?

Don't hesitate to ask questions if something is unclear. You can:
- Open an issue
- Join our community chat
- Contact the maintainers

## License

By contributing to this project, you agree that your contributions will be licensed under its [LICENSE](./LICENSE) license.

---

Thank you for contributing to our project! 🎉 