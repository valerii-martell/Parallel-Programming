with Ada.Text_IO, Ada.Integer_Text_IO, Ada.Calendar;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Calendar;
------------------------Main program------------------------------
--Programming for parallel computer systems
--Course work part #2. System with local memory. Ada. Rendezvous
--Valerii Martell
--NTUU "KPI"
--FICT IO - 41
--05.05.2017
--Task: A=B*(MO*MK)*d + max(Z)*R
------------------------------------------------------------------
procedure Main is
   N: Integer := 600;
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
      entry SetData(MK : in Matrix_N; B : in Vector_N; d : in Integer; MO : in Matrix_H);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
      entry GetA(A: out Vector_H);
   end Task1;

   task Task2 is
      entry SetZR(Z: in Vector_5H; R : in Vector_5H);
      entry SetMKBd(MK: in Matrix_N; B : in Vector_N; d : in Integer);
      entry GetA(A: out Vector_3H);
   end Task2;

   task Task3 is
      entry SetData(MK : in Matrix_N; B : in Vector_N; d : in Integer; MO : in Matrix_H; Z : in Vector_H; R : in Vector_H);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
      entry GetA(A: out Vector_H);
   end Task3;

   task Task4 is
      entry SetBd(B: in Vector_N; d : in Integer);
      entry SetMOZR(MO : in Matrix_3H; Z: in Vector_3H; R : in Vector_3H);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
      entry GetA(A: out Vector_5H);
   end Task4;

   task Task5 is
      entry SetData(MK : in Matrix_N; B : in Vector_N; d : in Integer; MO : in Matrix_H; Z : in Vector_H; R : in Vector_H);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
      entry GetA(A: out Vector_H);
   end Task5;

   task Task6 is
      entry SetData(MK : in Matrix_N; MO : in Matrix_H; Z : in Vector_H; R : in Vector_H);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
   end Task6;

   task body Task1 is
      B1 : Vector_N;
      d1 : Integer;
      MK1 : Matrix_N;
      MO_H : Matrix_H;
      Z : Vector_N;
      R : Vector_N;
      a1 : Integer;
      A_H : Vector_H;
      MOMK : Matrix_N;
      cell :Integer;
   begin
      Put_Line("Task 1 started");

      --input data
      VectorInput(Z);
      VectorInput(R);
      --Z(5):=10;
      --R(6):=10;

      --send data to T2
      Task2.SetZR(Z(H+1..6*H), R(H+1..6*H));

      accept SetData(MK : in Matrix_N; B : in Vector_N; d : in Integer; MO : in Matrix_H) do
         MK1:=MK;
         B1:=B;
         d1:=d;
         MO_H:=MO;
      end SetData;

      --compute max
      a1 := Z(1);
      for i in 2..H loop
         if Z(i)>a1 then
            a1 := Z(i);
         end if;
      end loop;

      --send max to T2
      accept GetMax(a : out Integer) do
         a:=a1;
      end GetMax;

      --recive max from T2
      accept SetMax(a: in Integer) do
         a1 := a;
      end SetMax;

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
            cell := cell + B1(l)*MOMK(i)(l);
         end loop;
         A_H(i) := d1*cell + a1*R(i);
      end loop;

      accept GetA(A: out Vector_H) do
         A := A_H;
      end GetA;

      Put_Line("Task 1 finished");
   end Task1;

   task body Task2 is
      B2 : Vector_N;
      d2 : Integer;
      MK2 : Matrix_N;
      MO : Matrix_N;
      Z_5H : Vector_5H;
      R_5H : Vector_5H;
      a1, a3, a4, a2 : Integer;
      A_3H : Vector_3H;
      MOMK : Matrix_N;
      cell :Integer;
   begin
      Put_Line("Task 2 started");

      MatrixInput(MO);

      accept SetZR(Z: in Vector_5H; R : in Vector_5H) do
         Z_5H:= Z;
         R_5H:=R;
      end SetZR;

      Task4.SetMOZR(MO(3*H+1..6*H), Z_5H(2*H+1..5*H), R_5H(2*H+1..5*H));

      accept SetMKBd(MK: in Matrix_N; B : in Vector_N; d : in Integer) do
         MK2:= MK;
         B2:=B;
         d2:=d;
      end SetMKBd;

      Task1.SetData(MK2(1..N), B2(1..N), d2, MO(1..H));
      Task3.SetData(MK2(1..N), B2(1..N), d2, MO(2*H+1..3*H), Z_5H(H+1..2*H), R_5H(H+1..2*H));

      --compute max
      a2 := Z_5H(1);
      for i in 2..H loop
         if Z_5H(i)>a2 then
            a2 := Z_5H(i);
         end if;
      end loop;

      Task1.GetMax(a1);
      if a1>a2 then
         a2:=a1;
      end if;

      Task3.GetMax(a3);
      if a3>a2 then
         a2:=a3;
      end if;

      Task4.GetMax(a4);
      if a4>a2 then
         a2:=a4;
      end if;

      Task4.SetMax(a2);
      Task1.SetMax(a2);
      Task3.SetMax(a2);

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
            cell := cell + B2(l)*MOMK(i)(l);
         end loop;
         A_3H(i+H) := d2*cell + a2*R_5H(i);
      end loop;

      Task1.GetA(A_3H(1..H));
      Task3.GetA(A_3H(2*H+1..3*H));

      accept GetA(A: out Vector_3H) do
         A := A_3H;
      end GetA;

      Put_Line("Task 2 finished");
   end Task2;

   task body Task3 is
      B3 : Vector_N;
      d3 : Integer;
      MK3 : Matrix_N;
      MO_H : Matrix_H;
      Z_H : Vector_H;
      R_H : Vector_H;
      a3 : Integer;
      A_H : Vector_H;
      MOMK : Matrix_N;
      cell :Integer;
   begin
      Put_Line("Task 3 started");

      accept SetData(MK : in Matrix_N; B : in Vector_N; d : in Integer; MO : in Matrix_H; Z : in Vector_H; R : in Vector_H) do
         MK3:=MK;
         B3:=B;
         d3:=d;
         MO_H:=MO;
         Z_H:=Z;
         R_H:=R;
      end SetData;

      --compute max
      a3 := Z_H(1);
      for i in 2..H loop
         if Z_H(i)>a3 then
            a3 := Z_H(i);
         end if;
      end loop;

      --send max to T2
      accept GetMax(a : out Integer) do
         a:=a3;
      end GetMax;

      --recive max from T2
      accept SetMax(a: in Integer) do
         a3 := a;
      end SetMax;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_H(i)(k)*MK3(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + B3(l)*MOMK(i)(l);
         end loop;
         A_H(i) := d3*cell + a3*R_H(i);
      end loop;

      accept GetA(A: out Vector_H) do
         A := A_H;
      end GetA;

      Put_Line("Task 3 finished");
   end Task3;

   task body Task4 is
      B4 : Vector_N;
      d4 : Integer;
      MK : Matrix_N;
      MO_3H : Matrix_3H;
      Z_3H : Vector_3H;
      R_3H : Vector_3H;
      a5, a6, a4 : Integer;
      A_5H : Vector_5H;
      MOMK : Matrix_N;
      cell :Integer;
   begin
      Put_Line("Task 4 started");

      MatrixInput(MK);

      accept SetBd(B: in Vector_N; d : in Integer) do
         B4:= B;
         d4:=d;
      end SetBd;

      accept SetMOZR(MO : in Matrix_3H; Z: in Vector_3H; R : in Vector_3H) do
         MO_3H:=MO;
         Z_3H:=Z;
         R_3H:=R;
      end SetMOZR;

      Task2.SetMKBd(MK(1..N), B4(1..N), d4);
      Task5.SetData(MK(1..N), B4(1..N), d4, MO_3H(H+1..2*H), Z_3H(H+1..2*H), R_3H(H+1..2*H));
      Task6.SetData(MK(1..N), MO_3H(2*H+1..3*H), Z_3H(2*H+1..3*H), R_3H(2*H+1..3*H));

      --compute max
      a4 := Z_3H(1);
      for i in 2..H loop
         if Z_3H(i)>a4 then
            a4 := Z_3H(i);
         end if;
      end loop;

      Task5.GetMax(a5);
      if a5>a4 then
         a4:=a5;
      end if;

      Task6.GetMax(a6);
      if a6>a4 then
         a4:=a6;
      end if;

      --send max to T2
      accept GetMax(a : out Integer) do
         a:=a4;
      end GetMax;

      --recive max from T2
      accept SetMax(a: in Integer) do
         a4 := a;
      end SetMax;

      Task5.SetMax(a4);
      Task6.SetMax(a4);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_3H(i)(k)*MK(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + B4(l)*MOMK(i)(l);
         end loop;
         A_5H(i+3*H) := d4*cell + a4*R_3H(i);
      end loop;

      Task5.GetA(A_5H(4*H+1..5*H));
      Task2.GetA(A_5H(1..3*H));

      accept GetA(A: out Vector_5H) do
         A := A_5H;
      end GetA;

      Put_Line("Task 4 finished");

   end Task4;

   task body Task5 is
      B5 : Vector_N;
      d5 : Integer;
      MK5 : Matrix_N;
      MO_H : Matrix_H;
      Z_H : Vector_H;
      R_H : Vector_H;
      a5 : Integer;
      A_H : Vector_H;
      MOMK : Matrix_N;
      cell :Integer;
   begin
      Put_Line("Task 5 started");

      accept SetData(MK : in Matrix_N; B : in Vector_N; d : in Integer; MO : in Matrix_H; Z : in Vector_H; R : in Vector_H) do
         MK5:=MK;
         B5:=B;
         d5:=d;
         MO_H:=MO;
         Z_H:=Z;
         R_H:=R;
      end SetData;

      --compute max
      a5 := Z_H(1);
      for i in 2..H loop
         if Z_H(i)>a5 then
            a5 := Z_H(i);
         end if;
      end loop;

      --send max to T4
      accept GetMax(a : out Integer) do
         a:=a5;
      end GetMax;

      --recive max from T4
      accept SetMax(a: in Integer) do
         a5 := a;
      end SetMax;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_H(i)(k)*MK5(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + B5(l)*MOMK(i)(l);
         end loop;
         A_H(i) := d5*cell + a5*R_H(i);
      end loop;

      accept GetA(A: out Vector_H) do
         A := A_H;
      end GetA;

      Put_Line("Task 5 finished");
   end Task5;

   task body Task6 is
      B : Vector_N;
      d : Integer;
      MK6 : Matrix_N;
      MO_H : Matrix_H;
      Z_H : Vector_H;
      R_H : Vector_H;
      a6 : Integer;
      A : Vector_N;
      MOMK : Matrix_N;
      cell :Integer;
   begin
      Put_Line("Task 6 started");

      --input data
      VectorInput(B);
      d:=1;

      Task4.SetBd(B(1..N), d);

      accept SetData(MK : in Matrix_N; MO : in Matrix_H; Z : in Vector_H; R : in Vector_H) do
         MK6:=MK;
         MO_H:=MO;
         Z_H:=Z;
         R_H:=R;
      end SetData;

      --compute max
      a6 := Z_H(1);
      for i in 2..H loop
         if Z_H(i)>a6 then
            a6 := Z_H(i);
         end if;
      end loop;

      --send max to T4
      accept GetMax(a : out Integer) do
         a:=a6;
      end GetMax;

      --recive max from T4
      accept SetMax(a: in Integer) do
         a6 := a;
      end SetMax;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_H(i)(k)*MK6(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + B(l)*MOMK(i)(l);
         end loop;
         A(i+5*H) := d*cell + a6*R_H(i);
      end loop;

      Task4.GetA(A(1..5*H));

      --show results
      New_Line;
      Put("A = ");
      New_Line;
      VectorOutput(A);
      New_Line;

      Put_Line("Task 6 finished");

      FinishTime := Clock;
      DiffTime := FinishTime - StartTime;

      Put("Time : ");
      Put(Integer(DiffTime), 1);
      Put_Line("");

      Get(a6);
   end Task6;

begin
   StartTime := Clock;
end Main;

