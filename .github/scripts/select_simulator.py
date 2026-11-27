#!/usr/bin/env python3
"""Print one available iPhone simulator UUID compatible with the active Xcode SDK."""

import json
import re
import subprocess
import sys


def version_tuple(value):
    return tuple(int(part) for part in re.findall(r"\d+", value))


def select_simulator(devices, sdk_version):
    candidates = []
    for runtime, runtime_devices in devices.items():
        if not runtime.startswith("com.apple.CoreSimulator.SimRuntime.iOS-"):
            continue
        version = version_tuple(runtime.split(".iOS-", 1)[1])
        if version < (18,) or version > version_tuple(sdk_version):
            continue
        for device in runtime_devices:
            if device.get("isAvailable") and device.get("name", "").startswith("iPhone"):
                candidates.append((version, device["name"], device["udid"]))
    if not candidates:
        raise RuntimeError("No available iPhone simulator for iOS 18+ matches the active Xcode SDK.")
    return max(candidates)[2]


def main():
    sdk_version = subprocess.check_output(
        ["xcrun", "--sdk", "iphonesimulator", "--show-sdk-version"], text=True
    ).strip()
    devices = json.loads(subprocess.check_output(
        ["xcrun", "simctl", "list", "devices", "available", "--json"], text=True
    ))["devices"]
    print(select_simulator(devices, sdk_version))


if __name__ == "__main__":
    try:
        main()
    except (KeyError, ValueError, RuntimeError, subprocess.CalledProcessError) as error:
        print(f"Simulator selection failed: {error}", file=sys.stderr)
        sys.exit(1)
