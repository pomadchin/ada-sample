   with ada_io; use ada_io;
   with Random_Generic;
   with Ada.Numerics.Elementary_Functions;
	
   procedure invup is
      type matrix is array(integer range <>,integer range <>) of Long_Long_Float;
      subtype RR is Positive range 1..10; -- for generator of random numbers
      package Rand is
      new Random_Generic(Result_Subtype => RR); -- numbers from 1 to 100
      p: integer := 5; -- processes
      r: constant integer := 20; -- dimension of a matrix 20x20
      a: matrix(1..r,1..r);
      b: matrix(1..r,1..r);
      c: matrix(1..r,1..r);
      
      procedure fillMatrix is -- to fill matrix
      begin
         for i in 1..r loop
            for j in 1..r loop
               a(i,j) := Long_Long_Float(Rand.Random_Value)/100.0;
               if i>j then a(i,j) := 0.0; end if; -- bottom
            end loop;
         end loop;
      end fillMatrix;
      
      procedure printMatrix(a_in:in matrix) is
      begin
         for i in 1..r loop
            for j in 1..r loop
               put(float(a_in(i,j)),5,3);
            end loop;
            new_line;
         end loop;
      end printMatrix;
      
      function compare(a,b: in Long_Long_Float) return boolean is -- to compare result
      begin
         if abs(a-b)> 0.01 then
            return true; -- error
         else
            return false;
         end if;
      end compare;
      
      procedure Test_Inv is -- to multiply and compare with unit matrix
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
         printMatrix(c); new_line;
         for i in 1..r loop
            for j in 1..r loop
               if(i = j) and compare(c(i,j),1.0) then -- a diagonal
                  put("Error("); put(i); put(","); put(j); put(") -");
                  put(float(c(i,j)),5,3); new_line; end if;
               if(i /= j) and compare(c(i,j),0.0) then -- the rest
                  put("Error("); put(i); put(","); put(j); put(") -");
                  put(float(c(i,j)),5,3); new_line; end if;
            end loop;
         end loop;
         new_line;
         put("====== End test result ======");
      end Test_Inv;
      
      function inv(a:in matrix; p:in integer) return matrix is
         h:integer;
         task type par is
            entry set(ll,uu:in integer);
         end par;
         unit: array(1..p) of par;
         
         task body par is
            l,u:integer;
            s:Long_Long_Float;
         begin
            accept set(ll,uu:in integer) do
               l := ll; u := uu; end set;
            for col in l..u loop
               for row in reverse 1..col-1 loop -- !!!
                  s := 0.0;
                  for j in row+1..col loop
                     s := s+a(row,j)*b(j,col);
                  end loop;
                  b(row,col) := -s*b(row,row);
               end loop;
            end loop;
         end par;
      	
      begin
         b :=(others =>(others => 0.0)); -- nulling matrix b
         h := r/p;
         for i in 1..r loop -- on main diag elements ^-1 to default
            b(i,i) := 1.0/a(i,i);
         end loop;
         for i in 1..p loop -- under diag
            unit(i).set((i-1) *h+1,i*h);
         end loop;
         return(b);
      end inv;
   	
   begin
      fillMatrix;
      printMatrix(a); new_line;
      b := inv(a,p);
      put("+++"); new_line;
      printMatrix(b); new_line;
      Test_Inv;
   end invup;