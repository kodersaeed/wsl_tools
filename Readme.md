# WSL Tools for Easy Dev Environment

**This script only works on Ubuntu 24.04 LTS, 22.04 LTS, 20.04 LTS and 18.04 LTS**
 
Features of this Tools:

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

1. Go to your home dir

    `cd ~`

2. Clone this Repo:

    `sudo git clone https://github.com/kodersaeed/wsl_tools.git`

3. Chmod recursively to make all files executeable in Repo.

    `sudo chmod -R +x ~/wsl_tools`

4. Create an Alias for the tools:

    `alias wsl_tools='sudo bash ~/wsl_tools/wsl_tools'` 

#### That's it. You can Always access the tools by this command:

`wsl_tools`

