
module spi_regmap_top
  ( input  logic        clk,              // 12MHz clock
    input  logic        reset,            // button
    input  logic        sclk,             // SPI CLK
    input  logic        ss_n,             // SPI CS_N
    input  logic        ss2_n,            // SPI CS_N channel 2
    input  logic        mosi,             // SPI MOSI
    output logic        miso,             // SPI MISO
    output logic [18:0] sram_addr,        // ext sram address
    inout  logic  [7:0] sram_data,        // ext sram data (bidir)
    output logic        sram_oen,         // ext sram output enable (active low)
    output logic        sram_wen,         // ext sram write enable  (active low)
    output logic        sram_cen,         // ext sram chip enable   (active low)
    output logic  [7:0] gpio_pat_gen_out, // pattern generation outputs 
    output logic        pattern_done,     // indicator to software that pattern has completed
    output logic        pmod_sclk,        // SD Card sclk
    output logic        pmod_mosi,        // SD Card input data
    input  logic        pmod_miso,        // SD Card output data
	output logic        pmod_cs,          // SD Card chip select
	input  logic        pmod_cd,          // SD Card detected, unused for now
	input  logic        button,           // Version flash
	output logic        led               // Version flash
    );

   logic  [7:0] rdata;
   logic  [7:0] rdata_regmap;
   logic  [7:0] wdata;
   logic [23:0] address;
   logic        rd_en_regmap;
   logic        wr_en_regmap;
   logic        rd_en_sram;
   logic        wr_en_sram;
   logic        rst_n;
   logic        reset_spi;
   logic [18:0] sram_addr_lbus;
   logic        sram_oen_lbus;
   logic        sram_cen_lbus;
   logic        sram_wen_lbus;
   logic [18:0] sram_addr_pat_gen;
   logic        pattern_active;
   logic [23:0] end_address_pat_gen;
   logic        enable_pat_gen;
   logic  [1:0] num_gpio_sel_pat_gen;
   logic  [4:0] timestep_sel_pat_gen;
   logic        repeat_enable_pat_gen;
   
   logic        lbus_miso;
   logic        sd_miso;

   assign rst_n = ~reset;

   assign reset_spi = reset || ss_n; // clear the SPI when the chip_select is inactive
   
   assign rdata     = (rd_en_sram) ? sram_data : rdata_regmap;
   assign sram_data = (sram_oen)   ? wdata     : 'z;
   
   assign miso = (!ss_n & lbus_miso) || (!ss2_n & pmod_miso);
   
   assign pmod_sclk = sclk;
   assign pmod_mosi = mosi;
   assign pmod_cs   = ss2_n;
   
   
   always_comb begin
     sram_addr = (pattern_active) ? sram_addr_pat_gen : sram_addr_lbus;
     sram_oen  = (pattern_active) ? 1'b0              : sram_oen_lbus;
     sram_cen  = (pattern_active) ? 1'b0              : sram_cen_lbus;
     sram_wen  = (pattern_active) ? 1'b1              : sram_wen_lbus;
   end

   spi_slave_lbus u_spi_slave_lbus
     ( .sclk,                     // input
       .mosi,                     // input
       .miso         (lbus_miso), // output
       .reset_spi,                // input
       .rdata,                    // input [7:0]
       .rd_en_regmap,             // output
       .wr_en_regmap,             // output
       .rd_en_sram,               // output
       .wr_en_sram,               // output
       .wdata,                    // output [7:0]
       .address                   // output [23:0]
       );

   lbus_regmap u_lbus_regmap
     ( .clk,                                 // input
       .rst_n,                               // input
       .rd_en_sclk           (rd_en_regmap), // input
       .wr_en_sclk           (wr_en_regmap), // input
       .address_sclk         (address),      // input [23:0]
       .wdata_sclk           (wdata),        // input  [7:0]
       .rdata                (rdata_regmap), // output [7:0]
       .end_address_pat_gen,                 // output [23:0]
       .enable_pat_gen,                      // output
       .repeat_enable_pat_gen,               // output
       .num_gpio_sel_pat_gen,                // output [1:0]
       .timestep_sel_pat_gen                 // output [4:0]
       );
       
    lbus_ext_sram u_lbus_ext_sram
      ( .clk,                           // input
        .rst_n,                         // input
        .rd_en_sclk   (rd_en_sram),     // input
        .wr_en_sclk   (wr_en_sram),     // input
        .address_sclk (address),        // input  [23:0]
        .sram_addr    (sram_addr_lbus), // output [18:0]
        .sram_oen     (sram_oen_lbus),  // output
        .sram_wen     (sram_wen_lbus),  // output
        .sram_cen     (sram_cen_lbus)   // output
       );
       
     pattern_gen u_pattern_gen
       ( .clk,                     // input
         .rst_n,                   // input
         .enable_pat_gen,          // input
         .end_address_pat_gen,     // input  [23:0]
         .num_gpio_sel_pat_gen,    // input  [1:0]
         .timestep_sel_pat_gen,    // input  [4:0]
         .repeat_enable_pat_gen,   // input
         .pattern_active,          // output
         .pattern_done,            // output
         .gpio_pat_gen_out,        // output [7:0]
         .sram_data,               // input  [7:0]
         .sram_addr_pat_gen        // output [18:0]
         );
         
      version_flash u_version_flash
        ( .clk,                    // input
          .rst_n,                  // input
          .button,                 // input
          .version (4'd5),         // input [3:0]
          .led                     // output
          );
         
endmodule
