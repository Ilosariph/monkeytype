// Fork change (charachorder): anticheat is always bypassed, regardless of
// BYPASS_ANTICHEAT, so results are accepted without validation (no wpm cap).
const hasAnticheatImplemented = true;

import { CompletedEvent, KeyStats } from "@monkeytype/schemas/results";
import Logger from "../utils/logger";

export function implemented(): boolean {
  if (hasAnticheatImplemented) {
    Logger.warning("BYPASS_ANTICHEAT is enabled! Running without anti-cheat.");
  }
  return hasAnticheatImplemented;
}

export function validateResult(
  _result: object,
  _version: string,
  _uaStringifiedObject: string,
  _lbOptOut: boolean,
): boolean {
  Logger.warning("No anticheat module found, result will not be validated.");
  return true;
}

export function validateKeys(
  _result: CompletedEvent,
  _keySpacingStats: KeyStats,
  _keyDurationStats: KeyStats,
  _uid: string,
): boolean {
  Logger.warning("No anticheat module found, key data will not be validated.");
  return true;
}
