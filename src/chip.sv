// Main Module 
`timescale 1ns/1ps
`default_nettype none

module my_chip (
    input logic [11:0] io_in,
    output logic [11:0] io_out,
    input logic clock,
    input logic reset    
);

    // Local Declarations 
    reg     [15:0] value_A,value_B;
    reg     [15:0] tmp_input_a, tmp_input_b;
    reg     [15:0] result,result_1;
    reg     [15:0] input_a,value2;
    reg     [15:0] temp_result_add;
    reg     [15:0] temp_result_mul;
    reg   temp_valid_mul;
    reg   temp_valid_add;
    reg   select,valid,valid_1;
    reg   [3:0] count;
    reg   [1:0] i;
    integer j;

assign select = io_in[8];

    always @(posedge clock) begin
        if(reset) begin 
            tmp_input_a <= 0;
            tmp_input_b <= 0;
            count <= 1;
            j <= 0;
        end
        else if (io_in[9]) begin
            if(count == 6) begin
                count <= 0;
                value_A <= tmp_input_a;
                value_B <= tmp_input_b;
            end
            else begin 
                tmp_input_a[j-:4] <= io_in[3:0];
                tmp_input_b[j-:4] <= io_in[7:4];
                count <= count +1; 
                j <= (4*count) -1;
            end
        end

        if(reset) begin
            i <= 0;
            io_out[8:0] <= 'h0;
            result_1 <= 'h0;
            valid_1  <= 'h0;
        end else begin
            case(i) 
            2'd0: begin
                i <= count == 6 ? 2'd1 : 2'd0;
                io_out[8] <= 'h0;
                end
            2'd1:	begin
                    result_1 <=  select ? temp_result_add : temp_result_mul;
                    valid_1 <= select ? temp_valid_add : temp_valid_mul;
                    i <= 2'd2;
                end
            2'd2:   begin
                    io_out[7:0] <= result_1[7:0];
                    io_out[8] <= valid_1;
                    count <=1;
                    i <= 2'd3;
                end
            2'd3:	begin
                    io_out[7:0] <= result_1[15:8];
                    i <= 2'd0;
                end
            endcase
        end
    end
  //Adder and Multiplier Functions
    add inst_add(
        .input_a(value_A),
        .input_b(value_B),
        .add_valid(temp_valid_add), 
        .add_out(temp_result_add)
    );

    mul inst_mul(
        .input_a(value_A),
        .input_b(value_B),
        .mul_valid(temp_valid_mul),
        .mul_out(temp_result_mul)
    );

    always @(posedge clock or posedge reset) begin 
    end

endmodule


