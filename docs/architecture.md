# habit_quest 架構筆記

從 `CLAUDE.md` 搬出來的子系統細節（2026-11-17），每個對話都會載入 CLAUDE.md，這裡只在改到那一塊時讀。
穩定的規則與常踩的坑仍在 `CLAUDE.md`；新的子系統細節寫在這裡對應的段落。

## 美術

- 字型：俐方體11號 Cubic 11（OFL 1.1，`assets/fonts/OFL.txt`），12px 網格；字級要讓 `fontSize × dpr / 12` 為整數才清晰
- 像素美術：1 美術像素 = iPhone 4 實體像素（1.33pt）、iPad 3 實體像素（1.5pt），用 `context.artPixel` 取得，剛好等於內文字的像素大小
- sprite 用 Dart 字元陣列定義、**不放大**：小圖 16×16（`PixelIcons`），大圖另畫 32×32（`PixelArt`、`PixelMonsters`），人物立繪 48×48（`PixelPortraits`、莉娜），整個畫面共用同一個像素格
- 人物立繪（2026-11-08 使用者選的方向：往 GBA 對話立繪的精細度）由腳本產生，**不要手改產出的 Dart 檔**：`docs/icon_candidates/mentor48.py` → `mentor_frames.dart`（莉娜＋動畫畫格），`portraits48.py` → `portrait_art.dart`（5 種職業）。共用同一張臉型（`FACE`），立繪專用色鍵 `F` `z` `c` `C` `W`
- 莉娜待機動畫 `MentorPortrait`：固定 24 秒循環（眨眼、z 飄、打哈欠），Ticker 不會停，畫面有 `MentorBox` 的測試不能用 `pumpAndSettle`；系統減少動態效果時靜止
- 任務的 spriteId 從 `kQuestSpriteIds` 選；封印從 `kMonsterSpriteIds` 選（`guessMonster` 依習慣名稱當備案）
- 木板、羊皮紙等紋理在 `texture.dart` 程序產生，先畫成小圖快取，再用 `FilterQuality.none` 放大（每張卡片一次 draw call）
- 光源固定在左上／上方：卡片陰影往下、sprite 高光在左上；色階的暗部偏紅紫、亮部偏橘黃
- 慶祝畫面的 Q 版角色是唯一放大 2 倍的 sprite（`PixelSpriteView.scale`）
- 圖示／啟動圖由 `docs/icon_candidates/` 的 Python 腳本產生（只用標準函式庫）
- 城鎮的建築圖（32×32 `PixelBuildings`）與分頁圖示（16×16 `kTownIcon`）由 `docs/icon_candidates/buildings32.py` 產生，不要手改 `buildings.dart`；它們不在 `PixelIcons.all`（AI 選任務圖示用的清單）裡

## 資料與 schema

- 備份：`BackupService` 以原始 SQL 值逐表匯出（`tableOrder` 父表在前），還原在一個 transaction 裡先清空再寫入；檔案進出由 `BackupFiles` 介面（`share_plus` + `file_selector`），測試用假的。**新增資料表要記得加進 `tableOrder`**（有測試會擋）；改 schema 時要處理舊版備份
- 資料庫 schema 2（2026-11-07）：adventurers 加職業／頭像／公會 Rank／考驗，habits 加 `cursedOn`，quests 加 `attribute`（舊任務是 null，`ActiveQuest.attribute` 依名稱猜）。`test/data/migration_test.dart` 用一個測試驗證從 schema 1 一路升到最新版：它在 `setup` 裡用原始 SQL 把檔案降回舊版，所以**每新增一張表或索引都要在那裡補 `DROP TABLE`／`DROP INDEX`**，不然 `createTable` 會因為表已存在而失敗
- 資料庫 schema 3（2026-11-07）：check_ins 加 `gold`，新表 `gold_events`（完美的一天、支線獎勵，`source`＋`ref` 只發一次）與 `purchases`；餘額＝打卡金幣＋事件－購買（`EconomyRepository`）
- 資料庫 schema 4：索引 check_ins(day)、check_ins(quest_id)、quests(habit_id, active_until)；schema 5：habits 加 `anchorHabitId`（不設 FK）、`anchorText`
- 資料庫 schema 6（2026-11-17，城鎮 M1）：只新增表——`price_weeks`（每週物價快照）、`focus_weeks`（一週的專注條件與結算）、`focus_sessions`（索引 `focus_sessions_day`）。三張都沒有外鍵，已加進 `BackupService.tableOrder` 與 `migration_test` 的降版 `setup`
- 旅店預約存在 `purchases`，itemId 是 `inn:<日期 key>`（`kInnPrefix`），所以不用新表、備份自動帶上；讀已購買外觀時要濾掉 `inn:`

