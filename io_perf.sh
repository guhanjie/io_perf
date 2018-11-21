## IO Performance Test Suite
## Author: guhanjie
## Version: 0.1
## Update: 2018-11-20 18:24:29

################################################
##                  环境变量                   ##
################################################
read -p "Please input test dir" TEST_DIR
OUTPUT_DIR=$TEST_DIR/output
TEST_TOOLS=$TEST_DIR/tools
FIO_BIN=$TEST_TOOLS/fio
IOR_BIN=$TEST_TOOLS/ior
MDTEST_BIN=$TEST_TOOLS/mdtest

################################################
##                预装测试环境                  ##
################################################
## Install Pre-requisites(Open-MPI, git, automake, libaio-devel)
echo "===============> start install pre-requisites tools <==============="
sudo yum install -y gcc gcc-gfortran gcc-c++ openmpi-devel openmpi git automake libaio-devel

## Install FIO
echo "===============> start install fio <==============="
cd $TEST_TOOLS/
git clone https://github.com/axboe/fio.git
cd fio/
./configure
make
make install

## Install IOR and MDTest
echo "===============> start install ior and mdtest <==============="
cd $TEST_TOOLS/
git clone https://github.com/hpc/ior.git
cd ior/
module load mpi/openmpi-x86_64
./bootstrap
./configure
make
make install


##***************************************************************************##
##====================               dd测试              ====================##
##***************************************************************************##
echo "===============> start dd test <==============="
TEST_DD=$TEST_DIR/dd
mkdir -p $TEST_DD
for i in 1 16 64 128 256 512
do
  mpirun -np $i -f mpi_hfile dd if=/dev/zero of=$TEST_DD/`hostname` bs=1M count=8000 oflag=sync &> $OUTPUT_DIR/dd_`hostname`.log
done
echo "===============> dd test done <==============="


##***************************************************************************##
##====================               FIO测试             ====================##
##***************************************************************************##
echo "===============> start fio test <==============="
TEST_FIO=$TEST_DIR/fio
mkdir -p $TEST_FIO
################################################
##                  吞吐测试                   ##
################################################
#### 1M顺序写
for i in 1 16 64 128 256 512
do
  mpirun -np $i -f mpi_hfile $FIO_BIN -name=1M_write_`hostname` --directory=$TEST_FIO/ -numjobs=1 -iodepth=128 -rw=write -bs=1M -size=8g -ioengine=posixaio -time_based -runtime=180 -ramp_time=6 -group_reporting -output=$OUTPUT_DIR/fio_1M_write_`hostname`.log
done
echo "######## FIO吞吐测试: 1M seq write done. ########"

#### 1M随机写
for i in 1 16 64 128 256 512
do
  mpirun -np $i -f mpi_hfile $FIO_BIN -name=1M_randwrite_`hostname` --directory=$TEST_FIO/ -numjobs=1 -iodepth=128 -rw=randwrite -bs=1M -size=8g -ioengine=posixaio -time_based -runtime=180 -ramp_time=6 -group_reporting -output=$OUTPUT_DIR/fio_1M_randwrite_`hostname`.log
done
echo "######## FIO吞吐测试: 1M rand write done. ########"

#### 1M顺序读
for i in 1 16 64 128 256 512
do
  mpirun -np $i -f mpi_hfile $FIO_BIN -name=1M_read_`hostname` --directory=$TEST_FIO/ -numjobs=1 -iodepth=128 -rw=read -bs=1M -size=8g -ioengine=posixaio -time_based -runtime=180 -ramp_time=6 -group_reporting -output=$OUTPUT_DIR/fio_1M_read_`hostname`.log
done
echo "######## FIO吞吐测试: 1M seq read done. ########"

#### 1M随机读
for i in 1 16 64 128 256 512
do
  mpirun -np $i -f mpi_hfile $FIO_BIN -name=1M_randread_`hostname` --directory=$TEST_FIO/ -numjobs=1 -iodepth=128 -rw=randread -bs=1M -size=8g -ioengine=posixaio -time_based -runtime=180 -ramp_time=6 -group_reporting -output=$OUTPUT_DIR/fio_1M_randread_`hostname`.log
done
echo "######## FIO吞吐测试: 1M rand write done. ########"

#### 1M顺序混合读写
for i in 1 16 64 128 256 512
do
  mpirun -np $i -f mpi_hfile $FIO_BIN -name=1M_rw_`hostname` --directory=$TEST_FIO/ -numjobs=1 -iodepth=128 -rw=rw -bs=1M -size=8g -ioengine=posixaio -time_based -runtime=180 -ramp_time=6 -group_reporting -output=$OUTPUT_DIR/fio_1M_rw_`hostname`.log
done
echo "######## FIO吞吐测试: 1M mixed seq rw done. ########"

