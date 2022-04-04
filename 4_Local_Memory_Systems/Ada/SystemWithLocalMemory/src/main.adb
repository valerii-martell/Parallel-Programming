with Ada.Text_IO, Ada.Integer_Text_IO, Ada.Calendar;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Calendar;
------------------------Main program------------------------------
--Programming for parallel computer systems
--Course work part #2. System with local memory. Ada. Rendezvous
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--25.04.2017
--Task: MA = (MB*MC)*e + max(Z)*MO
------------------------------------------------------------------
procedure Main is
   N: Integer := 12;
   P: Integer := 6;
   H: Integer := N / P;

   StartTime, FinishTime: Time;
   DiffTime: Duration;

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
      else
         Put("Output is too big");
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
      entry SetMCZe(MC :in Matrix_N; Z : in Vector_2H; e : in Integer);
      entry GetMax(a: out Integer);
      entry SetMax(a: in Integer);
      entry GetMA(MA: out Matrix_2H);
   end Task1;
   task Task2 is
      entry SetData(MC: in Matrix_N; MB : in Matrix_H; MO : in Matrix_H; Z : in Vector_H; e : in Integer);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
      entry GetMA(MA : out Matrix_H);
   end Task2;
   task Task3 is
      entry SetMBMO(MB: in Matrix_4H; MO: in Matrix_4H);
      entry SetZe(Z: in Vector_4H; e : in Integer);
      entry GetMA(MA: out Matrix_4H);
   end Task3;
   task Task4 is
      entry SetData(MC: in Matrix_N; MB : in Matrix_H; MO : in Matrix_H; Z : in Vector_H; e : in Integer);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
      entry GetMA(MA : out Matrix_H);
   end Task4;
   task Task5 is
      entry SetMCMBMO(MC : in Matrix_N; MB : in Matrix_2H; MO : in Matrix_2H);
      entry GetMax(a: out Integer);
      entry SetMax(a: in Integer);
      entry GetMA(MA : out Matrix_5H);
   end Task5;
   task Task6 is
      entry SetData(MC: in Matrix_N; MB : in Matrix_H; MO : in Matrix_H; Z : in Vector_H; e : in Integer);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
   end Task6;

   task body Task1 is

      MC1: Matrix_N;

      Z_2H: Vector_2H;

      MB: Matrix_N;
      MO: Matrix_N;

      MA_2H : Matrix_2H;

      e1:Integer;
      cell :Integer;
      a1,a2: Integer;
   begin
      Put_Line("Task 1 started");

      --input data
      MatrixInput(MB);
      MatrixInput(MO);

      --send fata to T3
      Task3.SetMBMO(MB(2*H+1..N), MO(2*H+1..N));

      --pause while T3 get data
      accept SetMCZe(MC :in Matrix_N; Z : in Vector_2H; e : in Integer) do
         MC1:=MC;
         Z_2H:=Z;
         e1:=e;
      end SetMCZe;

      --send data to T2
      Task2.SetData(MC1(1..N), MB(H+1..2*H), MO(H+1..2*H), Z_2H(H+1..2*H), e1);

      --compute max
      a1 := Z_2H(1);
      for i in 2..H loop
         if Z_2H(i)>a1 then
            a1 := Z_2H(i);
         end if;
      end loop;

      Task2.GetMax(a2);
      if a2>a1 then
         a1:=a2;
      end if;

      --send max to T3
      accept GetMax(a: out Integer) do
         a := a1;
      end GetMax;

      --recive max from T3
      accept SetMax(a: in Integer) do
         a1 := a;
      end SetMax;

      --send max to T2
      Task2.SetMax(a1);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MB(i)(k)*MC1(k)(j);
            end loop;
            MA_2H(i)(j) := e1*cell + a1*MO(i)(j);
         end loop;
      end loop;

      Task2.GetMA(MA_2H(H+1..2*H));

      accept GetMA(MA: out Matrix_2H) do
         MA := MA_2H;
      end GetMA;

      Put_Line("Task 1 finished");
   end Task1;

   task body Task2 is
      MC2: Matrix_N;

      Z_H: Vector_H;

      MB_H: Matrix_H;
      MO_H: Matrix_H;

      MA_H : Matrix_H;

      e2:Integer;
      cell :Integer;
      a2: Integer;
   begin
      Put_Line("Task 2 started");

      accept SetData(MC: in Matrix_N; MB : in Matrix_H; MO : in Matrix_H; Z : in Vector_H; e : in Integer) do
         MC2:= MC;
         MB_H:=MB;
         MO_H:=MO;
         Z_H:=Z;
         e2:=e;
      end SetData;

      --compute max
      a2 := Z_H(1);
      for i in 2..H loop
         if Z_H(i)>a2 then
            a2 := Z_H(i);
         end if;
      end loop;

      --send max to T1
      accept GetMax(a : out Integer) do
         a:=a2;
      end GetMax;

      --recive max from T1
      accept SetMax(a: in Integer) do
         a2 := a;
      end SetMax;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MB_H(i)(k)*MC2(k)(j);
            end loop;
            MA_H(i)(j) := e2*cell + a2*MO_H(i)(j);
         end loop;
      end loop;

      accept GetMA(MA : out Matrix_H) do
         MA:=MA_H(1..H);
      end GetMA;

      Put_Line("Task 2 finished");
   end Task2;

   task body Task3 is
      MC: Matrix_N;

      Z_4H: Vector_4H;

      MB_4H: Matrix_4H;
      MO_4H: Matrix_4H;

      MA_4H : Matrix_4H;

      e3:Integer;
      cell :Integer;
      a1, a3, a4, a5: Integer;
   begin
      Put_Line("Task 3 started");

      --input data
      MatrixInput(MC);

      accept SetMBMO(MB: in Matrix_4H; MO: in Matrix_4H) do
         MB_4H:= MB;
         MO_4H:=MO;
      end SetMBMO;

      accept SetZe(Z: in Vector_4H; e : in Integer) do
         Z_4H:= Z;
         e3:=e;
      end SetZe;

      --send fata to T1, T5, T4
      Task1.SetMCZe(MC(1..N), Z_4H(1..2*H), e3);
      Task5.SetMCMBMO(MC(1..N), MB_4H(2*H+1..4*H), MO_4H(2*H+1..4*H));
      Task4.SetData(MC(1..N), MB_4H(H+1..2*H), MO_4H(H+1..2*H), Z_4H(3*H+1..4*H), e3);

      --compute max
      a3 := Z_4H(2*H+1);
      for i in 2*H+2..3*H loop
         if Z_4H(i)>a3 then
            a3 := Z_4H(i);
         end if;
      end loop;

      Task4.GetMax(a4);
      if a4>a3 then
         a3:=a4;
      end if;

      Task1.GetMax(a1);
      if a1>a3 then
         a3:=a1;
      end if;

      Task5.GetMax(a5);
      if a5>a3 then
         a3:=a5;
      end if;

      Task4.SetMax(a3);
      Task1.SetMax(a3);
      Task5.SetMax(a3);

      --compute
      for i in 2*H+1..3*H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MB_4H(i)(k)*MC(k)(j);
            end loop;
            MA_4H(i)(j) := e3*cell + a3*MO_4H(i)(j);
         end loop;
      end loop;

      Task1.GetMA(MA_4H(1..2*H));
      Task4.GetMA(MA_4H(3*H+1..4*H));

      accept GetMA(MA: out Matrix_4H) do
         MA := MA_4H(1..4*H);
      end GetMA;

      Put_Line("Task 3 finished");
   end Task3;

   task body Task4 is
      MC4: Matrix_N;

      Z_H: Vector_H;

      MB_H: Matrix_H;
      MO_H: Matrix_H;

      MA_H : Matrix_H;

      e4:Integer;
      cell :Integer;
      a4: Integer;
   begin
      Put_Line("Task 4 started");

      accept SetData(MC: in Matrix_N; MB : in Matrix_H; MO : in Matrix_H; Z : in Vector_H; e : in Integer) do
         MC4:= MC;
         MB_H:=MB;
         MO_H:=MO;
         Z_H:=Z;
         e4:=e;
      end SetData;

      --compute max
      a4 := Z_H(1);
      for i in 2..H loop
         if Z_H(i)>a4 then
            a4 := Z_H(i);
         end if;
      end loop;

      --send max to T3
      accept GetMax(a : out Integer) do
         a:=a4;
      end GetMax;

      --recive max from T3
      accept SetMax(a: in Integer) do
         a4 := a;
      end SetMax;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MB_H(i)(k)*MC4(k)(j);
            end loop;
            MA_H(i)(j) := e4*cell + a4*MO_H(i)(j);
         end loop;
      end loop;

      accept GetMA(MA : out Matrix_H) do
         MA:=MA_H(1..H);
      end GetMA;

      Put_Line("Task 4 finished");

   end Task4;

   task body Task5 is
      MC5: Matrix_N;

      Z: Vector_N;

      MB_2H: Matrix_2H;
      MO_2H: Matrix_2H;

      MA_5H : Matrix_5H;

      e:Integer;
      cell :Integer;
      a5,a6: Integer;
   begin
      Put_Line("Task 5 started");

      --input data
      e:=1;
      VectorInput(Z);
      --Z(2):=5;

      --send fata to T3 and T4
      Task3.SetZe(Z(1..4*H), e);

      accept SetMCMBMO(MC : in Matrix_N; MB : in Matrix_2H; MO : in Matrix_2H) do
         MC5:=MC;
         MB_2H:=MB;
         MO_2H:=MO;
      end SetMCMBMO;

      Task6.SetData(MC5(1..N), MB_2H(H+1..2*H), MO_2H(H+1..2*H), Z(5*H+1..N), e);

      --compute max
      a5 := Z(4*H+1);
      for i in 4*H+2..5*H loop
         if Z(i)>a5 then
            a5 := Z(i);
         end if;
      end loop;

      Task6.GetMax(a6);
      if a6>a5 then
         a5:=a6;
      end if;

      --send max to T3
      accept GetMax(a: out Integer) do
         a := a5;
      end GetMax;

      --recive max from T3
      accept SetMax(a: in Integer) do
         a5 := a;
      end SetMax;

      --send max to T6
      Task6.SetMax(a5);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MB_2H(i)(k)*MC5(k)(j);
            end loop;
            MA_5H(i+4*H)(j) := e*cell + a5*MO_2H(i)(j);
         end loop;
      end loop;

      Task3.GetMA(MA_5H(1..4*H));

      accept GetMA(MA : out Matrix_5H) do
         MA:=MA_5H;
      end GetMA;

      Put_Line("Task 5 finished");
   end Task5;

   task body Task6 is
      MC6: Matrix_N;

      Z_H: Vector_H;

      MB_H: Matrix_H;
      MO_H: Matrix_H;

      MA : Matrix_N;

      e6:Integer;
      cell :Integer;
      a6: Integer;
   begin
      Put_Line("Task 6 started");

      accept SetData(MC: in Matrix_N; MB : in Matrix_H; MO : in Matrix_H; Z : in Vector_H; e : in Integer) do
         MC6:= MC;
         MB_H:=MB;
         MO_H:=MO;
         Z_H:=Z;
         e6:=e;
      end SetData;

      --compute max
      a6 := Z_H(1);
      for i in 2..H loop
         if Z_H(i)>a6 then
            a6 := Z_H(i);
         end if;
      end loop;

      --send max to T5
      accept GetMax(a : out Integer) do
         a:=a6;
      end GetMax;

      --recive max from T5
      accept SetMax(a: in Integer) do
         a6 := a;
      end SetMax;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MB_H(i)(k)*MC6(k)(j);
            end loop;
            MA(i+5*H)(j) := e6*cell + a6*MO_H(i)(j);
         end loop;
      end loop;

      Task5.GetMA(MA(1..5*H));

      --show results
      New_Line;
      Put("MA = ");
      New_Line;
      MatrixOutput(MA);
      New_Line;

      Put_Line("Task 6 finished");

      FinishTime := Clock;
      DiffTime := FinishTime - StartTime;

      Put("Time : ");
      Put(Integer(DiffTime), 1);
      Put_Line("");
   end Task6;

begin
   StartTime := Clock;
end Main;

