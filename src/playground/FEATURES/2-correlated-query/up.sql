BEGIN;

-- Drop the table if it exists for a clean migration run
DROP TABLE IF EXISTS employees;

-- Create the employees table
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    salary NUMERIC(12, 2),
    department VARCHAR(50)
);

-- Insert sample data into employees
-- Sales: Average salary = (5000 + 6000 + 4000)/3 = 5000.00; so Bob (6000) should be returned.
-- Engineering: Average salary = (8000 + 9000 + 7000)/3 = 8000.00; so Eve (9000) should be returned.
-- HR: Average salary = (3000 + 3500 + 2500)/3 = 3000.00; so Harry (3500) should be returned.
-- SoloDepartment: Only one employee so no one is above average.
INSERT INTO employees (name, salary, department) VALUES
  ('Alice',   5000.00, 'Sales'),
  ('Bob',     6000.00, 'Sales'),
  ('Charlie', 4000.00, 'Sales'),
  ('Dave',    8000.00, 'Engineering'),
  ('Eve',     9000.00, 'Engineering'),
  ('Frank',   7000.00, 'Engineering'),
  ('Gina',    3000.00, 'HR'),
  ('Harry',   3500.00, 'HR'),
  ('Irene',   2500.00, 'HR'),
  ('John',    5000.00, 'SoloDepartment');

COMMIT;
