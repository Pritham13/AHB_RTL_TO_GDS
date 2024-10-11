num_rw_ports    = 0
num_r_ports     = 1 
num_w_ports     = 1

word_size       = 32
num_words       = 256
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
