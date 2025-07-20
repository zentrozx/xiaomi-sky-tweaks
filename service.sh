#!/system/bin/sh
sleep 10
# Set scheduler for mmcblk1
echo mq-deadline > /sys/block/mmcblk1/queue/scheduler 2>/dev/null

# Set scheduler to 'none' for sd[a-f]
for d in a b c d e f; do
  DEV="/sys/block/sd$d/queue/scheduler"
  [ -w "$DEV" ] && echo none > "$DEV"
done

# Disable iostats for mmcblk1
[ -w /sys/block/mmcblk1/queue/iostats ] && echo 0 > /sys/block/mmcblk1/queue/iostats

# Disable iostats for sd[a-f]
for d in a b c d e f; do
  P="/sys/block/sd$d/queue/iostats"
  [ -w "$P" ] && echo 0 > "$P"
done

sleep 10

sysctl vm.swappiness=20


for POL in 0 6; do
  W="/sys/devices/system/cpu/cpufreq/policy$POL/walt"

  # adaptive_high_freq
  chmod 644 "$W/adaptive_high_freq" 2>/dev/null
  echo 0 > "$W/adaptive_high_freq" 2>/dev/null
  chmod 444 "$W/adaptive_high_freq" 2>/dev/null

  # hispeed_freq
  chmod 644 "$W/hispeed_freq" 2>/dev/null
  echo 0 > "$W/hispeed_freq" 2>/dev/null
  chmod 444 "$W/hispeed_freq" 2>/dev/null

  # hispeed_load
  chmod 644 "$W/hispeed_load" 2>/dev/null
  echo 95 > "$W/hispeed_load" 2>/dev/null
  chmod 444 "$W/hispeed_load" 2>/dev/null

  # up_rate_limit_us
  chmod 644 "$W/up_rate_limit_us" 2>/dev/null
  echo 9500 > "$W/up_rate_limit_us" 2>/dev/null
  chmod 444 "$W/up_rate_limit_us" 2>/dev/null
done