#### 1M随机混合读写
for i in 1 16 64 128 256 512
do
  mpirun -np $i -f mpi_hfile $FIO_BIN -name=1M_randrw_`hostname` --directory=$TEST_FIO/ -numjobs=1 -iodepth=128 -rw=randrw -bs=1M -size=8g -ioengine=posixaio -time_based -runtime=180 -ramp_time=6 -group_reporting -output=$OUTPUT_DIR/fio_1M_randrw_`hostname`.log
done
echo "######## FIO吞吐测试: 1M mixed rand rw done. ########"

################################################
##                IOPS和延迟测试                ##
################################################
#### 4K顺序写
for i in 1 16 64 128 256 512
do
  mpirun -np $i -f mpi_hfile $FIO_BIN -name=4K_write_`hostname` --directory=$TEST_FIO/ -numjobs=1 -iodepth=128 -rw=write -bs=4K -size=8g -ioengine=posixaio -time_based -runtime=180 -ramp_time=6 -group_reporting -output=$OUTPUT_DIR/fio_4K_write_`hostname`.log
done
echo "######## FIO IOPS测试: 4K seq write done. ########"

#### 4K随机写
for i in 1 16 64 128 256 512
do
  mpirun -np $i -f mpi_hfile $FIO_BIN -name=4K_randwrite_`hostname` --directory=$TEST_FIO/ -numjobs=1 -iodepth=128 -rw=randwrite -bs=4K -size=8g -ioengine=posixaio -time_based -runtime=180 -ramp_time=6 -group_reporting -output=$OUTPUT_DIR/fio_4K_randwrite_`hostname`.log
done
echo "######## FIO IOPS测试: 4K rand write done. ########"

#### 4K顺序读
for i in 1 16 64 128 256 512
do
  mpirun -np $i -f mpi_hfile $FIO_BIN -name=4K_read_`hostname` --directory=$TEST_FIO/ -numjobs=1 -iodepth=128 -rw=read -bs=4K -size=8g -ioengine=posixaio -time_based -runtime=180 -ramp_time=6 -group_reporting -output=$OUTPUT_DIR/fio_4K_read_`hostname`.log
done
echo "######## FIO IOPS测试: 4k seq read done. ########"

#### 4K随机读
for i in 1 16 64 128 256 512
do
  mpirun -np $i -f mpi_hfile $FIO_BIN -name=4K_randread_`hostname` --directory=$TEST_FIO/ -numjobs=1 -iodepth=128 -rw=randread -bs=4K -size=8g -ioengine=posixaio -time_based -runtime=180 -ramp_time=6 -group_reporting -output=$OUTPUT_DIR/fio_4K_randread_`hostname`.log
done
echo "######## FIO IOPS测试: 4k rand read done. ########"

#### 4K顺序混合读写
for i in 1 16 64 128 256 512
do
  mpirun -np $i -f mpi_hfile $FIO_BIN -name=4K_rw_`hostname` --directory=$TEST_FIO/ -numjobs=1 -iodepth=128 -rw=rw -bs=4K -size=8g -ioengine=posixaio -time_based -runtime=180 -ramp_time=6 -group_reporting -output=$OUTPUT_DIR/fio_4K_rw_`hostname`.log
done
echo "######## FIO IOPS测试: 4k mixed seq rw done. ########"

#### 4K随机混合读写
for i in 1 16 64 128 256 512
do
  mpirun -np $i -f mpi_hfile $FIO_BIN -name=4K_randrw_`hostname` --directory=$TEST_FIO/ -numjobs=1 -iodepth=128 -rw=randrw -bs=4K -size=8g -ioengine=posixaio -time_based -runtime=180 -ramp_time=6 -group_reporting -output=$OUTPUT_DIR/fio_4K_randrw_`hostname`.log
done
echo "######## FIO IOPS测试: 4k mixed rand rw done. ########"
echo "===============> fio test done <==============="


##***************************************************************************##
##====================               IOR测试             ====================##
##***************************************************************************##
echo "===============> start ior test <==============="
TEST_IOR=$TEST_DIR/ior
mkdir -p $TEST_IOR
################################################
##                  吞吐测试                   ##
################################################
#### Single File, Multiple Clients, Streaming, 多客户端以1M块大小并行顺序写同一个文件
for i in 1 16 64 128 256 512
do
  mpirun -np $i -f mpi_hfile $IOR_BIN -a MPIIO -v -B -g -e -w -r -t 1M -b 4G -C -Z -i 3 -T 3 -o $TEST_IOR/single_shared_1M_file.dat &| tee $OUTPUT_DIR/ior_single_shared_1M_seq_`hostname`.log 
done
echo "######## IOR吞吐测试: single shared file 1M seq rw done. ########"

#### Multiple Files per Process, Multiple Clients, Streaming, 多客户端以1M块大小并行顺序写不同文件
for i in 1 16 64 128 256 512
do
  mpirun -np $i -f mpi_hfile $IOR_BIN -a MPIIO -v -B -g -e -w -r -t 1M -b 4G -C -Z -i 3 -T 3 -F -u -o $TEST_IOR/multi_1M_file.dat &| tee $OUTPUT_DIR/ior_multi_files_1M_seq_`hostname`.log 
