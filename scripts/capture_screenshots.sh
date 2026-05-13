#!/usr/bin/env bash

set -euo pipefail

package_name="${1:-fr.foyerrural.stbonnettronc}"
screens_dir="docs/screens"

mkdir -p "${screens_dir}"
find "${screens_dir}" -maxdepth 1 -type f -name '*.png' -delete
touch "${screens_dir}/.gitkeep"

adb shell am force-stop "${package_name}" >/dev/null 2>&1 || true
adb shell monkey -p "${package_name}" -c android.intent.category.LAUNCHER 1 >/dev/null
sleep 5

size_line="$(adb shell wm size | tr -d '\r' | sed -nE 's/.*Physical size: ([0-9]+)x([0-9]+).*/\1 \2/p' | tail -n 1)"
if [[ -z "${size_line}" ]]; then
  echo "Failed to read emulator screen size" >&2
  exit 1
fi

read -r width height <<<"${size_line}"
nav_y=$((height - height / 24))
tab_y=$((height / 7))
first_card_y=$((height / 4))
center_x=$((width / 2))

tap_nav() {
  local slot="$1"
  local x=$(((width * (slot * 2 + 1)) / 10))
  adb shell input tap "${x}" "${nav_y}" >/dev/null
  sleep 2
}

shot() {
  local name="$1"
  sleep 1
  adb exec-out screencap -p > "${screens_dir}/${name}.png"
}

shot "01_home"
tap_nav 1
shot "02_records"
adb shell input tap "${center_x}" "${first_card_y}" >/dev/null
sleep 2
shot "03_record_detail"
adb shell input keyevent KEYCODE_BACK >/dev/null
sleep 1
tap_nav 2
shot "04_containers"
adb shell input tap $((width * 3 / 4)) "${tab_y}" >/dev/null
sleep 2
shot "05_equipment"
tap_nav 3
shot "06_revenue"
tap_nav 4
shot "07_settings"

printf 'Captured %s screenshots in %s\n' "$(find "${screens_dir}" -maxdepth 1 -type f -name '*.png' | wc -l)" "${screens_dir}"
