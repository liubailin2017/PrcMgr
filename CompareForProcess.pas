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
    Result := CompareStr(TProcessInfo(p2).Name,TProcessInfo(p1).Name);
  end;

  function CompareNmU(p1 : Pointer; p2 : Pointer): Integer;
  begin
    Result := CompareStr(TProcessInfo(p1).Name,TProcessInfo(p2).Name);
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

  function ComparePriD(p1 : Pointer; p2 : Pointer): Integer;
  begin
    Result := CompareStr(TProcessInfo(p2).Priority,TProcessInfo(p1).Priority);
  end;

  function ComparePriU(p1 : Pointer; p2 : Pointer): Integer;
  begin
    Result := CompareStr(TProcessInfo(p1).Priority,TProcessInfo(p2).Priority);
  end;

  function CompareUNmD(p1 : Pointer; p2 : Pointer): Integer;
  begin
    Result := CompareStr(TProcessInfo(p2).UserName,TProcessInfo(p1).UserName);
  end;

  function CompareUNmU(p1 : Pointer; p2 : Pointer): Integer;
  begin
    Result := CompareStr(TProcessInfo(p1).Priority,TProcessInfo(p2).Priority);
  end;

end.
