/////////////////////////////////////////////////////////////
// Created by: Synopsys Design Compiler(R)
// Version   : Q-2019.12-SP3
// Date      : Wed Nov 25 15:47:28 2020
/////////////////////////////////////////////////////////////


module gates ( A, B, And_t, Or_t, Xor_t, Xnor_t );
  input A, B;
  output And_t, Or_t, Xor_t, Xnor_t;
  wire   N0;

  GTECH_AND2 C10 ( .A(A), .B(B), .Z(And_t) );
  GTECH_OR2 C11 ( .A(A), .B(B), .Z(Or_t) );
  GTECH_XOR2 C12 ( .A(A), .B(B), .Z(Xor_t) );
  GTECH_NOT I_0 ( .A(N0), .Z(Xnor_t) );
  GTECH_XOR2 C14 ( .A(A), .B(B), .Z(N0) );
endmodule

