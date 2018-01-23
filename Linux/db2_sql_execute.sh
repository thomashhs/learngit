###自动执行当前目录所有SQL语句###

#删除当前目录下log日志文件
for test1 in `ls` 
do 
  result3=$( echo $test1 | grep ".log" )
  if [[ $result3 != "" ]]
  then
      rm -f "$result3"
  fi
done

#如果SQL语句有依赖顺序，则进行特殊命名以便于排序
for test1 in `ls` 
do 
  result4=$( echo $test1 | grep "CMTLRTLR" )
  result5=$( echo $test1 | grep "CMTRMTRM" )
  result6=$( echo $test1 | grep "CMTRMSPA" )

  if [[ $result4 != "" ]]
  then
      mv "$result4" "a$result4"    
  fi

  if [[ $result5 != "" ]]
  then
      mv "$result5" "b$result5"    
  fi
  
  if [[ $result6 != "" ]]
  then
      mv "$result6" "c$result6"    
  fi
done

#输入变量以确定数据库执行环境
case $1 in
"FT")
    db2 connect to FB01 user env001 using w54321 >/dev/null;
    db2 set schema CBODDBF1 >/dev/null;
    ;;
"UAT")
    db2 connect to tb01 user env001 using w54321 >/dev/null;
    db2 set schema cboddbs1 >/dev/null;
    ;;
"TST1")
    db2 connect to DB01 user env002 using r45321 >/dev/null;
    db2 set schema CBODDBT1 >/dev/null;
    ;;
"TST2")
    db2 connect to db01 user env004 using r45321 >/dev/null;
    db2 set schema cboddbt2 >/dev/null;
    ;;
"U1")
    db2 connect to ub01 user appusra using w45321 >/dev/null;
    db2 set schema cboddbu1 >/dev/null;
    ;;
*)
    echo "Warning:USAGE: ./test2.sh FT/UAT"  
    exit 1; 
    ;;
esac

#执行SQL语句并形成日志
for test1 in `ls` 
do 
  result3=$( echo $test1 | grep ".sql" )
  if [[ $result3 != "" ]]
  then
      db2 -tvf "$result3" > "$result3".log
  fi
done

#判断成功条数并输出结果至屏幕
for test1 in `ls` 
do 
  result3=$( echo $test1 | grep ".sql.log" )
  if [[ $result3 != "" ]]
  then
        result1=$( cat $result3 | grep -c "successfully" )
        result2=$( cat $result3 | grep -c "SQLSTATE" )

        if [[ $result1 != 0 ]]
        then
                echo "$result3:$result1 success"
        fi

        if [[ $result2 != 0 ]]
        then
                echo "$result3:$result2 unsuccess"
        fi
  fi
done
