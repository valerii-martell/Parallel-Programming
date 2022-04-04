------------------------Main program------------------------------
--Programming for parallel computer systems
--Laboratory work #5. Ada. Protected Units
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--20.04.2017
--Task: MA = d*(MZ*MK) + min(Z)*MT
------------------------------------------------------------------

with Ada.Text_IO, Ada.Integer_text_iO, Ada.Synchronous_Task_Control, Data;
use Ada.Text_IO, Ada.Integer_text_iO, Ada.Synchronous_Task_Control;

procedure Main is

   N: Integer :=8;
   P: Integer :=4;
   H: Integer:= N/P;

   package MonitorsData is new Data(N);
   use MonitorsData;

   Z : Vect;
   MA, MZ, MT, MK: Matrix;
   d : Integer;
   ------------------------------------------------------------------

   ------------------------------------------------------------------
   protected Synchronization is
      entry WaitForInput;
      entry WaitForMin;
      entry WaitForCalc;
      procedure InputSignal;
      procedure MinSignal;
      procedure CalcSignal;

   private
      inputFlag:Natural:=0;
      minFlag:Natural:=0;
      calcFlag:Natural:=0;

   end Synchronization;

   protected SharedResourse is
      procedure setMin(data : in Integer);
      procedure setMK(data : in Matrix);
      procedure setd(data : in Integer);

      function CopyMin return Integer;
      function Copyd return Integer;
      function CopyMK return Matrix;

   private
      d: Integer;
      min: Integer := Integer'Last;
      MK:Matrix;

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

      procedure MinSignal is
      begin
         minFlag := minFlag + 1;
      end MinSignal;

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

      entry WaitForMin
        when minFlag = 4 is
      begin
         null;
      end WaitForMin;

   end Synchronization;


   protected body SharedResourse is

      procedure setMin(data : in Integer) is
      begin
         if data <= min then
            min := data;
         end if;
      end setMin;

      procedure setd(data : in Integer) is
      begin
         d := data;
      end setd;

      procedure setMK(data : in Matrix) is
      begin
         MK:=data;
      end setMK;

      function Copyd return Integer is
      begin
         return d;
      end Copyd;

      function CopyMin return Integer is
      begin
         return min;
      end CopyMin;
      function CopyMK return Matrix is
      begin
         return MK;
      end CopyMK;

   end SharedResourse;
   ------------------------------------------------------------------

   ------------------------------------------------------------------
   procedure StartTasks  is
      ------------------------------------------------------------------

      ------------------------------------------------------------------
         task T1;
         MK1:Matrix;
         d1:Integer;
         m1:Integer;
         task body T1 is
         begin

            Put_Line ("T1 started");

            InputSimpleMatrix(MK);
            InputSimpleMatrix(MT);

            SharedResourse.setMK(MK);

            Synchronization.InputSignal;

            Synchronization.WaitForInput;

            m1 := Min(Z, 1, H);

            SharedResourse.setMin(m1);

            Synchronization.MinSignal;

            Synchronization.WaitForMin;

            m1 := SharedResourse.CopyMin;
            MK1 := SharedResourse.CopyMK;
            d1 := SharedResourse.Copyd;

            for i in 1..H loop
               for j in 1..N loop
                  MA(i,j) :=0;
                  for k in 1..N loop
                     MA(i,j) := MA(i,j) + MZ(i,k) * MK1(k,j);
                  end loop;
                  MA(i,j) := d1*MA(i,j) + m1*MT(i,j);
               end loop;
            end loop;

            Synchronization.CalcSignal;

            Put_Line ("T1 finished");
         end T1;

         task T2;
         MK2:Matrix;
         d2:Integer;
         m2:Integer;
         task body T2 is
         begin

            Put_Line ("T2 started");

            Synchronization.WaitForInput;

            m2 := Min(Z, H+1, 2*H);

            SharedResourse.setMin(m2);

            Synchronization.MinSignal;

            Synchronization.WaitForMin;

            m2 := SharedResourse.CopyMin;
            MK2 := SharedResourse.CopyMK;
            d2 := SharedResourse.Copyd;

            for i in H+1..2*H loop
               for j in 1..N loop
                  MA(i,j) :=0;
                  for k in 1..N loop
                     MA(i,j) := MA(i,j) + MZ(i,k) * MK2(k,j);
                  end loop;
                  MA(i,j) := d2*MA(i,j) + m2*MT(i,j);
               end loop;
            end loop;

            Synchronization.CalcSignal;

            Put_Line ("T2 finished");
         end T2;

         task T3;
         MK3:Matrix;
         d3:Integer;
         m3:Integer;
         task body T3 is
         begin

            Put_Line ("T3 started");

            InputSimpleMatrix(MZ);
            d := 1;

            SharedResourse.setd(d);

            Synchronization.InputSignal;

            Synchronization.WaitForInput;

            m3 := Min(Z, 2*H+1, 3*H);

            SharedResourse.setMin(m3);

            Synchronization.MinSignal;

            Synchronization.WaitForMin;

            m3 := SharedResourse.CopyMin;
            MK3 := SharedResourse.CopyMK;
            d3 := SharedResourse.Copyd;

            for i in 2*H+1..3*H loop
               for j in 1..N loop
                  MA(i,j) :=0;
                  for k in 1..N loop
                     MA(i,j) := MA(i,j) + MZ(i,k) * MK3(k,j);
                  end loop;
                  MA(i,j) := d3*MA(i,j) + m3*MT(i,j);
               end loop;
            end loop;

            Synchronization.CalcSignal;

            Put_Line ("T3 finished");
         end T3;

         task T4;
         MK4:Matrix;
         d4:Integer;
         m4:Integer;
         task body T4 is
         begin

            Put_Line ("T4 started");

         InputSimpleVect(Z);

            Synchronization.InputSignal;

            Synchronization.WaitForInput;

            m4 := Min(Z, 3*H+1, N);

            SharedResourse.setMin(m4);

            Synchronization.MinSignal;

            Synchronization.WaitForMin;

            m4 := SharedResourse.CopyMin;
            MK4 := SharedResourse.CopyMK;
         d4 := SharedResourse.Copyd;

            for i in 3*H+1..N loop
               for j in 1..N loop
                  MA(i,j) :=0;
                  for k in 1..N loop
                     MA(i,j) := MA(i,j) + MZ(i,k) * MK4(k,j);
                  end loop;
                  MA(i,j) := d4*MA(i,j) + m4*MT(i,j);
               end loop;
            end loop;

         Synchronization.WaitForCalc;

         New_Line;
         Put_Line("MA = ");
         ShowMatr(MA);
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
