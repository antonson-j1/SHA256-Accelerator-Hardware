module axi4_mem_periph #(
    parameter AXI_TEST = 0,
    parameter VERBOSE = 0
) (
    /* verilator lint_off MULTIDRIVEN */

    input             clk,
    input             mem_axi_awvalid,
    output reg        mem_axi_awready,
    input      [31:0] mem_axi_awaddr,
    input      [ 2:0] mem_axi_awprot,

    input             mem_axi_wvalid,
    output reg        mem_axi_wready,
    input      [31:0] mem_axi_wdata,
    input      [ 3:0] mem_axi_wstrb,

    output reg        mem_axi_bvalid,
    input             mem_axi_bready,

    input             mem_axi_arvalid,
    output reg        mem_axi_arready,
    input      [31:0] mem_axi_araddr,
    input      [ 2:0] mem_axi_arprot,

    output reg        mem_axi_rvalid,
    input             mem_axi_rready,
    output reg [31:0] mem_axi_rdata,

    output reg        tests_passed
);
    reg [31:0]   memory [0:128*1024/4-1] /* verilator public */;
    reg verbose;
    initial verbose = $test$plusargs("verbose") || VERBOSE;

    initial begin
        mem_axi_awready = 0;
        mem_axi_wready = 0;
        mem_axi_bvalid = 0;
        mem_axi_arready = 0;
        mem_axi_rvalid = 0;
        tests_passed = 0;
    end

    reg latched_raddr_en = 0;
    reg latched_waddr_en = 0;
    reg latched_wdata_en = 0;

    reg fast_raddr = 0;
    reg fast_waddr = 0;
    reg fast_wdata = 0;

    reg [31:0] latched_raddr;
    reg [31:0] latched_waddr;
    reg [31:0] latched_wdata;
    reg [ 3:0] latched_wstrb;
    reg        latched_rinsn;

    reg [0:511] message;
    reg reset;
    wire [255:0] hashvalue;
    wire ready;

    overall sha_core(
        .message(message),
        .clk(clk),
        .reset(reset),
        .ready(ready),
        .hashvalue(hashvalue));

    task handle_axi_arvalid; begin
        mem_axi_arready <= 1;
        latched_raddr = mem_axi_araddr;
        latched_rinsn = mem_axi_arprot[2];
        latched_raddr_en = 1;
        fast_raddr <= 1;
    end endtask

    task handle_axi_awvalid; begin
        mem_axi_awready <= 1;
        latched_waddr = mem_axi_awaddr;
        latched_waddr_en = 1;
        fast_waddr <= 1;
    end endtask

    task handle_axi_wvalid; begin
        mem_axi_wready <= 1;
        latched_wdata = mem_axi_wdata;
        latched_wstrb = mem_axi_wstrb;
        latched_wdata_en = 1;
        fast_wdata <= 1;
    end endtask

    task handle_axi_rvalid; begin
        if (verbose)
            $display("RD: ADDR=%08x DATA=%08x%s", latched_raddr, memory[latched_raddr >> 2], latched_rinsn ? " INSN" : "");
        if (latched_raddr < 128*1024) begin
            mem_axi_rdata <= memory[latched_raddr >> 2];
            mem_axi_rvalid <= 1;
            latched_raddr_en = 0;
        end else

            
            
        if (latched_raddr == 32'h3000_0000) begin
            //Reflects the ready signal
            mem_axi_rdata <= {{31{1'b0}},ready};
            mem_axi_rvalid <= 1;
            latched_raddr_en = 0; // Why?
        end else
            
        if (latched_raddr == 32'h3000_0200) begin
            // Return the hashvalue[31:0]
            mem_axi_rdata <= hashvalue[255:224];
            mem_axi_rvalid <= 1;
            latched_raddr_en = 0; // Why?
        end else

        if (latched_raddr == 32'h3000_0204) begin
            // Return the hashvalue[63:32]
            mem_axi_rdata <= hashvalue[223:192];
            mem_axi_rvalid <= 1;
            latched_raddr_en = 0; // Why?
        end else

        if (latched_raddr == 32'h3000_0208) begin
            // Return the hashvalue[95:64]
            mem_axi_rdata <= hashvalue[191:160];
            mem_axi_rvalid <= 1;
            latched_raddr_en = 0; // Why?
        end else

        if (latched_raddr == 32'h3000_020c) begin
            // Return the hashvalue[127:96]
            mem_axi_rdata <= hashvalue[159:128];
            mem_axi_rvalid <= 1;
            latched_raddr_en = 0; // Why?
        end else

        if (latched_raddr == 32'h3000_0210) begin
            // Return the hashvalue[159:128]
            mem_axi_rdata <= hashvalue[127:96];
            mem_axi_rvalid <= 1;
            latched_raddr_en = 0; // Why?
        end else
            
        if (latched_raddr == 32'h3000_0214) begin
            // Return the hashvalue[191:160]
            mem_axi_rdata <= hashvalue[95:64];
            mem_axi_rvalid <= 1;
            latched_raddr_en = 0; // Why?
        end else
            
        if (latched_raddr == 32'h3000_0218) begin
            // Return the hashvalue[223:192]
            mem_axi_rdata <= hashvalue[63:32];
            mem_axi_rvalid <= 1;
            latched_raddr_en = 0; // Why?
        end else
            
        if (latched_raddr == 32'h3000_021c) begin
            // Return the hashvalue[255:224]
            mem_axi_rdata <= hashvalue[31:0];
            mem_axi_rvalid <= 1;
            latched_raddr_en = 0; // Why?
        end 
        
        else begin
            $display("OUT-OF-BOUNDS MEMORY READ FROM %08x", latched_raddr);
            $finish;
        end
    end endtask

    task handle_axi_bvalid; begin
        if (verbose)
            $display("WR: ADDR=%08x DATA=%08x STRB=%04b", latched_waddr, latched_wdata, latched_wstrb);
        if (latched_waddr < 128*1024) begin
            if (latched_wstrb[0]) memory[latched_waddr >> 2][ 7: 0] <= latched_wdata[ 7: 0];
            if (latched_wstrb[1]) memory[latched_waddr >> 2][15: 8] <= latched_wdata[15: 8];
            if (latched_wstrb[2]) memory[latched_waddr >> 2][23:16] <= latched_wdata[23:16];
            if (latched_wstrb[3]) memory[latched_waddr >> 2][31:24] <= latched_wdata[31:24];
        end else
        if (latched_waddr == 32'h1000_0000) begin
            if (verbose) begin
                if (32 <= latched_wdata && latched_wdata < 128)
                    $display("OUT: '%c'", latched_wdata[7:0]);
                else
                    $display("OUT: %3d", latched_wdata);
            end else begin
                $write("%c", latched_wdata[7:0]);
`ifndef VERILATOR
                $fflush();
`endif
            end
        end else
        // address below used by assembly in start.S - we are not using this
        if (latched_waddr == 32'h2000_0000) begin
            if (latched_wdata == 1)
                tests_passed = 1;
        end else 
        // Changed the target address for the 'all pass' so that it can be written from C
        if (latched_waddr == 32'h2100_0000) begin
            if (latched_wdata == 1)
                tests_passed = 1;
        end else
            
            
        if (latched_waddr == 32'h3000_0000) begin // Add custom functionality
            $display("Writing reset signal", latched_wdata);
            reset <= latched_wdata;
        end else 
        
        if (latched_waddr == 32'h3000_0300) begin // Add custom functionality
            //Input message[0:31]
            message[0:31] <= latched_wdata;
        end else 

        if (latched_waddr == 32'h3000_0304) begin // Add custom functionality
            //Input message[32:63]
            message[32:63] <= latched_wdata;
        end else 

        if (latched_waddr == 32'h3000_0308) begin // Add custom functionality
            //Input message[64:95]
            message[64:95] <= latched_wdata;
        end else 

        if (latched_waddr == 32'h3000_030c) begin // Add custom functionality
            //Input message[96:127]
            message[96:127] <= latched_wdata;
        end else 

        if (latched_waddr == 32'h3000_0310) begin // Add custom functionality
            //Input message[128:159]
            message[128:159] <= latched_wdata;
        end else 

        if (latched_waddr == 32'h3000_0314) begin // Add custom functionality
            //Input message[160:191]
            message[160:191] <= latched_wdata;
        end else 

        if (latched_waddr == 32'h3000_0318) begin // Add custom functionality
            //Input message[192:223]
            message[192:223] <= latched_wdata;
        end else 

        if (latched_waddr == 32'h3000_031c) begin // Add custom functionality
            //Input message[224:255]
            message[224:255] <= latched_wdata;
        end else 

        if (latched_waddr == 32'h3000_0320) begin // Add custom functionality
            //Input message[256:287]
            message[256:287] <= latched_wdata;
        end else 

        if (latched_waddr == 32'h3000_0324) begin // Add custom functionality
            //Input message[288:319]
            message[288:319] <= latched_wdata;
        end else 

        if (latched_waddr == 32'h3000_0328) begin // Add custom functionality
            //Input message[320:351]
            message[320:351] <= latched_wdata;
        end else 

        if (latched_waddr == 32'h3000_032c) begin // Add custom functionality
            //Input message[352:383]
            message[352:383] <= latched_wdata;
        end else 

        if (latched_waddr == 32'h3000_0330) begin // Add custom functionality
            //Input message[384:415]
            message[384:415] <= latched_wdata;
        end else 

        if (latched_waddr == 32'h3000_0334) begin // Add custom functionality
            //Input message[416:447]
            message[416:447] <= latched_wdata;
        end else 

        if (latched_waddr == 32'h3000_0338) begin // Add custom functionality
            //Input message[448:479]
            message[448:479] <= latched_wdata;
        end else 

        if (latched_waddr == 32'h3000_033c) begin // Add custom functionality
            //Input message[480:511]
            message[480:511] <= latched_wdata;
        end else 
            
        begin
            $display("OUT-OF-BOUNDS MEMORY WRITE TO %08x", latched_waddr);
            $finish;
        end
        mem_axi_bvalid <= 1;
        latched_waddr_en = 0;
        latched_wdata_en = 0;
    end endtask

    always @(negedge clk) begin
        if (mem_axi_arvalid && !(latched_raddr_en || fast_raddr)) handle_axi_arvalid;
        if (mem_axi_awvalid && !(latched_waddr_en || fast_waddr)) handle_axi_awvalid;
        if (mem_axi_wvalid  && !(latched_wdata_en || fast_wdata)) handle_axi_wvalid;
        if (!mem_axi_rvalid && latched_raddr_en) handle_axi_rvalid;
        if (!mem_axi_bvalid && latched_waddr_en && latched_wdata_en) handle_axi_bvalid;
    end

    always @(posedge clk) begin
        mem_axi_arready <= 0;
        mem_axi_awready <= 0;
        mem_axi_wready <= 0;

        fast_raddr <= 0;
        fast_waddr <= 0;
        fast_wdata <= 0;

        if (mem_axi_rvalid && mem_axi_rready) begin
            mem_axi_rvalid <= 0;
        end

        if (mem_axi_bvalid && mem_axi_bready) begin
            mem_axi_bvalid <= 0;
        end

        if (mem_axi_arvalid && mem_axi_arready && !fast_raddr) begin
            latched_raddr = mem_axi_araddr;
            latched_rinsn = mem_axi_arprot[2];
            latched_raddr_en = 1;
        end

        if (mem_axi_awvalid && mem_axi_awready && !fast_waddr) begin
            latched_waddr = mem_axi_awaddr;
            latched_waddr_en = 1;
        end

        if (mem_axi_wvalid && mem_axi_wready && !fast_wdata) begin
            latched_wdata = mem_axi_wdata;
            latched_wstrb = mem_axi_wstrb;
            latched_wdata_en = 1;
        end

        if (mem_axi_arvalid && !(latched_raddr_en || fast_raddr)) handle_axi_arvalid;
        if (mem_axi_awvalid && !(latched_waddr_en || fast_waddr)) handle_axi_awvalid;
        if (mem_axi_wvalid  && !(latched_wdata_en || fast_wdata)) handle_axi_wvalid;

        if (!mem_axi_rvalid && latched_raddr_en) handle_axi_rvalid;
        if (!mem_axi_bvalid && latched_waddr_en && latched_wdata_en) handle_axi_bvalid;
    end
endmodule