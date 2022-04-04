with Ada.Text_IO, Ada.Integer_Text_IO;
use Ada.Text_IO, Ada.Integer_Text_IO;
----------------Main program---------------
--Programming for parallel computer systems
--Laboratory work #7. Ada. Rendezvous
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--22.05.2017
--Task: MA = d*MO + e*MT*MK
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
      entry SetData(MK :in Matrix_N; MO, MT : in Matrix_H; d, e : in Integer);
      entry GetResult(MA: out Matrix_H);
   end Task1;

   task Task2 is
      entry SetData(MK :in Matrix_N; MO, MT : in Matrix_4H; d, e : in Integer);
      entry GetResult(MA: out Matrix_4H);
   end Task2;

   task Task3 is
      entry SetData(MK :in Matrix_N; MO, MT : in Matrix_2H; d, e : in Integer);
      entry GetResult(MA: out Matrix_2H);
   end Task3;

   task Task4 is
      entry SetData(MK :in Matrix_N; MO, MT : in Matrix_5H; d, e : in Integer);
      entry GetResult(MA: out Matrix_5H);
   end Task4;

   task Task5 is
      entry SetData(MK :in Matrix_N; MO, MT : in Matrix_H; d, e : in Integer);
      entry GetResult(MA: out Matrix_H);
   end Task5;

   task Task6 is
   end Task6;

   task body Task1 is
      MK1: Matrix_N;
      MO_H, MT_H, MA_H:Matrix_H;
      d1, e1, cell:Integer;
   begin
      Put_Line("Task 1 started");

      accept SetData(MK :in Matrix_N; MO, MT : in Matrix_H; d, e : in Integer) do
         MK1:=MK;
         e1:=e;
         d1:=d;
         MO_H:=MO;
         MT_H:=MT;
      end SetData;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MT_H(i)(k)*MK1(k)(j);
            end loop;
            MA_H(i)(j) := d1*MO_H(i)(j) + e1*cell;
         end loop;
      end loop;

      accept GetResult(MA: out Matrix_H) do
         MA := MA_H;
      end GetResult;

      Put_Line("Task 1 finished");
   end Task1;

   task body Task2 is
      MK2: Matrix_N;
      MO_4H, MT_4H, MA_4H:Matrix_4H;
      d2, e2, cell:Integer;
   begin
      Put_Line("Task 2 started");

      accept SetData(MK :in Matrix_N; MO, MT : in Matrix_4H; d, e : in Integer) do
         MK2:=MK;
         e2:=e;
         d2:=d;
         MO_4H:=MO;
         MT_4H:=MT;
      end SetData;

      Task1.SetData(MK2, MO_4H(1..H), MT_4H(1..H), d2, e2);
      Task3.SetData(MK2, MO_4H(2*H+1..4*H), MT_4H(2*H+1..4*H), d2, e2);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MT_4H(i+H)(k)*MK2(k)(j);
            end loop;
            MA_4H(i+H)(j) := d2*MO_4H(i+H)(j) + e2*cell;
         end loop;
      end loop;

      Task1.GetResult(MA_4H(1..H));
      Task3.GetResult(MA_4H(2*H+1..4*H));

      accept GetResult(MA: out Matrix_4H) do
         MA := MA_4H;
      end GetResult;

      Put_Line("Task 2 finished");

   end Task2;

   task body Task3 is
      MK3: Matrix_N;
      MO_2H, MT_2H, MA_2H:Matrix_2H;
      d3, e3, cell:Integer;
   begin
      Put_Line("Task 3 started");

      accept SetData(MK :in Matrix_N; MO, MT : in Matrix_2H; d, e : in Integer) do
         MK3:=MK;
         e3:=e;
         d3:=d;
         MO_2H:=MO;
         MT_2H:=MT;
      end SetData;

      Task5.SetData(MK3, MO_2H(H+1..2*H), MT_2H(H+1..2*H), d3, e3);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MT_2H(i)(k)*MK3(k)(j);
            end loop;
            MA_2H(i)(j) := d3*MO_2H(i)(j) + e3*cell;
         end loop;
      end loop;

      Task5.GetResult(MA_2H(H+1..2*H));

      accept GetResult(MA: out Matrix_2H) do
         MA := MA_2H;
      end GetResult;

      Put_Line("Task 3 finished");
   end Task3;

   task body Task4 is
      MK4: Matrix_N;
      MO_5H, MT_5H, MA_5H:Matrix_5H;
      d4, e4, cell:Integer;
   begin
      Put_Line("Task 4 started");

      accept SetData(MK :in Matrix_N; MO, MT : in Matrix_5H; d, e : in Integer) do
         MK4:=MK;
         e4:=e;
         d4:=d;
         MO_5H:=MO;
         MT_5H:=MT;
      end SetData;

      Task2.SetData(MK4, MO_5H(1..4*H), MT_5H(1..4*H), d4, e4);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MT_5H(i+4*H)(k)*MK4(k)(j);
            end loop;
            MA_5H(i+4*H)(j) := d4*MO_5H(i+4*H)(j) + e4*cell;
         end loop;
      end loop;

      Task2.GetResult(MA_5H(1..4*H));

      accept GetResult(MA: out Matrix_5H) do
         MA := MA_5H;
      end GetResult;

      Put_Line("Task 4 finished");

   end Task4;

   task body Task5 is
      MK5: Matrix_N;
      MO_H, MT_H, MA_H:Matrix_H;
      d5, e5, cell:Integer;
   begin
      Put_Line("Task 5 started");

      accept SetData(MK :in Matrix_N; MO, MT : in Matrix_H; d, e : in Integer) do
         MK5:=MK;
         e5:=e;
         d5:=d;
         MO_H:=MO;
         MT_H:=MT;
      end SetData;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MT_H(i)(k)*MK5(k)(j);
            end loop;
            MA_H(i)(j) := d5*MO_H(i)(j) + e5*cell;
         end loop;
      end loop;

      accept GetResult(MA: out Matrix_H) do
         MA := MA_H;
      end GetResult;

      Put_Line("Task 5 finished");

   end Task5;

   task body Task6 is
      MK, MO, MT, MA: Matrix_N;
      d, e, cell:Integer;
   begin
      Put_Line("Task 6 started");

      d:=1;
      e:=1;
      MatrixInput(MT);
      MatrixInput(MK);
      MatrixInput(MO);

      Task4.SetData(MK, MO(1..5*H), MT(1..5*H), d, e);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MT(i+5*H)(k)*MK(k)(j);
            end loop;
            MA(i+5*H)(j) := d*MO(i+5*H)(j) + e*cell;
         end loop;
      end loop;

      Task4.GetResult(MA(1..5*H));

      --show results
      New_Line;
      Put("MA = ");
      New_Line;
      MatrixOutput(MA);
      New_Line;

      Put_Line("Task 6 finished");

   end Task6;

begin
   null;
end Main;
