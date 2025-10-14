# Virtual Glasses Try-On App

Ek Flutter-based mobile app jo aapko real-time mein glasses try karne ki facility deti hai using face detection aur AR technology.

## Features

- **Real-time Face Detection**: Google ML Kit ka use karke accurate face tracking
- **Virtual Glasses Overlay**: Glasses ko face par perfectly position karna
- **Multiple Glasses Options**: Different styles aur colors ke glasses choose kar sakte hain
- **Photo Capture**: Apni favorite look ko capture kar sakte hain
- **Cross-platform**: Android aur iOS dono platforms par kaam karta hai

## Technology Stack

- **Flutter**: Cross-platform mobile development
- **Google ML Kit**: Face detection aur landmark tracking
- **Camera Plugin**: Real-time camera access
- **Provider**: State management

## Setup Instructions

### Prerequisites

1. Flutter SDK install hona chahiye (version 3.0.0 ya usse upar)
2. Android Studio / Xcode (platform ke hisaab se)
3. Ek physical device ya emulator with camera support

### Installation

1. Repository clone karein:
```bash
git clone <repository-url>
cd virtual_glasses_tryon
```

2. Dependencies install karein:
```bash
flutter pub get
```

3. Android ke liye:
```bash
flutter run
```

4. iOS ke liye:
```bash
cd ios
pod install
cd ..
flutter run
```

## Project Structure

```
virtual_glasses_tryon/
├── lib/
│   ├── main.dart                          # Entry point
│   ├── models/
│   │   └── glasses_model.dart             # Glasses data model
│   ├── providers/
│   │   └── glasses_provider.dart          # State management
│   ├── screens/
│   │   └── home_screen.dart               # Main camera screen
│   ├── services/
│   │   └── face_detector_service.dart     # Face detection logic
│   └── widgets/
│       └── glasses_overlay_painter.dart   # Glasses rendering
├── assets/
│   └── glasses/                           # Glasses images
├── android/                               # Android-specific files
├── ios/                                   # iOS-specific files
└── pubspec.yaml                           # Dependencies

```

## How to Use

1. **App Launch karein**: App khulte hi camera permission allow karein
2. **Face Detection**: Apna chehra camera ke saamne rakhein, app automatically detect karega
3. **Glasses Select karein**: "Select Glasses" button par tap karke different glasses choose karein
4. **Try On**: Glasses real-time mein apke face par show honge
5. **Photo Capture**: Camera button se apni photo capture karein
6. **Toggle Visibility**: Top-right icon se glasses ko hide/show kar sakte hain

## Permissions Required

### Android
- `CAMERA`: Camera access ke liye
- `WRITE_EXTERNAL_STORAGE`: Photos save karne ke liye
- `READ_EXTERNAL_STORAGE`: Photos read karne ke liye

### iOS
- `NSCameraUsageDescription`: Camera access
- `NSPhotoLibraryUsageDescription`: Photo library access
- `NSPhotoLibraryAddUsageDescription`: Photos save karne ke liye

## Customization

### Naye Glasses Add Karna

`lib/models/glasses_model.dart` file mein naye glasses add kar sakte hain:

```dart
GlassesModel(
  id: '7',
  name: 'Your Glasses Name',
  imagePath: 'assets/glasses/your_image.png',
  color: 'Color Name',
  price: 99.99,
),
```

### Glasses Overlay Customize Karna

`lib/widgets/glasses_overlay_painter.dart` file mein `_drawGlasses` method edit karke glasses ka appearance change kar sakte hain.

## Troubleshooting

### Camera Initialize Nahi Ho Raha
- Device mein camera hai ya nahi check karein
- Permissions properly di gayi hain ya nahi verify karein
- Physical device use karein (emulator mein camera support limited hai)

### Face Detection Kaam Nahi Kar Raha
- Proper lighting ensure karein
- Face camera ke saamne clearly visible hona chahiye
- Google ML Kit dependencies properly install hain ya nahi check karein

### Build Errors
```bash
flutter clean
flutter pub get
flutter run
```

## Future Enhancements

- [ ] Custom glasses upload karne ki facility
- [ ] AR-based 3D glasses rendering
- [ ] Social media sharing
- [ ] Virtual try-on history
- [ ] AI-based glasses recommendations
- [ ] Multiple face support (group photos)

## Contributing

Contributions welcome hain! Please feel free to submit pull requests.

## License

This project is open source and available under the MIT License.

## Contact

Questions ya suggestions ke liye issue create karein.
