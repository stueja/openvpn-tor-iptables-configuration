#!/bin/bash
# http://www.cyberciti.biz/faq/unix-linux-getting-current-date-in-bash-ksh-shell-script/


#todo: je nach ip-adresse auf anderes ziel
# hostname -i

calendarweek="$(date +'%V')"
backuplocation=/home/juser/backups/
suffix=backup
#backuplocation=$backuplocation$calendarweek$suffix/
mkdir $backuplocation
#echo $backuplocation
filestobackup=/root/files2backup.txt
i=0

#arch:
pacman -Qqe > /home/juser/backups/pacman-Qqe.txt
expac --timefmt=%Y%m%d%H%M%S '%l\t%w\t%n-%v' | grep -v 'dependency' | sort -n > /home/juser//backups/pacman-expac.txt
while read file
do
        # skip comments
        [[ "$file" =~ ^#.*$ ]] && continue
        # skip empty lines
        [[ "$file" =~ ^\s*$ ]] && continue
        #echo "testing whether $file is newer than backup"
        cp --preserve --verbose --update --parents $file $backuplocation
done < $filestobackup

echo "generating tree"
#tree -ug -o /home/pi/primotree.txt $backuplocation
#cp /home/pi/primotree.txt $backuplocation

echo "Local Copy Finished."

#cp -r $backuplocation /home/juser/
chown -R juser:juser /home/juser/backups/

