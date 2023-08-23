const lcovJSON = require('../coverage.json');

(() => {
  const analyze = (file, section, numHits, numFound) => {
    if (numHits < numFound) {
      const percentage = (100.0 * numHits) / numFound;
      throw new Error(`${section} coverage for ${file} is at ${percentage}%`);
    }
  };

  lcovJSON.forEach(({ file, branches, functions, lines }) => {
    console.log(`Analyzing coverage for ${file}`);
    analyze(file, 'Branch', branches.hit, branches.found);
    analyze(file, 'Function', functions.hit, functions.found);
    analyze(file, 'Line', lines.hit, lines.found);
    console.log(`Coverage for ${file} is at 100%!`);
  });
})();
