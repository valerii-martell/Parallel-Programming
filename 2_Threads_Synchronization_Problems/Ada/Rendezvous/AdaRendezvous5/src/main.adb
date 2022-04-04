with Ada.Text_IO, Ada.Integer_Text_IO;
use Ada.Text_IO, Ada.Integer_Text_IO;
----------------Main program---------------
--Programming for parallel computer systems
--Laboratory work #7. Ada. Rendezvous
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--01.06.2017
--Task: A = d*B + max(Z)*T*(MO*MK)
-------------------------------------------
procedure Main is
   N: Integer := 8;
   P: Integer := 8;
   H: Integer := N / P;

   type Vector is array(Integer range<>) of Integer;
   subtype Vector_H is Vector(1..H);
   subtype Vector_2H is Vector(1..2*H);
   subtype Vector_3H is Vector(1..3*H);
   subtype Vector_4H is Vector(1..4*H);
   subtype Vector_5H is Vector(1..5*H);
   subtype Vector_6H is Vector(1..6*H);
   subtype Vector_7H is Vector(1..7*H);
   subtype Vector_N is Vector(1..N);

   type Matrix is array(Integer range<>) of Vector_N;
   subtype Matrix_H is Matrix(1..H);
   subtype Matrix_2H is Matrix(1..2*H);
   subtype Matrix_3H is Matrix(1..3*H);
   subtype Matrix_4H is Matrix(1..4*H);
   subtype Matrix_5H is Matrix(1..5*H);
   subtype Matrix_6H is Matrix(1..6*H);
   subtype Matrix_7H is Matrix(1..7*H);
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
      entry SetMK(MK: in Matrix_N);
      entry SetMOTd(MO: in Matrix_H; T: in Vector_N; d : in Integer);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
      entry GetA(A: out Vector_H);
   end Task1;

   task Task2 is
      entry SetBZ(B : in Vector_7H; Z: in Vector_7H);
      entry SetMK(MK: in Matrix_N);
      entry SetMOTd(MO: in Matrix_3H; T: in Vector_N; d : in Integer);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
      entry GetA(A: out Vector_3H);
   end Task2;

   task Task3 is
      entry SetBZ(B : in Vector_H; Z: in Vector_H);
      entry SetMK(MK: in Matrix_N);
      entry SetMOTd(MO: in Matrix_H; T: in Vector_N; d : in Integer);
      entry GetMax(a : out Integer);
      entry SetMax(a : in Integer);
      entry GetA(A: out Vector_H);
   end Task3;

   task Task4 is
      entry SetMK(MK: in Matrix_N);
      entry SetBZ(B : in Vector_5H; Z: in Vector_5H);
      entry SetMOTd(MO: in Matrix_5H; T: in Vector_N; d : in Integer);
      entry GetA(A: out Vector_5H);
   end Task4;

   task Task5 is
      entry SetBZ(B : in Vector_H; Z: in Vector_H);
      entry SetMK(MK: in Matrix_N);
      entry SetMOTd(MO: in Matrix_H; T: in Vector_N; d : in Integer);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
      entry GetA(A: out Vector_H);
   end Task5;

   task Task6 is
      entry SetMOTd(MO: in Matrix_6H; T: in Vector_N; d : in Integer);
      entry SetBZ(B : in Vector_3H; Z: in Vector_3H);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
      entry GetA(A: out Vector_6H);
   end Task6;

   task Task7 is
      entry SetMK(MK: in Matrix_N);
      entry SetMOTd(MO: in Matrix_7H; T: in Vector_N; d : in Integer);
      entry SetBZ(B : in Vector_2H; Z: in Vector_2H);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
      entry GetA(A: out Vector_7H);
   end Task7;

   task Task8 is
      entry SetMK(MK: in Matrix_N);
      entry SetBZ(B : in Vector_H; Z: in Vector_H);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
   end Task8;


   task body Task1 is
      MK1: Matrix_N;
      T1 : Vector_N;
      B:Vector_N;
      MO_H:Matrix_H;
      Z:Vector_N;
      d1:Integer;
      a1:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A_H:Vector_H;
   begin
      Put_Line("Task 1 started");

      --input data
      VectorInput(B);
      B(3):=10;
      VectorInput(Z);
      Z(3):=10;

      --send data to T2
      Task2.SetBZ(B(H+1..N), Z(H+1..N));

      accept SetMK(MK: in Matrix_N) do
         MK1:=MK;
      end SetMK;

      accept SetMOTd(MO: in Matrix_H; T: in Vector_N; d : in Integer) do
         MO_H:=MO;
         T1:=T;
         d1:=d;
      end SetMOTd;

      --compute max
      a1 := Z(1);
      for i in 2..H loop
         if Z(i)>a1 then
            a1 := Z(i);
         end if;
      end loop;

      accept GetMax(a : out Integer) do
         a:=a1;
      end GetMax;

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
            cell := cell + T1(l)*MOMK(i)(l);
         end loop;
         A_H(i) := d1*B(i) + a1*cell;
      end loop;

      accept GetA(A: out Vector_H) do
         A := A_H;
      end GetA;

      Put_Line("Task 1 finished");
   end Task1;

   task body Task2 is
      MK2: Matrix_N;
      T2 : Vector_N;
      B_7H:Vector_7H;
      MO_3H:Matrix_3H;
      Z_7H:Vector_7H;
      d2:Integer;
      a2,a1,a3:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A_3H:Vector_3H;
   begin
      Put_Line("Task 2 started");

      accept SetBZ(B : in Vector_7H; Z: in Vector_7H) do
         B_7H:=B;
         Z_7H:=Z;
      end SetBZ;

      --send data to T3
      Task3.SetBZ(B_7H(H+1..2*H), Z_7H(H+1..2*H));
      --send data to T3
      Task4.SetBZ(B_7H(2*H+1..7*H), Z_7H(2*H+1..7*H));

      accept SetMK(MK: in Matrix_N) do
         MK2:=MK;
      end SetMK;

      Task1.SetMK(MK2(1..N));
      Task3.SetMK(MK2(1..N));

      accept SetMOTd(MO: in Matrix_3H; T: in Vector_N; d : in Integer) do
         MO_3H:=MO;
         T2:=T;
         d2:=d;
      end SetMOTd;

      Task1.SetMOTd(MO_3H(1..H), T2(1..N), d2);
      Task3.SetMOTd(MO_3H(2*H+1..3*H), T2(1..N), d2);

      --compute max
      a2 := Z_7H(1);
      for i in 2..H loop
         if Z_7H(i)>a2 then
            a2 := Z_7H(i);
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

      accept GetMax(a : out Integer) do
         a:=a2;
      end GetMax;

      accept SetMax(a : in Integer) do
         a2:=a;
      end SetMax;

      Task1.SetMax(a2);
      Task3.SetMax(a2);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_3H(i+H)(k)*MK2(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + T2(l)*MOMK(i)(l);
         end loop;
         A_3H(i+H) := d2*B_7H(i) + a2*cell;
      end loop;

      Task1.GetA(A_3H(1..H));
      Task3.GetA(A_3H(2*H+1..3*H));

      accept GetA(A: out Vector_3H) do
         A := A_3H;
      end GetA;

      Put_Line("Task 2 finished");

   end Task2;

   task body Task3 is
      MK3: Matrix_N;
      T3 : Vector_N;
      B_H:Vector_H;
      MO_H:Matrix_H;
      Z_H:Vector_H;
      d3:Integer;
      a3:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A_H:Vector_H;
   begin
      Put_Line("Task 3 started");

      accept SetBZ(B : in Vector_H; Z: in Vector_H) do
         B_H:=B;
         Z_H:=Z;
      end SetBZ;

      accept SetMK(MK: in Matrix_N) do
         MK3:=MK;
      end SetMK;

      accept SetMOTd(MO: in Matrix_H; T: in Vector_N; d : in Integer) do
         MO_H:=MO;
         T3:=T;
         d3:=d;
      end SetMOTd;

      --compute max
      a3 := Z_H(1);
      for i in 2..H loop
         if Z_H(i)>a3 then
            a3 := Z_H(i);
         end if;
      end loop;

      accept GetMax(a : out Integer) do
         a:=a3;
      end GetMax;

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
            cell := cell + T3(l)*MOMK(i)(l);
         end loop;
         A_H(i) := d3*B_H(i) + a3*cell;
      end loop;

      accept GetA(A: out Vector_H) do
         A := A_H;
      end GetA;

      Put_Line("Task 3 finished");
   end Task3;

   task body Task4 is
      MK4: Matrix_N;
      T4 : Vector_N;
      B_5H:Vector_5H;
      MO_5H:Matrix_5H;
      Z_5H:Vector_5H;
      d4:Integer;
      a2,a4,a5,a6:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A_5H:Vector_5H;
   begin
      Put_Line("Task 4 started");

      accept SetMK(MK: in Matrix_N) do
         MK4:=MK;
      end SetMK;

      accept SetBZ(B : in Vector_5H; Z: in Vector_5H) do
         B_5H:=B;
         Z_5H:=Z;
      end SetBZ;

      Task5.SetBZ(B_5H(H+1..2*H), Z_5H(H+1..2*H));
      Task6.SetBZ(B_5H(2*H+1..5*H), Z_5H(2*H+1..5*H));

      Task2.SetMK(MK4(1..N));
      Task5.SetMK(MK4(1..N));

      accept SetMOTd(MO: in Matrix_5H; T: in Vector_N; d : in Integer) do
         MO_5H:=MO;
         T4:=T;
         d4:=d;
      end SetMOTd;

      Task2.SetMOTd(MO_5H(1..3*H), T4(1..N), d4);
      Task5.SetMOTd(MO_5H(4*H+1..5*H), T4(1..N), d4);

      --compute max
      a4 := Z_5H(1);
      for i in 2..H loop
         if Z_5H(i)>a4 then
            a4 := Z_5H(i);
         end if;
      end loop;

      Task5.GetMax(a5);
      if a5>a4 then
         a4:=a5;
      end if;

      Task2.GetMax(a2);
      if a2>a4 then
         a4:=a2;
      end if;

      Task6.GetMax(a6);
      if a6>a4 then
         a4:=a6;
      end if;

      Task6.SetMax(a4);
      Task2.SetMax(a4);
      Task5.SetMax(a4);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_5H(i+3*H)(k)*MK4(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + T4(l)*MOMK(i)(l);
         end loop;
         A_5H(i+3*H) := d4*B_5H(i) + a4*cell;
      end loop;

      Task2.GetA(A_5H(1..3*H));
      Task5.GetA(A_5H(4*H+1..5*H));

      accept GetA(A: out Vector_5H) do
         A := A_5H;
      end GetA;

      Put_Line("Task 4 finished");

   end Task4;

   task body Task5 is
      MK5: Matrix_N;
      T5 : Vector_N;
      B_H:Vector_H;
      MO_H:Matrix_H;
      Z_H:Vector_H;
      d5:Integer;
      a5:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A_H:Vector_H;
   begin
      Put_Line("Task 5 started");

      accept SetBZ(B : in Vector_H; Z: in Vector_H) do
         B_H:=B;
         Z_H:=Z;
      end SetBZ;

      accept SetMK(MK: in Matrix_N) do
         MK5:=MK;
      end SetMK;

      accept SetMOTd(MO: in Matrix_H; T: in Vector_N; d : in Integer) do
         MO_H:=MO;
         T5:=T;
         d5:=d;
      end SetMOTd;

      --compute max
      a5 := Z_H(1);
      for i in 2..H loop
         if Z_H(i)>a5 then
            a5 := Z_H(i);
         end if;
      end loop;

      accept GetMax(a : out Integer) do
         a:=a5;
      end GetMax;

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
            cell := cell + T5(l)*MOMK(i)(l);
         end loop;
         A_H(i) := d5*B_H(i) + a5*cell;
      end loop;

      accept GetA(A: out Vector_H) do
         A := A_H;
      end GetA;

   end Task5;

   task body Task6 is
      MK: Matrix_N;
      T6 : Vector_N;
      B_3H:Vector_3H;
      MO_6H:Matrix_6H;
      Z_3H:Vector_3H;
      d6:Integer;
      a6,a7:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A_6H:Vector_6H;
   begin
      Put_Line("Task 6 started");

      MatrixInput(MK);

      Task7.SetMK(MK(1..N));
      Task4.SetMK(MK(1..N));

      accept SetMOTd(MO: in Matrix_6H; T: in Vector_N; d : in Integer) do
         MO_6H:=MO;
         T6:=T;
         d6:=d;
      end SetMOTd;

      accept SetBZ(B : in Vector_3H; Z: in Vector_3H) do
         B_3H:=B;
         Z_3H:=Z;
      end SetBZ;

      Task7.SetBZ(B_3H(H+1..3*H), Z_3H(H+1..3*H));
      Task4.SetMOTd(MO_6H(1..5*H), T6(1..N), d6);

      --compute max
      a6 := Z_3H(1);
      for i in 2..H loop
         if Z_3H(i)>a6 then
            a6 := Z_3H(i);
         end if;
      end loop;

      Task7.GetMax(a7);
      if a7>a6 then
         a6:=a7;
      end if;

      accept GetMax(a : out Integer) do
         a:=a6;
      end GetMax;

      accept SetMax(a: in Integer) do
         a6 := a;
      end SetMax;

      Task7.SetMax(a6);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_6H(i+5*H)(k)*MK(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + T6(l)*MOMK(i)(l);
         end loop;
         A_6H(i+5*H) := d6*B_3H(i) + a6*cell;
      end loop;

      Task4.GetA(A_6H(1..5*H));

      accept GetA(A: out Vector_6H) do
         A := A_6H;
      end GetA;

      Put_Line("Task 6 finished");

   end Task6;

   task body Task7 is
      MK7: Matrix_N;
      T7 : Vector_N;
      B_2H:Vector_2H;
      MO_7H:Matrix_7H;
      Z_2H:Vector_2H;
      d7:Integer;
      a8,a7:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A_7H:Vector_7H;
   begin
      Put_Line("Task 7 started");

      accept SetMK(MK: in Matrix_N) do
         MK7:= MK;
      end SetMK;

      accept SetMOTd(MO: in Matrix_7H; T: in Vector_N; d : in Integer) do
         MO_7H:=MO;
         T7:=T;
         d7:=d;
      end SetMOTd;


      Task6.SetMOTd(MO_7H(H+1..7*H), T7(1..N), d7);
      Task8.SetMK(MK7(1..N));

      accept SetBZ(B : in Vector_2H; Z: in Vector_2H) do
         B_2H:=B;
         Z_2H:=Z;
      end SetBZ;

      Task8.SetBZ(B_2H(H+1..2*H), Z_2H(H+1..2*H));

      --compute max
      a7 := Z_2H(1);
      for i in 2..H loop
         if Z_2H(i)>a7 then
            a7 := Z_2H(i);
         end if;
      end loop;

      Task8.GetMax(a8);
      if a8>a7 then
         a7:=a8;
      end if;

      accept GetMax(a : out Integer) do
         a:=a7;
      end GetMax;

      accept SetMax(a: in Integer) do
         a7 := a;
      end SetMax;

      Task8.SetMax(a7);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_7H(i+6*H)(k)*MK7(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + T7(l)*MOMK(i)(l);
         end loop;
         A_7H(i+6*H) := d7*B_2H(i) + a7*cell;
      end loop;

      Task6.GetA(A_7H(1..6*H));

      accept GetA(A: out Vector_7H) do
         A := A_7H;
      end GetA;

      Put_Line("Task 7 finished");

   end Task7;

   task body Task8 is
      MK8: Matrix_N;
      T : Vector_N;
      B_H:Vector_H;
      MO:Matrix_N;
      Z_H:Vector_H;
      d:Integer;
      a8:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A:Vector_N;
   begin
      Put_Line("Task 8 started");

      d:=1;
      VectorInput(T);
      MatrixInput(MO);

      Task7.SetMOTd(MO(1..7*H), T(1..N), d);

      accept SetMK(MK: in Matrix_N) do
         MK8:=MK;
      end SetMK;

      accept SetBZ(B : in Vector_H; Z: in Vector_H) do
         B_H:=B;
         Z_H:=Z;
      end SetBZ;

      --compute max
      a8 := Z_H(1);
      for i in 2..H loop
         if Z_H(i)>a8 then
            a8 := Z_H(i);
         end if;
      end loop;

      accept GetMax(a : out Integer) do
         a:=a8;
      end GetMax;

      accept SetMax(a: in Integer) do
         a8 := a;
      end SetMax;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO(i+7*H)(k)*MK8(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + T(l)*MOMK(i)(l);
         end loop;
         A(i+7*H) := d*B_H(i) + a8*cell;
      end loop;

      Task7.GetA(A(1..7*H));

      --show results
      New_Line;
      Put("A = ");
      New_Line;
      VectorOutput(A);
      New_Line;

     Put_Line("Task 8 finished");
   end Task8;

begin
   null;
end Main;
