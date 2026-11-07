const fs = require('fs');
const path = require('path');

function fail(message) {
  throw new Error(message);
}

function lessonId(number) {
  return `lesson_${String(number).padStart(3, '0')}`;
}

function walk(directory) {
  const files = [];
  for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
    const entryPath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      files.push(...walk(entryPath));
    } else if (entry.isFile()) {
      files.push(entryPath);
    }
  }
  return files;
}

function readManifest(filePath) {
  try {
    const value = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    if (!value || typeof value !== 'object' || Array.isArray(value)) {
      return null;
    }
    return value;
  } catch (_) {
    return null;
  }
}

function manifestKeys(manifest) {
  return new Set(Object.keys(manifest));
}

function expectedAssets() {
  const assets = [
    'assets/content/lessons/catalog.json',
    'assets/content/lessons/lesson_001.json',
    'assets/content/lessons/lesson_002.json',
  ];
  for (let number = 3; number <= 26; number++) {
    assets.push(`assets/content/lessons/protected/${lessonId(number)}.enc.json`);
  }
  return assets;
}

function main() {
  const buildRoot = path.resolve(
    process.argv[2] || path.join(__dirname, '..', 'build', 'web'),
  );
  if (!fs.existsSync(buildRoot)) {
    fail(`Build output directory is missing: ${buildRoot}`);
  }

  const files = walk(buildRoot);
  const relativeFiles = files.map((filePath) =>
    path.relative(buildRoot, filePath).split(path.sep).join('/'),
  );
  const manifestPaths = [
    path.join(buildRoot, 'assets', 'AssetManifest.json'),
    path.join(buildRoot, 'assets', 'AssetManifest.bin.json'),
    path.join(buildRoot, 'AssetManifest.json'),
    path.join(buildRoot, 'AssetManifest.bin.json'),
  ];
  const manifests = manifestPaths
    .filter((filePath, index, paths) => paths.indexOf(filePath) === index)
    .map((filePath) => ({filePath, value: readManifest(filePath)}))
    .filter((entry) => entry.value !== null);
  if (manifests.length === 0) {
    fail('No readable JSON asset manifest was found in the web build.');
  }

  const keys = new Set();
  for (const manifest of manifests) {
    for (const key of manifestKeys(manifest.value)) {
      keys.add(key.replace(/^\//, ''));
    }
  }

  const missingManifestAssets = expectedAssets().filter((asset) => !keys.has(asset));
  if (missingManifestAssets.length > 0) {
    fail(`Required assets are missing from the generated manifest: ${missingManifestAssets.join(', ')}`);
  }

  const physicalAssets = new Set(
    relativeFiles
      .filter((file) => file.startsWith('assets/content/lessons/') || file.startsWith('assets/assets/content/lessons/'))
      .map((file) => file.replace(/^assets\/assets\//, 'assets/')),
  );
  const missingPhysicalAssets = expectedAssets().filter((asset) => !physicalAssets.has(asset));
  if (missingPhysicalAssets.length > 0) {
    fail(`Required assets are missing from the web build: ${missingPhysicalAssets.join(', ')}`);
  }

  const protectedPlaintext = relativeFiles.filter((file) =>
    /(?:^|\/)assets\/content\/lessons\/lesson_0(?:0[3-9]|1[0-9]|2[0-6])\.json$/.test(file),
  );
  if (protectedPlaintext.length > 0) {
    fail(`Protected plaintext lessons are present in the web build: ${protectedPlaintext.join(', ')}`);
  }

  const encryptedAssets = relativeFiles.filter((file) =>
    /(?:^|\/)assets\/content\/lessons\/protected\/lesson_\d{3}\.enc\.json$/.test(file),
  );
  const expectedEncrypted = new Set(expectedAssets().filter((asset) => asset.endsWith('.enc.json')));
  const unexpectedEncrypted = encryptedAssets.filter((file) => {
    const asset = file.replace(/^assets\/assets\//, 'assets/');
    return !expectedEncrypted.has(asset);
  });
  if (unexpectedEncrypted.length > 0 || encryptedAssets.length !== expectedEncrypted.size) {
    fail(`Expected exactly 24 protected encrypted assets, found ${encryptedAssets.length}.`);
  }

  const forbiddenFiles = relativeFiles.filter((file) =>
    /(?:password|inventory|plaintext-backup|backup|\.csv)/i.test(file),
  );
  if (forbiddenFiles.length > 0) {
    fail(`Sensitive or private files are present in the web build: ${forbiddenFiles.join(', ')}`);
  }

  process.stdout.write(`Web build asset security check passed for ${buildRoot}.\n`);
}

try {
  main();
} catch (error) {
  process.stderr.write(`${error.message}\n`);
  process.exitCode = 1;
}
