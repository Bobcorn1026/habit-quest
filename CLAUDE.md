# habit_quest（勇者日課）

通用規則見上層 `~/Developer/CLAUDE.md`（開發迴圈、何時發問、git 規則）。這份只記這個 app 自己的事。
完整設計與里程碑：`~/.claude/plans/app-ai-rpg-ai-trpg-starry-falcon.md`。
「城鎮」（修練場／銀行／賭場／Notion 連動，2026-11-16 使用者核准）的設計與所有已確認的決定：`~/.claude/plans/habit-quest-town.md`。
接手工作先讀 `HANDOFF.md`（現在做到哪、下一步；新對話用 `/pickup habit_quest`）。進度只寫在 HANDOFF.md，這份只放穩定的決定。
細節文件（需要時才讀）：`docs/features.md`（做完的功能與規則）、`docs/architecture.md`（各子系統的設計與坑，改到那一塊前先讀那一段）。

## 目標

- 受《原子習慣》啟發的習慣養成 app：把想養成／想戒掉的習慣，由 AI 包裝成中世紀劍與魔法 RPG 任務
- 依每週完成的量與品質推進 TRPG 式故事（每週一章、章末抉擇）、提升等級、公會 Rank、職業與能力值
- 「太簡單偵測」已在 2026-11-07 依使用者要求取消，只保留晉階邀請（超越目標、封印穩固）
- 先給自己用，之後可能上架並推出付費方案
- **只做手機 app（iOS）**：使用者 2026-11-04 決定不做 Mac 版，`macos/` 已刪除（要找回可從 git 歷史）

## 功能

做完的功能與細節在 `docs/features.md`（新功能做完要在那裡打勾）。
- **新功能要在 `lib/ui/widgets/mentor_tips.dart` 加一則莉娜的介紹**，並在功能第一次出現的地方呼叫 `showMentorTip`
- 還沒做：提醒打磨、備份打磨；（上架前）付費代生成
- 使用者決定不做：太簡單偵測（11/07 取消）、負傷時的兩分鐘迷你版、多語言、Mac 版

## 技術決定

