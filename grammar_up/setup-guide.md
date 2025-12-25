# Hướng dẫn setup cho Android & Chrome

Hướng dẫn đầy đủ để setup  cho app Flutter Grammar Up trên **Android** và **Chrome**.

---

1. Download file google-services.json (hỏi bình), sau đó dán vào đường dẫn: grammar_up/android/app
2. Tự tạo một file là api_keys.dart với cấu trúc mẫu đã có, sau đó vào file ai_chat_tab.dart và chỉnh sửa:
```
@override
  void initState() {
    super.initState();
    // Initialize OpenAI
    OpenAI.apiKey = ApiKeys.openAiApiKey; //chỉnh sửa đoạn code cho giống như thế này
    // Add system message for grammar assistant
    ....
  }

```
3. Nếu gặp lỗi kiểu như này:
[{
	"resource": "/E:/DO_AN_MOBILE_NEW/grammar_up/android/",
	"owner": "_generated_diagnostic_collection_name_#7",
	"code": "0",
	"severity": 8,
	"message": "The supplied phased action failed with an exception.\r\nCould not create task ':google_sign_in_android:compileDebugUnitTestSources'.\r\nthis and base files have different roots: E:\\DO_AN_MOBILE_NEW\\grammar_up\\build\\google_sign_in_android and C:\\Users\\HP\\AppData\\Local\\Pub\\Cache\\hosted\\pub.dev\\google_sign_in_android-6.2.1\\android.",
	"source": "Java",
	"startLineNumber": 1,
	"startColumn": 1,
	"endLineNumber": 1,
	"endColumn": 1,
	"origin": "extHost1"
}]

Thấy báo lỗi này trong project mà file nó không hiển thị/không tìm thấy chính xác file bị lỗi/báo là file ẩn thì project vẫn sẽ compile được bình thường.
Tương tự cho các lỗi khác có thông báo ở terminal nhưng mà không hiển thị ở code base.

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

