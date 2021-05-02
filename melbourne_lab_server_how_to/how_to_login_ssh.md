# Login using SSH
To connect to all our servers, we use the SSH protocol, which is considered the most secure way. The servers are all on the University of Colorado wired network. If you are off campus or on the wireless network, you must first VPN to the University of Colorado network. See OIT help pages for setting up VPN.

## Basic SSH connection

### Linux

**Option 1**
Open a  terminal and type
```bash
ssh <username>@<ipaddress>
```
where `<username>` is your username on the server (e.g. mine is brett), and `<ipaddress>` is the ip address of the server (e.g. melb2 is 128.138.220.251), thus, e.g.
```bash
ssh brett@128.138.220.251
```
* enter your password at the prompt
* you should now be connected to the server and ready to type commands in the terminal

**Option 2**
Use the Putty GUI (follow instructions for Windows option 1 below)
* advantage is that you can store the ip address and session details

### Windows

**Option 1**
The most widely used and trusted application is Putty. Download and install Putty from here:
* http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html 
* I generally only download putty.exe and not the other components.

Open Putty
* Enter the IP address (e.g. melb2 is 128.138.220.251) and leave the default port as 22
* Port 22 is the standard for ssh
* Click Open - a terminal will open with a login prompt
* Enter user name and password

You can save session details so next time you don't need to re-enter the IP address or other details. You can also set up your password manager to enter login details.

**Option 2**
Windows subsystem for linux (WSL)

This is a new Windows 10 feature that runs linux from within windows. It allows you to use a linux terminal from windows. Installation and configuration is in flux but details as of May 2020 here:
* https://docs.microsoft.com/en-us/windows/wsl/install-win10

To connect to the server, open a linux terminal and follow instructions for linux option (1) above.

### Mac
OS X has a built in Terminal application generally found in the Utilities folder in Applications.

**Option 1**
Open Terminal
* Select "New Remote Connection" from the Shell menu
* Enter the IP address and username
* Click Open - a terminal will open with a login prompt
* Enter user name and password

You can save session details so next time you don't need to re-enter the IP address or other details. 

**Option 2**
Open Terminal and follow instructions for linux option (1) above.

**Option 3**
Install an SSH GUI application, such as Putty
* https://www.ssh.com/ssh/putty/mac/
* follow instructions for Windows option (1) above.


## Multiple terminal windows
You can login more than once to have multiple windows.

You can also use screen.
```bash
man screen
```