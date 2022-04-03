with Data, Ada.Text_IO, Ada.Integer_Text_IO, System.Multiprocessors;
use Ada.Text_IO, Ada.Integer_Text_IO, System.Multiprocessors;
-------------Main program-----------
--Parallel and distributed computing
--Lab 1
--Valeriy Demchik
--NTUU "KPI"
--FICT IO-41
--19.09.2016
--F1: MC = MIN(A)*(MA*MD)
--F2: MK = TRANS(MA)*TRANS(MB*MM)+MX
--F3:  O = SORT(P)*(MR*MS)
-----------------------------------------

procedure Main is

   --Dimension (N)--
   n : Integer :=5;
   --Initialization package--
   package Lab1Data is new Data(n);
   use Lab1Data;

   CPU_0 :CPU_Range:=0;
   CPU_1 :CPU_Range:=1;

   -- Announcements tasks to perform functions F1
   task T1 is
      pragma Priority(9);
      pragma Task_Name ("T1");
      pragma Storage_Size(1000);
      pragma CPU (CPU_1);
   end T1;

   -- Task body
   task body T1 is
      A: Vect;
      MA,MD,MC: Matrix;

   begin

      delay 1.0;

      --Start report
      New_Line;
      put("T1 started!");

      --Input F1 data
      New_Line;
      Put("Arguments for F1");

      New_Line;
      Put("Vector A");
      New_Line;
      InputRandomVect(A);
      ShowVect(A);

      New_Line;
      Put("Matrix MA");
      New_Line;
      InputRandomMatrix(MA);
      ShowMatr(MA);

      New_Line;
      Put("Matrix MD");
      New_Line;
      InputRandomMatrix(MD);
      ShowMatr(MD);

      --Computing F1
      F1(A,MA,MD,MC);

      -- Show results
      New_Line;
      Put("F1 = ");
      showMatr(MC);

      --Finish report
      New_Line;
      put("T1 finished!");

   end T1;

   -- Announcements tasks to perform functions F2
   task T2 is
      pragma Priority(5);
      pragma Task_Name ("T2");
      pragma Storage_Size(1000);
      pragma CPU (CPU_0);
   end T2;

   -- Task body
   task body T2 is
      MA,MB,MM,MK,MX: Matrix;

   begin

      delay 5.0;

      --Start report
      New_Line;
      put("T2 started!");

      --Input F1 data
      New_Line;
      Put("Arguments for F2");

      New_Line;
      Put("Matrix MA");
      New_Line;
      InputRandomMatrix(MA);
      ShowMatr(MA);

      New_Line;
      Put("Matrix MB");
      New_Line;
      InputRandomMatrix(MB);
      ShowMatr(MB);

      New_Line;
      Put("Matrix MM");
      New_Line;
      InputRandomMatrix(MM);
      ShowMatr(MM);

      New_Line;
      Put("Matrix MX");
      New_Line;
      InputRandomMatrix(MX);
      ShowMatr(MX);

      --Computing F1
      F2(MA,MB,MM,MX,MK);

      -- Show results
      New_Line;
      Put("F2 = ");
      ShowMatr(MK);

      --Finish report
      New_Line;
      put("T2 finished!");

   end T2;

   -- Announcements tasks to perform functions F3
   task T3 is
      pragma Priority(1);
      pragma Task_Name ("T3");
      pragma Storage_Size(1000);
      pragma CPU (CPU_0);
   end T3;

   -- Task body
   task body T3 is
      O,P: Vect;
      MR,MS: Matrix;

   begin

      delay 9.0;

      --Start report
      New_Line;
      put("T3 started!");

      --Input F1 data
      New_Line;
      Put("Arguments for F3");

      New_Line;
      Put("Vector P");
      New_Line;
      InputRandomVect(P);
      ShowVect(P);

      New_Line;
      Put("Matrix MR");
      New_Line;
      InputRandomMatrix(MR);
      ShowMatr(MR);

      New_Line;
      Put("Matrix MS");
      New_Line;
      InputRandomMatrix(MS);
      ShowMatr(MS);

      --Computing F3
      F3(P,MR,MS,O);

      -- Show results
      New_Line;
      Put("F3 = ");
      ShowVect(O);

      --Finish report
      New_Line;
      put("T3 finished!");

   end T3;

begin
   Put("Lab 1");
   New_Line;
   Put("Dimension of all vectors and matrix is ");
   Put(n);
   Put(" arguments.");
   if N>5 then
      New_Line;
      Put("Results will not be displayed.");
   end if;
end Main;


