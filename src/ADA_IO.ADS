with text_io;
package ada_io is
package io is new text_io.integer_io(integer);
package rio is new text_io.float_io(float);
procedure put(s: in string);
procedure new_line;
procedure put(i: in integer);
procedure put(f: in float;a: in integer; b: in integer);
end ada_io;
