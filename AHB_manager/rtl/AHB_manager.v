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

localparam  s_addr ,
            s_data ;
//////////////////// Registers //////////////////////
reg [31:0] buffer ;


//////////////////arbriter Request driver////////////// 

always @(i_HCLK) begin 
  if(!i_HGRANT)
    o_HBUSREQ <= 1 ;
  else 
    o_HBUSREQ <= 0 ;

/////////////////////addr driving blocks///////////// 

always @(i_HCLK) begin 
  if (i_HREADY && i_HGRANT)
    o_HADDR <= Slave_addr ;
end

////////////////////data driving blocks///////////// 

always @(i_HCLK) begin 
  if (i_HREADY && i_HGRANT)
    o_HWDATA  <= i_HRDATA ;

end
