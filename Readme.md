# WSL/Ubuntu Tools for Easy Dev Environment

**This script only works on Ubuntu 24.04 LTS, 22.04 LTS, 20.04 LTS and 18.04 LTS. works both on Ubuntu installed in WSL 2 and native Ubuntu.**

Think of this tool as something similar to **Laravel Valet** but for Ubuntu.

**Why Only Ubuntu?**

Because Ubuntu is the most popular Linux distro used in servers and even **Ploi.io** or **Laravel Forge** requires Ubuntu on the server.

So this tool gives you something like a little **Ploi.io** or **Laravel Forge** experience but for your local dev environment.

## Requirements

* Ubuntu **24.04 LTS**, **22.04 LTS**, **20.04 LTS** and **18.04 LTS** either installed in WSL 2 or native Ubuntu.
  
## Features of this Tools:

* **Install Stacks in 1 Step**
    * PHP - All Versions (8.4, 8.3, 8.2, 8.1, 8.0, 7.4, 7.3, 7.2, 7.1, 7.0, 5.6)
    * Composer
    * Nginx
    * MYSQL 8.0
    * Nodejs, NPM, Yarn
    * Redis Server
    * Memcached
* **PHP Tools**
    * Change PHP CLI Version
    * Change PHP Version for vHost
    * Update MAX POST/UPLOAD Size in PHP.ini
* **Nginx Tools**
    * Create vHost & Enable it (Laravel/PHP, Vue/Static, NuxtJS SSR)
    * Remove vHost (Delete from sites-available & sites-enabled)
    * Enable a vHost (Symlink from sites-available TO sites-enabled)
    * Disable a vHost (Remove from sites-enabled)

## How to Install

1. Go to your home directory:

    `cd ~`

2. Clone this repo:

    `git clone https://github.com/kodersaeed/wsl_tools.git`

3. Chmod recursively to make all files executeable in repo:

    `chmod -R +x ~/wsl_tools`

4. Create an alias for the tools:

    `alias wsl_tools='sudo bash ~/wsl_tools/wsl_tools'` 

#### That's it. You can Always access the tools by this command:

`wsl_tools`

