#/bin/bash
cpu_core_count=`grep MHz /proc/cpuinfo  | wc -l`

dev_list=${dev_list-"sfdv0n1"}
numjobs_list=${numjobs_list-"1 8 ${cpu_core_count}"}
jobtype_list=${jobtype_list-"randwrite randrw randread"}
runtime=${runtime-3600}

timestamp=`date +"%Y%m%d_%H%M%S"`
out_dir=/home/`whoami`/benchmark/fio/tantan-${timestamp}

pin_cpu="-cpus_allowed=0" #only for 1 job case

if [ "$1" == "drill" ]; then runtime=10; fi

for dev in ${dev_list};
do
	result_dir=${out_dir}/${dev}
	mkdir -p ${result_dir}
    echo ${dev} | grep sfd
    if [ $? -eq 0 ]; 
    then 
        sudo chmod +r /var/log/sfx_messages
        tail -f -n0 /var/log/sfx_messages > ${result_dir}/sfx_messages &
        tail_pid=$!
    fi 
	for numjobs in ${numjobs_list};
	do
		if [ ${numjobs} -ne 1 ]; then pin_cpu=""; fi
		for jobtype in ${jobtype_list};
		do
			output_file=${result_dir}/${jobtype}_${numjobs}
			iostat -dxmct 1 ${dev} > ${output_file}.iostat &
			iostat_pid=$!
            cmd="fio -filename=/dev/${dev} \
 -name=${dev}_${numjobs}_${jobtype} \
 -group_reporting \
 -thread \
 -ioengine=libaio \
 -direct=1 \
 -iodepth 32 \
 -size=100% \
 -bs=8k \
 -rw=${jobtype} \
 -numjobs=${numjobs} \
 -runtime=${runtime} \
 --output=${output_file}.report \
 ${pin_cpu}"
                 
            echo ${cmd}
            
			sudo ${cmd}
			kill -9 ${iostat_pid}

            # convert iostat output to csv file, including both io / cpu data
			iostat_file=${output_file}.iostat
			grep -m1 Device ${iostat_file} | sed -r "s/\s+/,/g" > ${iostat_file}.io.csv
			grep ${dev} ${iostat_file} | sed -r "s/\s+/,/g" >> ${iostat_file}.io.csv
			grep -m1 avg-cpu ${iostat_file} | sed -r "s/\s+/,/g" > ${iostat_file}.cpu.csv
			grep -A1 avg-cpu ${iostat_file} | grep -v \- | sed -r "s/\s+/,/g" >> ${iostat_file}.cpu.csv
            echo ts > ${iostat_file}.ts.csv
            grep [0-9]:[0-9] ${iostat_file} | grep -v iostat >> ${iostat_file}.ts.csv
			paste -d, ${iostat_file}.ts.csv ${iostat_file}.io.csv ${iostat_file}.cpu.csv > ${iostat_file}.csv
			rm ${iostat_file}.io.csv ${iostat_file}.cpu.csv ${iostat_file}.ts.csv ${iostat_file}
		done
	done
    if [ "${tail_pid}" != "" ]; then kill -9 ${tail_pid}; fi
    echo ${WORKSPACE} | grep /home/`whoami`
    if [ $? -eq 0 ];
    then
        if [ -d ${WORKSPACE}/test_output ]; 
        then 
            rm -rf ${WORKSPACE}/test_output/*
        fi
        
        mkdir -p ${WORKSPACE}/test_output/${dev}
        cp ${result_dir}/*.csv ${WORKSPACE}/test_output/${dev}
        tar czf ${WORKSPACE}/test_output/${dev}/sfx_messages.tgz ${result_dir}/sfx_messages
        
        pushd ${WORKSPACE}/test_output/${dev}
        export CSV_FILE_LIST=`ls -tr *.csv | sort -t_ -k2n -k1r`
        popd

        ../../sysbench/lib/csv2chart.py -l 4,5 -r 18,19 \
            -d ${WORKSPACE}/test_output/${dev} \
            -o ${WORKSPACE}/test_output/${dev}/result.png
    fi
done

