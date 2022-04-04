------------------------Main program------------------------------
--Programming for parallel computer systems
--Laboratory work #5. Ada. Protected Units
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--15.06.2017
--Task: A = max(Z)*E + d*T(MO*MK)
--
--=======CM======
---|---|---|---|
---1---2---3---4
---|-------|---|
--dTMK----EMO--AZ
------------------------------------------------------------------

with Ada.Text_IO, Ada.Integer_text_iO, Ada.Synchronous_Task_Control, Data;
use Ada.Text_IO, Ada.Integer_text_iO, Ada.Synchronous_Task_Control;

procedure Main is

   N: Integer :=8;
   P: Integer :=4;
   H: Integer:= N/P;

   package MonitorsData is new Data(N);
   use MonitorsData;
   A, Z, E, T : Vect;
   MO, MK : Matrix;
   d : Integer;
   ------------------------------------------------------------------

   ------------------------------------------------------------------
   protected Synchronization is
      entry WaitForInput;
      entry WaitForMax;
      entry WaitForCalc;
      procedure InputSignal;
      procedure MaxSignal;
      procedure CalcSignal;

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

      entry WaitForInput
        when inputFlag = 3 is
      begin
         null;
      end WaitForInput;

      entry WaitForCalc
        when calcFlag = 3 is
      begin
         null;
      end WaitForCalc;

      entry WaitForMax
        when maxFlag = 4 is
      begin
         null;
      end WaitForMax;

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

         InputSimpleMatrix(MK);
         InputSimpleVect(T);
         d:=1;

         SharedResourse.SetT(T);
         SharedResourse.SetMK(MK);
         SharedResourse.Setd(d);

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
            A(i) := a1*E(i) + d1*buf;
         end loop;

         Synchronization.CalcSignal;

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
      begin

         Put_Line ("T2 started");

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
            A(i) := a2*E(i) + d2*buf;
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
         a3:Integer;
         buf:Integer;
      begin

         Put_Line ("T3 started");

         InputSimpleVect(E);
         --E(2):=10;
         InputSimpleMatrix(MO);

         Synchronization.InputSignal;

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
            A(i) := a3*E(i) + d3*buf;
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
         a4:Integer;
         buf:Integer;
      begin

         Put_Line ("T4 started");

         InputSimpleVect(Z);
         --Z(3):=10;

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
            A(i) := a4*E(i) + d4*buf;
         end loop;

         Synchronization.WaitForCalc;

         New_Line;
         Put_Line("A = ");
         ShowVect(A);
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

