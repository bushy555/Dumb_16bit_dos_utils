program DEBUG_to_INCLUDE__PAS;

uses graph, Crt,dos;

var
i:integer;
X: array [0..15] of char;
Y: String;
textin: text;
textout: text;
flag: integer;



begin
   Writeln('RAW 2 INCLUDE. By Bushy. Around 22-May-1996. Version 0.001 Alpha Beta.');
   Writeln('Converts a raw image file, such as a .EXE or a .COM to an include file');
   Writeln('Version 2 may work... This also fills out with the <ESC> (026d). Edit it!');
   Writeln;
   if ParamCount = 0 then
      BEGIN
         Writeln('Usage: RAW2INC [in-file] [out-file] [name-of-new-info]');
         Writeln;
      END
   ELSE
      BEGIN
         flag := 0;
         Assign(textin, paramstr(1));
         Reset(textin);
         while not eof(textin) do
            begin
                  read (textin, X[0]);
                  yardi;
                  write (textout, ord(X[0]));
                  write (textout, ', ');
                  read (textin, X[1]);
                  yardi;
                  write (textout, ord(X[1]));
                  write (textout, ', ');
                  read (textin, X[2]);
                  yardi;
                  write (textout, ord(X[2]));
                  write (textout, ', ');
                  read (textin, X[3]);
                  yardi;
                  write (textout, ord(X[3]));
                  write (textout, ', ');
                  read (textin, X[4]);
                  yardi;
                  write (textout, ord(X[4]));
                  write (textout, ', ');
                  read (textin, X[5]);
                  yardi;
                  write (textout, ord(X[5]));
                  write (textout, ', ');
                  read (textin, X[6]);
                  yardi;
                  write (textout, ord(X[6]));
                  write (textout, ', ');
                  read (textin, X[7]);
                  yardi;
                  write (textout, ord(X[7]));
                  write (textout, ', ');
                  read (textin, X[8]);
                  yardi;
                  write (textout, ord(X[8]));
                  write (textout, ', ');
                  read (textin, X[9]);
                  yardi;
                  write (textout, ord(X[9]));
                  write (textout, ', ');
                  read (textin, X[10]);
                  yardi;
                  write (textout, ord(X[10]));
                  write (textout, ', ');
                  read (textin, X[11]);
                  yardi;
                  write (textout, ord(X[11]));
                  write (textout, ', ');
                  read (textin, X[12]);
                  yardi;
                  write (textout, ord(X[12]));
                  write (textout, ', ');
                  read (textin, X[13]);
                  yardi;
                  write (textout, ord(X[13]));
                  write (textout, ', ');
                  read (textin, X[14]);
                  yardi;
                  write (textout, ord(X[14]));
                  write (textout, ', ');
                  read (textin, X[15]);
                  yardi;
                  writeln (textout, ord(X[15]));
            end;
         close (textout);
         close (textin);
         writeln('Finished.');
      end;
end.


{
******* THE BELOW CAN, sorry I will stop shouting, also be used for the
 above stuff. Does exact same stuff. Maybe a little bit slower, due to
 array looping and stuff. may be faster. who knows?

         for i := 0 to 15 do
            read (textin, X[i]);
         while not eof(textin) do
            begin
               if flag = 0 then
                  begin
                     Y := paramstr(3) + ' ';
                     write(textout,Y);
                     flag := 1;
                  end;
                  write (textout, 'db ');
                  for i := 0 to 15 do
                     begin
                        if (ord(X[i])< 10) then
                           write(textout, '00')
                        Else
                           if (ord(X[i])>9) and (ord(X[i])<100) then
                              write(textout, '0');
                        write (textout, ord (X[i]));
                        if (i < 15) then
                           write (textout, ', ');
                     end;
                  writeln (textout);
                  for i := 0 to 15 do
                     read (textin, X[i]);
            end;
         write (textout, 'db ');
         for i := 0 to 15 do
            begin
               if (ord(X[i])< 10) then
                  write(textout, '00')
               Else
                  if (ord(X[i])< 100) then
                     write(textout, '0');
               write (textout, ord (X[i]));
               if (i < 15) then
                  write (textout, ', ');
            end;
         writeln (textout);
}



