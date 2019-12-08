# ReflectorUnlink

These script files work together to help manage DStar reflector linking and
unlinking on a pi-star system.

checkLink.sh should be run on a cron job periodically. It will examine the
pi-star logs and determine if it is time to disconnect the reflector. It uses
multiple criteria to determine if it should disconnect, as listed here:
    - If there is no link active, nothing will happen.
    - If the flag indicating the link was made by netLink.sh, nothing will
        happen.
    - If the above criteria are met:
        - Get last link time.
        - Get last RF activity time, if any.
        - Set delta time to now minus least of last link time and last RF time.
        - If delta time is greater than inactivity time, then disconnect
            from reflector

I have these script files in /home/pi-star/bin but you can put them elsewhere
if you wish. Just make sure you set your cron jobs to the proper location.
As you can see in checkLink.sh, I have mine set to 3600 seconds (one hour)
of inactivity. I have it run via crontab every five minutes. Also note you
need to put in the callsign for your repeater or hotspot. When putting these
files on your pi-star, you will need to issue rpi-rw to remount the filesystem
as writable. I use putty to connect for this and  winscp to copy the files to
the proper folders. You'll also need putty or something similar to setup
your cron jobs (sudo crontab -e).

netLink.sh can be used to make timed connections to reflectors for scheduled
nets. Since it calls the pistar-link script, it takes the same arguments and
passes them on. The format is ref030_b for reflector 30 B. Also unlink is used
to unlink the reflector. netLink.sh simply adds the setting and clearing of
/tmp/netLink.flag that is used by checkLink.sh to determine if this is a
scheduled link for nets and does not do the disconnect on inactivity if so.

The easiest way to get this on you pi-star system is to log in as root and
use git to pull the repository to where you want it to reside. I do mine in
the root user directory (/root). By using git you can come back later as
needed and pull any updates or even roll back to any previous versions.
Here is the sequence of commands I use to do this from either an ssh terminal
session or via the SSH Access option in the Expert Configuration screen. You
can just copy and paste the entire block and paste it into your ssh session
(usually using Shift-Insert).

```bash
sudo -s
cd
# at this point run pwd to verify it displays /root
pwd
git clone https://github.com/wb4bxo/pi-star-ReflectorUnlink.git
chmod a+x pi-star-ReflectorUnlink/*.sh
exit
```

At this point you are ready to setup your cronjob(s) to run these scripts
using "sudo crontab -e". Note, if you get an error when you save your cronjobs
that it is most likely due to the fact that the file system on pi-star is
usually mounted read-only. To keep from loosing your cronjob you can open
another ssh session and run rpi-rw, then save again in the crontab editor.
Here is what I have in my root's crontab:

```bash
## Check for idle reflectors linked
*/5 * * * * /root/pi-star-ReflectorUnlink/checkLink.sh

## SE DStar weather net
55 20 * * 0 /root/pi-star-ReflectorUnlink/netLink.sh ref004_a fixed
00 22 * * 0 /root/pi-star-ReflectorUnlink/netLink.sh unlink

## Ham Nation after show net
45 21 * * 3 /root/pi-star-ReflectorUnlink/netLink.sh ref014_c fixed
00 00 * * 4 /root/pi-star-ReflectorUnlink/netLink.sh unlink
```

Hope you find this useful.
Feel free to give feedback, good, bad or suggestions.

Steve - WB4BXO
www.wb4bxo.us