## 金幣與通膨

- 金幣通膨（2026-11-17 使用者決定）：**所有**金幣收入與花費都乘「本週物價」——`GameRules.prices`（`lib/game/price_level.dart`，F×1…SSS×4）＋`inflate(base, percent)` 四捨五入；物價每週一依當時的公會 Rank 固定，週中升級下週才漲。**只有商店造型道具（`kShopItems`）不漲**。新增任何金幣數值都要過 `inflate`，不要直接用 `ProgressionRules` 裡的原始數字（套用進度見 HANDOFF.md）
- 「本週物價」由 `PriceService.percentFor(day)` 取得：那一週第一次用到時固定在當時的 Rank（寫進 `price_weeks`）；還沒有冒險者時回 100 且不寫入。`priceLevelProvider` 由 `AppEffects` 撐著，除了換日也 watch「冒險者是否存在」——只 watch 自己那張表的 provider 不會因為別張表變了而重算

## 遊戲系統

- 通知：`flutter_local_notifications` + `timezone`；不用重複排程，而是每次看板變動或 app 回到前景就重排未來 30 天的單次通知（`planReminders` 是純函式；iOS 最多 64 則）。第 2 天以後的文字依「幾天沒開 app」改寫
- 成長系統的數值都在 `ProgressionRules`（`lib/game/progression.dart`）；能力值＝基礎 5＋√(該屬性累積 XP × 權重) × 0.5，幸運來自完美的一天
- 詛咒在日子結束後由 `AppEffects` 呼叫 `settleCurses` 結算（結算前會重讀資料列，避免看板延遲造成重複扣分）
- 商店：品項在 `kShopItems`（`lib/game/shop.dart`），裝備存在設定 `equipped`；木紋透過 `BoardWoodScope`（`PlayerLook` 包在 app 外層）影響所有 `PixelBackdrop`
- 加持存在章節的 choices JSON（`StoryChoice.blessing`），生效期間是該章結束後的一段期間（`activeBlessing`）；支線委託存在章節的 statsJson（`sideQuest`），進度由 `activeSideQuest` 從打卡算
- 自動寫章節：`AppEffects` 監聽 `chapterDueProvider`，API 模式時呼叫 `ChapterService.autoWrite`（每章每次啟動只試一次，失敗就留給橫幅的按鈕）
- 通知 id：每日提醒用 1–30（`kReminderPlanDays`，`replaceAll` 只會動這一段）、debug 測試提醒 99；其他單次通知用 `ReminderScheduler.scheduleOnce`，id 必須 > 30（有 assert，修練場休息結束預定用 200）。`flutter_local_notifications` 排「已經過去的時間」會丟 `ArgumentError`（不是 `PlatformException`），`scheduleOnce` 已先擋掉；要測真的 `LocalReminderScheduler` 得用真實時鐘的未來時間（見 `test/app/local_reminder_scheduler_test.dart`）

## 城鎮（修練場）

