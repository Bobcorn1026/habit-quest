# 勇者日課（habit_quest）

受《原子習慣》啟發的 iOS 習慣養成 app：把想養成或想戒掉的習慣，由 AI 包裝成中世紀劍與魔法的 RPG 任務。每週完成的量與品質會推進 TRPG 式的故事（每週一章、章末抉擇），角色也會升級、提升公會 Rank、轉職。

城鎮裡有修練場（專注計時）、銀行（把真實的零用錢分成信封，可與 Notion 記帳本雙向同步）和賭場（用金幣抽籤）。

以 Flutter 寫成，只支援 iOS（iPhone 為主，iPad 也能跑），介面只有繁體中文。

## 建置

需要 Flutter 3.47 以上與 Xcode。

```bash
flutter pub get
flutter test
flutter build ios --simulator --debug   # → build/ios/iphonesimulator/Runner.app
```

### 本機設定（不在 git 裡，都可省略）

- `assets/local/profile.json`：自己的預設值（銀行每月收入、餐費、固定支出、示範角色名稱）。格式見 `docs/local_profile.example.json`；沒有這個檔就用程式裡的通用值
- `ios/Flutter/Team.xcconfig`：簽章用的 Apple 開發者 Team ID。從 `ios/Flutter/Team.xcconfig.example` 複製一份再填；只在模擬器跑可以不用
- AI 與 Notion 的金鑰在 app 的設定頁輸入，存在 iOS 鑰匙圈，不會進備份或 git

### Notion 記帳本

連動時，app 會在分享給整合的頁面裡，找標題剛好是「收支紀錄」的資料庫，並透過它的「預算項目」關聯欄位找到預算表。欄位名稱見 `lib/notion/ledger.dart` 的 `LedgerProps`。

## 文件

- `docs/features.md`：做完的功能與規則
- `docs/architecture.md`：各子系統的設計與要注意的地方
