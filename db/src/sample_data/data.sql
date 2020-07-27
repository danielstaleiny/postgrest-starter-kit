--
-- fill table data.user (2)
\echo # filling table data.user (2)
COPY data.user (id,name,email,"password") FROM STDIN (FREEZE ON, delimiter ',');
1,alice,alice@email.com,pass
2,bob,bob@email.com,pass
\.
--
--
\echo # filling table data.session (2)
COPY data.session (id,user_id,device_name,csrf,exp) FROM STDIN (FREEZE ON, delimiter ',');
de688895-6181-440f-a25a-8a9ba14b2162,1,test device,null,1598433264
\.
--
-- fill table data.todo (6)
\echo # filling table data.todo (6)
COPY data.todo (id,todo,private,owner_id) FROM STDIN (FREEZE ON, delimiter ',');
1,item_1,FALSE,1
2,item_2,TRUE,1
3,item_3,FALSE,1
4,item_4,TRUE,2
5,item_5,TRUE,2
6,item_6,FALSE,2
\.
-- 
-- restart sequences
ALTER SEQUENCE data.user_id_seq RESTART WITH 3;
ALTER SEQUENCE data.todo_id_seq RESTART WITH 7;
-- 
-- analyze modified tables
ANALYZE data.user;
ANALYZE data.session;
ANALYZE data.todo;
