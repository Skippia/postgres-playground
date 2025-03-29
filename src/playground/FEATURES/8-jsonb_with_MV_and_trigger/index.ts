import { pool } from '@/shared/pool'

export const main = async () => {
  try {
    // Query products by brand
    const productsByBrand = await pool.query(`SELECT * FROM products WHERE attributes->>'brand' = 'TechMaster';`)

    // Find orders with specific product options
    const orders15Inches = await pool.query(`
      SELECT * FROM orders
      WHERE line_items @> '[{"options": {"size": "15-inch"}}]';
      `)

    const products = await pool.query(`SELECT * FROM products;`)
    const orders = await pool.query(`SELECT * FROM orders;`)
    const product_specs = await pool.query(`SELECT * FROM product_specs;`)

    // Use materialized view for reporting
    const reportingByBrand = await pool.query(`SELECT brand, AVG(weight) FROM product_specs GROUP BY brand;`)

    // Calculate total sales using JSONB function
    const totalSales = await pool.query(`SELECT total_category_sales('electronics');`)

    console.dir({
      // productsByBrand: productsByBrand.rows
      // orders15Inches: orders15Inches.rows,
      orders: orders.rows,
      products: products.rows,
      product_specs: product_specs.rows,
      reportingByBrand: reportingByBrand.rows,
      totalSales: totalSales.rows
    }, {
      depth: null
    })
  } catch (err) {
    console.log(err)
  }
}

void main()


