-----Data package specification----------
generic
   N : in Integer;
package Data is

     --Definition of private types
     type Vect is array(1..N) of Integer;
     type Matrix is array(1..N, 1..N) of Integer;

   --The function for multiply two matrices in range
   function MultMatr(MA, MB : in Matrix; up, down : in Integer) return Matrix;

   --The function for adding two matrices in range
   procedure AddMatr(MR : out Matrix; MA, MB : in Matrix; up, down : in Integer);

   --The function for multiply number and matrix in range
   function MultNumb(a: in Integer; MA: in Matrix; up, down : in Integer) return Matrix;

   function Min(A: in Vect; up, down : in Integer) return Integer;

   function Max(A: in Vect; up, down : in Integer) return Integer;

   --The procedure for reading vector from console
   procedure ReadVect(A : out Vect);

   --The procedure for displaying vector in console
   procedure ShowVect(A : in Vect);

   --The procedure for reading matrix from console
   procedure ReadMatr(MA: out Matrix);

   --The procedure for displaying matrix in console
   procedure ShowMatr(MA: in Matrix);

   --The procedure for input simple vector
   procedure InputSimpleVect(A : out Vect);

   --The procedure for input simple matrix
   procedure InputSimpleMatrix(MA : out Matrix);



end Data;
