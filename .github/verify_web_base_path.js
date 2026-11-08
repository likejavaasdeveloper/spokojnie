const fs = require('fs');

const expectedHref = '/spokojnie/';
const inputPath = process.argv[2];

function fail(message) {
  process.stderr.write(`${message}\n`);
  process.exitCode = 1;
}

function readHtml() {
  if (!inputPath) {
    fail('Usage: node .github/verify_web_base_path.js <index.html>');
    return null;
  }
  try {
    return inputPath === '-'
      ? fs.readFileSync(0, 'utf8')
      : fs.readFileSync(inputPath, 'utf8');
  } catch (error) {
    fail(`Unable to read ${inputPath}: ${error.message}`);
    return null;
  }
}

function detectedHrefValues(baseElement) {
  const values = [];
  const hrefPattern = /(?:^|\s)href\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s"'=<>`]+))/gi;
  let match;
  while ((match = hrefPattern.exec(baseElement)) !== null) {
    values.push(match[1] !== undefined ? match[1] : match[2] !== undefined ? match[2] : match[3]);
  }
  return values;
}

const html = readHtml();
if (html !== null) {
  const baseElements = html.match(/<base\b[^>]*>/gi) || [];
  const hrefValues = baseElements.reduce(
    (values, baseElement) => values.concat(detectedHrefValues(baseElement)),
    [],
  );
  const hasExactlyOneBase = baseElements.length === 1;
  const hasExactlyOneHref = hrefValues.length === 1;
  const hasExpectedHref = hrefValues[0] === expectedHref;

  if (!hasExactlyOneBase || !hasExactlyOneHref || !hasExpectedHref) {
    const detected = hrefValues.length > 0 ? hrefValues.join(', ') : '<none>';
    fail(
      `Expected exactly one <base> element with href="${expectedHref}"; ` +
      `detected ${baseElements.length} base element(s) and href value(s): ${detected}.`,
    );
  } else {
    process.stdout.write(`Web base path check passed: ${expectedHref}\n`);
  }
}
