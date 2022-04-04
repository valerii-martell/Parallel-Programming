with Ada.Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Discrete_Random, Ada.Streams;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Streams;

---------Data package body--------------
package body Data is

   function Max(A: Vect; up, down : Integer) return Integer is
      Result : Integer;
   begin
      Result :=A(up);
      for i in up+1..down loop
         if A(i) > Result then
            Result := A(i);
            end if;
         end loop;
      return Result;
   end Max;

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
      if N<=20 then
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
      if N<=20 then
         for i in 1..N loop
            New_Line;
            for j in 1..N loop
               Put(MA(i,j));
            end loop;
         end loop;
      else
         Put("output is too big");
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
