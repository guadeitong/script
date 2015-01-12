create procedure proc_altertableengine()  
begin
  DECLARE tmpTablename varchar(50);
  DECLARE done INT DEFAULT 0;
  DECLARE curRowId INT DEFAULT 0;         
  DECLARE cur1 cursor for select table_name from information_schema.tables as A Where A.table_type='BASE TABLE' AND ENGINE='InnoDB' and table_schema='lzll_gm_app_ptg' ;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1; -- 此句一定要放在光标声明的后面
  open cur1;
  SET @table_name = '';     
  fetch cur1 into tmpTablename;    
  WHILE done = 0 DO    
    set curRowId = curRowId + 1;
    if @table_name = '' then
      set @table_name =  tmpTablename;
    else
      set @table_name = concat(@table_name, tmpTablename);
    end if;
    set @strsql = concat("ALTER TABLE ",tmpTablename ," ENGINE='MyISAM'");
    PREPARE stmt from @strsql ; -- 准备SQL语句
    EXECUTE   stmt;                      -- 执行SQL语句,改奕表的引擎为MyISAM
    fetch cur1 into tmpTablename;    
  END WHILE
  -- 可用此句提示已经完成修改 select '表的引擎修改成功！'
  -- 改变前，可用此句统计'次数  select curRowId;  
  -- 改变前，可用此句统计有那些'InnoDB'表被改变了 select   @table_name ;
  close cur1; 
end;

