------------------------Main program------------------------------
--Programming for parallel computer systems
--Laboratory work #5. Ada. Protected Units
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--15.06.2017
--Task: A = sort(d*B + max(Z)*T*(MO*MK))
--
--=======CM======
---|---|---|---|
---1---2---3---4
---|---|-------|
--TMO--dZ-----ABMK
------------------------------------------------------------------

with Ada.Text_IO, Ada.Integer_text_iO, Ada.Synchronous_Task_Control, Data;
use Ada.Text_IO, Ada.Integer_text_iO, Ada.Synchronous_Task_Control;

procedure Main is

   N: Integer :=8;
   P: Integer :=4;
   H: Integer:= N/P;

   package MonitorsData is new Data(N);
   use MonitorsData;
   A, Z, B, T, S, R : Vect;
   MO, MK : Matrix;
   d : Integer;
   ------------------------------------------------------------------

   ------------------------------------------------------------------
   protected Synchronization is
      entry WaitForInput;
      entry WaitForMax;
      entry WaitForCalc;
      entry WaitForSort12;
      entry WaitForSort34;
      entry WaitForSort;
      procedure InputSignal;
      procedure MaxSignal;
      procedure CalcSignal;
      procedure Sort12Signal;
      procedure Sort34Signal;
      procedure SortSignal;

   private
      inputFlag:Natural:=0;
      maxFlag:Natural:=0;
      calcFlag:Natural:=0;
      sort12Flag:Natural:=0;
      sort34Flag:Natural:=0;
      sortFlag:Natural:=0;
   end Synchronization;

   protected SharedResourse is
      procedure SetMax(data : in Integer);
      procedure SetMK(data : in Matrix);
      procedure SetT(data : in Vect);
      procedure Setd(data : in Integer);

      function CopyMax return Integer;
      function Copyd return Integer;
      function CopyT return Vect;
      function CopyMK return Matrix;

   private
      d: Integer;
      max: Integer := Integer'First;
      MK:Matrix;
      T:Vect;

   end SharedResourse;
   ------------------------------------------------------------------

   ------------------------------------------------------------------
   protected body Synchronization is

      procedure InputSignal is
      begin
         inputFlag := inputFlag + 1;
      end InputSignal;

      procedure CalcSignal is
      begin
         calcFlag := calcFlag + 1;
      end CalcSignal;

      procedure MaxSignal is
      begin
         maxFlag := maxFlag + 1;
      end MaxSignal;

      procedure Sort12Signal is
      begin
         sort12Flag := sort12Flag + 1;
      end Sort12Signal;

      procedure Sort34Signal is
      begin
         sort34Flag := sort34Flag + 1;
      end Sort34Signal;

      procedure SortSignal is
      begin
         sortFlag := sortFlag + 1;
      end SortSignal;

      entry WaitForInput
        when inputFlag = 3 is
      begin
         null;
      end WaitForInput;

      entry WaitForCalc
        when calcFlag = 4 is
      begin
         null;
      end WaitForCalc;

      entry WaitForMax
        when maxFlag = 4 is
      begin
         null;
      end WaitForMax;

      entry WaitForSort12
        when sort12Flag = 1 is
      begin
         null;
      end WaitForSort12;

      entry WaitForSort34
        when sort34Flag = 1 is
      begin
         null;
      end WaitForSort34;

      entry WaitForSort
        when sortFlag = 1 is
      begin
         null;
      end WaitForSort;

   end Synchronization;

   protected body SharedResourse is

      procedure SetMax(data : in Integer) is
      begin
         if data >= max then
            max := data;
         end if;
      end SetMax;

      procedure Setd(data : in Integer) is
      begin
         d := data;
      end Setd;

      procedure SetMK(data : in Matrix) is
      begin
         MK:=data;
      end SetMK;

      procedure SetT(data : in Vect) is
      begin
         T:=data;
      end SetT;

      function Copyd return Integer is
      begin
         return d;
      end Copyd;

      function CopyMax return Integer is
      begin
         return max;
      end CopyMax;

      function CopyMK return Matrix is
      begin
         return MK;
      end CopyMK;

      function CopyT return Vect is
      begin
         return T;
      end CopyT;

   end SharedResourse;
   ------------------------------------------------------------------

   ------------------------------------------------------------------
   procedure StartTasks  is
      ------------------------------------------------------------------

      ------------------------------------------------------------------
      task T1 is
      end T1;

      task body T1 is
         MK1:Matrix;
         MOMK1:Matrix;
         T1:Vect;
         d1:Integer;
         a1:Integer;
         buf:Integer;
      begin

         Put_Line ("T1 started");

         InputSimpleMatrix(MO);
         InputSimpleVect(T);

         SharedResourse.SetT(T);

         Synchronization.InputSignal;

         Synchronization.WaitForInput;

         a1 := Max(Z, 1, H);

         SharedResourse.setMax(a1);

         Synchronization.MaxSignal;

         Synchronization.WaitForMax;

         a1 := SharedResourse.CopyMax;
         MK1 := SharedResourse.CopyMK;
         d1 := SharedResourse.Copyd;
         T1 := SharedResourse.CopyT;

         for i in 1..H loop
            for j in 1..N loop
               buf :=0;
               for k in 1..N loop
                  buf := buf + MO(i,k) * MK1(k,j);
               end loop;
               MOMK1(i,j) := buf;
            end loop;
            buf := 0;
            for l in 1..N loop
               buf := buf + T1(l)*MOMK1(i,l);
            end loop;
            S(i) := d1*B(i) + a1*buf;
         end loop;

         Synchronization.CalcSignal;
         Synchronization.WaitForCalc;

         --Sort H
         for i in reverse 1..H loop
            for j in 1..(i-1) loop
               if S(j) > S(j+1) then
                  buf := S(j);
                  S(j):=S(j+1);
                  S(j+1):=buf;
               end if;
            end loop;
         end loop;

         Synchronization.Sort12Signal;

         Put_Line ("T1 finished");
      end T1;

      task T2 is
      end T2;

      task body T2 is
         MK2:Matrix;
         MOMK2:Matrix;
         T2:Vect;
         d2:Integer;
         a2:Integer;
         buf:Integer;
         i1, i2, current : Integer;
      begin

         Put_Line ("T2 started");

         d:=1;
         InputSimpleVect(Z);
         --Z(4):=2;

         SharedResourse.Setd(d);

         Synchronization.InputSignal;

         Synchronization.WaitForInput;

         a2 := Max(Z, H+1, 2*H);

         SharedResourse.SetMax(a2);

         Synchronization.MaxSignal;

         Synchronization.WaitForMax;

         a2 := SharedResourse.CopyMax;
         MK2 := SharedResourse.CopyMK;
         d2 := SharedResourse.Copyd;
         T2 := SharedResourse.CopyT;

         for i in H+1..2*H loop
            for j in 1..N loop
               buf :=0;
               for k in 1..N loop
                  buf := buf + MO(i,k) * MK2(k,j);
               end loop;
               MOMK2(i,j) := buf;
            end loop;
            buf := 0;
            for l in 1..N loop
               buf := buf + T2(l)*MOMK2(i,l);
            end loop;
            S(i) := d2*B(i) + a2*buf;
         end loop;

         Synchronization.CalcSignal;
         Synchronization.WaitForCalc;

         --Sort H
         for i in reverse H+1..2*H loop
            for j in 1..(i-1) loop
               if S(j) > S(j+1) then
                  buf := S(j);
                  S(j):=S(j+1);
                  S(j+1):=buf;
               end if;
            end loop;
         end loop;

         Synchronization.WaitForSort12;

         --Merge sort
         i1 := 1;
         i2 := H+1;
         current := 1;
         while i1 <= H and i2 <= 2*H loop
            if S(i1) > S(i2) then
               R(current) := S(i2);
               i2 := i2+1;
               current := current+1;
            else
               R(current) := S(i1);
               i1 := i1+1;
               current := current+1;
            end if;
         end loop;

         if i1 = H+1 then
            while i2 <= 2*H loop
               R(current) := S(i2);
               i2 := i2+1;
               current := current+1;
            end loop;
         else
            while i1 <= H loop
               R(current) := S(i1);
               i1 := i1+1;
               current := current+1;
            end loop;
         end if;

         Synchronization.SortSignal;

         Put_Line ("T2 finished");

      end T2;

      task T3 is
      end T3;

      task body T3 is
         MK3:Matrix;
         MOMK3:Matrix;
         T3:Vect;
         d3:Integer;
         a3:Integer;
         buf:Integer;
      begin

         Put_Line ("T3 started");

         Synchronization.WaitForInput;

         a3 := Max(Z, 2*H+1, 3*H);

         SharedResourse.SetMax(a3);

         Synchronization.MaxSignal;

         Synchronization.WaitForMax;

         a3 := SharedResourse.CopyMax;
         MK3 := SharedResourse.CopyMK;
         d3 := SharedResourse.Copyd;
         T3 := SharedResourse.CopyT;

         for i in 2*H+1..3*H loop
            for j in 1..N loop
               buf :=0;
               for k in 1..N loop
                  buf := buf + MO(i,k) * MK3(k,j);
               end loop;
               MOMK3(i,j) := buf;
            end loop;
            buf := 0;
            for l in 1..N loop
               buf := buf + T3(l)*MOMK3(i,l);
            end loop;
            S(i) := d3*B(i) + a3*buf;
         end loop;

         Synchronization.CalcSignal;
         Synchronization.WaitForCalc;

         --Sort H
         for i in reverse 2*H+1..3*H loop
            for j in 1..(i-1) loop
               if S(j) > S(j+1) then
                  buf := S(j);
                  S(j):=S(j+1);
                  S(j+1):=buf;
               end if;
            end loop;
         end loop;

         Synchronization.Sort34Signal;

         Put_Line ("T3 finished");
      end T3;

      task T4 is
      end T4;

      task body T4 is
         MK4:Matrix;
         MOMK4:Matrix;
         T4:Vect;
         d4:Integer;
         a4:Integer;
         buf:Integer;
         i1, i2, current : Integer;
      begin

         Put_Line ("T4 started");

         InputSimpleMatrix(MK);
         InputSimpleVect(B);
         --B(5):=10;
         --B(2):=5;
         --B(8):=3;

         SharedResourse.SetMK(MK);

         Synchronization.InputSignal;

         Synchronization.WaitForInput;

         a4 := Max(Z, 3*H+1, 4*H);

         SharedResourse.SetMax(a4);

         Synchronization.MaxSignal;

         Synchronization.WaitForMax;

         a4 := SharedResourse.CopyMax;
         MK4 := SharedResourse.CopyMK;
         d4 := SharedResourse.Copyd;
         T4 := SharedResourse.CopyT;

         for i in 3*H+1..4*H loop
            for j in 1..N loop
               buf :=0;
               for k in 1..N loop
                  buf := buf + MO(i,k) * MK4(k,j);
               end loop;
               MOMK4(i,j) := buf;
            end loop;
            buf := 0;
            for l in 1..N loop
               buf := buf + T4(l)*MOMK4(i,l);
            end loop;
            S(i) := d4*B(i) + a4*buf;
         end loop;

         Synchronization.CalcSignal;
         Synchronization.WaitForCalc;

         --Sort H
         for i in reverse 3*H+1..4*H loop
            for j in 1..(i-1) loop
               if S(j) > S(j+1) then
                  buf := S(j);
                  S(j):=S(j+1);
                  S(j+1):=buf;
               end if;
            end loop;
         end loop;

         Synchronization.WaitForSort34;

         --Merge sort
         i1 := 2*H+1;
         i2 := 3*H+1;
         current := 2*H+1;
         while i1 <= 3*H and i2 <= 4*H loop
            if S(i1) > S(i2) then
               R(current) := S(i2);
               i2 := i2+1;
               current := current+1;
            else
               R(current) := S(i1);
               i1 := i1+1;
               current := current+1;
            end if;
         end loop;

         if i1 = 3*H+1 then
            while i2 <= 4*H loop
               R(current) := S(i2);
               i2 := i2+1;
               current := current+1;
            end loop;
         else
            while i1 <= 3*H loop
               R(current) := S(i1);
               i1 := i1+1;
               current := current+1;
            end loop;
         end if;

         Synchronization.WaitForSort;

         --Merge sort
         i1 := 1;
         i2 := 2*H+1;
         current := 1;
         while i1 <= 2*H and i2 <= 4*H loop
            if R(i1) > R(i2) then
               A(current) := R(i2);
               i2 := i2+1;
               current := current+1;
            else
               A(current) := R(i1);
               i1 := i1+1;
               current := current+1;
            end if;
         end loop;

         if i1 = 2*H+1 then
            while i2 <= 4*H loop
               A(current) := R(i2);
               i2 := i2+1;
               current := current+1;
            end loop;
         else
            while i1 <= 2*H loop
               A(current) := R(i1);
               i1 := i1+1;
               current := current+1;
            end loop;
         end if;

         New_Line;
         Put_Line("A = ");
         ShowVect(S);
         New_Line;

         Put_Line ("T4 finished");
      end T4;

   begin
      null;
   end StartTasks;

begin
   Put_Line ("Main thread started");
   StartTasks;
   Put_Line ("Main thread finished");

end Main;

