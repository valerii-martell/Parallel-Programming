with Ada.Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Discrete_Random, Ada.Streams;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Streams;

---------Data package body--------------
package body Data is

   --Multiply two matrices in range
   function MultMatr(MA, MB : Matrix; up, down : Integer) return Matrix is
      Cell : Integer;
      Result : Matrix;
   begin
      for i in up..down loop
         for j in 1..N loop
            Cell := 0;
            for k in 1..N loop
               Cell := Cell + MA(i,k)*MB(k,j);
            end loop;
            Result(i,j):= Cell;
         end loop;
      end loop;
      return Result;
   end MultMatr;

   --Multiply vector and matrix
   function MultVectMatr(A : Vect; B : Matrix; up, down:Integer) return Vect is
      Cell : Integer;
      Result : Vect;
   begin
      for j in up..down loop
      Cell := 0;
      for k in 1..N loop
      Cell := Cell + A(k)*B(k,j);
      end loop;
      Result(j):= Cell;
      end loop;
      return Result;
   end MultVectMatr;

   --Adding two vectors
   procedure AddVect(Result : out Vect; A, B : Vect; up, down : Integer) is
   begin
      for i in up..down loop
      Result(i) := A(i) + B(i);
      end loop;
   end AddVect;

   --Multiply number and vector
   function MultNumb(c: Integer; A: Vect; up, down : Integer) return Vect is
      Result : Vect;
   begin
      for i in up..down loop
      Result(i):= c*A(i);
      end loop;
      return Result;
   end MultNumb;


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
      if N<=10 then
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

   --copy matrix
   function CopyMatr(MA: in Matrix) return Matrix is
      Result : Matrix;
   begin
   for i in 1..N loop
      for j in 1..N loop
            Result(i,j) := MA(i,j);
         end loop;
      end loop;
      return Result;
   end CopyMatr;

   --copy vector
   function CopyVect(A: in Vect) return Vect is
         Result : Vect;
   begin
   for i in 1..N loop
            Result(i) := A(i);
      end loop;
      return Result;
   end CopyVect;

   --Displaying matrix in console
   procedure ShowMatr(MA: in Matrix) is
   begin
      if N<=10 then
         for i in 1..N loop
            New_Line;
            for j in 1..N loop
               Put(MA(i,j));
            end loop;
         end loop;
      end if;
   end ShowMatr;

   --Input simple vector
   procedure InputSimpleVect(A : out Vect) is
   begin
      for i in 1..N loop
          A(i) := 1;
      end loop;
   end InputSimpleVect;

   --Input simple matrix
   procedure InputSimpleMatrix(MA : out Matrix) is
   begin
      for i in 1..N loop
         for j in 1..N loop
            MA(i,j):= 1;
         end loop;
      end loop;
   end InputSimpleMatrix;

end Data;
