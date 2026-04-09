#!/usr/bin/env node

'use strict';

const { parse, stringify, CommentArray } = require('./vendor/comment-json.bundle.js');
const fs = require('fs');

// Copy all five property-level comment Symbols for a key from src to dst.
const PROP_PREFIXES = ['before', 'after-prop', 'after-colon', 'after-value', 'after'];
function copyPropSymbols(src, dst, key) {
    for (const prefix of PROP_PREFIXES) {
        const sym = Symbol.for(`${prefix}:${key}`);
        if (src[sym] !== undefined) dst[sym] = src[sym];
    }
}

// Deep equality on data only — ignores Symbol (comment) properties.
function dataEqual(a, b) {
    return JSON.stringify(a) === JSON.stringify(b);
}

function isPlainObject(v) {
    return v !== null && typeof v === 'object' && !Array.isArray(v);
}

function deepMerge(target, update) {
    if (Array.isArray(target) && Array.isArray(update)) {
        // Set-union matching jq logic: (target entries NOT in update) + (all of update).
        // Entries present in both are represented by update's copy (preserving update order).
        const targetOnly = target.filter(t => !update.some(u => dataEqual(u, t)));
        const result = new CommentArray();

        // Copy container Symbols (before-all, after-all, etc.): target first, update wins.
        for (const sym of Object.getOwnPropertySymbols(target)) result[sym] = target[sym];
        for (const sym of Object.getOwnPropertySymbols(update)) result[sym] = update[sym];

        for (let i = 0; i < targetOnly.length; i++) {
            const origIdx = target.indexOf(targetOnly[i]);
            result.push(targetOnly[i]);
            copyPropSymbols(target, result, origIdx);
        }
        for (let i = 0; i < update.length; i++) {
            result.push(update[i]);
            copyPropSymbols(update, result, i);
        }
        return result;
    }

    if (isPlainObject(target) && isPlainObject(update)) {
        const result = {};

        // Non-property container Symbols (before-all, after-all, before, after):
        // target first, then update overwrites — so update wins on any overlap.
        for (const sym of Object.getOwnPropertySymbols(target)) result[sym] = target[sym];
        for (const sym of Object.getOwnPropertySymbols(update)) result[sym] = update[sym];

        // Keys: target order first, then new-from-update appended.
        const targetKeys = Object.keys(target);
        const updateKeys = Object.keys(update);
        const allKeys = [...targetKeys, ...updateKeys.filter(k => !targetKeys.includes(k))];

        for (const key of allKeys) {
            const inTarget = Object.prototype.hasOwnProperty.call(target, key);
            const inUpdate = Object.prototype.hasOwnProperty.call(update, key);
            if (inTarget && inUpdate) {
                result[key] = deepMerge(target[key], update[key]);
                copyPropSymbols(update, result, key);
            } else if (inUpdate) {
                result[key] = update[key];
                copyPropSymbols(update, result, key);
            } else {
                result[key] = target[key];
                copyPropSymbols(target, result, key);
            }
        }
        return result;
    }

    // Scalar conflict: update wins.
    return update;
}

function warn(msg) {
    process.stderr.write(`⚠️  Warning: ${msg}\n`);
}

const updateFile = process.argv[2];
const targetFile = process.argv[3];

try {
    // Read update file — an unreadable update file is a no-op (nothing to merge).
    let updateText;
    try {
        updateText = fs.readFileSync(updateFile, 'utf8');
    } catch (e) {
        warn(`Could not read update file, skipping merge.\n   Update file: ${updateFile}\n   ${e.message}`);
        process.exit(0);
    }

    // Parse update — empty or invalid JSONC is a no-op.
    let updateObj;
    try {
        updateObj = parse(updateText);
    } catch (e) {
        warn(`Update file is not valid JSONC, skipping merge.\n   Update file: ${updateFile}\n   ${e.message}`);
        process.exit(0);
    }
    if (updateObj == null) process.exit(0);

    // Read and parse target — missing or empty target gets update written directly.
    let targetObj = null;
    try {
        const targetText = fs.readFileSync(targetFile, 'utf8');
        try {
            targetObj = parse(targetText);
        } catch (e) {
            warn(`Target file is not valid JSONC, it will be overwritten with the update.\n   Target file: ${targetFile}\n   ${e.message}`);
        }
    } catch (e) {
        if (e.code !== 'ENOENT') {
            warn(`Could not read target file, it will be overwritten with the update.\n   Target file: ${targetFile}\n   ${e.message}`);
        }
        // ENOENT (file does not exist) is the normal "first run" case — no warning needed.
    }

    // Merge and write.
    const output = stringify(targetObj == null ? updateObj : deepMerge(targetObj, updateObj), null, 2) + '\n';
    try {
        fs.writeFileSync(targetFile, output);
    } catch (e) {
        warn(`Could not write target file, settings were not updated.\n   Target file: ${targetFile}\n   ${e.message}`);
        process.exit(0);
    }
} catch (e) {
    warn(`Unexpected error during JSON merge, target file was not modified.\n   Update file:  ${updateFile}\n   Target file:  ${targetFile}\n   ${e.message}`);
    process.exit(0);
}
