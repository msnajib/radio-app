// Known aliases for Indonesian radio stations.
// Key: normalized local station name (lowercase, no FM/AM/Radio, no specials).
// Value: list of normalized strings to check against Radio Browser API station names.
//
// This bonus (+20) fires when the API station name contains any of these aliases.

const Map<String, List<String>> kStationAliases = {
  // Jakarta
  'prambors':         ['prambors', 'prambors fm'],
  'gen fm':           ['gen fm', 'gen 987', 'gen987', '98 7 gen'],
  'hard rock fm':     ['hard rock', 'hardrock'],
  'elshinta':         ['elshinta'],
  'delta fm':         ['delta', 'delta fm'],
  'sonora fm':        ['sonora'],
  'trax fm':          ['trax', 'traxfm'],
  'female radio':     ['female radio', 'female'],
  'sport fm':         ['sport fm', 'sportfm'],
  'mustang 88 fm':    ['mustang'],
  'jak fm':           ['jak fm', 'jakfm'],
  'mstv radio':       ['mstv'],
  'global radio':     ['global radio', 'global'],
  'pas fm':           ['pas fm', 'pasfm'],
  'b radio':          ['b radio', 'bradio'],
  'eltv radio':       ['eltv'],

  // Surabaya
  'suara surabaya':   ['suara surabaya', 'ss fm'],
  'sas fm':           ['sas fm', 'sasfm'],
  'el victor':        ['el victor', 'elvictor'],
  'radio mandiri':    ['mandiri'],

  // Bandung
  'ardan fm':         ['ardan', 'ardan fm'],
  'oz radio':         ['oz radio', 'oz fm'],
  'rase fm':          ['rase', 'rase fm'],
  'cosmo radio':      ['cosmo'],

  // Semarang
  'idola fm':         ['idola', 'idola fm'],
  'cakra fm':         ['cakra', 'cakra fm'],
  'trax semarang':    ['trax'],

  // Yogyakarta
  'swaragama fm':     ['swaragama'],
  'geronimo fm':      ['geronimo'],
  'sindo radio':      ['sindo', 'sindonews'],

  // Medan
  'kiss fm':          ['kiss fm', 'kiss'],
  'prambors medan':   ['prambors'],
  'volare fm':        ['volare'],
  'master fm':        ['master'],

  // Makassar
  'madama fm':        ['madama'],
  'telstar fm':       ['telstar'],
};
