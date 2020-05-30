fio -filename=/opt/data/vanda/fio_28/fsb_test2 -direct=1 -iodepth 16 -thread -rw=randwrite -ioengine=libaio -bs=16k -numjobs=30 -runtime=3600 -group_reporting -name=fsb1 -size=3200G
