# Memory compiler 

The memory compiler used is a open Source memory compiler called [OpenRam](https://openram.org/)

It runs on miniconda
 

for installation use the following commands 

```bash
git clone https://github.com/VLSIDA/OpenRAM.git 
cd OpenRAM 
./install_conda.sh 
```

and post installation for testing 

```bash 
cd OpenRAM 
mkdir test 
source setpaths.sh
cd test
python3 $OPENRAM_HOME/../sram_compiler.py SRAM_32x128_1rw-cfg.py
```
SRAM_32x128_1rw-cfg.py is as follows 

```python3 
num_rw_ports    = 1
num_r_ports     = 0
num_w_ports     = 0

word_size       = 32
num_words       = 128
num_banks       = 1
words_per_row   = 4

tech_name       = "freepdk45"
process_corners = ["TT"]
supply_voltages = [1.1]
temperatures    = [25]

route_supplies  = True
check_lvsdrc    = False

output_path     = "SRAM_32x128_1rw"
output_name     = "SRAM_32x128_1rw"
instance_name   = "SRAM_32x128_1rw"
```


