with Ada.Text_IO, Ada.Integer_Text_IO, Ada.Calendar;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Calendar;
------------------------Main program------------------------------
--Programming for parallel computer systems
--Course work part #2. System with local memory. Ada. Rendezvous
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--20.05.2017
--Task: A = (B+sort(Z))*MO+e*T(MX*MZ)
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

   procedure VectorOutput4H(V: in Vector_4H) is
   begin
      if N<=20 then
         for i in 1..4*H loop
            Put(V(i));
         end loop;
      end if;
   end VectorOutput4H;

   procedure VectorOutput2H(V: in Vector_2H) is
   begin
      if N<=20 then
         for i in 1..2*H loop
            Put(V(i));
         end loop;
      end if;
   end VectorOutput2H;

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
      entry SetZTMZ(Z :in Vector_N; T : in Vector_N; MZ : in Matrix_N);
      entry SetMOe(MO :in Matrix_4H; e : in Integer);
      entry GetS(S: out Vector_2H);
      entry SetS(S: in Vector_4H);
      entry GetR(R: out Vector_4H);
      entry SetR(R: in Vector_N);
   end Task1;

   task Task2 is
      entry SetZTMZBMX(Z: in Vector_N; T : in Vector_N; MZ : in Matrix_N; B : in Vector_N; MX : in Matrix_N);
      entry SetMOe(MO: in Matrix_5H; e : in Integer);
      entry GetA(A : out Vector_N);
   end Task2;

   task Task3 is
      entry SetMOe(MO: in Matrix_5H; e : in Integer);
      entry SetZTMZBMX(Z: in Vector_4H; T : in Vector_N; MZ : in Matrix_N; B : in Vector_4H; MX : in Matrix_4H);
      entry GetS(S: out Vector_2H);
      entry SetS(S: in Vector_4H);
      entry GetR(R: out Vector_4H);
      entry SetR(R: in Vector_N);
      entry GetA(A: out Vector_4H);
   end Task3;

   task Task4 is
      entry SetBMXMOe(B: in Vector_H; MX : in Matrix_H; MO : in Matrix_H; e : in Integer);
      entry GetS(S: out Vector_H);
      entry SetS(S: in Vector_H);
      entry GetR(R: out Vector_H);
      entry SetR(R: in Vector_N);
      entry GetA(A : out Vector_H);
   end Task4;

   task Task5 is
      entry SetData(Z: in Vector_H; T : in Vector_N; MZ : in Matrix_N; B : in Vector_H; MX : in Matrix_H; MO: in Matrix_H; e : in Integer);
      entry GetS(S: out Vector_H);
      entry SetS(S: in Vector_H);
      entry GetR(R: out Vector_H);
      entry SetR(R: in Vector_N);
      entry GetA(A : out Vector_H);
   end Task5;

   task Task6 is
      entry SetZTMZBMX(Z: in Vector_H; T : in Vector_N; MZ : in Matrix_N; B : in Vector_H; MX : in Matrix_H);
      entry GetS(S: out Vector_H);
      entry SetS(S: in Vector_H);
      entry GetR(R: out Vector_H);
      entry SetR(R: in Vector_N);
      entry GetA(A : out Vector_H);
   end Task6;

   task body Task1 is
      A:Vector_N;
      B: Vector_N;
      MX : Matrix_N;
      Z_6H: Vector_N;
      T1: Vector_N;
      MZ1:Matrix_N;
      MO_4H:Matrix_4H;

      Z_2H: Vector_2H;
      Q_2H: Vector_2H;

      S_4H:Vector_4H;
      R_4H:Vector_4H;
      R_6H:Vector_N;

      MXMZ:Matrix_N;
      e1:Integer;
      buf, buf1, buf2, i1, i2, current :Integer;
   begin
      Put_Line("Task 1 started");

      --input data
      VectorInput(B);
      MatrixInput(MX);

      accept SetZTMZ(Z :in Vector_N; T : in Vector_N; MZ : in Matrix_N) do
         Z_6H:=Z;
         T1:=T;
         MZ1:=MZ;
      end SetZTMZ;

      --send data to T2
      Task2.SetZTMZBMX(Z_6H(1..N), T1(1..N), MZ1(1..N), B(1..N), MX(1..N));

      accept SetMOe(MO :in Matrix_4H; e : in Integer) do
         MO_4H:=MO;
         e1:=e;
      end SetMOe;

      Task4.SetBMXMOe(B(3*H+1..4*H), MX(3*H+1..4*H), MO_4H(3*H+1..4*H), e1);

      for i in H+1..2*H loop
         Z_2H(i):=Z_6H(i);
      end loop;

      --Sort H
      for i in reverse H+1..2*H loop
         for j in 1..(i-1) loop
            if Z_2H(j) > Z_2H(j+1) then
               buf := Z_2H(j);
               Z_2H(j):=Z_2H(j+1);
               Z_2H(j+1):=buf;
            end if;
         end loop;
      end loop;

      Task4.GetS(Z_2H(1..H));

      --Merge sort
         i1 := 1;
         i2 := H+1;
         current := 1;
         while i1 <= H and i2 <= 2*H loop
            if Z_2H(i1) > Z_2H(i2) then
               Q_2H(current) := Z_2H(i2);
               i2 := i2+1;
               current := current+1;
            else
               Q_2H(current) := Z_2H(i1);
               i1 := i1+1;
               current := current+1;
            end if;
         end loop;

         if i1 = H+1 then
            while i2 <= 2*H loop
               Q_2H(current) := Z_2H(i2);
               i2 := i2+1;
               current := current+1;
            end loop;
         else
            while i1 <= H loop
               Q_2H(current) := Z_2H(i1);
               i1 := i1+1;
               current := current+1;
            end loop;
      end if;

      accept GetS(S: out Vector_2H) do
         S := Q_2H;
      end GetS;

      accept SetS(S: in Vector_4H) do
         S_4H := S;
      end SetS;

      Task4.SetS(S_4H(3*H+1..4*H));

      for i in 1..H loop
         R_4H(i):=S_4H(i)+B(i);
      end loop;

      Task4.GetR(R_4H(3*H+1..4*H));

      accept GetR(R: out Vector_4H) do
         for i in 1..H loop
            R(i):=R_4H(i);
            R(i+3*H):=R_4H(i+3*H);
         end loop;
      end GetR;

      accept SetR(R: in Vector_N) do
         R_6H := R;
      end SetR;

      Task4.SetR(R_6H(1..N));

      --Computing
      for i in 1..H loop
         for j in 1..N loop
            buf1 := 0;
            for k in 1..N loop
               buf1 := buf1 + MX(i)(k)*MZ1(k)(j);
            end loop;
              MXMZ(i)(j) := buf1;
         end loop;
         buf1 := 0;
         buf2 := 0;
         for l in 1..N loop
            buf1 := buf1 + T1(l)*MXMZ(i)(l);
            buf2 := buf2 + R_6H(l)*MO_4H(i)(l);
         end loop;
         A(i) := buf2 + e1*buf1;
      end loop;

      Task4.GetA(A(3*H+1..4*H));
      Task2.GetA(A(1..N));

      --show results
      New_Line;
      Put("A = ");
      New_Line;
      VectorOutput(A);
      New_Line;

      Put_Line("Task 1 finished");

      FinishTime := Clock;
      DiffTime := FinishTime - StartTime;

      Put("Time : ");
      Put(Integer(DiffTime), 1);
      Put_Line("");

   end Task1;

   task body Task2 is
      B_6H: Vector_N;
      MX_6H : Matrix_N;
      Z_6H: Vector_N;
      T2: Vector_N;
      MZ2:Matrix_N;
      MO_5H:Matrix_5H;

      S_2H:Vector_2H;
      Q_2H: Vector_2H;

      S_4H:Vector_4H;
      Q_4H:Vector_4H;
      R_6H:Vector_N;
      S_6H:Vector_N;
      S:Vector_N;
      A_4H:Vector_4H;

      MXMZ:Matrix_N;
      e2:Integer;
      buf, buf1, buf2, i1, i2, current :Integer;
   begin
      Put_Line("Task 2 started");

      accept SetZTMZBMX(Z: in Vector_N; T : in Vector_N; MZ : in Matrix_N; B : in Vector_N; MX : in Matrix_N) do
         Z_6H:= Z;
         T2:=T;
         MZ2:=MZ;
         B_6H:=B;
         MX_6H:=MX;
      end SetZTMZBMX;

      accept SetMOe(MO: in Matrix_5H; e : in Integer) do
         MO_5H:= MO;
         e2:=e;
      end SetMOe;

      Task1.SetMOe(MO_5H(1..4*H), e2);
      Task3.SetZTMZBMX(Z_6H(2*H+1..N), T2(1..N), MZ2(1..N), B_6H(2*H+1..N), MX_6H(2*H+1..N));
      Task5.SetData(Z_6H(4*H+1..5*H), T2(1..N), MZ2(1..N), B_6H(4*H+1..5*H), MX_6H(4*H+1..5*H), MO_5H(3*H+1..4*H), e2);

      for i in H+1..2*H loop
         S_2H(i):=Z_6H(i);
      end loop;

      --Sort H
      for i in reverse 1..6*H loop
         for j in 1..(i-1) loop
            if Z_6H(j) > Z_6H(j+1) then
               buf := Z_6H(j);
               Z_6H(j):=Z_6H(j+1);
               Z_6H(j+1):=buf;
            end if;
         end loop;
      end loop;

      Task5.GetS(S_2H(1..H));

      --Merge sort
         i1 := 1;
         i2 := H+1;
         current := 1;
         while i1 <= H and i2 <= 2*H loop
            if S_2H(i1) > S_2H(i2) then
               Q_2H(current) := S_2H(i2);
               i2 := i2+1;
               current := current+1;
            else
               Q_2H(current) := S_2H(i1);
               i1 := i1+1;
               current := current+1;
            end if;
         end loop;

         if i1 = H+1 then
            while i2 <= 2*H loop
               Q_2H(current) := S_2H(i2);
               i2 := i2+1;
               current := current+1;
            end loop;
         else
            while i1 <= H loop
               Q_2H(current) := S_2H(i1);
               i1 := i1+1;
               current := current+1;
            end loop;
      end if;

      for i in 2*H+1..4*H loop
         S_4H(i):=Q_2H(i-2*H);
      end loop;

      Task1.GetS(S_4H(1..2*H));

      --Merge sort
         i1 := 1;
         i2 := 2*H+1;
         current := 1;
         while i1 <= 2*H and i2 <= 4*H loop
            if S_4H(i1) > S_4H(i2) then
               Q_4H(current) := S_4H(i2);
               i2 := i2+1;
               current := current+1;
            else
               Q_4H(current) := S_4H(i1);
               i1 := i1+1;
               current := current+1;
            end if;
         end loop;

         if i1 = 2*H+1 then
            while i2 <= 4*H loop
               Q_4H(current) := S_4H(i2);
               i2 := i2+1;
               current := current+1;
            end loop;
         else
            while i1 <= 2*H loop
               Q_4H(current) := S_4H(i1);
               i1 := i1+1;
               current := current+1;
            end loop;
      end if;

      for i in 2*H+1..6*H loop
         S_6H(i):=Q_4H(i-2*H);
      end loop;

      Task3.GetS(S_6H(1..2*H));

      --Merge sort
         i1 := 1;
         i2 := 4*H+1;
         current := 1;
         while i1 <= 4*H and i2 <= 6*H loop
            if S_6H(i1) > S_6H(i2) then
               S(current) := S_6H(i2);
               i2 := i2+1;
               current := current+1;
            else
               S(current) := S_6H(i1);
               i1 := i1+1;
               current := current+1;
            end if;
         end loop;

         if i1 = 4*H+1 then
            while i2 <= 6*H loop
               S(current) := S_6H(i2);
               i2 := i2+1;
               current := current+1;
            end loop;
         else
            while i1 <= 4*H loop
               S(current) := S_6H(i1);
               i1 := i1+1;
               current := current+1;
            end loop;
      end if;

      Task1.SetS(Z_6H(1..4*H));
      Task3.SetS(Z_6H(2*H+1..N));
      Task5.SetS(Z_6H(4*H+1..5*H));

      for i in H+1..2*H loop
         R_6H(i):=Z_6H(i)+B_6H(i);
      end loop;

      Task1.GetR(R_6H(1..4*H));
      Task3.GetR(R_6H(2*H+1..N));
      Task5.GetR(R_6H(4*H+1..5*H));


      Task1.SetR(R_6H(1..N));
      Task3.SetR(R_6H(1..N));
      Task5.SetR(R_6H(1..N));
      --Computing
      for i in 1..H loop
         for j in 1..N loop
            buf1 := 0;
            for k in 1..N loop
               buf1 := buf1 + MX_6H(i)(k)*MZ2(k)(j);
            end loop;
              MXMZ(i)(j) := buf1;
         end loop;
         buf1 := 0;
         buf2 := 0;
         for l in 1..N loop
            buf1 := buf1 + T2(l)*MXMZ(i)(l);
            buf2 := buf2 + R_6H(l)*MO_5H(i)(l);
         end loop;
         A_4H(i) := buf2 + e2*buf1;
      end loop;

      Task5.GetA(A_4H(2*H+1..3*H));
      Task3.GetA(A_4H(1..4*H));

      accept GetA(A : out Vector_N) do
         for i in 1..2*H loop
            A(i+H) := A_4H(i);
            A(i+4*H) := A_4H(i+2*H);
         end loop;
      end GetA;

      Put_Line("Task 2 finished");
   end Task2;

   task body Task3 is
      T3: Vector_N;
      MZ3:Matrix_N;
      MO_5H:Matrix_5H;

      Z_2H: Vector_2H;
      Q_2H: Vector_2H;
      Z_4H: Vector_4H;
      R_4H: Vector_4H;
      B_4H: Vector_4H;
      MX_4H:Matrix_4H;

      S_4H:Vector_4H;
      R_6H:Vector_N;
      A_4H: Vector_4H;

      MXMZ:Matrix_N;
      e3:Integer;
      buf, buf1, buf2, i1, i2, current :Integer;
   begin
      Put_Line("Task 3 started");

      accept SetMOe(MO: in Matrix_5H; e : in Integer) do
         MO_5H:= MO;
         e3:=e;
      end SetMOe;

      Task2.SetMOe(MO_5H(1..5*H), e3);

      accept SetZTMZBMX(Z: in Vector_4H; T : in Vector_N; MZ : in Matrix_N; B : in Vector_4H; MX : in Matrix_4H) do
         Z_4H:= Z;
         T3:=T;
         MZ3:=MZ;
         B_4H:=B;
         MX_4H:=MX;
      end SetZTMZBMX;

      Task6.SetZTMZBMX(Z_4H(3*H+1..4*H), T3(1..N), MZ3(1..N), B_4H(3*H+1..4*H), MX_4H(3*H+1..4*H));

      for i in 1..H loop
         Z_2H(i+H):=Z_4H(i);
      end loop;

      --Sort H
      for i in reverse H+1..2*H loop
         for j in 1..(i-1) loop
            if Z_2H(j) > Z_2H(j+1) then
               buf := Z_2H(j);
               Z_2H(j):=Z_2H(j+1);
               Z_2H(j+1):=buf;
            end if;
         end loop;
      end loop;

      Task6.GetS(Z_2H(1..H));

      --Merge sort
         i1 := 1;
         i2 := H+1;
         current := 1;
         while i1 <= H and i2 <= 2*H loop
            if Z_2H(i1) > Z_2H(i2) then
               Q_2H(current) := Z_2H(i2);
               i2 := i2+1;
               current := current+1;
            else
               Q_2H(current) := Z_2H(i1);
               i1 := i1+1;
               current := current+1;
            end if;
         end loop;

         if i1 = H+1 then
            while i2 <= 2*H loop
               Q_2H(current) := Z_2H(i2);
               i2 := i2+1;
               current := current+1;
            end loop;
         else
            while i1 <= H loop
               Q_2H(current) := Z_2H(i1);
               i1 := i1+1;
               current := current+1;
            end loop;
      end if;

      accept GetS(S: out Vector_2H) do
         S := Q_2H;
      end GetS;

      accept SetS(S: in Vector_4H) do
         S_4H := S;
      end SetS;

      Task6.SetS(S_4H(3*H+1..4*H));

      for i in 1..H loop
         R_4H(i):=S_4H(i)+B_4H(i);
      end loop;

      Task6.GetR(R_4H(3*H+1..4*H));

      accept GetR(R: out Vector_4H) do
         for i in 1..H loop
            R(i):=R_4H(i);
            R(i+3*H):=R_4H(i+3*H);
         end loop;
      end GetR;

      accept SetR(R: in Vector_N) do
         R_6H := R;
      end SetR;

      Task6.SetR(R_6H(1..N));

      --Computing
      for i in 1..H loop
         for j in 1..N loop
            buf1 := 0;
            for k in 1..N loop
               buf1 := buf1 + MX_4H(i)(k)*MZ3(k)(j);
            end loop;
              MXMZ(i)(j) := buf1;
         end loop;
         buf1 := 0;
         buf2 := 0;
         for l in 1..N loop
            buf1 := buf1 + T3(l)*MXMZ(i)(l);
            buf2 := buf2 + R_6H(l)*MO_5H(i)(l);
         end loop;
         A_4H(i) := buf2 + e3*buf1;
      end loop;



      Task6.GetA(A_4H(3*H+1..4*H));

      accept GetA(A: out Vector_4H) do
         for i in 1..H loop
            A(i+H):=A_4H(i);
            A(i+3*H):=A_4H(i+3*H);
         end loop;
      end GetA;

      Put_Line("Task 3 finished");
   end Task3;

   task body Task4 is
      MZ:Matrix_N;
      MO_H:Matrix_H;

      Z:Vector_N;
      T:Vector_N;

      B_H: Vector_H;
      MX_H:Matrix_H;

      A_H:Vector_H;
      Z_H:Vector_H;
      S_H:Vector_H;
      R_H:Vector_H;
      R_6H:Vector_N;

      MXMZ:Matrix_N;
      e4:Integer;
      buf, buf1, buf2 :Integer;
   begin
      Put_Line("Task 4 started");

      VectorInput(Z);
      Z(2):=10;
      VectorInput(T);
      MatrixInput(MZ);

      Task1.SetZTMZ(Z(1..N), T(1..N), MZ(1..N));

      accept SetBMXMOe(B: in Vector_H; MX : in Matrix_H; MO : in Matrix_H; e : in Integer) do
         B_H:= B;
         MX_H:=MX;
         MO_H:=MO;
         e4:=e;
      end SetBMXMOe;

      for i in 1..H loop
         Z_H(i):=Z(i+3*H);
      end loop;

      --Sort H
      for i in reverse 1..H loop
         for j in 1..(i-1) loop
            if Z_H(j) > Z_H(j+1) then
               buf := Z_H(j);
               Z_H(j):=Z_H(j+1);
               Z_H(j+1):=buf;
            end if;
         end loop;
      end loop;

      accept GetS(S: out Vector_H) do
         S := Z_H;
      end GetS;

      accept SetS(S: in Vector_H) do
         S_H := S;
      end SetS;

      for i in 1..H loop
         R_H(i):=S_H(i)+B_H(i);
      end loop;

      accept GetR(R: out Vector_H) do
         R := R_H;
      end GetR;

      accept SetR(R: in Vector_N) do
         R_6H := R;
      end SetR;

      --Computing
      for i in 1..H loop
         for j in 1..N loop
            buf1 := 0;
            for k in 1..N loop
               buf1 := buf1 + MX_H(i)(k)*MZ(k)(j);
            end loop;
              MXMZ(i)(j) := buf1;
         end loop;
         buf1 := 0;
         buf2 := 0;
         for l in 1..N loop
            buf1 := buf1 + T(l)*MXMZ(i)(l);
            buf2 := buf2 + R_6H(l)*MO_H(i)(l);
         end loop;
         A_H(i) := buf2 + e4*buf1;
      end loop;

      accept GetA(A : out Vector_H) do
         A:=A_H(1..H);
      end GetA;

      Put_Line("Task 4 finished");

   end Task4;

   task body Task5 is
      T5: Vector_N;
      MZ5:Matrix_N;
      MO_H:Matrix_H;


      B_H: Vector_H;
      MX_H:Matrix_H;

      A_H:Vector_H;
      Z_H:Vector_H;
      S_H:Vector_H;
      R_H:Vector_H;
      R_6H:Vector_N;

      MXMZ:Matrix_N;
      e5:Integer;
      buf, buf1, buf2 :Integer;
   begin
      Put_Line("Task 5 started");

      accept SetData(Z: in Vector_H; T : in Vector_N; MZ : in Matrix_N; B : in Vector_H; MX : in Matrix_H; MO: in Matrix_H; e : in Integer) do
         Z_H:= Z;
         T5:=T;
         MZ5:=MZ;
         B_H:=B;
         MX_H:=MX;
         MO_H:=MO;
         e5:=e;
      end SetData;

      --Sort H
      for i in reverse 1..H loop
         for j in 1..(i-1) loop
            if Z_H(j) > Z_H(j+1) then
               buf := Z_H(j);
               Z_H(j):=Z_H(j+1);
               Z_H(j+1):=buf;
            end if;
         end loop;
      end loop;

      accept GetS(S: out Vector_H) do
         S := Z_H;
      end GetS;

      accept SetS(S: in Vector_H) do
         S_H := S;
      end SetS;

      for i in 1..H loop
         R_H(i):=S_H(i)+B_H(i);
      end loop;

      accept GetR(R: out Vector_H) do
         R := R_H;
      end GetR;

      accept SetR(R: in Vector_N) do
         R_6H := R;
      end SetR;

      --Computing
      for i in 1..H loop
         for j in 1..N loop
            buf1 := 0;
            for k in 1..N loop
               buf1 := buf1 + MX_H(i)(k)*MZ5(k)(j);
            end loop;
            MXMZ(i)(j) := buf1;
         end loop;
         buf1 := 0;
         buf2 := 0;
         for l in 1..N loop
            buf1 := buf1 + T5(l)*MXMZ(i)(l);
            buf2 := buf2 + R_6H(l)*MO_H(i)(l);
         end loop;
         A_H(i) := buf2 + e5*buf1;
      end loop;

      accept GetA(A : out Vector_H) do
         A:=A_H(1..H);
      end GetA;

      Put_Line("Task 5 finished");
   end Task5;

   task body Task6 is
      MZ6:Matrix_N;
      MO:Matrix_N;
      T6:Vector_N;

      B_H: Vector_H;
      MX_H:Matrix_H;

      A_H:Vector_H;
      Z_H:Vector_H;
      S_H:Vector_H;
      R_H:Vector_H;
      R_6H:Vector_N;

      MXMZ:Matrix_N;
      e:Integer;
      buf, buf1, buf2 :Integer;
   begin
      Put_Line("Task 6 started");

      MatrixInput(MO);
      e := 1;

      Task3.SetMOe(MO(H+1..N), e);

      accept SetZTMZBMX(Z: in Vector_H; T : in Vector_N; MZ : in Matrix_N; B : in Vector_H; MX : in Matrix_H) do
         Z_H:= Z;
         T6:=T;
         MZ6:=MZ;
         B_H:=B;
         MX_H:=MX;
      end SetZTMZBMX;

      --Sort H
      for i in reverse 1..H loop
         for j in 1..(i-1) loop
            if Z_H(j) > Z_H(j+1) then
               buf := Z_H(j);
               Z_H(j):=Z_H(j+1);
               Z_H(j+1):=buf;
            end if;
         end loop;
      end loop;

      accept GetS(S: out Vector_H) do
         S := Z_H;
      end GetS;

      accept SetS(S: in Vector_H) do
         S_H := S;
      end SetS;

      for i in 1..H loop
         R_H(i):=S_H(i)+B_H(i);
      end loop;

      accept GetR(R: out Vector_H) do
         R := R_H;
      end GetR;

      accept SetR(R: in Vector_N) do
         R_6H := R;
      end SetR;

      --Computing
      for i in 1..H loop
         for j in 1..N loop
            buf1 := 0;
            for k in 1..N loop
               buf1 := buf1 + MX_H(i)(k)*MZ6(k)(j);
            end loop;
              MXMZ(i)(j) := buf1;
         end loop;
         buf1 := 0;
         buf2 := 0;
         for l in 1..N loop
            buf1 := buf1 + T6(l)*MXMZ(i)(l);
            buf2 := buf2 + R_6H(l)*MO(i+5*H)(l);
         end loop;
         A_H(i) := buf2 + e*buf1;
      end loop;



      accept GetA(A : out Vector_H) do
         A:=A_H(1..H);
      end GetA;

      Put_Line("Task 6 finished");
   end Task6;

begin
   StartTime := Clock;
end Main;

