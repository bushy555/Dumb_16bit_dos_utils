program DEBUG_to_INCLUDE__PAS;

uses graph, Crt,dos;

var
i:integer;
X: array [0..79] of char;
Y: String;
textin: text;
textout: text;
flag: integer;

begin
   Writeln('DEBUG 2 INCLUDE. By Bushy. Around 19-May-1996. Version 0.001 Alpha Beta.');
   Writeln('Converts a file with dumped DEBUG "D" info to an include file');
   Writeln('Version 2 will have also: RAW2INC.');
   Writeln;
   if ParamCount = 0 then
      BEGIN
         Writeln('Usage: DBG2INC [in-file] [out-file] [name-of-new-info]');
         Writeln;
      END
   ELSE
      BEGIN
         flag := 0;
         Assign(textin, paramstr(1));
         Assign(textout, paramstr(2));
         Reset(textin);
         rewrite(textout);
         for i := 0 to 78 do
            read (textin, X[i]);
         while not eof(textin) do
            begin
               if flag = 0 then
                  begin
                     Y := paramstr(3) + ' ';
                     write(textout,Y);
                     flag := 1;
                  end;
               Y := 'db 0'+X[11]+X[12]+'h,0'+X[14]+X[15]+'h,0'+X[17]+X[18]+'h,0'+X[20]+X[21]+'h,0';
               Y := Y + X[23]+X[24]+'h,0'+X[26]+X[27]+'h,0'+X[29]+X[30]+'h,0'+X[32]+X[33]+'h,0';
               Y := Y + X[35]+X[36]+'h,0'+X[38]+X[39]+'h,0'+X[41]+X[42]+'h,0'+X[44]+X[45]+'h,0';
               Y := Y + X[47]+X[48]+'h,0'+X[50]+X[51]+'h,0'+X[53]+X[54]+'h,0'+X[56]+X[57]+'h';
               writeln (textout, Y);
               for i := 0 to 78 do
                  read (textin, X[i]);
             end;
         close (textout);
         close (textin);
         writeln('Finished.');
      end;
end.
