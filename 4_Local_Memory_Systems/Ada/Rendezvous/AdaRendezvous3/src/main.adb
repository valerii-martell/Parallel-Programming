with Ada.Text_IO, Ada.Integer_Text_IO;
use Ada.Text_IO, Ada.Integer_Text_IO;
----------------Main program---------------
--Programming for parallel computer systems
--Laboratory work #7. Ada. Rendezvous
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--22.05.2017
--Task: MA = MB*MC + d*MO*MK
--
--2-3
--| |
--1-4-5-6
--
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
   subtype Vector_6H is Vector(1..6*H);
   subtype Vector_7H is Vector(1..7*H);
   subtype Vector_8H is Vector(1..8*H);
   subtype Vector_N is Vector(1..N);

   type Matrix is array(Integer range<>) of Vector_N;
   subtype Matrix_H is Matrix(1..H);
   subtype Matrix_2H is Matrix(1..2*H);
   subtype Matrix_3H is Matrix(1..3*H);
   subtype Matrix_4H is Matrix(1..4*H);
   subtype Matrix_5H is Matrix(1..5*H);
   subtype Matrix_6H is Matrix(1..6*H);
   subtype Matrix_7H is Matrix(1..7*H);
   subtype Matrix_8H is Matrix(1..8*H);
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
   end Task1;

   task Task2 is
      entry SetData(MB, MO: in Matrix_2H; MC, MK : in Matrix_N; d : in Integer);
      entry GetResult(MA: out Matrix_2H);
   end Task2;

   task Task3 is
      entry SetData(MB, MO: in Matrix_H; MC, MK : in Matrix_N; d : in Integer);
      entry GetResult(MA: out Matrix_H);
   end Task3;

   task Task4 is
      entry SetData(MB, MO: in Matrix_3H; MC, MK : in Matrix_N; d : in Integer);
      entry GetResult(MA: out Matrix_3H);
   end Task4;

   task Task5 is
      entry SetData(MB, MO: in Matrix_2H; MC, MK : in Matrix_N; d : in Integer);
      entry GetResult(MA: out Matrix_2H);
   end Task5;

   task Task6 is
      entry SetData(MB, MO: in Matrix_H; MC, MK : in Matrix_N; d : in Integer);
      entry GetResult(MA: out Matrix_H);
   end Task6;

   task body Task1 is
      MA, MB, MC, MO, MK: Matrix_N;
      d, cell1, cell2 : Integer;
   begin
      Put_Line("Task 1 started");

      --input data
      MatrixInput(MB);
      MatrixInput(MC);
      MatrixInput(MO);
      MatrixInput(MK);
      d:=1;

      --send data to T2
      Task2.SetData(MB(H+1..3*H), MO(H+1..3*H), MC(1..N), MK(1..N), d);
      --send data to T4
      Task4.SetData(MB(3*H+1..N), MO(3*H+1..N), MC(1..N), MK(1..N), d);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell1 := 0;
            cell2 := 0;
            for k in 1..N loop
               cell1 := cell1 + MB(i)(k)*MC(k)(j);
               cell2 := cell2 + MO(i)(k)*MK(k)(j);
            end loop;
            MA(i)(j) := cell1 + d*cell2;
         end loop;
      end loop;

      Task2.GetResult(MA(H+1..3*H));
      Task4.GetResult(MA(3*H+1..N));

      --show results
      New_Line;
      Put("MA = ");
      New_Line;
      MatrixOutput(MA);
      New_Line;

      Put_Line("Task 1 finished");

   end Task1;

   task body Task2 is
      MA_2H, MB_2H, MO_2H : Matrix_2H;
      MC2, MK2: Matrix_N;
      d2, cell1, cell2 : Integer;
   begin
      Put_Line("Task 2 started");

      --recive data from T1
      accept SetData(MB, MO: in Matrix_2H; MC, MK : in Matrix_N; d : in Integer) do
         MB_2H := MB;
         MO_2H := MO;
         MC2:=MC;
         MK2:=MK;
         d2:=d;
      end SetData;

      --send data to T3
      Task3.SetData(MB_2H(H+1..2*H), MO_2H(H+1..2*H), MC2(1..N), MK2(1..N), d2);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell1 := 0;
            cell2 := 0;
            for k in 1..N loop
               cell1 := cell1 + MB_2H(i)(k)*MC2(k)(j);
               cell2 := cell2 + MO_2H(i)(k)*MK2(k)(j);
            end loop;
            MA_2H(i)(j) := cell1 + d2*cell2;
         end loop;
      end loop;

      Task3.GetResult(MA_2H(H+1..2*H));

      accept GetResult(MA: out Matrix_2H) do
         MA := MA_2H;
      end GetResult;

      Put_Line("Task 2 finished");

   end Task2;

   task body Task3 is
      MA_H, MB_H, MO_H : Matrix_H;
      MC3, MK3: Matrix_N;
      d3, cell1, cell2 : Integer;
   begin
      Put_Line("Task 3 started");

      --recive data from T1
      accept SetData(MB, MO: in Matrix_H; MC, MK : in Matrix_N; d : in Integer) do
         MB_H := MB;
         MO_H := MO;
         MC3:=MC;
         MK3:=MK;
         d3:=d;
      end SetData;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell1 := 0;
            cell2 := 0;
            for k in 1..N loop
               cell1 := cell1 + MB_H(i)(k)*MC3(k)(j);
               cell2 := cell2 + MO_H(i)(k)*MK3(k)(j);
            end loop;
            MA_H(i)(j) := cell1 + d3*cell2;
         end loop;
      end loop;

      accept GetResult(MA: out Matrix_H) do
         MA := MA_H;
      end GetResult;

      Put_Line("Task 3 finished");

   end Task3;

   task body Task4 is
      MA_3H, MB_3H, MO_3H : Matrix_3H;
      MC4, MK4: Matrix_N;
      d4, cell1, cell2 : Integer;
   begin
      Put_Line("Task 4 started");

      --recive data from T1
      accept SetData(MB, MO: in Matrix_3H; MC, MK : in Matrix_N; d : in Integer) do
         MB_3H := MB;
         MO_3H := MO;
         MC4:=MC;
         MK4:=MK;
         d4:=d;
      end SetData;

      --send data to T5
      Task5.SetData(MB_3H(H+1..3*H), MO_3H(H+1..3*H), MC4(1..N), MK4(1..N), d4);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell1 := 0;
            cell2 := 0;
            for k in 1..N loop
               cell1 := cell1 + MB_3H(i)(k)*MC4(k)(j);
               cell2 := cell2 + MO_3H(i)(k)*MK4(k)(j);
            end loop;
            MA_3H(i)(j) := cell1 + d4*cell2;
         end loop;
      end loop;

      Task5.GetResult(MA_3H(H+1..3*H));

      accept GetResult(MA: out Matrix_3H) do
         MA := MA_3H;
      end GetResult;

      Put_Line("Task 4 finished");

   end Task4;

   task body Task5 is
      MA_2H, MB_2H, MO_2H : Matrix_2H;
      MC5, MK5: Matrix_N;
      d5, cell1, cell2 : Integer;
   begin
      Put_Line("Task 5 started");

      --recive data from T4
      accept SetData(MB, MO: in Matrix_2H; MC, MK : in Matrix_N; d : in Integer) do
         MB_2H := MB;
         MO_2H := MO;
         MC5:=MC;
         MK5:=MK;
         d5:=d;
      end SetData;

      --send data to T6
      Task6.SetData(MB_2H(H+1..2*H), MO_2H(H+1..2*H), MC5(1..N), MK5(1..N), d5);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell1 := 0;
            cell2 := 0;
            for k in 1..N loop
               cell1 := cell1 + MB_2H(i)(k)*MC5(k)(j);
               cell2 := cell2 + MO_2H(i)(k)*MK5(k)(j);
            end loop;
            MA_2H(i)(j) := cell1 + d5*cell2;
         end loop;
      end loop;

      Task6.GetResult(MA_2H(H+1..2*H));

      accept GetResult(MA: out Matrix_2H) do
         MA := MA_2H;
      end GetResult;

      Put_Line("Task 5 finished");

   end Task5;

   task body Task6 is
      MA_H, MB_H, MO_H : Matrix_H;
      MC6, MK6: Matrix_N;
      d6, cell1, cell2 : Integer;
   begin
      Put_Line("Task 6 started");

      --recive data from T5
      accept SetData(MB, MO: in Matrix_H; MC, MK : in Matrix_N; d : in Integer) do
         MB_H := MB;
         MO_H := MO;
         MC6:=MC;
         MK6:=MK;
         d6:=d;
      end SetData;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell1 := 0;
            cell2 := 0;
            for k in 1..N loop
               cell1 := cell1 + MB_H(i)(k)*MC6(k)(j);
               cell2 := cell2 + MO_H(i)(k)*MK6(k)(j);
            end loop;
            MA_H(i)(j) := cell1 + d6*cell2;
         end loop;
      end loop;

      accept GetResult(MA: out Matrix_H) do
         MA := MA_H;
      end GetResult;

      Put_Line("Task 6 finished");

   end Task6;

begin
   null;
end Main;
