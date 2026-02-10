import { pool } from '@/shared/pool'

export const main = async () => {
  try {

    await pool.query(
      `
    INSERT INTO reservations (room_id, booking_status, start_date, end_date)
    VALUES (1, 'CONFIRMED', '2025-01-12 14:00:00', '2025-01-18 12:00:00');

    INSERT INTO reservations (room_id, booking_status, start_date, end_date)
    VALUES (2, 'CONFIRMED', '2025-01-12 14:00:00', '2025-01-18 12:00:00');
    
    -- Cancel reservation for room_id = 2
    UPDATE reservations SET booking_status = 'CANCELED' WHERE room_id = 2;

    -- Inserting new reservation for exact room_id and period
    INSERT INTO reservations (room_id, booking_status, start_date, end_date)
    VALUES (2, 'CONFIRMED', '2025-01-12 14:00:00', '2025-01-18 12:00:00');
    `
    )

  } catch (err) {
    console.log((err as Error).message)
  } finally {
    const { rows } = await pool.query(
      `SELECT * FROM "reservations"`
    )

    console.log(rows)
  }

}

void main()
