`timescale 1ns / 100ps

import AXI_package::*;
import instruction_package::*;

`define SIMULATION 1

module AXI_top_tb_from_compiled();
    parameter CLOCK_SEMI_PERIOD = 5  ;
    parameter CC_ID_BITS =        2  ;
    parameter BB_N = 1;

    logic                             clk;
    logic                             rst; 
    logic [REG_WIDTH-1:0]  data_in_register;
    logic [REG_WIDTH-1:0]  address_register;
    logic [REG_WIDTH-1:0]  start_cc_pointer_register;
    logic [REG_WIDTH-1:0]  end_cc_pointer_register;
    logic [REG_WIDTH-1:0]  cmd_register;
    logic [REG_WIDTH-1:0]  status_register;
    logic [REG_WIDTH-1:0]  data_o_register;

    AXI_top #(
      .BB_N(BB_N),
      .CC_ID_BITS(CC_ID_BITS)
    ) dut (
    .clk                        ( clk                       ),
    .rst                        ( rst                       ),
    .data_in_register           ( data_in_register          ),
    .address_register           ( address_register          ),
    .start_cc_pointer_register  ( start_cc_pointer_register ),
    .end_cc_pointer_register    ( end_cc_pointer_register   ),
    .cmd_register               ( cmd_register              ),
    .status_register            ( status_register           ),
    .data_o_register            ( data_o_register           )
    );

    always begin
        #CLOCK_SEMI_PERIOD clk = ~ clk;
    end

    task write(input reg[REG_WIDTH-1:0] address, input reg[REG_WIDTH-1:0] value);
    begin
        @(posedge clk);
        address_register  <= address;
        @(posedge clk);
        data_in_register  <= value;
        @(posedge clk);
        cmd_register      <= CMD_WRITE;
        @(posedge clk);
        cmd_register      <= CMD_NOP;
    end
    endtask

    task read(input reg[REG_WIDTH-1:0] address, input reg[REG_WIDTH-1:0] expected_data);
    begin
        @(posedge clk);
        address_register  <= address;
        @(posedge clk);
        cmd_register      <= CMD_READ;
        @(posedge clk);
        cmd_register      <= CMD_NOP;
        @(posedge clk);

        if (data_o_register !== expected_data) begin
            $display("mismatch obtained %d != expected %d ", data_o_register, expected_data);
            $finish(1);
        end
    end
    endtask
    
    task write_file( int fp,
                     input  reg [REG_WIDTH-1:0] start_address ,
                     output reg [REG_WIDTH-1:0] address);
    begin
        reg                 flag;
        int c;
        reg [19:0] instr;
        reg [REG_WIDTH-1:0] data;
        address = start_address;
        $display("Start address: %h", address);
        
        flag    = 1'b1;  
        address = start_address;
        
        while (! $feof(fp)) 
        begin
            c = $fscanf(fp, "%x\n", instr);
            $display("%x",instr);
            data = {12'b0, instr};
            @(posedge clk);
            address_register  <= (address>>2);
            @(posedge clk);
            data_in_register  <= data;
            if(flag)
            begin
                @(posedge clk);
                cmd_register  <= CMD_WRITE;
                flag           = 1'b0;
            end
            address += 4;
        end
        @(posedge clk);
        cmd_register  <= CMD_NOP;
    end
    endtask

    task write_string_file(int fp, input reg [REG_WIDTH-1:0] start_address, output reg [REG_WIDTH-1:0] address_cur);
    begin
        int bytes_read;
        reg [7:0] c [3:0];
        reg [REG_WIDTH-1:0] data;
        reg [REG_WIDTH-1:0] tmp_address;
        tmp_address = start_address;
        address_cur = start_address;

        while (!$feof(fp)) begin
            for (int i = 0; i < 4 ; i++) begin
                if (!$feof(fp)) begin
                    bytes_read = $fscanf(fp, "%d\n", c[i]);
                    tmp_address += 1;
                    if (bytes_read == -1) begin
                        c[i] = 8'b0;
                    end
                end else begin
                    c[i] = 8'b0;
                end
            end
            data = {c[3], c[2], c[1], c[0]};
            @(posedge clk);
            address_register <= (address_cur >> 2);
            @(posedge clk);
            data_in_register <= data;
            @(posedge clk);
            cmd_register <= CMD_WRITE;
            @(posedge clk);
            cmd_register <= CMD_NOP;
            address_cur = tmp_address;
        end
    end
    endtask
    
    task read_and_compare_with_file( int fp,
                    input  reg [REG_WIDTH-1:0] start_address);
    begin
        reg [REG_WIDTH :0]  address;
        int c;
        reg [INSTRUCTION_WIDTH-1:0]           instr_0;
        reg [REG_WIDTH-1:0] data;
        reg                 flag;
        flag    = 1'b1;  
        address = start_address;
        $display("Start address: %h", address);
        
        while (! $feof(fp)) 
        begin
            c = $fscanf(fp,"%x\n", instr_0);
            $display("%x",instr_0);
            
            address_register  <= (address >> 2);
            @(posedge clk);
            if(flag)
            begin
                
                cmd_register  <= CMD_READ;
                flag           = 1'b0;
                @(posedge clk);
            end
            
           
            @(posedge clk);
            if ( data_o_register[19:0]  !==  instr_0)
            begin
                $display("%d: obtained %x !==  expected %x ",address, data_o_register[15:0]  , instr_0);
                $stop;
            end

            address += 4;
        end
        @(posedge clk);
        cmd_register  <= CMD_NOP;
    end
    endtask

    task read_and_compare_with_string_file( int fp,
                    input  reg [REG_WIDTH-1:0] start_address);
    begin
        reg [REG_WIDTH:0] address;
        int bytes_read;
        reg [7:0]           c [1:0];
        reg [REG_WIDTH-1:0]   data;
        reg                 flag;
        flag    = 1'b1;  
        address = start_address;
        $display("Start address: %h",address);
        
        while (! $feof(fp)) 
        begin
            for(int i = 0; i < 2 ; i++)
            begin
                if( ! $feof(fp))
                    bytes_read = $fscanf(fp,"%d\n", c[i]);
                else
                    c[i]       = {8{1'b0}};
            end
                
            $display("%d,%d", c[1], c[0]);
            data          = { c[1], c[0]};
            
            address_register  <= (address >> 2);
            @(posedge clk);
            if(flag)
            begin
                
                cmd_register  <= CMD_READ;
                flag           = 1'b0;
                @(posedge clk);
            end
            
           
            @(posedge clk);
            if ( data_o_register[((address>>1) % 2)*16+:16]  !== { c[1], c[0] })
            begin
                $display("%d: obtained %d, %d !==  expected %d %d",address, data_o_register[15:8], data_o_register[7:0]  , c[1], c[0]);
                $stop;
            end

            address += 2;
        end
        @(posedge clk);
        cmd_register  <= CMD_NOP;
    end
    endtask

    task start(input reg [REG_WIDTH-1:0] start_string_address, input reg [REG_WIDTH-1:0] end_string_address);
    begin
        @(posedge clk);
        start_cc_pointer_register <= start_string_address;
        @(posedge clk);
        end_cc_pointer_register <= end_string_address;
        @(posedge clk);
        cmd_register <= CMD_START;
        repeat(2) @(posedge clk);
        if (status_register !== STATUS_RUNNING) begin
            $display("status_register not running");
            $stop;
        end
        cmd_register <= CMD_NOP;
    end
    endtask

    task wait_result(output logic accept);
    begin
        while (status_register == STATUS_RUNNING) @(posedge clk);
        if (status_register !== STATUS_ACCEPTED && status_register !== STATUS_REJECTED) begin
            $display("KO: neither rejected or accepted");
            $stop();
        end
        accept = (status_register == STATUS_ACCEPTED);
    end
    endtask

    task get_cc_elapsed(output logic[REG_WIDTH-1:0] cc);
    begin
        cmd_register <= CMD_READ_ELAPSED_CLOCK;
        @(posedge clk);
        cc = data_o_register;
        @(posedge clk);
        cmd_register <= CMD_NOP;
    end
    endtask

    initial begin
        int fp_code , fp_string;
        int ok;
        reg [REG_WIDTH-1:0] start_code, end_code;
        reg [REG_WIDTH-1:0] start_string, end_string;
        reg [REG_WIDTH-1:0] cc_taken;
        reg res;

        clk = 1'b0;
        rst <= 1'b0;
        cmd_register <= CMD_NOP;

        @(posedge clk);
        rst <= 1'b1;
        @(posedge clk);
        rst <= 1'b0;
        repeat(30) @(posedge clk);

        fp_code = $fopen("/home/simo/Projects/Multidisciplinary_Project/CICERO/regex.txt", "r");
        if (fp_code == 0) begin
            $display("Could not open file 'regex.txt'");
            $stop;
        end

        start_code = 32'h0000_0000;
        write_file(fp_code, start_code, end_code);
        $display("End code: %h", end_code);

        fp_string = $fopen("/home/simo/Projects/Multidisciplinary_Project/CICERO/input.csv", "r");
        if (fp_string == 0) begin
            $display("Could not open file 'input.csv'");
            $stop;
        end

        start_string = end_code;
        while (start_string[0+:CC_ID_BITS] !== 0)
            start_string += 1;

        write_string_file(fp_string, start_string, end_string);

        ok = $rewind(fp_code);
        ok = $rewind(fp_string);
        read_and_compare_with_file(fp_code, start_code);
        read_and_compare_with_string_file(fp_string, start_string);
        $fclose(fp_code);
        $fclose(fp_string);

        repeat(10) @(posedge clk);

        $dumpfile("test.vcd");
        $dumpvars(0, AXI_top_tb_from_compiled);

        start(start_string, end_string - 1);

        wait_result(res);
        get_cc_elapsed(cc_taken);
        $display("cc taken: %d", cc_taken);
        if (res)
            $display("string accepted");
        else
            $display("string rejected");

        $dumpoff;
        $finish(0);
    end
endmodule
