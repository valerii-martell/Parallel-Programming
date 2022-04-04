with Data, Ada.Text_IO, Ada.Integer_Text_IO, System.Multiprocessors, Ada.Synchronous_Task_Control;
use Ada.Text_IO, Ada.Integer_Text_IO, System.Multiprocessors, Ada.Synchronous_Task_Control;

----------------Main program---------------
--Programming for parallel computer systems
--Laboratory work #1. Ada. Semaphores
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--29.04.2017
--Task: MA = MB*MC + d*(MO*MK)
-------------------------------------------

procedure Main is

   --Dimension (N)--
   n : Integer :=4;
   --Processors count (P)--
   p : Integer :=2;
   --Parts of elements (H)--
   h : Integer := n/p;
   --Semaphores
   SU, S1, S2, S3 : Suspension_Object;
   --Initialization package--
   package SemaphoresData is new Data(n);
   use SemaphoresData;
   --Global variables
   MA, MB,MC, MO, MK : Matrix;
   d : Integer;


   --CPU_0 :CPU_Range:=0;
   --CPU_1 :CPU_Range:=1;

   procedure Start is
      task T1 is
         --pragma Priority(9);
         --pragma Task_Name (T1);
         --pragma Storage_Size(999999999);
         --pragma CPU (CPU_0);
      end T1;

      -- Task body
      task body T1 is
         MC1, MK1 :  Matrix;
         d1, buf1, buf2 : Integer;
      begin
         --Start report
         New_Line;
         Put("T1 started!");

         --Input MC, MK, d
         InputSimpleMatrix(MC);
         InputSimpleMatrix(MK);
         d := 1;

         --Signal about the end of data entry
         Set_True(S1);

         --Wait signal from T2 about end of data entry
         Suspend_Until_True(S2);

         --Critical point
         Suspend_Until_True(SU);
         d1 := d;
         MC1 := MC;
         MK1 := MK;
         Set_True(SU);

         --Computing
         for i in 1..H loop
            for j in 1..N loop
               buf1 := 0;
               buf2 := 0;
               for k in 1..N loop
                  buf1 := buf1 + MB(i,k)*MC1(k,j);
                  buf2 := buf2 + MO(i,k)*MK1(k,j);
               end loop;
               MA(i,j) := buf1 + d1*buf2;
            end loop;
         end loop;

         --Signal about end of calculation
         Set_True(S3);

         --Finish report
         New_Line;
         Put("T1 finished!");

      end T1;

      task T2 is
         --pragma Priority(9);
         --pragma Task_Name (T2);
         --pragma Storage_Size(999999999);
         --pragma CPU (CPU_1);
      end T2;

      -- Task body
      task body T2 is
         MC2, MK2 :  Matrix;
         d2, buf1, buf2 : Integer;
      begin
         --Start report
         New_Line;
         Put("T2 started!");

         --Input MO, MB
         InputSimpleMatrix(MO);
         --ShowMatr(MR);
         InputSimpleMatrix(MB);
         --ShowMatr(MT);

         --Signal about the end of data entry
         Set_True(S2);

         --Wait signal from T1 about end of data entry
         Suspend_Until_True(S1);

         --Critical point
         Suspend_Until_True(SU);
         d2 := d;
         MC2 := MC;
         MK2 := MK;
         Set_True(SU);

         --Computing
         for i in H+1..N loop
            for j in 1..N loop
               buf1 := 0;
               buf2 := 0;
               for k in 1..N loop
                  buf1 := buf1 + MB(i,k)*MC2(k,j);
                  buf2 := buf2 + MO(i,k)*MK2(k,j);
               end loop;
               MA(i,j) := buf1 + d2*buf2;
            end loop;
         end loop;

         --Wait signal from T1 about end of calculation
         Suspend_Until_True(S3);

         -- Show results
         New_Line;
         Put("MA = ");
         ShowMatr(MA);

         --Finish report
         New_Line;
         Put("T2 finished!");

      end T2;

   begin
      Set_True(SU);
   end Start;

begin
   Put("Lab 1");
   New_Line;
   Put("Dimension of all vectors and matrix is ");
   Put(n);
   Put(" arguments.");
   if N > 10 then
      New_Line;
      Put("Results will not be displayed.");
   end if;
   Start;

end Main;
