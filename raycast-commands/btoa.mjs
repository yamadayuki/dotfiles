#!/usr/bin/env node
// @ts-check

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Encode Base64
// @raycast.mode fullOutput

// Optional parameters:
// @raycast.icon 🤖
// @raycast.packageName Snippets

import { execSync, spawnSync } from "child_process";

const s = execSync("pbpaste").toString();

console.log("before:", s);

const result = Buffer.from(s).toString("base64");

console.log("after:", result);

spawnSync("pbcopy", { input: result });