- 平台：iOS（Flutter），以 iPhone 為主；iPad 也能跑（內容欄寬上限 560）
- Bundle ID：`com.satori.habit_quest`
- **Repo 公開在 GitHub（`habit-quest`）**：不要 commit 私人資訊（Notion id、Apple Team ID、真實金額、Gmail、`/Users/...` 路徑）。使用者自己的預設值放 `assets/local/profile.json`（不進 git，`LocalProfile` 啟動時讀，範例 `docs/local_profile.example.json`）；Team ID 在 `ios/Flutter/Team.xcconfig`（不進 git）。程式與測試只用通用值（示範角色「亞倫」）
- 狀態管理：Riverpod（不用 codegen）；時間透過 `Clock` 注入，測試可固定時間
- 資料：drift（SQLite），只存本機；API key 存 Keychain（`flutter_secure_storage`）
- 一天從凌晨 4 點開始算（`GameRules.dayStartHour`）
- 所有遊戲數值集中在 `GameRules`、故事設定在 `StoryConfig`，不要寫死在畫面裡
- AI：三種模式共用同一套 prompt／schema／parser；Claude 預設 `claude-opus-5-5`，`anthropic-version: 2026-10-21`，開啟 `fallbacks: "default"`
- 只做繁體中文：使用者 2026-11-07 決定不做多語言（上架成本太高）。gen-l10n 還在但只有 app 名稱，UI 文字直接寫在程式裡
- 要跟著看板持續跑的副作用（晉階邀請、提醒排程）放在 `AppEffects`（包在 app 最外層）。Riverpod 3 會暫停被蓋住的頁面上的 listener，所以不要放在畫面裡
- 莉娜的提示在測試裡預設全部標成已看過（`AppHarness.showTips`），要測提示時設成 true
- Riverpod 3 會暫停沒人聽的 provider：在設定頁等地方要讀看板資料，用 `listenManual` 撐住（見 `loadRecord`）
- 底部表單一律用 `showPixelSheet`：它會避開狀態列（`useSafeArea`），內容包在 `SingleChildScrollView` 裡，所以鍵盤彈出時會捲動而不是溢位。表單內容不要用 `Expanded`／`Spacer` 撐高度。`test/ui/sheet_keyboard_test.dart` 用 iPhone 12 Pro 尺寸＋鍵盤驗證
- 數值的選項不要只給固定幾顆按鈕：整數範圍用 `PixelStepper`、時間／日期用 `pickTime`／`pickDay`（`widgets/pixel_pickers.dart`）。習慣頻率是「每週 N 次」（1–7，`timesPerWeek`），**沒有固定星期幾**（使用者 2026-11-19 決定）；`isDaily` ＝ 7 次
- Cubic 11 的數字不等寬（1 和冒號較窄），會跑動的數字（碼表、倒數）要加 `FontFeature.tabularFigures()`，大字級用 `crispFontSize(dpr, 目標)` 取清晰的大小
- 休息日以 `restDays` 參數傳進純函式（streak、period stats、guild、planReminders），不要在純函式裡讀 provider
- 金幣的寫入方式：一次性獎勵用 `EconomyRepository.reward()`；可重複的花費用 `spend()`（負數 gold event，每個 source/ref 一次、不透支）；會一直變的累計（例如當天的專注金幣）用 `setEvent()`（每個 source/ref 一列，沒變回 false 不寫入）
- 改 schema：**只新增表、不改既有表**（手機上有真實資料）；新表加進 `BackupService.tableOrder`（有測試擋）、在 `test/data/migration_test.dart` 的降版 `setup` 補 `DROP TABLE`／`DROP INDEX`，再加一個從上一版升級的測試；要處理舊版備份。各版 schema 的內容見 `docs/architecture.md`「資料與 schema」
- 金幣：**所有**收入與花費都過 `inflate(base, 本週物價)`，只有商店造型道具（`kShopItems`）不漲；細節見 `docs/architecture.md`「金幣與通膨」
- 腳本產生的檔案不要手改：人物立繪、建築圖、圖示（`docs/icon_candidates/*.py`）、音效（`docs/sfx/sfx.py`）。畫新圖或改像素 UI 前先讀 `docs/architecture.md`「美術」
- 畫面有 `MentorBox`（莉娜待機動畫，Ticker 不會停）的測試不能用 `pumpAndSettle`
- 改修練場／城鎮前先讀 `docs/architecture.md`「城鎮（修練場）」（計時器、週結算、音效的設計與坑）；改銀行前讀「城鎮（銀行）」、改賭場前讀「城鎮（賭場）」
- 銀行是新台幣整數，跟金幣無關、**不過 `inflate`**；銀行的寫入一律經 `BankService`（冪等靠 `bank_txns.ref`），不要直接寫表（例外：`NotionSync` 直接寫 Notion 來的列）
- 改銀行或 Notion 同步前讀 `docs/architecture.md`「Notion 連動（M4）」：新的自動搬錢一定要帶 `ref`，不然會被當成手記的帳推到 Notion

## 常用指令

```bash
flutter analyze && flutter test
dart run build_runner build               # 改了 drift 資料表後要跑
flutter build ios --simulator --debug     # → build/ios/iphonesimulator/Runner.app
# 模擬器的資料庫（改之前先 terminate；每次 launch 重裝後容器路徑會變，要重新取）
xcrun simctl terminate booted com.satori.habitQuest
sqlite3 "$(xcrun simctl get_app_container booted com.satori.habitQuest data)/Documents/habit_quest.sqlite"
```

## 已知問題 / 待辦

