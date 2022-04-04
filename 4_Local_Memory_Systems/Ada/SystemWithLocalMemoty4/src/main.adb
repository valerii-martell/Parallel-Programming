with Ada.Text_IO, Ada.Integer_Text_IO, Ada.Calendar;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Calendar;
------------------------Main program------------------------------
--Programming for parallel computer systems
--Course work part #2. System with local memory. Ada. Rendezvous
--Valerii Martell
--NTUU "KPI"
--FICT IO - 41
--05.05.2017
--Task: A=B*(MO*MC) + max(Z)*R
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
      entry SetRMO(R: in Vector_H; MO: in Matrix_H);
      entry SetZ(Z: in Vector_H);
      entry SetMC(MC: in Matrix_N);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
      entry GetA(A: out Vector_H);
   end Task1;

   task Task2 is
      entry SetB(B: in Vector_N);
      entry SetRMO(R: in Vector_2H; MO: in Matrix_2H);
      entry SetZ(Z: in Vector_H);
      entry SetMC(MC: in Matrix_N);
      entry GetA(A: out Vector_2H);
   end Task2;

   task Task3 is
      entry SetB(B: in Vector_N);
      entry SetZ(Z: in Vector_H);
      entry SetMC(MC: in Matrix_N);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
      entry GetA(A: out Vector_3H);
   end Task3;

   task Task4 is
      entry SetB(B: in Vector_N);
      entry SetRMO(R: in Vector_H; MO: in Matrix_H);
      entry SetZ(Z: in Vector_4H);
      entry SetMC(MC: in Matrix_N);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
      entry GetA(A: out Vector_H);
   end Task4;

   task Task5 is
      entry SetB(B: in Vector_N);
      entry SetRMO(R: in Vector_2H; MO: in Matrix_2H);
      entry SetZ(Z: in Vector_5H);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
      entry GetA(A: out Vector_2H);
   end Task5;

   task Task6 is
      entry SetB(B: in Vector_N);
      entry SetRMO(R: in Vector_3H; MO: in Matrix_3H);
      entry SetMC(MC: in Matrix_N);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
   end Task6;

   task body Task1 is
      MC1: Matrix_N;
      B : Vector_N;
      A_H : Vector_H;

      R_H : Vector_H;
      MO_H: Matrix_H;

      Z_H: Vector_H;

      MOMC : Matrix_N;

      cell :Integer;
      a1: Integer;
   begin
      Put_Line("Task 1 started");

      --input data
      VectorInput(B);

      --send data to T2
      Task2.SetB(B(1..N));
      Task4.SetB(B(1..N));

      accept SetRMO(R: in Vector_H; MO: in Matrix_H) do
         R_H:= R;
         MO_H := MO;
      end SetRMO;

      accept SetZ(Z: in Vector_H) do
         Z_H:= Z;
      end SetZ;

      accept SetMC(MC: in Matrix_N) do
         MC1:= MC;
      end SetMC;

      --compute max
      a1 := Z_H(1);
      for i in 2..H loop
         if Z_H(i)>a1 then
            a1 := Z_H(i);
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
               cell := cell + MO_H(i)(k)*MC1(k)(j);
            end loop;
            MOMC(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + B(l)*MOMC(i)(l);
         end loop;
         A_H(i) := cell + a1*R_H(i);
      end loop;

      accept GetA(A: out Vector_H) do
         A := A_H;
      end GetA;

      Put_Line("Task 1 finished");
   end Task1;

   task body Task2 is
      MC2: Matrix_N;
      B2 : Vector_N;
      A_2H : Vector_2H;


      R_2H : Vector_2H;
      MO_2H: Matrix_2H;

      Z_H: Vector_H;

      MOMC : Matrix_N;

      cell :Integer;
      a1,a2,a3,a5: Integer;
   begin
      Put_Line("Task 2 started");

      accept SetB(B: in Vector_N) do
         B2:= B;
      end SetB;

      Task3.SetB(B2(1..N));
      Task5.SetB(B2(1..N));

      accept SetRMO(R: in Vector_2H; MO: in Matrix_2H) do
         R_2H:= R;
         MO_2H := MO;
      end SetRMO;

      Task1.SetRMO(R_2H(1..H), MO_2H(1..H));

      accept SetZ(Z: in Vector_H) do
         Z_H:= Z;
      end SetZ;

      accept SetMC(MC: in Matrix_N) do
         MC2:= MC;
      end SetMC;

      Task1.SetMC(MC2(1..N));
      Task3.SetMC(MC2(1..N));

      --compute max
      a2 := Z_H(1);
      for i in 2..H loop
         if Z_H(i)>a2 then
            a2 := Z_H(i);
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

      Task5.GetMax(a5);
      if a5>a2 then
         a2:=a5;
      end if;

      Task5.SetMax(a2);
      Task1.SetMax(a2);
      Task3.SetMax(a2);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_2H(i+H)(k)*MC2(k)(j);
            end loop;
            MOMC(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + B2(l)*MOMC(i)(l);
         end loop;
         A_2H(i+H) := cell + a2*R_2H(i+H);
      end loop;

      Task1.GetA(A_2H(1..H));

      accept GetA(A: out Vector_2H) do
         A := A_2H;
      end GetA;

      Put_Line("Task 2 finished");
   end Task2;

   task body Task3 is
      MC3: Matrix_N;
      B3 : Vector_N;
      A_3H : Vector_3H;


      R : Vector_N;
      MO: Matrix_N;

      Z_H: Vector_H;

      MOMC : Matrix_N;

      cell :Integer;
      a3: Integer;
   begin
      Put_Line("Task 3 started");

      --input data
      MatrixInput(MO);
      VectorInput(R);
      --R(2):=5;

      accept SetB(B: in Vector_N) do
         B3:= B;
      end SetB;

      Task6.SetB(B3(1..N));

      Task2.SetRMO(R(1..2*H), MO(1..2*H));
      Task6.SetRMO(R(3*H+1..6*H), MO(3*H+1..6*H));

      accept SetZ(Z: in Vector_H) do
         Z_H:= Z;
      end SetZ;

      accept SetMC(MC: in Matrix_N) do
         MC3:= MC;
      end SetMC;

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
               cell := cell + MO(i+2*H)(k)*MC3(k)(j);
            end loop;
            MOMC(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + B3(l)*MOMC(i)(l);
         end loop;
         A_3H(i+2*H) := cell + a3*R(i+2*H);
      end loop;

      Task2.GetA(A_3H(1..2*H));

      accept GetA(A: out Vector_3H) do
         A := A_3H;
      end GetA;

      Put_Line("Task 3 finished");
   end Task3;

   task body Task4 is
      MC4: Matrix_N;
      B4 : Vector_N;
      A_H : Vector_H;


      R_H : Vector_H;
      MO_H: Matrix_H;

      Z_4H: Vector_4H;

      MOMC : Matrix_N;

      cell :Integer;
      a4: Integer;
   begin
      Put_Line("Task 4 started");

      accept SetB(B: in Vector_N) do
         B4:= B;
      end SetB;

      accept SetRMO(R: in Vector_H; MO: in Matrix_H) do
         R_H:= R;
         MO_H:=MO;
      end SetRMO;

      accept SetZ(Z: in Vector_4H) do
         Z_4H:= Z;
      end SetZ;

      Task1.SetZ(Z_4H(1..H));

      accept SetMC(MC: in Matrix_N) do
         MC4:= MC;
      end SetMC;

      --compute max
      a4 := Z_4H(3*H+1);
      for i in 3*H+2..4*H loop
         if Z_4H(i)>a4 then
            a4 := Z_4H(i);
         end if;
      end loop;

      --send max to T5
      accept GetMax(a : out Integer) do
         a:=a4;
      end GetMax;

      --recive max from T5
      accept SetMax(a: in Integer) do
         a4 := a;
      end SetMax;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_H(i)(k)*MC4(k)(j);
            end loop;
            MOMC(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + B4(l)*MOMC(i)(l);
         end loop;
         A_H(i) := cell + a4*R_H(i);
      end loop;

      accept GetA(A: out Vector_H) do
         A := A_H;
      end GetA;

      Put_Line("Task 4 finished");

   end Task4;

   task body Task5 is
      MC: Matrix_N;
      B5 : Vector_N;
      A_2H : Vector_2H;

      R_2H : Vector_2H;
      MO_2H: Matrix_2H;

      Z_5H: Vector_5H;

      MOMC : Matrix_N;

      cell :Integer;
      a6, a5, a4: Integer;
   begin
      Put_Line("Task 5 started");

      --input data
      MatrixInput(MC);

      accept SetB(B: in Vector_N) do
         B5:= B;
      end SetB;

      accept SetRMO(R: in Vector_2H; MO: in Matrix_2H) do
         R_2H:= R;
         MO_2H:=MO;
      end SetRMO;

      Task4.SetRMO(R_2H(1..H), MO_2H(1..H));

      accept SetZ(Z: in Vector_5H) do
         Z_5H:= Z;
      end SetZ;

      Task4.SetZ(Z_5H(1..4*H));
      Task2.SetZ(Z_5H(H+1..2*H));

      Task4.SetMC(MC(1..N));
      Task6.SetMC(MC(1..N));
      Task2.SetMC(MC(1..N));

      --compute max
      a5 := Z_5H(4*H+1);
      for i in 4*H+2..5*H loop
         if Z_5H(i)>a5 then
            a5 := Z_5H(i);
         end if;
      end loop;

      Task4.GetMax(a4);
      if a4>a5 then
         a5:=a4;
      end if;

      Task6.GetMax(a6);
      if a6>a5 then
         a5:=a6;
      end if;

      --send max to T2
      accept GetMax(a : out Integer) do
         a:=a5;
      end GetMax;

      --recive max from T2
      accept SetMax(a: in Integer) do
         a5 := a;
      end SetMax;

      Task4.SetMax(a5);
      Task6.SetMax(a5);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_2H(i+H)(k)*MC(k)(j);
            end loop;
            MOMC(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + B5(l)*MOMC(i)(l);
         end loop;
         A_2H(i+H) := cell + a5*R_2H(i+H);
      end loop;

      Task4.GetA(A_2H(1..H));

      accept GetA(A: out Vector_2H) do
         A := A_2H;
      end GetA;

      Put_Line("Task 5 finished");
   end Task5;

   task body Task6 is
      MC6: Matrix_N;
      B6 : Vector_N;
      A : Vector_N;


      R_3H : Vector_3H;
      MO_3H: Matrix_3H;

      Z: Vector_N;

      MOMC : Matrix_N;

      cell :Integer;
      a6: Integer;
   begin
      Put_Line("Task 6 started");

      --input data
      VectorInput(Z);
      --Z(5):=5;

      accept SetB(B: in Vector_N) do
         B6:= B;
      end SetB;

      accept SetRMO(R: in Vector_3H; MO: in Matrix_3H) do
         R_3H:= R;
         MO_3H:=MO;
      end SetRMO;

      Task5.SetRMO(R_3H(1..2*H), MO_3H(1..2*H));

      Task5.SetZ(Z(1..5*H));
      Task3.SetZ(Z(2*H+1..3*H));

      accept SetMC(MC: in Matrix_N) do
         MC6:= MC;
      end SetMC;

      --compute max
      a6 := Z(5*H+1);
      for i in 5*H+2..6*H loop
         if Z(i)>a6 then
            a6 := Z(i);
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
               cell := cell + MO_3H(i+2*H)(k)*MC6(k)(j);
            end loop;
            MOMC(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + B6(l)*MOMC(i)(l);
         end loop;
         A(i+5*H) := cell + a6*R_3H(i+2*H);
      end loop;

      Task5.GetA(A(3*H+1..5*H));
      Task3.GetA(A(1..3*H));

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
   end Task6;

begin
   StartTime := Clock;
end Main;
