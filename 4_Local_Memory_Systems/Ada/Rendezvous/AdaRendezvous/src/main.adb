with Ada.Text_IO, Ada.Integer_Text_IO;
use Ada.Text_IO, Ada.Integer_Text_IO;
----------------Main program---------------
--Programming for parallel computer systems
--Laboratory work #7. Ada. Rendezvous
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--22.05.2017
--Task: A = max(Z)*B + d*T*(MO*MK)
-------------------------------------------
procedure Main is
   N: Integer := 18;
   P: Integer := 9;
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
      entry SetTBMOZd(T: in Vector_N; B: in Vector_H; MO: in Matrix_H; Z: in Vector_H; d : in Integer);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
      entry GetA(A: out Vector_H);
   end Task1;

   task Task2 is
      entry SetMK(MK: in Matrix_N);
      entry SetTBMOZd(T: in Vector_N; B: in Vector_2H; MO: in Matrix_2H; Z: in Vector_2H; d : in Integer);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
      entry GetA(A: out Vector_2H);
   end Task2;

   task Task3 is
      entry SetMK(MK: in Matrix_N);
      entry SetZd(Z: in Vector_3H; d : in Integer);
      entry GetMax(a : out Integer);
      entry SetMax(a : in Integer);
      entry GetA(A: out Vector_3H);
   end Task3;

   task Task4 is
      entry SetMK(MK: in Matrix_N);
      entry SetTBMOZd(T :in Vector_N; B : in Vector_H; MO: in Matrix_H; Z: in Vector_H; d : in Integer);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
      entry GetA(A: out Vector_H);
   end Task4;

   task Task5 is
      entry SetMK(MK: in Matrix_N);
      entry SetTBMOZd(T :in Vector_N; B : in Vector_2H; MO: in Matrix_2H; Z: in Vector_2H; d : in Integer);
      entry GetA(A: out Vector_2H);
   end Task5;

   task Task6 is
      entry SetZd(Z: in Vector_6H; d : in Integer);
      entry SetTBMOMK(T :in Vector_N; B : in Vector_6H; MO: in Matrix_6H; MK: in Matrix_N);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
      entry GetA(A: out Vector_6H);
   end Task6;

   task Task7 is
      entry SetMK(MK: in Matrix_N);
      entry SetTBMOZd(T :in Vector_N; B : in Vector_H; MO: in Matrix_H; Z: in Vector_H; d : in Integer);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
      entry GetA(A: out Vector_H);
   end Task7;

   task Task8 is
      entry SetMK(MK: in Matrix_N);
      entry SetTBMOZd(T :in Vector_N; B : in Vector_2H; MO: in Matrix_2H; Z: in Vector_2H; d : in Integer);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
      entry GetA(A: out Vector_2H);
   end Task8;

   task Task9 is
      entry SetTBMOMK(T :in Vector_N; B : in Vector_3H; MO: in Matrix_3H; MK: in Matrix_N);
      entry GetMax(a : out Integer);
      entry SetMax(a: in Integer);
   end Task9;


   task body Task1 is
      MK: Matrix_N;
      T1 : Vector_N;
      B_H:Vector_H;
      MO_H:Matrix_H;
      Z_H:Vector_H;
      d1:Integer;
      a1:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A_H:Vector_H;
   begin
      Put_Line("Task 1 started");

      --input data
      MatrixInput(MK);

      --send data to T2
      Task2.SetMK(MK(1..N));
      Task4.SetMK(MK(1..N));

      accept SetTBMOZd(T: in Vector_N; B: in Vector_H; MO: in Matrix_H; Z: in Vector_H; d : in Integer) do
         T1:=T;
         B_H:=B;
         MO_H:=MO;
         Z_H:=Z;
         d1:=d;
      end SetTBMOZd;

      --compute max
      a1 := Z_H(1);
      for i in 2..H loop
         if Z_H(i)>a1 then
            a1 := Z_H(i);
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
               cell := cell + MO_H(i)(k)*MK(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + T1(l)*MOMK(i)(l);
         end loop;
         A_H(i) := d1*cell + a1*B_H(i);
      end loop;

      accept GetA(A: out Vector_H) do
         A := A_H;
      end GetA;

      Put_Line("Task 1 finished");
   end Task1;

   task body Task2 is
      MK2: Matrix_N;
      T2 : Vector_N;
      B_2H:Vector_2H;
      MO_2H:Matrix_2H;
      Z_2H:Vector_2H;
      d2:Integer;
      a1,a2,a3:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A_2H:Vector_2H;
   begin
      Put_Line("Task 2 started");

      accept SetMK(MK: in Matrix_N) do
         MK2:= MK;
      end SetMK;

      Task3.SetMK(MK2(1..N));
      Task5.SetMK(MK2(1..N));

      accept SetTBMOZd(T: in Vector_N; B: in Vector_2H; MO: in Matrix_2H; Z: in Vector_2H; d : in Integer) do
         T2:=T;
         B_2H:=B;
         MO_2H:=MO;
         Z_2H:=Z;
         d2:=d;
      end SetTBMOZd;

      Task1.SetTBMOZd(T2(1..N), B_2H(1..H), MO_2H(1..H), Z_2H(1..H), d2);

      --compute max
      a2 := Z_2H(H+1);
      for i in H+2..2*H loop
         if Z_2H(i)>a2 then
            a2 := Z_2H(i);
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
               cell := cell + MO_2H(i+H)(k)*MK2(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + T2(l)*MOMK(i)(l);
         end loop;
         A_2H(i+H) := d2*cell + a2*B_2H(i+H);
      end loop;

      Task1.GetA(A_2H(1..H));

      accept GetA(A: out Vector_2H) do
         A := A_2H;
      end GetA;

      Put_Line("Task 2 finished");

   end Task2;

   task body Task3 is
      MK3: Matrix_N;
      T : Vector_N;
      B:Vector_N;
      MO:Matrix_N;
      Z_3H:Vector_3H;
      d3:Integer;
      a3:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A_3H:Vector_3H;
   begin
      Put_Line("Task 3 started");

      --input data
      MatrixInput(MO);
      VectorInput(B);
      VectorInput(T);

      accept SetMK(MK: in Matrix_N) do
         MK3:= MK;
      end SetMK;

      Task6.SetTBMOMK(T(1..N), B(3*H+1..N), MO(3*H+1..N), MK3(1..N));

      accept SetZd(Z: in Vector_3H; d : in Integer) do
         Z_3H := Z;
         d3 := d;
      end SetZd;

      Task2.SetTBMOZd(T(1..N), B(1..2*H), MO(1..2*H), Z_3H(1..2*H), d3);

      --compute max
      a3 := Z_3H(2*H+1);
      for i in 2*H+2..3*H loop
         if Z_3H(i)>a3 then
            a3 := Z_3H(i);
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
               cell := cell + MO(i+2*H)(k)*MK3(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + T(l)*MOMK(i)(l);
         end loop;
         A_3H(i+2*H) := d3*cell + a3*B(i+2*H);
      end loop;

      Task2.GetA(A_3H(1..2*H));

      accept GetA(A: out Vector_3H) do
         A := A_3H;
      end GetA;

      Put_Line("Task 3 finished");
   end Task3;

   task body Task4 is
      MK4: Matrix_N;
      T4 : Vector_N;
      B_H:Vector_H;
      MO_H:Matrix_H;
      Z_H:Vector_H;
      d4:Integer;
      a4:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A_H:Vector_H;
   begin
      Put_Line("Task 4 started");

      accept SetMK(MK: in Matrix_N) do
         MK4:= MK;
      end SetMK;

      Task7.SetMK(MK4(1..N));

      accept SetTBMOZd(T :in Vector_N; B : in Vector_H; MO: in Matrix_H; Z: in Vector_H; d : in Integer) do
         T4:=T;
         B_H:=B;
         MO_H:=MO;
         Z_H:=Z;
         d4:=d;
      end SetTBMOZd;

      --compute max
      a4 := Z_H(1);
      for i in 2..H loop
         if Z_H(i)>a4 then
            a4 := Z_H(i);
         end if;
      end loop;

      accept GetMax(a : out Integer) do
         a:=a4;
      end GetMax;

      accept SetMax(a: in Integer) do
         a4 := a;
      end SetMax;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_H(i)(k)*MK4(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + T4(l)*MOMK(i)(l);
         end loop;
         A_H(i) := d4*cell + a4*B_H(i);
      end loop;

      accept GetA(A: out Vector_H) do
         A := A_H;
      end GetA;

      Put_Line("Task 4 finished");

   end Task4;

   task body Task5 is
      MK5: Matrix_N;
      T5 : Vector_N;
      B_2H:Vector_2H;
      MO_2H:Matrix_2H;
      Z_2H:Vector_2H;
      d5:Integer;
      a2,a4,a6,a8,a5:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A_2H:Vector_2H;
   begin
      Put_Line("Task 5 started");

      accept SetMK(MK: in Matrix_N) do
         MK5:= MK;
      end SetMK;

      Task8.SetMK(MK5(1..N));

      accept SetTBMOZd(T :in Vector_N; B : in Vector_2H; MO: in Matrix_2H; Z: in Vector_2H; d : in Integer) do
         T5:=T;
         B_2H:=B;
         MO_2H:=MO;
         Z_2H:=Z;
         d5:=d;
      end SetTBMOZd;

      Task4.SetTBMOZd(T5(1..N), B_2H(1..H), MO_2H(1..H), Z_2H(1..H), d5);

      --compute max
      a5 := Z_2H(H+1);
      for i in H+2..2*H loop
         if Z_2H(i)>a5 then
            a5 := Z_2H(i);
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

      Task2.GetMax(a2);
      if a2>a5 then
         a5:=a2;
      end if;

      Task8.GetMax(a8);
      if a8>a5 then
         a5:=a8;
      end if;

      Task2.SetMax(a5);
      Task8.SetMax(a5);
      Task4.SetMax(a5);
      Task6.SetMax(a5);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_2H(i+H)(k)*MK5(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + T5(l)*MOMK(i)(l);
         end loop;
         A_2H(i+H) := d5*cell + a5*B_2H(i+H);
      end loop;

      Task4.GetA(A_2H(1..H));

      accept GetA(A: out Vector_2H) do
         A := A_2H;
      end GetA;

   end Task5;

   task body Task6 is
      MK6: Matrix_N;
      T6 : Vector_N;
      B_6H:Vector_6H;
      MO_6H:Matrix_6H;
      Z_6H:Vector_6H;
      d6:Integer;
      a6:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A_6H:Vector_6H;
   begin
      Put_Line("Task 6 started");

      accept SetZd(Z: in Vector_6H; d : in Integer) do
         Z_6H := Z;
         d6 := d;
      end SetZd;

      accept SetTBMOMK(T :in Vector_N; B : in Vector_6H; MO: in Matrix_6H; MK: in Matrix_N) do
         T6:=T;
         B_6H:=B;
         MO_6H:=MO;
         MK6:=MK;
      end SetTBMOMK;

      Task3.SetZd(Z_6H(1..3*H), d6);
      Task9.SetTBMOMK(T6(1..N), B_6H(3*H+1..6*H), MO_6H(3*H+1..6*H), MK6(1..N));
      Task5.SetTBMOZd(T6(1..N), B_6H(1..2*H), MO_6H(1..2*H), Z_6H(3*H+1..5*H), d6);

      --compute max
      a6 := Z_6H(5*H+1);
      for i in 5*H+2..6*H loop
         if Z_6H(i)>a6 then
            a6 := Z_6H(i);
         end if;
      end loop;

      accept GetMax(a : out Integer) do
         a:=a6;
      end GetMax;

      accept SetMax(a: in Integer) do
         a6 := a;
      end SetMax;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_6H(i+2*H)(k)*MK6(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + T6(l)*MOMK(i)(l);
         end loop;
         A_6H(i+5*H) := d6*cell + a6*B_6H(i+2*H);
      end loop;

      Task5.GetA(A_6H(3*H+1..5*H));
      Task3.GetA(A_6H(1..3*H));

      accept GetA(A: out Vector_6H) do
         A := A_6H;
      end GetA;

      Put_Line("Task 6 finished");

   end Task6;

   task body Task7 is
      MK7: Matrix_N;
      T7 : Vector_N;
      B_H:Vector_H;
      MO_H:Matrix_H;
      Z_H:Vector_H;
      d7:Integer;
      a7:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A_H:Vector_H;
   begin
      Put_Line("Task 7 started");

      accept SetMK(MK: in Matrix_N) do
         MK7:= MK;
      end SetMK;

      accept SetTBMOZd(T :in Vector_N; B : in Vector_H; MO: in Matrix_H; Z: in Vector_H; d : in Integer) do
         T7:=T;
         B_H:=B;
         MO_H:=MO;
         Z_H:=Z;
         d7:=d;
      end SetTBMOZd;

      --compute max
      a7 := Z_H(1);
      for i in 2..H loop
         if Z_H(i)>a7 then
            a7 := Z_H(i);
         end if;
      end loop;

      accept GetMax(a : out Integer) do
         a:=a7;
      end GetMax;

      accept SetMax(a: in Integer) do
         a7 := a;
      end SetMax;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_H(i)(k)*MK7(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + T7(l)*MOMK(i)(l);
         end loop;
         A_H(i) := d7*cell + a7*B_H(i);
      end loop;

      accept GetA(A: out Vector_H) do
         A := A_H;
      end GetA;

      Put_Line("Task 7 finished");

   end Task7;

   task body Task8 is
      MK8: Matrix_N;
      T8 : Vector_N;
      B_2H:Vector_2H;
      MO_2H:Matrix_2H;
      Z_2H:Vector_2H;
      d8:Integer;
      a7,a8,a9:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A_2H:Vector_2H;
   begin
      Put_Line("Task 8 started");

      accept SetMK(MK: in Matrix_N) do
         MK8:= MK;
      end SetMK;

      accept SetTBMOZd(T :in Vector_N; B : in Vector_2H; MO: in Matrix_2H; Z: in Vector_2H; d : in Integer) do
         T8:=T;
         B_2H:=B;
         MO_2H:=MO;
         Z_2H:=Z;
         d8:=d;
      end SetTBMOZd;

      Task7.SetTBMOZd(T8(1..N), B_2H(1..H), MO_2H(1..H), Z_2H(1..H), d8);

      --compute max
      a8 := Z_2H(H+1);
      for i in H+2..2*H loop
         if Z_2H(i)>a8 then
            a8 := Z_2H(i);
         end if;
      end loop;

      Task7.GetMax(a7);
      if a7>a8 then
         a8:=a7;
      end if;

      Task9.GetMax(a9);
      if a9>a8 then
         a8:=a9;
      end if;

      accept GetMax(a : out Integer) do
         a:=a8;
      end GetMax;

      accept SetMax(a: in Integer) do
         a8 := a;
      end SetMax;

      Task7.SetMax(a8);
      Task9.SetMax(a8);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_2H(i+H)(k)*MK8(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + T8(l)*MOMK(i)(l);
         end loop;
         A_2H(i+H) := d8*cell + a8*B_2H(i+H);
      end loop;

      Task7.GetA(A_2H(1..H));

      accept GetA(A: out Vector_2H) do
         A := A_2H;
      end GetA;

     Put_Line("Task 8 finished");
   end Task8;

    task body Task9 is
      MK9: Matrix_N;
      T9 : Vector_N;
      B_3H:Vector_3H;
      MO_3H:Matrix_3H;
      Z:Vector_N;
      d:Integer;
      a9:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A:Vector_N;
    begin
      Put_Line("Task 9 started");

      d:=1;
      VectorInput(Z);
      Z(7):=2;

      Task6.SetZd(Z(1..6*H), d);

      accept SetTBMOMK(T :in Vector_N; B : in Vector_3H; MO: in Matrix_3H; MK: in Matrix_N) do
         T9:=T;
         B_3H:=B;
         MO_3H:=MO;
         MK9:=MK;
      end SetTBMOMK;

      Task8.SetTBMOZd(T9(1..N), B_3H(1..2*H), MO_3H(1..2*H), Z(6*H+1..8*H), d);

      --compute max
      a9 := Z(8*H+1);
      for i in 8*H+2..N loop
         if Z(i)>a9 then
            a9 := Z(i);
         end if;
      end loop;

      accept GetMax(a : out Integer) do
         a:=a9;
      end GetMax;

      accept SetMax(a: in Integer) do
         a9 := a;
      end SetMax;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_3H(i+2*H)(k)*MK9(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + T9(l)*MOMK(i)(l);
         end loop;
         A(i+8*H) := d*cell + a9*B_3H(i+2*H);
      end loop;

      Task8.GetA(A(6*H+1..8*H));
      Task6.GetA(A(1..6*H));

      --show results
      New_Line;
      Put("A = ");
      New_Line;
      VectorOutput(A);
      New_Line;

      Put_Line("Task 9 finished");

    end Task9;


begin
   null;
end Main;
