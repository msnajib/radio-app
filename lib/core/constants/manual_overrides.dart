// Hardcoded Radio Browser UUIDs for top Indonesian stations.
// These guarantee correct matching regardless of name/frequency ambiguity.
// Priority: HIGHEST — if a UUID is listed here it is used directly.
//
// Format key: 'city_lc:frequencyMHz:name_normalized'
//
// ⚠️ NOTES:
// - Entries here are curated & safe for production baseline
// - Some stations (low bitrate / missing state) still work but should be QA-tested
// - Do NOT blindly add all stations — only stable & well-known ones

const Map<String, String> kManualOverrides = {
  // ── Jakarta ────────────────────────────────────────────────────────────────
  'jakarta:102.2:prambors': 'ab8ee851-2750-475e-ab77-aab0b2c49823',
  'jakarta:90.0:elshinta': '37aaad0f-1cd6-4d68-9fd0-3a621251c546',
  'jakarta:92.0:sonora': 'fc4d5e3b-fe29-4ef8-b9d8-24773cde62db',
  'jakarta:97.1:rdi': '962fdcaf-0601-11e8-ae97-52543be04c81',
  'jakarta:106.2:bens': '6c63a6b2-88ea-46d8-9e5f-86f8e0a2f9da',

  // ⚠️ Low quality but usable (optional)
  'jakarta:99.1:delta': 'cdd58252-09b9-4c89-b688-243cf107ad29',

  // ── Surabaya ───────────────────────────────────────────────────────────────
  // ⚠️ Low bitrate — test playback
  'surabaya:100.0:suara surabaya': '1f33f36c-4ea8-4fb8-aac8-3fc83cd2a7ed',
  'surabaya:97.6:elshinta surabaya': '39e90ff6-e0d7-432c-a5ff-a6e629724a31',

  // ── Bandung ────────────────────────────────────────────────────────────────
  'bandung:89.3:elshinta bandung': 'dd0dd432-f938-42e5-be76-394fbc0dd5ac',
  'bandung:93.3:sonora bandung': 'bffe0959-edde-4adb-8b05-6a045317dca2',

  // ⚠️ bitrate unknown / 0kbps → still works in many cases
  'bandung:105.9:ardan': 'd0d5c057-c111-4975-9034-40ee02fcd7c4',

  // ── Yogyakarta ─────────────────────────────────────────────────────────────
  'yogyakarta:97.0:mnc trijaya yogya': '04812d3e-a13e-4fc5-b7be-2ac2cb0c620f',
  'yogyakarta:97.4:sonora yogya': '3ff79e0c-6051-4aec-a3e9-40472c78ddb1',
};
