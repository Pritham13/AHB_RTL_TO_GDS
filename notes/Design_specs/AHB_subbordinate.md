# AHB Slave Module Specifications

## Module Declaration
```verilog
module ahb_slave (
    // Global Signals
    input  wire        HCLK,
    input  wire        HRESETn,
    
    // Slave Inputs
    input  wire [31:0] HADDR,
    input  wire [2:0]  HBURST,
    input  wire        HMASTLOCK,
    input  wire [3:0]  HPROT,
    input  wire [2:0]  HSIZE,
    input  wire [1:0]  HTRANS,
    input  wire [31:0] HWDATA,
    input  wire        HWRITE,
    input  wire        HSEL,
    
    // Slave Outputs
    output reg  [31:0] HRDATA,
    output reg         HREADY,
    output reg  [1:0]  HRESP
);
```

## Block Diagram

![](../imgs/Pasted%20image%2020241010231348.png)

## Signal Descriptions

### Global Signals
1. `HCLK`: System clock input
   - All signal timings are related to the rising edge of HCLK
2. `HRESETn`: Active low reset
   - Used to reset the slave to a known state

### Slave Inputs
3. `HADDR[31:0]`: Address bus
   - Carries the byte address of each transfer
4. `HBURST[2:0]`: Burst type
   - Indicates if the transfer is part of a burst and the burst type
5. `HMASTLOCK`: Locked transfer indicator
   - Indicates that the current transfer is part of a locked sequence
6. `HPROT[3:0]`: Protection control
   - Provides additional information about the bus transfer
7. `HSIZE[2:0]`: Transfer size
   - Indicates the size of the transfer (byte, halfword, word, etc.)
8. `HTRANS[1:0]`: Transfer type
   - Indicates the transfer type: IDLE, BUSY, NONSEQ, SEQ
9. `HWDATA[31:0]`: Write data bus
   - Carries the data for write transfers
10. `HWRITE`: Transfer direction
    - Indicates if the transfer is a read or write operation
11. `HSEL`: Slave select
    - Indicates that this slave is selected for the current transfer

### Slave Outputs
12. `HRDATA[31:0]`: Read data bus
    - Carries the data for read transfers
13. `HREADY`: Transfer done
    - Indicates that a transfer has finished
    - Used by the slave to extend a transfer
14. `HRESP[1:0]`: Transfer response
    - Provides additional information on the status of the transfer

## Detailed Signal States

### Slave Inputs

1. `HADDR[31:0]`: 32-bit address bus
   - All 32 bits are significant
   - Byte-aligned address of the transfer

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
   - Valid in the cycle following the address phase

8. `HWRITE`: 1-bit transfer direction indicator
   - 0: Read transfer
   - 1: Write transfer

9. `HSEL`: 1-bit slave select
   - 0: Slave is not selected
   - 1: Slave is selected for the current transfer

### Slave Outputs

10. `HRDATA[31:0]`: 32-bit read data bus
    - Contains the data for read transfers
    - Must be valid when HREADY is HIGH

11. `HREADY`: 1-bit transfer done indicator
    - 0: Transfer is extended (insert wait state)
    - 1: Transfer can complete

12. `HRESP[1:0]`: 2-bit transfer response
    - 00: OKAY - Transfer has finished successfully
    - 01: ERROR - Transfer has terminated with an error
    - 10: RETRY - Transfer has not yet completed, master should retry
    - 11: SPLIT - Transfer has not yet completed, master should retry later (if slave is SPLIT-capable)

## Functionality Overview

1. Address Decoding:
   - The slave must decode `HADDR` to determine if it should respond to the transfer.
   - `HSEL` is typically used as an enable signal, indicating this slave is selected.

2. Transfer Type Handling:
   - The slave should respond appropriately to different `HTRANS` types:
     - IDLE and BUSY transfers should be ignored (respond with OKAY and HREADY HIGH).
     - NONSEQ and SEQ transfers should be processed.

3. Read Operations:
   - For read transfers (`HWRITE` is LOW), the slave should:
     - Decode the address and prepare the requested data.
     - Drive the data onto `HRDATA` when ready.
     - Assert `HREADY` HIGH when the data is valid.

4. Write Operations:
   - For write transfers (`HWRITE` is HIGH), the slave should:
     - Capture the address in the address phase.
     - Capture the data from `HWDATA` in the following cycle.
     - Assert `HREADY` HIGH when the write is complete.

5. Burst Handling:
   - The slave should be capable of handling burst transfers as indicated by `HBURST`.
   - For incrementing bursts, it should expect sequential addresses.
   - For wrapping bursts, it should handle address wrapping at appropriate boundaries.

6. Transfer Size:
   - The slave should support different transfer sizes as indicated by `HSIZE`.
   - It may need to perform multiple internal operations for sizes larger than its natural data width.

7. Wait State Insertion:
   - If the slave needs more time to complete a transfer, it can insert wait states by driving `HREADY` LOW.
   - It must continue to drive valid `HRDATA` (for reads) while `HREADY` is LOW.

8. Error Handling:
   - If the slave encounters an error (e.g., unsupported operation, invalid address), it should respond with an ERROR response:
     - Drive `HRESP` to 01 (ERROR) for two cycles.
     - Drive `HREADY` LOW in the first cycle and HIGH in the second cycle.

9. SPLIT and RETRY Responses (if supported):
   - These responses allow the slave to delay completion of a transfer.
   - The slave drives the appropriate `HRESP` value for two cycles, with `HREADY` LOW then HIGH.

10. Protection and Locking:
    - The slave may use `HPROT` and `HMASTLOCK` signals to implement access protection or ensure atomic operations.

## Implementation Considerations

- The slave should be designed with a state machine to manage the different phases of AHB transfers.
- Careful attention should be paid to timing, ensuring all outputs are registered and meet setup and hold times.
- The slave should be able to handle back-to-back transfers without inserting unnecessary wait states.
- For multi-cycle operations, the slave should be designed to pipeline requests if possible to improve performance.
- Error checking should be implemented to handle invalid or unsupported transfer types, sizes, or addresses.

## References
1. AMBA Specification 2.0
2. Multimedia Architecture and Processing Laboratory. "Introduction to AMBA AHB." Lecture by Prof. Wen-Hsiao Peng, 2007 Spring Term. Lecture 10