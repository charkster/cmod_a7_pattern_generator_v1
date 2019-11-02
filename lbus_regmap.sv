
module lbus_regmap
  ( input  logic        clk,
    input  logic        rst_n,
    input  logic        rd_en_sclk,
    input  logic        wr_en_sclk,
    input  logic [23:0] address_sclk,
    input  logic  [7:0] wdata_sclk,
    output logic  [7:0] rdata,
    output logic [23:0] end_address_pat_gen,
    output logic        enable_pat_gen,
    output logic        repeat_enable_pat_gen,
    output logic  [1:0] num_gpio_sel_pat_gen,
    output logic  [4:0] timestep_sel_pat_gen
    );
           
   logic sync_rd_en_ff1;
   logic sync_rd_en_ff2;
   logic sync_wr_en_ff1;
   logic sync_wr_en_ff2;
   logic hold_sync_wr_en_ff2;

   logic [2:0] raddress;

   logic [7:0] registers[7:0];

   always_ff @(posedge clk, negedge rst_n)
     if (~rst_n)  sync_rd_en_ff1 <= 1'b0;
     else         sync_rd_en_ff1 <= rd_en_sclk;

   always_ff @(posedge clk, negedge rst_n)
     if (~rst_n)  sync_rd_en_ff2 <= 1'b0;
     else         sync_rd_en_ff2 <= sync_rd_en_ff1;

   always_ff @(posedge clk, negedge rst_n)
     if (~rst_n)  sync_wr_en_ff1 <= 1'b0;
     else         sync_wr_en_ff1 <= wr_en_sclk;

   always_ff @(posedge clk, negedge rst_n)
     if (~rst_n)  sync_wr_en_ff2 <= 1'b0;
     else         sync_wr_en_ff2 <= sync_wr_en_ff1;

   always_ff @(posedge clk, negedge rst_n)
     if (~rst_n) hold_sync_wr_en_ff2 <= 1'b0;
     else        hold_sync_wr_en_ff2 <= sync_wr_en_ff2;

   assign raddress = {3{sync_rd_en_ff2}} & address_sclk[2:0];

   always_comb
     rdata[7:0] = (|address_sclk[23:3]) ? 8'd0 : registers[raddress];

   integer i;
   always_ff @(posedge clk, negedge rst_n)
     if (~rst_n)                  for (i=0; i<8; i=i+1) registers[i] <= 8'h00;
     else if (sync_wr_en_ff2 && (!hold_sync_wr_en_ff2)) registers[address_sclk[2:0]] <= wdata_sclk;

    always_comb begin
      end_address_pat_gen   = {registers[2],registers[3],registers[4]};
      enable_pat_gen        = registers[0][0];
      repeat_enable_pat_gen = registers[0][1];
      num_gpio_sel_pat_gen  = registers[1][1:0];
      timestep_sel_pat_gen  = registers[1][7:3];
    end

endmodule