`timescale 1ns/1ps
`default_nettype none

module add(input_a, input_b, add_out,add_valid);
  //Ports
  input reg [15:0] input_a, input_b;
  output reg [15:0] add_out;
  output reg add_valid;
  reg overflow;
  reg NaN; 
  
  reg [15:0] value_2, value_1; 
  reg [4:0] exp_2, exp_1; 
  reg [10:0] max_diff, min_diff; 
  reg [10:0] sing_1, shift_1; 
  reg [4:0] diff_expon; 
  reg [9:0] shifted_value; 
  reg [3:0] to_shift;
  reg [9:0] shift_ext;
  reg [9:0] shift_ext_1;
  reg [9:0] dec_1, dec_2; 
  reg [4:0] temp_1, temp_2,temp_3;
  reg sign_2, sign_1;

  reg [10:0] sum; 
  reg sum_carry;
  reg sign_equal;
  reg if_zero_1;
  reg if_inf; 

  reg [4:0] temp_exp, temp_exp_v;
  
  assign overflow = ((&exp_2[4:1] & ~exp_2[0]) & sum_carry & sign_equal) | if_inf;
  assign NaN = (&input_a[14:10] & |input_a[9:0]) | (&input_b[14:10] & |input_b[9:0]);
  assign if_inf = (&input_a[14:10] & ~|input_a[9:0]) | (&input_b[14:10] & ~|input_b[9:0]);
  assign add_out[15] = sign_2; 
  assign temp_exp = exp_2 + {4'd0, (~if_zero_1 & sum_carry & sign_equal)} - {4'd0,({1'b0,add_out[9:0]} == sum)};
  assign temp_exp_v = (temp_3 | (to_shift == 4'd10)) ? 5'd0 : (~to_shift + exp_2 + 5'd1);
  assign add_out[14:10] = ((sign_equal) ? temp_exp : temp_exp_v) | {5{overflow}};
  assign add_out[9:0] = ((if_zero_1) ? dec_1 : ((sign_equal) ? ((sum_carry) ? sum[10:1] : sum[9:0]) : ((temp_3) ? 10'd0 : shifted_value))) & {10{~overflow}};

  assign {sign_2, temp_1, dec_1} = value_2;
  assign {sign_1, temp_2, dec_2} = value_1;
  assign sign_equal = (sign_2 == sign_1);
  assign if_zero_1 = ~(|exp_1 | |dec_2);
  assign exp_2 = temp_1 + {4'd0, ~|temp_1};
  assign exp_1 = temp_2 + {4'd0, ~|temp_2};

  assign max_diff = {|temp_1, dec_1};
  assign min_diff = {|temp_2, dec_2};
  assign diff_expon = exp_2 - exp_1; 
  assign {sum_carry, sum} = sing_1 + max_diff; 
  assign shift_ext_1 = shift_ext;

  always @(*) begin 
    if(NaN)
      add_valid = 0;
      else add_valid = 1;
  end

  always @(*) begin
      if(input_b[14:10] > input_a[14:10])
        begin
          value_2 = input_b;
          value_1 = input_a;
        end
      else if(input_b[14:10] == input_a[14:10])
        begin
          if(input_b[9:0] > input_a[9:0])
            begin
              value_2 = input_b;
              value_1 = input_a;
            end
          else
            begin
              value_2 = input_a;
              value_1 = input_b;
            end
        end
      else
        begin
          value_2 = input_a;
          value_1 = input_b;
        end
    end

  assign temp_3 = (exp_2 < to_shift);



  always @(*) begin
      case (to_shift)
        4'd0: shifted_value =  sum[9:0];
        4'd1: shifted_value = {sum[8:0],shift_ext_1[9]};
        4'd2: shifted_value = {sum[7:0],shift_ext_1[9:8]};
        4'd3: shifted_value = {sum[6:0],shift_ext_1[9:7]};
        4'd4: shifted_value = {sum[5:0],shift_ext_1[9:6]};
        4'd5: shifted_value = {sum[4:0],shift_ext_1[9:5]};
        4'd6: shifted_value = {sum[3:0],shift_ext_1[9:4]};
        4'd7: shifted_value = {sum[2:0],shift_ext_1[9:3]};
        4'd8: shifted_value = {sum[1:0],shift_ext_1[9:2]};
        4'd9: shifted_value = {sum[0],  shift_ext_1[9:1]};
        default: shifted_value = shift_ext_1;
      endcase
    end

  always @(*)  begin
      case (diff_expon)
        5'h0: {shift_1,shift_ext} = {min_diff,10'd0};
        5'h1: {shift_1,shift_ext} = {min_diff,9'd0};
        5'h2: {shift_1,shift_ext} = {min_diff,8'd0};
        5'h3: {shift_1,shift_ext} = {min_diff,7'd0};
        5'h4: {shift_1,shift_ext} = {min_diff,6'd0};
        5'h5: {shift_1,shift_ext} = {min_diff,5'd0};
        5'h6: {shift_1,shift_ext} = {min_diff,4'd0};
        5'h7: {shift_1,shift_ext} = {min_diff,3'd0};
        5'h8: {shift_1,shift_ext} = {min_diff,2'd0};
        5'h9: {shift_1,shift_ext} = {min_diff,1'd0};
        5'ha: {shift_1,shift_ext} = min_diff;
        5'hb: {shift_1,shift_ext} = min_diff[10:1];
        5'hc: {shift_1,shift_ext} = min_diff[10:2];
        5'hd: {shift_1,shift_ext} = min_diff[10:3];
        5'he: {shift_1,shift_ext} = min_diff[10:4];
        5'hf: {shift_1,shift_ext} = min_diff[10:5];
        5'h10: {shift_1,shift_ext} = min_diff[10:5];
        5'h11: {shift_1,shift_ext} = min_diff[10:6];
        5'h12: {shift_1,shift_ext} = min_diff[10:7];
        5'h13: {shift_1,shift_ext} = min_diff[10:8];
        5'h14: {shift_1,shift_ext} = min_diff[10:9];
        5'h15: {shift_1,shift_ext} = min_diff[10];
        5'h16: {shift_1,shift_ext} = 0;
      endcase
    end

assign sing_1 = sign_equal? shift_1 : ~shift_1 + 11'b1;

    always @(*) begin
      casex(sum)
        11'b1??????????: to_shift = 4'd0;
        11'b01?????????: to_shift = 4'd1;
        11'b001????????: to_shift = 4'd2;
        11'b0001???????: to_shift = 4'd3;
        11'b00001??????: to_shift = 4'd4;
        11'b000001?????: to_shift = 4'd5;
        11'b0000001????: to_shift = 4'd6;
        11'b00000001???: to_shift = 4'd7;
        11'b000000001??: to_shift = 4'd8;
        11'b0000000001?: to_shift = 4'd9;
        default: to_shift = 4'd10;
      endcase
    end

endmodule
