{$MODE objfpc}

const
  BufSize = 65536;

var
  InF, OutFEven, OutFOdd: File;
  Buf: array [0..BufSize - 1] of Byte;
  BufEven, BufOdd: array [0..(BufSize div 2)  - 1] of Byte;
  BufRead: Integer;
  I : Integer;
begin
  if ParamCount <> 3 then
  begin
    Writeln('Usage: ' + ParamStr(0) + ' <input file> <even file> <odd file>');
    Halt(1);
  end;
  AssignFile(InF, ParamStr(1));
  Reset(InF, 1);
  AssignFile(OutFEven, ParamStr(2));
  Rewrite(OutFEven, 1);
  AssignFile(OutFOdd, ParamStr(3));
  Rewrite(OutFOdd, 1);
  while not EoF(InF) do
  begin
    BlockRead(InF, Buf, BufSize, BufRead);
    if BufRead > 0 then
    begin
      for I := 0 to (BufRead div 2) - 1 do
      begin
        BufEven[I] := Buf[2 * I];
        BufOdd[I] := Buf[2 * I + 1];
      end;
      BlockWrite(OutFEven, BufEven, BufRead div 2);
      BlockWrite(OutFOdd, BufOdd, BufRead div 2);
    end;
  end;
  CloseFile(OutFOdd);
  CloseFile(OutFEven);
  CloseFile(InF);
end.
