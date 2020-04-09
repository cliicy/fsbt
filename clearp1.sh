sudo umount /dev/sfdv0n1p1
sudo mkfs -t ext4 /dev/sfdv0n1p1
sudo mount /dev/sfdv0n1p1 /opt/data/vanda
sudo chown -R tcn:tcn /opt/data/vanda
mkdir /opt/data/vanda/fio
