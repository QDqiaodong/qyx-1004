ALTER TABLE dishes
ADD COLUMN max_quantity_per_order INT NOT NULL DEFAULT 10
AFTER is_available;

ALTER TABLE dishes
ADD CONSTRAINT ck_dishes_max_qty CHECK (max_quantity_per_order > 0);
