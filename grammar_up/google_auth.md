# Google Sign In - Hướng dẫn setup cho Android & Chrome

Hướng dẫn đầy đủ để setup Google Sign In cho app Flutter Grammar Up trên **Android** và **Chrome**.

---

## 🚀 Quick Start (Chrome only - 5 phút)

Nếu chỉ test trên Chrome (không cần Android):

1. **Tạo Firebase Project** (https://console.firebase.google.com/)
   - Add Web app
   - Copy Web Client ID

2. **Enable Supabase Google Provider** (https://supabase.com/dashboard)
   - Authentication → Providers → Google → Enable
   - Nhập Client ID + Secret

3. **Tạo file `.env`:**
   ```bash
   Copy-Item .env.example .env
   # Mở .env và điền GOOGLE_WEB_CLIENT_ID
   ```

4. **Update `web/index.html`:**
   - Dòng 36: Thay `YOUR_WEB_CLIENT_ID` bằng Web Client ID thật

5. **Run:**
   ```bash
   flutter pub get
   flutter run -d chrome
   ```

**Done! 🎉** Google Sign In sẽ hoạt động trên Chrome.

---

## 📋 Setup đầy đủ (Android + Chrome)

Để Google Sign In hoạt động trên cả Android và Chrome, bạn cần:

1. **Firebase Project** - Quản lý OAuth credentials
2. **Google Cloud Console** - Cấu hình OAuth Web Client
3. **Supabase Dashboard** - Kích hoạt Google Provider
4. **Local Config** - File `.env` và `google-services.json`
5. **SHA-1 Certificate** - Cho Android debugging

**Thời gian:** ~10 phút

---

## ⚙️ Bước 1: Firebase Console

### 1.1. Tạo Firebase Project

1. Truy cập: https://console.firebase.google.com/
2. Click **"Add project"**
3. Nhập tên: **"Grammar Up"**
4. Disable Google Analytics (không cần thiết)
5. Click **"Create project"**

### 1.2. Thêm Android App

1. Trong Firebase project, click **"Add app"** → chọn **Android**
2. Nhập thông tin:
   - **Android package name:** `com.example.grammar_up`
   - **App nickname:** Grammar Up Android
   - **Debug signing certificate SHA-1:** (để trống, sẽ thêm sau)
3. Click **"Register app"**
4. **Download `google-services.json`**
5. Copy file vào: `android/app/google-services.json`
6. Click **"Next"** → **"Continue to console"**

### 1.3. Thêm Web App

1. Trong Firebase project, click **"Add app"** → chọn **Web**
2. Nhập:
   - **App nickname:** Grammar Up Web
3. Click **"Register app"**
4. **Lưu lại Firebase config** (sẽ dùng sau)
5. Click **"Continue to console"**

### 1.4. Lấy Web Client ID

1. Trong Firebase Console, vào **"Project Settings"**
2. Scroll xuống phần **"Your apps"**
3. Click vào **Web app** vừa tạo
4. Copy **"Web Client ID"** (dạng `xxx.apps.googleusercontent.com`)
5. **Lưu lại để dùng ở bước 4**

---

---

## 🔐 Bước 2: Google Cloud Console

### 2.1. Enable Google People API

1. Truy cập: https://console.cloud.google.com/
2. **Chọn project Firebase:**
   - Nhìn lên góc trên cùng bên trái (cạnh chữ "Google Cloud")
   - Click vào dropdown (có tên project hiện tại hoặc "Select a project")
   - Tìm và chọn project **"Grammar Up"** vừa tạo trong Firebase
   - Đợi page load xong
3. Vào **"APIs & Services"** → **"Library"**
4. Search: **"People API"** hoặc **"Google People API"**
5. Click vào **"Google People API"**
6. Click nút **"Enable"**
7. Đợi 1-2 phút để API được kích hoạt

### 2.2. Cấu hình OAuth Consent Screen

1. Vào **"APIs & Services"** → **"OAuth consent screen"**
2. Chọn **"External"** (cho phép bất kỳ ai đăng nhập) → Click **"Create"**
3. Nhập thông tin bắt buộc:
   - **App name:** Grammar Up
   - **User support email:** [chọn email của bạn từ dropdown]
   - **Developer contact information:** [nhập email của bạn]
4. Click **"Save and Continue"**
5. **Scopes:** Không cần thêm gì, click **"Save and Continue"**
6. **Test users:** Không cần thêm, click **"Save and Continue"**
7. **Summary:** Review và click **"Back to Dashboard"**

### 2.3. Cấu hình Web OAuth Client

**Kiểm tra xem đã có OAuth Client chưa:**

1. Vào **"APIs & Services"** → **"Credentials"**
2. Nhìn vào section **"OAuth 2.0 Client IDs"**
3. Nếu thấy **"No OAuth clients to display"** → Làm theo **Cách A** (tạo mới)
4. Nếu đã có **"Web client (auto created by Google Service)"** → Làm theo **Cách B** (edit)

---

**Cách A: Tạo OAuth Client mới (nếu chưa có)**

1. Click nút **"+ Create credentials"** ở trên → Chọn **"OAuth client ID"**
2. Chọn **Application type:** **Web application**
3. Nhập **Name:** `Grammar Up Web Client`
4. Thêm vào **"Authorized JavaScript origins"** (click "Add URI"):
   ```
   http://localhost
   http://localhost:7357
   http://localhost:52044
   ```
5. Thêm vào **"Authorized redirect URIs"** (click "Add URI"):
   ```
   https://[YOUR_SUPABASE_PROJECT_ID].supabase.co/auth/v1/callback
   ```
   *(Thay `[YOUR_SUPABASE_PROJECT_ID]` bằng project ID thật của Supabase)*
   
6. Click **"Create"**
7. **QUAN TRỌNG:** Popup hiện ra, copy **Client ID** và **Client secret** → Lưu lại để dùng ở Bước 3
8. Click **"OK"**

---

**Cách B: Edit OAuth Client có sẵn**

1. Trong **"OAuth 2.0 Client IDs"**, tìm **"Web client (auto created by Google Service)"**
2. Click vào tên để edit
3. Thêm vào **"Authorized JavaScript origins":**
   ```
   http://localhost
   http://localhost:7357
   http://localhost:52044
   ```
4. Thêm vào **"Authorized redirect URIs":**
   ```
   https://[YOUR_SUPABASE_PROJECT_ID].supabase.co/auth/v1/callback
   ```
5. Click **"Save"**
6. Click vào tên Client lần nữa để xem **Client ID** và **Client secret**

---

## 🗄️ Bước 3: Supabase Dashboard

1. Truy cập: https://supabase.com/dashboard
2. Chọn project **Grammar Up**
3. Vào **"Authentication"** → **"Providers"**
4. Tìm **"Google"** → Click **"Enable"**
5. Nhập thông tin:
   - **Client ID:** [Web Client ID từ bước 1.4]
   - **Client Secret:** [Lấy từ Google Cloud Console → Credentials]
6. Click **"Save"**

---

## 📝 Bước 4: Cấu hình Local Project

### 4.1. Tạo file `.env`

1. Copy file template:
   ```powershell
   Copy-Item .env.example .env
   ```

2. Mở file `.env` và điền thông tin:
   ```env
   SUPABASE_URL=https://[YOUR_PROJECT_ID].supabase.co
   SUPABASE_ANON_KEY=[YOUR_ANON_KEY]
   GOOGLE_WEB_CLIENT_ID=[YOUR_WEB_CLIENT_ID].apps.googleusercontent.com
   ```

**Lấy thông tin từ đâu?**
- **SUPABASE_URL & ANON_KEY:** Supabase Dashboard → Project Settings → API
- **GOOGLE_WEB_CLIENT_ID:** Từ bước 1.4 (Firebase Web Client ID)

### 4.2. Đặt `google-services.json`

Đảm bảo file đã được copy đúng vị trí:
```
android/app/google-services.json
```

### 4.3. Bật Google Services Plugin

Mở file `android/app/build.gradle.kts` và **uncomment** dòng cuối cùng:

```kotlin
// Tìm dòng này (gần cuối file):
// apply(plugin = "com.google.gms.google-services")

// Uncomment thành:
apply(plugin = "com.google.gms.google-services")
```

**Quan trọng:** CHỈ uncomment SAU KHI đã có file `google-services.json`!

### 4.4. Cập nhật Web Client ID trong `web/index.html`

Mở `web/index.html` (dòng ~36) và thay `YOUR_WEB_CLIENT_ID`:

```html
<!-- Tìm dòng này: -->
<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">

<!-- Thay thành: -->
<meta name="google-signin-client_id" content="123456789-abc123xyz.apps.googleusercontent.com">
```

**Lưu ý:** Dùng Web Client ID từ bước 1.4, KHÔNG phải Android Client ID!

---

## 🔑 Bước 5: Lấy SHA-1 Certificate (cho Android)

### 5.1. Extract SHA-1 từ Debug Keystore

Chạy command sau trong PowerShell:

```powershell
cd android
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**Nếu keytool không tìm thấy, thử path này:**
```powershell
& "C:\Program Files\Java\jdk-XX\bin\keytool.exe" -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

### 5.2. Copy SHA-1

Trong output, tìm dòng:
```
SHA-1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
```

Copy toàn bộ chuỗi SHA-1.

### 5.3. Thêm SHA-1 vào Firebase

1. Vào Firebase Console → Project Settings
2. Scroll xuống phần **"Your apps"** → Chọn **Android app**
3. Click **"Add fingerprint"**
4. Paste SHA-1 vừa copy
5. Click **"Save"**

---

## ✅ Kiểm tra cấu hình

Chạy script kiểm tra:

```powershell
.\check_google_signin.ps1
```

Script sẽ check:
- ✓ File `.env` có đầy đủ keys
- ✓ File `google-services.json` tồn tại
- ✓ SHA-1 certificate (hướng dẫn extract)
- ✓ Flutter packages đã cài

---

## 🧪 Test Google Sign In

### 🌐 Test trên Chrome (Đơn giản - Khuyến nghị cho development)

**Requirements:**
- ✅ File `.env` với `GOOGLE_WEB_CLIENT_ID`
- ✅ Supabase Google Provider enabled
- ✅ `web/index.html` đã update Client ID

**Chạy:**
```powershell
flutter run -d chrome
```

**Hoặc dùng menu:**
```powershell
.\test.ps1
# Chọn option 1: Run on Chrome
```

**Ưu điểm:**
- ⚡ Nhanh, không cần Android device
- 🔄 Hot reload nhanh
- 🐛 Dễ debug với Chrome DevTools

---

### 📱 Test trên Android (Đầy đủ - Cho production testing)

**Requirements (thêm vào):**
- ✅ Firebase Android app đã setup
- ✅ `android/app/google-services.json` đã có
- ✅ SHA-1 certificate đã thêm vào Firebase
- ✅ Google Services plugin đã uncomment

**Chạy qua Flutter CLI:**
```powershell
flutter run
# Hoặc: .\test.ps1 → option 2
```

**Hoặc qua Android Studio:**
1. Mở Android Studio
2. File → Open → Chọn folder `android`
3. Đợi Gradle sync xong (~2-5 phút lần đầu)
4. Connect device/emulator
5. Click nút **"Run"** (▶️) hoặc Shift+F10

**Lưu ý:**
- 🕐 Lần build đầu tiên sẽ lâu (5-10 phút)
- 📱 Cần device thật hoặc emulator có Google Play Services
- ⏰ Sau khi thêm SHA-1, đợi 5-10 phút để Firebase sync

---

## 🐛 Troubleshooting

### Lỗi: "API Key not valid"

**Nguyên nhân:** SHA-1 chưa được thêm vào Firebase hoặc chưa đợi đủ lâu.

**Giải pháp:**
1. Kiểm tra SHA-1 đã add vào Firebase chưa (bước 5.3)
2. Đợi 5-10 phút để Firebase cập nhật
3. Clean build: `flutter clean && flutter pub get`

### Lỗi: "Sign in failed" trên Web

**Nguyên nhân:** `http://localhost` chưa được thêm vào Authorized Origins.

**Giải pháp:**
1. Vào Google Cloud Console → Credentials
2. Check "Authorized JavaScript origins" có `http://localhost` chưa
3. Thêm thêm: `http://localhost:7357` và `http://localhost:52044`

### Lỗi: "PlatformException: sign_in_failed" trên Android

**Nguyên nhân:** Google Services không được cấu hình đúng hoặc SHA-1 chưa thêm vào Firebase.

**Giải pháp:**
1. **Kiểm tra SHA-1:** Đảm bảo đã thêm SHA-1 vào Firebase (bước 5.3)
2. **Kiểm tra package name:** Mở `android/app/google-services.json`, tìm `"package_name"`, phải là `com.example.grammar_up`
3. **Kiểm tra plugin:** Uncomment `apply(plugin = "com.google.gms.google-services")` trong `android/app/build.gradle.kts`
4. **Clean build:**
   ```powershell
   cd android
   .\gradlew clean
   cd ..
   flutter clean
   flutter pub get
   ```
5. **Đợi Firebase sync:** Sau khi thêm SHA-1, đợi 5-10 phút rồi thử lại

### Lỗi: "Error while Sign in: null"

**Nguyên nhân:** Supabase chưa được cấu hình Google Provider.

**Giải pháp:**
1. Vào Supabase Dashboard → Authentication → Providers
2. Enable Google và nhập Client ID + Secret
3. Kiểm tra Redirect URL có đúng không

---

## 📚 Tóm tắt các file đã thay đổi

### Files cần tạo/cấu hình:
- ✅ `.env` - Environment variables (tạo từ `.env.example`)
- ✅ `android/app/google-services.json` - Firebase Android config
- ✅ `android/app/build.gradle.kts` - Uncomment Google Services plugin
- ✅ `web/index.html` - Thay Web Client ID

### Files hỗ trợ:
- 📄 `check_google_signin.ps1` - Script kiểm tra config
- 📄 `test.ps1` - Menu test nhanh

---

## 🎯 Checklist cuối cùng

### Cho Chrome/Web Testing:
- [ ] File `.env` đã tạo với `GOOGLE_WEB_CLIENT_ID`
- [ ] Google OAuth Client có `http://localhost` trong Authorized Origins
- [ ] Supabase đã enable Google Provider
- [ ] Web Client ID đã update trong `web/index.html`
- [ ] `flutter pub get` đã chạy

### Thêm cho Android Testing:
- [ ] Firebase project đã tạo và thêm Android app
- [ ] `google-services.json` đã download và đặt ở `android/app/`
- [ ] SHA-1 đã add vào Firebase Console (bước 5.3)
- [ ] Uncomment `apply(plugin = "com.google.gms.google-services")` trong `android/app/build.gradle.kts`
- [ ] `flutter clean && flutter pub get` đã chạy
- [ ] Đợi 5-10 phút sau khi thêm SHA-1 (để Firebase sync)

### Kiểm tra nhanh:
```powershell
# Check .env có keys chưa
Get-Content .env

# Check google-services.json có chưa (cho Android)
Test-Path android/app/google-services.json

# Clean và get packages
flutter clean
flutter pub get
```

**Done!** 🎉 Giờ có thể test Google Sign In trên Chrome (đơn giản) và Android (đầy đủ).
