unit CompareForProcess;

interface
uses
SysUtils,CustomTypes;

  function CompareNmD(p1 : Pointer; p2 : Pointer): Integer;

  function CompareNmU(p1 : Pointer; p2 : Pointer): Integer;

  function CompareMemD(p1 : Pointer; p2 : Pointer): Integer;

  function CompareMemU(p1 : Pointer; p2 : Pointer): Integer;

  function CompareCpuD(p1 : Pointer; p2 : Pointer): Integer;


  function CompareCpuU(p1 : Pointer; p2 : Pointer): Integer;


  function ComparePriD(p1 : Pointer; p2 : Pointer): Integer;

  function ComparePriU(p1 : Pointer; p2 : Pointer): Integer;


  function CompareUNmD(p1 : Pointer; p2 : Pointer): Integer;


  function CompareUNmU(p1 : Pointer; p2 : Pointer): Integer;

implementation
  function CompareNmD(p1 : Pointer; p2 : Pointer): Integer;
  begin

    Result := CompareStr(LowerCase(TProcessInfo(p2).Name),LowerCase(TProcessInfo(p1).Name));
  end;

  function CompareNmU(p1 : Pointer; p2 : Pointer): Integer;
  begin
    Result := CompareStr(LowerCase(TProcessInfo(p1).Name),LowerCase(TProcessInfo(p2).Name));
  end;

  function CompareMemD(p1 : Pointer; p2 : Pointer): Integer;
  begin
    Result := TProcessInfo(p2).MemUsg - TProcessInfo(p1).MemUsg;
  end;

  function CompareMemU(p1 : Pointer; p2 : Pointer): Integer;
  begin
    Result := TProcessInfo(p1).MemUsg - TProcessInfo(p2).MemUsg;
  end;

  function CompareCpuD(p1 : Pointer; p2 : Pointer): Integer;
  begin

    Result := Trunc( 10* (TProcessInfo(p2).CPUUsg - TProcessInfo(p1).CPUUsg) );
  end;

  function CompareCpuU(p1 : Pointer; p2 : Pointer): Integer;
  begin
    Result := Trunc( 10* (TProcessInfo(p1).CPUUsg - TProcessInfo(p2).CPUUsg) );
  end;

  function StrPriToCaomparable(str :string): Integer;
  begin
    Result := -1;
    if str = 'IDLE'  then  Result := 0;
    if str = 'NORMAL'  then  Result := 1;
    if str = 'ABOVE_NORMAL' then Result := 2;
    if str = 'HIGH'  then  Result := 3;
    if str = 'REALTIME'  then  Result := 4;
  end;

  function ComparePriD(p1 : Pointer; p2 : Pointer): Integer;
  begin
    Result := StrPriToCaomparable(TProcessInfo(p2).Priority) - StrPriToCaomparable(TProcessInfo(p1).Priority);
  end;


  function ComparePriU(p1 : Pointer; p2 : Pointer): Integer;
  begin
    Result := StrPriToCaomparable(TProcessInfo(p1).Priority) - StrPriToCaomparable(TProcessInfo(p2).Priority);
  end;

  function CompareUNmD(p1 : Pointer; p2 : Pointer): Integer;
  begin
    Result := CompareStr(TProcessInfo(p2).UserName,TProcessInfo(p1).UserName);
  end;

  function CompareUNmU(p1 : Pointer; p2 : Pointer): Integer;
  begin
    Result := CompareStr(TProcessInfo(p1).UserName,TProcessInfo(p2).UserName);
  end;

end.
