## Simple Transfer
- main clk : HLCK
- first clk cycle : address is sent in the 32 bit address bus 
- second cycle : data is sent/received  on the 32 bit data bus

![[Pasted image 20240929181925.png]]

> Note : starting stage 32 bit data transfer , non burst transfer

The address of the next data will be sent in the data cycle of the previous data this way pipeline is achieved 
### FSM states 
- Wait stage 
	-  waits for `HPREADY` to go high
-  Request state 
	-  request to use the bus is sent to the arbiter i.e `HBUSREQ` is pulled to 1 
	-  on receiving the usage of the bus i.e when `HGRANT` is pulled high we go on to the address sending stage 
-  Address stage (2 cycles)
	- Address is sent on the `HADDR` bus and on recieving the ack from the slave on `HREADY` in the `2nd` cycle we move on to the data cycle if its 0 we wait 
	- `HWRITE` is pulled HIGH/LOW depending on the requirement (i.e Read operation or write operation) 
	- `HTRANS` is set to   2'b10 and `HSIZE` is set to 3'b010
	>  Note : HRESP is typically low (OKAY) during the address phase of a transfer.

- Data transfer stage 
	-  data is read or written 
	-  `HRESP` is checked for the status and frames are resent in case of RETRY state 