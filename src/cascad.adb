   with ada_io; use ada_io;
   with Ada.Numerics.Elementary_Functions;
   
   procedure cascad is
      type vector is array(integer range <>) of float;
      p: constant integer := 128;
      a: vector(1..p);
      
      procedure fillVector is
      begin
         for i in 1..p loop
            a(i):=float(i)/100.0;
         end loop;
      end fillVector;
     
      procedure seqSum is -- sequential summ
         sum: float := a(1);
      begin
         for i in 2..p loop
            sum := sum + a(i);
         end loop;
         put("Sequential summ: ");
         put(sum,5,3); new_line;
      end seqSum;
      
      procedure cascad(a: in out vector) is
         aLast: constant integer :=a'last;
         v1: vector(1..p);
         v2: vector(1..p);
         operation: integer;
         shift: integer;
         task type item is
            entry get_id(k: in integer);
            entry op;
            entry s;
         end item;
         unit: array(1..p) of item;
         task body item is
            id: integer;
         begin
            accept get_id(k: in integer) do
               id:=k; 
            end get_id;
            v1(id):= 0.0;  
            v2(id):= 0.0;
            loop
               select
                  accept op;
                  case operation is
                     when 1 =>
                        v2(id):=v1(id)+v2(id);
                     when 2 =>
                        if id-shift>0 then
                           v2(id):=v1(id-shift);
                        else
                           v2(id):=0.0;
                        end if;
                     when others => null;
                  end case;
                  accept s;
               or
                  terminate;
               end select;
            end loop;
         end item;
         
         function log2(n: in integer) return integer is
         begin
            return Integer(Ada.Numerics.Elementary_Functions.Log(Float(n), 2.0));  
         end log2;
         
         procedure init is
         begin
            for i in 1..p loop
               unit(i).get_id(i);
            end loop;
         end init;
         
         procedure step is
         begin
            for i in 1..p loop
               unit(i).op;
            end loop;
            for i in 1..p loop
               unit(i).s;
            end loop;
         end step;
         
         function "+"(vv1: in vector;vv2: in vector) return vector is -- override + for vectors
         begin
            v1:=vv1;
            v2:=vv2;
            operation:=1;
            step;
            return v2;
         end "+";
         
         function shiftr(v: in vector; l: in integer) return vector is -- right shifting vector
         begin
            v1:=v;
            shift:=l;
            operation:=2;
            step;
            return v2;
         end shiftr;
         
      begin -- cascad
         init;
         put("Iterations number (for cascade summ): ");
         put(log2(aLast)); new_line;
         for l in 1..log2(aLast) loop -- pows of 2 (1, 2, 4,...)
            a:=a+shiftr(a, 2**(l-1));
         end loop;
      end cascad;
      
   begin -- main
      fillVector;
      seqSum;
      cascad(a);
      put("Cascad summ: ");
      put(a(a'last),5,3); -- due to right shifting
   end cascad;