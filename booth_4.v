// Code your design here


///////////////////////////////////////////////////////////////////////////
///////////////////////////DATA PATH///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
module Booth_4DP (ldA,ldQ,ldM,sftA,sftQ,sftD,clrA,clrQ,clrM,clrff,addsub1,addsub2,decr,ldcnt,q0,q1,qm1,eqz,clk,data_in,OUT);
  input ldA,ldQ,ldM,sftA,sftQ,sftD,clrA,clrQ,clrM,clrff,clk,decr,ldcnt;
  input addsub1,addsub2;
  input [15:0] data_in;
  output [31:0] OUT;
  output qm1,eqz,q0,q1;
  
  
  wire [15:0] A,Q,M,Z;
  wire [3:0] count;
  
  assign OUT = {A,Q};
  assign eqz = ~|count;
  assign q0 = Q[0];
  assign q1 = Q[1];
  
  shiftreg SA (A,Z,{2{A[15]}},ldA,clrA,sftA,clk);
  shiftreg SQ (Q,data_in,{A[1],A[0]},ldQ,clrQ,sftQ,clk);
  
  dff QM (qm1,Q[1],clrff,sftD,clk);
  
  pipo MP (M,data_in,ldM,clrM,clk);
  
  ALU AS (Z,A,M,addsub1,addsub2);
  
  CNTR CN (count,decr,ldcnt,clk);
  
endmodule


module shiftreg  (out,in,s_in,ld,clr,sft,clk);
  input ld,clr,sft,clk;
  input [1:0] s_in;
  input [15:0] in;
  output reg [15:0] out;
  
  always @ (posedge clk)
    begin
      if (clr)
        out <= 16'b0000_0000_0000_0000;
      else if (ld)
        out <= in;
      else if (sft)
        out <= {s_in,out[15:2]};
      else 
        out <= out;
    end
endmodule


module dff (out,in,clr,sft,clk);
  input in,clr,sft,clk;
  output reg out;
  
  always @(posedge clk)
    begin
      if (clr)
        out <= 1'b0;
      else if (sft)
        out <= in;
      else
        out <= out;
   end
endmodule


module pipo (out,in,ld,clr,clk); 
  input ld,clr,clk;
  input [15:0] in;
  output reg [15:0] out;
  
  always @(posedge clk)
    begin
      if (clr)
        out <= 16'b0;
      else if (ld)
        out <= in;
      else
        out <= out; 
    end
endmodule


module ALU (out,in1,in2,addsub1,addsub2);
  input  addsub1,addsub2;
  input [15:0] in1,in2;
  output reg [15:0] out;
  
  always @(*)
    begin
      if (addsub1==1'b0) begin out = in1 + in2; end
      else  if (addsub1==1'b1) begin out = in1 - in2; end
      else  if (addsub2==1'b0) begin out = in1 + (2*in2); end
      else  if (addsub2==1'b1) begin out = in1 - (2*in2); end
      else out = out;
    end
endmodule


module CNTR (out,decr,ld,clk);
  input ld,decr,clk;
  output reg [3:0] out;
  
  always @(posedge clk)
    begin
      if (ld) out <= 4'b1000;
      else if (decr) out <= out - 1;
      else out <= out;
    end
endmodule



///////////////////////////////////////////////////////////////////////////
///////////////////////////CONTROLER PATH///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////


module Booth4_CP (ldA,ldQ,ldM,sftA,sftQ,sftD,clrA,clrQ,clrM,clrff,clk,decr,ldcnt,addsub1,addsub2,eqz,qm1,q0,q1,done,start);
  input qm1,eqz,clk,start,q0,q1;
 
  
  output ldA,ldQ,ldM,sftA,sftQ,sftD,clrA,clrQ,clrM,clrff,decr,ldcnt,done;
  output addsub1, addsub2;
  
  reg [3:0] state,next_state;
  
  parameter S0=4'd0,
            S1=4'd1,
            S2=4'd2,
            S3=4'd3,
            S4=4'd4,
            S5=4'd5,
            S6=4'd6,
            S7=4'd7,
            S8=4'd8;
  
  
  always @(posedge clk)
    begin
      state <= next_state;
    end
  
  always @(state or q0 or qm1 or eqz or start)
    begin
      next_state = S0;
      case (state)
        S0 : next_state = start ? S1:S0;
        S1 : next_state = S2;
       
        S2 : begin
          if (({q1,q0,qm1}==3'd1)||({q1,q0,qm1}==3'd2)) next_state = S3;
          else if (({q1,q0,qm1}==3'd5)||({q1,q0,qm1}==3'd6)) next_state = S4;
          else if ({q1,q0,qm1}==3'd4) next_state = S5;
          else if ({q1,q0,qm1}==3'd3) next_state = S6;
          else if (({q1,q0,qm1}==3'd0)||({q1,q0,qm1}==3'd7)) next_state = S7;
          else next_state = S2;
        end
        
        S3 : next_state = S7;
        S4 : next_state = S7;
        S5 : next_state = S7;
        S6 : next_state = S7;
         
        S7 : begin
          if ((({q1,q0,qm1}==3'd1)||({q1,q0,qm1}==3'd2)) && !eqz) next_state = S3;
          else if ((({q1,q0,qm1}==3'd5)||({q1,q0,qm1}==3'd6)) && !eqz) next_state = S4;
          else if (({q1,q0,qm1}==3'd4) && !eqz) next_state = S5;
          else if (({q1,q0,qm1}==3'd3) && !eqz) next_state = S6;
          else if(eqz) next_state = S8;
          else next_state = S7;
        end
           
        S8 :   next_state = S8;
      endcase
    end
  
  //ldA,ldQ,ldM,sftA,sftQ,sfD,clrA,clrQ,clrM,clrff,decr,ldcnt,done;
  //output [1:0] addsub;
  assign clrA =  (state==S1) ? 1:0;
  assign clrM =  (state==S0) ? 1:0;
  assign clrff =  (state==S0) ? 1:0;
  assign clrQ =  (state==S0) ? 1:0;
  assign ldA =  ((state==S3) || (state==S4) ||(state==S5) || (state==S6)) ? 1:0;
  assign ldQ =  (state==S2) ? 1:0;
  assign ldM =  (state==S1) ? 1:0;
  assign sftA =  (state==S7) ? 1:0;
  assign sftQ =  (state==S7) ? 1:0;
  assign sftD =  (state==S7) ? 1:0;
  assign decr =  (state==S7) ? 1:0;
  assign ldcnt =  (state==S1) ? 1:0;
  assign done =  (state==S8) ? 1:0;
  assign addsub1 =  ~(state==S3);
  assign addsub1 =  (state==S4);
  assign addsub2=  ~(state==S5);
  assign addsub2=  (state==S6);


endmodule
    
  

            
          
            
            