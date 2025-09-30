# Contributing to BharatChat

Thank you for your interest in contributing to BharatChat! We welcome contributions from the community.

## How to Contribute

### 1. Fork the Repository
- Fork the repository on GitHub
- Clone your fork locally

### 2. Set up Development Environment
- Install Flutter SDK (3.9.2 or higher)
- Install dependencies: `flutter pub get`
- Set up Firebase project and configuration

### 3. Create a Branch
```bash
git checkout -b feature/your-feature-name
```

### 4. Make Changes
- Follow the existing code style
- Add tests for new features
- Update documentation as needed

### 5. Test Your Changes
```bash
flutter test
flutter analyze
```

### 6. Submit a Pull Request
- Push your changes to your fork
- Create a pull request with a clear description
- Reference any related issues

## Code Style Guidelines

### Dart/Flutter
- Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` to format your code
- Run `flutter analyze` to check for issues
- Add documentation comments for public APIs

### File Organization
```
lib/
├── models/          # Data models
├── screens/         # UI screens
├── services/        # Business logic
├── providers/       # State management
└── widgets/         # Reusable widgets
```

### Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/Functions: `camelCase`
- Constants: `SCREAMING_SNAKE_CASE`

## What Can You Contribute?

### 🐛 Bug Fixes
- Report bugs via GitHub Issues
- Include steps to reproduce
- Provide system information

### ✨ New Features
- Discuss new features in Issues first
- Keep features focused and atomic
- Include tests and documentation

### 📚 Documentation
- Improve existing documentation
- Add code examples
- Fix typos and grammar

### 🎨 UI/UX Improvements
- Follow Material Design guidelines
- Maintain consistency with existing UI
- Consider accessibility

## Priority Areas

1. **WebRTC Improvements**
   - Better error handling
   - Connection optimization
   - Screen sharing support

2. **Performance Optimization**
   - Message loading performance
   - Image compression
   - Memory management

3. **Accessibility**
   - Screen reader support
   - High contrast themes
   - Font scaling support

4. **Internationalization**
   - Hindi language support
   - Regional Indian languages
   - Right-to-left text support

## Getting Help

- Join our community discussions
- Check existing issues and pull requests
- Ask questions in issues with the "question" label

## Code of Conduct

Please be respectful and inclusive in all interactions. We want BharatChat to be a welcoming project for everyone.

Thank you for contributing to BharatChat! 🚀