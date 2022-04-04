with Ada.Text_IO, Ada.Integer_Text_IO, Ada.Calendar;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Calendar;
----------------Main program---------------
--Programming for parallel computer systems
--Course work part #2. System with local memory. Ada. Rendezvous
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--20.04.2017
--Task: MA = max(Z)*(MO*MK) + e*MT
-------------------------------------------
procedure Main is
   N: Integer := 12;
   P: Integer := 4;
   H: Integer := N / P;

   StartTime, FinishTime: Time;
   DiffTime: Duration;

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
      entry SetZ(Z :in Vector_2H);
      entry SetMOMT(MO: in Matrix_H; MT : in Matrix_H);
      entry GetMax(a: out Integer);
      entry SetMax(a: in Integer);
      entry GetMA(MA: out Matrix_2H);
   end Task1;
   task Task2 is
      entry SetMKe(MK: in Matrix_N; e : in Integer);
      entry SetMOMT(MO: in Matrix_2H; MT : in Matrix_2H);
      entry SetZ (Z: in Vector_H);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
      entry GetMA(MA : out Matrix_H);
   end Task2;
   task Task3 is
      entry SetZ(Z :in Vector_H);
      entry SetMKe(MK : in Matrix_N; e : in Integer);
      entry GetMax(a : out Integer);
      entry SetMax(a : in Integer);
      entry GetMA(MA : out Matrix_H);
   end Task3;
   task Task4 is
      entry SetMKe(MK :in Matrix_N; e : in Integer);
      entry SetMOMT(MO :in Matrix_H; MT: in Matrix_H);
   end Task4;

   task body Task1 is

      MK: Matrix_N;

      Z_2H: Vector_2H;

      MO_H: Matrix_H;
      MT_H: Matrix_H;

      MA_2H : Matrix_2H;

      e:Integer;
      cell :Integer;
      a1,a2: Integer;
   begin
      Put_Line("Task 1 started");

      --input data
      MatrixInput(MK);
      e := 1;

      --send fata to T2 and T4
      Task2.SetMKe(MK(1..N), e);
      Task4.SetMKe(MK(1..N), e);

      --pause while T4 get Z_2H and T2 get MO_H, MT_H
      accept SetZ(Z :in Vector_2H) do
         Z_2H:=Z;
      end SetZ;

      --pause while T2 get MO_H and MT_H
      accept SetMOMT(MO: in Matrix_H; MT : in Matrix_H) do
         MO_H := MO;
         MT_H :=MT;
      end SetMOMT;

      --send Z_H to T2
      Task2.SetZ(Z_2H(H+1..2*H));

      --compute max
      a1 := Z_2H(1);
      for i in 2..H loop
         if Z_2H(i)>a1 then
            a1 := Z_2H(i);
         end if;
      end loop;

      Task2.GetMax(a2);

      --send max to T4
      if a2>a1 then
         a1:=a2;
      end if;

      accept GetMax(a: out Integer) do
         a := a1;
      end GetMax;

      --get max from T4
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
               cell := cell + MO_H(i)(k)*MK(k)(j);
            end loop;
            MA_2H(i)(j) := a1*cell + e*MT_H(i)(j);
         end loop;
      end loop;

      Task2.GetMA(MA_2H(H+1..2*H));

      accept GetMA(MA: out Matrix_2H) do
         MA := MA_2H;
      end GetMA;

      Put_Line("Task 1 finished");
   end Task1;

   task body Task2 is
      MK2: Matrix_N;

      Z_H: Vector_H;

      MO_2H: Matrix_2H;
      MT_2H: Matrix_2H;

      MA_2H : Matrix_2H;

      e2:Integer;
      cell :Integer;
      a2: Integer;
   begin
      Put_Line("Task 2 started");

      accept SetMKe(MK: in Matrix_N; e : in Integer) do
         MK2:= MK;
         e2 := e;
      end SetMKe;

      accept SetMOMT(MO: in Matrix_2H; MT : in Matrix_2H) do
         MO_2H := MO;
         MT_2H :=MT;
      end SetMOMT;

      Task1.SetMOMT(MO_2H(1..H), MT_2H(1..H));

      accept SetZ (Z: in Vector_H) do
         Z_H := Z;
      end SetZ;

      --compute max
      a2 := Z_H(1);
      for i in 2..H loop
         if Z_H(i)>a2 then
            a2 := Z_H(i);
         end if;
      end loop;

      accept GetMax(a : out Integer) do
         a:=a2;
      end GetMax;

      accept SetMax(a: in Integer) do
         a2 := a;
      end SetMax;

      --compute
      for i in H+1..2*H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_2H(i)(k)*MK2(k)(j);
            end loop;
            MA_2H(i)(j) := a2*cell + e2*MT_2H(i)(j);
         end loop;
      end loop;

      accept GetMA(MA : out Matrix_H) do
         MA:=MA_2H(H+1..2*H);
      end GetMA;
      Put_Line("Task 2 finished");
   end Task2;

   task body Task3 is
      MK3: Matrix_N;

      Z_H: Vector_H;

      MO: Matrix_N;
      MT: Matrix_N;

      MA_H : Matrix_H;

      e3:Integer;
      cell :Integer;
      a3: Integer;
   begin
      Put_Line("Task 3 started");

      --input data
      MatrixInput(MO);
      MatrixInput(MT);

      --send fata to T2 and T4
      Task2.SetMOMT(MO(1..2*H), MT(1..2*H));
      Task4.SetMOMT(MO(3*H+1..N), MT(3*H+1..N));

      --pause while T4 get Z_H
      accept SetZ(Z :in Vector_H) do
         Z_H:=Z;
      end SetZ;
      --pause while T4 get MK and e
      accept SetMKe(MK : in Matrix_N; e : in Integer) do
         MK3:=MK;
         e3:=e;
      end SetMKe;

      --compute max
      a3 := Z_H(1);
      for i in 2..H loop
         if Z_H(i)>a3 then
            a3 := Z_H(i);
         end if;
      end loop;

      --pause while T4 ask about max
      accept GetMax(a : out Integer) do
         a:=a3;
      end GetMax;

      --pause while T4 get max
      accept SetMax(a : in Integer) do
         a3:=a;
      end SetMax;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO(i+2*H)(k)*MK3(k)(j);
            end loop;
            MA_H(i)(j) := a3*cell + e3*MT(i+2*H)(j);
         end loop;
      end loop;

      accept GetMA(MA : out Matrix_H) do
         MA:=MA_H;
      end GetMA;

      Put_Line("Task 3 finished");
   end Task3;

   task body Task4 is
      MK4: Matrix_N;

      Z: Vector_N;

      MO_H: Matrix_H;
      MT_H: Matrix_H;

      MA : Matrix_N;

      e4:Integer;
      cell :Integer;
      a4,a3,a1: Integer;
   begin
      Put_Line("Task 4 started");

      VectorInput(Z);
      --Z(4):=2;

      accept SetMKe(MK :in Matrix_N; e : in Integer) do
         MK4 := MK;
         e4 := e;
      end SetMKe;

      accept SetMOMT(MO :in Matrix_H; MT: in Matrix_H) do
         MO_H:=MO;
         MT_H:=MT;
      end SetMOMT;

      Task1.SetZ(Z(1..2*H));
      Task3.SetZ(Z(2*H+1..3*H));
      Task3.SetMKe(MK4(1..N), e4);

      --compute max
      a4 := Z(3*H+1);
      for i in 3*H+2..N loop
         if Z(i)>a4 then
            a4 := Z(i);
         end if;
      end loop;

      Task3.GetMax(a3);
      if a3>a4 then
         a4:=a3;
      end if;

      Task1.GetMax(a1);
      if a1 > a4 then
         a4 := a1;
      end if;

      Task3.SetMax(a4);

      Task1.SetMax(a4);

      --compute
      for i in 3*H+1..N loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_H(i-(3*H))(k)*MK4(k)(j);
            end loop;
            MA(i)(j) := a4*cell + e4*MT_H(i-(3*H))(j);
         end loop;
      end loop;

      Task3.GetMA(MA(2*H+1..3*H));
      Task1.GetMA(MA(1..2*H));

      --show results
      New_Line;
      Put("MA = ");
      New_Line;
      MatrixOutput(MA);
      New_Line;

      Put_Line("Task 4 finished");

      FinishTime := Clock;
      DiffTime := FinishTime - StartTime;

      Put("Time : ");
      Put(Integer(DiffTime), 1);
      Put_Line("");
   end Task4;

begin
   StartTime := Clock;
end Main;
