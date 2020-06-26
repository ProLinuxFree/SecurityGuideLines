Files=`/bin/rpm -V audit 2>/dev/null | /bin/grep '^.M' | /bin/awk '{print $NF}'`
if [ ! -z "$Files" ]
  then
  for File in $Files
   do
   RpmPerm=`/bin/rpm -q --queryformat "[%{FILEMODES:perms} %{FILENAMES}\n]" audit | /bin/egrep "[[:space:]]$File$" | /bin/awk '{print $1}'`
   FilePerm=`/bin/ls -ldL "$File" | /bin/awk '{print $1}' | /bin/sed 's/\.//'`
   RpmPermRegEx=`/bin/echo "$RpmPerm" | /bin/awk '{gsub(/[^-]/,".",$0) gsub(/^./,".",$0); print}'`
   /bin/echo "$FilePerm" | /bin/awk '$0 !~ /^'$RpmPerm RegEx'$/{ print "'$File':\n RPM Permissions: '$RpmPerm'\n File Permissions:'$FilePerm'" }'
done
fi