   with ada_io;use ada_io;
   procedure Contr_1 is
      z: float; -- function zero
      n : integer := 0; -- step number
      
      function f(x: in float) return float is
      begin
         return (x - 5.0)*(x + 4.0)*(x - 1.0) + 0.7;
      end;
      
       pragma INLINE(f);
   	 
      procedure Iter(x1, x2, x3 : in float; res : out float; e : in float) is
         task type p is
            entry set(i: in integer);
            entry start_step;
            entry end_step;
         end p;
         proc: array(1..3) of p; -- 3 proceesses aray
         type points is array (1..3) of float; -- point type
         s: points := (x1,x2,x3); -- old points
         x: points := (0.0,0.0,0.0); -- new points
         eps: float := e;
         d : float := 100.0; -- find min of points |old - new|
         k : integer; -- accumulator for one of three points (necessary)
         
         task body p is
            j,jj:integer;
         begin
            accept set(i: in integer) do
               j:=i; 
            end set;
            if j=3 then -- define next point
               jj:=1;
            else 
               jj:=j+1; 
            end if;
            loop
               select
                  accept start_step;
                  x(j):=s(j)-f(s(j))*(s(j)-s(jj))/(f(s(j))-f(s(jj)));
               or
                  accept end_step;
               or
                  terminate;
               end select; 
            end loop;
         end p;
         
         procedure init is
         begin
            for i in 1..3 loop
               proc(i).set(i);
            end loop;
         end init;
         
         procedure step is
         begin
            for i in 1..3 loop
               proc(i).start_step;
            end loop;
            for i in 1..3 loop
               proc(i).end_step;
            end loop;
            n := n+1;
            put("step number: "); put(n); new_line;
         end step;
         
      begin
         init;
         while d>eps
         loop
            step;
            d := 100.0;
            for i in 1..3 loop
               if abs(s(i)-x(i))<d then -- min accuracy old & new points;
                  begin
                     d := abs(s(i)-x(i));
                     k := i;
                  end;
               end if; 
            end loop;
            s:=x; -- conuted new now old
         end loop;
         res := (s(k) + x(k))/2.0; -- ~ most equal
      end Iter;
      
   begin
      Iter(-7.7, -6.8, -6.2, z, 1.0e-4);
      put(z, 3, 5); new_line;
      Iter(0.7, 0.8, 1.2, z, 1.0e-4);
      put(z, 3, 5); new_line;
      Iter(3.1, 8.4, 20.0, z, 1.0e-4);  
      put(z, 3, 5); new_line;
   
   end Contr_1;