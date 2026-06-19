"""PromLight animation engine — loops progress-bar patterns until killed."""
import socket, json, time, sys, signal, os

HOST, PORT = "127.0.0.1", 47800

PATTERNS = {
    # (1)(12)(123)(12) contracting — speeds vary by state
    "think": [  # medium
        ("led green on --only", 0.25),
        ("led yellow on", 0.25),
        ("led red on", 0.25),
        ("led red off", 0.25),
        ("led yellow off", 0.25),
    ],
    "work": [  # fast
        ("led green on --only", 0.12),
        ("led yellow on", 0.15),
        ("led red on", 0.12),
        ("led red off", 0.10),
        ("led yellow off", 0.10),
    ],
    "idle": [  # slow breathing
        ("led green on --only", 2.0),
        ("led yellow on", 2.0),
        ("led yellow off", 2.0),
    ],
    "wait": [  # pulse
        ("led green on --only", 0.3),
        ("led yellow on", 0.5),
        ("led yellow off", 0.3),
    ],
    "alert": [  # urgent fast
        ("led green on --only", 0.10),
        ("led yellow on", 0.10),
        ("led red on", 0.12),
        ("led all off", 0.08),
    ],
    "error": [  # fast panic
        ("led green on --only", 0.08),
        ("led yellow on", 0.08),
        ("led red on", 0.10),
        ("led all off", 0.06),
    ],
}

def send(cmd):
    try:
        s = socket.create_connection((HOST, PORT), timeout=0.3)
        s.sendall(json.dumps({"cmd": cmd, "message": "anim"}).encode() + b"\n")
        s.close()
    except Exception:
        pass

def run(pattern_name):
    frames = PATTERNS.get(pattern_name)
    if not frames:
        return
    while True:
        for cmd, delay in frames:
            send(cmd)
            time.sleep(delay)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: promlight_anim.py <think|work|idle|wait|alert|error>")
        sys.exit(1)
    # Ignore SIGTERM for clean kill
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
    run(sys.argv[1])
