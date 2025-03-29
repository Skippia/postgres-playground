import { pool } from '@/shared/pool'

/**
 * Найти:
 *  - пользователей, на которых подписаны те, на кого подписан id = 10 (я) (
 *    т.е владельцы каналов на которые подписаны владельцы каналов на которые подписан я) (depth = 2)
 *  (id = 3, id = 8)
 * - пользователей, на которых подписаны пользователя уровня 2 (depth = 3)
 *  (id = 2, id = 6)
 */
export const main = () => {
  pool.query(
    `
    WITH RECURSIVE suggestions(leader_id, follower_id, depth) AS (
        SELECT leader_id, follower_id, 1 as depth
        FROM followers
        WHERE follower_id = 10
      UNION
        SELECT f.leader_id, f.follower_id, s.depth + 1
        FROM followers f
        JOIN suggestions s ON s.leader_id = f.follower_id
        WHERE s.depth < 3
    )

    SELECT DISTINCT users.id, users.username
    FROM suggestions
    JOIN users ON users.id = suggestions.leader_id
    WHERE suggestions.depth > 1
    `
  )
    .then((res) => {
      console.log(res.rows)
    })
    .catch((err) => {
      console.log(err)
    })
}

void main()