- 音效：`docs/sfx/sfx.py`（只用標準函式庫，方波）產生 `assets/sfx/*.wav`，檔名是 `SfxCue` 的 snake_case（`sfxAsset`），不要手改 wav。`AudioSfx`（`lib/app/sfx.dart`）每個音效一個 `AudioPool`、iOS `ambient` 類別（靜音鍵時不響、不打斷使用者的音樂）；`play` 立刻返回、失敗只 log，不會卡住計時器。要不要響由呼叫端看設定 `focus.sound`
- 省電模式的覆蓋層出現時隱藏狀態列（`SystemUiMode.manual, overlays: []`），dispose 時還原 `edgeToEdge`
- 修練場的規則是純函式 `computeFocusLedger`（`lib/game/focus.dart`）：每天 −50 分鐘（使用者決定從**裝好新版當天**起算）、沒還的帶到隔天、過 0 才賺、每週可賺 250 分鐘；賺滿後多做的時間是「預繳」，只抵本週之後的負債（使用者要「每天做」和「一天做完」拿到差不多的金幣）。一週的條件（`FocusTerms`）在週初固定
- 修練場的週：`TownService.rollover()`（`lib/app/town_service.dart`）開週（`focus_weeks`，條件用該週物價＋設定 `focus` 快照）與結算（帳本補正每天的 `focus` 金幣、只罰剛結束那週）；週裡還有沒結束的 session 就先不結算，等計時器結束它後再呼叫。`AppEffects` 在啟動、換日、有冒險者時與回前景時呼叫；跑的時候再被呼叫會多跑一輪
- 專注計時器 `FocusController`（`lib/app/focus_service.dart`）：所有動作排進 `_serial` 佇列依序跑；秒數用錨點算（時鐘倒退不扣、只有往後的日子才切 session）；沒看到 tick 超過 30 秒視同離開；依賴在 `build()` 用 `ref.read`（watch 會在依賴變動時重建、把跑步中的 session 弄丟）。螢幕／音效／亂數走 `ScreenControl`／`Sfx`／`randomProvider`，測試用 `AppHarness` 裡的假的；服務層測試把 `focusTickProvider` 設成 null、自己呼叫 `tick()`
- 「還欠 N 分鐘」用無條件進位（`owedMinutes`），所以 -43:23 會寫還欠 44 分鐘
- 計時器測試不能一次快轉好幾分鐘：超過 30 秒沒 tick 會被當成離開 app；要每 10 秒 advance＋pump（見 `test/ui/town_test.dart`）
- 專注頁有自己的 1 秒 `Timer`（休息倒數、現在時間），只在休息中或開了「顯示現在時間」才 setState
- 離開確認用 `PopScope(canPop: !running)`；「結束並離開」= `stop()`（進休息）再 pop
- 省電覆蓋層蓋在 `PixelPage` 上面（Stack），位置每分鐘依分鐘數換；點一下 `setPowerSave(false)`
- 模擬器座標（iPhone 18 Pro，402×874 pt，示範資料）：城鎮分頁 (251,815)、修練場「進入」(348,170)、開始／停止 (148,292)、省電模式 (337,292)
- 音效有沒有播：`xcrun simctl spawn booted log show --last 2m --predicate 'process == "Runner"' | grep "stopping timebase"`（會印出播了幾秒）
- audioplayers 啟用 session 時系統會記一筆「AVAudioSession Hang Risk」（在主執行緒呼叫 setActive），只是效能提示，沒有實際卡頓

## 城鎮（銀行）

- 規則是純函式 `lib/game/bank_rules.dart`（`mealPlan` 有界逐日抽樣再洗牌、`evenSplit` 備案、`transferFee`、`prorate`、`openMonth`、`closeMeal`）；型別在 `lib/domain/bank.dart`（`AccountRole`、`TxnKind`（**以名稱存，不要改名**）、`BankConfig`、`FixedCost`、`kDefaultAccounts`）
- schema 7：`bank_accounts`（中央、獎池是 role 隱藏列）、`bank_txns`（from／to 為 null＝外面；`amount` 有 CHECK > 0；`ref` unique 做冪等；`group_id` 綁轉帳＋手續費一起作廢；`fixed_id` 標記付哪個固定支出；M4 欄位先留著）、`bank_months`（設定快照、餐費表、預留）。餘額不存，`BankRepository.balances()` 用 SQL 即時算
- 冪等 ref：`opening`、`income:<yyyy-MM>`、`fixed:<yyyy-MM>:<id>`、`refill:<yyyy-MM>`、`meal:<日期>`、`mealsweep:<yyyy-MM>`、`mealcover:<yyyy-MM>`（獎池補）、`mealcover:<yyyy-MM>:vault`（中央補）、`demo:*`（debug 示範）
- `BankService.rollover()` 由 `TownService._rollover()` 最先呼叫（不等冒險者）：從最新的月一路結到今天的月，每個月「月結＋開下個月」一個 transaction；時鐘倒退時什麼都不做
- 預留＝各月 `reserves_json` 加總 − 未作廢的 `expense` 且 `fixed_id` 相同的支出，最低 0；「本月餐費」預留＝本月還沒領的天數合計
- 畫面讀 `bankViewProvider`（`BankService.watchView()`：每次銀行表有寫入就重算整個 `BankView`，隨 `todayProvider` 重建）；明細 `bankTxnsProvider(accountId)`；遮住金額存設定 `bank_hidden`
- `poolFree()`＝獎池餘額 − 還沒結算的週裡還沒抽的獎金（`CasinoRepository.promised()`）
- 帳戶圖示 `PixelBankIcons`（16×16）由 `docs/icon_candidates/bank16.py` 產生，不要手改 `bank_icons.dart`；帳戶存的是圖示 id
- 測試：表單裡的輸入框用 `find.ancestor(of: find.text(hint), matching: find.byType(TextField))`（hint 不在 `EditableText` 底下）；關表單後要多 pump 約 1 秒，不然底下的頁面會找到重複的文字

