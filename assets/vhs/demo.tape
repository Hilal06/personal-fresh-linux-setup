# VHS Demo Recording Tape for Personal Fresh Linux Setup
# https://github.com/charmbracelet/vhs

Output assets/demo.gif

Set Shell "bash"
Set FontSize 14
Set Width 1150
Set Height 680
Set Theme "Catppuccin Mocha"
Set Padding 20
Set TypingSpeed 40ms

# Start the interactive setup suite
Type "./linux-setup/setup.sh"
Sleep 600ms
Enter
Sleep 2s

# 1. Language Selection Screen
Sleep 1s
Down 1
Sleep 800ms
Up 1
Sleep 800ms
Enter
Sleep 2.5s

# 2. Main Automation Dashboard
Sleep 1s
Down 1
Sleep 600ms
Down 1
Sleep 600ms
Up 2
Sleep 800ms

# 3. View Quick Presets
Enter
Sleep 2s
Down 1
Sleep 800ms
Down 1
Sleep 800ms
Escape
Sleep 1.5s

# 4. View Shell & Terminal Setup
Down 1
Sleep 600ms
Enter
Sleep 2s
Escape
Sleep 1.5s

# 5. Exit Cleanly
Down 9
Sleep 600ms
Enter
Sleep 2s
