with Ada.Text_IO, Ada.Integer_Text_IO;
use Ada.Text_IO, Ada.Integer_Text_IO;
----------------Main program---------------
--Programming for parallel computer systems
--Laboratory work #7. Ada. Rendezvous
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--12.06.2017
--Task: MA = d*MO + min(Z)*ME*MK
-------------------------------------------
procedure Main is
   N: Integer := 7;
   P: Integer := 7;
   H: Integer := N / P;

   type Vector is array(Integer range<>) of Integer;
   subtype Vector_H is Vector(1..H);
   subtype Vector_2H is Vector(1..2*H);
   subtype Vector_3H is Vector(1..3*H);
   subtype Vector_4H is Vector(1..4*H);
   subtype Vector_5H is Vector(1..5*H);
   subtype Vector_6H is Vector(1..6*H);
   subtype Vector_N is Vector(1..N);

   type Matrix is array(Integer range<>) of Vector_N;
   subtype Matrix_H is Matrix(1..H);
   subtype Matrix_2H is Matrix(1..2*H);
   subtype Matrix_3H is Matrix(1..3*H);
   subtype Matrix_4H is Matrix(1..4*H);
   subtype Matrix_5H is Matrix(1..5*H);
   subtype Matrix_6H is Matrix(1..6*H);
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
      entry SetMOME(MO, ME: in Matrix_H);
      entry GetMin(a : out Integer);
      entry SetMin(a: in Integer);
      entry GetMA(MA: out Matrix_H);
   end Task1;

   task Task2 is
      entry SetMKZd(MK: in Matrix_N; Z: in Vector_6H; d : in Integer);
      entry SetMOME(MO, ME: in Matrix_2H);
      entry GetMin(a : out Integer);
      entry SetMin(a: in Integer);
      entry GetMA(MA: out Matrix_2H);
   end Task2;

   task Task3 is
      entry SetMKZd(MK: in Matrix_N; Z: in Vector_5H; d : in Integer);
   end Task3;

   task Task4 is
      entry SetMOMEMKZd(MO, ME: in Matrix_4H; MK: in Matrix_N; Z: in Vector_4H; d : in Integer);
      entry GetMin(a : out Integer);
      entry SetMin(a: in Integer);
      entry GetMA(MA: out Matrix_4H);
   end Task4;

   task Task5 is
      entry SetMOMEMKZd(MO, ME: in Matrix_H; MK: in Matrix_N; Z: in Vector_H; d : in Integer);
      entry GetMin(a : out Integer);
      entry SetMin(a: in Integer);
      entry GetMA(MA: out Matrix_H);
   end Task5;

   task Task6 is
      entry SetMOMEMKZd(MO, ME: in Matrix_H; MK: in Matrix_N; Z: in Vector_H; d : in Integer);
      entry GetMin(a : out Integer);
      entry SetMin(a: in Integer);
      entry GetMA(MA: out Matrix_H);
   end Task6;

   task Task7 is
      entry SetMOMEMKZd(MO, ME: in Matrix_H; MK: in Matrix_N; Z: in Vector_H; d : in Integer);
      entry GetMin(a : out Integer);
      entry SetMin(a: in Integer);
      entry GetMA(MA: out Matrix_H);
   end Task7;

   task body Task1 is
      MO_H, ME_H, MA_H : Matrix_H;
      MK : Matrix_N;
      Z : Vector_N;
      a1, d, cell : Integer;
   begin
      Put_Line("Task 1 started");

      --input data
      d:=1;
      VectorInput(Z);
      MatrixInput(MK);
      --Z(1):=-1;

      --send data to T2
      Task2.SetMKZd(MK(1..N), Z(H+1..N), d);

      accept SetMOME(MO, ME: in Matrix_H) do
         MO_H:=MO;
         ME_H:=ME;
      end SetMOME;

      --compute min
      a1 := Z(1);
      for i in 2..H loop
         if Z(i)<a1 then
            a1 := Z(i);
         end if;
      end loop;

      accept GetMin(a : out Integer) do
         a:=a1;
      end GetMin;

      accept SetMin(a: in Integer) do
         a1 := a;
      end SetMin;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + ME_H(i)(k)*MK(k)(j);
            end loop;
            MA_H(i)(j) := d*MO_H(i)(j) + a1*cell;
         end loop;
      end loop;

      accept GetMA(MA: out Matrix_H) do
         MA := MA_H;
      end GetMA;

      Put_Line("Task 1 finished");

   end Task1;

   task body Task2 is
      MO_2H, ME_2H, MA_2H : Matrix_2H;
      MK2 : Matrix_N;
      Z_6H : Vector_6H;
      a1, a2, d2, cell : Integer;
   begin
      Put_Line("Task 2 started");

      accept SetMKZd(MK: in Matrix_N; Z: in Vector_6H; d : in Integer) do
         MK2:= MK;
         Z_6H:=Z;
         d2:=d;
      end SetMKZd;

      accept SetMOME(MO, ME: in Matrix_2H) do
         MO_2H:=MO;
         ME_2H:=ME;
      end SetMOME;

      --send data to T3
      Task3.SetMKZd(MK2(1..N), Z_6H(H+1..6*H), d2);

      --send data to T1
      Task1.SetMOME(MO_2H(1..H), ME_2H(1..H));

      --compute min
      a2 := Z_6H(1);
      for i in 2..H loop
         if Z_6H(i)<a2 then
            a2 := Z_6H(i);
         end if;
      end loop;

      Task1.GetMin(a1);
      if a1<a2 then
         a2:=a1;
      end if;

      accept GetMin(a : out Integer) do
         a:=a2;
      end GetMin;

      accept SetMin(a: in Integer) do
         a2 := a;
      end SetMin;

      Task1.SetMin(a2);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + ME_2H(i+H)(k)*MK2(k)(j);
            end loop;
            MA_2H(i+H)(j) := d2*MO_2H(i+H)(j) + a2*cell;
         end loop;
      end loop;

      Task1.GetMA(MA_2H(1..H));

      accept GetMA(MA: out Matrix_2H) do
         MA := MA_2H;
      end GetMA;

      Put_Line("Task 2 finished");

   end Task2;

   task body Task3 is
      MO, ME, MA : Matrix_N;
      MK3 : Matrix_N;
      Z_5H : Vector_5H;
      a2, a3, a4, d3, cell : Integer;
   begin
      Put_Line("Task 3 started");

      --input data
      MatrixInput(MO);
      MatrixInput(ME);

      --send data to T2
      Task2.SetMOME(MO(1..2*H), ME(1..2*H));

      accept SetMKZd(MK: in Matrix_N; Z: in Vector_5H; d : in Integer) do
         MK3:= MK;
         Z_5H:=Z;
         d3:=d;
      end SetMKZd;

      --send data to T4
      Task4.SetMOMEMKZd(MO(3*H+1..N), ME(3*H+1..N), MK3(1..N), Z_5H(H+1..5*H), d3);

      --compute min
      a3 := Z_5H(1);
      for i in 2..H loop
         if Z_5H(i)<a3 then
            a3 := Z_5H(i);
         end if;
      end loop;

      Task2.GetMin(a2);
      if a2<a3 then
         a3:=a2;
      end if;

      Task4.GetMin(a4);
      if a4<a3 then
         a3:=a4;
      end if;

      Task2.SetMin(a3);
      Task4.SetMin(a3);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + ME(i+2*H)(k)*MK3(k)(j);
            end loop;
            MA(i+2*H)(j) := d3*MO(i+2*H)(j) + a3*cell;
         end loop;
      end loop;

      Task2.GetMA(MA(1..2*H));
      Task4.GetMA(MA(3*H+1..N));

      --show results
      New_Line;
      Put("MA = ");
      New_Line;
      MatrixOutput(MA);
      New_Line;

      Put_Line("Task 3 finished");
   end Task3;

   task body Task4 is
      MO_4H, ME_4H, MA_4H : Matrix_4H;
      MK4 : Matrix_N;
      Z_4H : Vector_4H;
      a4, a5, a6, a7, d4, cell : Integer;
   begin
      Put_Line("Task 4 started");

      accept SetMOMEMKZd(MO, ME: in Matrix_4H; MK: in Matrix_N; Z: in Vector_4H; d : in Integer) do
         MO_4H:=MO;
         ME_4H:=ME;
         MK4:= MK;
         Z_4H:=Z;
         d4:=d;
      end SetMOMEMKZd;

      --send data to T5
      Task5.SetMOMEMKZd(MO_4H(H+1..2*H), ME_4H(H+1..2*H), MK4(1..N), Z_4H(H+1..2*H), d4);

      --send data to T6
      Task6.SetMOMEMKZd(MO_4H(2*H+1..3*H), ME_4H(2*H+1..3*H), MK4(1..N), Z_4H(2*H+1..3*H), d4);

      --send data to T7
      Task7.SetMOMEMKZd(MO_4H(3*H+1..4*H), ME_4H(3*H+1..4*H), MK4(1..N), Z_4H(3*H+1..4*H), d4);

      --compute min
      a4 := Z_4H(1);
      for i in 2..H loop
         if Z_4H(i)<a4 then
            a4 := Z_4H(i);
         end if;
      end loop;

      Task5.GetMin(a5);
      if a5<a4 then
         a4:=a5;
      end if;

      Task6.GetMin(a6);
      if a6<a4 then
         a4:=a6;
      end if;

      Task7.GetMin(a7);
      if a7<a4 then
         a4:=a7;
      end if;

      accept GetMin(a : out Integer) do
         a:=a4;
      end GetMin;

      accept SetMin(a: in Integer) do
         a4 := a;
      end SetMin;

      Task5.SetMin(a4);
      Task6.SetMin(a4);
      Task7.SetMin(a4);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + ME_4H(i)(k)*MK4(k)(j);
            end loop;
            MA_4H(i)(j) := d4*MO_4H(i)(j) + a4*cell;
         end loop;
      end loop;

      Task5.GetMA(MA_4H(H+1..2*H));
      Task6.GetMA(MA_4H(2*H+1..3*H));
      Task7.GetMA(MA_4H(3*H+1..4*H));

      accept GetMA(MA: out Matrix_4H) do
         MA := MA_4H;
      end GetMA;

      Put_Line("Task 4 finished");

   end Task4;

   task body Task5 is
      MO_H, ME_H, MA_H : Matrix_H;
      MK5 : Matrix_N;
      Z_H : Vector_H;
      a5, d5, cell : Integer;
   begin
      Put_Line("Task 5 started");

      accept SetMOMEMKZd(MO, ME: in Matrix_H; MK: in Matrix_N; Z: in Vector_H; d : in Integer) do
         MO_H:=MO;
         ME_H:=ME;
         MK5:= MK;
         Z_H:=Z;
         d5:=d;
      end SetMOMEMKZd;

      --compute min
      a5 := Z_H(1);
      for i in 2..H loop
         if Z_H(i)<a5 then
            a5 := Z_H(i);
         end if;
      end loop;

      accept GetMin(a : out Integer) do
         a:=a5;
      end GetMin;

      accept SetMin(a: in Integer) do
         a5 := a;
      end SetMin;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + ME_H(i)(k)*MK5(k)(j);
            end loop;
            MA_H(i)(j) := d5*MO_H(i)(j) + a5*cell;
         end loop;
      end loop;

      accept GetMA(MA: out Matrix_H) do
         MA := MA_H;
      end GetMA;

      Put_Line("Task 5 finished");

   end Task5;

   task body Task6 is
      MO_H, ME_H, MA_H : Matrix_H;
      MK6 : Matrix_N;
      Z_H : Vector_H;
      a6, d6, cell : Integer;
   begin
      Put_Line("Task 6 started");

      accept SetMOMEMKZd(MO, ME: in Matrix_H; MK: in Matrix_N; Z: in Vector_H; d : in Integer) do
         MO_H:=MO;
         ME_H:=ME;
         MK6:= MK;
         Z_H:=Z;
         d6:=d;
      end SetMOMEMKZd;

      --compute min
      a6 := Z_H(1);
      for i in 2..H loop
         if Z_H(i)<a6 then
            a6 := Z_H(i);
         end if;
      end loop;

      accept GetMin(a : out Integer) do
         a:=a6;
      end GetMin;

      accept SetMin(a: in Integer) do
         a6 := a;
      end SetMin;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + ME_H(i)(k)*MK6(k)(j);
            end loop;
            MA_H(i)(j) := d6*MO_H(i)(j) + a6*cell;
         end loop;
      end loop;

      accept GetMA(MA: out Matrix_H) do
         MA := MA_H;
      end GetMA;

      Put_Line("Task 6 finished");

   end Task6;

   task body Task7 is
      MO_H, ME_H, MA_H : Matrix_H;
      MK7 : Matrix_N;
      Z_H : Vector_H;
      a7, d7, cell : Integer;
   begin
      Put_Line("Task 7 started");

      accept SetMOMEMKZd(MO, ME: in Matrix_H; MK: in Matrix_N; Z: in Vector_H; d : in Integer) do
         MO_H:=MO;
         ME_H:=ME;
         MK7:= MK;
         Z_H:=Z;
         d7:=d;
      end SetMOMEMKZd;

      --compute min
      a7 := Z_H(1);
      for i in 2..H loop
         if Z_H(i)<a7 then
            a7 := Z_H(i);
         end if;
      end loop;

      accept GetMin(a : out Integer) do
         a:=a7;
      end GetMin;

      accept SetMin(a: in Integer) do
         a7 := a;
      end SetMin;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + ME_H(i)(k)*MK7(k)(j);
            end loop;
            MA_H(i)(j) := d7*MO_H(i)(j) + a7*cell;
         end loop;
      end loop;

      accept GetMA(MA: out Matrix_H) do
         MA := MA_H;
      end GetMA;

      Put_Line("Task 7 finished");

   end Task7;


begin
   null;
end Main;
