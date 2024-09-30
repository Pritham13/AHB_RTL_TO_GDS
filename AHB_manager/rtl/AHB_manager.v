module AHB_manager (
  input  i_HCLK,
  input  i_HRESETn,
  
  // Master Outputs
  output reg  [31:0] o_HADDR,
  output reg  [2:0]  o_HBURST,
  output reg         o_HMASTLOCK,
  output reg  [3:0]  o_HPROT,
  output reg  [2:0]  o_HSIZE,
  output reg  [1:0]  o_HTRANS,
  output reg  [31:0] o_HWDATA,
  output reg         o_HWRITE,
  
  // Master Inputs
  input   [31:0] i_HRDATA,
  input          i_HREADY,
  input   [1:0]  i_HRESP,
  
  // Arbiter Signals
  output reg     o_HBUSREQ,
  input          i_HGRANT,
  output reg     o_HLOCK
); 
localparam ADDR_NUM = 3 ;
localparam  s_addr ,
            s_data ;
//////////////////// Registers //////////////////////
reg [31:0] r_data_buffer ;
reg [31:0] addr_mem [ADDR_NUM - 1 : 0] ;
reg [3:0] r_ptr_addr ;

//////////////////arbriter Request driver////////////// 
always @(i_HCLK) begin 
  if(!i_HGRANT)begin 
    o_HBUSREQ <= 1 ;
    r_ptr_addr <= 0 ;
  end 
  else 
    o_HBUSREQ <= 0 ; //NOTE: needs to be checked

/////////////////////addr driving blocks///////////// 

always @(i_HCLK) begin 
  if (i_HREADY && i_HGRANT) begin 
    r_data_buffer <= i_HRDATA ; 
    o_HADDR <= addr_mem[r_ptr_addr] ;
    r_ptr_addr <= r_ptr_addr + 1 ;
  end
end

////////////////////data driving blocks///////////// 

always @(i_HCLK) begin 
  if (i_HREADY && i_HGRANT)
    o_HWDATA  <= r_data_buffer ;
end
