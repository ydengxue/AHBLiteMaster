/*****************************************************************************************************
* Description:                 Simplified AHB-Lite bus master
                          - no locked transfer (no HMASTLOCK)
                          - no burst operation (no HBURST[2:0], no HTRANS[1:0])
                          - no protection control (no HPROT[3:0])
                          - no support for multiple slaves
                          - no support for slave response (no HRESP)
*
* Author:                      Dengxue Yan, Washington University in St. Louis
*
* Rev History:
*       <Author>        <Data>        <Hardware>     <Version>        <Description>    <Reference>
*     YanDengxue   2015-09-12 17:00       --           1.00             Create
*****************************************************************************************************/
`define AHB_STATE_ROUTINE     1'b0
`define AHB_STATE_WAIT_READY  1'b1

//module AHBLiteJuniorMaster(
//     HRESETn,
//     HCLK,
//     
//     ADDR,
//     WRITE,
//     WDATA,
//     RDATA,
//     
//     HREADY,
//     HADDR,
//     HWRITE,
//     HWDATA,
//     HRDATA
//);
module AHBLiteMaster (
    HREADY, HRESETn, HCLK, HRDATA, WRITE, ADDR, WDATA, HADDR, HWRITE, HWDATA, RDATA
    );
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    
    input HRESETn;
    input HCLK;
    
    input  [ADDR_WIDTH - 1:0] ADDR;
    input  WRITE;
    input  [ADDR_WIDTH - 1:0] WDATA;
    output [ADDR_WIDTH - 1:0] RDATA;
    reg    [ADDR_WIDTH - 1:0] RDATA = 32'hZZZZZZZZ;
    
    input  HREADY;
    
    output [ADDR_WIDTH - 1:0] HADDR;
    reg    [ADDR_WIDTH - 1:0] HADDR = 32'hZZZZZZZZ;
    output HWRITE;
    reg    HWRITE = 1'bZ;
    output [ADDR_WIDTH - 1:0] HWDATA;
    reg    [ADDR_WIDTH - 1:0] HWDATA = 32'hZZZZZZZZ;
    input  [ADDR_WIDTH - 1:0] HRDATA;
    
    // Data phase is delayed the next rising CLK after the WRITE signal, so we need to delay WRITE for a CLK.
    reg WRITE_delay = 1'b1;
    always @ (posedge HCLK)
    begin
        if (!HRESETn)
        begin
            WRITE_delay <= 1'b1;
        end
        else
        begin
            WRITE_delay <= WRITE;
        end
    end
    
    reg AHB_state = 1'b0;// AHB master operates state machine
    reg WRITE_lock <= 1'b1;
    always @ (posedge HCLK)
    begin
        if (!HRESETn)
        begin
            RDATA  <= 32'hZZZZ;
            HADDR  <= 32'hZZZZ;
            HWDATA <= 32'hZZZZ;
            HWRITE <= 1'bZ;
            WAIT_SLAVE_REDAY <= 1'b0;
            WRITE_lock <= 1'b1;
            AHB_state <= AHB_STATE_ROUTINE;
        end
        else
        begin
            case (AHB_state)
            begin
                // Normal process
                `AHB_ROUTINE:
                begin
                    if (HREADY)
                    // Routine
                    begin
                        HADDR <= ADDR;
                        HWRITE <= WRITE;
                        if (!WRITE_delay)
                        begin
                            RDATA <= HRDATA;
                        end
                        else
                        begin
                            HWDATA <= WDATA;
                        end
                    end
                    else
                    // When ready becomes low, the first CLK's rising edge lock the concerning signals.
                    // 1. HADDR must update to the current ADDR and keep this state later.
                    // 2. HWRITE must update to the current WRITE and keep this state later.                
                    // 3. DATA:
                    //     3.1. If WRITE_delay is 0, which means it is a read phase, the RDATA still maintains the last HRDATA.
                    //     3.2. If WRITE_delay is 1, which means it is a write phase, the HWDATA must update to the current WDATA and keep at this state later.
                    // Also, we need to store WRITE_delay in order to recover from the wait state, because recover process need to know whether a READ phase or a WRITE phase are waiting.                
                    begin
                        HADDR <= ADDR;
                        HWRITE <= WRITE;
                        WRITE_lock <= WRITE_delay;
                        if (WRITE_delay)
                        begin
                            HWDATA <= WDATA;
                        end
                        AHB_STATE_state <= `AHB_STATE_WAIT_READY;
                    end
                end
                
                // Wait slave to ready
                `AHB_STATE_WAIT_READY:
                begin
                    if (HREADY)
                    // Recover from wait state:
                    // 1. If WRITE_lock is 0 which means wait state happaned at read phase, RDATA reads the lastest HRDATA;
                    // 2. If WRITE_lock is 1 which means wait state happaned at write phase, HWDATA needs to stay for a CLK to make sure the slave read the right data;
                    begin
                        if (!WRITE_lock)
                        begin
                            RDATA <= HRDATA;
                        end
                        AHB_state <= `AHB_STATE_ROUTINE;
                    end
                end
                default:
                begin
                    AHB_state <= `AHB_STATE_ROUTINE;
                end
            endcase
        end
    end
endmodule
