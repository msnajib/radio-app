// Hardcoded Radio Browser UUIDs for top Indonesian stations.
// These guarantee correct matching regardless of name/frequency ambiguity.
// Priority: HIGHEST — if a UUID is listed here it is used directly.
//
// Format key: 'city_lc:frequencyMHz:name_normalized'
// Verify/update UUIDs at: https://de1.api.radio-browser.info/#GetStationsByName
//
// How to find a UUID:
//   curl "https://de1.api.radio-browser.info/json/stations/byname/Prambors" | jq '.[0].stationuuid'

const Map<String, String> kManualOverrides = {
  // ── Jakarta ────────────────────────────────────────────────────────────────
  // Add verified UUIDs below. Example format (uncomment and fill):
  // 'jakarta:102.2:prambors':       '<stationuuid>',
  // 'jakarta:98.7:gen fm':          '<stationuuid>',
  // 'jakarta:101.4:hard rock fm':   '<stationuuid>',
  // 'jakarta:103.0:elshinta':       '<stationuuid>',
  // 'jakarta:100.0:delta fm':       '<stationuuid>',
  // 'jakarta:107.5:sonora fm':      '<stationuuid>',

  // ── Surabaya ───────────────────────────────────────────────────────────────
  // 'surabaya:100.5:suara surabaya': '<stationuuid>',

  // ── Bandung ────────────────────────────────────────────────────────────────
  // 'bandung:101.0:prambors bandung': '<stationuuid>',
};
