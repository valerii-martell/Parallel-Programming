with Data, Ada.Text_IO, Ada.Integer_Text_IO, System.Multiprocessors, Ada.Synchronous_Task_Control;
use Ada.Text_IO, Ada.Integer_Text_IO, System.Multiprocessors, Ada.Synchronous_Task_Control;

----------------Main program---------------
--Programming for parallel computer systems
--Laboratory work #1. Ada. Semaphores
--Valerii Martell
--NTUU "KPI"
--FICT IO-41
--01.03.2017
--Task: A = sort(B)*MO + E*(MT*MK)*d
-------------------------------------------

procedure Main is

   --Dimension (N)--
   n : Integer :=4;
   --Processors count (P)--
   p : Integer :=2;
   --Parts of elements (H)--
   h : Integer := n/p;
   --Semaphores
   SU, S1, S2, S3, S4 : Suspension_Object;
   --Initialization package--
   package SemaphoresData is new Data(n);
   use SemaphoresData;
   --Global variables
   MO, MK, MT : Matrix;
   A, B, E, K : Vect;
   d : Integer;


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
         E1, K1 : Vect;
         MK1 : Matrix;
         d1,m : Integer;
      begin
         --Start report
         New_Line;
         put("T1 started!");
         --Input MO
         InputSimpleMatrix(MO);
         InputSimpleMatrix(MT);
         InputSimpleMatrix(MK);
         InputSimpleVect(B);
         InputSimpleVect(E);
         d:=1;
         --B(1):=5;
         --B(2):=4;
         --B(3):=10;
         --B(4):=2;

         --Signal about the end of data entry
         Set_True(S1);

         --sort(half-B)
         for i in 1..h loop
            K(i):= B(i);
         end loop;
         for i in reverse 1..h loop
            for j in 1..(i-1) loop
               if K(j) > K(j+1) then
                  m := K(j);
                  K(j):=K(j+1);
                  K(j+1):=m;
               end if;
            end loop;
         end loop;

         --ShowVect(K);

         --Wait signal from T2 about end of sort
         Suspend_Until_True(S2);

         --Sort B
         for i in 1..h loop
            for j in h+1..n loop
               if K(i) > K(j) then
                  m := K(j);
                  K(j):=K(i);
                  K(i):=m;
               end if;
            end loop;
         end loop;

         --Signal about the end of sort
         Set_True(S3);

         --Critical point
         Suspend_Until_True(SU);
         d1 := d;
         E1 := CopyVect(E);
         K1 := CopyVect(K);
         MK1 := CopyMatr(MK);
         Set_True(SU);

         --Computing
         AddVect(A, MultVectMatr(K1, MO, 1, h), MultNumb(d1, MultVectMatr(E1, MultMatr(MK1, MT, 1, h), 1, h), 1, h), 1, h);

         --Wait signal from T2 about end of calculation
         Suspend_Until_True(S4);

         -- Show results
         New_Line;
         Put("A = ");
         ShowVect(A);

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
         E2, K2 : Vect;
         MK2 : Matrix;
         d2,m : Integer;
      begin
         --Start report
         New_Line;
         Put("T2 started!");

         --Wait signal from T1 about end of data entry
         Suspend_Until_True(S1);

         --sort(half-B)
         for i in h+1..n loop
            K(i):= B(i);
         end loop;
         for i in reverse h+1..n loop
            for j in h+1..(i-1) loop
               if K(j) > K(j+1) then
                  m := K(j);
                  K(j):=K(j+1);
                  K(j+1):=m;
               end if;
            end loop;
         end loop;



         --Put(K(3));
         --Put(K(4));

         --Signal about end of sort
         Set_True(S2);

         --Wait signal from T1 about end of sort
         Suspend_Until_True(S3);

         --Critical point
         Suspend_Until_True(SU);
         d2 := d;
         E2 := CopyVect(E);
         K2 := CopyVect(K);
         MK2 := CopyMatr(MK);
         Set_True(SU);

         --Computing
         AddVect(A, MultVectMatr(K2, MO, h-1, n), MultNumb(d2, MultVectMatr(E2, MultMatr(MK2, MT, h-1, n), h-1, n), h-1, n), h-1, n);

         --Signal about end of calculation
         Set_True(S4);

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
