------------------------Main program------------------------------
--Programming for parallel computer systems
--Laboratory work #5. Ada. Protected Units
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--15.06.2017
--Task: A = sort(Z)*e + d*T(MO*MK)
--
--=======CM======
---|---|---|---|
---1---2---3---4
---|-------|----
--MKAZT---edMO
------------------------------------------------------------------

with Ada.Text_IO, Ada.Integer_text_iO, Ada.Synchronous_Task_Control, Data;
use Ada.Text_IO, Ada.Integer_text_iO, Ada.Synchronous_Task_Control;

procedure Main is

   N: Integer :=8;
   P: Integer :=4;
   H: Integer:= N/P;

   package MonitorsData is new Data(N);
   use MonitorsData;
   A, Z, T, S : Vect;
   MO, MK : Matrix;
   d,e : Integer;
   ------------------------------------------------------------------

   ------------------------------------------------------------------
   protected Synchronization is
      entry WaitForInput;
      entry WaitForSort12;
      entry WaitForSort34;
      entry WaitForSort13;
      entry WaitForSort;
      entry WaitForCalc;
      procedure InputSignal;
      procedure Sort12Signal;
      procedure Sort34Signal;
      procedure Sort13Signal;
      procedure SortSignal;
      procedure CalcSignal;

   private
      inputFlag:Natural:=0;
      calcFlag:Natural:=0;
      sort12Flag:Natural:=0;
      sort34Flag:Natural:=0;
      sort13Flag:Natural:=0;
      sortFlag:Natural:=0;
   end Synchronization;

   protected SharedResourse is
      procedure Sete(data : in Integer);
      procedure Setd(data : in Integer);
      procedure SetMK(data : in Matrix);
      procedure SetT(data : in Vect);

      function Copye return Integer;
      function Copyd return Integer;
      function CopyT return Vect;
      function CopyMK return Matrix;

   private
      d,e: Integer;
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

      procedure Sort12Signal is
      begin
         sort12Flag := sort12Flag + 1;
      end Sort12Signal;

      procedure Sort13Signal is
      begin
         sort13Flag := sort13Flag + 1;
      end Sort13Signal;

      procedure Sort34Signal is
      begin
         sort34Flag := sort34Flag + 1;
      end Sort34Signal;

      procedure SortSignal is
      begin
         sortFlag := sortFlag + 1;
      end SortSignal;

      entry WaitForInput
        when inputFlag = 2 is
      begin
         null;
      end WaitForInput;

      entry WaitForCalc
        when calcFlag = 3 is
      begin
         null;
      end WaitForCalc;

      entry WaitForSort12
        when sort12Flag = 1 is
      begin
         null;
      end WaitForSort12;

      entry WaitForSort13
        when sort13Flag = 1 is
      begin
         null;
      end WaitForSort13;

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

      procedure Setd(data : in Integer) is
      begin
         d := data;
      end Setd;

      procedure Sete(data : in Integer) is
      begin
         e := data;
      end Sete;

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

      function Copye return Integer is
      begin
         return e;
      end Copye;

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
         e1:Integer;
         i1, i2, current, buf:Integer;
      begin

         Put_Line ("T1 started");

         InputSimpleMatrix(MK);
         InputSimpleVect(T);
         InputSimpleVect(Z);
         --Z(8):=5;
         --Z(3):=10;

         SharedResourse.SetT(T);
         SharedResourse.SetMK(MK);

         Synchronization.InputSignal;

         Synchronization.WaitForInput;

         --Sort H
         for i in reverse 1..H loop
            for j in 1..(i-1) loop
               if Z(j) > Z(j+1) then
                  buf := Z(j);
                  Z(j):=Z(j+1);
                  Z(j+1):=buf;
               end if;
            end loop;
         end loop;

         Synchronization.WaitForSort12;

         --Merge sort
         i1 := 1;
         i2 := H+1;
         current := 1;
         while i1 <= H and i2 <= 2*H loop
            if Z(i1) > Z(i2) then
               S(current) := Z(i2);
               i2 := i2+1;
               current := current+1;
            else
               S(current) := Z(i1);
               i1 := i1+1;
               current := current+1;
            end if;
         end loop;

         if i1 = H+1 then
            while i2 <= 2*H loop
               S(current) := Z(i2);
               i2 := i2+1;
               current := current+1;
            end loop;
         else
            while i1 <= H loop
               S(current) := Z(i1);
               i1 := i1+1;
               current := current+1;
            end loop;
         end if;

         Synchronization.WaitForSort13;

         --Merge sort
         i1 := 1;
         i2 := 2*H+1;
         current := 1;
         while i1 <= 2*H and i2 <= 4*H loop
            if S(i1) > S(i2) then
               Z(current) := S(i2);
               i2 := i2+1;
               current := current+1;
            else
               Z(current) := S(i1);
               i1 := i1+1;
               current := current+1;
            end if;
         end loop;

         if i1 = 2*H+1 then
            while i2 <= 4*H loop
               Z(current) := S(i2);
               i2 := i2+1;
               current := current+1;
            end loop;
         else
            while i1 <= 2*H loop
               Z(current) := S(i1);
               i1 := i1+1;
               current := current+1;
            end loop;
         end if;

         Synchronization.SortSignal;

         e1 := SharedResourse.Copye;
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
            A(i) := e1*Z(i) + d1*buf;
         end loop;

         Synchronization.WaitForCalc;

         New_Line;
         Put_Line("A = ");
         ShowVect(A);
         New_Line;

         Put_Line ("T1 finished");
      end T1;

      task T2 is
      end T2;

      task body T2 is
         MK2:Matrix;
         MOMK2:Matrix;
         T2:Vect;
         d2:Integer;
         e2:Integer;
         buf:Integer;
      begin

         Put_Line ("T2 started");

         Synchronization.WaitForInput;

         --Sort H
         for i in reverse H+1..2*H loop
            for j in 1..(i-1) loop
               if Z(j) > Z(j+1) then
                  buf := Z(j);
                  Z(j):=Z(j+1);
                  Z(j+1):=buf;
               end if;
            end loop;
         end loop;

         Synchronization.Sort12Signal;

         Synchronization.WaitForSort;

         e2 := SharedResourse.Copye;
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
            A(i) := e2*Z(i) + d2*buf;
         end loop;

         Synchronization.CalcSignal;

         Put_Line ("T2 finished");

      end T2;

      task T3 is
      end T3;

      task body T3 is
         MK3:Matrix;
         MOMK3:Matrix;
         T3:Vect;
         d3:Integer;
         e3:Integer;
         i1, i2, current, buf:Integer;
      begin

         Put_Line ("T3 started");

         e:=1;
         d:=1;
         InputSimpleMatrix(MO);

         SharedResourse.Sete(e);
         SharedResourse.Setd(d);

         Synchronization.InputSignal;

         Synchronization.WaitForInput;

         --Sort H
         for i in reverse 2*H+1..3*H loop
            for j in 1..(i-1) loop
               if Z(j) > Z(j+1) then
                  buf := Z(j);
                  Z(j):=Z(j+1);
                  Z(j+1):=buf;
               end if;
            end loop;
         end loop;

         Synchronization.WaitForSort34;

         --Merge sort
         i1 := 2*H+1;
         i2 := 3*H+1;
         current := 2*H+1;
         while i1 <= 3*H and i2 <= 4*H loop
            if Z(i1) > Z(i2) then
               S(current) := Z(i2);
               i2 := i2+1;
               current := current+1;
            else
               S(current) := Z(i1);
               i1 := i1+1;
               current := current+1;
            end if;
         end loop;

         if i1 = 3*H+1 then
            while i2 <= 4*H loop
               S(current) := Z(i2);
               i2 := i2+1;
               current := current+1;
            end loop;
         else
            while i1 <= 3*H loop
               S(current) := Z(i1);
               i1 := i1+1;
               current := current+1;
            end loop;
         end if;

         Synchronization.Sort13Signal;

         Synchronization.WaitForSort;

         e3 := SharedResourse.Copye;
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
            A(i) := e3*Z(i) + d3*buf;
         end loop;

         Synchronization.CalcSignal;

         Put_Line ("T3 finished");
      end T3;

      task T4 is
      end T4;

      task body T4 is
         MK4:Matrix;
         MOMK4:Matrix;
         T4:Vect;
         d4:Integer;
         e4:Integer;
         buf:Integer;
      begin

         Put_Line ("T4 started");

         Synchronization.WaitForInput;

         --Sort H
         for i in reverse 3*H+1..4*H loop
            for j in 1..(i-1) loop
               if Z(j) > Z(j+1) then
                  buf := Z(j);
                  Z(j):=Z(j+1);
                  Z(j+1):=buf;
               end if;
            end loop;
         end loop;

         Synchronization.Sort34Signal;

         Synchronization.WaitForSort;

         e4 := SharedResourse.Copye;
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
            A(i) := e4*Z(i) + d4*buf;
         end loop;

         Synchronization.CalcSignal;

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

