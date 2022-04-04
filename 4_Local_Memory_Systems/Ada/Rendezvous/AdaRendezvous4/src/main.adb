with Ada.Text_IO, Ada.Integer_Text_IO;
use Ada.Text_IO, Ada.Integer_Text_IO;
----------------Main program---------------
--Programming for parallel computer systems
--Laboratory work #7. Ada. Rendezvous
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--22.05.2017
--Task: A = d*B + C*(MO*MK)
--
---1---2---3---4
---|-------|
--A,B,MK---5
-----------|
-----------6
-----------|
---------d,C,MO
-------------------------------------------
procedure Main is
   N: Integer := 12;
   P: Integer := 6;
   H: Integer := N / P;

   type Vector is array(Integer range<>) of Integer;
   subtype Vector_H is Vector(1..H);
   subtype Vector_2H is Vector(1..2*H);
   subtype Vector_3H is Vector(1..3*H);
   subtype Vector_4H is Vector(1..4*H);
   subtype Vector_5H is Vector(1..5*H);
   subtype Vector_N is Vector(1..N);

   type Matrix is array(Integer range<>) of Vector_N;
   subtype Matrix_H is Matrix(1..H);
   subtype Matrix_2H is Matrix(1..2*H);
   subtype Matrix_3H is Matrix(1..3*H);
   subtype Matrix_4H is Matrix(1..4*H);
   subtype Matrix_5H is Matrix(1..5*H);
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
      entry SetCMOd(C: in Vector_N; MO: in Matrix_H; d : in Integer);
   end Task1;

   task Task2 is
      entry SetBMK(B: in Vector_5H; MK : in Matrix_N);
      entry SetCMOd(C: in Vector_N; MO: in Matrix_2H; d : in Integer);
      entry GetA(A: out Vector_5H);
   end Task2;

   task Task3 is
      entry SetBMK(B: in Vector_4H; MK : in Matrix_N);
      entry SetCMOd(C: in Vector_N; MO: in Matrix_4H; d : in Integer);
      entry GetA(A: out Vector_4H);
   end Task3;

   task Task4 is
      entry SetBMKCMOd(B: in Vector_H; MK : in Matrix_N; C: in Vector_N; MO: in Matrix_H; d : in Integer);
      entry GetA(A: out Vector_H);
   end Task4;

   task Task5 is
      entry SetCMOd(C: in Vector_N; MO: in Matrix_5H; d : in Integer);
      entry SetBMK(B: in Vector_2H; MK : in Matrix_N);
      entry GetA(A: out Vector_2H);
   end Task5;

   task Task6 is
      entry SetBMK(B: in Vector_H; MK : in Matrix_N);
      entry GetA(A: out Vector_H);
   end Task6;

   task body Task1 is
      MK, MOMK: Matrix_N;
      MO_H : Matrix_H;
      A, B, C1 : Vector_N;
      d1, cell:Integer;
   begin
      Put_Line("Task 1 started");

      --input data
      MatrixInput(MK);
      VectorInput(B);
      --B(5):=2;

      Task2.SetBMK(B(H+1..N), MK);

      accept SetCMOd(C: in Vector_N; MO: in Matrix_H; d : in Integer) do
         C1:=C;
         MO_H:=MO;
         d1:=d;
      end SetCMOd;

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
            cell := cell + C1(l)*MOMK(i)(l);
         end loop;
         A(i) := d1*B(i) + cell;
      end loop;

      Task2.GetA(A(H+1..N));

      --show results
      New_Line;
      Put("A = ");
      New_Line;
      VectorOutput(A);
      New_Line;

      Put_Line("Task 1 finished");
   end Task1;

   task body Task2 is
      MK2, MOMK: Matrix_N;
      MO_2H: Matrix_2H;
      C2 : Vector_N;
      A_5H, B_5H: Vector_5H;
      d2, cell:Integer;
   begin
      Put_Line("Task 2 started");

      accept SetBMK(B: in Vector_5H; MK : in Matrix_N) do
         B_5H:=B;
         MK2:=MK;
      end SetBMK;

      Task3.SetBMK(B_5H(H+1..5*H), MK2);

      accept SetCMOd(C: in Vector_N; MO: in Matrix_2H; d : in Integer) do
         C2:=C;
         MO_2H:=MO;
         d2:=d;
      end SetCMOd;

      Task1.SetCMOd(C2, MO_2H(1..H), d2);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_2H(i+H)(k)*MK2(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + C2(l)*MOMK(i)(l);
         end loop;
         A_5H(i) := d2*B_5H(i) + cell;
      end loop;

      Task3.GetA(A_5H(H+1..5*H));

      accept GetA(A: out Vector_5H) do
         A := A_5H;
      end GetA;

      Put_Line("Task 2 finished");
   end Task2;

   task body Task3 is
      MK3, MOMK: Matrix_N;
      MO_4H: Matrix_4H;
      C3 : Vector_N;
      A_4H, B_4H: Vector_4H;
      d3, cell:Integer;
   begin
      Put_Line("Task 3 started");

      accept SetBMK(B: in Vector_4H; MK : in Matrix_N) do
         B_4H:=B;
         MK3:=MK;
      end SetBMK;

      accept SetCMOd(C: in Vector_N; MO: in Matrix_4H; d : in Integer) do
         C3:=C;
         MO_4H:=MO;
         d3:=d;
      end SetCMOd;

      Task2.SetCMOd(C3, MO_4H(1..2*H), d3);
      Task5.SetBMK(B_4H(2*H+1..4*H), MK3);
      Task4.SetBMKCMOd(B_4H(H+1..2*H), MK3, C3, MO_4H(3*H+1..4*H), d3);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_4H(i+2*H)(k)*MK3(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + C3(l)*MOMK(i)(l);
         end loop;
         A_4H(i) := d3*B_4H(i) + cell;
      end loop;

      Task4.GetA(A_4H(H+1..2*H));
      Task5.GetA(A_4H(2*H+1..4*H));

      accept GetA(A: out Vector_4H) do
         A := A_4H;
      end GetA;

      Put_Line("Task 3 finished");
   end Task3;

   task body Task4 is
      MK4, MOMK: Matrix_N;
      MO_H: Matrix_H;
      C4 : Vector_N;
      A_H, B_H: Vector_H;
      d4, cell:Integer;
   begin
      Put_Line("Task 4 started");

      accept SetBMKCMOd(B: in Vector_H; MK : in Matrix_N; C: in Vector_N; MO: in Matrix_H; d : in Integer) do
         B_H:=B;
         MK4:=MK;
         C4:=C;
         MO_H:=MO;
         d4:=d;
      end SetBMKCMOd;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_H(i)(k)*MK4(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + C4(l)*MOMK(i)(l);
         end loop;
         A_H(i) := d4*B_H(i) + cell;
      end loop;

      accept GetA(A: out Vector_H) do
         A := A_H;
      end GetA;

      Put_Line("Task 4 finished");
   end Task4;

   task body Task5 is
      MK5, MOMK: Matrix_N;
      MO_5H: Matrix_5H;
      C5 : Vector_N;
      A_2H, B_2H: Vector_2H;
      d5, cell:Integer;
   begin
      Put_Line("Task 5 started");

      accept SetCMOd(C: in Vector_N; MO: in Matrix_5H; d : in Integer) do
         C5:=C;
         MO_5H:=MO;
         d5:=d;
      end SetCMOd;

      Task3.SetCMOd(C5, MO_5H(1..4*H), d5);

      accept SetBMK(B: in Vector_2H; MK : in Matrix_N) do
         B_2H:=B;
         MK5:=MK;
      end SetBMK;

      Task6.SetBMK(B_2H(H+1..2*H), MK5);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_5H(i+4*H)(k)*MK5(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + C5(l)*MOMK(i)(l);
         end loop;
         A_2H(i) := d5*B_2H(i) + cell;
      end loop;

      Task6.GetA(A_2H(H+1..2*H));

      accept GetA(A: out Vector_2H) do
         A := A_2H;
      end GetA;

      Put_Line("Task 5 finished");
   end Task5;

   task body Task6 is
      MO, MK6, MOMK: Matrix_N;
      C : Vector_N;
      A_H, B_H: Vector_H;
      d, cell:Integer;
   begin
      Put_Line("Task 6 started");

      MatrixInput(MO);
      VectorInput(C);
      d:=1;

      Task5.SetCMOd(C, MO(1..5*H), d);

      accept SetBMK(B: in Vector_H; MK : in Matrix_N) do
         B_H:=B;
         MK6:=MK;
      end SetBMK;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO(i+5*H)(k)*MK6(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + C(l)*MOMK(i)(l);
         end loop;
         A_H(i) := d*B_H(i) + cell;
      end loop;

      accept GetA(A: out Vector_H) do
         A := A_H;
      end GetA;

      Put_Line("Task 6 finished");
   end Task6;

begin
   null;
end Main;
