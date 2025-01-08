import times

proc logstamp() =
  var line: string
  while stdin.readLine(line):
    let timestamp = now().format("yyyy-MM-dd HH:mm:ss")
    echo "[", timestamp, "] ", line

when isMainModule:
  logstamp()
