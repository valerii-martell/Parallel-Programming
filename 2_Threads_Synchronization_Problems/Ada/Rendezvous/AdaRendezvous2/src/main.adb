with Ada.Text_IO, Ada.Integer_Text_IO;
use Ada.Text_IO, Ada.Integer_Text_IO;
----------------Main program---------------
--Programming for parallel computer systems
--Laboratory work #7. Ada. Rendezvous
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--01.06.2017
--Task: A = (B*C)*Z +d*T*(MO*MK)
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
      entry SetCTBMK(C: in Vector_H; T : in Vector_N; B: in Vector_H; MK : in Matrix_N);
      entry GetBC(a : out Integer);
      entry SetBC(a: in Integer);
      entry GetA(A: out Vector_H);
   end Task1;

   task Task2 is
      entry SetMOZd(MO: in Matrix_7H; Z: in Vector_7H; d : in Integer);
      entry SetMKB(MK: in Matrix_N; B1: in  Vector_2H; B2: in Vector_H);
      entry SetCT(C1: in Vector_2H; C2 : in Vector_H; T: in Vector_N);
      entry GetBC(a : out Integer);
      entry SetBC(a: in Integer);
      entry GetA(A1: out Vector_2H; A2: out Vector_H);
   end Task2;

   task Task3 is
      entry SetMKB(MK: in Matrix_N; B1: in  Vector_3H; B2: in Vector_4H);
      entry SetMOZd(MO1: in Matrix_2H; MO2: in Matrix_3H; Z1: in Vector_2H; Z2: in Vector_3H; d : in Integer);
      entry SetCT(C: in Vector_5H; T: in Vector_N);
      entry GetA(A1: out Vector_3H; A2: out Vector_4H);
   end Task3;

   task Task4 is
      entry SetCTMOZd(C: in Vector_H; T: in Vector_N; MO: in Matrix_H; Z: in Vector_H; d : in Integer);
      entry GetBC(a : out Integer);
      entry SetBC(a: in Integer);
   end Task4;

   task Task5 is
      entry SetCTBMKMOZd(C: in Vector_H; T: in Vector_N; B: in Vector_H; MK: in Matrix_N; MO: in Matrix_H; Z: in Vector_H; d : in Integer);
      entry GetBC(a : out Integer);
      entry SetBC(a: in Integer);
      entry GetA(A: out Vector_H);
   end Task5;

   task Task6 is
      entry SetMKB(MK : in Matrix_N; B : in Vector_3H);
      entry SetCT(C: in Vector_6H; T: in Vector_N);
      entry SetMOZd(MO : in Matrix_3H; Z : in Vector_3H; d : in Integer);
      entry GetBC(a : out Integer);
      entry SetBC(a: in Integer);
      entry GetA(A: out Vector_3H);
   end Task6;

   task Task7 is
      entry SetMKBMOZd(MK : in Matrix_N; B : in Vector_2H; MO: in Matrix_2H; Z: in Vector_2H; d : in Integer);
      entry GetBC(a : out Integer);
      entry SetBC(a: in Integer);
      entry GetA(A: out Vector_2H);
   end Task7;

   task Task8 is
      entry SetCT(C: in Vector_H; T: in Vector_N);
      entry SetMKBMOZd(MK : in Matrix_N; B : in Vector_H; MO: in Matrix_H; Z: in Vector_H; d : in Integer);
      entry GetBC(a : out Integer);
      entry SetBC(a: in Integer);
      entry GetA(A: out Vector_H);
   end Task8;


   task body Task1 is
      MK1: Matrix_N;
      MO:Matrix_N;
      Z:Vector_N;
      T1 : Vector_N;
      B_H:Vector_H;
      C_H:Vector_H;
      d:Integer;
      a1:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A_H:Vector_H;
   begin
      Put_Line("Task 1 started");

      --input data
      d:=1;
      MatrixInput(MO);
      VectorInput(Z);
      Z(2):=2;

      --send data to T2
      Task2.SetMOZd(MO(H+1..N), Z(H+1..N), d);

      accept SetCTBMK(C: in Vector_H; T : in Vector_N; B: in Vector_H; MK : in Matrix_N) do
         C_H:=C;
         T1:=T;
         B_H:=B;
         MK1:=MK;
      end SetCTBMK;

      --compute 1
      a1:=0;
      for i in 1..H loop
         a1 := a1 + B_H(i)*C_H(i);
      end loop;

      accept GetBC(a : out Integer) do
         a:=a1;
      end GetBC;

      accept SetBC(a: in Integer) do
         a1:=a;
      end SetBC;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO(i)(k)*MK1(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + T1(l)*MOMK(i)(l);
         end loop;
         A_H(i) := a1*Z(i) + d*cell;
      end loop;

      accept GetA(A: out Vector_H) do
         A := A_H;
      end GetA;

      Put_Line("Task 1 finished");
   end Task1;

   task body Task2 is
      MK2: Matrix_N;
      MO_7H:Matrix_7H;
      Z_7H:Vector_7H;
      T2 : Vector_N;
      B_3H:Vector_3H;
      C_3H:Vector_3H;
      d2:Integer;
      a1,a2,a5:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A_3H:Vector_3H;
   begin
      Put_Line("Task 2 started");

      --recive data from T1
      accept SetMOZd(MO: in Matrix_7H; Z: in Vector_7H; d : in Integer) do
         MO_7H:=MO;
         Z_7H:=Z;
         d2:=d;
      end SetMOZd;

      accept SetMKB(MK: in Matrix_N; B1: in  Vector_2H; B2: in Vector_H) do
         MK2:=MK;
         B_3H(1..2*H):=B1;
         B_3H(2*H+1..3*H):=B2;
      end SetMKB;

      Task3.SetMOZd(MO_7H(H+1..3*H), MO_7H(4*H+1..7*H), Z_7H(H+1..3*H), Z_7H(4*H+1..7*H), d2);

      accept SetCT(C1: in Vector_2H; C2 : in Vector_H; T: in Vector_N) do
         C_3H(1..2*H):=C1;
         C_3H(2*H+1..3*H):=C2;
         T2:=T;
      end SetCT;

      Task1.SetCTBMK(C_3H(1..H), T2(1..N), B_3H(1..H), MK2(1..N));
      Task5.SetCTBMKMOZd(C_3H(2*H+1..3*H), T2(1..N), B_3H(2*H+1..3*H), MK2(1..N), MO_7H(3*H+1..4*H), Z_7H(3*H+1..4*H), d2);

      --compute 1
      a2:=0;
      for i in H+1..2*H loop
         a2 := a2 + B_3H(i) * C_3H(i);
      end loop;

      Task1.GetBC(a1);
      Task5.GetBC(a5);
      a2:=a2+a1+a5;

      accept GetBC(a : out Integer) do
         a:=a2;
      end GetBC;

      accept SetBC(a: in Integer) do
         a2:=a;
      end SetBC;

      Task1.SetBC(a2);
      Task5.SetBC(a2);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_7H(i)(k)*MK2(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + T2(l)*MOMK(i)(l);
         end loop;
         A_3H(i+H) := a2*Z_7H(i) + d2*cell;
      end loop;

      Task1.GetA(A_3H(1..H));
      Task5.GetA(A_3H(2*H+1..3*H));

      accept GetA(A1: out Vector_2H; A2: out Vector_H) do
         A1 := A_3H(1..2*H);
         A2 := A_3H(2*H+1..3*H);
      end GetA;

      Put_Line("Task 2 finished");

   end Task2;

   task body Task3 is
      MK3: Matrix_N;
      MO_5H:Matrix_5H;
      Z_5H:Vector_5H;
      T3 : Vector_N;
      B_7H:Vector_7H;
      C_5H:Vector_5H;
      d3:Integer;
      a2,a3,a4,a6:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A_7H:Vector_7H;
   begin
      Put_Line("Task 3 started");

      accept SetMKB(MK: in Matrix_N; B1: in  Vector_3H; B2: in Vector_4H) do
         MK3:=MK;
         B_7H(1..3*H):=B1;
         B_7H(3*H+1..7*H):=B2;
      end SetMKB;

      Task2.SetMKB(MK3(1..N), B_7H(1..2*H), B_7H(3*H+1..4*H));
      Task6.SetMKB(MK3(1..N), B_7H(4*H+1..7*H));

      accept SetMOZd(MO1: in Matrix_2H; MO2: in Matrix_3H; Z1: in Vector_2H; Z2: in Vector_3H; d : in Integer) do
         MO_5H(1..2*H):=MO1;
         MO_5H(2*H+1..5*H):=MO2;
         Z_5H(1..2*H):=Z1;
         Z_5H(2*H+1..5*H):=Z2;
         d3:=d;
      end SetMOZd;

      Task6.SetMOZd(MO_5H(2*H+1..5*H),Z_5H(2*H+1..5*H),d3);

      accept SetCT(C: in Vector_5H; T: in Vector_N) do
         C_5H:=C;
         T3:=T;
      end SetCT;

      Task2.SetCT(C_5H(1..2*H), C_5H(4*H+1..5*H), T3(1..N));
      Task4.SetCTMOZd(C_5H(3*H+1..4*H), T3(1..N), MO_5H(H+1..2*H), Z_5H(H+1..2*H), d3);

      --compute 1
      a3:=0;
      for i in 2*H+1..3*H loop
         a3 := a3 + B_7H(i) * C_5H(i);
      end loop;

      Task4.GetBC(a4);
      Task2.GetBC(a2);
      Task6.GetBC(a6);

      a3:=a3+a2+a4+a6;

      Task4.SetBC(a3);
      Task2.SetBC(a3);
      Task6.SetBC(a3);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_5H(i)(k)*MK3(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + T3(l)*MOMK(i)(l);
         end loop;
         A_7H(i+2*H) := a3*Z_5H(i) + d3*cell;
      end loop;

      Task2.GetA(A_7H(1..2*H), A_7H(3*H+1..4*H));
      Task6.GetA(A_7H(4*H+1..7*H));

      accept GetA(A1: out Vector_3H; A2: out Vector_4H) do
         A1 := A_7H(1..3*H);
         A2:=A_7H(3*H+1..7*H);
      end GetA;

      Put_Line("Task 3 finished");
   end Task3;

   task body Task4 is
      MK: Matrix_N;
      MO_H:Matrix_H;
      Z_H:Vector_H;
      T4 : Vector_N;
      B:Vector_N;
      C_H:Vector_H;
      d4:Integer;
      a4:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A:Vector_N;
   begin
      Put_Line("Task 4 started");

      VectorInput(B);
      MatrixInput(MK);
      --B(2):=2;

      Task3.SetMKB(MK(1..N), B(1..3*H), B(4*H+1..N));

      accept SetCTMOZd(C: in Vector_H; T: in Vector_N; MO: in Matrix_H; Z: in Vector_H; d : in Integer) do
         C_H:=C;
         T4:=T;
         MO_H:=MO;
         Z_H:=Z;
         d4:=d;
      end SetCTMOZd;

      --compute 1
      a4:=0;
      for i in 3*H+1..4*H loop
         a4 := a4 + B(i) * C_H(i-3*H);
      end loop;

      accept GetBC(a : out Integer) do
         a:=a4;
      end GetBC;

      accept SetBC(a: in Integer) do
         a4:=a;
      end SetBC;

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
            cell := cell + T4(l)*MOMK(i)(l);
         end loop;
         A(i+3*H) := a4*Z_H(i) + d4*cell;
      end loop;

      Task3.GetA(A(1..3*H), A(4*H+1..N));

      --show results
      New_Line;
      Put("A = ");
      New_Line;
      VectorOutput(A);
      New_Line;

      Put_Line("Task 4 finished");

   end Task4;

   task body Task5 is
      MK5: Matrix_N;
      MO_H:Matrix_H;
      Z_H:Vector_H;
      T5 : Vector_N;
      B_H:Vector_H;
      C_H:Vector_H;
      d5:Integer;
      a5:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A_H:Vector_H;
   begin
      Put_Line("Task 5 started");

      accept SetCTBMKMOZd(C: in Vector_H; T: in Vector_N; B: in Vector_H; MK: in Matrix_N; MO: in Matrix_H; Z: in Vector_H; d : in Integer) do
         C_H:=C;
         T5:=T;
         B_H:=B;
         MK5:=MK;
         MO_H:=MO;
         Z_H:=Z;
         d5:=d;
     end SetCTBMKMOZd;

      --compute 1
      a5:=0;
      for i in 1..H loop
         a5 := a5 + B_H(i) * C_H(i);
      end loop;

      accept GetBC(a : out Integer) do
         a:=a5;
      end GetBC;

      accept SetBC(a: in Integer) do
         a5:=a;
      end SetBC;

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
         A_H(i) := a5*Z_H(i) + d5*cell;
      end loop;

      accept GetA(A: out Vector_H) do
         A := A_H;
      end GetA;

      Put_Line("Task 5 finished");

   end Task5;

   task body Task6 is
      MK6: Matrix_N;
      MO_3H:Matrix_3H;
      Z_3H:Vector_3H;
      T6 : Vector_N;
      B_3H:Vector_3H;
      C_6H:Vector_6H;
      d6:Integer;
      a7,a6:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A_3H:Vector_3H;
   begin
      Put_Line("Task 6 started");

      accept SetMKB(MK : in Matrix_N; B : in Vector_3H) do
         MK6:=MK;
         B_3H:=B;
      end SetMKB;

      accept SetCT(C: in Vector_6H; T: in Vector_N) do
         C_6H:=C;
         T6:=T;
      end SetCT;

      accept SetMOZd(MO : in Matrix_3H; Z : in Vector_3H; d : in Integer) do
         MO_3H:=MO;
         Z_3H:=Z;
         d6:=d;
      end SetMOZd;

      Task3.SetCT(C_6H(1..5*H), T6(1..N));
      Task7.SetMKBMOZd(MK6(1..N), B_3H(H+1..3*H), MO_3H(H+1..3*H), Z_3H(H+1..3*H), d6);

      --compute 1
      a6:=0;
      for i in 5*H+1..6*H loop
         a6 := a6 + B_3H(i-5*H) * C_6H(i);
      end loop;

      Task7.GetBC(a7);
      a6:=a6+a7;

      accept GetBC(a : out Integer) do
         a:=a6;
      end GetBC;

      accept SetBC(a: in Integer) do
         a6:=a;
      end SetBC;

      Task7.SetBC(a6);

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_3H(i)(k)*MK6(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + T6(l)*MOMK(i)(l);
         end loop;
         A_3H(i) := a6*Z_3H(i) + d6*cell;
      end loop;

      Task7.GetA(A_3H(H+1..3*H));

      accept GetA(A: out Vector_3H) do
         A := A_3H;
      end GetA;

      Put_Line("Task 6 finished");

   end Task6;

   task body Task7 is
      MK7: Matrix_N;
      MO_2H:Matrix_2H;
      Z_2H:Vector_2H;
      T : Vector_N;
      B_2H:Vector_2H;
      C:Vector_N;
      d7:Integer;
      a7,a8:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A_2H:Vector_2H;
   begin
      Put_Line("Task 7 started");

      VectorInput(C);
      VectorInput(T);
      --C(2):=2;

      Task6.SetCT(C(1..6*H), T(1..N));
      Task8.SetCT(C(7*H+1..N), T(1..N));

      accept SetMKBMOZd(MK : in Matrix_N; B : in Vector_2H; MO: in Matrix_2H; Z: in Vector_2H; d : in Integer) do
         MK7:=MK;
         B_2H:=B;
         MO_2H:=MO;
         Z_2H:=Z;
         d7:=d;
      end SetMKBMOZd;

      Task8.SetMKBMOZd(MK7(1..N), B_2H(H+1..2*H), MO_2H(H+1..2*H), Z_2H(H+1..2*H), d7);

      --compute 1
      a7:=0;
      for i in 6*H+1..7*H loop
         a7 := a7 + B_2H(i-6*H) * C(i);
      end loop;

      Task8.GetBC(a8);
      a7:=a7+a8;

      accept GetBC(a : out Integer) do
         a:=a7;
      end GetBC;

      accept SetBC(a: in Integer) do
         a7:=a;
      end SetBC;

      Task8.SetBC(a7);



      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_2H(i)(k)*MK7(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + T(l)*MOMK(i)(l);
         end loop;
         A_2H(i) := a7*Z_2H(i) + d7*cell;
      end loop;

      Task8.GetA(A_2H(H+1..2*H));

      accept GetA(A: out Vector_2H) do
         A := A_2H;
      end GetA;

      Put_Line("Task 7 finished");

   end Task7;

   task body Task8 is
      MK8: Matrix_N;
      MO_H:Matrix_H;
      Z_H:Vector_H;
      T8 : Vector_N;
      B_H:Vector_H;
      C_H:Vector_H;
      d8:Integer;
      a8:Integer;
      cell:Integer;
      MOMK:Matrix_N;
      A_H:Vector_H;
   begin
      Put_Line("Task 8 started");

      accept SetCT(C: in Vector_H; T: in Vector_N) do
         C_H:=C;
         T8:=T;
      end SetCT;

      accept SetMKBMOZd(MK : in Matrix_N; B : in Vector_H; MO: in Matrix_H; Z: in Vector_H; d : in Integer) do
         MK8:=MK;
         B_H:=B;
         MO_H:=MO;
         Z_H:=Z;
         d8:=d;
      end SetMKBMOZd;

      --compute 1
      a8:=0;
      for i in 1..H loop
         a8 := a8 + B_H(i) * C_H(i);
      end loop;

      accept GetBC(a : out Integer) do
         a:=a8;
      end GetBC;

      accept SetBC(a: in Integer) do
         a8:=a;
      end SetBC;

      --compute
      for i in 1..H loop
         for j in 1..N loop
            cell := 0;
            for k in 1..N loop
               cell := cell + MO_H(i)(k)*MK8(k)(j);
            end loop;
            MOMK(i)(j) := cell;
         end loop;
         cell := 0;
         for l in 1..N loop
            cell := cell + T8(l)*MOMK(i)(l);
         end loop;
         A_H(i) := a8*Z_H(i) + d8*cell;
      end loop;

      accept GetA(A: out Vector_H) do
         A := A_H;
      end GetA;

     Put_Line("Task 8 finished");
   end Task8;

begin
   null;
end Main;
