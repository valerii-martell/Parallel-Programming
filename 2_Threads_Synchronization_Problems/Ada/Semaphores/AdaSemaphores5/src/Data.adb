with Ada.Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Discrete_Random, Ada.Streams;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Streams;

---------Data package body--------------
package body Data is

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
