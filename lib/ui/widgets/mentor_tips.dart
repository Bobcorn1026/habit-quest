import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/settings_repository.dart';
import 'mentor.dart';

/// Things 莉娜 explains once, the first time they matter. A new feature
/// gets its introduction by adding a tip here and showing it where the
/// feature first appears.
enum MentorTip {
  board,
  chronicle,
  hero,
  classOpen,
  trial,
  offer,
  shop,
  inn,
  blessing,
  sideQuest,
  stacking,
  town,
  focus,
  bank,
  meal,
  casino,
  notion;

  List<String> lines(String name) => switch (this) {
    board => [
      '這裡是任務板，你今天的委託都貼在這裡。',
      '做完一件就按「完成」回報，填上做了多少；想寫一句心得也可以。',
      '封印要每天回報：守住了，還是出現裂痕。老實說就好，裂痕不是世界末日。',
      '還有公會的老規矩：錯過一天沒關係，別連續錯過兩天就好。',
    ],
    chronicle => [
      '這是冒險日誌。每過一週，吟遊詩人會照你的表現寫下新的一章。',
      '章末會有抉擇，你選的路會接到下一章。',
      '故事裡的能力檢定看起來像在擲骰子……其實結果早就由你那週的努力決定了。噓。',
    ],
    hero => [
      '這是你的冒險者資料。完成任務，對應的能力值就會成長。',
      '累積公會點數就能挑戰晉升考驗，Rank 從 F 一路到 SSS。',
      '冒險的第二週，公會會替你做就職鑑定，照你的任務決定職業。',
      '想修改任務的內容也行，不過……修改是要付出代價的。那天的任務會被詛咒，一定要完成。',
    ],
    classOpen => ['$name，就職鑑定的日子到了！', '到「角色」頁按「鑑定」，公會會照你這陣子的任務決定你的職業。'],
    trial => [
      '$name，你的公會點數夠了，可以挑戰晉升考驗！',
      '考驗期間，每天的委託都要全部完成、封印全部守住。準備好就到「角色」頁接受考驗吧。',
    ],
    shop => [
      '歡迎光臨公會商店——呼啊，我是說，歡迎光臨。',
      '金幣可以換頭像、稱號框，還有任務板的木頭。完成委託、連續不中斷、過完完美的一天，金幣就會進帳。',
      '有些東西要更高的 Rank 才能買，慢慢來就好。',
    ],
    inn => [
      '商店最上面多了一間旅店。累了的時候，可以花金幣訂一天休息日。',
      '休息日不回報也不會負傷，連續紀錄不會中斷，也不算漏掉。想回報的話照樣可以。',
      '每週最多訂兩晚，只能訂明天起一週內的日子；還沒到的日子，取消可以全額退款。',
    ],
    blessing => [
      '你在章末選的路，會帶來一段期間的加持。',
      '像是某種任務的 EXP 多一點、金幣多一枚，或檢定比較容易過。看看任務板上方寫了什麼吧。',
    ],
    sideQuest => ['有人託我轉交一份「支線委託」給你……呼啊。', '在期限內達成，就有額外的金幣和經驗值。沒做到也不會怎樣，別有壓力。'],
    stacking => [
      '「接在…之後」是習慣堆疊：把新習慣綁在你本來就會做的事後面。',
      '可以接在刷完牙、吃完午餐這類固定的事，也可以接在另一件委託之後。',
      '前一件做完，這件的任務卡就會亮起「下一步」。改這一欄不算修改任務，不會被詛咒。',
    ],
    offer => ['有人注意到你一直超越委託的要求……任務卡上出現了晉階邀請。', '要不要接受由你決定。留在原本的任務也完全沒問題喔。'],
    town => ['這裡是城鎮。公會商店和旅店搬到這裡了。', '修練場和銀行已經開張囉。賭場還在施工，蓋好了我再帶你去看。'],
    focus => [
      '歡迎來到修練場。這裡的碼表很特別：每天都從 -50:00 開始。',
      '從今天起，每天會多 50 分鐘的負債。先專注把它還清，過了 0 之後的時間才會賺金幣。',
      '沒還完的會帶到隔天，週日結束時還欠著的會扣一點金幣。旅店的休息日不加新負債。',
      '每週專注滿 10 小時就達標。一口氣做完也行，超過能賺的部分會自動預繳之後幾天的負債。',
      '專注時離開 app 超過 30 秒，這一輪就會結束。停下來之後休息一下，時間到我會叫你。',
    ],
    bank => [
      '這裡是銀行……管的是你現實世界的錢，不是金幣喔。',
      '中央銀行就是你的戶頭。底下的子帳戶像信封，一個用途一個，裡面的錢要靠賭場贏回來。',
      '每個月 1 號，收入會進中央銀行，扣掉餐費和固定支出，剩下的放進賭場的獎池。',
      '花了錢就按「記支出」。數字跟戶頭對不上時用「對帳」。中央銀行的數字太誘人的話，按「遮住」就好。',
    ],
    meal => [
      '餐費是每天領的。按「領今日餐費」，會抽 150 到 250 元放進餐費帳戶。',
      '一個月加起來剛好是設定的餐費。忘了領也沒關係，可以補領，月底也會自動補上。',
      '月底餐費帳戶有剩，會進獎池；吃超過了，獎池會先幫你補。還有，餐費帳戶的錢不能轉出去喔。',
    ],
    casino => [
      '這裡是賭場……別緊張，玩法很像一番賞，籤抽完就把整週的獎金拿光了。',
      '每週一，銀行的獎池會撥一筆本週獎金，切成 A 到 D 賞的籤，再加 4 張「退費」。每張籤都有獎，中的錢會直接放進對應的帳戶。',
      '一抽要幾枚金幣，週一就定好了：這週委託全做、每天完美、修練場賺滿，大概剛好抽得完九成五的籤。',
      '週日過完，沒抽完的獎金一半進投資帳戶、一半留在獎池。所以……好好做委託，就是最好的賭運。',
    ],
    notion => [
      '記帳本連上了！從現在起，你在 Notion 記的帳會自動搬進銀行，在銀行記的也會寫回 Notion。',
      'Notion 那邊有填「帳戶」，錢就從那個帳戶扣；沒填的我會照分類猜，猜不到的先放在中央銀行的「待分類」，等你來選。',
      '領餐費、中獎、轉帳這些銀行裡面搬來搬去的錢，不會寫進 Notion。每月的固定支出和生活費也是銀行自己記，Notion 的那幾筆不會搬進來。',
    ],
  };
}

class _TipQueue {
  Future<void> last = Future.value();
}

final _tipQueueProvider = Provider((_) => _TipQueue());

/// Shows [tip] unless it was shown before. Tips asked for at the same time
/// wait for each other.
Future<void> showMentorTip(BuildContext context, WidgetRef ref, MentorTip tip) {
  final queue = ref.read(_tipQueueProvider);
  return queue.last = queue.last
      // _show checks `context.mounted` before using it.
      // ignore: use_build_context_synchronously
      .then((_) => _show(context, ref, tip))
      .catchError((Object e) => debugPrint('mentor tip: $e'));
}

Future<void> _show(BuildContext context, WidgetRef ref, MentorTip tip) async {
  if (!context.mounted) return;
  final settings = ref.read(settingsRepoProvider);
  final raw = await settings.read(SettingKeys.tipsSeen);
  final seen = {if (raw is List) ...raw.whereType<String>()};
  if (seen.contains(tip.name) || !context.mounted) return;
  await settings.write(SettingKeys.tipsSeen, [...seen, tip.name]);
  final name = (await ref.read(adventurerRepoProvider).get())?.name ?? '勇者';
  if (context.mounted) await showMentor(context, tip.lines(name));
}
