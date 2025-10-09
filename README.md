# Installation Scripts
These are bash scripts I created to setup my kali VM automatically. I have tried to make it as automated as possible which means I have probably repeated commands unnecessary (like apt-get --fix-broken) just to avoid as many errors as possible. More tools will be added and I am very selective about them. Feel free to copy the code and modify it according to your setup. 

The script installs packages through apt-get one by one using loop because installing many packages at a same time can lead to errors even if one of them is missing or faulty. Missing package shouldn't affect rest of the installation unless it is a missing major dependencies so lets just hope kali repository doesn't remove them. Sadly, apt doesn't allow concurrent installations and I couldn't think of a wayaround.

For others (such as using git or go), the commands are run concurrently (5 commands at a time) to optimize the speed and efficiency. There can be more optimization tweaks in future, if required. Since the commands are run concurrently, the output on terminal is mixture of them and I prefer that over implementing better error handling logic. 

I have used python virtual environments and aliases wherever possible. I prefer cloning from github (than apt) for many tools so it can be updated more frequently.

Currently, this has a very basic and flawed error detection-kind of thing. If a command fails to execute (for whatever reason), it is added to a log file so it can be reviewed later. If a package is already installed it will cause a false point entry into the log file. I do not require proper error handling for my purpose (yet) but I may implement it later, if required.

Script order=> utilities.sh -> tools.sh -> wordlists.sh -> gnome-gui.sh