## 城鎮（賭場）

- 規則是純函式 `lib/game/casino_rules.dart`（`releasePlan`、`weeklyRelease`、`priceAndCount`、`splitPrizes`、`buildDeck`、`expectedWeeklyGold`、`sweepOf`），數值在 `GameRules.casino`（`CasinoRules`）；型別 `lib/domain/casino.dart`（`PrizeTier`、`TicketKind`、`CasinoGame`，**以名稱存，不要改名**）
- schema 8：`casino_weeks`（週一主鍵；`pool_before`、`released`、`price`、`target_gold`＝G*、`price_level`、`terms_json`＝`CasinoTerms`：月計畫、計價天數、週初金幣…；`settled_at`＋`swept`）、`casino_tickets`（索引 `casino_tickets_week`；`kind`／`tier`／`amount`／`account_id`，抽了才有 `drawn_at`／`game`／`paid`）。沒有外鍵
- 月份的週＝週一落在那個月的週（`mondaysLeftInMonth`）。那個月第一次開週時抽計畫（每週百分比、平均 100），寫進每週的 `terms_json.plan`，後面的週讀前一週的；每週撥款＝`poolFree × 本週份額 ÷ 剩下各週份額合計`（份額×開放天數），所以手續費、週結退回的錢會分給剩下的週
- `CasinoService.rollover()` 由 `TownService._rollover()` 在修練場之後呼叫（價格要讀修練場那週的 `maxGold`）；要銀行已開戶。先結算上週（一個 transaction：一半進投資 txn `invest:<週一>`、標 `settled_at`），再開本週（一個 transaction）。賭場第一天＝第一次開週那天，之後的週從週一算。大廳打開時也會呼叫 `townService.rollover()`（剛開戶的情況）
- 抽籤 `draw()`：一個 transaction，動畫前就寫完——先要有一抽的金幣（退費籤抽到才知道）→ 隨機（或指定 `ticketId`）取一張 → 獎籤 `spend`（gold event `casino`／`t:<id>`）→ 獎池到帳戶（txn `prize`，ref `ticket:<id>`）→ `markDrawn`。退費籤不扣金幣、也算一抽。寶箱用 `chests()`（不寫入）取三張，選中的用 `draw(ticketId:)`
- 畫面讀 `casinoViewProvider`（`watchView()`：賭場或銀行表有寫入就重算）。特效 `lib/ui/widgets/casino_fx.dart`（`WinFx` 包 `FlashOverlay`／`ShakeBox`／`CoinBurst`，**樹的結構要固定**——曾經因為依獎項大小換結構，讓裡面的拉霸 state 被重建、永遠停不下來）；全部遵守 `disableAnimations`
- 刮刮樂用 `Listener` 收手指，外面包 `RawGestureDetector`＋`EagerGestureRecognizer`（還有銀漆時才掛）：只用 Listener 時 iOS 上 ListView 仍會跟著捲／回彈。底部按鈕原地換功能（一口氣刮開↔再買一張）後停用 500ms，防連點；格子抽獎每張籤的位置用週一當亂數種子固定
- 遊戲頁 `_GamePage` 只在 `view.open` 時建遊戲，否則顯示 `CasinoClosedNotice`（換週那一下 week 是 null）。拉霸的特效大小（`_fx`）要等轉輪停才決定，不然會先劇透；同理 `draw()` 一開始就寫入，所以拉霸到 `_landed`、刮刮樂到 `_reveal` 之前，頂部 `CasinoHeader` 顯示抽之前的快照（`_GamePage.frozen`），否則金幣與「本週獎金還剩」會先劇透；換週時轉輪會被卸載（轉到一半或抽獎結果回來前），所以 `SlotReels` 重新掛上時若 `landed` 是 false 會直接落地，`_landed` 靠 `_landedSpin` 只跑一次；連抽顯示 `bestOf`（退費最後）。寶箱打開前先查那張還在不在本週牌組（`_inDeck`），不在就重發；也 `listenManual` 週次變化（手上沒箱子時看 `_emptyWeek`，牌組抽完的頁面換週也會重發）
- 動態效果一律用 `reduceMotion(context)`（`casino_fx.dart`）：iOS 的「減少動態效果」只設 `accessibilityFeatures.reduceMotion`，**不會**設 `MediaQuery.disableAnimations`
- 數值紀錄 `lib/app/tuning_log.dart`：純函式 `buildTuningLog` ＋ `exportTuningLog(db)`，只有彙總數字
- 測賭場（`test/ui/casino_fixes_test.dart`）：用 `prepare`（開戶、給金幣、rollover）＋ `leaveOnly` 決定牌組剩什麼；測換週空檔就覆寫 `casinoViewProvider`，用 `ValueNotifier` ＋ `ref.invalidateSelf()` 切「準備中」；測真的換週不能在畫面監聽時於 `runAsync` 裡 `rollover()`（會卡死），要在 pump 前把時鐘撥到下週、rollover、再撥回來，測試中 `h.clock.advance(7 天)` ＋ `tester.pump(1 分鐘)` 讓 `todayProvider` 換日；golden（`casino*.png`）開 disableAnimations

