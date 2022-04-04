-----Data package specification----------
generic
   N : in Integer;
package Data is

   --Declaration of private types
   type Vect is private;
   type Matrix is private;

   --F1: MC = MIN(A)*(MA*MD)
   procedure F1(A: in Vect; MA, MD: in Matrix; MC : out Matrix);

   --F2: MK = TRANS(MA)*TRANS(MB*MM)+MX
   procedure F2(MA,MB,MM,MX: in Matrix; MK: out Matrix);

   --F3:  O = SORT(P)*(MR*MS)
   procedure F3(P: in Vect; MR,MS: in Matrix; O: out Vect);

   --The procedure for reading vector from console
   procedure ReadVect(A : out Vect);

   --The procedure for displaying vector in console
   procedure ShowVect(A : in Vect);

   --The procedure for reading matrix from console
   procedure ReadMatr(MA: out Matrix);

   --The procedure for displaying matrix in console
   procedure ShowMatr(MA: in Matrix);

   --Input random vector
   procedure InputRandomVect(A : out Vect);

   --Input random matrix
   procedure InputRandomMatrix(MA : out Matrix);

  --Definition of private types
  private
     type Vect is array(1..N) of Integer;
     type Matrix is array(1..N, 1..N) of Integer;

end Data;