done
echo "######## IOR吞吐测试: multi files 1M seq rw done. ########"

################################################
##                IOPS和延迟测试                ##
################################################
#### Single Shared File, Multiple Clients, Random I/O，多客户端以4K大小并行随机读写同一个文件
for i in 1 16 64 128 256 512
do
  mpirun -np $i -f mpi_hfile $IOR_BIN -a MPIIO -v -B -g -e -w -r -t 4K -b 4G -C -Z -z -i 3 -T 3 -o $TEST_IOR/single_shared_4K_file.dat &| tee $OUTPUT_DIR/ior_single_shared_4K_random_`hostname`.log 
done
echo "######## IOR吞吐测试: single shared file 4K rand rw done. ########"

#### Multiple Files per Process, Random I/O，多客户端以4K大小并行随机读写不同文件
for i in 1 16 64 128 256 512
do
  mpirun -np $i -f mpi_hfile $IOR_BIN -a MPIIO -v -B -g -e -w -r -w -t 4K -b 4G -C -Z -z -i 3 -T 3 -F -u -o $TEST_IOR/multi_4K_file.dat &| tee $OUTPUT_DIR/ior_multi_files_4K_random_`hostname`.log 
done
echo "######## IOR吞吐测试: multi files 4K rand rw done. ########"
echo "===============> ior test done <==============="


##***************************************************************************##
##====================            MDTest测试             ====================##
##***************************************************************************##
echo "===============> start metest test <==============="
TEST_MDTEST=$TEST_DIR/mdtest
mkdir -p $TEST_MDTEST
#### Single Shared Target Dir, Multiple Clients, no data
for i in 1 16 64 128 512
do
  mpirun -np $i -f mpi_hfile $MDTEST_BIN -i 3 -I 8 -z 5 -b 5 -d $TEST_MDTEST | tee $OUTPUT_DIR/mdtest_nodata_ops_`hostname`.log 
done
echo "######## MDTest OPS测试: single shared target no data ops done. ########"

#### Single Shared Target Dir, Multiple Clients, with 4K data
for i in 1 16 64 128 512
do
  mpirun -np $i -f mpi_hfile $MDTEST_BIN -i 3 -I 8 -z 5 -b 5 -e 4096 -w 4096 -d $TEST_MDTEST | tee $OUTPUT_DIR/mdtest_withdata_ops_`hostname`.log 
done
echo "######## MDTest OPS测试: single shared target with data ops done. ########"

#### Multi Target Dirs, Multiple Clients
for i in 1 16 64 128 512
do
  mpirun -np $i -f mpi_hfile $MDTEST_BIN -i 3 -I 8 -z 5 -b 5 -u -d $TEST_MDTEST | tee $OUTPUT_DIR/mdtest_multi_nodata_ops_`hostname`.log 
done
echo "######## MDTest OPS测试: multi target no data ops done. ########"

#### Multi Target Dirs, Multiple Clients, Randomly stat
for i in 1 16 64 128 512
do
  mpirun -np $i -f mpi_hfile $MDTEST_BIN -i 3 -I 8 -z 5 -b 5 -R -u -d $TEST_MDTEST | tee $OUTPUT_DIR/mdtest_multi_nodata_random_stat_ops_`hostname`.log 
done
echo "######## MDTest OPS测试: multi target random stat ops done. ########"

#### Single Target Dir, Multiple Meta ops, 100w small files/dirs
for i in 1 16 64 128 512
do
  mpirun -np $i -f mpi_hfile $MDTEST_BIN -i 3 -n 1000000 -z 5 -b 5 -d $TEST_MDTEST | tee $OUTPUT_DIR/mdtest_100w_nodata_ops_`hostname`.log 
done
echo "######## MDTest OPS测试: 100w files/dirs no data ops done. ########"

#### 扁平目录结构（Shallow Directory Structure）
for i in 1 16 64 128 512
do
  mpirun -np $i -f mpi_hfile $MDTEST_BIN -i 3 -I 1000000 -z 1 -b 1 -d $TEST_MDTEST | tee $OUTPUT_DIR/mdtest_100w_shallow_nodata_ops_`hostname`.log 
done
echo "######## MDTest OPS测试: 扁平目录结构ops测试 done. ########"

#### 深目录结构（Deep Directory Structure）
for i in 1 16 64 128 512
do
  mpirun -np $i -f mpi_hfile $MDTEST_BIN -i 3 -I 8 -z 8 -b 4 -d $TEST_MDTEST | tee $OUTPUT_DIR/mdtest_deep_nodata_ops_`hostname`.log 
done
echo "######## MDTest OPS测试: 深目录结构ops测试 done. ########"
echo "===============> metest test done <==============="