## Notion 連動（M4）

- 三層：`lib/notion/notion_client.dart`（HTTP：`Notion-Version: 2026-03-11`；429／529／409 照 `Retry-After` 重試，5xx 只重試可重複的請求，`createPage` 不重試）、`lib/notion/ledger.dart`（純函式：`LedgerRow.parse`、`planRow`、`ledgerPage`、分類→帳戶對應表 `kCategoryAccount`、欄位名 `LedgerProps`、記帳本標題 `kLedgerTitle`）、`lib/app/notion_sync.dart`（`NotionSync`，設定 `SettingKeys.notion` 存 `NotionLink`，金鑰 `SecretKeys.notion` 在鑰匙圈）
- 沒有新表：用 schema 7 就留好的 `bank_txns` 欄位。`notion_page_id`（unique）連到頁面；`sync_state`（`SyncState`）：`synced`／`dirty`（在 app 歸類了、要寫回帳戶）／`trashed`（已作廢且不用再送垃圾桶）／`creating`（正在建頁；再看到時先用 App ID 查 Notion，避免回應遺失時建兩頁）／`failed`（Notion 拒收這頁，不再重試）；`inbox`＝待分類（錢在中央）；`category`＝Notion 分類
- 程式裡沒有任何 Notion id：連動時用 `POST /v1/search`（只找 data source）找標題**剛好是**「收支紀錄」的，再從它 schema 的「預算項目」relation 拿到預算表（`budgetSourceOf`），兩個 id 存在 `NotionLink.ledger`／`budget`。舊的連動沒有 id，下一次同步時自動找（`_syncOnce`）。找不到回 404 `ledger_not_found`（顯示「找不到記帳本…分享給這個連線」）
- 銀行還沒開戶不能連動（`NotionSync.bankClosed`）：不然開戶金額已經算進去的帳會再扣一次
- `sync()` 不會丟例外，也不會重疊：跑的時候再叫一次，會在這次跑完後再跑一次，兩個 future 都等到最後一次結束（「立即同步」才不會提早說好了）；所有錯誤都存進 `NotionLink.error`
- 每次寫入連動設定、開始推送前都重讀設定（`_still`）：同步途中按「解除連動」，這次同步就停，不會把連動寫回去
- 推送時單一頁被拒（400／403／404）就放掉那一筆繼續推其他的，最後才顯示第一個原因；離線、金鑰錯、429、5xx 才整次中止
- 解除後再連動：舊連動同步過的列保留（`LedgerSkip.beforeTheLink` 不作廢）
- 偵測刪除／還原：最近 45 天建立的頁 id 清單裡，本地沒作廢卻不在清單 → GET（垃圾桶或 404 就作廢）；本地因 Notion 作廢、卻又出現在清單 → GET（還原，不靠編輯時間有沒有變）
- 同名帳戶：列已經在那個名稱的帳戶就不搬；名稱對照時沒封存的帳戶優先
- 用預留的錢付的支出（`fixed_id`，例如年費訂閱）是手記的真實支出，**會**推到 Notion；銀行自動扣的固定支出（kind `fixed`，有 ref）不會
- 一次同步：先拉、再推。拉＝`last_edited_time ≥ 游標 − 5 分鐘`的頁（第一次用 `created_time ≥ 連動時間`）＋最近 45 天建立的頁 id 清單（查詢**永遠不回傳垃圾桶裡的頁**，所以本地有、清單沒有的頁逐一 GET，在垃圾桶或 404 就作廢）；網路都做完才在一個 transaction 裡寫進銀行。推＝作廢的送垃圾桶、`dirty` 的送「帳戶」、新的建頁
- 比對看內容不看編輯時間（Notion 時間只到分鐘，同一分鐘的修改會被漏掉）；`_apply` 欄位都一樣就不寫
- 冪等：建頁後當掉、沒存到 page id → 下次拉到那頁時用「App ID」＝`bank_txns.uid` 認領；在 Notion 複製頁面會帶著同一個 App ID，這時發新的 uid（uid 有 unique）
- 「連動時間」取到分鐘（Notion 的 `created_time` 也是），兩邊都只同步這之後**建立**的帳；app 這邊看 `bank_txns.at`，所以從 Notion 匯入的列 `at` 用頁面的 `created_time`
- 推送對象：`kind` 是 expense／income、`ref` 為 null（自動的搬錢都有 ref）、還沒有 page id、沒作廢
- app 寫進 Notion 的列（App ID＝自己的 uid）不受略過規則影響；從 Notion 來的列變成要略過的（例如分類改成生活費）就作廢
- 帳戶靠**名稱**對應（Notion 的「帳戶」是選項名）：在 app 改帳戶名稱後，舊名稱的列會進待分類；寫入不存在的選項名 Notion 會自動新增
- 測試：`test/support/fake_notion.dart` 是記憶體裡的 Notion（`MockClient`），時間只到分鐘、垃圾桶不出現在查詢裡；widget test 要在第一次 `pump` 前就同步（畫面監聽中在 `runAsync` 裡同步會卡死，見 `test/ui/notion_test.dart` 的 `before`）；開 sheet 後要先 `pump()` 再 `pump(1 秒)`，不然點擊會落在還在滑上來的 sheet 外
- 2026-11-18 用真的金鑰在模擬器驗證過（1 元測試列，測完丟垃圾桶）：app 記的帳建頁（來源、帳戶、分類、預算項目、App ID 都對）；Claude 記帳有帳戶→進該帳戶、購物沒帳戶→待分類；在 app 歸類→寫回「帳戶」；Notion 改帳戶／金額→app 跟著改；丟垃圾桶→作廢、還原→恢復。查詢的 `filter_properties: ['title']` 與垃圾桶偵測在真 API 上照設計運作

## 其他

- 設定頁（debug 版）有「5 秒後測試提醒」可以確認通知真的會跳
- 服務層的測試不一定要用 widget：`ProviderContainer`＋`container.listen(boardProvider, …)` 就能拿到 `BoardEntry` 去呼叫 `GameService`，見 `test/app/price_service_test.dart`
- Notion 記帳本（Claude 記帳技能在用）：收支紀錄、預算項目、週期扣款三個 data source（id 不放進 git；要查就用 Notion 連接器搜「收支紀錄」）；改 Notion 結構或技能文字前要先給使用者看。技能是 claude.ai 同步下來的外掛技能（`~/.claude/skills/synced/…`），本機改了會被蓋掉
