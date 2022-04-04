with Ada.Text_IO, Ada.Integer_Text_IO, Ada.Calendar;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Calendar;
------------------------Main program------------------------------
--Programming for parallel computer systems
--Course work part #2. System with local memory. Ada. Rendezvous
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--20.05.2017
--Task: MA = min(Z)*MO + d*MT*MR
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
      entry SetMRd(MR :in Matrix_N; d : in Integer);
      entry SetMTZ(MT :in Matrix_3H; Z : in Vector_3H);
      entry GetMin(a: out Integer);
      entry SetMin(a: in Integer);
      entry GetMA(MA: out Matrix_H);
   end Task1;
   task Task2 is
      entry SetMTZMO(MT: in Matrix_2H; Z: in Vector_2H; MO : in Matrix_2H);
      entry GetMA(MA : out Matrix_2H);
   end Task2;
   task Task3 is
      entry SetMRd(MR :in Matrix_N; d : in Integer);
      entry SetMTZMO(MT: in Matrix_H; Z: in Vector_H; MO : in Matrix_H);
      entry GetMin(a: out Integer);
      entry SetMin(a: in Integer);
      entry GetMA(MA: out Matrix_3H);
   end Task3;
   task Task4 is
      entry SetMRd(MR :in Matrix_N; d : in Integer);
      entry SetMO(MO :in Matrix_3H);
      entry GetMin(a: out Integer);
      entry SetMin(a: in Integer);
      entry GetMA(MA : out Matrix_H);
   end Task4;
   task Task5 is
      entry SetMRd(MR :in Matrix_N; d : in Integer);
      entry SetMTZMO(MT: in Matrix_2H; Z: in Vector_2H; MO : in Matrix_2H);
      entry GetMin(a: out Integer);
      entry SetMin(a: in Integer);
      entry GetMA(MA : out Matrix_2H);
   end Task5;
   task Task6 is
      entry SetMRd(MR :in Matrix_N; d : in Integer);
      entry GetMin(a: out Integer);
      entry SetMin(a: in Integer);
      entry SetMTZMO(MT: in Matrix_H; Z: in Vector_H; MO : in Matrix_H);
   end Task6;

   task body Task1 is

      MR1: Matrix_N;

      Z_3H: Vector_3H;
      MT_3H:Matrix_3H;
      MO: Matrix_N;

      MA_H : Matrix_H;

      d1:Integer;
      cell :Integer;
      a1: Integer;
   begin
      Put_Line("Task 1 started");

      --input data
      MatrixInput(MO);

      accept SetMRd(MR :in Matrix_N; d : in Integer) do
         MR1:=MR;
         d1:=d;
      end SetMRd;

      Task4.SetMRd(MR1(1..N), d1);

      accept SetMTZ(MT :in Matrix_3H; Z : in Vector_3H) do
         MT_3H:=MT;
         Z_3H:=Z;
      end SetMTZ;

      Task4.SetMO(MO(3*H+1..N));

      Task2.SetMTZMO(MT_3H(H+1..3*H), Z_3H(H+1..3*H), MO(H+1..3*H));

      --compute min
      a1 := Z_3H(1);
      for i in 2..H loop
         if Z_3H(i)<a1 then
            a1 := Z_3H(i);
         end if;
      end loop;

      --send min to T2
      accept GetMin(a: out Integer) do
         a := a1;
      end GetMin;

      --recive min from T2
      accept SetMin(a: in Integer) do
         a1 := a;
      end SetMin;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MT_3H(i)(k)*MR1(k)(j);
            end loop;
            MA_H(i)(j) := d1*cell + a1*MO(i)(j);
         end loop;
      end loop;

      accept GetMA(MA : out Matrix_H) do
         MA:=MA_H(1..H);
      end GetMA;

      Put_Line("Task 1 finished");
   end Task1;

   task body Task2 is
      MR: Matrix_N;

      Z_2H: Vector_2H;
      MT_2H:Matrix_2H;
      MO_2H: Matrix_2H;

      MA_2H : Matrix_2H;

      d:Integer;
      cell :Integer;
      a1, a2, a3, a5: Integer;
   begin
      Put_Line("Task 2 started");

      MatrixInput(MR);
      d := 1;

      Task5.SetMRd(MR(1..N), d);
      Task1.SetMRd(MR(1..N), d);
      Task3.SetMRd(MR(1..N), d);

      accept SetMTZMO(MT: in Matrix_2H; Z: in Vector_2H; MO : in Matrix_2H) do
         MT_2H := MT;
         Z_2H:=Z;
         MO_2H:=MO;
      end SetMTZMO;

      Task3.SetMTZMO(MT_2H(H+1..2*H), Z_2H(H+1..2*H), MO_2H(H+1..2*H));

      --compute min
      a2 := Z_2H(1);
      for i in 2..H loop
         if Z_2H(i)<a2 then
            a2 := Z_2H(i);
         end if;
      end loop;

      Task1.GetMin(a1);
      if a1<a2 then
         a2:=a1;
      end if;

      Task3.GetMin(a3);
      if a3<a2 then
         a2:=a3;
      end if;

      Task5.GetMin(a5);
      if a5<a2 then
         a2:=a5;
      end if;

      Task5.SetMin(a2);
      Task1.SetMin(a2);
      Task3.SetMin(a2);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MT_2H(i)(k)*MR(k)(j);
            end loop;
            MA_2H(i+H)(j) := d*cell + a2*MO_2H(i)(j);
         end loop;
      end loop;

      Task1.GetMA(MA_2H(1..H));

      accept GetMA(MA : out Matrix_2H) do
         MA:=MA_2H(1..2*H);
      end GetMA;

      Put_Line("Task 2 finished");
   end Task2;

   task body Task3 is
      MR3: Matrix_N;

      Z_H: Vector_H;
      MT_H:Matrix_H;
      MO_H: Matrix_H;

      MA_3H : Matrix_3H;

      d3:Integer;
      cell :Integer;
      a3: Integer;
   begin
      Put_Line("Task 3 started");

      accept SetMRd(MR :in Matrix_N; d : in Integer) do
         MR3:=MR;
         d3:=d;
      end SetMRd;

      Task6.SetMRd(MR3(1..N), d3);

      accept SetMTZMO(MT: in Matrix_H; Z: in Vector_H; MO : in Matrix_H) do
         MT_H := MT;
         Z_H:=Z;
         MO_H:=MO;
      end SetMTZMO;

      --compute min
      a3 := Z_H(1);
      for i in 2..H loop
         if Z_H(i)<a3 then
            a3 := Z_H(i);
         end if;
      end loop;

      --send min to T2
      accept GetMin(a: out Integer) do
         a := a3;
      end GetMin;

      --recive min from T2
      accept SetMin(a: in Integer) do
         a3 := a;
      end SetMin;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MT_H(i)(k)*MR3(k)(j);
            end loop;
            MA_3H(i+2*H)(j) := d3*cell + a3*MO_H(i)(j);
         end loop;
      end loop;

      Task2.GetMA(MA_3H(1..2*H));

      accept GetMA(MA: out Matrix_3H) do
         MA := MA_3H(1..3*H);
      end GetMA;

      Put_Line("Task 3 finished");
   end Task3;

   task body Task4 is
      MR4: Matrix_N;

      Z: Vector_N;
      MT:Matrix_N;
      MO_3H: Matrix_3H;

      MA_H : Matrix_H;

      d4:Integer;
      cell :Integer;
      a4: Integer;
   begin
      Put_Line("Task 4 started");

      MatrixInput(MT);
      VectorInput(Z);
      --Z(2):=-1;

      accept SetMRd(MR :in Matrix_N; d : in Integer) do
         MR4:=MR;
         d4:=d;
      end SetMRd;

      Task1.SetMTZ(MT(1..3*H), Z(1..3*H));

      accept SetMO(MO :in Matrix_3H) do
         MO_3H:=MO;
      end SetMO;

      Task5.SetMTZMO(MT(4*H+1..N), Z(4*H+1..N), MO_3H(H+1..3*H));

      --compute min
      a4 := Z(3*H+1);
      for i in 3*H+2..4*H loop
         if Z(i)<a4 then
            a4 := Z(i);
         end if;
      end loop;

      --send min to T5
      accept GetMin(a: out Integer) do
         a := a4;
      end GetMin;

      --recive min from T5
      accept SetMin(a: in Integer) do
         a4 := a;
      end SetMin;

     --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MT(i+3*H)(k)*MR4(k)(j);
            end loop;
            MA_H(i)(j) := d4*cell + a4*MO_3H(i)(j);
         end loop;
      end loop;

      accept GetMA(MA : out Matrix_H) do
         MA:=MA_H(1..H);
      end GetMA;

      Put_Line("Task 4 finished");

   end Task4;

   task body Task5 is
      MR5: Matrix_N;

      Z_2H: Vector_2H;
      MT_2H:Matrix_2H;
      MO_2H: Matrix_2H;

      MA_2H : Matrix_2H;

      d5:Integer;
      cell :Integer;
      a4, a5, a6: Integer;
   begin
      Put_Line("Task 5 started");

      accept SetMRd(MR :in Matrix_N; d : in Integer) do
         MR5:=MR;
         d5:=d;
      end SetMRd;

      accept SetMTZMO(MT: in Matrix_2H; Z: in Vector_2H; MO : in Matrix_2H) do
         MT_2H := MT;
         Z_2H:=Z;
         MO_2H:=MO;
      end SetMTZMO;

      Task6.SetMTZMO(MT_2H(H+1..2*H), Z_2H(H+1..2*H), MO_2H(H+1..2*H));

      --compute min
      a5 := Z_2H(1);
      for i in 2..H loop
         if Z_2H(i)<a5 then
            a5 := Z_2H(i);
         end if;
      end loop;

      Task4.GetMin(a4);
      if a4<a5 then
         a5:=a4;
      end if;

      Task6.GetMin(a6);
      if a6<a5 then
         a5:=a6;
      end if;

      --send min to T2
      accept GetMin(a: out Integer) do
         a := a5;
      end GetMin;

      --recive min from T2
      accept SetMin(a: in Integer) do
         a5 := a;
      end SetMin;

      Task4.SetMin(a5);
      Task6.SetMin(a5);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MT_2H(i)(k)*MR5(k)(j);
            end loop;
            MA_2H(i+H)(j) := d5*cell + a5*MO_2H(i)(j);
         end loop;
      end loop;

      Task4.GetMA(MA_2H(1..H));

      accept GetMA(MA : out Matrix_2H) do
         MA:=MA_2H;
      end GetMA;

      Put_Line("Task 5 finished");
   end Task5;

   task body Task6 is
      MR6: Matrix_N;

      Z_H: Vector_H;
      MT_H:Matrix_H;
      MO_H: Matrix_H;

      MA : Matrix_N;

      d6:Integer;
      cell :Integer;
      a6: Integer;
   begin
      Put_Line("Task 6 started");

      accept SetMRd(MR :in Matrix_N; d : in Integer) do
         MR6:=MR;
         d6:=d;
      end SetMRd;

      accept SetMTZMO(MT: in Matrix_H; Z: in Vector_H; MO : in Matrix_H) do
         MT_H := MT;
         Z_H:=Z;
         MO_H:=MO;
      end SetMTZMO;

      --compute min
      a6 := Z_H(1);
      for i in 2..H loop
         if Z_H(i)<a6 then
            a6 := Z_H(i);
         end if;
      end loop;

      --send min to T5
      accept GetMin(a: out Integer) do
         a := a6;
      end GetMin;

      --recive min from T5
      accept SetMin(a: in Integer) do
         a6 := a;
      end SetMin;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MT_H(i)(k)*MR6(k)(j);
            end loop;
            MA(i+5*H)(j) := d6*cell + a6*MO_H(i)(j);
         end loop;
      end loop;

      Task5.GetMA(MA(3*H+1..5*H));
      Task3.GetMA(MA(1..3*H));

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

