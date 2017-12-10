if "%ARCH%"=="32" (
    set PLATFORM=Win32
) else (
    set PLATFORM=x64
)

set VSPROJ_EXT="vcxproj"

if "%VS_YEAR%" == "2008" (
  xcopy /s /y /i %RECIPE_DIR%\build.vc9 %SRC_DIR%\build.vc9
  copy %LIBRARY_INC%\stdint.h %SRC_DIR%\
  copy %LIBRARY_INC%\inttypes.h %SRC_DIR%\
  REM VS2008 doesn't like source code files with same names
  for %%s in (mpf mpq mpz mpn\generic) do (
    for /f "delims=" %%i in ('dir /b %%s\*.c') do (
      move %%s\%%i %%s\%%~ns_%%i
    )
  )
  set VSPROJ_EXT="vcproj"
)

cd build.vc%VS_MAJOR%

REM build static library
msbuild.exe /p:Platform=%PLATFORM% /p:Configuration=Release lib_mpir_gc\lib_mpir_gc.%VSPROJ_EXT%
msbuild.exe /p:Platform=%PLATFORM% /p:Configuration=Release lib_mpir_cxx\lib_mpir_cxx.%VSPROJ_EXT%
REM build dll library, cxx is also included.
msbuild.exe /p:Platform=%PLATFORM% /p:Configuration=Release dll_mpir_gc\dll_mpir_gc.%VSPROJ_EXT%

if not exist "%LIBRARY_LIB%" mkdir %LIBRARY_LIB%
if not exist "%LIBRARY_INC%" mkdir %LIBRARY_INC%
if not exist "%LIBRARY_BIN%" mkdir %LIBRARY_BIN%

REM move .lib, .dll and .pdb files to LIBRARY_LIB
move lib_mpir_gc\%PLATFORM%\Release\mpir.lib %LIBRARY_LIB%\mpir_static.lib
move lib_mpir_gc\%PLATFORM%\Release\mpir.pdb %LIBRARY_BIN%\mpir_static.pdb
move lib_mpir_cxx\%PLATFORM%\Release\mpirxx.lib %LIBRARY_LIB%\mpirxx_static.lib
move lib_mpir_cxx\%PLATFORM%\Release\mpirxx.pdb %LIBRARY_BIN%\mpirxx_static.pdb

move dll_mpir_gc\%PLATFORM%\Release\mpir.lib %LIBRARY_LIB%\mpir.lib
move dll_mpir_gc\%PLATFORM%\Release\mpir.dll %LIBRARY_BIN%\mpir.dll
move dll_mpir_gc\%PLATFORM%\Release\mpir.pdb %LIBRARY_BIN%\mpir.pdb

REM create gmp libs to be compatible
copy %LIBRARY_LIB%\mpir_static.lib %LIBRARY_LIB%\gmp_static.lib
copy %LIBRARY_LIB%\mpirxx_static.lib %LIBRARY_LIB%\gmpxx_static.lib
copy %LIBRARY_LIB%\mpir.lib %LIBRARY_LIB%\gmp.lib
copy %LIBRARY_BIN%\mpir.dll %LIBRARY_BIN%\gmp.dll

cd ..
REM move .h files to LIBRARY_INC
move lib\%PLATFORM%\Release\mpir.h %LIBRARY_INC%
move lib\%PLATFORM%\Release\mpirxx.h %LIBRARY_INC%
move lib\%PLATFORM%\Release\gmp.h %LIBRARY_INC%
move lib\%PLATFORM%\Release\gmpxx.h %LIBRARY_INC%

move lib\%PLATFORM%\Release\config.h %LIBRARY_INC%\gmp-config.h
move lib\%PLATFORM%\Release\gmp-impl.h %LIBRARY_INC%
move lib\%PLATFORM%\Release\gmp-mparam.h %LIBRARY_INC%
move lib\%PLATFORM%\Release\longlong.h %LIBRARY_INC%\gmp-longlong.h

dir %LIBRARY_INC%
dir %LIBRARY_LIB%

:TRIM
  SetLocal EnableDelayedExpansion
  set Params=%*
  for /f "tokens=1*" %%a in ("!Params!") do EndLocal & set %1=%%b
  exit /B

