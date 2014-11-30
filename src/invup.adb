   with ada_io; use ada_io;
   with Random_Generic;
   with Ada.Numerics.Elementary_Functions;

   procedure invup is
   
      type matrix is array(integer range <>,integer range <>) of Long_Long_Float;
   
      subtype RR is Positive range 1..100; -- for generator of random numbers
      package Rand is
      new Random_Generic(Result_Subtype => RR); -- numbers from 1 to RR
   
      r: constant integer := 20; -- matrix dimension 20x20
      p: integer := r; -- num
      a: matrix(1..r,1..r); -- init matrix
      b: matrix(1..r,1..r); -- A^-1
      c: matrix(1..r,1..r); -- matrix multiply
   
      procedure Fill_Matrix is 
      begin
         for i in 1..r loop
            for j in 1..r loop
               a(i,j) := Long_Long_Float(Rand.Random_Value)/100.0;
               if i>j then a(i,j) := 0.0; end if; -- under diag
            end loop;
         end loop;
      end Fill_Matrix;
   
      procedure printMatrix(a_in:in matrix) is
      begin
         for i in 1..r loop
            for j in 1..r loop
               put(float(a_in(i,j)),5,3);
            end loop;
            new_line;
         end loop;
      end printMatrix;
   
       -- accuracy low far from diag
      function compare(a,b: in Long_Long_Float) return boolean is -- to compare result
      begin
         if abs(a-b)> 0.01 then
            return true; -- error
         else
            return false;
         end if;
      end Compare;
   
      procedure Test_Inv is -- multiply matrix and compare with E
      begin
         new_line;
         put("========= Testing; ========");
         new_line;
         c := (others =>(others => 0.0));
         for i in 1..r loop
            for j in 1..r loop
               for k in 1..r loop
                  c(i,j) := c(i,j) + a(i,k) * b(k,j);
               end loop;
            end loop;
         end loop;
         printMatrix(c);
         for i in 1..r loop
            for j in 1..r loop
               if(i = j) and compare(c(i,j),1.0) then -- a diagonal
                  put("Error("); put(i); put(","); put(j); put(") -");
                  put(float(c(i,j)),5,3); new_line; 
               end if;
               if(i /= j) and compare(c(i,j),0.0) then -- the rest
                  put("Error("); put(i); put(","); put(j); put(") -");
                  put(float(c(i,j)),5,3); new_line;
               end if;
            end loop;
         end loop;
         put("====== End test result ======");
      end Test_Inv;
   
   
      function inv(a:in matrix; p:in integer) return matrix is -- matrix and a flow
         h:integer; -- each process rows num
      
         task type par is
            entry set(ll:in integer);
            entry start;
            entry stop;
         end par;
      
         unit: array(1..p) of par; -- flow arr
      
         task body par is
            l,u:integer;
            s:Long_Long_Float;
         begin
         
            accept set(ll:in integer) do -- get (set) line
               l := ll;  
            end set;
            loop
               select
                  accept start;
                  for col in l+1..r loop
                  
                     s := 0.0; -- result summ
                     for j in 1..col-1 loop
                        s := s+a(j,col)*b(l,j);
                     end loop;
                  
                     b(l,col):= long_long_float(s*(-1.0/a(col,col)));
                  end loop;
                  accept stop;
               or
                  terminate;
               end select;
            end loop;
         
         end par;
      
      begin --begin inv
         b :=(others =>(others => 0.0)); -- null matrix b
         h := r/p; -- rows for each flow
         for i in 1..r loop
            b(i,i) := 1.0/a(i,i); -- main diag ^-1 elements 
         end loop;
      
         for i in 1..p loop
            unit(i).set(i); -- row for flow
         end loop;
         for i in 1..p loop
            unit(i).start;
         end loop;
         for i in 1..p loop
            unit(i).stop;
         end loop;
         return(b);
      end inv;
   
   begin
      Fill_Matrix;
      printMatrix(a);
      b := inv(a,p);
      new_line;
      printMatrix(b);
      Test_Inv;
   end invup;