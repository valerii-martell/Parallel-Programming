with Data, Ada.Text_IO, Ada.Integer_Text_IO, System.Multiprocessors, Ada.Synchronous_Task_Control;
use Ada.Text_IO, Ada.Integer_Text_IO, System.Multiprocessors, Ada.Synchronous_Task_Control;

----------------Main program---------------
--Programming for parallel computer systems
--Laboratory work #1. Ada. Semaphores
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--29.04.2017
--Task: A = e*B + C*(MO*(MK*MT))
-------------------------------------------

procedure Main is

   --Dimension (N)--
   N : Integer :=4;
   --Processors count (P)--
   P : Integer :=2;
   --Parts of elements (H)--
   H : Integer := N/P;
   --Semaphores
   SU, S1, S2, S3 : Suspension_Object;
   --Initialization package--
   package SemaphoresData is new Data(n);
   use SemaphoresData;
   --Global variables
   MO, MK, MT : Matrix;
   A, B, C : Vect;
   e : Integer;


   --CPU_0 : CPU_Range :=0;
   --CPU_1 : CPU_Range :=1;

   procedure Start is
      task T1 is
         --pragma Priority(9);
         --pragma Task_Name (T1);
         --pragma Storage_Size(999999999);
         --pragma CPU (CPU_0);
      end T1;

      -- Task body
      task body T1 is
         MT1, MO1, MKMT, MOMKMT :  Matrix;
         C1 : Vect;
         e1, cell : Integer;
      begin
         --Start report
         New_Line;
         Put("T1 started!");

         --Input MO, B
         InputSimpleMatrix(MO);
         InputSimpleVect(B);

         --Signal about the end of data entry
         Set_True(S1);

         --Wait signal from T2 about end of data entry
         Suspend_Until_True(S2);

         --Critical point
         Suspend_Until_True(SU);
         e1 := e;
         C1 := C;
         MO1 := MO;
         MT1 := MT;
         Set_True(SU);

         --Computing
         for i in 1..H loop
            for j in 1..N loop
               cell := 0;
               for k in 1..N loop
                  cell := cell + MK(i,k)*MT1(k,j);
               end loop;
               MKMT(i,j) := cell;
            end loop;
         end loop;

         for i in 1..H loop
            for j in 1..N loop
               cell := 0;
               for k in 1..N loop
                  cell := cell + MKMT(i,k)*MO1(k,j);
               end loop;
               MOMKMT(i,j) := cell;
            end loop;
         end loop;

         for i in 1..H loop
            cell := 0;
            for j in 1..N loop
               cell := cell + C1(j) * MOMKMT(i,j);
            end loop;
            A(i) :=  B(i)*e1 + cell;
         end loop;

         --Wait signal from T2 about end of calculation
         Suspend_Until_True(S3);

         -- Show results
         New_Line;
         Put("A = ");
         ShowVect(A);

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
         MT2, MO2, MKMT, MOMKMT :  Matrix;
         C2 : Vect;
         e2, cell :  Integer;
      begin
         --Start report
         New_Line;
         Put("T2 started!");

         --Input e,C,MK,MT
         e := 1;
         InputSimpleMatrix(MK);
         --ShowMatr(MR);
         InputSimpleMatrix(MT);
         --ShowMatr(MT);
         InputSimpleVect(C);

         --Signal about the end of data entry
         Set_True(S2);

         --Wait signal from T1 about end of data entry
         Suspend_Until_True(S1);

         --Critical point
         Suspend_Until_True(SU);
         e2 := e;
         C2 := C;
         MO2 := MO;
         MT2 := MT;

         Set_True(SU);

         --Computing
         for i in H+1..N loop
            for j in 1..N loop
               cell := 0;
               for k in 1..N loop
                  cell := cell + MK(i,k)*MT2(k,j);
               end loop;
               MKMT(i,j) := cell;
            end loop;
         end loop;

         for i in H+1..N loop
            for j in 1..N loop
               cell := 0;
               for k in 1..N loop
                  cell := cell + MKMT(i,k)*MO2(k,j);
               end loop;
               MOMKMT(i,j) := cell;
            end loop;
         end loop;

         for i in H+1..N loop
            cell := 0;
            for j in 1..N loop
               cell := cell + C2(j)*MOMKMT(i,j);
            end loop;
            A(i) :=  B(i)*e2 + cell;
         end loop;

         --Signal about end of calculation
         Set_True(S3);

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
