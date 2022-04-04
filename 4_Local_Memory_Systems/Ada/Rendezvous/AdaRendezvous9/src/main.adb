with Ada.Text_IO, Ada.Integer_Text_IO;
use Ada.Text_IO, Ada.Integer_Text_IO;
----------------Main program---------------
--Programming for parallel computer systems
--Laboratory work #7. Ada. Rendezvous
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--22.05.2017
--Task: MA = d*MO*MK - e*MZ
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
      entry SetData(MK: in Matrix_N; MO, MZ: in Matrix_H; d,e : in Integer);
      entry GetResult(MA: out Matrix_H);
   end Task1;

   task Task2 is
   end Task2;

   task Task3 is
      entry SetData(MK: in Matrix_N; MO, MZ: in Matrix_H; d,e : in Integer);
      entry GetResult(MA: out Matrix_H);
   end Task3;

   task Task4 is
      entry SetData(MK: in Matrix_N; MO, MZ: in Matrix_4H; d,e : in Integer);
      entry GetResult(MA: out Matrix_4H);
   end Task4;

   task Task5 is
      entry SetData(MK: in Matrix_N; MO, MZ: in Matrix_H; d,e : in Integer);
      entry GetResult(MA: out Matrix_H);
   end Task5;

   task Task6 is
      entry SetData(MK: in Matrix_N; MO, MZ: in Matrix_2H; d,e : in Integer);
      entry GetResult(MA: out Matrix_2H);
   end Task6;

   task body Task1 is
      MK1: Matrix_N;
      MO_H, MZ_H, MA_H: Matrix_H;
      d1, e1, cell:Integer;
   begin
      Put_Line("Task 1 started");

      accept SetData(MK: in Matrix_N; MO, MZ: in Matrix_H; d,e : in Integer) do
         MK1:=MK;
         MO_H:=MO;
         MZ_H:=MZ;
         d1:=d;
         e1:=e;
      end SetData;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_H(i)(k)*MK1(k)(j);
            end loop;
         MA_H(i)(j):=d1*cell - e1*MZ_H(i)(j);
         end loop;
      end loop;

      accept GetResult(MA: out Matrix_H) do
         MA := MA_H;
      end GetResult;

      Put_Line("Task 1 finished");
   end Task1;

   task body Task2 is
      MK, MZ, MO, MA: Matrix_N;
      d, e, cell:Integer;
   begin
      Put_Line("Task 2 started");

      --input data
      MatrixInput(MK);
      MatrixInput(MO);
      MatrixInput(MZ);
      d:=1;
      e:=1;

      Task4.SetData(MK, MO(2*H+1..N), MZ(2*H+1..N), d, e);
      Task1.SetData(MK, MO(H+1..2*H), MZ(H+1..2*H), d, e);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO(i+H)(k)*MK(k)(j);
            end loop;
         MA(i+H)(j):=d*cell - e*MZ(i+H)(j);
         end loop;
      end loop;

      Task1.GetResult(MA(1..H));
      Task4.GetResult(MA(2*H+1..N));

      --show results
      New_Line;
      Put("MA = ");
      New_Line;
      MatrixOutput(MA);
      New_Line;

      Put_Line("Task 2 finished");

   end Task2;

   task body Task3 is
      MK3: Matrix_N;
      MO_H, MZ_H, MA_H: Matrix_H;
      d3, e3, cell:Integer;
   begin
      Put_Line("Task 3 started");

      accept SetData(MK: in Matrix_N; MO, MZ: in Matrix_H; d,e : in Integer) do
         MK3:=MK;
         MO_H:=MO;
         MZ_H:=MZ;
         d3:=d;
         e3:=e;
      end SetData;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_H(i)(k)*MK3(k)(j);
            end loop;
            MA_H(i)(j):=d3*cell - e3*MZ_H(i)(j);
         end loop;
      end loop;

      accept GetResult(MA: out Matrix_H) do
         MA := MA_H;
      end GetResult;

      Put_Line("Task 3 finished");
   end Task3;

   task body Task4 is
      MK4: Matrix_N;
      MO_4H, MZ_4H, MA_4H: Matrix_4H;
      d4, e4, cell:Integer;
   begin
      Put_Line("Task 4 started");

      accept SetData(MK: in Matrix_N; MO, MZ: in Matrix_4H; d,e : in Integer) do
         MK4:=MK;
         MO_4H:=MO;
         MZ_4H:=MZ;
         d4:=d;
         e4:=e;
      end SetData;

      Task6.SetData(MK4, MO_4H(2*H+1..4*H), MZ_4H(2*H+1..4*H), d4, e4);
      Task3.SetData(MK4, MO_4H(1..H), MZ_4H(1..H), d4, e4);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_4H(i+H)(k)*MK4(k)(j);
            end loop;
            MA_4H(i+H)(j):=d4*cell - e4*MZ_4H(i+H)(j);
         end loop;
      end loop;

      Task3.GetResult(MA_4H(1..H));
      Task6.GetResult(MA_4H(2*H+1..4*H));

      accept GetResult(MA: out Matrix_4H) do
         MA := MA_4H;
      end GetResult;

      Put_Line("Task 4 finished");

   end Task4;

   task body Task5 is
      MK5: Matrix_N;
      MO_H, MZ_H, MA_H: Matrix_H;
      d5, e5, cell:Integer;
   begin
      Put_Line("Task 5 started");

      accept SetData(MK: in Matrix_N; MO, MZ: in Matrix_H; d,e : in Integer) do
         MK5:=MK;
         MO_H:=MO;
         MZ_H:=MZ;
         d5:=d;
         e5:=e;
      end SetData;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_H(i)(k)*MK5(k)(j);
            end loop;
            MA_H(i)(j):=d5*cell - e5*MZ_H(i)(j);
         end loop;
      end loop;

      accept GetResult(MA: out Matrix_H) do
         MA := MA_H;
      end GetResult;

      Put_Line("Task 5 finished");

   end Task5;

   task body Task6 is
      MK6: Matrix_N;
      MO_2H, MZ_2H, MA_2H: Matrix_2H;
      d6, e6, cell:Integer;
   begin
      Put_Line("Task 6 started");

      accept SetData(MK: in Matrix_N; MO, MZ: in Matrix_2H; d,e : in Integer) do
         MK6:=MK;
         MO_2H:=MO;
         MZ_2H:=MZ;
         d6:=d;
         e6:=e;
      end SetData;

      Task5.SetData(MK6, MO_2H(1..H), MZ_2H(1..H), d6, e6);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_2H(i+H)(k)*MK6(k)(j);
            end loop;
            MA_2H(i+H)(j):=d6*cell - e6*MZ_2H(i+H)(j);
         end loop;
      end loop;

      Task5.GetResult(MA_2H(1..H));

      accept GetResult(MA: out Matrix_2H) do
         MA := MA_2H;
      end GetResult;

      Put_Line("Task 6 finished");

   end Task6;

begin
   null;
end Main;
