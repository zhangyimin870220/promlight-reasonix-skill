# PromLight Use Cases

## 1. Solo Coding Session
Light flow: Start → Work → Idle → End
- SessionStart: RGB cycle → green solid
- While coding/editing: yellow solid
- Waiting for confirmation: yellow blink
- Errors: red blink
- Task done: green solid
- Session end: green breathing

## 2. Multi-Project Parallel
Two PromLight devices, each assigned to a Reasonix project:
- Project A → Device "Tom"
- Project B → Device "Jerry"
Configure in `devices.json` routes by project directory.

## 3. Pair Programming / Demo
Audience watches light to know agent status:
- Yellow = agent working, don't interrupt
- Yellow blink = agent needs input, look at screen
- Red = something broke, investigate
- Green = all good, review results

## 4. Long-Running Background Task
Start task, walk away:
- Glance at light from across room
- Green breathing = done
- Red blink = check terminal

## 5. Debugging Loop
Fix → test → fail → fix cycle:
- Yellow during edit
- Yellow rapid blink during test run
- Red on test failure
- Yellow on next fix attempt
- Green when all tests pass

## 6. RTK + Caveman Full Mode
Combined with caveman (terse output) and rtk (compressed commands):
- Light still shows real agent state underneath compressed I/O
- Red blink on rtk-detected failures
- Green when rtk gain shows savings accumulating
