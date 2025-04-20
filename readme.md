# Personal MacOS configuration

![banner](./assets/banner.png)

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

