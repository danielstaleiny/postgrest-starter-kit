create table session (
	id uuid DEFAULT uuid_generate_v4 () primary key,
	user_id int references "user"(id) default request.user_id(),
	device_name text not null,
	csrf text DEFAULT null,
	exp int not null
);
