### Interconnect 
Responsible for connecting / providing access to the mater or slave modules to the bus 
### Transfer types 
- Single
- Burst
	- Incrementing bursts
	- Wrapping bursts

## Module Declaration
```verilog
module ahb_master (
    // Global Signals
    input  wire        HCLK,
    input  wire        HRESETn,
    
    // Master Outputs
    output reg  [31:0] HADDR,
    output reg  [2:0]  HBURST,
    output reg         HMASTLOCK,
    output reg  [3:0]  HPROT,
    output reg  [2:0]  HSIZE,
    output reg  [1:0]  HTRANS,
    output reg  [31:0] HWDATA,
    output reg         HWRITE,
    
    // Master Inputs
    input  wire [31:0] HRDATA,
    input  wire        HREADY,
    input  wire [1:0]  HRESP,
    
    // Arbiter Signals
    output reg         HBUSREQ,
    input  wire        HGRANT,
    output reg         HLOCK
);
```

## Signal Descriptions

### Global Signals
1. `HCLK`: System clock input
   - All signal timings are related to the rising edge of HCLK
2. `HRESETn`: Active low reset
   - Used to reset the master to a known state

### Master Outputs

1. `HADDR[31:0]`: 32-bit address bus
   - Byte-aligned address of the transfer
   - All 32 bits are significant

2. `HBURST[2:0]`: 3-bit burst type indicator
   - 000: SINGLE - Single transfer
   - 001: INCR - Indefinite length incremental burst
   - 010: WRAP4 - 4-beat wrapping burst
   - 011: INCR4 - 4-beat incremental burst
   - 100: WRAP8 - 8-beat wrapping burst
   - 101: INCR8 - 8-beat incremental burst
   - 110: WRAP16 - 16-beat wrapping burst
   - 111: INCR16 - 16-beat incremental burst

3. `HMASTLOCK`: 1-bit locked transfer indicator
   - 0: Normal transfer
   - 1: Locked transfer

4. `HPROT[3:0]`: 4-bit protection control
   - HPROT[0]: 0 - Data access, 1 - Opcode fetch
   - HPROT[1]: 0 - User access, 1 - Privileged access
   - HPROT[2]: 0 - Non-bufferable, 1 - Bufferable
   - HPROT[3]: 0 - Non-cacheable, 1 - Cacheable

5. `HSIZE[2:0]`: 3-bit transfer size
   - 000: Byte (8 bits)
   - 001: Halfword (16 bits)
   - 010: Word (32 bits)
   - 011: 2-word line (64 bits)
   - 100: 4-word line (128 bits)
   - 101: 8-word line (256 bits)
   - 110: 512 bits
   - 111: 1024 bits

6. `HTRANS[1:0]`: 2-bit transfer type
   - 00: IDLE - No transfer is required
   - 01: BUSY - Insert idle cycles in the middle of a burst
   - 10: NONSEQ - Single transfer or first transfer of a burst
   - 11: SEQ - Subsequent transfers in a burst

7. `HWDATA[31:0]`: 32-bit write data bus
   - Contains the data for write transfers
   - Driven in the cycle following the address phase

8. `HWRITE`: 1-bit transfer direction indicator
   - 0: Read transfer
   - 1: Write transfer
#### Arbiter Signals
1.  `HBUSREQ`: 1-bit bus request
    - 0: Master does not require the bus
    - 1: Master is requesting the bus

2. `HGRANT`: 1-bit bus grant
    - 0: Bus not granted to this master
    - 1: Bus granted to this master

3. `HLOCK`: 1-bit locked sequence request
    - 0: Normal operation
    - 1: Master requires locked access to the bus

### Master Inputs

1. `HRDATA[31:0]`: 32-bit read data bus
   - Contains the data for read transfers
   - Valid only when HREADY is HIGH

2. `HREADY`: 1-bit transfer done indicator
    - 0: Transfer is extended (wait state)
    - 1: Transfer can complete

3. `HRESP[1:0]`: 2-bit transfer response
    - 00: OKAY - Transfer has finished successfully
    - 01: ERROR - Transfer has terminated with an error
    - 10: RETRY - Transfer has not yet completed, master should retry
    - 11: SPLIT - Transfer has not yet completed, master should retry later



## State Transitions and Timing Considerations

1. Address Phase:
   - `HADDR`, `HTRANS`, `HWRITE`, `HSIZE`, `HBURST`, and `HPROT` should be set up on the rising edge of `HCLK` when `HREADY` is HIGH.
   - These signals should remain stable until the next address phase.

2. Data Phase:
   - For write operations, `HWDATA` should be set up on the rising edge of `HCLK` in the cycle following the address phase.
   - For read operations, `HRDATA` is sampled on the rising edge of `HCLK` when `HREADY` is HIGH.

3. Burst Operations:
   - For incremental bursts, `HADDR` should be incremented by the appropriate amount (based on `HSIZE`) for each beat of the burst.
   - For wrapping bursts, `HADDR` should wrap at the appropriate boundary based on the burst size.

4. Wait States:
   - When `HREADY` is LOW, all control signals should remain stable.
   - Data phases can be extended indefinitely by keeping `HREADY` LOW.

5. Response Handling:
   - `HRESP` should be sampled along with `HREADY` on the rising edge of `HCLK`.
   - For RETRY and SPLIT responses, the master should abort the current transfer and re-attempt it later.

6. Arbitration:
   - `HBUSREQ` should be asserted when the master needs the bus and de-asserted when it no longer needs it.
   - The master can start a transfer on the next cycle after `HGRANT` is asserted and `HREADY` is HIGH.

7. Locked Transfers:
   - `HMASTLOCK` should be asserted for the duration of a locked sequence.
   - `HLOCK` should be asserted to the arbiter along with `HBUSREQ` to request a locked sequence.


## Functionality Overview

1. The master initiates a transfer by asserting `HBUSREQ` to the arbiter.
2. Once `HGRANT` is asserted, the master can begin a transfer on the next `HCLK` rising edge.
3. For a transfer, the master sets `HADDR`, `HTRANS`, `HWRITE`, `HSIZE`, `HBURST`, and `HPROT`.
4. For write operations, the master drives `HWDATA` in the cycle following the address phase.
5. The master monitors `HREADY` to determine when a transfer is complete.
6. The master checks `HRESP` to determine the status of the transfer and takes appropriate action (e.g., retry on RETRY or SPLIT responses).
7. For burst transfers, the master continues to drive subsequent addresses and data until the burst is complete.
8. The master can use `HMASTLOCK` and `HLOCK` to indicate and request locked sequences of transfers.

