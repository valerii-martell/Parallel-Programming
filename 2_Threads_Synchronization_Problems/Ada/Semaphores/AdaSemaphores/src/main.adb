with Data, Ada.Text_IO, Ada.Integer_Text_IO, System.Multiprocessors, Ada.Synchronous_Task_Control;
use Ada.Text_IO, Ada.Integer_Text_IO, System.Multiprocessors, Ada.Synchronous_Task_Control;

----------------Main program---------------
--Programming for parallel computer systems
--Laboratory work #1. Ada. Semaphores
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--19.02.2017
--Task: MA = d*MO + e*(MR*MT)
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
   MA, MO, MR, MT : Matrix;
   d, e : Integer;


   CPU_0 :CPU_Range:=0;
   CPU_1 :CPU_Range:=1;

   procedure Start is
      task T1 is
         --pragma Priority(9);
         pragma Task_Name ("T1");
         pragma Storage_Size(999999999);
         pragma CPU (CPU_0);
      end T1;

      -- Task body
      task body T1 is
         MR1 : Matrix;
         d1, e1 : Integer;
      begin
         --Start report
         New_Line;
         put("T1 started!");
         --Input MO
         InputSimpleMatrix(MO);

         --Signal about the end of data entry
         Set_True(S1);

         --Wait signal from T2 about end of data entry
         Suspend_Until_True(S2);

         --Critical point
         Suspend_Until_True(SU);
         d1 := d;
         e1 := e;
         MR1 := MR;
         Set_True(SU);

         --Computing
         AddMatr(MA, MultNumb(d1, MO, 1, h), MultNumb(e1, MultMatr(MR1, MT, 1, h), 1, h), 1, h);

         --Wait signal from T2 about end of calculation
         Suspend_Until_True(S3);

         -- Show results
         New_Line;
         Put("MA = ");
         showMatr(MA);

         --Finish report
         New_Line;
         put("T1 finished!");

      end T1;

      task T2 is
         --pragma Priority(9);
         pragma Task_Name ("T2");
         pragma Storage_Size(999999999);
         pragma CPU (CPU_1);
      end T2;

      -- Task body
      task body T2 is
         MR2 : Matrix;
         d2, e2 : Integer;
      begin
         --Start report
         New_Line;
         Put("T2 started!");

         --Input d,e,MR,MT
         d := 1;
         e := 1;
         InputSimpleMatrix(MR);
         --ShowMatr(MR);
         InputSimpleMatrix(MT);
         --ShowMatr(MT);

         --Signal about the end of data entry
         Set_True(S2);

         --Wait signal from T1 about end of data entry
         Suspend_Until_True(S1);

         --Critical point
         Suspend_Until_True(SU);
         d2 := d;
         e2 := e;
         MR2 := MR;
         Set_True(SU);

         --Computing
         AddMatr(MA, MultNumb(e2, MO, h-1, n), MultNumb(e2, MultMatr(MR2, MT, h-1, n), h-1, n), h-1, n);

         --Signal about end of calculation
         Set_True(S3);

         --Finish report
         New_Line;
         put("T2 finished!");

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
   if N>10 then
      New_Line;
      Put("Results will not be displayed.");
   end if;
   Start;

end Main;
