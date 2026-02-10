BEGIN;

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    department VARCHAR(50) NOT NULL,
    employee_name VARCHAR(100) NOT NULL,
    salary NUMERIC(12, 2) NOT NULL
);

INSERT INTO employees (department, employee_name, salary) VALUES
  ('Sales', 'Alice', 5000.00),
  ('Sales', 'Bob', 6000.00),
  ('Sales', 'Charlie', 4000.00);

-- Engineering department
INSERT INTO employees (department, employee_name, salary) VALUES
  ('Engineering', 'Dave', 9000.00),
  ('Engineering', 'Eve', 8000.00),
  ('Engineering', 'Frank', 7000.00);

-- HR department
INSERT INTO employees (department, employee_name, salary) VALUES
  ('HR', 'Gina', 3000.00),
  ('HR', 'Harry', 3500.00),
  ('HR', 'Irene', 2500.00);

COMMIT;

BEGIN;

CREATE TABLE product_groups (
    group_id SERIAL PRIMARY KEY,
    group_name VARCHAR(100) NOT NULL
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    group_id INTEGER NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    CONSTRAINT fk_group
      FOREIGN KEY(group_id)
        REFERENCES product_groups(group_id)
        ON DELETE CASCADE
);

INSERT INTO product_groups (group_name) VALUES
  ('Electronics'),
  ('Clothing'),
  ('Books');


-- Electronics (group_id = 1)
INSERT INTO products (group_id, product_name, price) VALUES
  (1, 'Laptop', 1000.00),
  (1, 'Smartphone', 800.00),
  (1, 'Tablet', 600.00);

-- Clothing (group_id = 2)
INSERT INTO products (group_id, product_name, price) VALUES
  (2, 'Jacket', 100.00),
  (2, 'Jeans', 50.00),
  (2, 'T-shirt', 20.00);

-- Books (group_id = 3)
INSERT INTO products (group_id, product_name, price) VALUES
  (3, 'Textbook', 75.00),
  (3, 'Novel', 15.00),
  (3, 'Magazine', 5.00);

COMMIT;
