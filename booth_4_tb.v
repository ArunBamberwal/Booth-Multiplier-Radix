// Code your testbench here
// or browse Examples
module Booth4_test ;
  reg [15:0] data_in;
  reg start,clk;
  wire [31:0] OUT;
  wire done;
  
  Booth_4DP DP (ldA,ldQ,ldM,sftA,sftQ,sftD,clrA,clrQ,clrM,clrff,addsub1,addsub2,decr,ldcnt,q0,q1,qm1,eqz,clk,data_in,OUT); 
  
  Booth4_CP CP (ldA,ldQ,ldM,sftA,sftQ,sftD,clrA,clrQ,clrM,clrff,clk,decr,ldcnt,addsub1,addsub2,eqz,qm1,q0,q1,done,start);
 
  
initial 
  begin
    clk = 1'b0;
   #10  start = 1'b1;
    #500 $finish;
  end
  
  always #5 clk = ~clk;
  
  
  initial 
    begin
     
         #20 data_in = 16'b1111_1111_1111_0011; 
        #20 data_in = 16'b0000_0000_0001_1001; 
    end
  initial 
    begin
      $dumpfile ("Booth_4DP.vcd");
      $dumpvars (0,Booth4_test);
      $monitor ($time,"%8d %d %b %b",DP.M,CP.state,OUT,done);
    end
endmodule