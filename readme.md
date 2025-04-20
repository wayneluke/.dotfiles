![banner](./assets/banner.png)
# Personal MacOS "Zorya" configuration

## Why Zorya

The Zorya (sometimes spelled Zarya or Zore) are Slavic star goddesses, often appearing as two or three sisters associated with the sky, light, and time. In some legends, the Zorya sisters guard the doomsday hound, Simargl, who is chained to the constellation Ursa Minor. If the chain breaks, the universe ends. Each Zorya takes a shift watching the beast — this myth frames the daily cycle of sunrise, sunset, and midnight as a divine act of cosmic protection.


## Command Line Options

- dry-run: Allows a test run of the script.
    - example: ./install.sh --dry-run
- script: Run one or more scripts fron the install directory.
    - example: ./install.sh --script setup.sh --script install_fonts.sh
- no-script: Skip all scripts in the install directory
- verbose: Copy files in verbose mode for more information.
    - example: ./install.sh --verbose
- log: Direct output to a different log file from install.log
    - example: ./install.sh --log <filename>
    
These options can be mix and matched except, script and no-script cancel each other out.
