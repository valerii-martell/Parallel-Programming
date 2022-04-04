-----Data package specification----------
generic
   N : in Integer;
package Data is

   --Definition of types
   type Vect is array(1..N) of Integer;
   type Matrix is array(1..N, 1..N) of Integer;

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
