/*****************************************************************************************************
* Description:                 Simplified AHB-Lite bus master
                          - no locked transfer (no HMASTLOCK)
                          - no burst operation (no HBURST[2:0], no HTRANS[1:0])
                          - no protection control (no HPROT[3:0])
                          - no support for multiple slaves
                          - no support for slave response (no HRESP)
*
* Author:                      Dengxue Yan, Washington University in St. Louis

* Reference:
*
* Rev History:
*       <Author>        <Data>        <Hardware>     <Version>        <Description>    
*     Dengxue Yan   2015-09-12 17:00       --           1.00             Create
*     Dengxue Yan   2015-09-22 21:00       --           1.00          Modify timing of HADDR and HWDATA
                                                                      to catch the lab assignment
*****************************************************************************************************/
`define AHB_STATE_ROUTINE     2'b01
`define AHB_STATE_WAIT_READY  2'b10

`timescale 100ps / 1ps

module AHBLiteMaster (
    HREADY, HRESETn, HCLK, HRDATA, WRITE, ADDR, WDATA, HADDR, HWRITE, HWDATA, RDATA
    );
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    
    input HRESETn;
    input HCLK;
    
    input  [ADDR_WIDTH - 1:0] ADDR;
    input  WRITE;
    input  [DATA_WIDTH - 1:0] WDATA;
    output [DATA_WIDTH - 1:0] RDATA;
    reg    [DATA_WIDTH - 1:0] RDATA = 32'hZZZZZZZZ;
    
    input  HREADY;
    
    output [ADDR_WIDTH - 1:0] HADDR;
    reg    [ADDR_WIDTH - 1:0] HADDR = 32'hZZZZZZZZ;
    output HWRITE;
    reg    HWRITE = 1'bZ;
    output [DATA_WIDTH - 1:0] HWDATA;
    reg    [DATA_WIDTH - 1:0] HWDATA = 32'hZZZZZZZZ;
    input  [DATA_WIDTH - 1:0] HRDATA;
    
    // Buffer regs
    reg [DATA_WIDTH - 1:0] WDATA_AHB_master_buffer = 32'hZZZZZZZZ;
    reg HWRITE_AHB_master_buffer;
    
    // 1. The master drives the address and control signals onto the bus after the rising edge of HCLK.
    // 2. The slave then samples the address and control information on the next rising edge of HCLK.
    // 3. After the slave has sampled the address and control it can start to drive the appropriate HREADY response. 
    //    This response is sampled by the master on the third rising edge of HCLK.
    always @ (posedge HCLK)
    begin
        if (!HRESETn)
        begin
            HADDR  <= 32'h00000000;
            HWDATA <= 32'h00000000;
            HWRITE <= 1'b0;

            WDATA_AHB_master_buffer   <= 32'h00000000;
            HWRITE_AHB_master_buffer  <= 1'b0;
        end
        else
        begin
            // WDATA is released at the same time with the ADDR, 
            // but HWDATA gets WDATA at the next rising edge of HCLK, 
            // so we must buffer WDATA for a HCLK.
            // And when HREADY is low, we still need to update WDATA_AHB_master_buffer
            WDATA_AHB_master_buffer  <= WDATA;
            
            // HADDR is modified to update all the time, even when HREADY is low 
            HADDR  <= ADDR;
 
            // Only when HREADY is high, we need to update HADDR, HWRITE,
            // and if HWRITE is high, HWDATA need to be updated,
            // and if HWRITE is low, SLAVE need to prepare HRDATA
            if (HREADY)
            begin
                HWRITE <= WRITE;

                // We need to buffer HWRITE for RDATA 
                HWRITE_AHB_master_buffer <= HWRITE;


                // if HWRITE is high, AHB bus write buffered WDATA to HWDATA
                // if HWRITE is low, SLAVE prepares HRDADA
                if (HWRITE)
                begin
                    HWDATA <= WDATA_AHB_master_buffer;
                end
//                else if (!HWRITE)// SLAVE prepares HRDADA
//                begin
//                end             
            end
        end
    end
    
    // Master send Slave response HRDADA to RDADA
    always @ (posedge HCLK)
    begin
        if (!HRESETn)
        begin
            RDATA  <= 32'h00000000;
        end
        else
        begin
            if (HREADY)
            begin
                // 1. At next rising edge after HRDATA is prepared, RDATA get HRDATA's value
                // so we detect HWRITE_AHB_master_buffer which is buffered HWRITE
                // 2. Actually, we don't need to buffer HWRITE if SLAVE always puts right HRDATA on bus. 
                // Here we buffer it in case of changing HRDATA when HWRITE is high. 
                // 3. When HREADY is pulled down, we do not care about HRDATA. But when it recovers, 
                // we need to update RDATA to the latest HRDATA
                if (!HWRITE_AHB_master_buffer)
                begin
                    RDATA <= HRDATA;
                end
            end
        end
    end
endmodule
