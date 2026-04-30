// Alias map for Indonesian radio stations.
// Key: local station name lowercased (matches LocalStation.name.toLowerCase()).
// Value: alias terms to search within normalized API text (name+tags+state+country).
//
// Alias bonus fires when ANY alias term is found in the Radio Browser API text.
// This helps when the same brand appears with slightly different names in the API.

const Map<String, List<String>> kStationAliases = {
  // ── Prambors (multi-city) ──────────────────────────────────────────────────
  'prambors fm':              ['prambors'],
  'prambors jakarta':         ['prambors'],
  'prambors surabaya':        ['prambors'],
  'prambors semarang':        ['prambors'],
  'prambors bandung':         ['prambors'],
  'prambors yogyakarta':      ['prambors', 'prambors jogja', 'prambors yogya'],
  'prambors medan':           ['prambors'],

  // ── Elshinta (multi-city) ─────────────────────────────────────────────────
  'radio elshinta':           ['elshinta'],
  'radio elshinta surabaya':  ['elshinta'],
  'radio elshinta semarang':  ['elshinta'],
  'radio elshinta bandung':   ['elshinta'],
  'radio elshinta medan':     ['elshinta'],

  // ── Trijaya / MNC Trijaya ─────────────────────────────────────────────────
  'mnc trijaya fm':           ['trijaya', 'sindo trijaya', 'mnc trijaya'],
  'radio trijaya fm surabaya':['trijaya', 'mnc trijaya'],
  'radio trijaya fm semarang':['trijaya', 'mnc trijaya'],
  'radio trijaya fm bandung': ['trijaya', 'mnc trijaya'],
  'mnc trijaya fm yogya':     ['trijaya', 'mnc trijaya'],
  'sindo trijaya fm':         ['trijaya', 'sindo trijaya', 'mnc trijaya'],

  // ── Gen FM ────────────────────────────────────────────────────────────────
  'gen fm':                   ['gen'],
  'gen fm surabaya':          ['gen'],

  // ── Delta FM ──────────────────────────────────────────────────────────────
  'delta fm':                 ['delta'],
  'delta fm semarang':        ['delta'],
  'delta fm bandung':         ['delta'],
  'radio delta fm yogya':     ['delta'],
  'radio delta fm medan':     ['delta'],

  // ── Sonora ────────────────────────────────────────────────────────────────
  'sonora fm':                ['sonora'],
  'radio sonora':             ['sonora'],
  'radio sonora surabaya':    ['sonora'],
  'radio sonora semarang':    ['sonora'],
  'radio sonora bandung':     ['sonora'],
  'radio sonora yogya':       ['sonora'],

  // ── i-Swara ───────────────────────────────────────────────────────────────
  'i-swara':                  ['iswara', 'i swara', 'i-swara'],
  'iswara fm surabaya':       ['iswara', 'i swara'],
  'iswara fm semarang':       ['iswara', 'i swara'],
  'iswara fm yogya':          ['iswara', 'i swara'],
  'iswara fm medan':          ['iswara', 'i swara'],

  // ── RRI ───────────────────────────────────────────────────────────────────
  'rri programa 1':           ['rri pro 1', 'rri programa satu', 'rri pro1'],
  'rri programa 2':           ['rri pro 2', 'rri programa dua',  'rri pro2'],
  'rri programa 3':           ['rri pro 3', 'rri programa tiga', 'rri pro3'],
  'rri programa 4':           ['rri pro 4', 'rri programa empat','rri pro4'],
  'rri pro 1 surabaya':       ['rri surabaya pro 1', 'rri programa 1 surabaya'],
  'rri pro 2 surabaya':       ['rri surabaya pro 2', 'rri programa 2 surabaya'],
  'rri pro 3 surabaya':       ['rri surabaya pro 3', 'rri programa 3 surabaya'],
  'rri pro 4 surabaya':       ['rri surabaya pro 4', 'rri programa 4 surabaya'],
  'rri yogyakarta pro 1':     ['rri jogja pro 1', 'rri yogya pro 1'],
  'rri pro 2 yogyakarta':     ['rri jogja pro 2', 'rri yogya pro 2'],
  'rri pro 3 yogyakarta':     ['rri jogja pro 3', 'rri yogya pro 3'],
  'rri pro 4 yogyakarta':     ['rri jogja pro 4', 'rri yogya pro 4'],

  // ── Jakarta ───────────────────────────────────────────────────────────────
  'hard rock fm':             ['hard rock', 'hardrock'],
  'jak fm':                   ['jak fm', 'jakfm'],
  'trax fm':                  ['trax', 'traxfm'],
  'mustang 88 fm':            ['mustang'],
  'female radio':             ['female radio', 'female'],
  'sport fm':                 ['sport fm', 'sportfm'],
  'pas fm':                   ['pas fm', 'pasfm'],
  'global radio':             ['global radio'],
  'b radio':                  ['b radio', 'bradio'],

  // ── Surabaya ──────────────────────────────────────────────────────────────
  'suara surabaya':           ['suara surabaya', 'ss fm'],
  'sas fm':                   ['sas fm', 'sasfm'],
  'el victor':                ['el victor', 'elvictor'],

  // ── Bandung ───────────────────────────────────────────────────────────────
  'ardan fm':                 ['ardan'],
  'oz radio':                 ['oz radio', 'oz fm'],
  'rase fm':                  ['rase'],
  'cosmo radio':              ['cosmo'],

  // ── Semarang ──────────────────────────────────────────────────────────────
  'idola fm':                 ['idola'],
  'cakra fm':                 ['cakra'],

  // ── Yogyakarta ────────────────────────────────────────────────────────────
  'swaragama fm':             ['swaragama'],
  'geronimo fm':              ['geronimo'],

  // ── Medan ─────────────────────────────────────────────────────────────────
  'kiss fm':                  ['kiss fm', 'kiss'],
  'volare fm':                ['volare'],
  'master fm':                ['master'],
};
