with Ada.Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Discrete_Random, Ada.Streams;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Streams;

---------Data package body--------------
package body Data is

   --Multiply two matrices
   function MultMatr (A, B : Matrix) return Matrix is
      Cell : Integer;
      Result : Matrix;
   begin
      for i in 1..N loop
      for j in 1..N loop
      Cell := 0;
      for k in 1..N loop
      Cell := Cell + A(i,k)*B(k,j);
      end loop;
      Result(i,j):= Cell;
      end loop;
      end loop;
      return Result;
   end MultMatr;

   --Transposition matrix
   function Transp (A : Matrix) return Matrix is
      Result : Matrix;
   begin
      for i in 1..N loop
      for j in 1..N loop
      Result(i,j) := A(j,i);
      end loop;
      end loop;
      return Result;
   end Transp;

   --Search minimum element in vector
   function SearchVectMin(A: Vect) return Integer is
      min : Integer;
   begin
      min := A(1);
      for i in 1..N loop
      if A(i) < min then
      min := A(i);
      end if;
      end loop;
      return min;
   end SearchVectMin;

   --Adding two matrices
   function AddMatr(A, B : Matrix) return Matrix is
      Result : Matrix;
   begin
      for i in 1..N loop
      for j in 1..N loop
      Result(i,j) := A(i,j) + B(i,j);
      end loop;
      end loop;
      return Result;
   end AddMatr;

   --Multiply vector and matrix
   function MultVectMatr(A : Vect; B : Matrix) return Vect is
      Cell : Integer;
      Result : Vect;
   begin
      for j in 1..N loop
      Cell := 0;
      for k in 1..N loop
      Cell := Cell + A(k)*B(k,j);
      end loop;
      Result(j):= Cell;
      end loop;
      return Result;
   end MultVectMatr;

   --Sort elements of vector from low to high
   function SortVect(A : Vect) return Vect is
      m : Integer;
      Result: Vect;
   begin
      for i in 1..N loop
      Result(i):= A(i);
      end loop;
      for i in reverse 1..N loop
      for j in 1..(i-1) loop
      if Result(j) > Result(j+1) then
      m := Result(j);
      Result(j):=Result(j+1);
      Result(j+1):=m;
      end if;
      end loop;
      end loop;
      return Result;
   end SortVect;

   --Multiply number and matrix
   function MultNumb(a: Integer; MA: Matrix) return Matrix is
      Result : Matrix;
   begin
      for i in 1..N loop
      for j in 1..N loop
      Result(i,j):= a*MA(i,j);
      end loop;
      end loop;
      return Result;
   end MultNumb;

   --F1: MC = MIN(A)*(MA*MD)
   procedure F1(A: in Vect; MA, MD: in Matrix; MC : out Matrix) is
   begin
      MC := MultNumb(SearchVectMin(A),MultMatr(MA,MD));
   end F1;

   --F2: MK = TRANS(MA)*TRANS(MB*MM)+MX
   procedure F2(MA,MB,MM,MX: in Matrix; MK: out Matrix) is
   begin
      MK := AddMatr(MultMatr(Transp(MA),Transp(MultMatr(MB,MM))),MX);
   end F2;

   --F3:  O = SORT(P)*(MR*MS)
   procedure F3(P: in Vect; MR,MS: in Matrix; O: out Vect) is
   begin
      O:= MultVectMatr(SortVect(P),MultMatr(MR,MS));
   end F3;

   --Reading vector from console
   procedure ReadVect(A : out Vect) is
   begin
      for i in 1..N loop
         Get(A(i));
      end loop;
   end ReadVect;

   --Displaying vector in console
   procedure ShowVect(A : in Vect) is
   begin
      if N<=5 then
         for i in 1..N loop
            Put(A(i));
         end loop;
      end if;
   end ShowVect;

   --Reading matrix from console
   procedure ReadMatr(MA: out Matrix) is
   begin
      for i in 1..N loop
      Put("New row");
      New_Line;
      for j in 1..N loop
      Get(MA(i,j));
      end loop;
      end loop;
   end ReadMatr;

   --Displaying matrix in console
   procedure ShowMatr(MA: in Matrix) is
   begin
      if N<=5 then
         for i in 1..N loop
            New_Line;
            for j in 1..N loop
               Put(MA(i,j));
            end loop;
         end loop;
      end if;
   end ShowMatr;

   --Input random vector
   procedure InputRandomVect(A : out Vect) is
      subtype Rand_Range is Integer range 1..100;
      package Random_Gen is new Ada.Numerics.Discrete_Random (Rand_Range);
      use Random_Gen;
      G : Generator;
   begin
      Reset(G);
      for i in 1..N loop
          A(i) := Random(G);
      end loop;
   end InputRandomVect;

   --Input random matrix
   procedure InputRandomMatrix(MA : out Matrix) is
      subtype Rand_Range is Integer range 1..100;
      package Random_Gen is new Ada.Numerics.Discrete_Random (Rand_Range);
      use Random_Gen;
      G : Generator;
   begin
      Reset(G);
      for i in 1..N loop
      for j in 1..N loop
      MA(i,j):= Random(G);
      end loop;
      end loop;
   end InputRandomMatrix;

end Data;
