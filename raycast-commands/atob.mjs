#!/usr/bin/env node
// @ts-check

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Decode Base64
// @raycast.mode fullOutput

// Optional parameters:
// @raycast.icon 🤖
// @raycast.packageName Snippets

import { execSync, spawnSync } from "child_process";

const s = execSync("pbpaste").toString();

console.log("before:", s);

const result = Buffer.from(s, "base64").toString();

console.log("after:", result);

spawnSync("pbcopy", { input: result });
