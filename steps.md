cp -r /home/tcn/software/vanda/r48996 /opt/data/vanda


# 2 partition
sudo mkfs -t ext4 /dev/sfdv0n1p1
sudo mount  -o discard,noatime /dev/sfdv0n1p1 /opt/data/vanda
sudo chown -R tcn:tcn /opt/data/vanda
mkdir /opt/data/vanda/fio

sudo mkfs -t ext4 /dev/sfdv0n1p2
sudo mount  -o discard,noatime /dev/sfdv0n1p2 /opt/data/vanda2
sudo chown -R tcn:tcn /opt/data/vanda2
mkdir /opt/data/vanda2/fio

# fio commandline 
# write file
sudo fio -directory=/opt/data/vanda/fio -name=sfdv0n1_24_randread -group_reporting -thread -ioengine=libaio -direct=1 -iodepth 32 -bs=8k -size=20G -rw=randread -numjobs=24 -runtime=300 --output=/opt/app/benchmark/fsb/benchbox/fio/24-20200409_164929/sfdv0n1/randread-file

# write 裸设备
sudo fio -filename=/dev/sfdv0n1 -name=sfdv0n1_24_randread -group_reporting -thread -ioengine=libaio -direct=1 -iodepth 32 -size=100% -bs=8k -rw=randread -numjobs=24 -runtime=300 --output=/opt/app/benchmark/fsb/benchbox/fio/24-20200409_164929/sfdv0n1/randread_24.report
