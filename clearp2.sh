sudo umount /dev/sfdv0n1p2
sudo mkfs -t ext4 /dev/sfdv0n1p2
sudo mount /dev/sfdv0n1p2 /opt/data/vanda2
sudo chown -R tcn:tcn /opt/data/vanda2
mkdir /opt/data/vanda2/fio
