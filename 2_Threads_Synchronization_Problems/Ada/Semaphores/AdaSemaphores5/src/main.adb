with Data, Ada.Text_IO, Ada.Integer_Text_IO, System.Multiprocessors, Ada.Synchronous_Task_Control;
use Ada.Text_IO, Ada.Integer_Text_IO, System.Multiprocessors, Ada.Synchronous_Task_Control;

----------------Main program---------------
--Programming for parallel computer systems
--Laboratory work #1. Ada. Semaphores
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--29.04.2017
--Task: A = sort(B+e*C(MZ*MK))
-------------------------------------------

procedure Main is

   --Dimension (N)--
   n : Integer :=8;
   --Processors count (P)--
   p : Integer :=2;
   --Parts of elements (H)--
   h : Integer := n/p;
   --Semaphores
   SU, S1, S2 : Suspension_Object;
   --Initialization package--
   package SemaphoresData is new Data(n);
   use SemaphoresData;
   --Global variables
   MZ, MK : Matrix;
   A, B, C, S : Vect;
   e : Integer;


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
         MK1, MZMK :  Matrix;
         C1 : Vect;
         e1, buf, i1, i2, current : Integer;
      begin
         --Start report
         New_Line;
         Put("T1 started!");

         --Input data
         e := 1;
         InputSimpleMatrix(MZ);
         InputSimpleMatrix(MK);
         InputSimpleVect(C);
         InputSimpleVect(B);
         --B(8) := 10;
         --B(1) := 5;

         --Signal about the end of data entry
         Set_True(S1);

         --Critical point
         Suspend_Until_True(SU);
         e1 := e;
         C1 := C;
         MK1 := MK;
         Set_True(SU);

         --Computing
         for i in 1..H loop
            for j in 1..N loop
               buf := 0;
               for k in 1..N loop
                  buf := buf + MZ(i,k)*MK1(k,j);
               end loop;
               MZMK(i,j) := buf;
            end loop;
            buf := 0;
            for l in 1..N loop
               buf := buf + C1(l)*MZMK(i,l);
            end loop;
            S(i) := B(i) + e1*buf;
         end loop;

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

         --Wait signal from T2 about end of sort
         Suspend_Until_True(S2);

         --Merge sort
         i1 := 1;
         i2 := H+1;
         current := 1;
         while i1 <= H and i2 <= N loop
            if S(i1) > S(i2) then
               A(current) := S(i2);
               i2 := i2+1;
               current := current+1;
            else
               A(current) := S(i1);
               i1 := i1+1;
               current := current+1;
            end if;
         end loop;

         if i1 = H+1 then
            while i2 <= N loop
               A(current) := S(i2);
               i2 := i2+1;
               current := current+1;
            end loop;
         else
            while i1 <= H loop
               A(current) := S(i1);
               i1 := i1+1;
               current := current+1;
            end loop;
         end if;

         -- Show results
         New_Line;
         Put("A = ");
         ShowVect(A);

         --Finish report
         New_Line;
         Put_Line("T1 finished!");

      end T1;

      task T2 is
         --pragma Priority(9);
         --pragma Task_Name (T2);
         --pragma Storage_Size(999999999);
         --pragma CPU (CPU_1);
      end T2;

      -- Task body
      task body T2 is
         MK2, MZMK :  Matrix;
         C2 : Vect;
         e2, buf : Integer;
      begin
         --Start report
         New_Line;
         Put("T2 started!");

         --Wait signal from T1 about end of data entry
         Suspend_Until_True(S1);

         --Critical point
         Suspend_Until_True(SU);
         e2 := e;
         C2 := C;
         MK2 := MK;
         Set_True(SU);

         --Computing
         for i in H+1..N loop
            for j in 1..N loop
               buf := 0;
               for k in 1..N loop
                  buf := buf + MZ(i,k)*MK2(k,j);
               end loop;
               MZMK(i,j) := buf;
            end loop;
            buf := 0;
            for l in 1..N loop
               buf := buf + C2(l)*MZMK(i,l);
            end loop;
            S(i) := B(i) + e2*buf;
         end loop;

         --Sort H
         for i in reverse H+1..N loop
            for j in 1..(i-1) loop
               if S(j) > S(j+1) then
                  buf := S(j);
                  S(j):=S(j+1);
                  S(j+1):=buf;
               end if;
            end loop;
         end loop;

         --Signal about end of sort
         Set_True(S2);

         --Finish report
         New_Line;
         Put_Line("T2 finished!");

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
