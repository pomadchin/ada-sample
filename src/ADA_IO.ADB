package body ada_io is
procedure put(s: in string) renames text_io.put;
procedure new_line is
begin
text_io.New_Line(1);
end new_line;
procedure put(i: in integer) is 
begin
io.put(i);
end put;
procedure put(f: in float;a: in integer; b: in integer) is
begin
	  rio.put(f,a,b);
end put;
begin
null;
end ada_io;
