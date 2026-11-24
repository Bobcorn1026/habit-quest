import '../domain/chapter.dart';
import '../domain/quest_rank.dart';
import '../domain/side_quest.dart';
import '../domain/sprite_ids.dart';
import '../domain/stat.dart';
import 'ai_tasks.dart';

// Structured outputs reject numeric and length constraints, so limits are
// enforced by the parser instead of here.

Map<String, Object?> _object(Map<String, Object?> properties) => {
  'type': 'object',
  'additionalProperties': false,
  'required': properties.keys.toList(),
  'properties': properties,
};

const _string = {'type': 'string'};

Map<String, Object?> _nullable(Map<String, Object?> schema) => {
  'anyOf': [
    schema,
    {'type': 'null'},
  ],
};

final _choice = _object({
  'label': _string,
  'hint': _string,
  'blessing': _nullable(
    _object({
      'kind': {
        'type': 'string',
        'enum': [for (final k in BlessingKind.values) k.name],
      },
      'stat': {
        'type': 'string',
        'enum': [for (final s in Stat.attributes) s.code],
      },
    }),
  ),
});

final _header = {
  'protocol': {
    'type': 'string',
    'enum': [kProtocol],
  },
  'requestId': _string,
};

final forgeSchema = _object({
  ..._header,
  'quests': {
    'type': 'array',
    'items': _object({
      'key': _string,
      'rank': {
        'type': 'string',
        'enum': [for (final r in QuestRank.values) r.label],
      },
      'title': _string,
      'subtitle': _string,
      'flavor': _string,
      'spriteId': {
        'type': 'string',
        'enum': [...kQuestSpriteIds, ...kMonsterSpriteIds],
      },
      'attribute': {
        'type': 'string',
        'enum': [for (final s in Stat.attributes) s.code],
      },
    }),
  },
  'world': _nullable(
    _object({
      'summary': _string,
      'npcs': {
        'type': 'array',
        'items': _object({'name': _string, 'description': _string}),
      },
    }),
  ),
  'prologue': _nullable(
    _object({
      'title': _string,
      'body': _string,
      'choices': {'type': 'array', 'items': _choice},
      'recap': _string,
    }),
  ),
});

final classSchema = _object({
  ..._header,
  'name': _string,
  'stats': {
    'type': 'array',
    'items': {
      'type': 'string',
      'enum': [for (final s in Stat.attributes) s.code],
    },
  },
  'flavor': _string,
  'portrait': {'type': 'string', 'enum': kPortraitIds},
  'ceremony': _string,
});

final upgradeSchema = _object({
  ..._header,
  'title': _string,
  'subtitle': _string,
  'npcLine': _string,
  'target': _nullable({'type': 'number'}),
});

final titleSchema = _object({..._header, 'title': _string, 'reason': _string});

final chapterSchema = _object({
  ..._header,
  'sideQuest': _nullable(
    _object({
      'title': _string,
      'story': _string,
      'kind': {
        'type': 'string',
        'enum': [for (final k in SideQuestKind.values) k.name],
      },
      'questKey': _nullable(_string),
      'stat': _nullable({
        'type': 'string',
        'enum': [for (final s in Stat.attributes) s.code],
      }),
      'target': {'type': 'number'},
    }),
  ),
  'title': _string,
  'body': _string,
  'choices': {'type': 'array', 'items': _choice},
  'recap': _string,
  'qualityBonus': {'type': 'number'},
  'upgrades': {
    'type': 'array',
    'items': _object({
      'questKey': _string,
      'title': _string,
      'subtitle': _string,
      'npcLine': _string,
    }),
  },
});
