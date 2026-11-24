import '../domain/quest.dart';
import '../domain/upgrade_offer.dart';

typedef OfferText = ({String title, String subtitle, String npcLine});

/// Default NPC lines for upgrade invitations, used until a chapter's AI
/// rewrites them.
OfferText offerTemplate(OfferKind kind, Quest q) => switch (kind) {
  OfferKind.stale || OfferKind.surpass => (
    title: '${q.title}・精通',
    subtitle: '～你早已不是當初的你～',
    npcLine:
        '公會長拍了拍你的肩：「你每次交回來的成果都遠超委託內容。'
        '是時候接更高階的任務了。」',
  ),
  OfferKind.sealMastery => (
    title: '${q.title}・強化封印',
    subtitle: '～封印的光芒穩定而明亮～',
    npcLine:
        '賢者端詳著封印：「這道封印已經很牢固了。'
        '要再收緊一點條件，還是把它封存起來，當作你的戰利品？」',
  ),
};
