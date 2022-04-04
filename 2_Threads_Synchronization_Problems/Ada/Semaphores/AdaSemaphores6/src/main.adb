with Ada.Text_IO, Ada.Integer_Text_IO, Ada.Synchronous_Task_Control;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Synchronous_Task_Control;

procedure Main is

   n: Integer := 4;
   p: Integer := 2;
   h: Integer := n/p;

   -- types
   type Vector is array (1..n) of Integer;
   type Matrix is array (1..n) of Vector;

   R, E, Z, A: Vector;
   MO, MX: Matrix;
   zmax : Integer := Integer'First;

   SU1, SU2, S4, S1, S2, S3 : Suspension_Object;

   -- vector input
   procedure Vector_Input(v : out Vector) is
   begin
      for i in 1..N loop
          v(i) := 1;
      end loop;
   end Vector_Input;

   -- matrix input
   procedure Matrix_Input(m : out Matrix) is
   begin
      for i in 1..N loop
         for j in 1..N loop
            m(i)(j) := 1;
         end loop;
      end loop;
   end Matrix_Input;


   -- procedure with tasks
   procedure start is
      task T1 is
         pragma Storage_Size(999999999);
      end T1;
      task body T1 is
         MO1: Matrix;
         R1: Vector;
         CH:Vector;
         z1: Integer;

        -- matrix multiplying
         function multiplyMatrix(M1 : in Matrix; M2 : in Matrix) return Matrix is
            M3: Matrix;
         begin
            for i in 1..h loop
               for j in 1..n loop
                  M3(i)(j) := 0;
                  for k in 1..n loop
                     M3(i)(j) := M3(i)(j) + M2(i)(k)*M1(k)(j);
                  end loop;
               end loop;
            end loop;
            return M3;
         end multiplyMatrix;

         -- max
         function Max(one : in Integer; two : in Integer) return Integer is
            max : Integer;
         begin
            if one >= two then
               max := one;
            else
               max := two;
            end if;
            return max;
         end Max;

         -- matrix and vector multiplying
         function multiplyVectorMatrix(V : in Vector; M : in Matrix) return Vector is
            V2: Vector;
         begin
            for i in 1..h loop
               V2(i) := 0;
               for j in 1..n loop
                  V2(i) := V2(i) + V(j)*M(i)(j);
               end loop;
            end loop;
            return V2;
         end multiplyVectorMatrix;

      -- beginning of task T1
      begin
         Put_Line("T1 started");

         Matrix_Input(MO);
         Vector_Input(E);
         Vector_Input(R);

         Suspend_Until_True(S1);

         z1 := Z(1);
         for i in 2..h loop
            if Z(i) > z1 then
               z1 := Z(i);
            end if;
         end loop;

         Suspend_Until_True(SU1);
         zmax := Max(z1, zmax);
         Set_True(SU1);

         Set_True(S2);
         Suspend_Until_True(S3);

         Suspend_Until_True(SU2);
         z1 := zmax;
         R1 := R;
         MO1 := MO;
         Set_True(SU2);


         CH := multiplyVectorMatrix(R1, multiplyMatrix(MX, MO1));
         for i in 1..h loop
            A(i) := z1*E(i) + CH(i);
         end loop;




         Set_True(S4);

         Put_Line("T1 finished");

      end T1;

      task T2 is
         pragma Storage_Size(999999999);
      end T2;
      task body T2 is
         MO2: Matrix;
         R2: Vector;
         CH:Vector;
         z2: Integer;

         -- max
         function Max(one : in Integer; two : in Integer) return Integer is
            max : Integer;
         begin
            if one >= two then
               max := one;
            else
               max := two;
            end if;
            return max;
         end Max;

         -- matrix multiplying
         function multiplyMatrix(M1 : in Matrix; M2 : in Matrix) return Matrix is
            M3: Matrix;
         begin
            for i in h+1..n loop
               for j in 1..n loop
                  M3(i)(j) := 0;
                  for k in 1..n loop
                     M3(i)(j) := M3(i)(j) + M2(i)(k)*M1(k)(j);
                  end loop;
               end loop;
            end loop;
            return M3;
         end multiplyMatrix;

         -- matrix and vector multiplying
         function multiplyVectorMatrix(V : in Vector; M : in Matrix) return Vector is
            V2: Vector;
         begin
            for i in h+1..n loop
               V2(i) := 0;
               for j in 1..n loop
                  V2(i) := V2(i) + V(j)*M(i)(j);
               end loop;
            end loop;
            return V2;
         end multiplyVectorMatrix;

      -- beginning of task T2
      begin
         Put_Line("T2 started");

         Vector_Input(Z);
         Z(2):=5;
         Matrix_Input(MX);

         Set_True(S1);

         z2 := Z(h+1);
         for i in h+2..n loop
            if Z(i) > z2 then
               z2 := Z(i);
            end if;
         end loop;

         Suspend_Until_True(SU1);
         zmax := Max(z2, zmax);
         Set_True(SU1);

         Set_True(S3);
         Suspend_Until_True(S2);


         Suspend_Until_True(SU2);
         z2 := zmax;
         R2 := R;
         MO2 := MO;
         Set_True(SU2);

         CH := multiplyVectorMatrix(R2, multiplyMatrix(MX, MO2));
         for i in h+1..n loop
            A(i) := z2*E(i) + CH(i);
         end loop;

         Suspend_Until_True(S4);

         Put_Line("A =");
         if n<=10 then
         for i in 1..n loop
            Put(A(i));
         end loop;
      end if;

         Put_Line("T2 finished");

      end T2;

   begin
      null;
   end start;

begin
   Set_True(SU1);
   Set_True(SU2);
   start;
end Main;
