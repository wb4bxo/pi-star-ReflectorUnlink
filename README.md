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

Here is what I have in my root's crontab:

```bash
## Check for idle reflectors linked
*/5 * * * * /home/pi-star/bin/checkLink.sh

## SE DStar weather net
55 20 * * 0 /home/pi-star/bin/netLink.sh ref004_a fixed
00 22 * * 0 /home/pi-star/bin/netLink.sh unlink

## Ham Nation after show net
45 21 * * 3 /home/pi-star/bin/netLink.sh ref014_c fixed
00 00 * * 4 /home/pi-star/bin/netLink.sh unlink
```


Hope you find this useful.
Feel free to give feedback, good, bad or suggestions.

Steve - WB4BXO
www.wb4bxo.us
