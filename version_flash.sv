`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2019 11:10:22 PM
// Design Name: 
// Module Name: version_flash
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module version_flash(
   input  logic       clk,
   input  logic       rst_n,
   input  logic       button,
   input  logic [3:0] version,
   output logic       led
    );
    
    logic  [3:0] version_counter;
    logic [23:0] duration_counter; // 12MHz has 83.5ns period. 2 ^ 24 * 83.5ns = 1.4 seconds, 0.7s on and 0.7s off
    logic        button_q;
    logic        button_fall_det;
    logic        version_inc;
    logic        version_finish;
    logic        version_busy;
    logic        led_on;
    
    always_ff @(posedge clk, negedge rst_n)       
       if (~rst_n) button_q <= 1'b0;
       else        button_q <= button;
    
    assign button_fall_det = !button && button_q;
    
    assign version_inc    =  (version == '0) ? 1'b0 : (version_counter < (version - 1)) && (duration_counter == '1);
    assign version_finish = ((version == '0) || (version_counter == (version - 1))) && (duration_counter == '1);
    assign version_busy   = (duration_counter != '0) || (version_counter != '0);

    always_ff @(posedge clk, negedge rst_n)
       if (~rst_n)              version_counter <= '0;
       else if (version_inc)    version_counter <= version_counter + 1;
       else if (version_finish) version_counter <= '0;
    
    always_ff @(posedge clk, negedge rst_n)
       if (~rst_n)                               duration_counter <= '0;
       else if (button_fall_det || version_busy) duration_counter <= duration_counter + 1;
       else                                      duration_counter <= '0;
       
     assign led_on = (duration_counter != '0) && (duration_counter < 24'h800000);

     always_ff @(posedge clk, negedge rst_n)
        if (~rst_n)      led <= 1'b0;
        else if (led_on) led <= 1'b1;
        else             led <= 1'b0;
    
endmodule
