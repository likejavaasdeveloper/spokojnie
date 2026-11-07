const fs = require('fs');
const path = require('path');

function fail(message) {
  throw new Error(message);
}

function lessonId(number) {
  return `lesson_${String(number).padStart(3, '0')}`;
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function main() {
  const repositoryRoot = path.resolve(__dirname, '..');
  const assetRoot = path.join(repositoryRoot, 'assets', 'content', 'lessons');
  const catalogPath = path.join(assetRoot, 'catalog.json');
  const catalog = readJson(catalogPath);
  if (!catalog || !Array.isArray(catalog.lessons) || catalog.lessons.length !== 26) {
    fail('The protected catalog draft must contain exactly 26 lessons.');
  }

  const seenIds = new Set();
  const violations = [];
  catalog.lessons.forEach((lesson, index) => {
    const expectedId = lessonId(index + 1);
    if (lesson.id !== expectedId) {
      violations.push(`Catalog order or identifier mismatch at index ${index}: ${lesson.id}.`);
    }
    if (seenIds.has(lesson.id)) {
      violations.push(`Duplicate catalog identifier: ${lesson.id}.`);
    }
    seenIds.add(lesson.id);
    const expectedAccess = index < 2 ? 'free' : 'protected';
    if (lesson.access !== expectedAccess) {
      violations.push(`${lesson.id} must have access=${expectedAccess}.`);
    }
    const expectedAsset = expectedAccess === 'protected'
      ? `assets/content/lessons/protected/${lesson.id}.enc.json`
      : `assets/content/lessons/${lesson.id}.json`;
    if (lesson.contentAsset != null && lesson.contentAsset !== expectedAsset) {
      violations.push(`${lesson.id} does not point to its expected asset.`);
    }
  });

  for (let number = 3; number <= 26; number++) {
    const id = lessonId(number);
    const plaintextPath = path.join(assetRoot, `${id}.json`);
    if (fs.existsSync(plaintextPath)) {
      violations.push(`Protected plaintext asset exists: ${plaintextPath}.`);
    }
    const entry = catalog.lessons.find((lesson) => lesson.id === id);
    if (entry) {
      const encryptedPath = path.resolve(
        repositoryRoot,
        entry.contentAsset || `assets/content/lessons/protected/${id}.enc.json`,
      );
      if (!fs.existsSync(encryptedPath)) {
        violations.push(`Encrypted asset is missing: ${encryptedPath}.`);
      }
    }
  }

  if (violations.length > 0) {
    process.stderr.write(`${violations.join('\n')}\n`);
    process.exitCode = 1;
    return;
  }
  process.stdout.write('Lesson asset exposure check passed.\n');
}

try {
  main();
} catch (error) {
  process.stderr.write(`${error.message}\n`);
  process.exitCode = 1;
}
