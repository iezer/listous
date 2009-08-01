CREATE TABLE lists (
	id INT NOT NULL,
	owner VARCHAR (100),
	name VARCHAR (20),
	permissions VARCHAR (10),
	PRIMARY KEY (id)
);

CREATE TABLE items (
	id INT,
	list_id INT,
	author VARCHAR (140),
	content VARCHAR (140),
	fullMessage VARCHAR (140),
	created TIMESTAMP,
	FOREIGN KEY (list_id) REFERENCES lists(id)
	ON DELETE CASCADE
);
