#!/system/bin/sh

# Initial I/O tuning (early boot-safe)
sleep 5
echo mq-deadline > /sys/block/mmcblk1/queue/scheduler 2>/dev/null
for d in a b c d e f; do
  DEV="/sys/block/sd$d/queue/scheduler"
  [ -w "$DEV" ] && echo none > "$DEV"
done
[ -w /sys/block/mmcblk1/queue/iostats ] && echo 0 > /sys/block/mmcblk1/queue/iostats
for d in a b c d e f; do
  P="/sys/block/sd$d/queue/iostats"
  [ -w "$P" ] && echo 0 > "$P"
done

# ✅ Defer the rest until after boot completes (like post-init)
(
  sleep 45  # give system plenty of time to settle

  # Set swappiness
  [ -w /proc/sys/vm/swappiness ] && echo 20 > /proc/sys/vm/swappiness

  # Apply WALT params on policy0 and policy6
  for POL in 0 6; do
    W="/sys/devices/system/cpu/cpufreq/policy$POL/walt"

    [ -d "$W" ] || continue

    chmod 644 "$W/adaptive_high_freq" 2>/dev/null
    echo 0 > "$W/adaptive_high_freq" 2>/dev/null
    chmod 444 "$W/adaptive_high_freq" 2>/dev/null

    chmod 644 "$W/hispeed_freq" 2>/dev/null
    echo 0 > "$W/hispeed_freq" 2>/dev/null
    chmod 444 "$W/hispeed_freq" 2>/dev/null

    chmod 644 "$W/hispeed_load" 2>/dev/null
    echo 95 > "$W/hispeed_load" 2>/dev/null
    chmod 444 "$W/hispeed_load" 2>/dev/null

    chmod 644 "$W/up_rate_limit_us" 2>/dev/null
    echo 9500 > "$W/up_rate_limit_us" 2>/dev/null
    chmod 444 "$W/up_rate_limit_us" 2>/dev/null
  done
) &  # background it so it doesn't block boot