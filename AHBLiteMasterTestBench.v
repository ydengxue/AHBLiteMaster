//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modified by Dengxue Yan at 9/20/2015:
//    Add "read with wait followed by a write"
//    and "write with wait followed by a read"
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module AHBLiteMaster_tb;

    wire HWRITE;
    wire [31:0]HADDR,HWDATA,RDATA;

    reg HREADY,HRESETn,HCLK,WRITE;
    reg [31:0]HRDATA,ADDR,WDATA;

    AHBLiteMaster DUT (HREADY,HRESETn,HCLK,HRDATA,WRITE,ADDR,WDATA,HADDR,HWRITE,HWDATA,RDATA);

    //====================================================================================================
    // Master output signals
    //====================================================================================================
    initial begin

        $dumpfile("AHBLiteMaster.vcd"); 
        $dumpvars(0, AHBLiteMaster_tb); 
        
        HCLK=0;

        HRESETn=0; // reset

        //------------------------------------------------------------------------------------------------
        // 2 write cycles
        //------------------------------------------------------------------------------------------------
        #20     
        HRESETn=1; // write 1
        WRITE=1;
        WDATA=32'h11111111;
        ADDR=32'h11111111;
        
        #20
        HRESETn=1; // write 2
        WRITE=1;
        WDATA=32'h22222222;
        ADDR=32'h22222222;
        
        //------------------------------------------------------------------------------------------------
        // 2 read cycles
        //------------------------------------------------------------------------------------------------
        #20
        HRESETn=1; // read 1
        WRITE=0;
        ADDR=32'h33333333;
        
        #20
        HRESETn=1; //read 2
        WRITE=0;
        ADDR=32'h44444444;
        
        //------------------------------------------------------------------------------------------------
        // a write followed by a read
        //------------------------------------------------------------------------------------------------
        #20
        HRESETn=1; //write 3
        WRITE=1;
        WDATA=32'h55555555;
        ADDR=32'h55555555;
        
        #20
        HRESETn=1; // read 3
        WRITE=0;
        ADDR=32'h66666666;

        //------------------------------------------------------------------------------------------------
        // read with wait states
        //------------------------------------------------------------------------------------------------
        #20
        HRESETn=1; // read with wait states1
        WRITE=0;
        ADDR=32'h77777777;
               
        #20
        HRESETn=1; // read with wait states2
        WRITE=0;
        ADDR=32'h88888888;
        
        #20
        HRESETn=1; // read with wait states3
        WRITE=0;
        ADDR=32'h99999999;
        
        #20
        HRESETn=1; // read with wait states4
        WRITE=0;
        ADDR=32'hAAAAAAAA;
        
        //------------------------------------------------------------------------------------------------
        // write with wait states
        //------------------------------------------------------------------------------------------------
        #20
        HRESETn=1; // write with wait states1
        WRITE=1;
        WDATA=32'hBBBBBBBB;
        ADDR=32'hBBBBBBBB;
        
        #20
        HRESETn=1; // write with wait states2
        WRITE=1;
        WDATA=32'hCCCCCCCC;
        ADDR=32'hCCCCCCCC;
        
        #20
        HRESETn=1; // write with wait states3
        WRITE=1;
        WDATA=32'hDDDDDDDD;
        ADDR=32'hDDDDDDDD;
        
        #20
        HRESETn=1; // write with wait states4
        WRITE=1;
        WDATA=32'hEEEEEEEE;
        ADDR=32'hEEEEEEEE;

        //------------------------------------------------------------------------------------------------
        // read with wait followed by a write
        //------------------------------------------------------------------------------------------------
        #20
        HRESETn=1; // read with wait followed by a write states1
        WRITE=0;
        WDATA=32'h11117777;
        ADDR=32'h00009999;
        
        #20
        HRESETn=1; // read with wait followed by a write states2
        WRITE=1;
        WDATA=32'h11118888;
        ADDR=32'h00008888;
        
        #20
        HRESETn=1; // read with wait followed by a write states3
        WRITE=1;
        WDATA=32'h11119999;
        ADDR=32'h00007777;
        
        #20
        HRESETn=1; // read with wait followed by a write states4
        WRITE=1;
        WDATA=32'h1111AAAA;
        ADDR=32'h00006666;

        //------------------------------------------------------------------------------------------------
        // write with wait followed by a read
        //------------------------------------------------------------------------------------------------        
        #20
        HRESETn=1; // write with wait followed by a read states1
        WRITE=1;
        WDATA=32'h22227777;
        ADDR=32'h33339999;
        
        #20
        HRESETn=1; // write with wait followed by a read states2
        WRITE=0;
        WDATA=32'h22228888;
        ADDR=32'h33338888;
        
        #20
        HRESETn=1; // write with wait followed by a read states3
        WRITE=0;
        WDATA=32'h22229999;
        ADDR=32'h33337777;
        
        #20
        HRESETn=1; // write with wait followed by a read states4
        WRITE=0;
        WDATA=32'h2222AAAA;
        ADDR=32'h33336666;

        
        #20

        #60
        $finish;
    end

    //====================================================================================================
    // Slave response signals
    //====================================================================================================
    initial begin
        #91
        HRDATA = 32'h33333333;

        #20
        HRDATA = 32'h44444444;

        #40
        HRDATA = 32'h66666666;

        #20
        HRDATA = 32'h77777777;

        #20
        HRDATA = 32'h88888888;
        
        #20
        HRDATA = 32'h99999999;
        
        #20
        HRDATA = 32'hAAAAAAAA;

        #20
        HRDATA = 32'hBBBBBBBB;

        #20
        HRDATA = 32'hCCCCCCCC;

        #20
        HRDATA = 32'hDDDDDDDD;

        #20
        HRDATA = 32'hEEEEEEEE;

        #20
        HRDATA = 32'hFFFFFFFF;

        #20
        HRDATA = 32'h00001111;

        #20
        HRDATA = 32'h00002222;

        #20
        HRDATA = 32'h00003333;

        #20
        HRDATA = 32'h00004444;

        #20
        HRDATA = 32'h00005555;

        #20
        HRDATA = 32'h00006666;

        #20
        HRDATA = 32'h00007777;

        #20
        HRDATA = 32'h00008888;        
    end
    initial begin
        #0
        HREADY=1;

        #171
        HREADY = 0;

        #40
        HREADY = 1;

        #40
        HREADY = 0;

        #40
        HREADY = 1;

        #60
        HREADY = 0;

        #20
        HREADY = 1;

        #60
        HREADY = 0;

        #20
        HREADY = 1;
    end

    //====================================================================================================
    // System CLK
    //====================================================================================================
    always
        #10 HCLK= !HCLK;
    
endmodule
