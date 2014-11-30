
with ada_io;use ada_io;
procedure Find0 is
z:float;

function find(L,R:in float)return float is
 N:constant integer:=10;
  z:float;

function fp(x:in float)return float is
   begin--fp
    return 2.0*x-15.0;
   end fp;
pragma INLINE(fp);

 task type p is
  entry new_b(L,R:in float);
 end p;
 
 task total is
  entry b(L,R:in float);
  entry result(z:out float);
 end total;
 
 process:array(1..N) of p;
 
 task body p is
  LL:float;
  RR:float;
  
 begin--p
  loop
   select
    accept new_b(L,R:in float) do
     LL:=L;RR:=R;
    end new_b;
          if fp(LL)=0.0 then
          total.b(LL,LL);
          end if;
    if fp(LL)*fp(RR)<0.0 then
     total.b(LL,RR);
    end if;
    or
     terminate;
    end select;
   end loop;
  end p;
  
  task body total is
   e:constant float:=0.1E-4;
   LL:float:=0.0;
   RR:float:=10.0;
   l,u:float;
   begin--total
   loop
      accept b(L,R:in float)do
       LL:=L;RR:=R;
      end b;
     if abs(RR-LL)<e then exit; end if;
     for i in 0..N-1 loop
     l:=LL+((RR-LL)/float(N))*float(i);
     u:=LL+((RR-LL)/float(N))*float(i+1);
     put(l,3,5);put(",");put(u,3,5);new_line;
      process(i+1).new_b(l,u);
     end loop;
   end loop;
   accept result(z:out float)do
    z:=RR;
   end result;
  end total;
  
 
  begin--find
   total.b(L,R);
   total.result(z);
   return z;
  end find;
 begin--main
  z:=find(0.0,10.0);
  put("x=");put(z,3,5);new_line;
  put("y=");put(2.0*z - 15.0,3,5);
 end Find0;   
  
                          
         
 
    
