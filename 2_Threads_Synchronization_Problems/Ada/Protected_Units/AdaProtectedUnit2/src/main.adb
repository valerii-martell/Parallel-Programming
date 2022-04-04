------------------------Main program------------------------------
--Programming for parallel computer systems
--Laboratory work #5. Ada. Protected Units
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--15.06.2017
--Task: MA = MB*MC + d*MO*MK
--
---==========SM=========
----|-----|-----|-----|
----1-----2-----3-----4
----|-----------|-----|
--MA,MB-------MC,MO--d,MK
------------------------------------------------------------------

with Ada.Text_IO, Ada.Integer_text_iO, Ada.Synchronous_Task_Control, Data;
use Ada.Text_IO, Ada.Integer_text_iO, Ada.Synchronous_Task_Control;

procedure Main is

   N: Integer :=8;
   P: Integer :=4;
   H: Integer:= N/P;

   package MonitorsData is new Data(N);
   use MonitorsData;
   MA, MB, MC, MO, MK : Matrix;
   d : Integer;
   ------------------------------------------------------------------

   ------------------------------------------------------------------
   protected Synchronization is
      entry WaitForInput;
      entry WaitForCalc;
      procedure InputSignal;
      procedure CalcSignal;

   private
      inputFlag:Natural:=0;
      calcFlag:Natural:=0;
   end Synchronization;

   protected SharedResourse is
      procedure SetMC(data : in Matrix);
      procedure SetMK(data : in Matrix);
      procedure Setd(data : in Integer);

      function CopyMC return Matrix;
      function CopyMK return Matrix;
      function Copyd return Integer;

   private
      d: Integer;
      MK:Matrix;
      MC:Matrix;

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

   end Synchronization;

   protected body SharedResourse is

      procedure Setd(data : in Integer) is
      begin
         d := data;
      end Setd;

      procedure SetMK(data : in Matrix) is
      begin
         MK:=data;
      end SetMK;

      procedure SetMC(data : in Matrix) is
      begin
         MC:=data;
      end SetMC;

      function Copyd return Integer is
      begin
         return d;
      end Copyd;

      function CopyMK return Matrix is
      begin
         return MK;
      end CopyMK;

      function CopyMC return Matrix is
      begin
         return MC;
      end CopyMC;

   end SharedResourse;
   ------------------------------------------------------------------

   ------------------------------------------------------------------
   procedure StartTasks  is
      ------------------------------------------------------------------

      ------------------------------------------------------------------
      task T1 is
      end T1;

      task body T1 is
         MK1, MC1:Matrix;
         d1, buf1, buf2 :Integer;
      begin

         Put_Line ("T1 started");

         InputSimpleMatrix(MB);

         Synchronization.InputSignal;

         Synchronization.WaitForInput;

         MC1 := SharedResourse.CopyMC;
         MK1 := SharedResourse.CopyMK;
         d1 := SharedResourse.Copyd;

         for i in 1..H loop
            for j in 1..N loop
               buf1 :=0;
               buf2 :=0;
               for k in 1..N loop
                  buf1 := buf1 + MB(i,k) * MC1(k,j);
                  buf2 := buf2 + MO(i,k) * MK1(k,j);
               end loop;
               MA(i,j) := buf1 + d1*buf2;
            end loop;
         end loop;

         Synchronization.WaitForCalc;

         New_Line;
         Put_Line("MA = ");
         ShowMatr(MA);
         New_Line;

         Put_Line ("T1 finished");
      end T1;

      task T2 is
      end T2;

      task body T2 is
         MK2, MC2:Matrix;
         d2, buf1, buf2 :Integer;
      begin

         Put_Line ("T2 started");

         Synchronization.WaitForInput;

         MC2 := SharedResourse.CopyMC;
         MK2 := SharedResourse.CopyMK;
         d2 := SharedResourse.Copyd;

         for i in H+1..2*H loop
            for j in 1..N loop
               buf1 :=0;
               buf2 :=0;
               for k in 1..N loop
                  buf1 := buf1 + MB(i,k) * MC2(k,j);
                  buf2 := buf2 + MO(i,k) * MK2(k,j);
               end loop;
               MA(i,j) := buf1 + d2*buf2;
            end loop;
         end loop;

         Synchronization.CalcSignal;

         Put_Line ("T2 finished");

      end T2;

      task T3 is
      end T3;

      task body T3 is
         MK3, MC3:Matrix;
         d3, buf1, buf2 :Integer;
      begin

         Put_Line ("T3 started");

         InputSimpleMatrix(MC);
         InputSimpleMatrix(MO);

         SharedResourse.SetMC(MC);

         Synchronization.InputSignal;

         Synchronization.WaitForInput;

         MC3 := SharedResourse.CopyMC;
         MK3 := SharedResourse.CopyMK;
         d3 := SharedResourse.Copyd;

         for i in 2*H+1..3*H loop
            for j in 1..N loop
               buf1 :=0;
               buf2 :=0;
               for k in 1..N loop
                  buf1 := buf1 + MB(i,k) * MC3(k,j);
                  buf2 := buf2 + MO(i,k) * MK3(k,j);
               end loop;
               MA(i,j) := buf1 + d3*buf2;
            end loop;
         end loop;

         Synchronization.CalcSignal;

         Put_Line ("T3 finished");
      end T3;

      task T4 is
      end T4;

      task body T4 is
         MK4, MC4:Matrix;
         d4, buf1, buf2 :Integer;
      begin

         Put_Line ("T4 started");

         InputSimpleMatrix(MK);
         d:=1;

         SharedResourse.Setd(d);
         SharedResourse.SetMK(MK);

         Synchronization.InputSignal;

         Synchronization.WaitForInput;

         MC4 := SharedResourse.CopyMC;
         MK4 := SharedResourse.CopyMK;
         d4 := SharedResourse.Copyd;

         for i in 3*H+1..N loop
            for j in 1..N loop
               buf1 :=0;
               buf2 :=0;
               for k in 1..N loop
                  buf1 := buf1 + MB(i,k) * MC4(k,j);
                  buf2 := buf2 + MO(i,k) * MK4(k,j);
               end loop;
               MA(i,j) := buf1 + d4*buf2;
            end loop;
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

