---
name: mobile-app
description: |
  Mobile app development guide for cross-platform apps.
  Covers React Native, Flutter, and Expo frameworks.

  Triggers: mobile app, React Native, Flutter, Expo, iOS, Android, 모바일 앱, モバイルアプリ, 移动应用
agent: pipeline-guide
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - WebSearch
user-invocable: false
---

# Mobile App Development Expertise

## Overview

Guide for developing mobile apps based on web development experience.
Develop for iOS and Android simultaneously using cross-platform frameworks.

## Framework Selection Guide

| Framework | Recommended For | Advantages | Disadvantages |
|-----------|----------------|------------|---------------|
| **Expo (React Native)** | Web developers | Leverage React knowledge | Native module limitations |
| **React Native CLI** | Complex apps | Full native access | Complex setup |
| **Flutter** | High-performance UI | Fast rendering | Need to learn Dart |

### Level-wise Recommendations

```
Starter → Expo (React Native)
Dynamic → Expo + EAS Build
Enterprise → React Native CLI or Flutter
```

## Expo (React Native) Guide

### Project Creation

```bash
npm install -g expo-cli
npx create-expo-app my-app
cd my-app && npx expo start
```

### Folder Structure

```
my-app/
├── app/                    # Expo Router pages
│   ├── (tabs)/            # Tab navigation
│   │   ├── index.tsx      # Home tab
│   │   └── _layout.tsx    # Tab layout
│   └── _layout.tsx        # Root layout
├── components/            # Reusable components
├── hooks/                 # Custom hooks
└── assets/               # Images, fonts
```

### Navigation Patterns

```typescript
// app/_layout.tsx - Stack navigation
import { Stack } from 'expo-router';

export default function RootLayout() {
  return (
    <Stack>
      <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
      <Stack.Screen name="modal" options={{ presentation: 'modal' }} />
    </Stack>
  );
}
```

```typescript
// app/(tabs)/_layout.tsx - Tab navigation
import { Tabs } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';

export default function TabLayout() {
  return (
    <Tabs>
      <Tabs.Screen
        name="index"
        options={{
          title: 'Home',
          tabBarIcon: ({ color }) => <Ionicons name="home" color={color} size={24} />,
        }}
      />
    </Tabs>
  );
}
```

### Styling Patterns

```typescript
// NativeWind (Tailwind for RN) - Recommended
import { View, Text } from 'react-native';

export function MyComponent() {
  return (
    <View className="flex-1 p-4 bg-white">
      <Text className="text-2xl font-bold">Hello</Text>
    </View>
  );
}
```

### Authentication Pattern

```typescript
// context/AuthContext.tsx
import * as SecureStore from 'expo-secure-store';

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);

  const signIn = async (email: string, password: string) => {
    const response = await fetch('/api/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
    const { token, user } = await response.json();
    await SecureStore.setItemAsync('authToken', token);
    setUser(user);
  };

  const signOut = async () => {
    await SecureStore.deleteItemAsync('authToken');
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, signIn, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}
```

## Flutter Guide

### Project Creation

```bash
flutter create my_app && cd my_app && flutter run
```

### Folder Structure

```
my_app/
├── lib/
│   ├── main.dart
│   ├── features/           # Feature-based folders
│   │   ├── auth/screens/
│   │   └── home/
│   ├── shared/widgets/
│   └── core/theme/
└── pubspec.yaml
```

### State Management (Riverpod)

```dart
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);
  void increment() => state++;
}

// Usage
class CounterScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Text('Count: $count');
  }
}
```

## Web vs Mobile Differences

| Element | Web | Mobile |
|---------|-----|--------|
| Click | onClick | onPress |
| Scroll | overflow: scroll | ScrollView / FlatList |
| Input | input | TextInput |
| Storage | localStorage | AsyncStorage, SecureStore |
| Navigation | URL-based | Stack-based |

## Build & Deployment

### Expo EAS Build

```bash
npm install -g eas-cli
eas login
eas build:configure
eas build --platform ios
eas build --platform android
eas submit --platform ios
```

### Environment Variables

```json
// app.json
{
  "expo": {
    "extra": { "apiUrl": "https://api.example.com" }
  }
}
```

```typescript
import Constants from 'expo-constants';
const apiUrl = Constants.expoConfig?.extra?.apiUrl;
```

## Mobile PDCA Checklist

### Phase 1: Schema
- [ ] Identify data that needs offline caching
- [ ] Define sync conflict resolution strategy

### Phase 3: Mockup
- [ ] Follow iOS/Android native UX guidelines
- [ ] Consider gestures (swipe, pinch, etc.)
- [ ] Layout for different screen sizes

### Phase 6: UI
- [ ] Keyboard handling (screen adjustment)
- [ ] Safe Area handling (notch, home button)
- [ ] Handle platform-specific UI differences

### Phase 7: Security
- [ ] Store sensitive info with SecureStore
- [ ] Certificate Pinning (if needed)
- [ ] App obfuscation settings

### Phase 9: Deployment
- [ ] Follow App Store review guidelines
- [ ] Prepare Privacy Policy URL
- [ ] Prepare screenshots, app description

## FAQs

**Q: Can I convert a web project to an app?**
Recommend separate project - APIs can be shared, UI needs rewriting.

**Q: Should I use Expo or React Native CLI?**
Start with Expo! 90%+ of apps are sufficient. Can eject later if needed.

**Q: How long does app review take?**
iOS: 1-7 days, Android: Few hours ~ 3 days.
