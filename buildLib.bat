: # This is a bash/bat compatible shell
: # and will work on both unix based and windows
: # systems

:<<"::CMDLITERAL"
@ECHO OFF
GOTO :CMDSCRIPT
::CMDLITERAL

$WD=$PWD
$OUTPUT=couchbase.zip
$ZIPBASEDIR=haxelib
$ZIPSUBDIR=couchbase
$ZIPDIR=$ZIPBASEDIR/$ZIPSUBDIR
$DIRTOZIP="src/*"
rm -rf $ZIPBASEDIR
mkdir -p $ZIPDIR
cp -r $DIRTOZIP $ZIPDIR

cd $ZIPBASEDIR
zip -rq $OUTPUT $ZIPSUBDIR
haxelib install $OUTPUT
cd $WD
exit 0

:CMDSCRIPT
@set WD=%CD%
@set OUTPUT=couchbase.zip
@set DIRTOZIP=src
@set ZIPBASEDIR=haxelib
@set ZIPSUBDIR=couchbase
@set ZIPDIR=%ZIPBASEDIR%\%ZIPSUBDIR%

rmdir /S /Q %ZIPBASEDIR% 2>NUL
mkdir %ZIPDIR%
xcopy /yeq %DIRTOZIP% %ZIPDIR% >NUL 2>&1

chdir %ZIPBASEDIR%
"c:\Program Files\WinRAR\WinRAR.exe" a -afzip %OUTPUT% %ZIPSUBDIR%
haxelib install %OUTPUT%
chdir %WD%