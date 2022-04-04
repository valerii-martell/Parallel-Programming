with Data, Ada.Text_IO, Ada.Integer_Text_IO, System.Multiprocessors, Ada.Synchronous_Task_Control;
use Ada.Text_IO, Ada.Integer_Text_IO, System.Multiprocessors, Ada.Synchronous_Task_Control;

----------------Main program---------------
--Programming for parallel computer systems
--Laboratory work #1. Ada. Semaphores
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--19.02.2017
--Task: MA = min(MO)*MS + e*(ME*MT)
-------------------------------------------

procedure Main is

   --Dimension (N)--
   n : Integer :=4;
   --Processors count (P)--
   p : Integer :=2;
   --Parts of elements (H)--
   h : Integer := n/p;
   --Semaphores
   SU1, SU2, S1, S2, S3, S4, S5 : Suspension_Object;
   --Initialization package--
   package SemaphoresData is new Data(n);
   use SemaphoresData;
   --Global variables
   MA, MO, MS, ME, MT : Matrix;
   e : Integer;
   a : Integer :=  Integer'Last;


   --CPU_0 :CPU_Range:=0;
   --CPU_1 :CPU_Range:=1;

   procedure Start is
      task T1 is
         --pragma Priority(9);
         --pragma Task_Name ("T1");
         --pragma Storage_Size(999999999);
         --pragma CPU (CPU_0);
      end T1;

      -- Task body
      task body T1 is
         MT1 : Matrix;
         a1, e1, cell : Integer;
      begin
         --Start report
         New_Line;
         put("T1 started!");

         --Input data
         InputSimpleMatrix(MO);
         --MO(3,2):=10;
         InputSimpleMatrix(ME);
         InputSimpleMatrix(MT);

         --Signal about the end of data entry
         Set_True(S1);

         --Wait signal from T2 about end of data entry
         Suspend_Until_True(S2);

         --min
         a1:=MO(1,1);
         for i in 1..H loop
            for j in 1..N loop
               if MO(i,j)<a1 then
                  a1:=MO(i,j);
               end if;
            end loop;
         end loop;

         --Critical point
         Suspend_Until_True(SU1);
         if a1 < a then
            a:=a1;
         end if;
         Set_True(SU1);

         --Signal about the end of min
         Set_True(S3);

         --Wait signal from T2 about end of min
         Suspend_Until_True(S4);

         --Critical point
         Suspend_Until_True(SU2);
         a1 := a;
         e1 := e;
         MT1 := MT;
         Set_True(SU2);

         --Computing
         for i in 1..H loop
            for j in 1..N loop
               cell := 0;
               for k in 1..N loop
                  cell := cell + ME(i,k)*MT1(k,j);
               end loop;
               MA(i,j) := e1*cell + a1*MS(i,j);
            end loop;
         end loop;

         --Signal about end of calculation
         Set_True(S5);

         --Finish report
         New_Line;
         put("T1 finished!");

      end T1;

      task T2 is
         --pragma Priority(9);
         --pragma Task_Name ("T2");
         --pragma Storage_Size(999999999);
         --pragma CPU (CPU_1);
      end T2;

      -- Task body
      task body T2 is
         MT2 : Matrix;
         a2, e2, cell : Integer;
      begin
         --Start report
         New_Line;
         Put("T2 started!");

         --Input data
         e := 1;
         InputSimpleMatrix(MS);

         --Signal about the end of data entry
         Set_True(S2);

         --Wait signal from T1 about end of data entry
         Suspend_Until_True(S1);

         --min
         a2:=MO(H+1,1);
         for i in H+1..N loop
            for j in 1..N loop
               if MO(i,j)<a2 then
                  a2:=MO(i,j);
               end if;
            end loop;
         end loop;

         --Critical point
         Suspend_Until_True(SU1);
         if a2 < a then
            a:=a2;
         end if;
         Set_True(SU1);

         --Signal about the end of min
         Set_True(S4);

         --Wait signal from T2 about end of min
         Suspend_Until_True(S3);

         --Critical point
         Suspend_Until_True(SU2);
         a2 := a;
         e2 := e;
         MT2 := MT;
         Set_True(SU2);

         --Computing
         for i in H+1..N loop
            for j in 1..N loop
               cell := 0;
               for k in 1..N loop
                  cell := cell + ME(i,k)*MT2(k,j);
               end loop;
               MA(i,j) := e2*cell + a2*MS(i,j);
            end loop;
         end loop;

         --Wait signal from T2 about end of calculation
         Suspend_Until_True(S5);

         -- Show results
         New_Line;
         Put("MA = ");
         showMatr(MA);

         --Finish report
         New_Line;
         put("T2 finished!");

      end T2;

   begin
      Set_True(SU1);
      Set_True(SU2);
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
