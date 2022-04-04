with Ada.Text_IO, Ada.Integer_Text_IO;
use Ada.Text_IO, Ada.Integer_Text_IO;
----------------Main program---------------
--Programming for parallel computer systems
--Laboratory work #7. Ada. Rendezvous
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--22.05.2017
--Task: A = d*B + c*Z*(MO*MK)
--
---1---2---3---4
---|---|-------|
--cd--ZMO-----ABMK
-------------------------------------------
procedure Main is
   N: Integer := 8;
   P: Integer := 4;
   H: Integer := N / P;

   type Vector is array(Integer range<>) of Integer;
   subtype Vector_H is Vector(1..H);
   subtype Vector_2H is Vector(1..2*H);
   subtype Vector_3H is Vector(1..3*H);
   subtype Vector_N is Vector(1..N);

   type Matrix is array(Integer range<>) of Vector_N;
   subtype Matrix_H is Matrix(1..H);
   subtype Matrix_2H is Matrix(1..2*H);
   subtype Matrix_3H is Matrix(1..3*H);
   subtype Matrix_N is Matrix(1..N);

   procedure VectorInput(V: out Vector_N) is
   begin
      for i in 1..N loop
         V(i) := 1;
      end loop;
   end VectorInput;

   procedure VectorOutput(V: in Vector_N) is
   begin
      if N<=20 then
         for i in 1..N loop
            Put(V(i));
         end loop;
      end if;
   end VectorOutput;

   procedure MatrixOutput(M: in Matrix_N) is
   begin
      if N<=20 then
         for i in 1..N loop
            New_Line;
            for j in 1..N loop
               Put(M(i)(j));
            end loop;
         end loop;
      end if;
   end MatrixOutput;

   procedure MatrixInput(M: out Matrix_N) is
   begin
      for col in 1..N loop
         for row in 1..N loop
            M(col)(row) := 1;
         end loop;
      end loop;
   end MatrixInput;

   task Task1 is
      entry SetZMO(Z: in Vector_N; MO: in Matrix_H);
      entry SetBMK(B: in Vector_H; MK: in Matrix_N);
      entry GetA(A: out Vector_H);
   end Task1;

   task Task2 is
      entry Setcd(c, d: in Integer);
      entry SetBMK(B: in Vector_2H; MK: in Matrix_N);
      entry GetA(A: out Vector_2H);
   end Task2;

   task Task3 is
      entry SetBMK(B: in Vector_3H; MK: in Matrix_N);
      entry SetZMOcd(Z: in Vector_N; MO : in Matrix_2H; c, d: in Integer);
      entry GetA(A: out Vector_3H);
   end Task3;

   task Task4 is
      entry SetZMOcd(Z: in Vector_N; MO: in Matrix_H; c,d : in Integer);
   end Task4;

   task body Task1 is
      Z1:Vector_N;
      MO_H:Matrix_H;
      c, d, cell:Integer;
      MOMK, MK1 :Matrix_N;
      A_H, B_H:Vector_H;
   begin
      Put_Line("Task 1 started");

      --input data
      c:=1;
      d:=1;

      --send data to T2
      Task2.Setcd(c, d);

      accept SetZMO(Z: in Vector_N; MO: in Matrix_H) do
         Z1:=Z;
         MO_H:=MO;
      end SetZMO;

      accept SetBMK(B: in Vector_H; MK: in Matrix_N) do
         B_H:=B;
         MK1:=MK;
      end SetBMK;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_H(i)(k)*MK1(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + Z1(l)*MOMK(i)(l);
         end loop;
         A_H(i) := d*B_H(i) + c*cell;
      end loop;

      accept GetA(A: out Vector_H) do
         A := A_H;
      end GetA;

      Put_Line("Task 1 finished");
   end Task1;

   task body Task2 is
      Z:Vector_N;
      c2, d2, cell:Integer;
      MOMK, MK2, MO :Matrix_N;
      A_2H, B_2H:Vector_2H;
   begin
      Put_Line("Task 2 started");

      --Input data
      VectorInput(Z);
      MatrixInput(MO);

      accept Setcd(c, d: in Integer) do
         c2:=c;
         d2:=d;
      end Setcd;

      Task1.SetZMO(Z, MO(1..H));

      --send data to T3
      Task3.SetZMOcd(Z, MO(2*H+1..4*H), c2, d2);

      accept SetBMK(B: in Vector_2H; MK: in Matrix_N) do
         B_2H:=B;
         MK2:=MK;
      end SetBMK;

      Task1.SetBMK(B_2H(1..H), MK2);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO(i+H)(k)*MK2(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + Z(l)*MOMK(i)(l);
         end loop;
         A_2H(i+H) := d2*B_2H(i+H) + c2*cell;
      end loop;

      Task1.GetA(A_2H(1..H));

      accept GetA(A: out Vector_2H) do
         A := A_2H;
      end GetA;

      Put_Line("Task 2 finished");

   end Task2;

   task body Task3 is
      Z3:Vector_N;
      MO_2H:Matrix_2H;
      c3, d3, cell:Integer;
      MOMK, MK3 :Matrix_N;
      A_3H, B_3H:Vector_3H;
   begin
      Put_Line("Task 3 started");

      accept SetBMK(B: in Vector_3H; MK: in Matrix_N) do
         B_3H:=B;
         MK3:=MK;
      end SetBMK;

      accept SetZMOcd(Z: in Vector_N; MO : in Matrix_2H; c, d: in Integer) do
         Z3:=Z;
         MO_2H:=MO;
         c3:=c;
         d3:=d;
      end SetZMOcd;

      Task2.SetBMK(B_3H(1..2*H), MK3);

      Task4.SetZMOcd(Z3, MO_2H(H+1..2*H), c3, d3);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_2H(i)(k)*MK3(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + Z3(l)*MOMK(i)(l);
         end loop;
         A_3H(i+2*H) := d3*B_3H(i+2*H) + c3*cell;
      end loop;

      Task2.GetA(A_3H(1..2*H));

      accept GetA(A: out Vector_3H) do
         A := A_3H;
      end GetA;

      Put_Line("Task 3 finished");
   end Task3;

   task body Task4 is
      A, B, Z4:Vector_N;
      MO_H:Matrix_H;
      c4, d4, cell:Integer;
      MOMK, MK :Matrix_N;
   begin
      Put_Line("Task 4 started");

      --Input data
      VectorInput(B);
      MatrixInput(MK);

      --send data to T3
      Task3.SetBMK(B(1..3*H), MK);

      accept SetZMOcd(Z: in Vector_N; MO: in Matrix_H; c,d : in Integer) do
         Z4:=Z;
         MO_H:=MO;
         c4:=c;
         d4:=d;
      end SetZMOcd;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_H(i)(k)*MK(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + Z4(l)*MOMK(i)(l);
         end loop;
         A(i+3*H) := d4*B(i+3*H) + c4*cell;
      end loop;

      Task3.GetA(A(1..3*H));

      --show results
      New_Line;
      Put("A = ");
      New_Line;
      VectorOutput(A);
      New_Line;

      Put_Line("Task 4 finished");

   end Task4;


begin
   null;
end Main;
