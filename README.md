# 📖 Documentation

**🌐 Languages:** 🇬🇧 [English](README.md) • 🇮🇷 [فارسی](README-FA.md)
If you look at any mobile phone today, you'll find a swarm of VPN apps, several of which are reported as spyware every month. The risk of infection and compromising your phone's data—which serves as our bridge to the outside world for everything from banking and shopping to entertainment and gaming—is far too great to ignore. If you have more devices connected to the internet than fingers on one hand where you live or work, the effort behind this guide (explained in very straightforward language) is well worth it.

A config seller's small customer base, straightforward service setup, official and open-source clients, and minimal required capital significantly lower a customer's VPN risks on paper compared to an untrusted app. However, isolating the system and running the VPN on a dedicated computer with secure firewall settings protects your devices and data even further. You will no longer need to install VPN apps on your phone. Phone resources won't be wasted, and your security won't be compromised.

In our building, a single unlimited configuration powers more than forty devices. Look at it from any angle, and building this router is worth it.

Years ago, I wrote a guide explaining how you can turn an old computer into a powerful, advanced router. Today, we are taking that same setup several steps further. Network restrictions on one side and blocked external services on the other have left everyone exhausted. I won't waste any more of your time dwelling on these difficulties—let's jump straight to the core topic.

At the end, by building a simple app for Android and iOS, we will give users the ability to route their connection through the VPN on the router or establish a direct connection to use domestic services. That said, we use `ip rule` to connect the entire Iranian IP range directly to the ISP. In any case, this capability remains in your hands as the network administrator and in the hands of the users.

Although we are set to do big things, simply being familiar with a computer and keyboard is enough for us to learn a lot together. So don't be afraid—you can definitely handle it.

## Required Hardware

For this setup, you need an old computer or a mini-PC with at least two network ports. It is best if the network ports are Gigabit. Desktop computers can usually be upgraded using an expansion card, but if using a mini-PC, ensure it has two built-in ports. If you are using a USB-to-Gigabit Ethernet adapter, make sure it has native Linux kernel support. You can even use a laptop and its Wi-Fi interface, but this tutorial does not cover configuring Wi-Fi as an access point. For very small networks where a laptop's Wi-Fi could replace an access point, it is better to look at other projects.

**Access Point:** An access point's job is to distribute the internet connection received from the computer above. An access point is usually a more cost-effective choice than a router, but if you want an all-in-one device, a router might be a better option. Of course, in this configuration, we set the router to access point mode as well. Even an old modem can act as an access point. Simply disable its DHCP engine from its web console and change the device's IP address to a subnet of the network we are building.

**Graphics Card:** You don't need one at all. My server is headless, meaning I only communicate with it through another device. No inputs, no outputs (other than the network cable)—the sole communication is via SSH. You only need to borrow a graphics card, keyboard, and monitor from your primary system for a few minutes for BIOS settings and setting the initial root password. The advantages of not having a graphics card outweigh having one: far lower power consumption.

What if we want to use this router to stream movies and series? Modern TVs and mobile phones almost all support DLNA. This means you don't need a graphics card even to play movies and music stored on the server—simply connect to the router's network to access all media on the server. That means a TV or phone on the fourth floor can stream movies stored on the server on the first floor in high quality.

That's all there is to it.

## Operating System

In keeping with our previous approach, we will use Arch Linux. I didn't choose Arch Linux out of mere preference; Arch is simply everything we need:

* It is straightforward to install remotely.
* It is stable. My previous computer spent almost its entire lifespan on a single Arch installation. A single Arch installation lasted nearly a decade on my old system.
* It is lightweight. It contains only the packages you need. You even install basic packages like `nano` or `sudo` yourself.
* It is fast and runs smoothly even on very low-spec systems.

This project also includes an easy installation script so that after installing the base OS, you can easily configure the entire system with it in just a few short minutes.

## Roadmap

1. Prepare the hardware.
2. Download Arch Linux and write it to a USB flash drive.
3. Install Arch.
4. Install essential tools such as `nftables`, `dnsmasq`, and `ssh` for basic operation.
5. Install CLI-based circumvention tools such as OpenVPN and WireGuard.
6. Optimally split traffic based on geographic location.
7. Install and configure DNS circumvention tools such as Dnscrypt Proxy.
8. Configure `tc` for traffic management among users.
9. Create scripts to automate tasks like backups.
10. Build a small PWA app for users to toggle the VPN on and off.
    * *Note:* For the app and dedicated DoH, it is best to register a domain. If you have an Iranican account, register a cheap `.ir` domain. If not, get a $1 domain from websites that support cryptocurrency payments. While this step is optional, it is important for running the app smoothly and without errors on mobile devices.
11. Build a diagnostic tool for troubleshooting when the system is unresponsive.
    * *Note:* Set aside the cheapest low-capacity USB flash drive you can find for this purpose. It will turn into an interesting device.

**Idea:** You can install this router onto a USB flash drive. That way, it won't require a hard drive, and troubleshooting becomes exceptionally easy. Simply plug the flash drive into the back of your primary system and boot it for diagnostics. The downside lies in the flash drive's lifespan, as flash drives are not built for frequent writes. The solution is somewhat complex and time-consuming, but generally, you can mount most directories as read-only and load high-write system directories into RAM (you will need at least 4 GB of RAM). I will leave the explanation of how to set that up for another post.

If you look at any mobile phone today, you'll find an abundance of VPN apps, with several reported as spyware every month. The risk of infection and compromising your phone's data—which serves as our gateway to the outside world for everything from banking and markets to entertainment and gaming—is far too great to ignore. If you have more internet-connected devices at your home or workplace than fingers on one hand, the effort required for this guide (which is explained in very straightforward language) is well worth it.

A config seller's limited customer base, straightforward service setup, official and open-source clients, and minimal required capital significantly lower the theoretical risks of a VPN for a customer compared to a random app. However, isolating the system and running the VPN on a dedicated computer with secure firewall settings will make your devices and data even more secure. You will no longer need to install a VPN app on your phone. Your phone's resources won't be wasted needlessly, and your security won't be ruined.

In our building, a single unlimited configuration feeds more than forty devices. Look at it from any angle, and building this router is worth it.

Years ago, I wrote a guide explaining how to turn an old computer into a powerful, advanced router. Today, we are taking that same setup several steps further. Network restrictions on one side and blocked external services on the other have left everyone exhausted. I won't waste any more of your time explaining this misery—let's jump straight to the point.

At the end, by building a simple app for Android and iOS, we will give users the ability to route their connection through the VPN on the router or establish a direct connection to use domestic services. That said, we use `ip rule` to route the entire Iranian IP range directly to the ISP. In any case, this capability remains in the hands of the user and you as the network administrator.

Although we are going to do big things, simply being familiar with a computer and keyboard is enough for us to learn a lot together. So don't be afraid—you can definitely handle it.

## Required Hardware

For this task, you need an old computer or a mini-PC with at least two network ports. It is best if the network ports are Gigabit. Desktop computers can usually make do with an expansion card, but if using a mini-PC, ensure it definitely has two ports. If you are using a USB-to-Gigabit Ethernet adapter, make sure it has native Linux kernel support. You can even use a laptop and a Wi-Fi network, but this tutorial does not cover configuring Wi-Fi as an access point. For very small networks where a laptop's Wi-Fi could act as an access point, it is better to look at other projects.

**Access Point:** The access point's job is to broadcast the internet received from the computer above. An access point is usually a more cost-effective choice than a router, but if you want an all-in-one device, a router might be a better option. Of course, in this setup, we will also put the router in access point mode. Even an old modem can play the role of an access point. Simply disable its DHCP engine from within the console and change the device's IP address to a subnet of the network we are building.

**Graphics Card:** You don't need one at all. My server is headless. This means I only communicate with it through another device. No input, no output (other than the network cable)—the only connection is via SSH. You only need to borrow a graphics card, keyboard, and monitor from your main system for a few minutes for BIOS settings and the initial root password. The advantage of lacking a graphics card outweighs having one: significantly lower power consumption.

What if we want to use this router to stream movies and series? Modern TVs and mobile phones almost all support DLNA. This means you don't even need a graphics card to play movies and songs stored on the server—simply being connected to the router's network is enough to access all the multimedia on the server. This means even a TV or phone on the fourth floor can watch movies on the server on the first floor in the highest quality.

That's all.

## Operating System

Following our past style, we are going to use Arch Linux. I didn't choose Arch Linux out of mere interest; rather, Arch is exactly everything we need:

*   Installing it remotely is very simple.
*   It is stable. My previous computer spent almost its entire life with a single Arch installation. One Arch installation lasted nearly a decade on my old system.
*   It is lightweight. It only contains the packages you need. You even install basic packages like `nano` or `sudo` yourself.
*   It is fast and runs very well even on very weak systems.

This project also includes an easy-install script so that after installing the base operating system, you can easily use it to handle the entire system configuration in just a few short minutes.

## Roadmap

1.  Prepare the hardware.
2.  Download Arch Linux and write it to a USB flash drive.
3.  Install Arch.
4.  Install necessary tools like `nftables`, `dnsmasq`, and `ssh` for initial operation.
5.  Install CLI-based circumvention tools like OpenVPN and WireGuard.
6.  Highly optimized traffic splitting based on geographic location.
7.  Install and configure DNS circumvention tools like Dnscrypt Proxy.
8.  Configure `tc` to manage traffic among users.
9.  Create several scripts to automate tasks like backups.
10. Build a small PWA app for users to toggle the VPN on and off.
    *Note: For the app and dedicated DoH, it is best to register a domain. If you are an NIC.ir member, get a cheap `.ir` domain. If not, get a one-dollar domain from sites that allow cryptocurrency payments. This step is not mandatory, but it is important for the app to run flawlessly and without errors on mobile.*
11. Build a diagnostic tool for troubleshooting when the system becomes unresponsive.
    *Note: Set aside the cheapest, lowest-capacity USB flash drive you can find for this. It will become an interesting device.*

*Idea:* You can install this router on a USB flash drive. In this case, it won't need a hard drive, and troubleshooting becomes incredibly easy. Simply plug the flash drive into the back of your main system and boot the system for troubleshooting. The problem lies in the flash drive's lifespan. Flash drives are not built for frequent writes. The solution is slightly complex and time-consuming, but generally, you can mount most directories as read-only and load directories that the OS writes to frequently into RAM (you will need at least 4 GB of RAM). I will postpone explaining how to do this to another post.

# Building the Router

## BIOS
Borrow a graphics card and boot up the old computer. Enter the BIOS settings. By default, during `POST` or initial boot, if your computer encounters an error—like a missing keyboard—it will halt the boot process and prompt the user to fix the issue. A computer running without a graphics card or keyboard will definitely throw an error during `POST`. Look for an option similar to `Halt on Errors` in the BIOS settings and change it to `None` or `Disable`. From this point on, the system will ignore errors and continue the boot sequence.

Visit the `Health` section and ensure that the `CPU` and other components are running cool.

Navigate to `Boot Sequences` and make sure your first priority is `USB Storage`, with your hard disk set as the second priority.

If the BIOS security settings are set to `UEFI`, change it to `Legacy`.

Go to the Power Management section and find an option similar to Restore AC Power Loss. It usually offers 3 selectable options. Select Power On. This ensures that whether you intentionally shut down the computer before a power outage, or power is suddenly lost, the computer will automatically power on and boot the operating system once power is restored. This is the optimal configuration for our router-computer. 

The BIOS configuration is mostly complete; press `F10`, confirm your changes, and exit.

## Access Point (AP)
If you have an old ADSL modem, it will come in handy now. Power it on and connect to it using a phone or computer. Enter the console IP address in your browser to access the modem settings. Look for an option like `DHCP engine` in the `LAN` settings and disable it. 

You should also find an option on the same page to change/assign the modem's own IP address. If it is set to automatic, disable that and assign it a static IP within the `172.22.0.1/24` range—for example, `172.22.0.120`. While the modem will ultimately receive an IP from our router, assigning this specific address ensures we can ping it later to verify accessibility. We can also use this address to log back into the modem's console. If necessary, go to the security settings section and change the wireless password. 

Once you are sure of the settings, save them through the menu and restart the modem if prompted. At this point, you will lose your connection to the modem until you connect it to the router. To establish that connection, simply plug one of its network ports into the router. If you encounter any issues, use the physical `Reset` button to revert the modem to its factory settings and repeat the process.

If you are using a standard wireless router, navigate to the `Administration` section and then to `Operation Mode` (or similar). Look for the `AP` or `Access Point(AP) mode` option and enable it. Set a strong password for the `wlan` and you are done. From now on, this router functions purely as an access point, leaving all the routing heavy lifting to our main Arch Linux machine.

When you connect a network port from the router or modem to Arch, the remaining ports can distribute the internet connection. Consequently, your modem or access point can also act as a switch—though purchasing an unmanaged gigabit switch is a smart move if our router needs to feed multiple different `AP`s. However, you can always expand the system over time.

## Downloading Arch
Download the latest `x86_64` version of Arch Linux from the link below (a suitable mirror for downloading from Iran):
```text
https://mirror.mobinhost.com/archlinux/iso/2026.07.01/archlinux-x86_64.iso
```
Download from Fastly:
```text
https://fastly.mirror.pkgbuild.com/iso/2026.07.01/archlinux-x86_64.iso
```

> Note: If your system is not `x86_64`, you likely already know which version to download; otherwise, this exact version is right for you.

