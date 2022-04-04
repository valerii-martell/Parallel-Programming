------------------------Main program------------------------------
--Programming for parallel computer systems
--Course work part #1. System with shared memory. Ada. Protected Units
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--25.04.2017
--Task: MA = (MB*MC)*e + max(Z)*MO
------------------------------------------------------------------

with Data, Ada.Text_IO, Ada.Integer_text_iO, Ada.Synchronous_Task_Control, Ada.Calendar;
use Ada.Text_IO, Ada.Integer_text_iO, Ada.Synchronous_Task_Control, Ada.Calendar;

procedure Main is

   N: Integer :=12;
   P: Integer :=6;
   H: Integer:= N/P;

   package MonitorsData is new Data(N);
   use MonitorsData;

   Z : Vect;
   MA, MB, MC, MO: Matrix;
   e : Integer;

   StartTime, FinishTime: Time;
   DiffTime: Duration;

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

   end Synchronization;

   protected SharedResourse is
      procedure SetMax(data : in Integer);
      procedure SetMC(data : in Matrix);
      procedure Sete(data : in Integer);

      function CopyMax return Integer;
      function Copye return Integer;
      function CopyMC return Matrix;

   private
      e: Integer;
      max: Integer := Integer'First;
      MC:Matrix;

   end SharedResourse;

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
        when calcFlag = 5 is
      begin
         null;
      end WaitForCalc;

      entry WaitForMax
        when maxFlag = 6 is
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

      procedure Sete(data : in Integer) is
      begin
         e := data;
      end Sete;

      procedure SetMC(data : in Matrix) is
      begin
         MC:=data;
      end SetMC;

      function Copye return Integer is
      begin
         return e;
      end Copye;

      function CopyMax return Integer is
      begin
         return max;
      end CopyMax;

      function CopyMC return Matrix is
      begin
         return MC;
      end CopyMC;

   end SharedResourse;

   procedure StartTasks  is

      task T1;
      MC1:Matrix;
      e1:Integer;
      m1:Integer;
      task body T1 is
      begin

         Put_Line ("T1 started");

         --Input MB
         InputSimpleMatrix(MB);
         InputSimpleMatrix(MO);

         Synchronization.InputSignal;

         Synchronization.WaitForInput;

         m1 := Max(Z, 1, H);

         SharedResourse.SetMax(m1);

         Synchronization.MaxSignal;

         Synchronization.WaitForMax;

         m1 := SharedResourse.CopyMax;
         MC1 := SharedResourse.CopyMC;
         e1 := SharedResourse.Copye;

         for i in 1..H loop
            for j in 1..N loop
               MA(i,j) :=0;
               for k in 1..N loop
                  MA(i,j) := MA(i,j) + MB(i,k) * MC1(k,j);
               end loop;
               MA(i,j) := e1*MA(i,j) + m1*MO(i,j);
            end loop;
         end loop;

         Synchronization.CalcSignal;

         Put_Line ("T1 finished");
      end T1;

      task T2;
      MC2:Matrix;
      e2:Integer;
      m2:Integer;
      task body T2 is
      begin

         Put_Line ("T2 started");

         Synchronization.WaitForInput;

         m2 := Max(Z, H+1, 2*H);

         SharedResourse.SetMax(m2);

         Synchronization.MaxSignal;

         Synchronization.WaitForMax;

         m2 := SharedResourse.CopyMax;
         MC2 := SharedResourse.CopyMC;
         e2 := SharedResourse.Copye;

         for i in H+1..2*H loop
            for j in 1..N loop
               MA(i,j) :=0;
               for k in 1..N loop
                  MA(i,j) := MA(i,j) + MB(i,k) * MC2(k,j);
               end loop;
               MA(i,j) := e2*MA(i,j) + m2*MO(i,j);
            end loop;
         end loop;

         Synchronization.CalcSignal;

         Put_Line ("T2 finished");
      end T2;

      task T3;
      MC3:Matrix;
      e3:Integer;
      m3:Integer;
      task body T3 is
      begin

         Put_Line ("T3 started");

         --Input MC
         InputSimpleMatrix(MC);

         SharedResourse.SetMC(MC);

         Synchronization.InputSignal;

         Synchronization.WaitForInput;

         m3 := Max(Z, 2*H+1, 3*H);

         SharedResourse.SetMax(m3);

         Synchronization.MaxSignal;

         Synchronization.WaitForMax;

         m3 := SharedResourse.CopyMax;
         MC3 := SharedResourse.CopyMC;
         e3 := SharedResourse.Copye;

         for i in 2*H+1..3*H loop
            for j in 1..N loop
               MA(i,j) :=0;
               for k in 1..N loop
                  MA(i,j) := MA(i,j) + MB(i,k) * MC3(k,j);
               end loop;
               MA(i,j) := e3*MA(i,j) + m3*MO(i,j);
            end loop;
         end loop;

         Synchronization.CalcSignal;

         Put_Line ("T3 finished");
      end T3;

      task T4;
      MC4:Matrix;
      e4:Integer;
      m4:Integer;
      task body T4 is
      begin

         Put_Line ("T4 started");

         Synchronization.WaitForInput;

         m4 := Max(Z, 3*H+1, N);

         SharedResourse.SetMax(m4);

         Synchronization.MaxSignal;

         Synchronization.WaitForMax;

         m4 := SharedResourse.CopyMax;
         MC4 := SharedResourse.CopyMC;
         e4 := SharedResourse.Copye;

         for i in 3*H+1..4*H loop
            for j in 1..N loop
               MA(i,j) :=0;
               for k in 1..N loop
                  MA(i,j) := MA(i,j) + MB(i,k) * MC4(k,j);
               end loop;
               MA(i,j) := e4*MA(i,j) + m4*MO(i,j);
            end loop;
         end loop;

         Synchronization.CalcSignal;

         Put_Line ("T4 finished");
      end T4;

      task T5;
      MC5:Matrix;
      e5:Integer;
      m5:Integer;
      task body T5 is
      begin

         Put_Line ("T5 started");

         --Input e, Z
         e:=1;
         InputSimpleVect(Z);
         --Z(2):=2;

         SharedResourse.Sete(e);

         Synchronization.InputSignal;

         Synchronization.WaitForInput;

         m5 := Max(Z, 4*H+1, 5*H);

         SharedResourse.SetMax(m5);

         Synchronization.MaxSignal;

         Synchronization.WaitForMax;

         m5 := SharedResourse.CopyMax;
         MC5 := SharedResourse.CopyMC;
         e5 := SharedResourse.Copye;

         for i in 4*H+1..5*H loop
            for j in 1..N loop
               MA(i,j) :=0;
               for k in 1..N loop
                  MA(i,j) := MA(i,j) + MB(i,k) * MC5(k,j);
               end loop;
               MA(i,j) := e5*MA(i,j) + m5*MO(i,j);
            end loop;
         end loop;

         Synchronization.CalcSignal;

         Put_Line ("T5 finished");
      end T5;

      task T6;
      MC6:Matrix;
      e6:Integer;
      m6:Integer;
      task body T6 is
      begin

         Put_Line ("T6 started");

         Synchronization.WaitForInput;

         m6 := Max(Z, 5*H+1, N);

         SharedResourse.SetMax(m6);

         Synchronization.MaxSignal;

         Synchronization.WaitForMax;

         m6 := SharedResourse.CopyMax;
         MC6 := SharedResourse.CopyMC;
         e6 := SharedResourse.Copye;

         for i in 5*H+1..N loop
            for j in 1..N loop
               MA(i,j) :=0;
               for k in 1..N loop
                  MA(i,j) := MA(i,j) + MB(i,k) * MC6(k,j);
               end loop;
               MA(i,j) := e6*MA(i,j) + m6*MO(i,j);
            end loop;
         end loop;

         Synchronization.WaitForCalc;

         New_Line;
         Put("MA = ");
         New_Line;
         ShowMatr(MA);
         New_Line;

         Put_Line ("T6 finished");

         FinishTime := Clock;
         DiffTime := FinishTime - StartTime;

         Put("Time : ");
         Put(Integer(DiffTime), 1);
         Put_Line("");
      end T6;


      begin
         null;
      end StartTasks;


begin
   StartTime := Clock;
   Put_Line ("Main thread started");
   StartTasks;
   Put_Line ("Main thread finished");

end Main;
