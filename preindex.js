let lunr = require('./assets/js/lunr.min.js');
require('./assets/js/lunr.stemmer.support.min.js')(lunr);
require('./assets/js/tinyseg.js')(lunr);
require('./assets/js/lunr.ja.min.js')(lunr);

let stdin = process.stdin,
    stdout = process.stdout,
    buffer = [];

stdin.resume()
stdin.setEncoding('utf8')

stdin.on('data', function (data) {
  buffer.push(data)
})

stdin.on('end', function () {
  const json = JSON.parse(buffer.join(''))
  const idx = lunr(function () {
    this.use(lunr.ja);
    this.ref('id');
    this.field('title', { boost : 5 });
    this.field('content');
    Object.keys(json).forEach((id) => {
      this.add({"id" : id, ...json[id]});
    });
  });
  stdout.write(JSON.stringify(idx))
})

