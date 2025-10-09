#!/usr/bin/env node

/**
 * OPS-LocalGate: Preflight check system
 * Ensures local tests are green before allowing push
 * 
 * Usage:
 *   npm run preflight              # Full suite
 *   npm run preflight:quick        # Skip Playwright + web build
 *   node scripts/preflight.mjs --quick --fix --no-emulators
 */

import { $ } from 'zx';
import { execa } from 'execa';
import { cyan, green, red, yellow, bold, dim } from 'colorette';
import { mkdir, writeFile } from 'fs/promises';
import { existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import kill from 'tree-kill';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const ROOT = join(__dirname, '..');

// Parse flags
const args = process.argv.slice(2);
const FLAGS = {
  quick: args.includes('--quick'),
  noEmulators: args.includes('--no-emulators'),
  fix: args.includes('--fix'),
};

// Setup logging
const LOG_DIR = join(ROOT, 'local-ci', 'logs');
const SUMMARY_PATH = join(ROOT, 'local-ci', 'summary.md');

await mkdir(LOG_DIR, { recursive: true });

let globalLogs = '';
let results = [];

function log(message) {
  console.log(message);
  globalLogs += message + '\n';
}

function banner(text) {
  const line = '='.repeat(60);
  log('');
  log(cyan(line));
  log(cyan(bold(`  ${text}`)));
  log(cyan(line));
  log('');
}

async function writeLog(filename, content) {
  await writeFile(join(LOG_DIR, filename), content, 'utf-8');
}

async function checkTool(name, command, versionFlag = '--version') {
  try {
    const { stdout } = await execa(command, [versionFlag], { reject: false });
    const version = stdout.split('\n')[0].trim();
    log(green(`✓ ${name}: ${dim(version)}`));
    return true;
  } catch (err) {
    log(red(`✗ ${name}: NOT FOUND`));
    return false;
  }
}

async function runStep(name, command, options = {}) {
  const startTime = Date.now();
  log(bold(`\n▶ ${name}...`));
  
  const logFile = name.toLowerCase().replace(/[^a-z0-9]+/g, '-') + '.log';
  let output = '';
  let success = false;
  let error = null;

  try {
    const result = await execa(command, options.args || [], {
      cwd: options.cwd || ROOT,
      shell: true,
      all: true,
      reject: false,
      ...options.execaOpts,
    });

    output = result.all || result.stdout || '';
    success = result.exitCode === 0;
    error = success ? null : (result.stderr || `Exit code: ${result.exitCode}`);

    if (success) {
      log(green(`✓ ${name} PASSED`) + dim(` (${Date.now() - startTime}ms)`));
    } else {
      log(red(`✗ ${name} FAILED`) + dim(` (${Date.now() - startTime}ms)`));
      if (error) log(red(`  ${error.split('\n')[0]}`));
    }
  } catch (err) {
    output = err.message;
    error = err.message;
    log(red(`✗ ${name} ERROR: ${err.message}`));
  }

  await writeLog(logFile, output);

  results.push({
    name,
    success,
    duration: Date.now() - startTime,
    error,
    logFile,
  });

  return success;
}

async function writeSummary() {
  const passed = results.filter(r => r.success).length;
  const failed = results.filter(r => !r.success).length;
  const total = results.length;

  let md = `# Local CI - Preflight Summary\n\n`;
  md += `**Generated:** ${new Date().toISOString()}\n\n`;
  md += `**Flags:** ${JSON.stringify(FLAGS)}\n\n`;
  md += `## Results: ${passed}/${total} passed\n\n`;
  
  md += `| Step | Status | Duration | Log |\n`;
  md += `|------|--------|----------|-----|\n`;
  
  for (const r of results) {
    const status = r.success ? '✅ PASS' : '❌ FAIL';
    const duration = `${r.duration}ms`;
    md += `| ${r.name} | ${status} | ${duration} | [${r.logFile}](logs/${r.logFile}) |\n`;
  }

  if (failed > 0) {
    md += `\n## Failures\n\n`;
    for (const r of results.filter(r => !r.success)) {
      md += `### ${r.name}\n`;
      md += `\`\`\`\n${r.error || 'See log file'}\n\`\`\`\n\n`;
    }
  }

  await writeFile(SUMMARY_PATH, md, 'utf-8');
}

// Main execution
(async () => {
  banner('LOCAL CI – PREFLIGHT');

  log(dim('Flags:'));
  log(dim(`  --quick: ${FLAGS.quick}`));
  log(dim(`  --no-emulators: ${FLAGS.noEmulators}`));
  log(dim(`  --fix: ${FLAGS.fix}`));
  log('');

  // Step 1: Tooling checks
  log(bold('🔧 Checking required tools...'));
  const tools = [
    await checkTool('Flutter', 'flutter', '--version'),
    await checkTool('Dart', 'dart', '--version'),
    await checkTool('Node.js', 'node', '--version'),
    await checkTool('npm', 'npm', '--version'),
    await checkTool('Firebase CLI', 'firebase', '--version'),
  ];

  if (!tools.every(Boolean)) {
    log(red('\n✗ Missing required tools. Install and retry.'));
    process.exit(1);
  }

  // Step 2: Flutter app checks
  banner('Flutter App Checks');

  if (!(await runStep('Flutter pub get', 'flutter', { args: ['pub', 'get'] }))) {
    log(red('\n❌ Preflight FAILED at: Flutter pub get'));
    await writeSummary();
    process.exit(1);
  }

  const analyzeArgs = ['analyze', '--no-fatal-infos', '--no-fatal-warnings'];
  if (!(await runStep('Flutter analyze', 'flutter', { args: analyzeArgs }))) {
    log(red('\n❌ Preflight FAILED at: Flutter analyze'));
    log(yellow('   Hint: Run `flutter analyze` locally to see errors'));
    await writeSummary();
    process.exit(1);
  }

  if (!(await runStep('Flutter test', 'flutter', { args: ['test', '--coverage'] }))) {
    log(red('\n❌ Preflight FAILED at: Flutter test'));
    log(yellow('   Hint: Run `flutter test` locally to debug'));
    await writeSummary();
    process.exit(1);
  }

  if (!FLAGS.quick) {
    if (!(await runStep('Flutter build web', 'flutter', { 
      args: ['build', 'web', '--release'] 
    }))) {
      log(red('\n❌ Preflight FAILED at: Flutter build web'));
      await writeSummary();
      process.exit(1);
    }
  } else {
    log(dim('⏩ Skipping Flutter build web (--quick mode)'));
  }

  // Step 3: Functions checks
  banner('Functions Checks');

  const functionsDir = join(ROOT, 'functions');
  
  if (!(await runStep('Functions npm ci', 'npm', { 
    args: ['ci'], 
    cwd: functionsDir 
  }))) {
    log(red('\n❌ Preflight FAILED at: Functions npm ci'));
    await writeSummary();
    process.exit(1);
  }

  const lintArgs = FLAGS.fix ? ['run', 'lint', '--', '--fix'] : ['run', 'lint'];
  if (!(await runStep('Functions lint', 'npm', { 
    args: lintArgs, 
    cwd: functionsDir 
  }))) {
    log(red('\n❌ Preflight FAILED at: Functions lint'));
    log(yellow('   Hint: Try `npm run lint --fix` in functions/'));
    await writeSummary();
    process.exit(1);
  }

  if (!(await runStep('Functions test', 'npm', { 
    args: ['test', '--silent'], 
    cwd: functionsDir 
  }))) {
    log(red('\n❌ Preflight FAILED at: Functions test'));
    log(yellow('   Hint: Run `npm test` in functions/ to debug'));
    await writeSummary();
    process.exit(1);
  }

  // Step 4: Security rules & E2E
  banner('Security Rules & E2E Tests');

  const securityDir = join(ROOT, 'test', 'security');
  
  if (!FLAGS.quick && !FLAGS.noEmulators) {
    // Full E2E with emulators and Playwright
    log(bold('Running full E2E suite with emulators...'));
    
    const emulatorsCmd = `firebase emulators:exec --project demo-test --only firestore,auth,storage "cd test/security && npm ci && npm run test:rules && npx playwright install --with-deps && npx playwright test --config=playwright.smoke.config.ts"`;
    
    if (!(await runStep('E2E with emulators', 'bash', {
      args: ['-c', emulatorsCmd],
    }))) {
      log(red('\n❌ Preflight FAILED at: E2E with emulators'));
      await writeSummary();
      process.exit(1);
    }
  } else {
    // Quick mode: just security rules
    log(dim('⏩ Quick mode: running security rules tests only'));
    
    if (existsSync(securityDir)) {
      if (!(await runStep('Security rules test', 'npm', {
        args: ['run', 'test:rules'],
        cwd: securityDir,
      }))) {
        log(red('\n❌ Preflight FAILED at: Security rules test'));
        await writeSummary();
        process.exit(1);
      }
    } else {
      log(yellow('⚠ test/security not found, skipping'));
    }
  }

  // Success!
  await writeSummary();
  
  banner('✅ PREFLIGHT PASSED');
  log(green(bold('All checks passed! Safe to push.')));
  log(dim(`\nLogs: ${LOG_DIR}`));
  log(dim(`Summary: ${SUMMARY_PATH}`));
  log('');

  process.exit(0);
})().catch(async (err) => {
  log(red(`\n❌ FATAL ERROR: ${err.message}`));
  log(red(err.stack));
  
  await writeSummary();
  
  banner('❌ PREFLIGHT FAILED');
  log(red('Fix errors above and retry.'));
  log(dim(`\nLogs: ${LOG_DIR}`));
  log(dim(`Summary: ${SUMMARY_PATH}`));
  
  process.exit(1);
});