## Preparing for Installation
Using a tool like [Rufus](https://github.com/pbatard/rufus/releases/download/v4.15/rufus-4.15.exe), write the Arch `iso` file to your USB flash drive as a `bootable` disk. It is best to set the `Target System` to `BIOS`. If you are currently using Linux, my best experience has been with the [Popsicle](https://github.com/pop-os/popsicle) utility, which you can install via your distribution's repository.

Make sure to connect the computer to the internet using an Ethernet cable.

Insert the flash drive into the system. If the graphics card is still installed, monitor the boot process. It takes about a minute to boot into the Arch live environment. If you only have one monitor, don't worry—our Arch system will not need a monitor from now on. Just before you completely run it headless, execute the following command and take a picture of the output:
```bash
ip addr show
```
> Note: Pay special attention to spaces when typing commands, as spaces are processed as part of the command in the Linux terminal. Additionally, most standard commands are written in lowercase, and the command line of Unix-like operating systems (like Linux) is case-sensitive. Therefore, `ls` is not the same as `LS`, and `README.txt` differs from `readme.txt`.

Now that we have verified Arch boots successfully without any errors, our initial work with this machine is done. Power it off using the following command:
```bash
poweroff
```

My network expansion card was a `PCIe x4` interface, but my motherboard only had a single `PCIe x16` slot. It was either the graphics card or the network card. I removed the GPU and installed the network card.

Now, use your phone or personal computer to access your modem's console. Navigate to the `LAN` section and look for an option like `DHCP Static IP Configuration`. Check the picture you took of the `ip addr show` output. You should see a six-part address formatted like `6c:c1:00:25:da:a5`. This is the physical MAC address of your network interface. We will need this address. In the modem's settings, look for an `Add` or `New` button. Enter the MAC address and assign a static `IP` to it within your modem's subnet range. For instance, my modem's subnet is `192.168.100.1/24`, so I assigned the IP `192.168.100.100` to this MAC address. The `24` indicates that in this subnet, the last octet can hold a value between `1` and `254`, while the first 24 bits of the address remain static. We use this exact value because an 8-bit block (or 255 IP addresses) is more than enough for the network we are building.

Power the computer back on. Wait about 1 minute for it to boot into the Arch live environment. In the live environment, `sshd` is running by default, allowing us to connect remotely using a phone or another computer. However, we must first set a password for the `root` user. On the system's keyboard—assuming you have no video output—carefully type the following command and press `Enter`:
```bash
passwd
```
The Arch command line will now prompt you for a password. Type a simple word using only lowercase letters and no numbers. (The reason for avoiding numbers is a topic for the comments). 
For example, a simple password like:
```text
hello
```
After hitting `Enter`, it will ask you to retype the password. Carefully type `hello` a second time, press `Enter`, and you are set.

Open the command line on your personal operating system and run the following command:
> For Android or iOS, you can install Termius. For Windows, use PowerShell.

```bash
ssh root@IP-ADDRESS
```
Replace `IP-Address` with the static IP you configured in the modem's console. Both the Arch machine and the device running this command must be connected to the same network (logically, this is the network broadcasted by your main modem). Simply put, ensure both devices are connected to your main modem.

You will be prompted for confirmation. Type `y` or `yes`. It will then ask for the password. Type `hello`. If you have followed all the steps correctly, you are now logged into the Arch Linux environment. Remote access makes our setup infinitely easier since we will be copying and pasting almost everything going forward.
> Remember that copy and paste is usually executed with `Ctrl+Shift+C` and `Ctrl+Shift+V`. In `Termius`, add the `Paste` button to the top keyboard bar for convenience.

## Starting the Installation
From this point forward, copy the commands and paste them into the terminal you opened while logged into the Arch live environment. You do not need to type anything manually. You only need to change values, such as partition names, if they differ from the ones in my commands. For example, if `sda2` is `sdb2` on your system, simply change the letter `a` to `b`.

Run the following command to synchronize the system clock:
```
timedatectl set-ntp true
```
Now, identify the hard disk:
```
lsblk
```
I recommend dedicating a separate disk for this task. The type of drive does not matter, and given how lightweight the system is, this drive could even be a USB flash drive. The total space this system will occupy is less than 5 GB. The output of the command above will look something like this:
```
lsblk  
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS  
sda      8:0    0 461.6G  0 disk    
├─sda1   8:1    0     2M  0 part    
└─sda2   8:2    0 461.6G  0 part /
```
You will also likely see the installation flash drive and the loop device created by the Arch installer. You can easily identify which drive to use based on the `SIZE`. Note its device variable: for me, it is `sda`.

Next, proceed to partition it:
```
cfdisk /dev/sda
```
If it prompts you to select a partition table type, choose `gpt`.
If there are existing partitions on the disk, assuming **you do not need the data on this disk**, select all of them using the up and down arrow keys and `Delete` them using the left and right keys.
Now, all the disk space will be labeled as `Free`. Use the `Create` option to create a 2 MB partition.
Select it using the up and down keys, and navigate to the `Type` option using the left and right keys. Change its type to `BIOS boot`.
Now, we are left with the rest of the free space. Create a partition with the default size (which is the entire remaining space) and set its `Type` to `Linux filesystem`.
Finally, select `Write`. It will ask for confirmation. Type `yes` and confirm. Select `Quit` to exit `cfdisk`.

You can review the partition structure once more with `lsblk`. Your larger partition, where the operating system will be installed, should be listed under the 2 MB partition. Note its name. For me, as seen in the example above, it is `sda2`.

Format it using the following command:
```
mkfs.btrfs -f /dev/sda2
```
To ensure we can utilize snapshots in the future—which is the most important feature of `BTRFS`—you need to create several subvolumes. Enter the following commands:
```
mount /dev/sda2 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@srv
umount /mnt
```
Now, mount all of these subvolumes:
```
mount -o noatime,compress=zstd,subvol=@ /dev/sda2 /mnt
mkdir -p /mnt/{home,srv}
mount -o noatime,compress=zstd,subvol=@home /dev/sda2 /mnt/home
mount -o noatime,compress=zstd,subvol=@srv /dev/sda2 /mnt/srv
```
Pay attention to changing the device name from `sda` to your specific partition variable.

It is time to install the system software. The following command contains all the packages we will need during and after the installation:
```
pacstrap -K /mnt base linux-lts linux-lts-headers linux-firmware bind btrfs-progs btop caddy cronie dnscrypt-proxy nftables dnsmasq fish grub inetutils minidlna nano net-tools openssh openvpn perl python-cryptography python-flask rclone stress-ng sudo tcpdump vnstat which wireguard-tools iproute2 dosfstools
```
These are all the packages required to build and run this router, and we will rely on this specific set for the rest of the tutorial. If you compare this list to the default packages installed on distributions like Ubuntu, you will immediately notice one of Arch's greatest advantages: installing only what you truly need and avoiding dozens of unnecessary bloatware packages.

Next, generate the `fstab` file. This file informs the operating system about the location of disks, partitions, subvolumes, and their mount points:
```
genfstab -U /mnt >> /mnt/etc/fstab
```
You can inspect its contents after generation using the following command:
```
cat /mnt/etc/fstab
```

Now, `chroot` into your newly installed system:
```
arch-chroot /mnt
```
Enable these two critical services right away:
```
systemctl enable sshd
systemctl enable systemd-timesyncd
```
Why must we enable the `sshd` service? Unlike the Arch live disk, this service is disabled by default on a fresh installation. Not only must you enable it, but you also need to modify its configuration so that you can connect via `ssh` after the system boots.
Open the following file using nano:
```
nano /etc/ssh/sshd_config
```
Almost the entire file is commented out. This means you will see a `#` symbol at the beginning of each line. This symbol tells the program that the line is merely a comment or note and should be ignored.
Scroll to the end of the file and append these two lines (you can optionally omit the first line and log in exclusively with the user we will create, but if you ever need to `ssh` as root, the first line is necessary):
```
PermitRootLogin yes
PasswordAuthentication yes
```
Pay close attention here: to save the data and exit nano, you must follow these exact steps: First, press `Ctrl+X`. Nano will then ask if you want to save the modified buffer. Press `y` on your keyboard and then hit `Enter`. It is that simple.

Assign a password to the `root` user using the following command:
```
passwd
```

There are two methods to configure the network: using a pre-made script I created, or doing it manually.

### Network Detection Script
If you prefer an automated approach, this script will be to your liking. However, I strongly recommend reading through the manual network configuration method to gain a better understanding of how the system operates.

Run one of the two commands below in the terminal. Both commands point to the same script, but one link is shortened via `bit.ly` to make manual typing easier:
```
curl -fsSL https://bit.ly/network-detection | sudo bash
```

```
curl -fsSL https://raw.githubusercontent.com/emanamini/routerScripts/refs/heads/main/scripts/network-detection.sh | sudo bash
```
The script will automatically detect your network and attempt to assign the name `wan` to the port currently connected to the internet, while assigning `lan` to the second port designated for the access point. If it detects the ports correctly, simply press `Enter`. Otherwise, manually input the full interface name (which usually starts with `ens`) for the `wan` interface connected to the internet, and the `lan` interface connected to the access point. Reading the [[#Manual Network Configuration]] section will give you a more comprehensive view of what we are doing here.

### Manual Network Configuration
For a router, it is crucial that network interface names remain persistent and easily identifiable. This means we cannot rely on `udev` dynamically assigning a name to the network interface every time the system boots. We currently have two network interfaces on the system: the motherboard's built-in interface and the expansion network card we added. Retrieve their physical MAC addresses using the following command:
```
ip addr show
```
Now, create a file at this path:
```
nano /etc/udev/rules.d/10-network-names.rules
```
The path should already exist, but if you see a red warning in nano, it means the target directory is missing. Exit nano with `Ctrl+X`. Create the directory using this command:
```
mkdir -p /etc/udev/rules.d/
```
Then, run the previous command again to create the file. Add the following values to its contents:
> Use `Ctrl+Shift+V` to paste the text you copied. You will need these three keys constantly, so do not forget them. In `Termius`, the `Paste` option is usually located in the top bar, which is more straightforward.

```
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="XX:XX:XX:XX:XX:XX", NAME="lan"  
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="XX:XX:XX:XX:XX:XX", NAME="wan"
```
Replace the `XX` placeholders with the MAC addresses of your two network interfaces. Notice that each is assigned a specific name: one is `wan` and the other is `lan`. Enter the MAC address of the interface connected to your modem (which supplies internet to Arch) on the `wan` line.
Enter the MAC address of the interface connecting to the access point on the `lan` line.
All the numerous scripts I will provide are written based on these two specific names, so be extremely careful not to swap or misspell them; otherwise, you will get nothing but headaches. Press `Ctrl+X`, type `y`, and hit `Enter` to save.

Next, create the network interface configuration files. First, create the directory if it does not already exist:
```
mkdir -p /etc/systemd/network/
```
Now for the files. You can easily create them using nano, or use the single commands below to generate them instantly. For the `wan` interface:
```
cat <<EOF > /etc/systemd/network/wan.network
[Match]
Name=wan

[Network]
DHCP=yes
EOF
```
And for the `lan` interface:
```
cat <<EOF > /etc/systemd/network/lan.network
[Match]
Name=lan

[Network]
Address=172.22.0.1/24
Address=10.10.10.10/32
EOF
```
You can use `cat` to view their contents. For me, the output of `cat` for both files looks like this:
```
cat /etc/systemd/network/lan.network  
[Match]  
Name=lan  
  
[Network]  
Address=172.22.0.1/24
Address=10.10.10.10/32
```

```
cat /etc/systemd/network/wan.network  
[Match]  
Name=wan  
  
[Network]  
DHCP=yes
```
We are going to bring up the network on the `172.22.0.1/24` subnet.

The only thing left is configuring the `resolv.conf` file. We will configure this file manually; although we could enable `systemd-resolved`, our system specifically relies on port `53`. Open the file with nano:
```
nano /etc/resolv.conf
```
And edit it with the following information:
```
nameserver 8.8.8.8
nameserver 8.8.4.4
```
Ensure that `systemd-resolved` is disabled:
```
systemctl disable systemd-resolved
```

Enable the network daemon so we don't end up locked out of the system after installing Arch:
```
systemctl enable systemd-networkd
```
The manual network configuration is complete. Next time, you can use the script to automate all of these steps in seconds.

Whether you used the [[#Network Detection Script]] or configured it via [[#Manual Network Configuration]], ensure your changes are saved by running the following command to view the contents of the `10-network-names.rules` file:
```
cat /etc/udev/rules.d/10-network-names.rules
```

### Bootloader
It is time to install the GRUB bootloader. Paying close attention to your disk name—for me, it is `sda`—enter the following commands:
```
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```
The output should display the message `No Error Reported`.

Now, assign a hostname to the system:
```
echo "router" > /etc/hostname
```
Open the `locale` configuration using the following command:
```
nano /etc/locale.gen
```
Look for the following line:
```
en_US.UTF-8 UTF-8
```
But how do you find it among all those lines? In the nano environment, press `F6`. Type a portion of the phrase above and hit `Enter`. Nano will take you directly to the target line. Remove the `#` symbol in front of it (uncomment it), then save and exit with `Ctrl+X` and confirm. Now run the following command:
```
locale-gen
```

Before finishing up, it is best to create a standard user, as operating as the `root` user is highly discouraged due to its unlimited privileges. Run the following command to create a user:
> Although the scripts have the capability to detect the user and configure the system based on the existing user, it is safer to name this user `net`, exactly as I have done.

```
useradd -m -G wheel,systemd-journal -s /bin/bash net
```
Assign a password to the `net` user:
```
passwd net
```
Since we will use this user to manage the entire system, we must grant it the necessary permissions. Open the following file, but before making any changes, remember that this file is extremely sensitive. Whatever level of care you took while typing previous commands, multiply it by ten when editing this file. Open it in nano using the following command:
```
EDITOR=nano visudo
```
Look for the following line near the bottom of the file:
```
# %wheel ALL=(ALL:ALL) ALL
```
Remove the `#` symbol at the beginning to uncomment it:
```
%wheel ALL=(ALL:ALL) ALL
```
Save the changes and exit by pressing `Ctrl + X` and typing `Y`. This line tells the system that users belonging to the `wheel` group are permitted to execute high-level system commands via `sudo`. If you look back at the `useradd` command, you will see that we already added the `net` user to this group.

Switch to the `net` user environment using the following command:
```
su - net
```
Verify that you have permission to execute system commands by running:
```
sudo echo "Sudo access is working!"
```
The first time you run `sudo`, the system will display a message warning you that with great power comes great responsibility, urging you to use `sudo` responsibly.
Exit the `net` user environment:
```
exit
```
To ensure the app we are going to build functions correctly, the `net` user requires passwordless `sudo` privileges for a specific set of commands. Create the following file:
```
nano /etc/sudoers.d/99-router-scripts
```
Add the following content to it:
```
net ALL=(ALL) NOPASSWD: /opt/router/scripts/toggle-route, /opt/router/scripts/srv.sh, /usr/local/bin/srv, /usr/bin/reboot, /usr/bin/systemctl, /usr/bin/ip, /usr/bin/wg-quick, /usr/bin/openvpn
```
Save the file and exit. It is time to close the `chroot` environment:
```
exit
```
Unmount all mount points (we mounted them earlier, now we detach them):
```
umount -R /mnt
```
And power off the system:
```
poweroff
```
Now, remove the installation flash drive. **Take a network cable and connect the network interface to the access point.** The physical layout is as follows: the main modem is connected to the motherboard's network card named `wan`, and the access point is connected to the additional network card we named `lan`. Power on the access point, followed by the system.

If everything went smoothly, you should be able to log in after about 1 minute, and the `wan` interface should have acquired the IP address you assigned to it in your modem's console. Log in via `Powershell` using the command below. If you are connecting from your phone via `Termius`, simply change the user to `net` and connect using the same connection profile as before:
```
ssh net@IP-Address
```
From here on, we will assume the `wan` IP address is:
```
192.168.100.100
```
Replace the value above with your actual IP address. For my IP, the command looks like this:
```
ssh net@192.168.100.100
```
The installation is complete. Let's move on to configuring the system itself.

## First Experience in the Router Environment
You are now inside the installed operating system environment. Given the network configurations applied during installation, you should see the appropriate output for each network interface by running the `ip addr show` command.
```
ip addr show  
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000  
   link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00  
   inet 127.0.0.1/8 scope host lo  
      valid_lft forever preferred_lft forever  
   inet6 ::1/128 scope host noprefixroute   
      valid_lft forever preferred_lft forever  
2: lan: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc htb state UP group default qlen 1000  
   link/ether a2:c6:2a:6e:b6:52 brd ff:ff:ff:ff:ff:ff  
   altname enp1s0f0  
   altname enx00152a6eb848  
   inet 172.22.0.1/24 brd 172.22.0.255 scope global lan  
      valid_lft forever preferred_lft forever  
   inet6 fe80::215:2aff:fe6e:b848/64 scope link proto kernel_ll   
      valid_lft forever preferred_lft forever  
3: wan: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq state UP group default qlen 1000  
   link/ether a2:c6:2a:6e:b6:51 brd ff:ff:ff:ff:ff:ff  
   altname enp1s0f1  
   altname enx00152a6eb849  
   inet 192.168.100.201/24 metric 1024 brd 192.168.100.255 scope global dynamic wan  
      valid_lft 10954sec preferred_lft 10954sec  
   inet6 fe80::215:2aff:fe6e:b849/64 scope link proto kernel_ll   
      valid_lft forever preferred_lft forever
```
Of course, since you have connected to the system via `ssh`, everything has presumably gone well.
To verify your internet connection, ping Google:
```
ping -c 2 google.com
```
# Automated Router Installation
If you scroll to the bottom of this document, you will see that we have a massive amount of work to do. This multi-week process—which will take you less than a day with this document—was one of the best and most educational courses of my life. With Gemini's help, I have prepared a set of modules that perform almost all these tasks for you in under a minute. The tasks the script does not do for you are: [[#Creating a Custom Stamp]], setting up [[#Diag]], adding the [[#VPN]] config, [[#Backing Up Sensitive Files]], and [[#Additional Optimizations]]. However, for Diag, you only need to extract your USB flash drive's `UUID` and place it in the `99-router-diag.rules` file. The rest of the configurations are handled by the script. 

For the app's domain settings, you must carefully read the [[#Preparing Caddy]] section. Although the script handles all the necessary tasks to install and configure Caddy, you must obtain your `API` key from Cloudflare and configure two `A` records for your domain in Cloudflare's `DNS` section. Without reading this section and having the `API` key, you cannot proceed with the automated Caddy installation module.

Run the following command in the terminal and carefully answer the few simple questions it asks. Usually, pressing `Enter` works fine:
```
mkdir -p router-installer && curl -sL https://github.com/emanamini/routerScripts/releases/download/Router/install.tar.gz | tar -xzf - -C router-installer && (cd router-installer && chmod +x install.sh modules/*.sh && sudo -E ./install.sh) ; rm -rf router-installer
```
# Manual Router Installation
First and foremost, change the local time to Tehran so the timestamps do not confuse you during debugging:
```
sudo ln -sf /usr/share/zoneinfo/Asia/Tehran /etc/localtime
timedatectl
```
## Configuring the Firewall
Let's move on to the firewall. Open a new file with nano:
```
sudo nano /etc/nftables.conf
```
This file should be empty, but if it contains anything, move it using the following command and open a new file again:
```
sudo mv /etc/nftables.conf /etc/nftables.conf.bck
sudo nano /etc/nftables.conf
```
Now copy the exact contents below and paste them into nano using `Ctrl+Shift+V`:
```
#!/usr/sbin/nft -f  
  
flush ruleset  
  
define LAN = "lan"  
define WAN = "wan"  
  
table inet filter {  
  
   chain input {  
       type filter hook input priority filter; policy drop;  
  
       # Accept loopback  
       iifname "lo" accept  
  
       # Drop invalid packets  
       ct state invalid drop  
  
       # Accept established/related connections  
       ct state established,related accept  
  
       # Allow everything from the trusted LAN  
       iifname $LAN accept  
  
       # SSH from the WAN subnet only  
       iifname $WAN ip saddr 192.168.100.0/24 tcp dport 22 ct state new accept  
  
       # Ping  
       ip protocol icmp accept  
       ip6 nexthdr icmpv6 accept  
   }  
  
   chain forward {  
       type filter hook forward priority filter; policy drop;  
  
       # Drop invalid packets  
       ct state invalid drop  
  
       # Allow established/related traffic  
       ct state established,related accept  
  
       # ADDED LINE: Block specific IP range from accessing direct ISP WAN connection  
       ip saddr 172.22.0.1-172.22.0.100 oifname $WAN drop  
  
       # LAN -> Internet  
       iifname $LAN oifname $WAN accept  
  
       # LAN -> VPN  
       iifname $LAN oifname { "tun0", "tun1" } accept  
   }  
  
   chain output {  
       type filter hook output priority filter; policy accept;  
   }  
}  
  
table ip nat {  
  
   chain postrouting {  
       type nat hook postrouting priority srcnat;  
  
       oifname $WAN masquerade  
       oifname { "tun0", "tun1" } masquerade  
   }  
}
```
Save and exit with `Crtl + X` and `Y`. You can view its contents using the `cat` command and the file path. Keep this command in mind. For example, for the file above:
```
cat /etc/nftables.conf
```
The file above is well-commented, with explanations above each line. For further explanation, you can feed the entire file to an AI like [Grok](https://grok.com) and ask it to explain it line by line.
Now you need to enable IP forwarding. My file is slightly more comprehensive to better optimize the connections to the router. Create the following file exactly as mine:
```
sudo nano /etc/sysctl.d/router.conf
```
And add the following contents to it:
```
# Arch Router Kernel Optimizations  
# ==============================================================================  
  
# 1. Enable IPv4 Forwarding  
net.ipv4.ip_forward = 1  
  
# 2. Modern TCP Congestion Control & Queue Management (BBR + FQ)  
net.core.default_qdisc = fq  
net.ipv4.tcp_congestion_control = bbr  
  
# 3. Security: Prevent IP Spoofing  
net.ipv4.conf.default.rp_filter = 1  
net.ipv4.conf.all.rp_filter = 1  
  
# 4. Performance: Increase maximum packet backlog queue  
net.core.netdev_max_backlog = 10000
```
Save and exit. You can apply its contents without a `reboot` using the command below, but it is not necessary as the system will load them automatically on the next `reboot`.
```
sudo sysctl --system
```
Enable the firewall service with the following command:
```
sudo systemctl enable --now nftables.service
```
The `enable --now` parameter both enables the service to start on the next boot and starts it immediately, acting equivalent to the two commands below:
```
sudo systemctl enable nftables.service
sudo systemctl start nftables.service
```
Check its status with the following command:
```
sudo systemctl status nftables
```
Since this service does not need to run continuously and only executes once to establish the firewall rules, you should see messages similar to these at the end of the command output:
```
Jul 25 10:05:40 router systemd[1]: Starting Netfilter Tables...  
Jul 25 10:05:40 router systemd[1]: nftables.service: Deactivated successfully.  
Jul 25 10:05:40 router systemd[1]: Finished Netfilter Tables.
```
## A Brief Overview of `systemd`
This is our first time using `systemd` in this installation (excluding enabling `sshd`). This tool allows you to manage various services. Commands related to it must all be executed with `sudo`. You do not need to memorize anything right now, as we will deal with these commands so frequently that you will learn them by heart regardless.
The following command enables the `BLAHBLAH` service to start during boot:
```
systemctl enable BLAHBLAH.service
```
This command starts it:
```
systemctl start BLAHBLAH.service
```
This command disables it from starting during boot:
```
systemctl disable BLAHBLAH.service
```
This command stops it:
```
systemctl stop BLAHBLAH.service
```
And this command restarts the service:
```
systemctl restart BLAHBLAH.service
```
This command shows the service status:
```
systemctl status BLAHBLAH.service
```
This command displays currently running services:
```
systemctl list-units --type=service --state=running
```
And this command lists `failed` services:
```
systemctl --failed
```
This critical command is also useful if you have modified services. Be sure to run this command after updating services, which we will do later:
```
systemctl daemon-reload
```
Two other essential commands:
```
systemctl reboot
systemctl poweroff
systemctl suspend
systemctl hibernate
```
Actually, that was 4 commands, but the bottom two are practically useless for our purposes and I only included them for reference. Try to shut down or reboot the system exclusively using these commands.
A crucial command for live troubleshooting is:
```
journalctl -u BLAHBLAH.service -f
```
And to check critical system messages:
```
journalctl -xe
```
While not exhaustive, these are sufficient for our needs.
## Configuring `dnsmasq`
Take a backup of the configuration file installed alongside the package:
```
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.bck
```
Create and open a new file with nano:
```
sudo nano /etc/dnsmasq.conf
```
Paste the exact contents below into it and save:
```
cat /etc/dnsmasq.conf  
# ==============================================================================  
# Arch Linux Router - dnsmasq Configuration  
# Network Interface & Binding  
# ==============================================================================  
interface=lan  
bind-interfaces  
listen-address=172.22.0.1  
log-dhcp  
# log-queries  
no-resolv
# ==============================================================================  
# Upstream Encrypted DNS Forwarding  
# Forward uncached requests locally to dnscrypt-proxy on port 5353  
# ==============================================================================  
server=127.0.0.1#5353  
# server=9.9.9.9  
# server=1.1.1.1  
  
# ==============================================================================  
# Aggressive Caching & Outage Resilience (Shutdown & Throttle Protection)  
# ==============================================================================  
# Cache capacity for up to 10,000 domain entries  
cache-size=10000  
  
# Minimum cache retention forced to 24 hours (86,400 seconds)  
# min-cache-ttl=86400  
  
# Maximum cache TTL allowed up to 7 days (604,800 seconds)  
# max-cache-ttl=604800  
  
# Set minimum TTL to 0 so dnsmasq respects the natural TTL set by the domain owner  
min-cache-ttl=0  
  
# Cap the maximum cache time to 1 hour (3600 seconds) so stale records clear quickly  
max-cache-ttl=3600  
  
# SERVE STALE CACHE:  
# Serves expired cached entries if upstream encrypted resolvers become unreachable  
use-stale-cache=0  
  
# ==============================================================================  
# DHCP Range & Options  
# ==============================================================================  
dhcp-range=172.22.0.10,172.22.0.90,255.255.255.0,24h  
dhcp-option=option:router,172.22.0.1  
dhcp-option=option:dns-server,172.22.0.1  
  
# ==============================================================================  
# STATIC IP RESERVATIONS (Paste your dhcp-host entries below)  
# ==============================================================================  
  
  
#########################################################  
# 🏠 1st FLOOR DEVICES (100–114)  
#########################################################  
  
dhcp-host=BC:F1:A5:68:C4:03,172.22.0.101,SonyTV1-L  
dhcp-host=BC:F1:A5:68:14:58,172.22.0.102,SonyTV1-W
```
You can enable the service, but my experience with enabling `dnsmasq` has been inconsistent. Despite configuring options to wait, it still encounters errors during the startup race, rendering the system inaccessible via the `lan`. Therefore, we will start it later using another script named `delayed-startup`. This is sufficient for now.

Let me provide a brief explanation of this file. In this file, we instruct `dnsmasq` to listen on the `lan` interface. It tells connecting devices to use `dnscrypt proxy` at the address `172.22.0.1` on port `53`. However, `dnscrypt proxy` uses port `5353`, and it is `dnsmasq` that acts as the bridge between us and it via `server=127.0.0.1#5353`.
In this configuration, `dnsmasq` randomly assigns IPs in the range of `172.22.0.10` to `172.22.0.90` to connected devices unknown to the system. In the bottom section, you can define a specific IP outside this range for individual devices. This is essential for building the `PWA` app, as the app only trusts users whose `MAC Address` is registered in the system. I recommend reserving the range from `172.22.0.101` up to `172.22.0.200` for them. I have also reserved addresses `172.22.0.201` to `172.22.0.210` for the access points, depending on their count. In our building, there are 5 access points, each with its own dedicated IP.
> Note: Almost all modern phones use a randomized MAC address to connect to a network. You must disable this feature when connecting devices and instruct the system to use the phone's actual MAC address, indicating it is on a trusted network.

### Why Static IPs? 
The reason for this comes down to network security. Later, we will write a few scripts with system-level privileges that users connected to your network will use to bypass the `VPN`. Unknown users are restricted from this script for two reasons:
1) To prevent direct access to the internal network. This way, if your access point password is hacked for any reason, the connected user's only communication will be through the `VPN`. By utilizing a secure `VPN`, you can rest easy knowing that if they use your network maliciously, you will not face legal consequences. While not bulletproof, penetrating this setup is nearly impossible because the hacker would need the MAC address of one of the trusted devices specified in `dnsmasq` and then use MAC Spoofing to enter your network with a forged address. Even then, they would have to figure out how to disable the `VPN`, which they likely cannot do.
2) The `wan` connection supplied by the `ISP` is blocked via `nftables` for all IPs in the sub-100 range. With a static IP, you grant users the ability to use the internal network to connect to banks and the broad network of domestic sites and services.
**So do not forget that IPs in the 100+ range can bypass the VPN and use the domestic internet, but those below this range cannot.**

Our work with `dnsmasq` is almost complete. Just remind your users when they complain about their bank not loading on your network that they must provide their MAC address to regain access. The beauty of this method is that it no longer matters how many access points you have; users will receive their dedicated `IP` regardless of where they are on your network.

## Configuring `DNSCrypt Proxy`
This is the final piece of the system's backbone puzzle. We installed its package previously. Now we need to enable it on port `5353`. 
You can use general configurations, or you can build your own personal, free `DNS` server.
### General Configuration
Download and move the following file using these commands:
```
curl -L https://raw.githubusercontent.com/emanamini/routerScripts/refs/heads/main/scripts/dnscrypt-proxy.toml --output dnscrypt-proxy.toml
sudo mv /etc/dnscrypt-proxy/dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml.bck
sudo mv dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
```
Start the service and then check its latest status using `status`.
```
sudo systemctl start dnscrypt-proxy.service
sudo systemctl status dnscrypt-proxy.service
```
You should see something like this in the last line of the status output:
```
Server with the lowest initial latency: google (rtt: 144ms), live servers: 2
```
### Custom Configuration
This is a bit more complex, but it is worth it. Move the configuration file and then open a new file with nano:

```
sudo mv /etc/dnscrypt-proxy/dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml.bck
sudo nano /etc/dnscrypt-proxy/dnscrypt-proxy.toml  
```
Place the following contents into it:
```
# Custom DoH server  
server_names = ['cf1']  

# Listening  
# ============================================================================== 
listen_addresses = ['127.0.0.1:5353', '[::1]:5353']  
 
# Protocol Requirements  
# ==============================================================================    
doh_servers = true  
dnscrypt_servers = true  
  
require_dnssec = true  
require_nolog = true  
require_nofilter = false  
  
  
# Load Balancing  
# ==============================================================================  
  
lb_strategy = 'p2'  
lb_estimator = true  
  
  
# Bootstrap  
# ==============================================================================  
  
bootstrap_resolvers = ['1.1.1.1:53', '8.8.8.8:53']  
  
fallback_resolvers = ['1.1.1.1:53']  
  
  
# Timeouts  
# ==============================================================================  
  
netprobe_timeout = 60  
netprobe_address = '1.1.1.1:53'  
  
timeout = 2500  
keepalive = 30  
  
  
# Operational  
# ==============================================================================  
  
ignore_system_dns = true  
max_clients = 250  
  
  
# Cache  
# ==============================================================================  
  
cache = true  
cache_size = 10000  
# cache_min_ttl = 86400  
# cache_max_ttl = 604800  
# cache_neg_min_ttl = 60  
# cache_neg_max_ttl = 600  
  
# Minimum TTL to keep things fresh  
cache_min_ttl = 60  
# Maximum TTL capped at 1 hour (3600 seconds)  
cache_max_ttl = 3600  
cache_neg_min_ttl = 60  
cache_neg_max_ttl = 600  
  
  
# Static Resolver  
# ==============================================================================  
  
[static]  
  
[static.'cf1']  
stamp = 'sdns://XXX'
```
The only section you need to edit is the last line. In a restricted network like ours, the ISP heavily manipulates `DNS` requests. Sometimes even `DNS` providers like Cloudflare are filtered during emergencies, effectively leaving us without any working `Resolver`. Because of this, after years of wrestling with different options, I concluded it is better to have my own `Resolver`. Here, I will teach you how to build your own `Resolver`.
### Creating a Custom Stamp
But for those of you eager for an adventure, I hope the website you registered is ready. Go to the [Cloudflare](https://dash.cloudflare.com) website and log in.
From the left panel, navigate to `Domains` and then `Overview`. Click `Add domain` on the top right.
Select the `Connect a domain` option. Enter the domain name you registered in full, such as `example.com`.
Click `Continue`. If the domain has not been registered yet, Cloudflare might show a warning. It does not matter; proceed to the next step. Select the `Free` plan here.
It will ask you to enter a record. We do not need this section either; click `Continue to activation` at the bottom of the page. Click the `Confirm` button in the dialog that opens. In the section below, two `nameservers` are assigned to your account.
```
Replace your current nameservers with Cloudflare nameservers
```
Copy them, then return to the site where you registered the domain. Find the option to change nameservers, or something like `Change Nameservers`, clear their default values, and enter and save the values Cloudflare provided instead of `NS1` and `NS2`.
Now return to Cloudflare and click the `I updated my nameservers` button at the bottom of the page. It usually takes a few minutes to a few hours for your domain to successfully connect to Cloudflare.

Now it is time to build the Worker app. Return to the [Cloudflare Main Dashboard](https://dash.cloudflare.com) and navigate to the following section from the side panel:
```
Compute >  Workers & Pages
```
Click the blue `Create application` button at the top of the page. Select the `Start with Hello World!` option, and on the next page, click `Deploy`. Wait a moment for the new app to be created, then click the `Edit code` button on the top right.
You will now see the contents of the `worker.js` file. Delete all of its contents. Open the following [file](https://raw.githubusercontent.com/TheGreatAzizi/Secure-DNS-over-HTTPS-Cloudflare-Worker/refs/heads/main/Worker.js).
```
https://raw.githubusercontent.com/TheGreatAzizi/Secure-DNS-over-HTTPS-Cloudflare-Worker/refs/heads/main/Worker.js
```
Carefully copy all of its contents and replace the previous contents of `worker.js`. Now, look for this line in the first few lines:
```
DNS_PATH: '/dns-query',
```
Replace `dns-query` with something like a password so others cannot access and abuse your server. I use lowercase letters and numbers. For example, I changed it to this:
```
DNS_PATH: '/3eazvtvz5yay0',
```
Now click the `Deploy` button on the top right. Wait until it confirms the app is active with a green message.
On the top left, you will usually find the three-part name of the worker with a back arrow. Click it to return to its main page.
Click on `Domains` in the top bar of this section. Then, click the blue `Add domain` option. The domain name you added should be in the list. Select it and choose a subdomain name like `doh`. Press the `Add` option to add it.
We are back on the main Worker page. Click the `Visit` option. If the domain is active, it will give you your own `DoH` address with a custom domain. Having a custom domain reduces the likelihood of it being filtered, as `worker.dev` is often among the first domains filtered during a crisis, effectively disabling our `DoH`. However, if you are not using a custom domain, you still currently have a `DoH` under the `workers.dev` service that is usable in the next section. If it does not open, wait ten minutes and try again.
> Most popular browsers like Firefox support `DoH` to blind the `ISP`. You can use the `DNS Server` you built in all of these apps. Simply enter the full address you see in the middle of the Worker page (when you clicked Visit) into them.

Now, go to the [DNS Stamp Calculator](https://dnscrypt.info/stamps/) website.
Set the protocol to `DoH` from the dropdown menu. In the `Hostname` box, enter the domain address along with the subdomain (the Cloudflare worker address is also acceptable if you don't have a domain):
```
doh.example.com
```
In the `Path` section, enter the Worker's `DoH` path that we changed earlier for security. In our example, the path looks like this:
```
/3eazvtvz5yay0
```
Turn on the `DNSSEC` and `No logs` toggles from the side options, and turn off the `No filter` option. In the `IP` field, using a clean Cloudflare `IP` is also recommended. This makes detecting your server significantly harder.

Your `Stamp` is now ready. Copy it and place it in the line:
```
stamp = 'sdns://XXX'
```
Like this:
```
stamp = 'sdns://AgMAAAAAAAAAAAAACi9kbnMtcXVlcnk'
```
Start the service and then view its latest status with `status`.
```
sudo systemctl start dnscrypt-proxy.service
sudo systemctl status dnscrypt-proxy.service
```
Our work here is done. On Cloudflare's free plan, you can send nearly 100,000 requests daily, which is sufficient for over 50 people. In my experience, daily requests for a 4-story building full of internet-loving humans have been less than 10,000.
We also run the `dnscrypt` service via `delayed-startup` in the style of `dnsmasq`. We want to keep the system startup as clean and simple as possible.
Now that everything is working, you can take one more step to elevate your privacy level (recommended but not mandatory). To disable the subdomain page, go to the Worker's code edit section where you pasted `worker.js`. Search for these lines:
```
if (url.pathname === '/' || url.pathname === '/index.html') {
      return renderUI(url.host);
    }

    return textResponse('Not found', 404);
```
And replace them with these lines (we commented them out with `//`):
```
    // if (url.pathname === '/' || url.pathname === '/index.html') {
    //   return renderUI(url.host);
    // }

    return textResponse('Not found', 404);
```
### Creating a Highly Private Custom Stamp
A minimal Worker template can also serve your needs instead of the relatively advanced one above; it optimizes the request volume and generally acts as a good failover alternative. Create a new Worker in the same style as the previous one and click edit code. Instead of the code you grabbed from GitHub earlier, enter this code into the Worker:
```
// 1. Define your secret path
const SECRET_PATH = "/dtutr8w001zzoth0g"; 

// 2. Add multiple upstream DoH servers to this array
// The worker will try them in order from top to bottom.
const UPSTREAM_DOH_SERVERS = [
  "https://adblock.mydns.network/dns-query",
  "https://dns.quad9.net/dns-query",       // Backup 1 (Quad9 Malware Blocking)
  "https://security.cloudflare-dns.com/dns-query" // Backup 2 (Cloudflare Security)
];

export default {
  async fetch(request) {
    const url = new URL(request.url);

    // SECURITY CHECK: Drop unauthorized paths
    if (url.pathname !== SECRET_PATH) {
      return new Response("Not Found", { status: 404 });
    }

    // Only accept Standard DoH methods
    if (request.method !== 'GET' && request.method !== 'POST') {
      return new Response("Forbidden", { status: 403 });
    }

    // Clone the body because it can only be read once per fetch attempt
    // If we need to try multiple servers, we need a fresh copy of the body each time.
    let requestBody = null;
    if (request.method === 'POST') {
      requestBody = await request.clone().arrayBuffer(); 
    }

    // FAILOVER LOGIC: Loop through upstreams until one succeeds
    for (const upstream of UPSTREAM_DOH_SERVERS) {
      try {
        const upstreamUrl = new URL(upstream);
        if (request.method === 'GET') {
          upstreamUrl.search = url.search; // Append ?dns=...
        }

        const response = await fetch(upstreamUrl.toString(), {
          method: request.method,
          headers: {
            "Accept": "application/dns-message",
            "Content-Type": "application/dns-message",
          },
          body: requestBody
        });

        // If the upstream responded successfully (Status 200 OK), return it immediately
        if (response.ok) {
          return new Response(response.body, {
            status: response.status,
            headers: {
              "Content-Type": "application/dns-message",
              "Cache-Control": response.headers.get("Cache-Control") || "max-age=60",
              "Access-Control-Allow-Origin": "*"
            }
          });
        }
      } catch (err) {
        // If the fetch fails (e.g., timeout or server down), simply ignore and loop to the next one
        console.error(`Upstream ${upstream} failed.`);
      }
    }

    // If ALL servers in the array fail, return a 502 Bad Gateway
    return new Response("All upstream servers failed", { status: 502 });
  }
}
```
Like me, insert a random string in the second line of the code instead of `dtutr01zzoth0g`. This string acts as the `Path` for your server. 
On the [DNS Stamp Calculator](https://dnscrypt.info/stamps/) website, you must enter this exact string into the `Path` section like this (for example, for me):
```
/dtutr01zzoth0g
```
In the `Host name` section, enter the Worker's subdomain again and grab your unique `Stamp` (using a clean Cloudflare `IP` in the `IP` field is also recommended).
The beginning and end structure of the file below
```
sudo nano /etc/dnscrypt-proxy/dnscrypt-proxy.toml
```
for two Workers will look something like this (pay attention to the quotation marks; although sometimes not strictly required, having them is better than not):
```
# Custom DoH server  
server_names = ['eman1', 'eman2']
```

```
[static]  
  
[static.'eman1']  
stamp = 'sdns://AgMAAAAAAAAAAAANd2Vyd2VyZXJld2V3chYvd2VlcnRyeXJ0eXR5cnR5cnR5cnR5'  
  
[static.'eman2']  
stamp = 'sdns://AgMAAAAAAAAAAAAYd2Vyd3NlaTtob3Nkb2loZXJlcmV3ZXdyFi93ZW'
```
In my opinion, build both Workers and place them in the file above. 
Start the service and then view its latest status with `status`.
```
sudo systemctl start dnscrypt-proxy.service
sudo systemctl status dnscrypt-proxy.service
```
### DNS Chain
It might not be a bad idea to learn a bit about this chain for general knowledge. When you attempt to open a web address, your operating system relies on a `DNS Server`. It provides the website name to this server and typically receives a four-part string of numbers between 0 and 255 in return. Internet service providers heavily rely on this capability for monitoring and imposing restrictions, as the exchanged data can usually be monitored on a predictable port like port `53`. Because of this, manipulating them to enforce restrictions is a very common method. 
The job of tools like `DNSCrypt` is to conceal this request using various methods, such as masquerading them as normal `https` traffic on port `443`. 
In our Linux system, applications typically rely on `resolv.conf` to receive server information, and this file cannot read data from a port other than `53`. This is where `dnsmasq` steps in. It takes the requests from `resolv.conf`, hands them to `DNSCrypt`, which then encrypts the request and sends it to your personal server; upon receiving the response, it delivers it through this same chain to the requesting app.
Of course, since we do not browse the web directly on the router itself, we can make `resolv.conf` simpler and leave its contents untouched, because other devices connect to this chain and have their requests encrypted thanks to the `dnsmasq` software's DHCP engine. A simpler `resolv.conf` minimizes the chances of software errors caused by delays in starting `DNSCrypt`. Nevertheless, if you want the router itself to use `DNSCrypt`, edit the following file:
```
sudo nano /etc/resolv.conf
```
And change its contents from this:
```
nameserver 8.8.8.8
nameserver 8.8.4.4
```
To this:
```
nameserver 172.22.0.1
```
These lines in `dnsmasq` are responsible for linking these chains together:
```
listen-address=172.22.0.1
server=127.0.0.1#5353
dhcp-option=option:dns-server,172.22.0.1
```
The architecture looks like this:
```
[ Client Device (Port 53)] < > 
[ Linux Router: dnsmasq (Port 5353)] < > 
[ dnscrypt-proxy ] ──(DNS Stamp) (Encrypted HTTPS / Port 443) < > 
[ Cloudflare Worker (Custom Endpoint) ]

```
You might wonder, if `DNSCrypt` encrypts the data and sends it over another port, what is the need to build a personal server on Cloudflare Workers? Encrypted requests inevitably send server metadata initially, and strict monitoring of user traffic can pinpoint the request's destination. When `DNSCrypt` sends a request to one of thousands of known servers like Google, the firewall can detect and block it. A custom server with a custom domain has the advantage of easily bypassing this hurdle; unless the filtering system uses `Whitelisting` and blocks everything indiscriminately.
Your system is now ready as a router. Before you restart it once, we will enable the `dnsmasq` service to ensure clients acquire an IP from its engine for now. Later, you can offload it to the startup script as I did.
First, run the following command:
```
sudo systemctl edit dnsmasq
```
Now, exactly between these two lines:
```
### Anything between here and the comment below will become the contents of the drop-in file  
  
### Edits below this comment will be discarded
```
If there is anything there, delete it and insert these lines:
```
[Unit]
Wants=network-online.target
After=network-online.target

[Service]
Restart=on-failure
RestartSec=5s
StartLimitIntervalSec=2min
StartLimitBurst=24
```
Now reload the service, restart it, and view its status. It should be properly activated:
```
sudo systemctl daemon-reload
sudo systemctl restart dnsmasq
sudo systemctl status dnsmasq
```
If everything looks good, reboot the system and transfer your current device to the `lan` subnet. For example, if you are using a computer, disconnect it from the modem and connect it to the access point attached to the `lan` interface. This will be your first connection to the router, and once connected, you will have internet access.
Given the extensive and varying configurations we made, it is also recommended to turn the access point (`AP`) off and on.
If you cannot connect, you better proceed to the troubleshooting phase. Reconnect your personal system to the main modem, ssh into the router, and attempt to connect a third device to the access point. Now check the services on the router one by one. The most critical services you should check:
```
systemctl status systemd-networkd
systemctl status dnscrypt-proxy.service
systemctl status dnsmasq.service

```

If there is an issue with any of them, first restart it using `sudo systemctl restart SERVICENAME.service` and check its status again with `status`. If the issue persists, refer back to its section in this tutorial and carefully verify the steps one by one.
Notice that we have not `enabled` any of these services because the [[#startup script]] is meant to handle that for us. If you rebooted the system for any reason before creating the `Startup` script, remember to start these two critical services manually:
```
systemctl start dnsmasq.service
systemctl start dnscrypt-proxy.service
```
## Management Scripts
### How to Create and Use Them
Managing the router via the command line with lengthy commands was not for me; therefore, I began writing basic management scripts. Since programming isn't my profession and my goal was simply to get things working, the initial scripts were so ugly they would have earned me curses from any developer. That is, until AI came to the rescue. All the code has been rewritten with the help of AI. Every script is well-commented and easy to use. The scripts are hosted in the repository below, primarily within the `scripts` directory:
```text
https://github.com/emanamini/routerScripts/
```

We will create a dedicated directory for our scripts in `/opt/`, assign ownership to our user (`net`), and symlink it to the home directory for easy access:
```bash
sudo mkdir /opt/router/scripts/
sudo chown -R net:net /opt/router/scripts
ln -s /opt/router/scripts/ /home/net/scripts
cd /opt/router/scripts/ 
```
When we `cd` into a symlink, our path is usually preserved, even though we are physically in the target directory. To completely change the path, you must use the `-P` option as shown below. Observe the difference in the following commands:
```bash
cd scripts/  
pwd  
/home/net/scripts  
cd   
cd -P scripts/  
pwd  
/opt/router/scripts  
```

## `systemd` Management Script
Typing long `systemctl` commands has always been a pain for me, especially when you miss a single character and try to correct it on a mobile phone terminal. This script helps you easily start, stop, enable, disable, and monitor the status of your required services. Ensure you are in the `/opt/router/scripts/` directory and download the script using the following command:
```bash
curl -L https://raw.githubusercontent.com/emanamini/routerScripts/refs/heads/main/scripts/srv.sh --output srv.sh
```
By default, Linux does not grant execution permissions to files. Make the target script executable with the following command:
```bash
chmod +x srv.sh
```
If you encounter a `Permission denied` error while running a command that does not require root privileges, you likely haven't made the file executable. You can grant this permission using `chmod +x`.
Now you can execute it using one of the three commands below (the `~` symbol represents the user's home directory, which for us is `/home/net/`):
```bash
./srv.sh
~/scripts/srv.sh
/opt/router/scripts/srv.sh
```
For the first command, your terminal must be in the `/opt/router/scripts/` directory. To view your current terminal path, use the `pwd` command:
```bash
pwd  
/opt/router/scripts
```
After creating the script and making it executable, we will create a symlink in the user binaries path for convenience. Just remember to use the absolute or full path during creation:
```bash
sudo ln -s /opt/router/scripts/srv.sh /usr/local/bin/srv
```
In the command above, we linked `srv.sh` to `srv` (for ease of invocation) in the user binaries directory. Now, it no longer matters where your terminal is currently located; running the command below will invoke our script.
```text
srv    
Usage: /usr/local/bin/srv  
   l | launch | start     
   r | restart    
   k | kill | stop    
   e | enable    
   d | disable    
   s | status
```
It is that simple. The original script remains in `/opt/router/scripts/`, and we do not edit the symlink. The symlink simply calls the original script.
Let's review how this script works with a few examples. As seen in the output of the `srv` command, this script accepts various values as its first parameter. Suppose you want to stop a service. You can clearly use `k`, `kill`, or `stop` as the first parameter. For convenience, I always use the single-letter option:
```text
srv k
Select the services to perform actions on:  
1. systemd-networkd.service  
2. dnsmasq.service  
3. nftables.service  
4. ip-rules.service  
5. wg-quick@tun0.service  
6. openvpn-client@tun0.service  
7. vpn-manager.service  
8. dnscrypt-proxy.service  
9. minidlna.service  
10. tc.service  
11. cronie.service  
12. delayed-startup.service  
13. arch-portal.service  
14. caddy  
Enter the numbers of services to perform action on (space or comma-separated):
```
The services defined in the script—which are easily customizable to your needs—are listed. You can stop a service by entering its corresponding number, based on the parameter you provided `(k)`. You can also manage multiple services at once. Simply type the number corresponding to each service, separated by spaces or commas:
```text
srv k    
Select the services to perform actions on:  
1. systemd-networkd.service  
2. dnsmasq.service  
3. nftables.service  
4. ip-rules.service  
5. wg-quick@tun0.service  
6. openvpn-client@tun0.service  
7. vpn-manager.service  
8. dnscrypt-proxy.service  
9. minidlna.service  
10. tc.service  
11. cronie.service  
12. delayed-startup.service  
13. arch-portal.service  
14. caddy.service
15. wan-watcher.service
Enter the numbers of services to perform action on (space or comma-separated): 6 5  
Service 'openvpn-client@tun0.service' stopped.  
Service 'wg-quick@tun0.service' stopped.
```
In the example above, we stopped two services.
Once you memorize the service numbers, you can pass them as the second parameter like this:
```text
srv k 6,5  
Service 'openvpn-client@tun0.service' stopped.  
Service 'wg-quick@tun0.service' stopped.
```
Just remember that when formatting multiple services this way, you MUST use commas with absolutely no spaces between the numbers.
To add or remove services, simply open the main `srv.sh` script with nano and navigate to the `# List of services` section on line 52. Write each service inside quotation marks on a separate line.

## VPN Bypass
A set of interconnected scripts and files is responsible for identifying routes and directing the traffic of various IP ranges based on routing tables. The functionality of these scripts—whose service is listed as item `4` in the `srv` script—is to open a route through a specified table in the system's `route`. With a high priority metric, this table attempts to intercept any packet sent to or received from IP ranges defined in another file, routing it directly before the VPN captures it. This script suite can bypass all traffic for Iran, or any other country you choose. You can even specify specific domains in a file instead of an entire country's IP ranges; the script will resolve their IPs and route only the traffic for those specific websites directly. It can also operate on a per-client basis, routing the entire internet traffic of a connected device directly into the table, exactly as if the VPN were disabled on that device.
First, let's create the service. We will name it `ip-rules.service`. From here on, I will provide the file contents immediately after the nano command:
```bash
sudo nano /etc/systemd/system/ip-rules.service
```
```ini
[Unit]  
Description=IP Rules  
  
[Service]  
Type=oneshot  
ExecStart=/opt/router/scripts/ip-rule.sh  
User=root  
RemainAfterExit=yes  
  
[Install]  
WantedBy=multi-user.target
```
As you can see, this service executes a script named `ip-rule.sh`. Download the script with the following commands:
```bash
cd /opt/router/scripts/
curl -L https://raw.githubusercontent.com/emanamini/routerScripts/refs/heads/main/scripts/ip-rule.sh --output ip-rule.sh
chmod +x ip-rule.sh
```
If you correctly named the network interfaces as instructed in the installation guide, all of these scripts will work automatically for your system as well. Let me briefly explain the core lines of this script:
```bash
TABLE_NAME="irtr"
PRIORITY=7998
lanIP=$(ip -4 -o addr show dev lan 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n 1)
firstThreeOctets=$(echo "$lanIP" | cut -d '.' -f 1-3)
wanGateway=$(ip route show dev wan | grep -oP 'default via \K\S+' | head -n 1)
```
These lines involve the table through which direct traffic will be routed. The priority is intentionally set to this number because `Wireguard` was ignoring our rules by creating a rule with a higher priority. (This issue might be resolved in newer versions). The third and fifth lines dynamically extract the `lan` and `wan` IPs. Extracting them instead of hardcoding allows us to seamlessly utilize different subnets without breaking the system. 
This line creates (or rebuilds, if it already exists) the necessary route (`irtr`) for direct traffic:
```bash
ip route replace default via "$wanGateway" dev wan table "$TABLE_NAME"
```
Naturally, we must create its routing table. Create the following file if it does not exist. Even if the directory doesn't exist, you must run the `mkdir` command:
```bash
sudo mkdir -p /etc/iproute2/
sudo nano /etc/iproute2/rt_tables
```
If the file already exists, simply append this value to the bottom:
```text
100     irtr
```
If the file didn't exist at all, add the default values for safety. Copy and paste my text directly into it:
```text
# reserved values  
255     local  
254     main  
253     default  
0       unspec  
 
# local  
# custom tables  
100     irtr
```
The table is now created, and the command I explained earlier will work perfectly. Pay close attention to this line:
```bash
for i in 241 242 243 244 245; do
```
We have two methods for routing traffic directly through the `irtr` table and bypassing the VPN: adding the destination IP or adding the client IP. Let me explain with a clearer example. Suppose your destination is a domestic site named `example.com`. You can obtain the IP of this site using the `dig` command. Then, you create a direct route to this IP via the `irtr` table. From then on, all devices connected to your system will have direct, non-VPN access to this website. Alternatively, you can route the entirety of a connected client's traffic directly into the `irtr` table; acting exactly as if the VPN was turned off on that device. This is the entire reason we assign a static IP to each device. Assume my mobile phone, named `Eman-Phone`, is bound to the IP `172.22.0.116` in the `dnsmasq` file. From now on, to turn off its VPN, I can create a direct route for this specific IP. While the VPN remains active on our router, the traffic this device receives will bypass it.
The line above in the `ip-rule.sh` file serves exactly this purpose. Suppose there are devices on your network that should never connect to the VPN. Simply list the last octet of their IP addresses in the line above, separated by spaces. The first three octets of the IP are appended automatically via the `firstThreeOctets` variable we defined earlier, placing the complete IP in the route.
This brings us to this highly critical line:
```bash
/opt/router/scripts/irtr.sh irlist
```
After bypassing traffic for specific client IPs through the `irtr` route, we move to the next phase: bypassing destination IPs. This is where we encounter another crucial script: `irtr.sh`. Download the script with the following commands so I can explain it. Note that this script was executed with the `irlist` parameter above.
```bash
curl -L https://raw.githubusercontent.com/emanamini/routerScripts/refs/heads/main/scripts/irtr.sh --output irtr.sh
chmod +x irtr.sh
```
For proper execution, this script requires a couple of files to be located in the same directory as the script itself. One is `irdomains.txt` and the other is `iriplist.txt`. The first contains website addresses, and the second contains the IP ranges you wish to route directly. Both files exist in the [GitHub repository](https://github.com/emanamini/routerScripts/tree/main/scripts), but it is highly recommended that you generate them yourself. If you want to download the samples, run the following commands:
```bash
curl -L https://raw.githubusercontent.com/emanamini/routerScripts/refs/heads/main/scripts/irdomains.txt --output irdomains.txt
curl -L https://raw.githubusercontent.com/emanamini/routerScripts/refs/heads/main/scripts/iriplist.txt --output iriplist.txt
```
But before complicating things further, let me explain the two general methods for using this script: bypassing specific website traffic and bypassing the entire domestic internet traffic of a country.

### Bypassing Specific Websites
For the `irdomains.txt` file, you must monitor app and website traffic to uncover all the domains and subdomains utilized by that website. It is not an easy task, but you have the best tool at your disposal. Open the `dnsmasq` config file:
```bash
sudo nano /etc/dnsmasq.conf
```
This line exists in the config file I provided. Uncomment it:
```text
log-queries
```
Now restart the service:
```bash
srv r 2
```
Your device has acquired an IP from the router. Extract the IP from your device's network settings. Let's assume your device IP is `172.22.0.116`. Create a script:
```bash
curl -L https://raw.githubusercontent.com/emanamini/routerScripts/refs/heads/main/scripts/domain-harvest.sh --output domain-harvest.sh
chmod +x domain-harvest.sh
```
Make it executable and run it using the IP of the client that will be browsing the target websites, like this:
```bash
./domain-harvest.sh 172.22.0.116
```
Enter the server user's password to grant it execution privileges. Now, on the target device (connected to the router with IP .116), try opening a website, an app, a banking portal—whatever you want to uncover the visible and hidden addresses for—and browse around a bit. If a login is required, log in; if there is multimedia, play it. In short, be creative and dig deep. Return to the terminal. You will see a list of all DNS queries. Once you are done, press `Ctrl+C` to stop the script. A file named `domain-query.log` has now been created in that same directory. View its contents with the command below and copy the addresses:
```bash
cat domain-query.log
```
Logically, the entire list should be related to the site you were browsing, but you should review the file, remove any extraneous domains, and save the rest elsewhere because running the script again will overwrite this data. Repeat this process for other sites over and over. Once you have built a comprehensive list, paste the entire content into the `irdomains.txt` file. The exact path for this file is:
```text
/opt/router/scripts/irdomains.txt
```
You now possess your own custom, comprehensive list of domestic sites and domains that should bypass the VPN. The first step is to extract all the IPs for all these domains and subdomains. Run the following command:
```bash
/opt/router/scripts/irtr.sh e
```
This command generates the `temp_ip_list.txt` file, which contains the unique IPs resolved from all the domains in `irdomains.txt`. Since these IPs occasionally change, you must run the command above periodically to rebuild the list.
Now, run the following command to create and enforce the direct routes:
```bash
sudo /opt/router/scripts/irtr.sh a
```
Once finished, **do not forget** to re-comment the `log-queries` option in the `dnsmasq` config file and restart its service:
```bash
srv r 2
```
A quick educational tip: When managing the router, it is generally best to be in the current directory of the scripts:
```bash
cd /opt/router/scripts
```
So that executing commands remains short and simple:
```bash
sudo ./irtr.sh a
```
A brief educational explanation: pay attention to `./`. These characters denote the current directory and MUST be included to execute a script; otherwise, without `./`, the system searches the `PATH` variables (directories where binaries are stored). For example, assume you have an executable script in `/opt/router/scripts/` named `eman`. You also have a binary with the exact same name in one of the system's binary paths, say `/usr/local/bin/`. Assuming you are inside `/opt/router/scripts/`, running the command:
```bash
./eman
```
Executes the script located in the current directory (`/opt/router/scripts/`). However, the command:
```bash
eman
```
Executes the script located in `/usr/local/bin/`. The distinction between the two is vital.
Back to the `irtr.sh a` command: This command must be executed with `sudo` because system routing requires specific privileges. Now, the websites you specified will no longer use the VPN.

### Bypassing the Entire Internet of a Country
There is a more comprehensive solution for bypassing all IP blocks of a specific country. Go to the [ip2location](https://www.ip2location.com/) website. From the top menu, select `Resources` and then `Tools`. Among the options, select `Firewall List by Country`. On the new page, navigate to the `Download List` section. In the first field, select the country name from the list. In the second field, select `IPv4`. In the `Output Format` dropdown menu, select `CIDR`. Download and unzip it. You now have a file named `firewall.txt`. Open it, delete the initial header lines up to the first IP range, and save it. Now, use nano to create a file with this name on the server:
```bash
nano /opt/router/scripts/iriplist.txt
```
Paste all several thousand lines of the file into this new file, save it with `Ctrl+X` and `Y`, and exit.
If you have carefully followed all the steps I outlined, it is time to run the following command:
```bash
sudo ./irtr irlist
```
This command will directly route all traffic for that country. Depending on your system, execution might take up to a minute, so be patient.
Now, depending on whether you prefer the first method or the second method for internet bypassing, we return to the `ip-rule.sh` file and the important line:
```bash
/opt/router/scripts/irtr.sh irlist
```
If you want the service we wrote to bypass all of the country's IPs, leave this line alone. However, if you only want it to bypass the specific IPs of the sites you curated, replace this line with the following:
```bash
/opt/router/scripts/irtr.sh a
```
If you utilize this method, remember to execute the following command on the router once a week to keep your IP list updated:
```bash
/opt/router/scripts/irtr.sh e
```
Now you can enable the service, although I do not recommend it:
```bash
sudo systemctl enable --now ip-rules.service
```
Or start it manually:
```bash
sudo systemctl start ip-rules.service
```
This service's ID in my `srv` script is 4. Therefore, I can start it with `srv l 4` and enable it with `srv e 4`.
Do not confuse packet handling by the powerful Linux kernel with the `Split Tunneling` feature of VPN applications. The power and speed provided by the Linux kernel are so massive that you won't even notice the presence of several thousand routing guide lines in the traffic table. Try feeding just a few hundred traffic-splitting parameters to Windscribe—which is undeniably among the top 5 VPNs in the world in terms of quality—and compare the latency yourself to realize what an absolute monster you are building.
All these scripts intelligently prevent the addition of redundant or duplicate lines, so do not worry about running them multiple times.
**I will explain the reasoning behind my recommendation not to enable these scripts in the startup script section.**

### Route Monitoring
If an issue occurs with the `wan` network interface, `systemd-networkd` might be triggered to reset the connection. Should this happen, the route we use to bypass the VPN is destroyed, causing bypassed traffic to hit a dead end and fall back to the VPN. To prevent this, we must build a monitoring service that rapidly rebuilds the route if such an event occurs. First, create the service file:
```bash
sudo nano /etc/systemd/system/wan-watcher.service
```
```ini
[Unit]
Description=WAN Link State Watcher
After=systemd-networkd.service

[Service]
Type=simple
ExecStart=/opt/router/scripts/wan-watcher.sh
Restart=always
RestartSec=5
User=root

[Install]
WantedBy=multi-user.target
```

Download the following script:
```bash
cd /opt/router/scripts
curl -L https://raw.githubusercontent.com/emanamini/routerScripts/refs/heads/main/scripts/wan-watcher.sh --output wan-watcher.sh
```
Make it executable and reload the `Daemon`:
```bash
chmod +x /opt/router/scripts/wan-watcher.sh
srv reload
sudo systemctl start wan-watcher.service
```
This service is included in the startup script, so there is no need to `enable` it manually.

## VPN
We have reached the main event. Acquire an unlimited WireGuard or OpenVPN configuration. Ensure it provides good ping and speed. The files you receive usually have a `.conf` extension. Use the `mv` command to move each to its respective system directory while simultaneously renaming it to `tun0.conf`.
> For WireGuard, `wg` prefixes are common, but for flawless system operation and the creation of an interface named `tun0`, you MUST rename the config file to `tun0`. 

If the directory does not exist, create it with `sudo mkdir -p`. 
Assuming your config is named `eman.conf` and you are in the same directory as the file, enter the following command for WireGuard:
```bash
sudo mv ./eman.conf /etc/wireguard/tun0.conf
```
And for OpenVPN (even if the file extension is `ovpn`, the relocation process is identical):
```bash
sudo mv ./eman.conf /etc/openvpn/client/tun0.conf
```
If OpenVPN requires a username and password to connect, you must open the config file with nano:
```bash
sudo nano /etc/openvpn/client/tun0.conf
```
Add the following line to the file (I typically place it at the end of the primary variables, just before `<ca>`), or if `auth-user-pass` already exists, modify it to look like this:
```text
auth-user-pass /etc/openvpn/client/pass.txt
```
> Before saving and closing the config file, let me share a reminder. OpenVPN, on several systems of mine, would hang after a while and freeze the entire router. After extensive research and troubleshooting, I found the culprit. If your system experiences a similar issue, insert a line with the phrase `disable-dco` among the initial lines in this config file. This relatively new feature seems to have severe conflicts with certain processors.

Exit with `Ctrl+X` and `Y`. Now create a file named `pass.txt`:
```bash
sudo nano  /etc/openvpn/client/pass.txt
```
Place your username on the first line and your password on the second line. To ensure everything works correctly, start the OpenVPN service and verify the connection:
```bash
sudo systemctl start openvpn-client@tun0.service
```
Check the service status:
```bash
systemctl status openvpn-client@tun0.service
```
The OpenVPN status is displayed at the beginning of the output. You should see something resembling this:
```text
Status: "Initialization Sequence Completed"
```
To check your connection status, issue the following command in the terminal:
```bash
curl myip.wtf/json
```
The VPN IP and geographic location should reflect somewhere other than Iran, meaning your connection is working perfectly. You can use this exact command to test WireGuard as well.
An important question: How do we transfer the VPN config file to the router? There are many ways, but I have explained the easiest method at the end of the [[#Creating a Media Server - Sharing Files and Movies on the Network]] section ([[#Transferring Files to the Server]]).
Our work with the VPN is done. We will hand over its management to an intelligent script.

## VPN Manager
Download the following script:
```bash
cd /opt/router/scripts/
curl -L https://raw.githubusercontent.com/emanamini/routerScripts/refs/heads/main/scripts/vpn-manager.sh --output vpn-manager.sh
chmod +x vpn-manager.sh
```
Create a service for it:
```bash
sudo nano /etc/systemd/system/vpn-manager.service
```
```ini
[Unit]  
Description=VPN Manager Supervisor (DNSCrypt + OpenVPN/WireGuard)  
After=network-online.target  
Wants=network-online.target  
  
[Service]  
Type=simple  
ExecStart=/opt/router/scripts/vpn-manager.sh  
# Gracefully tear down active networking components when manager is stopped  
ExecStop=/bin/bash -c 'source /etc/vpn-manager.conf; systemctl stop $OPENVPN_SERVICE $WIREGUARD_SERVICE $DNSCRYPT_SERVICE'  
Restart=always  
RestartSec=10  
User=root  
  
[Install]  
WantedBy=multi-user.target
```
Create a `conf` file for the VPN manager (you can customize this file based on your needs):
```bash
sudo nano /etc/vpn-manager.conf
```
```ini
# ====================================================================  
# VPN MANAGER CONFIGURATION  
# ====================================================================  
  
# Active VPN backend ('openvpn' or 'wireguard')  
VPN_TYPE=openvpn  
  
# Interface names (Both use tun0)  
TUN_INTERFACE=tun0  
  
# Service definitions  
OPENVPN_SERVICE=openvpn-client@tun0.service  
WIREGUARD_SERVICE=wg-quick@tun0.service  
DNSCRYPT_SERVICE=dnscrypt-proxy.service  
  
# Monitoring parameters  
DNS_TEST_DOMAIN=google.com  
DNS_SERVER=127.0.0.1  
DNS_PORT=5353  
ROUTE_TEST_IP=8.8.8.8  
CHECK_INTERVAL=300  
  
# Advanced Timing & Limits  
VPN_START_TIMEOUT=30  
WIREGUARD_MAX_HANDSHAKE_AGE=300  
MAX_RECOVERY_ATTEMPTS=5  
COOLDOWN_PERIOD=1800  
  
# Safety Feature  
# Set to 'yes' to only log failures without restarting services  
# Set to 'no' to enable automatic recovery restarts  
MONITOR_ONLY=no
```
The file above assumes you are using OpenVPN. If you have a WireGuard config, change the VPN type to WireGuard at the beginning of the config file:
```ini
VPN_TYPE=wireguard
```
This service checks your connection's health status every 300 seconds (or 5 minutes) via `CHECK_INTERVAL=300`, waits 30 seconds for a successful VPN connection via `VPN_START_TIMEOUT=30`, and if it fails to restore the connection after 5 attempts (`MAX_RECOVERY_ATTEMPTS=5`), it halts retry attempts for 30 minutes via `COOLDOWN_PERIOD=1800`. Now you have a better idea of how to configure it. The `MONITOR_ONLY=no` option is for enabling or disabling the "monitor only" mode. Suppose you want to test the functionality but do not want the VPN manager doing anything other than monitoring the system (e.g., restarting the VPN). You set `MONITOR_ONLY` to `yes` and observe. This option was mostly for initial testing of the script, and you should keep it set to `no` unless the script exhibits strange behavior, forcing you to monitor it without interfering with the VPN.
If you have enabled any of the services that this supervisor manages, disable them, and if they are currently running, stop them:
```bash
sudo systemctl disable dnscrypt-proxy.service
sudo systemctl disable openvpn-client@tun0.service
sudo systemctl disable wg-quick@tun0.service

sudo systemctl stop dnscrypt-proxy.service openvpn-client@tun0.service wg-quick@tun0.service
```
Now execute the service:
```bash
sudo systemctl daemon-reload
sudo systemctl start vpn-manager.service
```
The service logically detects that `dnscrypt-proxy` is down, attempts to bring it up, and then starts OpenVPN. I spent nearly 24 hours working on this script with Gemini, so I am highly confident it detects and resolves issues excellently.
To view the live operation of the script, especially when a connection issue occurs, run this command:
```bash
sudo journalctl -u vpn-manager -f
```

## Android and iOS App
We installed these packages previously, but for reference, I will list the dependencies one more time: 
```bash
sudo pacman -S python-flask caddy dnsmasq iproute2
```
### Preparing Caddy
To ensure the app functions flawlessly, we require a valid `ssl` certificate and a domain connected to Cloudflare. You can skip this section, but acquiring a cheap or even free domain with customizable DNS records is well worth it. In this tutorial, we assume the domain `ilola.ir` is designated for this task. Replace it with your own domain in the configurations below. Go to Cloudflare and connect your domain. I provided a brief explanation on this in the [[#Creating a Custom Stamp]] section. 
On the [Cloudflare main page](https://dash.cloudflare.com), navigate to the left menu, select the `Domains` section, and then `Overview`. Select your previously added domain. Now, from the left panel, select `DNS` and then `Records`. Click the blue `Add record` button. Set the `Type` to `A`. In the `Name` field, enter the `@` character. In the `IPv4 address` field, enter your `lan` IP address, which is `172.22.0.1`. The `Proxy Status` toggle should automatically turn off. If it doesn't, turn it off manually. Click the blue `Add record` button again and repeat the previous steps, with the exception that in the `Name` field, enter `www` instead of `@` to create a new record. We now have two records tied to the `lan` IP—one pointing to the root address and the other pointing to the `www` address. Let's proceed to the next Cloudflare setting. Return to the main [dashboard](https://dash.cloudflare.com) page.

To acquire an API token, scroll down the sidebar to `Manage account`. Then, from the expanded menu, select `Account API tokens`. Click the blue `Create token` button. On the resulting page, under `Edit policy`, open the dropdown menu and change it from `Entire account` to `Specified Domains`. An option will appear next to it. Select the domain you designated for Caddy. Scroll down slightly and open `DNS & Zones`. Check the `Read` and `Edit` boxes next to `DNS`, and check the `Read` box next to `Zone`. Scroll to the bottom of the page and click the blue `Review token` button. On the next page, you should see something resembling this:
```text
ilola.ir in
e**********ni@gmail.com's Account

DNS Read
DNS Write
Zone Read
```
Now click the blue `Create token` button. An `API` key will be generated for you. Save it immediately in a secure location because it will only be displayed once. The key typically begins with the string `cfat`.

Now we will fetch the Caddy binary (`caddy`) for the system using these commands and relocate it to the proper directory:
```bash
curl -sL "https://caddyserver.com/api/download?os=linux&arch=amd64&p=github.com%2Fcaddy-dns%2Fcloudflare" -o caddy

sudo mv caddy /usr/local/bin/caddy

sudo chmod +x /usr/local/bin/caddy
```
Next, we will modify the Caddy service:
```bash
sudo systemctl edit caddy.service
```
There are two lines in the file that opens. One is near the top, and the other is slightly further down:
```text
### Anything between here and the comment below will become the contents of the drop-in file  
   
### Edits below this comment will be discarded
```
The configurations below MUST be placed exactly between these two lines, otherwise, they will be ignored:
```ini
### Anything between here and the comment below will become the contents of the drop-in file  
  
[Unit]  
After=network-online.target arch-portal.service  
Wants=network-online.target arch-portal.service  
StartLimitIntervalSec=60s  
StartLimitBurst=10  
  
[Service]  
# 1. Clear and override the Validation pre-check  
ExecStartPre=  
ExecStartPre=/usr/local/bin/caddy validate --config /etc/caddy/Caddyfile  
  
# 2. Clear and override the Main startup command  
ExecStart=  
ExecStart=/usr/local/bin/caddy run --environ --config /etc/caddy/Caddyfile  
  
Restart=on-failure  
RestartSec=5s  
  
### Edits below this comment will be discarded
```
This service requires the [[#VPN Portal]] as a dependency, which we will build in a few minutes. Next up is the Caddy file. Open it with nano:
```bash
sudo nano /etc/caddy/Caddyfile
```
The values below belong to my file. Treat them as a template. You must modify them according to your own variables:
```text
{
    admin "unix//run/caddy/admin.socket"
}
# 1. The Real Domain (Uses Cloudflare DNS Challenge for valid SSL!)
ilola.ir, www.ilola.ir {
    tls {
        dns cloudflare cfat_XXXXXXXX
    }
    reverse_proxy 127.0.0.1:8080
}
# 2. Pure HTTP for the Fallback IPs
http://172.22.0.1 {
    reverse_proxy 127.0.0.1:8080
}
# 3. Forced HTTPS for the Fallback IPs
https://172.22.0.1 {
    tls internal
    reverse_proxy 127.0.0.1:8080
}
```
You must replace both site names and the `API` key with your respective values. With this configuration, the portal interface becomes accessible over port 80 on the `lan` IP.

If you bypassed the Cloudflare domain registration steps, you must comment out the entirety of block 1 by placing `#` symbols at the start of its lines down to `# 2`. If you do this, your portal will throw an `ssl` error during runtime and may prevent you from installing it as a standalone app. The beauty of purchasing a domain, connecting it to Cloudflare, and applying the aforementioned configurations is precisely this automatic retrieval of a valid `ssl` certificate. 

If you configured Cloudflare, it is time for `dnsmasq` to act as the bridge between the domain address and the service. Open its config file and insert the following line among the settings:
```bash
sudo nano /etc/dnsmasq.conf
```
```text
address=/ilola.ir/172.22.0.1
```
### VPN Portal
Download the following file from Git:
```bash
cd /opt/router/scripts/
curl -L https://raw.githubusercontent.com/emanamini/routerScripts/refs/heads/main/scripts/toggle-route --output toggle-route
chmod +x /opt/router/scripts/toggle-route
```
Create these two directories:
```bash
sudo mkdir -p /opt/arch-portal/templates
sudo mkdir -p /opt/arch-portal/static
```
Now to fetch the actual portal app, written in Python:
```bash
cd /opt/arch-portal/
curl -L https://raw.githubusercontent.com/emanamini/routerScripts/refs/heads/main/scripts/app.py --output app.py
```
We also need to create a log file to track the MAC addresses of unknown devices in the future:
```bash
sudo touch /opt/arch-portal/devices.log
sudo chown net:net /opt/arch-portal/devices.log
```
Prepare a `512*512` icon in `PNG` format and place it in the directory below:
```text
/opt/arch-portal/static
```
You might ask, how? The easiest way is using `sftp`, but for now, I will opt for a quicker workaround. Download the Arch icon along with the `manifest.json` file using the commands below and place them in the directory:
```bash
cd /opt/arch-portal/static/
curl -L https://raw.githubusercontent.com/emanamini/routerScripts/refs/heads/main/opt/icon.png --output icon.png
curl -L https://raw.githubusercontent.com/emanamini/routerScripts/refs/heads/main/opt/manifest.json --output manifest.json
```
Time to build the `Frontend`. Download the `index.html` file using the following command:
```bash
cd /opt/arch-portal/templates/
curl -L https://raw.githubusercontent.com/emanamini/routerScripts/refs/heads/main/opt/index.html --output index.html
```
Now, it is time to create the `arch-portal` service. Add the following contents to it:
```bash
sudo nano /etc/systemd/system/arch-portal.service
```
```ini
[Unit]  
Description=Arch Router Web Control Portal  
After=network.target dnsmasq.service  
Wants=dnsmasq.service  
  
[Service]  
Type=simple  
User=net  
WorkingDirectory=/opt/arch-portal  
ExecStart=/usr/bin/python3 /opt/arch-portal/app.py  
  
# Graceful Restart Policy  
Restart=always  
RestartSec=5s  
StartLimitBurst=10  
StartLimitIntervalSec=60s  
  
[Install]  
WantedBy=multi-user.target
```
The portal is ready, and I highly doubt I missed anything. 
Start the services to test:
```bash
sudo systemctl daemon-reload
sudo systemctl restart dnsmasq.service
sudo systemctl start arch-portal.service
sleep 5; 
sudo systemctl start caddy
```
Now, open the site address you created for the portal on your mobile phone. For instance, `ilola.ir` or `www.ilola.ir`. You will be greeted by the portal page. Before diving into the portal's features, let's install it. On iPhone, select `Add to Home Screen` in `Safari`. On Android, be sure to open the page in Chrome and select `Install and create shortcut` (or its localized equivalent) from the side menu. It will take roughly a minute for the app to appear in your app drawer.
If you did not acquire a domain for the portal, you can access it via the `lan` address. In this tutorial, we configured two addresses for the `lan`. One is the primary IP dealing with clients, and the other is designated for easy portal access: `10.10.10.10`
Enter this exact address into the browser of a mobile phone, PC, TV, or any device equipped with a browser connected to your router to bring up the portal to toggle the VPN on or off for that device.

### Crucial Details
First and foremost, for this app, users are divided into two categories: trusted and untrusted. Untrusted users lack the ability to turn off the VPN. The VPN on/off toggle is disabled for them. They also cannot view the advanced section of the app. However, they can report their MAC address to the system administrator (that's you) via the `REGISTER THIS DEVICE` button. Upon pressing this button, the system prompts them for their device name. By entering the name and hitting submit, an entry is generated in the log file we created earlier, displaying the user's device information:
```bash
cat /opt/arch-portal/devices.log
```
This way, you can capture their MAC address, insert it into the `dnsmasq` config file, and elevate the device to trusted status at your discretion. You understood that correctly: for the application to trust someone, it must see their device's MAC address in the `dnsmasq` file. However, this condition alone is insufficient. Trusted devices must all possess an IP higher than `100` (in the fourth octet of the IP). Meaning, this range starts from `172.22.0.100` and goes up to `172.22.0.254`. Therefore, when editing the `dnsmasq.conf` file, remember to reserve IPs below 100 for the `dhcp` engine to assign randomly to unknown MACs, and allocate the higher range to users you know so the app will trust them going forward.

Beyond the ability to toggle the device's VPN, this trust grants another privilege. A dedicated advanced section unlocks in the portal for these devices. In this section, you can input the fourth octet of the IP for any device you know, and if its IP falls within the 100+ range, you can toggle its VPN on or off. Suppose you want to turn off the PlayStation's VPN, but you don't have access to the PlayStation's browser to do it locally. Simply enter the PlayStation's IP in the advanced section and turn its VPN off (remember, the PlayStation's IP must also be in the 100+ range, otherwise its VPN will not turn off). 

You can similarly report the MAC address of other devices to the system administrator. Suppose the PlayStation automatically received the IP 71 (which is viewable in the PlayStation's network settings). In the app's `Advanced Settings` section, you type the number 71 and hit `Check`. The PlayStation's MAC address will appear (the PlayStation must be powered on and connected to the network). Tap the `REGISTER TARGET MAC` button in the advanced section to send the MAC to the system admin via the log file. Now append the MAC to `dnsmasq.conf` to add the PlayStation to the trusted devices list as well. Do not forget to restart the respective service after making any changes. For example, after adding the MAC:
```bash
srv r 2
```
Or
```bash
sudo systemctl restart dnsmasq
```

## Traffic Management
As a system administrator, you must distribute traffic fairly among users. The YouTube app should not perceive a bandwidth so massive that it hogs it completely, leaving the next person joining the network struggling to stream video at `144p`. Furthermore, calculating overall traffic consumption on a per-interface basis provides excellent visibility into how much traffic routes directly versus through the VPN, enabling smarter purchasing decisions in the future. It also allows you to compare daily network quality.
### Smart Traffic Management with TC Cake
To intelligently manage traffic so everyone receives a fair share of the bandwidth, we employ Cake within TC. We could strictly limit each user's speed, but when the bandwidth is idle and no one else is using the network, it is far smarter to allocate that extra bandwidth to an active user. First, download the following script:

```bash
cd /opt/router/scripts/
curl -L https://raw.githubusercontent.com/emanamini/routerScripts/refs/heads/main/scripts/tc.sh --output tc.sh
chmod +x tc.sh
```
Look for the `skip_numbers` section within the script. You can space-separate the last octet of the IPs for devices you wish to target in this line. The script divides traffic into two distinct classes, granting these specific devices a larger chunk of the bandwidth than the rest. So, if you have a device that absolutely requires guaranteed bandwidth, place it on this list.
Now, we build a service for it:
```bash
sudo nano /etc/systemd/system/tc.service
```
```ini
[Unit]  
Description=Traffic Control  
  
[Service]  
Type=oneshot  
ExecStart=/opt/router/scripts/tc.sh  
User=root  
RemainAfterExit=yes  
  
[Install]  
WantedBy=multi-user.target
```
To reload and activate the script, use the following commands (in `srv`, the number 10 corresponds to `TC`):
```bash
srv reload
sudo systemctl start tc.service
```
If for any reason you wish to purge these rules, use the command below to delete them, and subsequent commands to check their status:
```bash
sudo tc qdisc del dev lan root
tc qdisc show dev lan
tc class show dev lan
```
These rules must be re-applied after every restart, otherwise, they will not take effect. You can either enable the service, or like me, delegate this task to the [[#startup script]].
```bash
srv e 10
```
### Monitoring System Usage by Network Interface
The absolute best tool I found for meticulously analyzing traffic status was `vnstat`. We installed it earlier. First, enable its service:
```bash
sudo systemctl enable --now vnstat.service
```
It is nearly ready, but because its commands are difficult to remember, I have prepared a simple, ready-to-use script for you. Grab the following file:
```bash
cd /opt/router/scripts/
curl -L https://raw.githubusercontent.com/emanamini/routerScripts/refs/heads/main/scripts/vns.sh --output vns.sh
chmod +x vns.sh
```
Now, create a symlink in the binaries directory:
```bash
sudo ln -s /opt/router/scripts/vns.sh /usr/local/bin/vns
```
You can now run it using the `vns` command in the terminal from anywhere on the system. 

## `startup` Script
Upon receiving power, our system rapidly boots and comes online. My system boots faster than both the modem and the access point. When the interfaces are not fully ready, `systemd` exhibits unpredictable behaviors—at least in my experience. This is where I decided to create the `startup` script, allowing the system to boot, giving other devices a moment to breathe, and sequentially enabling the services. The script is highly straightforward and linked to a service. First, create the script itself:
```bash
cd /opt/router/scripts/
curl -L https://raw.githubusercontent.com/emanamini/routerScripts/refs/heads/main/scripts/startup.sh --output startup.sh
chmod +x startup.sh
```
Sequentially, the script initially waits 40 seconds, restarts the network interfaces, spins up `dnsmasq`, follows with the `ip-rules` service, then `dnscrypt-proxy`, subsequently `vpn-manager`, then the traffic manager, and finally launches the Arch portal, Caddy, and `wan-watcher`—typically staggered by 5-second intervals. If you previously enabled any of these services, disable them now, or use `restart` instead of `start`.
Now, we create its corresponding service:
```bash
sudo nano /etc/systemd/system/delayed-startup.service
```
```ini
[Unit]  
Description=Delayed startup services  
After=multi-user.target  
  
[Service]  
Type=oneshot  
ExecStart=/opt/router/scripts/startup.sh  
  
[Install]  
WantedBy=multi-user.target
```
And enable it:
```bash
sudo systemctl enable delayed-startup.service
```

## Diagnostics (Diag)
On a `Headless` server, our access to inspect the system is confined to connecting via interfaces fed by the network. Should something happen to the system resulting in a network disruption, we are left with zero pathways to communicate with it. A diagnostic tool can illuminate what is happening inside the system and guide our troubleshooting strategy. 

The mechanism of the diagnostic tool we are building is quite fascinating. A cheap, one or two-gigabyte USB flash drive works perfectly for this. 
> You can certainly use a flash drive you rely on daily, provided you never format it after applying the configurations below.

The moment you plug this specific flash drive into the system via a `USB` port, the system identifies it and recognizes it as our diagnostic drive. It then prepares the environment to automount the diagnostic drive. Next, it executes a comprehensive script that aggregates data across all operating system components, applications, interfaces, and anything required for troubleshooting, copying it to a designated path on the diagnostic drive. Finally, it unmounts it. This entire process takes less than a minute, but as a rule of thumb, wait one minute after plugging in the diagnostic drive before safely removing it. Now, plug it into your main computer and review a snapshot of the system's health in the `Summary` file. This file pinpoints why the system became unreachable. You can hunt for further details regarding the issue within the generated directory.
But how do we implement it? You can format the flash drive (`Fat32`) via your personal computer, or you can use the router. We will use the router here. 
Exercise extreme caution when formatting via the router. A single wrong letter could format the router's hard drive and destroy all your hard work. First, list the connected devices:
```bash
lsblk -f  
NAME   FSTYPE FSVER LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINTS  
sda                                                                                  
├─sda1                                                                               
└─sda2 btrfs              7e823fa0-8XXXXXXXXXXXXXXXXXXXXXXXXXX  455.6G     1% /  
sdb    btrfs              f4149414-1XXXXXXXXXXXXXXXXXXXXXXXXXX
```
Pay close attention to my router's `lsblk -f` output. `sda2`, marked with `/`, clearly relates to the root filesystem. We must avoid it at all costs. The flash drive is the next device, namely `sdb`. If it is mounted—which it is not in our example—unmount/detach it:
```bash
sudo umount /dev/sdb
```
Now we format it with the label `DIAG` and type `FAT32`.
```bash
sudo mkfs.fat -F 32 -n DIAG /dev/sdb
```
Obtain the new `UUID` of the device with the following command:
```bash
lsblk -f
sdb    vfat   FAT32 DIAG  A7A6-EFC1
```
The device's new identifier is `A7A6-EFC1`. 
We write a new rule for `udev`:
```bash
sudo nano /etc/udev/rules.d/99-router-diag.rules
```
Place the following contents inside, ensuring you replace my `UUID` with your own `UUID`:
```text
# Trigger systemd service when the specific diagnostic USB is inserted  
ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_UUID}=="A7A6-EFC1", TAG+="systemd", ENV{SYSTEMD_WANTS}="router-diag@%k.service"
```
This file triggers the specified diagnostic service the exact moment you plug in the flash drive. Save the file with `Ctrl+X` and `Y`, and exit.
Download the following scripts:
```bash
cd /opt/router/scripts/
curl -L https://raw.githubusercontent.com/emanamini/routerScripts/refs/heads/main/scripts/router-diagnostics.sh  --output router-diagnostics.sh 
curl -L https://raw.githubusercontent.com/emanamini/routerScripts/refs/heads/main/scripts/router-diag-wrapper.sh --output router-diag-wrapper.sh
chmod +x router-diagnostics.sh
chmod +x router-diag-wrapper.sh
```
Now to build the system service for the diagnostic tool:
```bash
sudo nano /etc/systemd/system/router-diag@.service                                                                
```
```ini
[Unit]  
Description=Router Diagnostic USB Automount and Dump  
BindsTo=dev-%i.device  
After=dev-%i.device  
  
[Service]  
Type=oneshot  
# Call the wrapper script in your scripts directory  
ExecStart=/opt/router/scripts/router-diag-wrapper.sh /dev/%I
```
Save the file with `Ctrl + X` and `Y`, and exit. Then run:
```bash
sudo systemctl daemon-reload
sudo udevadm control --reload-rules
```
To ensure everything proceeds smoothly, unplug the flash drive and execute the following command in the terminal:
```bash
sudo journalctl -f
```
This command displays system operations live. Now, plug the flash drive into the system and monitor the output until you see the `Finished Router Diagnostic` message. The operation only took 9 seconds for us. Unplug the flash drive and connect it to your main system. It should contain a collection of diagnostic files.
Overall, it is a wise practice to periodically plug the flash drive into the system to review errors and warnings before the system encounters a critical failure. For example, during the creation of this very tutorial, I received a system warning and resolved it before I completely lost `ssh` access. You can, of course, run the diagnostic script independently from time to time:
```bash
mkdir ~/router-test-report
/opt/router/scripts/router-diagnostics.sh ~/router-test-report
```
And retrieve the report in the directory mentioned above.

## Creating a Media Server - Sharing Files and Movies on the Network
How does a hard drive packed with movies, TV series, and music, accessible to every device in the building, sound to you? Nearly all modern mobile phones and smart TVs are capable of streaming from a `dlna` server. We will create a dedicated multimedia directory on Arch at the path below. We will then create a user named `share` and a group named `media`. We will add the `share` and `net` users to this group, and then use `chmod` to grant members of this group full access to this directory. Next, we will connect to the `share` user via `sftp` so we can push files from our phones and computers to the server for hosting. We intentionally created a separate user so you can safely distribute its login credentials to others, allowing them to help expand the collection. However, we do not add this user to the `wheel` group, meaning it lacks `sudo` privileges and cannot modify the system, assuring you that no one can sabotage the system with its credentials.
We begin by creating the user and group, and assigning a password:
```bash
sudo groupadd media
sudo useradd -m -s /bin/bash share
sudo passwd share
```
Next, we add both system users to the `media` group:
```bash
sudo usermod -aG media net
sudo usermod -aG media share
```
Now, we create the dedicated media server directory and set the necessary permissions:
```bash
sudo mkdir -p /srv/dlna
sudo chown -R net:media /srv/dlna
sudo chmod 2775 /srv/dlna
```
Applying `setgid` ensures that new files and directories created in this path inherit group ownership. Note that the primary owner is the main `net` user, but thanks to the settings above, the `share` user will also have full access to this path. `setgid` guarantees that both users maintain full access to files in this directory.
We also create a symlink in the `share` user's home directory so that when users open the home folder via `sftp`, the server folder is right in front of them.
```bash
sudo ln -s /srv/dlna /home/share/DLNA
sudo chown -h share:share /home/share/DLNA
```
Now for configuring `minidlna`. Back up the original file and create a new one:
```bash
sudo mv /etc/minidlna.conf /etc/minidlna.conf.bck
sudo nano /etc/minidlna.conf
```
Paste the following contents into it:
```ini
port=8200
network_interface=lan
user=minidlna
media_dir=/srv/dlna/
friendly_name=Arch DLNA
db_dir=/var/cache/minidlna
#log_dir=/var/log
album_art_names=Cover.jpg/cover.jpg/AlbumArtSmall.jpg/albumartsmall.jpg/AlbumArt.jpg/albumart.jpg/Album.jpg/album.jpg/Folder.jpg/folder.jpg/Thumb.jpg/thumb.jpg
inotify=yes
enable_tivo=no
tivo_discovery=bonjour
strict_dlna=no
notify_interval=900
enable_subtitles=yes
serial=12345678  
model_number=1
```
To view additional settings, you can open the file you backed up and inspect the available options yourself. These settings work flawlessly for me. Then restart the service:
```bash
sudo systemctl restart minidlna.service
```
We previously added the `minidlna` service to the startup list, so there is no need to `enable` it manually. In our management script, row 9 corresponds to `minidlna`.
If the `minidlna` database acts up for any reason or fails to index a file properly, you can force it to rebuild the entire database from scratch with the following commands:
```bash
srv k 9
sudo rm -f /var/cache/minidlna/files.db
srv l 9
```
### Transferring Files to the Server
**But how do we populate the server folder with movies, series, and music?** This is exactly why we created the `share` user. Using this user and an application that supports `sftp`, we access the router.
For Android, the best options are `Solid Explorer` and `Amaze File Manager` to connect. On Windows, I believe newer versions of File Explorer support `sftp`, but `WinSCP` is also an excellent option. For iPhone, use `FE File explorer`. On Linux, pretty much anything works; effortlessly connect using Dolphin or `nautilus` by typing the server address into the address bar. The credentials you require are:
```text
Protocol: sftp
Server: 172.22.0.1
User: share
Password: The pass you have chosen.
Path: /home/share/
Port: 22
```
For Dolphin, and likely Windows File Explorer and `nautilus`, utilize the following address: 
```text
sftp://share@172.22.0.1/home/share/
```
It is now time to hand the above information over to the movie buffs and music lovers in the building, letting them fill the hard drive in a day so everyone can enjoy it together.
To view server statistics, you can also open the following address in your browser:
```text
http://172.22.0.1:8200/
```

**In the future, you can use this exact path to transfer non-media files as well.** For instance, imagine you downloaded a new `OpenVPN` config on your mobile phone. You open `Solid Explorer`. The server folder is right there. You enter it and copy/paste the config. Because we are in the server symlink, everything you do is physically occurring in `/srv/dlna/`, which is owned by `net`. The file is now on the server's hard drive. Log in via `ssh` effortlessly using the `net` user and move the file wherever you need it. For example:
```bash
sudo mv /srv/dlna/config.conf /etc/openvpn/client/tun0.conf
```

## Backing Up Sensitive Files
Naturally, your configuration files will evolve over time from the initial setup we performed here, based on your changing needs. A script that daily inspects configuration files and backs them up if it detects a modification can be a massive lifesaver. The script I am introducing now does exactly that. This script runs daily at 4:00 AM via `cronie`, assessing the status of every file listed within it. If a modification has occurred in any of the files or directories, the script detects it, generates a comprehensive backup—usually under a megabyte—and subsequently uploads it to [MEGA](https://mega.nz/). Create a [MEGA](https://mega.nz/) account (if you already have one, create a new one exclusively for this purpose) so we can proceed with configuring `rclone`. 
```text
https://mega.nz/
```
Once the account is created, switch to the root user and execute the following command:
```bash
sudo su
cd
rclone config
No remotes found, make a new one?  
n) New remote  
s) Set configuration password  
q) Quit config  
n/s/q>
```
Press the `n` key to create a new remote:
```text
Enter name for new remote.  
name> RouterBackup
```
Name the backup exactly as I have: `RouterBackup`. Pay close attention to capitalization. Hitting `Enter` lists all services supported by `rclone`. MEGA's corresponding number for me is `39`, but this might change in the future. Find MEGA in that general vicinity, type its corresponding number, and press `Enter`:
```text
Storage> 39  
  
Option user.  
User name.  
Enter a value.  
user>
```
It prompts you for a username. Enter the email you used to register with MEGA. In the next step, it asks for your password. Press `y` to input your MEGA password manually:
```text
Option pass.  
Password.  
Choose an alternative below.  
y) Yes, type in my own password  
g) Generate random password  
y/g> y
```
Here, you must enter your MEGA password twice and hit `Enter`:
```text
Enter the password:  
password:  
Confirm the password:  
password:
```

I advise against enabling two-factor authentication (`2fa`) on MEGA; simply hit `Enter` to skip this step. As long as your password is robust and you don't forget it, you will be fine. Otherwise, you are doomed.
```text
Option 2fa.  
The 2FA code of your MEGA account if the account is set up with one  
Enter a value. Press Enter to leave empty.  
2fa>
```
Hit `Enter` through these two prompts as well to skip them:
```text
Edit advanced config?  
y) Yes  
n) No (default)  
y/n>    
  
Configuration complete.  
Options:  
- type: mega  
- user: ema*******@gmail.com  
- pass: *** ENCRYPTED ***  
Keep this "RouterBackup" remote?  
y) Yes this is OK (default)  
e) Edit this remote  
d) Delete this remote  
y/e/d>
```
A summary of your configuration is displayed here:
```text
Current remotes:  
  
Name                 Type  
====                 ====  
RouterBackup         mega  
  
e) Edit existing remote  
n) New remote  
d) Delete remote  
r) Rename remote  
c) Copy remote  
s) Set configuration password  
q) Quit config  
e/n/d/r/c/s/q>
```
Simply press `q` to exit. To verify the connection, you can create the directory we use for storing backups and then inspect it:
```bash
rclone mkdir RouterBackup:RouterBackup  
rclone lsd RouterBackup:  
```
You should see output resembling this:
```text
-1 2026-07-19 15:52:19        -1 Router_Backup
```
The configuration file should also contain your account details. Verify its existence with the following command and finally exit the root environment with `exit`:
```bash
cat /root/.config/rclone/rclone.conf
exit
```
Your password is encrypted within this file, but rclone's encryption key is public; anyone with access to this file can extract your password. Therefore, keep access to this file strictly restricted and do not share it with anyone.
Download the primary script with the following command:
```bash
cd /opt/router/scripts/
curl -L https://raw.githubusercontent.com/emanamini/routerScripts/refs/heads/main/scripts/rclone-backup.sh --output rclone-backup.sh
chmod +x rclone-backup.sh
```
Now it is time to append a cron job for the root user:
```bash
sudo EDITOR=nano crontab -e
```
Add the following line to it:
```text
0 4 * * * /opt/router/scripts/rclone-backup.sh >> /opt/router/backup-state/cron.log 2>&1
```
Save and exit.
Ensure the cron service is enabled:
```bash
sudo systemctl enable --now cronie.service
```
The backup configuration is complete, but to guarantee everything runs smoothly, execute it once manually. You might receive errors about files that do not exist, which is inconsequential.
```bash
sudo /opt/router/scripts/rclone-backup.sh
```
Because `rclone` is executed with root user privileges, it searches for the config in a different path than the configuration file we just created together. We have explicitly defined this path in line `18` of the script. Merely keep in mind how `rclone` operates; otherwise, you do not need to take any special actions.
My output looked something like this:
```text
2026-08-01 00:25:14 Checking configuration... Changes detected.  
2026-08-01 00:25:14 Warning: Path /etc/nftables.d does not exist. Skipping.  
2026-08-01 00:25:14 Created and verified archive: router-2026-08-01_002514.tar.zst  
2026-08-01 00:25:16 Syncing to MEGA...  
2026-08-01 00:25:24 rclone sync successful
```
To add a file or directory to the backup, simply open the script:
```bash
nano /opt/router/scripts/rclone-backup.sh
```
Append files to this section using this exact format:
```bash
FILES=(  
   "/etc/fstab"  
   "/etc/nftables.conf"  
   "/etc/dnsmasq.conf"
```
And directories to this section:
```bash
DIRS=(  
   "/opt/router/scripts"  
   "/root/.ssh"
```
To prevent others from accessing the files, the script alters the permission of the backup directory to `700`, but remember that protecting it remains your responsibility. The backup file will house your system's critical information. Also, bear in mind that 50 backup files are retained; subsequently, older files are automatically purged from both the disk and MEGA. You can modify this count on line `16` of the script.

## Additional Optimizations
### Filesystem Configurations
Here we will briefly cover actions you can take to reduce the workload on your hard drive. Open the `fstab` file and modify the options on the root mount line to reflect these options:
```text
UUID=XXXXXXXXXXXXXXXXXXXXXXX  /  btrfs  rw,noatime,commit=120,space_cache=v2,subvol=/@  0 0
```
In sequence: `rw` instructs the system to mount the filesystem as read/write. `noatime` ensures the system refrains from updating the access time every single time a file or directory is read. You rarely need this update, and it merely accelerates the aging of your disk. The `relatime` option conflicts with this; ensure only one is active. Therefore, disabling it in favor of `noatime` is highly logical. `commit=120` instructs the system to commit new changes and metadata in RAM to the disk every 120 seconds instead of every 5 seconds. Enable this option only when your system reaches a stable state; in the event of a sudden power loss or crash, the last 120 seconds of changes might contain crucial, useful data for troubleshooting that will be lost. But once the system stabilizes, this significantly extends the health of your disk. The presence of the `space_cache=v2` option forces the filesystem to utilize the newer `space_cache` iteration, boasting vastly improved performance over the first version.

### Secondary Application Configurations
Now, create the following file to optimize syncing data from RAM to disk:
```bash
sudo nano /etc/sysctl.d/99-disk-writes.conf
```
```ini
# Hold dirty memory pages longer in RAM before syncing to disk
vm.dirty_background_ratio = 5
vm.dirty_ratio = 10
vm.dirty_writeback_centisecs = 1500
```
And apply it:
```bash
sudo sysctl --system
```
A few more minor tweaks:
Dump `dnsmasq` leases into RAM by appending this line to its config file:
```bash
sudo nano /etc/dnsmasq.conf
```
```text
dhcp-leasefile=/run/dnsmasq.leases
```
And likewise, add this line to the `OpenVPN` config file to flush the status log into RAM:
```text
status /run/openvpn-status.log
verb 1
```

### `journald` Configurations
Journals also consume significant space after a while. This data is typically irrelevant after two days. To instruct the system not to retain logs older than two days and to cap them at 100 MB, open the file below. Either locate the following lines and uncomment them while assigning the new values, or simply ignore searching and insert these few lines among the settings:
```ini
[Journal]
Storage=persistent
MaxRetentionSec=2day
SystemMaxUse=100M
```
Then apply the settings:
```bash
sudo systemctl restart systemd-journald
```
This command also sweeps away journals older than 2 days:
```bash
sudo journalctl --vacuum-time=2d
```

### BTRFS Filesystem Status
I avoided entering the BTRFS realm for years, clinging tightly to ext4, but I must confess I was wrong. This filesystem truly lives up to its name, `Better FS`. I will outline a few critical commands for checking system status and resolving issues. First, verifying the filesystem: try to run a comprehensive check every month to ascertain your disk's health status:
```bash
sudo btrfs device stats /  

[/dev/sda2].write_io_errs    0  
[/dev/sda2].read_io_errs     0  
[/dev/sda2].flush_io_errs    0  
[/dev/sda2].corruption_errs  0  
[/dev/sda2].generation_errs  0
```
Your output should mirror my system's output. If you encounter errors, use the following command to verify data checksums against their blocks:
```bash
sudo btrfs scrub start /
```
And use this command to check the status of the scrub the system is actively performing:
```bash
sudo btrfs scrub status /
```
Alternatively, you can use the `-B` option to run the scrub in the foreground. 
```bash
sudo btrfs scrub start -B /
```
Regardless, if the final scrub status ultimately yields an error-free output:
```text
sudo btrfs scrub status /  
UUID:             7e823fa0-8f26-41e0-90ba-553317b8ec79  
Scrub started:    Sat Aug  1 01:00:56 2026  
Status:           finished  
Duration:         0:02:07  
Total to scrub:   14.46GiB  
Rate:             116.61MiB/s  
Error summary:    no errors found
```
And you previously received an error, the scrub does not reset the error log counter. You must manually reset it to zero:
```bash
sudo btrfs device stats -z /
```

### Disk Health
You can inquire about your disk's health using `smartctl`:
```bash
sudo smartctl -a /dev/sda
```
Substitute your actual disk name in place of `sda`. The output will be quite lengthy. In the very first lines, search for something resembling this. It indicates your disk's overall health is good:
```text
SMART overall-health self-assessment test result: PASSED
```
For complete assurance, inspect the `RAW_VALUE` column for the following factors in the `SMART Attributes` table further down; their values must absolutely be `0`:
```text
Reallocated_Sector_Ct
Current_Pending_Sector
UDMA_CRC_Error_Count
```
