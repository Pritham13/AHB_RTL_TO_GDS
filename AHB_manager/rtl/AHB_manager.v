module AHB_manager (
  input  HCLK,
  input  HRESETn,
  
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
  input   [31:0] HRDATA,
  input          HREADY,
  input   [1:0]  HRESP,
  
  // Arbiter Signals
  output reg     HBUSREQ,
  input          HGRANT,
  output reg     HLOCK
); 
localparam ADDR_NUM = 3 ;
localparam  s_addr ,
            s_data ;
//////////////////// Registers //////////////////////
reg [31:0] r_data_buffer ;
reg [31:0] addr_mem [ADDR_NUM - 1 : 0] ;
reg [3:0] r_ptr_addr ;

//////////////////arbriter Request driver////////////// 
always @(HCLK) begin 
  if(!HGRANT)begin 
    HBUSREQ <= 1 ;
    r_ptr_addr <= 0 ;
  end 
  else 
    HBUSREQ <= 0 ; //NOTE: needs to be checked

/////////////////////addr driving blocks///////////// 

always @(HCLK) begin 
  if (HREADY && HGRANT) begin 
    r_data_buffer <= HRDATA ; 
    HADDR <= addr_mem[r_ptr_addr] ;
    r_ptr_addr <= r_ptr_addr + 1 ;
  end
end

////////////////////data driving blocks///////////// 

always @(HCLK) begin 
  if (HREADY && HGRANT)
    HWDATA  <= r_data_buffer ;
end