- 真正的 Claude／OpenAI API 呼叫還沒用真的 key 測過（只有 MockClient 測試）
- iOS 上按「從剪貼簿貼上」會跳系統的「允許貼上」詢問；模擬器要先 `xcrun simctl privacy booted grant pasteboard com.satori.habitQuest`
- `xcrun simctl pbcopy` 要加 `LC_ALL=en_US.UTF-8`，不然中文會變亂碼
- 模擬器的 `text` 自動輸入很不穩，onboarding 流程靠 widget test 驗證
- widget test 裡關 drift 資料庫不能放在 `runAsync` 裡（會卡死），見 `test/support/app_harness.dart`
- 畫面已經在監聽資料庫時，不要在一個 `runAsync` 裡連續做好幾次讀寫（drift 會鎖住、測試卡死）；把資料準備都放在第一次 `pump` 之前
- 用 python/sed 改檔前先確認字串還在：`dart format` 會改換行，替換會悄悄失效
- 測試裡開新頁面後要多 pump 一下（約 1 秒）讓轉場跑完，不然底下的頁面還沒被蓋住，測不出「暫停 listener」這類問題
- **裝到使用者的 iPhone**：使用者用「自動續簽」（`apps/auto_resign`）裝。改完程式請使用者在它的視窗對勇者日課選「從原始碼重新建置並安裝」（覆蓋安裝，資料會留著），它也會在 7 天到期前自動續簽。Claude 自己跑 `flutter build ios --release` 會失敗（指令沙盒讀不到 Xcode 帳號，顯示「No Accounts」），不要去讀鑰匙圈繞過
- debug 版可以快轉時間：設定頁「開發」區的 ＋1 天／＋1 週／回到現在（`AdjustableClock`，偏移只在記憶體裡，重開 app 就回到現在）。快轉時寫下的東西（結算、罰金、下週的列）回到現在也不會復原，要乾淨就重新載入示範資料。要看任意某一天，還是可以直接改模擬器的資料庫（指令見上面「常用指令」），例如旅店預約是 `purchases` 表的 `item_id='inn:YYYY-MM-DD'`
- 模擬器自動點擊：頁面還在慣性捲動時，第一下點擊只會讓它停下；表單有開啟動畫，連點會點錯地方；莉娜對話框的「跳過 »」只會跳到最後一句，要再點一下才會關
- 委派 implementer 時要寫明 repo 路徑 `~/Developer/apps/habit_quest`（在 `~/Developer` 跑 git 會說「不是 repo」）
- 手機上是真實資料（schema 5 起）：遷移只新增資料表，不改既有表；不要叫使用者重裝（會清掉資料），安裝新版前請他先匯出備份
- `gold_events` 沒有 UNIQUE 索引，「只發一次」靠 `EconomyRepository.reward()` 在交易裡先查；真實資料可能有重複，所以**不要在遷移裡補 UNIQUE 索引**。`purchases` 的主鍵是 itemId，不能拿來記可重複的花費（用負數的 `gold_events`）
- 示範資料（`seedDemo`／測試的 `h.seed()`）的冒險者是 **D 級，物價 ×1.5**：用它的測試與 golden 裡金額都是通膨後的（旅店 75、完美的一天 15）。「載入示範資料」按鈕包在一個 transaction 裡，監聽資料庫的東西才不會先看到 F 級
- `boardProvider` 監聽 `goldProvider`：每寫一次金幣，`AppEffects` 就會重跑 `syncOffers`／`settleCurses`。會頻繁變動的金幣（例如計時中的收益）只在整數變了才寫
- iOS 外掛目前走 Swift Package Manager（沒有 `ios/Podfile`）：加套件後 build 一次，如果冒出 Podfile，上手機前先確認「自動續簽」還能建置
- iOS 的「減少動態效果」只設 `accessibilityFeatures.reduceMotion`、不設 `MediaQuery.disableAnimations`：賭場用 `reduceMotion(context)`（`lib/ui/widgets/casino_fx.dart`），其他畫面（莉娜待機、領餐費輪盤、慶祝）還只看 disableAnimations
- 包在遊戲外面的特效 widget 不能依狀態換掉 widget 型別（例如有時回傳 child、有時回傳 Transform）：裡面遊戲的 State 會被重建
- 通知 id：每日提醒 1–30，其他單次通知用 `scheduleOnce` 且 id > 30（細節見 `docs/architecture.md`「遊戲系統」）
