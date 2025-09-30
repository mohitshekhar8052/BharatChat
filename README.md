# BharatChat

A modern Flutter chat application with video calling capabilities for New India.

## Features

### 🚀 Core Features
- **Real-time Messaging**: Instant messaging with Firebase Firestore
- **User Authentication**: Secure login and registration with Firebase Auth
- **Contact Management**: Import and manage contacts
- **Profile Management**: Customizable user profiles
- **Stories**: Share temporary stories like WhatsApp
- **Settings**: Comprehensive app settings and preferences

### 📞 Communication Features
- **Video Calls**: High-quality peer-to-peer video calling using WebRTC
- **Voice Calls**: Crystal clear audio calls
- **Real-time Chat**: Instant messaging with read receipts
- **Image Sharing**: Share photos from camera or gallery
- **Contact Sync**: Automatic contact synchronization

### 🎨 UI/UX Features
- **Dark Theme**: Beautiful dark theme optimized for Indian users
- **Material Design**: Modern Material Design 3 components
- **Responsive UI**: Adaptive layouts for different screen sizes
- **Smooth Animations**: Fluid transitions and animations
- **Indian Design Language**: Culturally relevant design elements

## Technology Stack

### Frontend
- **Flutter**: Cross-platform mobile development
- **Dart**: Programming language
- **Material Design 3**: UI components and theming
- **Provider**: State management

### Backend Services
- **Firebase Authentication**: User authentication and authorization
- **Cloud Firestore**: Real-time NoSQL database
- **Firebase Storage**: File and image storage
- **WebRTC**: Peer-to-peer video/audio communication

### Libraries & Packages
- `firebase_core`: Firebase core functionality
- `firebase_auth`: Authentication services
- `cloud_firestore`: Firestore database integration
- `flutter_webrtc`: WebRTC for video/audio calls
- `image_picker`: Camera and gallery access
- `flutter_contacts`: Contact management
- `permission_handler`: Runtime permissions
- `provider`: State management
- `shared_preferences`: Local data storage

## Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/mohitshekhar8052/BharatChat.git
   cd BharatChat
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android and iOS apps to your Firebase project
   - Download and place configuration files:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`
   - Enable Authentication and Firestore in Firebase Console

4. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── models/           # Data models
├── screens/          # UI screens
├── services/         # Business logic and API services
├── providers/        # State management providers
├── main.dart         # App entry point
└── firebase_options.dart  # Firebase configuration

android/              # Android platform code
ios/                  # iOS platform code
web/                  # Web platform code
```

## Features in Detail

### Authentication System
- Email/password authentication
- User registration with profile setup
- Secure password reset functionality
- Remember me functionality
- Auto-logout on security events

### Real-time Chat
- One-on-one messaging
- Message timestamps and read receipts
- Image sharing capabilities
- Real-time message synchronization
- Chat history management

### Video/Audio Calling
- WebRTC-based peer-to-peer communication
- Video call with camera switching
- Audio-only calls
- Call controls (mute, video toggle, speaker)
- Incoming call notifications

### Contact Management
- Import contacts from phone
- Search and filter contacts
- Add contacts manually
- Contact synchronization
- Privacy controls

## Configuration

### Firebase Security Rules

**Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Chat messages
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
    }
    
    // Call documents
    match /calls/{callId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.callerId || 
         request.auth.uid == resource.data.calleeId);
    }
  }
}
```

### Permissions

**Android Permissions:**
- Camera access for video calls
- Microphone access for audio/video calls
- Contacts access for contact sync
- Internet access for data connectivity
- Network state access for connectivity checks

**iOS Permissions:**
- Camera usage description
- Microphone usage description
- Contacts usage description

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email support@bharatchat.com or join our community chat.

## Acknowledgments

- Firebase team for excellent backend services
- Flutter team for the amazing cross-platform framework
- WebRTC community for real-time communication standards
- Indian developer community for inspiration and feedback

---

**Made with ❤️ for Bharat (India)**
